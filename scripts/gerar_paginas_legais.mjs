// As páginas legais do site, escritas a partir de assets/legal/*.md.
//
// O PORQUÊ: até aqui site/privacidade/index.html e site/termos/index.html
// eram HTML digitado à mão, em português só. Documento sem compilador
// envelhece em silêncio, e estes envelheceram: a página ainda prometia que a
// sincronização na nuvem era "apenas para quem é Premium" muito depois de o
// paywall ter saído do DataSyncService — enquanto o .md que o app exibe já
// dizia a verdade. A catraca de test/politica_legal_test.dart guardava o .md
// e o ARB; o site ficava de fora porque o site não vinha do .md. Vem agora:
// há uma fonte só, e a página é um derivado dela.
//
// O que se perdeu na troca: as caixas decorativas que as páginas antigas
// tinham (o quadro "📌 Importante", o cartão de contato em dourado) não
// existem no Markdown e não sobrevivem. Dava para inventar uma marcação para
// recriá-las, mas isso devolveria ao site um texto que não está no documento
// — que é exatamente a doença que estamos curando. O visual (fundo, fontes,
// cores, largura, responsivo) é o mesmo; a diagramação ficou mais plana.
//
// O conversor é mínimo de propósito: os seis documentos usam seis construções
// (h1, h2, h3, lista com "-", parágrafo, **negrito**) e nada mais — isso foi
// conferido lendo os seis. Diante de qualquer coisa fora desse conjunto ele
// PARA com o arquivo e a linha, em vez de cuspir "[texto](url)" literal na
// web. Preferir o erro é o ponto: no dia em que a política ganhar um link, a
// publicação para e alguém ensina o link ao conversor.
//
// Uso: node scripts/gerar_paginas_legais.mjs <diretorio_de_saida>
import fs from 'node:fs';
import path from 'node:path';
import url from 'node:url';

const RAIZ = path.dirname(path.dirname(url.fileURLToPath(import.meta.url)));

/// O domínio de produção. Entra nas URLs canônicas, nos alternates de idioma
/// e nas meta tags de prévia de link — que precisam de endereço absoluto para
/// funcionar em qualquer rastreador.
export const DOMINIO = 'https://grimoriodebolso.app';

/// O ano do rodapé. Constante nomeada porque é a única data inventada na
/// página: todo o resto vem do documento.
const ANO = '2026';

/// Os seis documentos e onde cada um é publicado.
///
/// A rota escolhida: o idioma é uma PASTA dentro do documento
/// (/privacidade/, /privacidade/en/, /privacidade/es/). Assim o endereço em
/// português não muda — ele já está no sitemap, na tela de consentimento do
/// Google e em links antigos —, cada tradução ganha um endereço fixo que se
/// pode colar num e-mail ou numa loja, e o rastreador acha as três sem
/// executar nada. Negociar pelo cabeçalho Accept-Language exigiria uma
/// Function no Cloudflare (JavaScript na borda) e devolveria UM endereço
/// servindo três textos diferentes: o oposto de "um link pode apontar para
/// ele".
///
/// `extras` são os links que só fazem sentido em português, porque as páginas
/// de destino só existem em português.
export const DOCUMENTOS = [
  {
    id: 'privacidade-pt',
    fonte: 'assets/legal/politica_de_privacidade.md',
    rota: 'privacidade/',
    idioma: 'pt',
    htmlLang: 'pt-BR',
    ogLocale: 'pt_BR',
    par: 'termos-pt',
    extras: [
      { href: '/privacidade/data-deletion.html', rotulo: 'Solicitação de Exclusão de Dados' },
      { href: '/sobre/', rotulo: 'Sobre o Grimório de Bolso' },
    ],
  },
  {
    id: 'privacidade-en',
    fonte: 'assets/legal/politica_de_privacidade_en.md',
    rota: 'privacidade/en/',
    idioma: 'en',
    htmlLang: 'en',
    ogLocale: 'en_US',
    par: 'termos-en',
    extras: [],
  },
  {
    id: 'privacidade-es',
    fonte: 'assets/legal/politica_de_privacidade_es.md',
    rota: 'privacidade/es/',
    idioma: 'es',
    htmlLang: 'es',
    ogLocale: 'es_ES',
    par: 'termos-es',
    extras: [],
  },
  {
    id: 'termos-pt',
    fonte: 'assets/legal/termos_de_uso.md',
    rota: 'termos/',
    idioma: 'pt',
    htmlLang: 'pt-BR',
    ogLocale: 'pt_BR',
    par: 'privacidade-pt',
    extras: [{ href: '/sobre/', rotulo: 'Sobre o Grimório de Bolso' }],
  },
  {
    id: 'termos-en',
    fonte: 'assets/legal/termos_de_uso_en.md',
    rota: 'termos/en/',
    idioma: 'en',
    htmlLang: 'en',
    ogLocale: 'en_US',
    par: 'privacidade-en',
    extras: [],
  },
  {
    id: 'termos-es',
    fonte: 'assets/legal/termos_de_uso_es.md',
    rota: 'termos/es/',
    idioma: 'es',
    htmlLang: 'es',
    ogLocale: 'es_ES',
    par: 'privacidade-es',
    extras: [],
  },
];

/// As frases que não podem voltar ao site, em nenhum idioma.
///
/// É a mesma lista de test/politica_legal_test.dart, que guarda o .md e o
/// ARB. Ela mora aqui, e não só no teste, porque este gerador roda em TODA
/// montagem do site — inclusive numa publicação local que não roda teste
/// nenhum. Se a mentira reaparecer no documento, a publicação para antes de a
/// página existir, em vez de esperar o CI.
/// A regra que pega a mentira REESCRITA, e não só copiada.
///
/// A lista literal acima é memória do que já foi dito; ela não pega "cloud
/// syncing is reserved for Premium subscribers", que diz a mesma coisa com
/// outras palavras. Esta regra pega: a palavra Premium a até 40 caracteres
/// de "sincroniza"/"sync", em qualquer ordem, dentro da mesma frase.
///
/// `licito` é a saída legítima — o documento PRECISA poder dizer "em
/// qualquer plano, gratuito ou Premium", que é justamente o conserto. A
/// vizinhança do achado tem de trazer essa afirmação; sem ela, a montagem
/// para. O custo assumido: uma frase futura que toque nos dois assuntos sem
/// essa âncora barra a publicação até alguém reescrevê-la ou rever esta
/// regra. É o custo certo — barrar demais aqui atrasa uma publicação, barrar
/// de menos manda informação falsa sobre dados pessoais para a web.
const PREMIUM_PERTO_DA_NUVEM = {
  pt: { sincronizacao: 'sincroniza', licito: 'qualquer plano' },
  en: { sincronizacao: 'sync', licito: 'any plan' },
  es: { sincronizacao: 'sincroniza', licito: 'cualquier plan' },
};

export const FRASES_PROIBIDAS = {
  pt: [
    'exclusiva do Premium',
    'apenas se você for Premium',
    'apenas para quem é Premium',
    'opcional, Premium',
    'sincronização Premium',
  ],
  en: [
    'exclusive to Premium',
    'only if you are Premium',
    'Premium-only sync',
    'optional, Premium',
    'Premium sync',
  ],
  es: [
    'exclusiva de Premium',
    'solo si eres Premium',
    'opcional, Premium',
    'sincronización Premium',
  ],
};

/// O texto que a pessoa lê sai do documento; o pouco que sobra é rótulo de
/// navegação. Os nomes de idioma são endônimos — não são frase traduzida,
/// são como cada idioma se chama —, e o nome do documento vizinho é o título
/// que o próprio .md dele declara. Assim a página não inventa uma linha
/// sequer de prosa que o documento não tenha.
const NOME_DO_IDIOMA = { pt: 'Português', en: 'English', es: 'Español' };

function erro(mensagem) {
  throw new Error(mensagem);
}

function escapar(texto) {
  return texto
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');
}

function escaparAtributo(texto) {
  return escapar(texto).replaceAll('"', '&quot;');
}

const EMAIL = /[\w.+-]+@[\w-]+\.[\w.-]*\w/g;

/// Recusa toda marcação que o conversor não sabe traduzir.
///
/// Separada de `emLinha` porque o título de primeiro nível também precisa
/// dela: ele não passa pela conversão (vira `<h1>`, `<title>` e og:title como
/// texto puro), e sem esta passagem um `# **Política** — App` publicaria os
/// asteriscos à vista no título da aba e na prévia do link.
///
/// A lista cresceu depois de uma varredura: a versão anterior prometia parar
/// diante do desconhecido e parava só diante de cinco construções. Passavam
/// caladas, publicando a marcação crua na página legal, o link de referência
/// (`[termos][t]`), a nota de rodapé (`[^1]`), a ênfase com sublinhado
/// (`_assim_`, `__assim__`) e o tachado (`~~assim~~`) — nenhuma delas
/// aparecia no `]\(` que a versão anterior procurava. Agora o colchete, o
/// sublinhado e o til são recusados inteiros, sem tentar adivinhar a intenção.
///
/// O custo assumido, dito inteiro — porque ele é maior do que um e-mail com
/// sublinhado no nome (`a_b@exemplo.com`), que era o único exemplo que este
/// comentário dava. O colchete e o sublinhado são PONTUAÇÃO legítima de prosa
/// jurídica: `[sic]`, `[tutor]`, uma elisão `[...]`, e qualquer campo de dado
/// citado pelo nome (`user_id`, `sb_access_token`) — coisa provável numa
/// política que lista o que guarda. Hoje nenhum dos seis documentos usa nada
/// disso (conferido), mas no dia em que usar, a publicação de PRODUÇÃO para
/// diante de um texto correto, e alguém terá de ensinar o caso ao conversor
/// antes de publicar. É o lado caro da troca, e é o lado certo dela: parar
/// alto custa uma publicação atrasada, publicar torto manda `_itálico_` cru
/// — ou pior, marcação que muda o sentido — para dentro de um documento
/// legal que a pessoa lê para decidir sobre os próprios dados.
function recusarOQueNaoSabe(texto, onde) {
  const proibido = [
    [/\]\(/, 'link'],
    [/!\[/, 'imagem'],
    [/[[\]]/, 'colchete (link de referência, nota de rodapé)'],
    [/`/, 'código'],
    [/<[a-zA-Z/!]/, 'HTML embutido'],
    [/\*\*\*/, 'negrito e itálico juntos'],
    [/_/, 'sublinhado (a ênfase _assim_ ou __assim__)'],
    [/~~/, 'tachado'],
    // `&nbsp;` virava `&amp;nbsp;` e a pessoa lia o código cru no meio da
    // política — o escape de `&`, que existe para a empresa "A & B", não tem
    // como distinguir os dois. Quem quer um espaço que não quebra escreve o
    // caractere, não a entidade.
    [/&[a-zA-Z][a-zA-Z0-9]*;|&#\d+;|&#x[0-9a-fA-F]+;/, 'entidade HTML (&nbsp;, &copy;)'],
  ];
  for (const [padrao, oQue] of proibido) {
    if (padrao.test(texto)) {
      erro(`${onde}: o conversor não sabe ${oQue} — ensine-o antes de usá-lo no documento.`);
    }
  }
  if ((texto.match(/\*\*/g) || []).length % 2 !== 0) {
    erro(`${onde}: ** sem par — o negrito ficaria aberto até o fim da página.`);
  }
  if (/(^|[^*])\*([^*]|$)/.test(texto)) {
    erro(`${onde}: asterisco solto — o conversor só entende **negrito**.`);
  }
}

/// Tira a marcação de negrito de um trecho que vai virar TEXTO PURO — o
/// resumo da prévia de link, que mora num atributo e não aceita `<strong>`.
/// Sem isto a descrição do link saía com os asteriscos à vista no dia em que
/// a abertura do documento ganhasse um negrito.
function semNegrito(texto) {
  return texto.replace(/\*\*(.+?)\*\*/g, '$1');
}

/// Converte o trecho em linha: só **negrito** e o e-mail que vira mailto.
///
/// A ordem importa: escapar primeiro, marcar depois. O contrário deixaria
/// `<strong>` virar `&lt;strong&gt;`.
function emLinha(texto, onde) {
  recusarOQueNaoSabe(texto, onde);

  let html = escapar(texto);
  html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
  // O e-mail de contato era clicável nas páginas antigas e continua sendo:
  // no Markdown ele é texto puro, e quem lê a política para pedir exclusão de
  // dados não deveria ter de copiar o endereço à mão.
  html = html.replace(EMAIL, (endereco) => `<a href="mailto:${endereco}">${endereco}</a>`);
  return html;
}

/// Lê um .md e devolve as partes que a página precisa.
///
/// Estrito de propósito: qualquer linha fora do conjunto conhecido derruba a
/// conversão com arquivo e número da linha.
export function converterMarkdown(fonte, nomeDoArquivo) {
  const linhas = fonte.split('\n');
  const blocos = [];
  let titulo = null;
  let aplicativo = null;

  for (let i = 0; i < linhas.length; i++) {
    const linha = linhas[i];
    const onde = `${nomeDoArquivo}:${i + 1}`;
    if (linha.trim() === '') continue;

    if (/^\s/.test(linha)) {
      erro(`${onde}: linha indentada — o conversor não trata lista aninhada nem bloco de código.`);
    }
    if (/^(>|\||```|---|___|\d+\.\s)/.test(linha)) {
      erro(`${onde}: citação, tabela, regra ou lista numerada — o conversor não trata nenhuma delas.`);
    }
    // `* item` já caía no "asterisco solto", com uma mensagem que falava de
    // negrito e não de lista; `+ item` não caía em nada e virava parágrafo,
    // publicando o marcador à vista. A lista deste documento se escreve com
    // "-" e só.
    if (/^[*+]\s/.test(linha)) {
      erro(`${onde}: marcador de lista "${linha[0]}" — neste documento a lista se escreve com "- ".`);
    }
    // Título sublinhado (setext) publicava DOIS erros calados: a linha de "="
    // virava um parágrafo de sinais e o título acima dela virava prosa comum.
    if (/^=+\s*$/.test(linha)) {
      erro(`${onde}: título sublinhado com "=" — os títulos aqui se escrevem com "#", "##" e "###".`);
    }
    // O fecho ATX (`## Título ##`) é Markdown válido e o `slice` não o
    // enxerga: ele corta só a abertura, e os cerquilhas da direita iam para
    // dentro do `<h2>` — para dentro do `<title>` e da prévia do link, no caso
    // do primeiro nível. Mesma classe das outras recusas: parar, não adivinhar
    // se aquilo é fecho ou texto.
    if (/^#/.test(linha) && /\s#+\s*$/.test(linha)) {
      erro(`${onde}: título fechado com "#" à direita — aqui o "#" só abre o título.`);
    }

    if (linha.startsWith('# ')) {
      if (titulo !== null) erro(`${onde}: segundo título de primeiro nível; o documento tem de ter um só.`);
      const inteiro = linha.slice(2).trim();
      recusarOQueNaoSabe(inteiro, onde);
      // O negrito é marcação VÁLIDA que este lugar não sabe honrar: o título
      // vira `<h1>`, `<title>` e og:title, e nos dois últimos só cabe texto
      // puro. Não dá para converter, e converter só no `<h1>` deixaria a aba
      // dizendo "**Política**". Recusar é o mesmo trato do resto do arquivo.
      if (inteiro.includes('**')) {
        erro(`${onde}: negrito no título de primeiro nível — ele vira também <title> e prévia de link, onde não há como marcá-lo.`);
      }
      const partes = inteiro.split(' — ');
      if (partes.length !== 2) {
        erro(`${onde}: o título de primeiro nível precisa ser "Documento — Aplicativo" separado por travessão.`);
      }
      titulo = partes[0].trim();
      aplicativo = partes[1].trim();
      continue;
    }
    if (linha.startsWith('### ')) {
      blocos.push({ tipo: 'h3', texto: linha.slice(4).trim(), onde });
      continue;
    }
    if (linha.startsWith('## ')) {
      blocos.push({ tipo: 'h2', texto: linha.slice(3).trim(), onde });
      continue;
    }
    if (/^#/.test(linha)) {
      erro(`${onde}: título de quarto nível ou mais fundo — a página só tem estilo até o terceiro.`);
    }
    if (linha.startsWith('- ')) {
      // `---`, `___`, `***` e `* * *` já param acima. `- - -` é a única
      // grafia de régua que chegava aqui, e chegava disfarçada de item: virava
      // `<li>- -</li>`, um marcador solto no meio da política.
      if (/^[-*\s]+$/.test(linha.slice(2))) {
        erro(`${onde}: régua horizontal ("- - -") — o conversor não trata régua, e isto viraria um item de lista com dois traços dentro.`);
      }
      const anterior = blocos[blocos.length - 1];
      if (anterior && anterior.tipo === 'lista' && anterior.fim === i - 1) {
        anterior.itens.push({ texto: linha.slice(2).trim(), onde });
        anterior.fim = i;
      } else {
        blocos.push({ tipo: 'lista', itens: [{ texto: linha.slice(2).trim(), onde }], fim: i });
      }
      continue;
    }
    if (titulo === null) {
      erro(`${onde}: o documento começa antes do título de primeiro nível.`);
    }
    // Em Markdown, duas linhas seguidas são UM parágrafo; aqui cada linha era
    // um bloco, e a diferença não era cosmética: a data de vigência e a
    // abertura são pegas por POSIÇÃO (o 1º e o 2º parágrafos), então quebrar
    // a linha da data ao editar o .md partia a data em duas — a página
    // publicava "Última atualização: 13 de setembro de", sem o ano, e o ano
    // sozinho virava a descrição da prévia do link. Sem erro nenhum.
    //
    // A recusa pega também a continuação preguiçosa de item de lista
    // (`- item` numa linha, o resto na seguinte), que virava um parágrafo
    // solto depois do `</ul>`.
    //
    // Parágrafo logo abaixo de um `###`, sem linha em branco no meio, é outra
    // coisa e continua valendo: os três documentos de privacidade fazem isso
    // quinze vezes, e ali o título de fato terminou.
    const anteriorCru = i > 0 ? linhas[i - 1] : '';
    if (anteriorCru.trim() !== '' && !anteriorCru.startsWith('#')) {
      erro(`${onde}: linha de parágrafo colada na linha de cima — em Markdown as duas são um parágrafo só, e o conversor faria dois. Junte-as numa linha ou separe-as com uma linha em branco.`);
    }
    blocos.push({ tipo: 'p', texto: linha.trim(), onde });
  }

  if (titulo === null) erro(`${nomeDoArquivo}: sem título de primeiro nível.`);

  // O primeiro parágrafo é a data de vigência (ela existe nos seis, e
  // test/politica_legal_test.dart garante que continue existindo); o segundo
  // é a abertura, que vira a descrição da prévia de link. Identificados pela
  // POSIÇÃO, não pela frase: "Última atualização", "Last updated" e "Última
  // actualización" são três frases, e casar por texto seria mais uma lista
  // por idioma para esquecer de alimentar.
  const paragrafos = blocos.filter((b) => b.tipo === 'p');
  const vigencia = paragrafos[0];
  const abertura = paragrafos[1];
  if (!vigencia || !abertura) {
    erro(`${nomeDoArquivo}: faltam a data de vigência e o parágrafo de abertura logo abaixo do título.`);
  }

  const corpo = [];
  for (const bloco of blocos) {
    if (bloco === vigencia) continue;
    if (bloco.tipo === 'h2') {
      corpo.push(`    <h2>${emLinha(bloco.texto, bloco.onde)}</h2>`);
    } else if (bloco.tipo === 'h3') {
      corpo.push(`    <h3>${emLinha(bloco.texto, bloco.onde)}</h3>`);
    } else if (bloco.tipo === 'p') {
      corpo.push(`    <p>${emLinha(bloco.texto, bloco.onde)}</p>`);
    } else {
      corpo.push('    <ul>');
      for (const item of bloco.itens) {
        corpo.push(`      <li>${emLinha(item.texto, item.onde)}</li>`);
      }
      corpo.push('    </ul>');
    }
  }

  return {
    titulo,
    aplicativo,
    vigencia: vigencia.texto,
    abertura: abertura.texto,
    corpoHtml: corpo.join('\n'),
  };
}

/// Corta a abertura no tamanho que cabe numa prévia de link, sem partir
/// palavra ao meio.
function resumir(texto, limite = 160) {
  if (texto.length <= limite) return texto;
  const corte = texto.slice(0, limite);
  const espaco = corte.lastIndexOf(' ');
  return `${(espaco > 40 ? corte.slice(0, espaco) : corte).trimEnd()}…`;
}

/// O mesmo visual das páginas antigas: fundo, fontes, cartão central, cores e
/// o corte para tela estreita, copiados de site/privacidade/index.html. O que
/// mudou foi o que sumiu (as caixas decorativas, que nada mais emite) e o que
/// entrou: estilo para h3, que o Markdown usa e a página escrita à mão não
/// tinha, e as duas tiras de navegação.
const ESTILO = `    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      font-family: 'Quicksand', -apple-system, 'Segoe UI', Roboto, Arial, sans-serif;
      line-height: 1.7;
      color: #d8d2e0;
      background:
        radial-gradient(ellipse at 20% -10%, rgba(155, 109, 198, 0.22) 0%, transparent 55%),
        radial-gradient(ellipse at 85% 15%, rgba(240, 199, 94, 0.07) 0%, transparent 45%),
        linear-gradient(160deg, #17111f 0%, #0d0a14 60%, #0a0810 100%);
      background-attachment: fixed;
      min-height: 100vh;
      padding: 28px 16px 48px;
    }

    .container {
      max-width: 780px;
      margin: 0 auto;
      background: rgba(30, 22, 40, 0.92);
      border: 1px solid rgba(201, 162, 232, 0.22);
      padding: 44px 36px;
      border-radius: 22px;
      box-shadow: 0 18px 60px rgba(0, 0, 0, 0.55);
    }

    .brand {
      text-align: center;
      font-size: 2.2em;
      letter-spacing: 2px;
      margin-bottom: 4px;
    }

    h1 {
      font-family: 'Cinzel Decorative', serif;
      color: #c9a2e8;
      text-align: center;
      font-size: 1.7em;
      margin-bottom: 8px;
    }

    .last-updated {
      text-align: center;
      color: #8d84a0;
      font-size: 0.9em;
      margin-bottom: 30px;
    }

    h2 {
      font-family: 'Cinzel Decorative', serif;
      color: #c9a2e8;
      font-size: 1.12em;
      margin: 34px 0 12px;
      padding-bottom: 8px;
      border-bottom: 1px solid rgba(201, 162, 232, 0.25);
    }

    h3 {
      font-family: 'Quicksand', -apple-system, 'Segoe UI', Roboto, Arial, sans-serif;
      color: #efe9f6;
      font-size: 1.02em;
      letter-spacing: 0.3px;
      margin: 24px 0 8px;
    }

    p { margin-bottom: 12px; }
    ul, ol { margin: 0 0 14px 22px; }
    li { margin-bottom: 7px; }
    strong { color: #efe9f6; }

    a { color: #c9a2e8; text-decoration: none; border-bottom: 1px dotted rgba(201,162,232,.5); }
    a:hover { color: #f0c75e; border-bottom-color: #f0c75e; }

    .idiomas {
      text-align: center;
      margin-bottom: 26px;
      color: #8d84a0;
      font-size: 0.9em;
    }
    .idiomas a, .idiomas span { margin: 0 8px; }
    .idiomas span[aria-current] { color: #f0c75e; border-bottom: 1px solid rgba(240, 199, 94, 0.5); }

    .navegacao {
      margin-top: 34px;
      padding-top: 20px;
      border-top: 1px solid rgba(201, 162, 232, 0.18);
    }
    .navegacao ul { list-style: none; margin: 0; }

    .footer {
      text-align: center;
      margin-top: 24px;
      color: #8d84a0;
      font-size: 0.88em;
    }

    @media (max-width: 520px) {
      .container { padding: 30px 20px; }
      body { padding: 14px 8px 32px; }
    }`;

/// Monta o HTML de uma página a partir do documento já convertido e dos
/// vizinhos (o outro documento no mesmo idioma, e o mesmo documento nos
/// outros idiomas).
export function montarPagina(documento, convertido, porId) {
  const canonica = `${DOMINIO}/${documento.rota}`;
  const descricao = resumir(semNegrito(convertido.abertura));

  // O mesmo documento nos outros idiomas: é o que o rastreador usa para
  // entender que as três páginas são a mesma coisa em línguas diferentes, e
  // é a tira que a pessoa clica no topo.
  const irmaos = DOCUMENTOS.filter(
    (d) => d.rota.split('/')[0] === documento.rota.split('/')[0],
  );

  const alternates = irmaos
    .map((d) => `  <link rel="alternate" hreflang="${d.htmlLang}" href="${DOMINIO}/${d.rota}">`)
    .concat([`  <link rel="alternate" hreflang="x-default" href="${DOMINIO}/${irmaos[0].rota}">`])
    .join('\n');

  const tiraDeIdiomas = irmaos
    .map((d) =>
      d.id === documento.id
        ? `<span aria-current="page">${NOME_DO_IDIOMA[d.idioma]}</span>`
        : `<a href="/${d.rota}" hreflang="${d.htmlLang}" lang="${d.htmlLang}">${NOME_DO_IDIOMA[d.idioma]}</a>`,
    )
    .join('\n      ');

  const par = porId.get(documento.par);
  const links = [
    { href: `/${DOCUMENTOS.find((d) => d.id === documento.par).rota}`, rotulo: par.titulo },
    ...documento.extras,
  ]
    .map((l) => `        <li><a href="${l.href}">${escapar(l.rotulo)}</a></li>`)
    .join('\n');

  return `<!DOCTYPE html>
<html lang="${documento.htmlLang}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="icon" type="image/png" href="${DOMINIO}/favicon.png">
  <meta name="application-name" content="${escaparAtributo(convertido.aplicativo)}">
  <title>${escapar(convertido.titulo)} — ${escapar(convertido.aplicativo)}</title>
  <meta name="description" content="${escaparAtributo(descricao)}">
  <link rel="canonical" href="${canonica}">
${alternates}
  <meta property="og:type" content="article">
  <meta property="og:site_name" content="${escaparAtributo(convertido.aplicativo)}">
  <meta property="og:locale" content="${documento.ogLocale}">
  <meta property="og:title" content="${escaparAtributo(`${convertido.titulo} — ${convertido.aplicativo}`)}">
  <meta property="og:description" content="${escaparAtributo(descricao)}">
  <meta property="og:url" content="${canonica}">
  <meta property="og:image" content="${DOMINIO}/og-image.png">
  <meta property="og:image:type" content="image/png">
  <meta property="og:image:width" content="1129">
  <meta property="og:image:height" content="630">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="${escaparAtributo(`${convertido.titulo} — ${convertido.aplicativo}`)}">
  <meta name="twitter:description" content="${escaparAtributo(descricao)}">
  <meta name="twitter:image" content="${DOMINIO}/og-image.png">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Cinzel+Decorative:wght@700&family=Quicksand:wght@400;500;700&display=swap" rel="stylesheet">
  <style>
${ESTILO}
  </style>
</head>
<body>
  <div class="container">
    <div class="brand">🌙</div>
    <h1>${escapar(convertido.titulo)}</h1>
    <p class="last-updated">${escapar(convertido.aplicativo)} &bull; ${emLinha(convertido.vigencia, `${documento.fonte} (data de vigência)`)}</p>
    <nav class="idiomas">
      ${tiraDeIdiomas}
    </nav>
${convertido.corpoHtml}
    <nav class="navegacao">
      <ul>
${links}
      </ul>
    </nav>
    <div class="footer">
      <p>${escapar(convertido.aplicativo)} © ${ANO} 🌙✨</p>
    </div>
  </div>
</body>
</html>
`;
}

/// Converte os seis e devolve o HTML de cada rota, sem escrever em disco —
/// é por aqui que o teste entra.
export function gerarPaginas(raiz = RAIZ) {
  const porId = new Map();
  for (const documento of DOCUMENTOS) {
    const fonte = fs.readFileSync(path.join(raiz, documento.fonte), 'utf8');
    porId.set(documento.id, converterMarkdown(fonte, documento.fonte));
  }

  const paginas = new Map();
  for (const documento of DOCUMENTOS) {
    paginas.set(`${documento.rota}index.html`, montarPagina(documento, porId.get(documento.id), porId));
  }
  return paginas;
}

/// A frase que morreu não volta pela porta do site.
///
/// Roda em toda montagem, não só no teste: uma publicação feita à mão, sem
/// CI, também para aqui. Devolve a lista de problemas em vez de lançar, para
/// o chamador poder mostrar todos de uma vez.
export function conferirFrasesProibidas(paginas) {
  const achados = [];
  for (const [rota, html] of paginas) {
    const documento = DOCUMENTOS.find((d) => `${d.rota}index.html` === rota);
    for (const frase of FRASES_PROIBIDAS[documento.idioma]) {
      if (html.includes(frase)) achados.push(`${rota}: "${frase}"`);
    }

    const regra = PREMIUM_PERTO_DA_NUVEM[documento.idioma];
    const texto = html.replace(/<[^>]+>/g, ' ').replaceAll('&amp;', '&');
    // \w não serve: em JavaScript ele é [A-Za-z0-9_], então "sincronização"
    // termina no "ç" e a conta da distância sai curta — foi assim que uma
    // primeira versão desta regra deixou passar a frase em espanhol e pegou a
    // em português por dois caracteres de sorte. Com \p{L} e a bandeira u, a
    // palavra inteira conta.
    const perto = new RegExp(
      `(${regra.sincronizacao}[\\p{L}\\p{N}_]*[^.]{0,80}Premium` +
        `|Premium[^.]{0,80}${regra.sincronizacao}[\\p{L}\\p{N}_]*)`,
      'giu',
    );
    for (const achado of texto.matchAll(perto)) {
      const vizinhanca = texto.slice(
        Math.max(0, achado.index - 150),
        achado.index + achado[0].length + 150,
      );
      if (!vizinhanca.includes(regra.licito)) {
        achados.push(
          `${rota}: "${achado[0]}" — Premium ao lado da sincronização sem dizer ` +
            `"${regra.licito}".`,
        );
      }
    }
  }
  return achados;
}

export function escrever(saida, paginas) {
  for (const [rota, html] of paginas) {
    const destino = path.join(saida, rota);
    fs.mkdirSync(path.dirname(destino), { recursive: true });
    fs.writeFileSync(destino, html, 'utf8');
  }
}

// Execução direta: gera dentro do diretório de publicação.
if (process.argv[1] && path.resolve(process.argv[1]) === url.fileURLToPath(import.meta.url)) {
  const saida = process.argv[2];
  if (!saida) {
    console.error('Uso: node scripts/gerar_paginas_legais.mjs <diretorio_de_saida>');
    process.exit(2);
  }
  // A recusa do conversor é uma decisão, não um acidente: ela merece a mesma
  // mensagem limpa que a frase proibida ganha logo abaixo, e não um rastro de
  // pilha do Node com o caminho do módulo — que esconde a única linha que
  // interessa (o arquivo e a linha do .md a corrigir).
  let paginas;
  try {
    paginas = gerarPaginas();
  } catch (e) {
    console.error('ERRO: o conversor não soube traduzir o documento para a web:');
    console.error(`  ${e.message}`);
    console.error('Ou o documento volta ao conjunto que o conversor conhece, ou');
    console.error('scripts/gerar_paginas_legais.mjs aprende a construção nova.');
    process.exit(1);
  }
  const achados = conferirFrasesProibidas(paginas);
  if (achados.length > 0) {
    console.error('ERRO: página legal gerada com frase que já foi desmentida pelo código:');
    for (const achado of achados) console.error(`  ${achado}`);
    console.error('A nuvem não depende de plano desde que o paywall saiu do DataSyncService.');
    console.error('Corrija assets/legal/*.md — a página é derivada dele.');
    process.exit(1);
  }
  // A escrita tem o mesmo direito à mensagem limpa que a conversão: disco
  // cheio ou permissão negada saíam daqui como rastro de pilha do Node, e
  // podiam deixar três das seis páginas gravadas. Quem monta o site vê o
  // motivo em uma linha; o laço de conferência de assemble_site.sh cuida das
  // que faltaram.
  try {
    escrever(saida, paginas);
  } catch (e) {
    console.error(`ERRO: não foi possível gravar as páginas legais em ${saida}:`);
    console.error(`  ${e.message}`);
    process.exit(1);
  }
  for (const rota of paginas.keys()) console.log(`  /${rota.replace(/index\.html$/, '')}`);
}
