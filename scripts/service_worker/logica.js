// A lógica do service worker do app web (a parte que não muda entre builds).
//
// Este arquivo NÃO é publicado sozinho: scripts/gerar_service_worker.mjs cola
// na frente dele um cabeçalho com as constantes de cada build —
//
//   const VERSAO = '…';            // md5 do manifesto inteiro
//   const RECURSOS = {…};          // caminho → md5 de cada arquivo do build
//   const NUCLEO = […];            // a casca que o install baixa de uma vez
//   const ROTAS_ESTATICAS = […];   // o que NÃO é o app (/sobre, legais, QR)
//
// — e grava tudo num único sw.js. Um arquivo só, de propósito: o navegador
// só reinstala um service worker quando os BYTES do script mudam, e o
// manifesto embutido é o que muda a cada publicação. Com importScripts o
// navegador poderia (e alguns fazem) reaproveitar o script importado do cache
// HTTP e nunca enxergar a versão nova.
//
// O PORQUÊ de existir: o Flutter 3.35 descontinuou o service worker dele e o
// 3.47 gera um STUB que se desregistra ao ativar. Sem SW nenhum, nada fica em
// cache, e o app web — que é o único caminho no iPhone — mostrava a página de
// erro do navegador sem rede, mesmo com a pessoa logada e todos os dados no
// SQLite local. Este SW devolve o offline: a casca do app é baixada na
// instalação, o resto entra no cache conforme é usado (ou por aquecimento) e,
// sem rede, qualquer rota do app abre a partir do cache.
//
// JavaScript clássico, sem módulos: o escopo de um service worker é o
// script inteiro, e `const` no topo aqui é o que o cabeçalho gerado usa.

/* global VERSAO, RECURSOS, NUCLEO, ROTAS_ESTATICAS */

// Um cache por versão para o app e um temporário para a instalação: assim a
// versão que está servindo continua inteira até a nova estar completa, e uma
// instalação interrompida (aba fechada no meio) não deixa a casca pela
// metade — o que ficou é só o temp, que a próxima instalação refaz.
const CACHE_APP = 'gdb-app-' + VERSAO;
const CACHE_TEMP = 'gdb-temp-' + VERSAO;
// Guarda o RECURSOS da versão instalada: é o que permite, na atualização,
// reaproveitar do cache antigo os arquivos cujo md5 não mudou — sem baixar
// de novo 7 MB de CanvasKit porque uma imagem de conteúdo mudou.
const CACHE_MANIFESTO = 'gdb-manifesto';
// As fontes do Google (Nunito, Cinzel Decorative, Lora) que google_fonts busca
// em tempo de execução. Não versionado: a fonte com aquele nome de arquivo é
// sempre a mesma, e apagá-la a cada publicação seria baixar de novo à toa.
const CACHE_FONTES = 'gdb-fontes-v1';

const HOSTS_DE_FONTES = ['fonts.gstatic.com', 'fonts.googleapis.com'];

// Prazo da tentativa online da casca. Uma rede "conectada mas sem internet"
// (Wi-Fi de portão, sinal de uma barra) não falha: pendura. Sem prazo, o app
// ficaria na tela branca por quanto tempo o navegador quisesse esperar, com a
// versão inteira no cache ao lado. Exposto em `self.GDB_PRAZO_MS` para o
// teste encurtar.
const PRAZO_PADRAO_MS = 4000;

// A chave do índice no cache. O Cloudflare redireciona /index.html → / (URLs
// limpas), então a casca vive sob '/', que é o que o navegador de fato pede.
const CHAVE_DA_CASCA = '/';

// O arquivo de índice, como aparece em RECURSOS. Qualquer pedido dele é um
// pedido da casca.
const ARQUIVO_DA_CASCA = 'index.html';

function urlDe(caminho) {
  return new URL(caminho, self.location.origin).href;
}

// O caminho de um pedido como chave de RECURSOS: sem a barra inicial e sem a
// query (`?v=…` de cache busting não muda o arquivo). Decodifica porque
// RECURSOS guarda o nome do arquivo em disco e a URL pode vir escapada.
function chaveDe(url) {
  const caminho = url.pathname.replace(/^\//, '');
  try {
    return decodeURIComponent(caminho);
  } catch (_) {
    return caminho;
  }
}

function temRecurso(chave) {
  return Object.prototype.hasOwnProperty.call(RECURSOS, chave);
}

// Onde cada recurso é guardado no cache: o índice sob '/', o resto sob o
// próprio caminho.
function urlDoRecurso(chave) {
  return urlDe(chave === ARQUIVO_DA_CASCA ? CHAVE_DA_CASCA : chave);
}

// A chave de RECURSOS que uma entrada do cache representa (o inverso de
// urlDoRecurso): a entrada '/' é o index.html.
function chaveDaEntrada(url) {
  const chave = chaveDe(url);
  return chave === '' ? ARQUIVO_DA_CASCA : chave;
}

function eRotaEstatica(caminho) {
  return ROTAS_ESTATICAS.some(function (prefixo) {
    return caminho === prefixo || caminho.startsWith(prefixo + '/');
  });
}

// Uma navegação é do app quando não é página estática nem arquivo solto
// (/robots.txt, /sitemap.xml, /version.txt): esses o navegador busca sozinho,
// e sem rede a resposta certa para eles é o erro do navegador — não a casca
// do app fingindo ser um robots.txt.
function navegacaoEDoApp(url) {
  const chave = chaveDe(url);
  if (eRotaEstatica(url.pathname)) return false;
  const ultimoSegmento = chave.split('/').pop();
  const temExtensao = /\.[A-Za-z0-9]+$/.test(ultimoSegmento);
  if (temExtensao && !temRecurso(chave)) return false;
  return true;
}

function comPrazo(promessa, ms) {
  return new Promise(function (resolver, rejeitar) {
    const temporizador = setTimeout(function () {
      rejeitar(new Error('prazo de ' + ms + ' ms esgotado'));
    }, ms);
    promessa.then(
      function (valor) {
        clearTimeout(temporizador);
        resolver(valor);
      },
      function (erro) {
        clearTimeout(temporizador);
        rejeitar(erro);
      }
    );
  });
}

async function lerManifestoAnterior(cacheManifesto) {
  try {
    const guardado = await cacheManifesto.match(urlDe(CACHE_MANIFESTO));
    if (!guardado) return {};
    const dados = await guardado.json();
    return dados && typeof dados === 'object' ? dados : {};
  } catch (_) {
    // Manifesto ilegível é o mesmo que nenhum: tudo se baixa de novo.
    return {};
  }
}

// INSTALL: baixa a casca inteira para o cache temporário.
//
// `cache: 'no-cache'` revalida cada arquivo com o servidor (etag) em vez de
// aceitar o que o cache HTTP do navegador tiver — e, quando o etag bate, o
// navegador reaproveita o corpo sem baixar de novo. É o que evita baixar o
// main.dart.js duas vezes na primeira visita (uma pela página, outra aqui).
//
// `skipWaiting` porque não há motivo para a versão nova esperar todas as abas
// fecharem: o index.html recarrega sozinho em `controllerchange`.
self.addEventListener('install', function (event) {
  self.skipWaiting();
  event.waitUntil(
    (async function () {
      const temp = await caches.open(CACHE_TEMP);
      await temp.addAll(
        NUCLEO.map(function (caminho) {
          return new Request(urlDoRecurso(caminho), { cache: 'no-cache' });
        })
      );
    })()
  );
});

// ACTIVATE: monta o cache da versão e apaga o que sobrou.
//
// A migração reaproveita do cache antigo tudo o que continua em RECURSOS com
// o MESMO md5 (segundo o manifesto que estava instalado) — o cache "antigo"
// pode ser o de outra versão ou o desta mesma, se uma ativação anterior parou
// no meio. Depois copia o temp por cima (o núcleo recém-baixado ganha),
// grava o manifesto novo e apaga: o temp, os caches de outras versões e
// qualquer `flutter-*` (flutter-app-cache, flutter-temp-cache,
// flutter-app-manifest — o SW antigo do Flutter deixou isso para trás em
// quem visitava o site antes da 3.47).
self.addEventListener('activate', function (event) {
  event.waitUntil(
    (async function () {
      await self.clients.claim();

      const app = await caches.open(CACHE_APP);
      const temp = await caches.open(CACHE_TEMP);
      const cacheManifesto = await caches.open(CACHE_MANIFESTO);
      const anterior = await lerManifestoAnterior(cacheManifesto);

      for (const nome of await caches.keys()) {
        if (!nome.startsWith('gdb-app-')) continue;
        const antigo = await caches.open(nome);
        for (const pedido of await antigo.keys()) {
          const chave = chaveDaEntrada(new URL(pedido.url));

          // O cache DESTA versão não precisa do manifesto para ser julgado: o
          // nome dele é o md5 do manifesto inteiro, então tudo o que está
          // dentro foi escrito por um service worker com este mesmo RECURSOS e
          // é, por construção, o arquivo certo. Conferir contra o manifesto
          // ANTERIOR aqui apagaria o que o aquecimento acabou de guardar — na
          // primeira visita ele chega assim que o `clients.claim()` acima
          // resolve, com esta ativação ainda correndo, e o manifesto anterior
          // é vazio, então TUDO pareceria velho. A segunda visita offline
          // abriria sem renderizador, que é justamente o que o aquecimento
          // existe para evitar.
          if (nome === CACHE_APP) {
            if (!temRecurso(chave)) await app.delete(pedido);
            continue;
          }

          if (temRecurso(chave) && anterior[chave] === RECURSOS[chave]) {
            const resposta = await antigo.match(pedido);
            if (resposta) await app.put(pedido, resposta);
          }
        }
      }

      for (const pedido of await temp.keys()) {
        const resposta = await temp.match(pedido);
        if (resposta) await app.put(pedido, resposta);
      }
      await caches.delete(CACHE_TEMP);

      await cacheManifesto.put(
        urlDe(CACHE_MANIFESTO),
        new Response(JSON.stringify(RECURSOS), {
          headers: { 'content-type': 'application/json' },
        })
      );

      for (const nome of await caches.keys()) {
        const doFlutter = nome.startsWith('flutter-');
        const deOutraVersao =
          (nome.startsWith('gdb-app-') || nome.startsWith('gdb-temp-')) && nome !== CACHE_APP;
        if (doFlutter || deOutraVersao) await caches.delete(nome);
      }
    })()
  );
});

// A casca, online-first com prazo.
//
// Online-first (e não cache-first) porque o index.html é o ponto de entrada:
// é ele que aponta para o flutter_bootstrap.js, e uma publicação nova precisa
// chegar pela rede na primeira recarga. O prazo é o que faz o offline
// funcionar numa rede que pendura em vez de falhar.
async function servirCasca(request) {
  const app = await caches.open(CACHE_APP);
  const prazo = typeof self.GDB_PRAZO_MS === 'number' ? self.GDB_PRAZO_MS : PRAZO_PADRAO_MS;
  // A tentativa de rede é guardada fora do `comPrazo`: quando o prazo vence e
  // NÃO há casca no cache, é ela que continua valendo (ver abaixo).
  const daRede = fetch(request);
  try {
    const resposta = await comPrazo(daRede, prazo);

    // Resposta redirecionada NÃO entra no cache: o navegador recusa servir uma
    // resposta redirecionada para uma navegação, e a casca guardada assim
    // deixaria o app sem abrir offline — um defeito que só apareceria depois,
    // longe da publicação que o causou.
    if (resposta.ok && !resposta.redirected) {
      await app.put(urlDe(CHAVE_DA_CASCA), resposta.clone());
      return resposta;
    }

    // Erro DO SERVIDOR (a borda fora do ar, um 502 de implantação): a casca
    // guardada abre o app, e o app fala com o Supabase por conta própria. Só
    // 5xx — um 404 ou um redirecionamento são respostas legítimas, e trocá-las
    // pela casca esconderia o endereço errado em vez de mostrá-lo.
    if (resposta.status >= 500) {
      const guardada = await app.match(urlDe(CHAVE_DA_CASCA));
      if (guardada) return guardada;
    }
    return resposta;
  } catch (erro) {
    const guardada = await app.match(urlDe(CHAVE_DA_CASCA));
    if (guardada) return guardada;
    // Sem casca no cache não há o que servir do lado de cá. O prazo existe
    // para PREFERIR o cache numa rede que pendura, não para desistir de uma
    // conexão lenta: na primeira visita (nada guardado ainda) desistir aos 4 s
    // trocaria uma espera por uma página de erro. Então espera a rede até o
    // fim — e, se ela falhar de verdade, o erro segue para o navegador, que
    // mostra a própria página.
    const tardia = await daRede;
    if (tardia.ok && !tardia.redirected) {
      await app.put(urlDe(CHAVE_DA_CASCA), tardia.clone());
    }
    return tardia;
  }
}

// Um recurso do build, cache-first.
//
// O nome de cada arquivo está em RECURSOS com o md5 desta versão, e o cache é
// desta versão: o que está lá é o arquivo certo, sem perguntar ao servidor.
// `ignoreSearch` porque o Flutter pode pedir `main.dart.js?v=…`; a chave no
// cache é o caminho limpo. Só resposta `ok` entra no cache: um 404 ou um 503
// guardado ficaria sendo servido até a próxima publicação.
async function servirRecurso(request, chave) {
  const app = await caches.open(CACHE_APP);
  const guardada = await app.match(request, { ignoreSearch: true });
  if (guardada) return guardada;
  const resposta = await fetch(request);
  if (resposta.ok) await app.put(urlDoRecurso(chave), resposta.clone());
  return resposta;
}

// As fontes do Google, cache-first no cache que não é versionado.
async function servirFonte(request) {
  const fontes = await caches.open(CACHE_FONTES);
  const guardada = await fontes.match(request);
  if (guardada) return guardada;
  const resposta = await fetch(request);
  if (resposta.ok) await fontes.put(request, resposta.clone());
  return resposta;
}

// FETCH: decide SINCRONAMENTE se responde — `respondWith` fora do tique do
// evento é erro no navegador. Quem não é nosso (Supabase, RevenueCat,
// accounts.google.com, www.gstatic.com, /version.txt) passa direto.
self.addEventListener('fetch', function (event) {
  const request = event.request;
  if (request.method !== 'GET') return;

  const url = new URL(request.url);
  if (url.origin === self.location.origin) {
    const chave = chaveDe(url);
    if (request.mode === 'navigate' || chave === '' || chave === ARQUIVO_DA_CASCA) {
      if (!navegacaoEDoApp(url)) return;
      event.respondWith(servirCasca(request));
      return;
    }
    if (temRecurso(chave)) {
      event.respondWith(servirRecurso(request, chave));
    }
    return;
  }

  if (HOSTS_DE_FONTES.includes(url.hostname)) {
    event.respondWith(servirFonte(request));
  }
});

// AQUECIMENTO: guarda o que a página já baixou por fora do service worker.
//
// Na PRIMEIRA visita o SW ainda não controla a página quando ela baixa o
// CanvasKit, o wasm e as fontes — esses pedidos nunca passam pelo `fetch`
// acima. O index.html manda a lista de recursos que a página carregou
// (performance.getEntriesByType('resource')) e aqui cada um que é nosso e
// ainda não está no cache é buscado (revalidando; o cache HTTP reaproveita o
// corpo). Sem isto, a segunda visita offline abriria sem renderizador.
// Oportunista de propósito: erro individual não derruba os outros.
async function aquecer(urls) {
  const app = await caches.open(CACHE_APP);
  const fontes = await caches.open(CACHE_FONTES);
  for (const texto of urls) {
    try {
      const url = new URL(texto, self.location.origin);
      let cache;
      let chaveNoCache;
      if (url.origin === self.location.origin) {
        const chave = chaveDe(url);
        if (!temRecurso(chave)) continue;
        cache = app;
        chaveNoCache = urlDoRecurso(chave);
      } else if (HOSTS_DE_FONTES.includes(url.hostname)) {
        cache = fontes;
        chaveNoCache = url.href;
      } else {
        continue;
      }
      await guardarSeFaltar(cache, chaveNoCache);
    } catch (_) {
      // Aquecimento é oportunista: o que não entrou agora entra no próximo.
    }
  }
}

// AQUECIMENTO DE FUNDO: completa o cache com o que ninguém pediu ainda.
//
// O cache preguiçoso só guarda o que a pessoa VISITOU. Quem abriu o app,
// ficou no Seu Dia e depois perdeu a rede encontrava a tela do Conselheiro
// sem a bola de cristal, a erva sem foto, a carta sem ilustração — o app
// abria, mas pela metade, e pela metade é o tipo de defeito que parece
// aleatório para quem usa. Aqui o resto do build entra em segundo plano,
// uma requisição por vez, depois que o app já está de pé.
//
// FORA o `canvaskit/`: são três variantes (~7 MB cada) e o navegador usa UMA.
// A que ele usa já entra por outro caminho — pelo aquecimento oportunista na
// primeira visita, e pelo `fetch` normal da segunda em diante, quando o SW já
// controla a página. Baixar as outras duas seria jogar 14 MB fora.
//
// Quem decide QUANDO chamar é o index.html, que também respeita a economia de
// dados do aparelho: isto aqui é o braço, não a cabeça.
async function aquecerTudo() {
  const app = await caches.open(CACHE_APP);
  for (const chave of Object.keys(RECURSOS)) {
    if (chave.startsWith('canvaskit/')) continue;
    try {
      await guardarSeFaltar(app, urlDoRecurso(chave));
    } catch (_) {
      // Idem: um arquivo que não veio agora vem no próximo aquecimento.
    }
  }
}

// Busca e guarda, se ainda não estiver no cache. `cache: 'no-cache'` revalida
// com o servidor, então um arquivo que o navegador já tem no cache HTTP não é
// baixado de novo — só confirmado.
async function guardarSeFaltar(cache, chaveNoCache) {
  if (await cache.match(chaveNoCache)) return;
  const resposta = await fetch(new Request(chaveNoCache, { cache: 'no-cache' }));
  if (resposta.ok) await cache.put(chaveNoCache, resposta);
}

self.addEventListener('message', function (event) {
  const dados = event.data;
  if (!dados) return;

  let trabalho = null;
  if (dados.tipo === 'aquecer' && Array.isArray(dados.urls)) {
    trabalho = aquecer(dados.urls);
  } else if (dados.tipo === 'aquecer-tudo') {
    trabalho = aquecerTudo();
  }
  if (trabalho && typeof event.waitUntil === 'function') event.waitUntil(trabalho);
});
