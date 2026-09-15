// O service worker do app web (scripts/gerar_service_worker.mjs +
// scripts/service_worker/logica.js) só existe depois da montagem e roda
// dentro do navegador: `flutter test` nunca chega perto dele. Este é o único
// gate que o exercita — e o que ele protege só aparece sem rede, no celular
// de alguém, longe de qualquer console: uma casca que não entra no cache, um
// prazo que não vence, um 404 guardado até a próxima publicação.
//
// Duas metades: o gerador contra um build/web falso em pasta temporária, e o
// sw.js GERADO rodando num `vm` com dublês de `self`, `caches` e `fetch` — o
// mesmo arquivo que a montagem publica, não uma cópia da lógica.
//
// Uso: node test/service_worker_test.mjs
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import url from 'node:url';
import vm from 'node:vm';

import { DOCUMENTOS } from '../scripts/gerar_paginas_legais.mjs';
import {
  ROTAS_ESTATICAS,
  calcularManifesto,
  gerarServiceWorker,
  listarArquivos,
} from '../scripts/gerar_service_worker.mjs';

const RAIZ = path.dirname(path.dirname(url.fileURLToPath(import.meta.url)));
const ORIGEM = 'https://grimoriodebolso.app';

const md5 = (conteudo) => crypto.createHash('md5').update(conteudo).digest('hex');

// ---------------------------------------------------------------------------
// O build/web falso: o suficiente para o gerador ter o que escolher e o que
// deixar de fora.
// ---------------------------------------------------------------------------

const ARQUIVOS_DO_BUILD = {
  'index.html': '<!DOCTYPE html><html><body>casca</body></html>',
  'flutter_bootstrap.js': '_flutter.buildConfig = {"useLocalCanvasKit":true};',
  'main.dart.js': 'console.log("app")',
  'canvaskit/canvaskit.js': 'canvaskit',
  'canvaskit/canvaskit.wasm': 'wasm-canvaskit',
  'canvaskit/chromium/canvaskit.wasm': 'wasm-chromium',
  'assets/AssetManifest.bin.json': '{}',
  'assets/images/x.png': 'png',
};
const ARQUIVOS_IGNORADOS = {
  'flutter_service_worker.js': '',
  'main.dart.js.map': '{"mappings":""}',
  'canvaskit/canvaskit.js.symbols': 'simbolos',
};

function criarBuildFalso() {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'gdb-sw-'));
  for (const [caminho, conteudo] of Object.entries({ ...ARQUIVOS_DO_BUILD, ...ARQUIVOS_IGNORADOS })) {
    const destino = path.join(dir, caminho);
    fs.mkdirSync(path.dirname(destino), { recursive: true });
    fs.writeFileSync(destino, conteudo);
  }
  return dir;
}

// ---------------------------------------------------------------------------
// 1. O gerador
// ---------------------------------------------------------------------------

test('calcularManifesto: md5 de cada arquivo, sem stub, mapa nem símbolos', () => {
  const dir = criarBuildFalso();
  const { recursos, nucleo, versao } = calcularManifesto(dir);

  for (const [caminho, conteudo] of Object.entries(ARQUIVOS_DO_BUILD)) {
    assert.equal(recursos[caminho], md5(conteudo), `md5 errado para ${caminho}`);
  }
  for (const caminho of Object.keys(ARQUIVOS_IGNORADOS)) {
    assert.ok(!(caminho in recursos), `${caminho} não deveria estar no manifesto`);
  }
  assert.deepEqual(Object.keys(recursos), Object.keys(ARQUIVOS_DO_BUILD).sort());
  assert.deepEqual(listarArquivos(dir), Object.keys(ARQUIVOS_DO_BUILD).sort());

  // O núcleo é um subconjunto dos recursos, traz a casca e deixa o CanvasKit
  // (7 MB por variante) para o cache preguiçoso.
  for (const caminho of nucleo) assert.ok(caminho in recursos, `${caminho} no núcleo mas fora dos recursos`);
  for (const esperado of ['index.html', 'flutter_bootstrap.js', 'main.dart.js', 'assets/AssetManifest.bin.json']) {
    assert.ok(nucleo.includes(esperado), `${esperado} deveria estar no núcleo`);
  }
  assert.ok(!nucleo.some((c) => c.startsWith('canvaskit/')), 'canvaskit não pode estar no núcleo');
  assert.ok(!nucleo.includes('assets/images/x.png'), 'imagem de conteúdo não é núcleo');

  // A versão é função do conteúdo: um byte diferente é outra versão — e é a
  // versão que faz o navegador enxergar um sw.js novo.
  assert.match(versao, /^[0-9a-f]{32}$/);
  fs.writeFileSync(path.join(dir, 'main.dart.js'), 'console.log("app v2")');
  assert.notEqual(calcularManifesto(dir).versao, versao);
  // E é estável: o mesmo build dá a mesma versão.
  assert.equal(calcularManifesto(dir).versao, calcularManifesto(dir).versao);
});

test('ROTAS_ESTATICAS cobre exatamente o que o repositório publica fora do app', () => {
  // Lendo o repositório de verdade: uma pasta nova em site/, uma Function
  // nova em functions/ ou um documento legal novo sem entrada na lista
  // derruba este teste — em vez de virar uma página que o SW engole e
  // responde com a casca do app.
  const pastasDoSite = fs
    .readdirSync(path.join(RAIZ, 'site'), { withFileTypes: true })
    .filter((e) => e.isDirectory())
    .map((e) => `/${e.name}`);
  const funcoes = fs
    .readdirSync(path.join(RAIZ, 'functions'))
    .filter((nome) => nome.endsWith('.js'))
    .map((nome) => `/${nome.replace(/\.js$/, '')}`);
  // As legais são geradas na montagem (não existem em site/): a rota vem de
  // onde o gerador as publica.
  const legais = DOCUMENTOS.map((d) => `/${d.rota.split('/')[0]}`);

  const esperado = [...new Set([...pastasDoSite, ...funcoes, ...legais])].sort();
  assert.deepEqual([...ROTAS_ESTATICAS].sort(), esperado);
});

test('o sw.js gerado compila e embute as constantes do build', () => {
  const dir = criarBuildFalso();
  const manifesto = calcularManifesto(dir);
  const codigo = gerarServiceWorker(manifesto);
  assert.doesNotThrow(() => new vm.Script(codigo, { filename: 'sw.js' }));
  assert.ok(codigo.includes(`const VERSAO = "${manifesto.versao}"`));
  assert.ok(codigo.includes('const RECURSOS = {'));
  assert.ok(codigo.includes('const NUCLEO = ['));
  assert.ok(codigo.includes('const ROTAS_ESTATICAS = ['));
  // Dois builds iguais, o mesmo sw.js byte a byte — senão toda publicação
  // reinstalaria o SW à toa.
  assert.equal(gerarServiceWorker(calcularManifesto(dir)), codigo);
});

// ---------------------------------------------------------------------------
// 4. O comportamento: o sw.js gerado rodando num vm com dublês
// ---------------------------------------------------------------------------

/// A URL de um pedido, aceitando o que a API de cache aceita (string, URL ou
/// Request — ou o objeto simples que usamos para navegação).
function urlDe(pedido) {
  if (typeof pedido === 'string') return new URL(pedido, ORIGEM).href;
  if (pedido instanceof URL) return pedido.href;
  return pedido.url;
}

function semBusca(href) {
  const u = new URL(href);
  u.search = '';
  return u.href;
}

/// Um Cache do navegador sobre um Map, chaveando por URL.
class CacheFalso {
  constructor() {
    this.entradas = new Map();
  }
  async match(pedido, opcoes = {}) {
    const alvo = urlDe(pedido);
    if (!opcoes.ignoreSearch) {
      const r = this.entradas.get(alvo);
      return r ? r.clone() : undefined;
    }
    for (const [chave, r] of this.entradas) {
      if (semBusca(chave) === semBusca(alvo)) return r.clone();
    }
    return undefined;
  }
  async put(pedido, resposta) {
    this.entradas.set(urlDe(pedido), resposta);
  }
  async add(pedido) {
    const resposta = await rede.fetch(pedido);
    // O navegador recusa guardar resposta que não seja ok em add/addAll.
    if (!resposta.ok) throw new TypeError(`addAll: ${urlDe(pedido)} respondeu ${resposta.status}`);
    await this.put(pedido, resposta);
  }
  async addAll(pedidos) {
    for (const p of pedidos) await this.add(p);
  }
  async keys() {
    return [...this.entradas.keys()].map((u) => new Request(u));
  }
  async delete(pedido) {
    return this.entradas.delete(urlDe(pedido));
  }
  get urls() {
    return [...this.entradas.keys()];
  }
}

class CacheStorageFalso {
  constructor() {
    this.caches = new Map();
  }
  async open(nome) {
    if (!this.caches.has(nome)) this.caches.set(nome, new CacheFalso());
    return this.caches.get(nome);
  }
  async keys() {
    return [...this.caches.keys()];
  }
  async has(nome) {
    return this.caches.has(nome);
  }
  async delete(nome) {
    return this.caches.delete(nome);
  }
}

/// A rede controlável: online por padrão; `offline` falha como o navegador
/// falha (TypeError); `pendurada` nunca responde; `respostas` troca a
/// resposta de uma URL específica.
const rede = {
  modo: 'online',
  respostas: new Map(),
  chamadas: [],
  reiniciar() {
    this.modo = 'online';
    this.respostas.clear();
    this.chamadas = [];
  },
  async fetch(pedido) {
    const href = urlDe(pedido);
    this.chamadas.push(href);
    if (this.modo === 'offline') throw new TypeError('Failed to fetch');
    if (this.modo === 'pendurada') return new Promise(() => {});
    const fabrica = this.respostas.get(href);
    if (fabrica) return fabrica();
    return new Response(`corpo de ${new URL(href).pathname}`, {
      status: 200,
      headers: { 'content-type': 'text/plain' },
    });
  },
};

/// Sobe o sw.js gerado num contexto novo e devolve os controles.
function subirServiceWorker(codigo) {
  const ouvintes = new Map();
  const chamadas = { skipWaiting: 0, claim: 0 };
  const self = {
    addEventListener(tipo, fn) {
      if (!ouvintes.has(tipo)) ouvintes.set(tipo, []);
      ouvintes.get(tipo).push(fn);
    },
    async skipWaiting() {
      chamadas.skipWaiting++;
    },
    clients: {
      async claim() {
        chamadas.claim++;
      },
    },
    registration: {},
    location: { origin: ORIGEM },
  };
  const caches = new CacheStorageFalso();
  const contexto = vm.createContext({
    self,
    caches,
    fetch: (pedido, init) => rede.fetch(pedido, init),
    Request,
    Response,
    URL,
    Headers,
    setTimeout,
    clearTimeout,
    console,
  });
  new vm.Script(codigo, { filename: 'sw.js' }).runInContext(contexto);

  const dispararComEspera = async (tipo, extras = {}) => {
    const esperas = [];
    const evento = { ...extras, waitUntil: (p) => esperas.push(p) };
    for (const fn of ouvintes.get(tipo) ?? []) fn(evento);
    await Promise.all(esperas);
  };

  return {
    self,
    caches,
    chamadas,
    instalar: () => dispararComEspera('install'),
    ativar: () => dispararComEspera('activate'),
    mensagem: (data) => dispararComEspera('message', { data }),
    /// Chama o handler de fetch e devolve a promessa passada a `respondWith`
    /// — ou null se o SW deixou o pedido para o navegador.
    dispararFetch(request) {
      let respondido = null;
      const evento = {
        request,
        respondWith(p) {
          respondido = Promise.resolve(p);
        },
        waitUntil() {},
      };
      for (const fn of ouvintes.get('fetch') ?? []) fn(evento);
      return respondido;
    },
  };
}

/// Um pedido de navegação. `new Request` do Node não aceita mode 'navigate'
/// (nem o do navegador, fora dele), então é um objeto simples com o que o SW
/// lê.
const navegacao = (caminho) => ({
  url: new URL(caminho, ORIGEM).href,
  method: 'GET',
  mode: 'navigate',
  headers: new Headers(),
});

/// Um SW instalado e ativado sobre o build falso, com o flutter-app-cache
/// antigo já presente para o activate limpar.
async function servicoPronto() {
  rede.reiniciar();
  const dir = criarBuildFalso();
  const manifesto = calcularManifesto(dir);
  const sw = subirServiceWorker(gerarServiceWorker(manifesto));
  await sw.caches.open('flutter-app-cache');
  await sw.instalar();
  await sw.ativar();
  return { sw, manifesto };
}

test('a. install guarda o núcleo (com a casca em "/") e activate monta o cache da versão', async () => {
  rede.reiniciar();
  const dir = criarBuildFalso();
  const manifesto = calcularManifesto(dir);
  const sw = subirServiceWorker(gerarServiceWorker(manifesto));
  await sw.caches.open('flutter-app-cache');
  await sw.caches.open('flutter-temp-cache');

  await sw.instalar();
  assert.equal(sw.chamadas.skipWaiting, 1);
  const temp = await sw.caches.open(`gdb-temp-${manifesto.versao}`);
  assert.ok(temp.urls.includes(`${ORIGEM}/`), 'a casca entra sob "/"');
  assert.ok(!temp.urls.includes(`${ORIGEM}/index.html`), 'não sob index.html (o Cloudflare redireciona)');
  for (const caminho of manifesto.nucleo.filter((c) => c !== 'index.html')) {
    assert.ok(temp.urls.includes(`${ORIGEM}/${caminho}`), `${caminho} deveria estar no temp`);
  }
  assert.ok(!temp.urls.some((u) => u.includes('/canvaskit/')), 'canvaskit não é baixado no install');

  await sw.ativar();
  assert.equal(sw.chamadas.claim, 1);
  const nomes = await sw.caches.keys();
  assert.ok(nomes.includes(`gdb-app-${manifesto.versao}`));
  assert.ok(!nomes.includes(`gdb-temp-${manifesto.versao}`), 'o temp é apagado');
  assert.ok(!nomes.some((n) => n.startsWith('flutter-')), 'os caches do SW antigo do Flutter somem');

  const app = await sw.caches.open(`gdb-app-${manifesto.versao}`);
  assert.ok(app.urls.includes(`${ORIGEM}/`));
  assert.ok(app.urls.includes(`${ORIGEM}/main.dart.js`));

  const cacheManifesto = await sw.caches.open('gdb-manifesto');
  assert.equal(cacheManifesto.urls.length, 1);
  const guardado = await (await cacheManifesto.match(cacheManifesto.urls[0])).json();
  assert.deepEqual(guardado, manifesto.recursos);
});

test('b. offline, a navegação para /seu-dia responde com a casca guardada', async () => {
  const { sw } = await servicoPronto();
  rede.modo = 'offline';

  const resposta = await sw.dispararFetch(navegacao('/seu-dia'));
  assert.ok(resposta, 'o SW tem de responder a navegação do app');
  assert.equal(await resposta.text(), 'corpo de /');
});

test('c. navegação para /sobre/ e para /robots.txt fica com o navegador', async () => {
  const { sw } = await servicoPronto();
  rede.modo = 'offline';

  assert.equal(sw.dispararFetch(navegacao('/sobre/')), null);
  assert.equal(sw.dispararFetch(navegacao('/sobre')), null);
  assert.equal(sw.dispararFetch(navegacao('/privacidade/en/')), null);
  assert.equal(sw.dispararFetch(navegacao('/termos/')), null);
  assert.equal(sw.dispararFetch(navegacao('/baixar?origem=panfleto')), null);
  assert.equal(sw.dispararFetch(navegacao('/robots.txt')), null);
  assert.equal(sw.dispararFetch(navegacao('/version.txt')), null);
  // As rotas do app, todas: qualquer uma delas pode ser a primeira URL aberta.
  for (const rota of ['/', '/seu-dia', '/enciclopedia', '/grimorio', '/diarios', '/welcome', '/login', '/entrando']) {
    assert.ok(sw.dispararFetch(navegacao(rota)), `${rota} é do app`);
  }
});

test('d. online, a navegação para / vem da rede e atualiza a casca no cache', async () => {
  const { sw, manifesto } = await servicoPronto();
  rede.respostas.set(`${ORIGEM}/`, () => new Response('casca nova', { status: 200 }));

  const resposta = await sw.dispararFetch(navegacao('/'));
  assert.equal(await resposta.text(), 'casca nova');
  const app = await sw.caches.open(`gdb-app-${manifesto.versao}`);
  assert.equal(await (await app.match(`${ORIGEM}/`)).text(), 'casca nova');

  // Erro DO SERVIDOR: a casca guardada abre o app, e a casca boa continua no
  // cache — um 502 de implantação não pode deixar quem já tem o app instalado
  // olhando para a página de erro da borda.
  rede.respostas.set(`${ORIGEM}/seu-dia`, () => new Response('fora do ar', { status: 503 }));
  const ruim = await sw.dispararFetch(navegacao('/seu-dia'));
  assert.equal(await ruim.text(), 'casca nova');
  assert.equal(await (await app.match(`${ORIGEM}/`)).text(), 'casca nova');

  // Um 404 NÃO vira casca: é resposta legítima, e trocá-la esconderia o
  // endereço errado em vez de mostrá-lo.
  rede.respostas.set(`${ORIGEM}/nao-existe`, () => new Response('sumiu', { status: 404 }));
  const ausente = await sw.dispararFetch(navegacao('/nao-existe'));
  assert.equal(ausente.status, 404);
  assert.equal(await (await app.match(`${ORIGEM}/`)).text(), 'casca nova');
});

test('d2. resposta redirecionada não vira casca (o navegador a recusa numa navegação)', async () => {
  const { sw, manifesto } = await servicoPronto();
  const app = await sw.caches.open(`gdb-app-${manifesto.versao}`);
  const antes = await (await app.match(`${ORIGEM}/`)).text();

  rede.respostas.set(`${ORIGEM}/`, () => {
    const r = new Response('veio de um redirecionamento', { status: 200 });
    Object.defineProperty(r, 'redirected', { value: true });
    return r;
  });
  await sw.dispararFetch(navegacao('/'));

  assert.equal(
    await (await app.match(`${ORIGEM}/`)).text(),
    antes,
    'a casca redirecionada não pode substituir a boa',
  );
});

test('e. rede pendurada: a navegação cai para o cache dentro do prazo', async () => {
  const { sw } = await servicoPronto();
  rede.modo = 'pendurada';
  sw.self.GDB_PRAZO_MS = 50;

  const inicio = Date.now();
  const resposta = await sw.dispararFetch(navegacao('/grimorio'));
  const duracao = Date.now() - inicio;
  assert.equal(await resposta.text(), 'corpo de /');
  assert.ok(duracao < 1000, `demorou ${duracao} ms — o prazo não venceu`);
});

test('e2. prazo vencido SEM casca no cache: espera a rede em vez de mostrar erro', async () => {
  // Primeira visita numa rede lenta: o service worker já controla a página
  // (skipWaiting + claim), mas ainda não há nada guardado. Desistir no prazo
  // aqui trocaria uma espera por uma página de erro — e o prazo existe para
  // PREFERIR o cache, não para abandonar uma conexão lenta.
  rede.reiniciar();
  const dir = criarBuildFalso();
  const manifesto = calcularManifesto(dir);
  const sw = subirServiceWorker(gerarServiceWorker(manifesto));
  sw.self.GDB_PRAZO_MS = 20;
  rede.respostas.set(
    `${ORIGEM}/seu-dia`,
    () =>
      new Promise((resolver) =>
        setTimeout(() => resolver(new Response('casca tardia', { status: 200 })), 120),
      ),
  );

  const resposta = await sw.dispararFetch(navegacao('/seu-dia'));
  assert.equal(await resposta.text(), 'casca tardia');

  // E o que chegou tarde vira a casca: a próxima abertura já tem offline.
  const app = await sw.caches.open(`gdb-app-${manifesto.versao}`);
  assert.equal(await (await app.match(`${ORIGEM}/`)).text(), 'casca tardia');
});

test('f. recurso do build: rede e guarda, depois cache; 404 não é guardado', async () => {
  const { sw, manifesto } = await servicoPronto();
  const app = await sw.caches.open(`gdb-app-${manifesto.versao}`);
  const imagem = `${ORIGEM}/assets/images/x.png`;

  const primeira = await sw.dispararFetch(new Request(`${imagem}?v=1`));
  assert.equal(await primeira.text(), 'corpo de /assets/images/x.png');
  assert.ok(rede.chamadas.includes(`${imagem}?v=1`), '1ª vez vai à rede');
  assert.ok(app.urls.includes(imagem), 'guardada sob o caminho limpo, sem a query');

  rede.modo = 'offline';
  const segunda = await sw.dispararFetch(new Request(`${imagem}?v=2`));
  assert.equal(await segunda.text(), 'corpo de /assets/images/x.png');

  // Um 404 (publicação no meio, arquivo que sumiu) não pode ficar no cache
  // até a próxima versão.
  rede.modo = 'online';
  const canvaskit = `${ORIGEM}/canvaskit/canvaskit.js`;
  rede.respostas.set(canvaskit, () => new Response('não achei', { status: 404 }));
  const naoAchou = await sw.dispararFetch(new Request(canvaskit));
  assert.equal(naoAchou.status, 404);
  assert.ok(!app.urls.includes(canvaskit));

  // Fora de RECURSOS, o SW não responde: nem o carimbo de versão nem um POST.
  assert.equal(sw.dispararFetch(new Request(`${ORIGEM}/version.txt`)), null);
  assert.equal(sw.dispararFetch(new Request(`${ORIGEM}/sw.js`)), null);
  assert.equal(sw.dispararFetch(new Request(imagem, { method: 'POST', body: 'x' })), null);
});

test('g. Supabase passa; fontes do Google ficam em gdb-fontes-v1 e servem offline', async () => {
  const { sw } = await servicoPronto();

  assert.equal(sw.dispararFetch(new Request('https://abc.supabase.co/rest/v1/x')), null);
  assert.equal(sw.dispararFetch(new Request('https://api.revenuecat.com/v1/subscribers/x')), null);
  assert.equal(sw.dispararFetch(new Request('https://www.gstatic.com/flutter-canvaskit/abc/canvaskit.js')), null);

  const fonte = 'https://fonts.gstatic.com/s/nunito.woff2';
  const online = await sw.dispararFetch(new Request(fonte));
  assert.equal(await online.text(), 'corpo de /s/nunito.woff2');
  const fontes = await sw.caches.open('gdb-fontes-v1');
  assert.ok(fontes.urls.includes(fonte));

  rede.modo = 'offline';
  const offline = await sw.dispararFetch(new Request(fonte));
  assert.equal(await offline.text(), 'corpo de /s/nunito.woff2');

  // Uma fonte que o Google não tem não fica guardada como se tivesse.
  rede.modo = 'online';
  const inexistente = 'https://fonts.gstatic.com/s/naoexiste.woff2';
  rede.respostas.set(inexistente, () => new Response('', { status: 404 }));
  await sw.dispararFetch(new Request(inexistente));
  assert.ok(!fontes.urls.includes(inexistente));
});

test('h. aquecer guarda só o que é do build (ou fonte do Google)', async () => {
  const { sw, manifesto } = await servicoPronto();
  const app = await sw.caches.open(`gdb-app-${manifesto.versao}`);
  const wasm = `${ORIGEM}/canvaskit/chromium/canvaskit.wasm`;

  await sw.mensagem({
    tipo: 'aquecer',
    urls: [
      wasm,
      `${ORIGEM}/nao-esta-no-build.js`,
      'https://accounts.google.com/gsi/client',
      'https://fonts.gstatic.com/s/lora.woff2',
      'isto não é uma url válida ://',
    ],
  });

  assert.ok(app.urls.includes(wasm), 'o wasm do CanvasKit entra');
  assert.ok(!app.urls.includes(`${ORIGEM}/nao-esta-no-build.js`));
  assert.ok(!rede.chamadas.includes(`${ORIGEM}/nao-esta-no-build.js`), 'nem chega a ir à rede');
  assert.ok(!rede.chamadas.includes('https://accounts.google.com/gsi/client'));
  const fontes = await sw.caches.open('gdb-fontes-v1');
  assert.ok(fontes.urls.includes('https://fonts.gstatic.com/s/lora.woff2'));

  // O que já está no cache não é baixado de novo — o aquecimento repete 15 s
  // depois da montagem e não pode custar o wasm duas vezes.
  const chamadasAntes = rede.chamadas.length;
  await sw.mensagem({ tipo: 'aquecer', urls: [wasm] });
  assert.equal(rede.chamadas.length, chamadasAntes);

  // Mensagem que não é nossa é ignorada, sem erro.
  await sw.mensagem({ tipo: 'outra' });
  await sw.mensagem(null);
});

test('atualização: reaproveita do cache antigo só o que tem o mesmo md5', async () => {
  // Versão 1 instalada, com uma imagem já no cache preguiçoso.
  rede.reiniciar();
  const dir = criarBuildFalso();
  const v1 = calcularManifesto(dir);
  const sw1 = subirServiceWorker(gerarServiceWorker(v1));
  await sw1.instalar();
  await sw1.ativar();
  await sw1.dispararFetch(new Request(`${ORIGEM}/assets/images/x.png`));
  await sw1.dispararFetch(new Request(`${ORIGEM}/canvaskit/canvaskit.wasm`));

  // Versão 2: só o main.dart.js e a imagem mudaram.
  fs.writeFileSync(path.join(dir, 'main.dart.js'), 'console.log("app v2")');
  fs.writeFileSync(path.join(dir, 'assets/images/x.png'), 'png v2');
  const v2 = calcularManifesto(dir);
  assert.notEqual(v2.versao, v1.versao);

  // O SW novo sobe no MESMO CacheStorage (é o mesmo navegador).
  const sw2 = subirServiceWorker(gerarServiceWorker(v2));
  sw2.caches.caches = sw1.caches.caches;
  rede.chamadas = [];
  await sw2.instalar();
  await sw2.ativar();

  const nomes = await sw2.caches.keys();
  assert.ok(nomes.includes(`gdb-app-${v2.versao}`));
  assert.ok(!nomes.includes(`gdb-app-${v1.versao}`), 'o cache da versão anterior some');

  const app = await sw2.caches.open(`gdb-app-${v2.versao}`);
  assert.ok(app.urls.includes(`${ORIGEM}/canvaskit/canvaskit.wasm`), 'o wasm intacto migra sem download');
  assert.ok(!rede.chamadas.includes(`${ORIGEM}/canvaskit/canvaskit.wasm`));
  assert.ok(!app.urls.includes(`${ORIGEM}/assets/images/x.png`), 'a imagem que mudou não migra');
  assert.equal(
    await (await app.match(`${ORIGEM}/main.dart.js`)).text(),
    'corpo de /main.dart.js',
    'o núcleo vem do temp, recém-baixado',
  );
  const guardado = await (await (await sw2.caches.open('gdb-manifesto')).match(`${ORIGEM}/gdb-manifesto`)).json();
  assert.deepEqual(guardado, v2.recursos);
});

test('o que o aquecimento guardou durante a ativação sobrevive a ela', async () => {
  // O aquecimento da PRIMEIRA visita chega assim que o `clients.claim()`
  // resolve — com a ativação ainda correndo — e o manifesto anterior está
  // vazio. Uma migração que julgasse o cache DESTA versão por esse manifesto
  // apagaria tudo o que acabou de entrar, e a segunda visita offline abriria
  // sem renderizador: exatamente o que o aquecimento existe para evitar.
  rede.reiniciar();
  const dir = criarBuildFalso();
  const manifesto = calcularManifesto(dir);
  const sw = subirServiceWorker(gerarServiceWorker(manifesto));
  await sw.instalar();

  const app = await sw.caches.open(`gdb-app-${manifesto.versao}`);
  await app.put(`${ORIGEM}/canvaskit/canvaskit.wasm`, new Response('wasm aquecido'));
  // Já isto não é mais do build — e some.
  await app.put(`${ORIGEM}/assets/images/sumiu.png`, new Response('velharia'));

  await sw.ativar();

  assert.equal(
    await (await app.match(`${ORIGEM}/canvaskit/canvaskit.wasm`)).text(),
    'wasm aquecido',
    'o aquecimento não pode ser apagado pela própria ativação',
  );
  assert.ok(
    !app.urls.includes(`${ORIGEM}/assets/images/sumiu.png`),
    'o que saiu do build é apagado',
  );
});
