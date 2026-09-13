// A catraca que alcança o site.
//
// O PORQUÊ: test/politica_legal_test.dart guarda os .md e os ARBs, e guardou
// bem — mas o site ficava fora do alcance dela, porque as páginas legais eram
// HTML digitado à mão. Foi exatamente ali que a mentira sobreviveu: a página
// continuou prometendo sincronização "apenas para quem é Premium" muito
// depois de o documento ter sido reescrito. As páginas agora são geradas de
// assets/legal/*.md, e este teste prova as duas coisas que essa troca tinha
// de garantir:
//
//   1. que a página É o documento — bloco a bloco, na ordem, sem nada
//      acrescentado e sem nada perdido no caminho;
//   2. que a frase desmentida não volta, em idioma nenhum.
//
// O item 1 é o que impede o teste de ser decorativo. Procurar só a frase
// proibida provaria pouco: uma página vazia passaria. Procurar só as seções
// obrigatórias provaria pouco: uma página com as seções certas e o texto
// errado passaria. A comparação bloco a bloco é a única que prova a
// derivação, e é ela que faz o gerador ser obrigado a carregar o documento
// inteiro para a web.
//
// As páginas só existem depois da montagem, então o teste roda o gerador —
// não lê `public/`, que pode nem existir.
//
// Uso: node test/paginas_legais_site_test.mjs
import fs from 'node:fs';
import path from 'node:path';
import url from 'node:url';

import {
  DOCUMENTOS,
  DOMINIO,
  FRASES_PROIBIDAS,
  conferirFrasesProibidas,
  converterMarkdown,
  gerarPaginas,
  montarPagina,
} from '../scripts/gerar_paginas_legais.mjs';

const RAIZ = path.dirname(path.dirname(url.fileURLToPath(import.meta.url)));
const paginas = gerarPaginas(RAIZ);
const porRota = (documento) => paginas.get(`${documento.rota}index.html`);

const casos = [];
const t = (nome, fn) => casos.push([nome, fn]);

const semMarcacao = (texto) => texto.replaceAll('**', '').trim();

const decodificar = (html) =>
  html
    .replaceAll('&bull;', '•')
    .replaceAll('&quot;', '"')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&amp;', '&');

/// Os blocos do .md, em ordem, já sem a marcação: é o lado esquerdo da
/// comparação. O título de primeiro nível e a data de vigência ficam de fora
/// porque viram cabeçalho da página, não corpo.
function blocosDoDocumento(fonte) {
  const blocos = [];
  let viuTitulo = false;
  let vigenciaComida = false;
  for (const linha of fonte.split('\n')) {
    if (linha.trim() === '') continue;
    if (linha.startsWith('# ')) {
      viuTitulo = true;
      continue;
    }
    if (!viuTitulo) continue;
    if (linha.startsWith('### ')) {
      blocos.push({ tipo: 'h3', texto: semMarcacao(linha.slice(4)) });
    } else if (linha.startsWith('## ')) {
      blocos.push({ tipo: 'h2', texto: semMarcacao(linha.slice(3)) });
    } else if (linha.startsWith('- ')) {
      blocos.push({ tipo: 'li', texto: semMarcacao(linha.slice(2)) });
    } else if (!vigenciaComida) {
      vigenciaComida = true; // a data de vigência
    } else {
      blocos.push({ tipo: 'p', texto: semMarcacao(linha) });
    }
  }
  return blocos;
}

/// Os blocos que a página publica, em ordem: é o lado direito. Só o miolo
/// entre a tira de idiomas e a navegação do rodapé — o resto é moldura.
function blocosDaPagina(html) {
  const inicio = html.indexOf('</nav>');
  const fim = html.indexOf('<nav class="navegacao">');
  if (inicio < 0 || fim < 0) throw new Error('a página perdeu a moldura de navegação');
  const miolo = html.slice(inicio, fim);
  const blocos = [];
  for (const achado of miolo.matchAll(/<(h2|h3|p|li)>([\s\S]*?)<\/\1>/g)) {
    const texto = decodificar(
      achado[2]
        .replaceAll(/<\/?strong>/g, '')
        .replaceAll(/<a href="mailto:[^"]*">/g, '')
        .replaceAll('</a>', ''),
    ).trim();
    blocos.push({ tipo: achado[1], texto });
  }
  return blocos;
}

t('gera exatamente as seis rotas, uma por documento e idioma', () => {
  const esperadas = [
    'privacidade/index.html',
    'privacidade/en/index.html',
    'privacidade/es/index.html',
    'termos/index.html',
    'termos/en/index.html',
    'termos/es/index.html',
  ];
  const obtidas = [...paginas.keys()].sort();
  if (JSON.stringify(obtidas) !== JSON.stringify([...esperadas].sort())) {
    throw new Error(`rotas geradas: ${obtidas.join(', ')}`);
  }
});

t('cada página É o seu documento: mesmos blocos, mesma ordem', () => {
  for (const documento of DOCUMENTOS) {
    const fonte = fs.readFileSync(path.join(RAIZ, documento.fonte), 'utf8');
    const doDocumento = blocosDoDocumento(fonte);
    const daPagina = blocosDaPagina(porRota(documento));

    if (doDocumento.length !== daPagina.length) {
      throw new Error(
        `${documento.rota}: o documento tem ${doDocumento.length} blocos e a ` +
          `página publica ${daPagina.length}. A página deixou de ser o documento.`,
      );
    }
    for (let i = 0; i < doDocumento.length; i++) {
      if (doDocumento[i].tipo !== daPagina[i].tipo || doDocumento[i].texto !== daPagina[i].texto) {
        throw new Error(
          `${documento.rota}, bloco ${i + 1}:\n` +
            `  documento (${doDocumento[i].tipo}): ${doDocumento[i].texto.slice(0, 110)}\n` +
            `  página    (${daPagina[i].tipo}): ${daPagina[i].texto.slice(0, 110)}`,
        );
      }
    }
  }
});

t('todas as seções do documento viram <h2> na página', () => {
  // Redundante com a comparação acima de propósito: se um dia alguém afrouxar
  // aquela, esta ainda diz em voz alta que nenhuma seção pode sumir do site.
  for (const documento of DOCUMENTOS) {
    const fonte = fs.readFileSync(path.join(RAIZ, documento.fonte), 'utf8');
    const html = porRota(documento);
    const secoes = fonte
      .split('\n')
      .filter((l) => l.startsWith('## '))
      .map((l) => semMarcacao(l.slice(3)));
    if (secoes.length < 10) throw new Error(`${documento.fonte}: só ${secoes.length} seções?`);
    for (const secao of secoes) {
      if (!html.includes(`<h2>${secao}</h2>`)) {
        throw new Error(`${documento.rota}: a seção "${secao}" não chegou à página.`);
      }
    }
  }
});

t('nenhuma página diz que a nuvem é do Premium', () => {
  const achados = conferirFrasesProibidas(paginas);
  if (achados.length > 0) throw new Error(achados.join(' | '));
});

t('a catraca pega a frase reescrita, não só a copiada', () => {
  // Sem esta prova, a catraca acima seria só um "não encontrei nada" — que é
  // o que um teste que não prova nada também diz. Aqui a mentira volta com
  // outras palavras, nos três idiomas, e a catraca tem de acusar cada uma.
  const reescritas = {
    pt: 'A sincronização na nuvem é reservada a assinantes Premium.',
    en: 'Cloud syncing is reserved for Premium subscribers.',
    es: 'La sincronización en la nube está reservada a suscriptores Premium.',
  };
  for (const documento of DOCUMENTOS) {
    const adulterada = new Map([
      [`${documento.rota}index.html`, `<p>${reescritas[documento.idioma]}</p>`],
    ]);
    if (conferirFrasesProibidas(adulterada).length === 0) {
      throw new Error(
        `a catraca deixou passar, em ${documento.idioma}: "${reescritas[documento.idioma]}"`,
      );
    }
  }

  // E o contrário: a frase LEGÍTIMA — a que conserta o documento — não pode
  // ser barrada, senão a catraca obrigaria a política a calar sobre o plano.
  const legitimas = {
    pt: '<p>enviados à nuvem enquanto a sincronização estiver ligada — em qualquer plano, gratuito ou Premium.</p>',
    en: '<p>sent to the cloud while sync is on — on any plan, free or Premium.</p>',
    es: '<p>enviados a la nube mientras la sincronización esté activa — en cualquier plan, gratuito o Premium.</p>',
  };
  for (const documento of DOCUMENTOS) {
    const boa = new Map([[`${documento.rota}index.html`, legitimas[documento.idioma]]]);
    const achados = conferirFrasesProibidas(boa);
    if (achados.length > 0) {
      throw new Error(`a catraca barrou a frase correta em ${documento.idioma}: ${achados[0]}`);
    }
  }
});

t('as três políticas afirmam que a nuvem vale em qualquer plano', () => {
  // Âncora POSITIVA: proibir a frase antiga não impede a próxima reescrita de
  // simplesmente calar sobre o plano — e calar é o estado em que a mentira
  // nasceu.
  const afirmacao = { pt: 'em qualquer plano', en: 'on any plan', es: 'en cualquier plan' };
  for (const documento of DOCUMENTOS.filter((d) => d.rota.startsWith('privacidade'))) {
    const html = porRota(documento);
    if (!html.includes(afirmacao[documento.idioma])) {
      throw new Error(
        `${documento.rota}: a política publicada parou de dizer "${afirmacao[documento.idioma]}".`,
      );
    }
  }
});

t('o idioma declarado no html é o idioma do documento', () => {
  for (const documento of DOCUMENTOS) {
    const html = porRota(documento);
    if (!html.startsWith(`<!DOCTYPE html>\n<html lang="${documento.htmlLang}">`)) {
      throw new Error(`${documento.rota}: lang errado ou ausente no <html>.`);
    }
    if (!html.includes(`<link rel="canonical" href="${DOMINIO}/${documento.rota}">`)) {
      throw new Error(`${documento.rota}: sem canônica.`);
    }
  }
});

t('as três versões de um documento se apontam, e o vizinho fica no idioma', () => {
  for (const documento of DOCUMENTOS) {
    const html = porRota(documento);
    const irmaos = DOCUMENTOS.filter(
      (d) => d.rota.split('/')[0] === documento.rota.split('/')[0],
    );
    if (irmaos.length !== 3) throw new Error(`${documento.rota}: ${irmaos.length} irmãos?`);
    for (const irmao of irmaos) {
      if (!html.includes(`hreflang="${irmao.htmlLang}" href="${DOMINIO}/${irmao.rota}">`)) {
        throw new Error(`${documento.rota}: não declara a versão em ${irmao.idioma}.`);
      }
      if (irmao.id !== documento.id && !html.includes(`href="/${irmao.rota}"`)) {
        throw new Error(`${documento.rota}: a tira de idiomas não leva a /${irmao.rota}.`);
      }
    }
    // O x-default é para quem chega sem idioma declarado. Tem de apontar
    // para o português: é o documento original, e os outros dois são
    // tradução dele.
    const emPortugues = irmaos.find((d) => d.idioma === 'pt');
    if (!html.includes(`hreflang="x-default" href="${DOMINIO}/${emPortugues.rota}">`)) {
      throw new Error(
        `${documento.rota}: o x-default não aponta para /${emPortugues.rota} — o ` +
          'rastreador fica sem padrão, ou com o padrão errado.',
      );
    }
    // Política e termos se apontam DENTRO do mesmo idioma: mandar quem lê em
    // espanhol para o documento em português seria perder a tradução no
    // último passo.
    const par = DOCUMENTOS.find((d) => d.id === documento.par);
    if (par.idioma !== documento.idioma) throw new Error('o par mudou de idioma');
    if (!html.includes(`href="/${par.rota}"`)) {
      throw new Error(`${documento.rota}: não leva ao documento vizinho /${par.rota}.`);
    }
  }
});

t('a moldura não é JavaScript e não vaza para fora do domínio', () => {
  for (const documento of DOCUMENTOS) {
    const html = porRota(documento);
    if (/<script/i.test(html)) {
      throw new Error(`${documento.rota}: ganhou script — a página é lida por rastreador.`);
    }
    for (const achado of html.matchAll(/href="(https?:[^"]+)"/g)) {
      const permitido =
        achado[1].startsWith(DOMINIO) ||
        achado[1].startsWith('https://fonts.googleapis.com') ||
        achado[1].startsWith('https://fonts.gstatic.com');
      if (!permitido) throw new Error(`${documento.rota}: link externo novo — ${achado[1]}`);
    }
  }
});

t('não sobrou página legal escrita à mão em site/', () => {
  // A montagem gera DEPOIS de copiar site/, então um arquivo esquecido aqui
  // seria substituído em silêncio — e voltaria a divergir no editor de quem o
  // abrisse por engano.
  for (const caminho of ['site/privacidade/index.html', 'site/termos/index.html']) {
    if (fs.existsSync(path.join(RAIZ, caminho))) {
      throw new Error(
        `${caminho} voltou a existir. As páginas legais vêm de assets/legal/*.md ` +
          '— edite o documento, não o HTML.',
      );
    }
  }
});

t('o conversor escapa os caracteres que viram marcação', () => {
  // O & e o < que aparecem como TEXTO (uma comparação, uma empresa "A & B")
  // não podem chegar crus ao navegador — viram entidade. O que PARECE tag é
  // caso à parte e está na lista de recusas abaixo: escapá-lo em silêncio
  // publicaria "&lt;script&gt;" visível no meio da política, que é errado de
  // outro jeito.
  const convertido = converterMarkdown(
    '# T — A\n\nvigência\n\nabertura\n\n## 1. x\n\nA & B, com 7 < 13 > 2 anos\n',
    'sintético.md',
  );
  if (!convertido.corpoHtml.includes('A &amp; B, com 7 &lt; 13 &gt; 2 anos')) {
    throw new Error('texto não escapado: ' + convertido.corpoHtml);
  }
});

t('o conversor para diante do que não sabe, em vez de publicar errado', () => {
  const cabecalho = '# T — A\n\nvigência\n\nabertura\n\n';
  const recusas = [
    ['[termos](/termos/)', 'link'],
    ['![foto](a.png)', 'imagem'],
    ['use `codigo` aqui', 'código'],
    ['um <script>alerta()</script> no meio', 'HTML embutido'],
    ['**aberto e nunca fechado', '** ímpar'],
    ['1. primeiro', 'lista numerada'],
    ['> citação', 'citação'],
    ['  indentado', 'linha indentada'],
    ['#### fundo demais', 'quarto nível'],
    ['um * solto', 'asterisco solto'],
    // As sete abaixo PASSAVAM caladas até esta revisão, publicando a marcação
    // crua no meio da política. Nenhuma delas cai no `](` que a primeira
    // versão procurava — e "o conversor para diante do que não conhece" só é
    // verdade se ele parar diante destas também.
    ['texto com _itálico_ aqui', 'ênfase com _'],
    ['texto com __negrito__ aqui', 'negrito com __'],
    ['veja os [termos][t] aqui', 'link de referência'],
    ['uma afirmação[^1]', 'nota de rodapé'],
    ['+ um item de lista', 'lista com marcador +'],
    ['~~riscado~~', 'tachado'],
    ['Título grande\n===', 'título sublinhado com ='],
    // As quatro abaixo também passavam caladas, e a primeira é a única do
    // grupo com consequência no que a pessoa LÊ: a linha quebrada partia a
    // data de vigência ao meio (o caso dedicado a ela é o penúltimo deste
    // arquivo).
    ['um parágrafo que o autor\nquebrou em duas linhas', 'parágrafo colado na linha de cima'],
    ['## Fecha com hashes ##', 'fecho ATX no título'],
    ['- - -', 'régua escrita com espaços'],
    ['um espaço&nbsp;que não quebra', 'entidade HTML'],
  ];
  for (const [corpo, oQue] of recusas) {
    let parou = false;
    try {
      converterMarkdown(cabecalho + corpo + '\n', 'sintético.md');
    } catch (e) {
      parou = true;
      if (!/sintético\.md:\d+/.test(e.message)) {
        throw new Error(`"${oQue}": o erro não diz a linha — ${e.message}`);
      }
    }
    if (!parou) throw new Error(`o conversor aceitou "${oQue}" em silêncio.`);
  }
});

t('o título de primeiro nível recusa negrito, e a prévia de link sai sem asterisco', () => {
  // Dois lugares onde a marcação não tem como ser honrada e escapava.
  //
  // O título vira <h1>, <title> e og:title: nos dois últimos só cabe texto
  // puro, então `# **Política** — App` publicava os asteriscos na aba do
  // navegador. Agora para.
  let parou = false;
  try {
    converterMarkdown('# **T** — A\n\nvigência\n\nabertura\n\n## 1. x\n\ny\n', 'sintético.md');
  } catch {
    parou = true;
  }
  if (!parou) throw new Error('o conversor aceitou negrito no título de primeiro nível.');

  // A descrição da prévia nasce do parágrafo de abertura, onde o negrito É
  // legítimo — ali a saída certa não é parar, é publicar o texto sem a
  // marcação, porque um atributo não aceita <strong>.
  const convertido = converterMarkdown(
    '# T — A\n\nvigência\n\nabertura com **negrito** dentro\n\n## 1. x\n\ny **forte** z\n',
    'sintético.md',
  );
  const documento = DOCUMENTOS.find((d) => d.id === 'privacidade-pt');
  const html = montarPagina(documento, convertido, new Map(DOCUMENTOS.map((d) => [d.id, convertido])));
  for (const meta of ['name="description"', 'property="og:description"']) {
    const achado = html.match(new RegExp(`${meta} content="([^"]*)"`));
    if (!achado) throw new Error(`a página perdeu ${meta}.`);
    if (achado[1].includes('*')) {
      throw new Error(`a prévia de link saiu com marcação crua: ${achado[1]}`);
    }
  }
  // E o corpo, que aceita, continua marcando.
  if (!html.includes('<strong>forte</strong>')) {
    throw new Error('o negrito sumiu do corpo da página.');
  }
});

t('a data de vigência não se parte, e o parágrafo abaixo do ### continua valendo', () => {
  // O caso concreto do ponto cego: vigência e abertura são pegas por POSIÇÃO
  // (1º e 2º parágrafos). Com a linha da data quebrada, a página publicava
  // "Última atualização: 13 de setembro de" — sem o ano — e o ano sozinho
  // virava a descrição da prévia do link. Nenhum erro, publicação calada.
  let parou = false;
  try {
    converterMarkdown(
      '# T — A\n\nÚltima atualização: 13 de setembro de\n2026\n\nabertura\n',
      'sintético.md',
    );
  } catch (e) {
    parou = true;
    if (!/sintético\.md:4/.test(e.message)) {
      throw new Error('o erro não aponta a linha quebrada: ' + e.message);
    }
  }
  if (!parou) throw new Error('a data de vigência foi partida em duas em silêncio.');

  // E o outro lado da recusa: parágrafo logo abaixo de um "###", sem linha em
  // branco no meio, é construção legítima que os três documentos de
  // privacidade usam quinze vezes. Se esta recusa a pegasse junto, a
  // publicação de produção pararia HOJE.
  const convertido = converterMarkdown(
    '# T — A\n\nvigência\n\nabertura\n\n### Dados de conta\nNome e e-mail.\n',
    'sintético.md',
  );
  if (!convertido.corpoHtml.includes('<h3>Dados de conta</h3>')) {
    throw new Error('o ### sumiu: ' + convertido.corpoHtml);
  }
  if (!convertido.corpoHtml.includes('<p>Nome e e-mail.</p>')) {
    throw new Error('o parágrafo colado no ### foi recusado por engano: ' + convertido.corpoHtml);
  }
});

t('a lista de frases proibidas cobre os três idiomas', () => {
  // Um idioma novo sem coluna aqui publicaria sem catraca nenhuma. Melhor
  // falhar pelo nome do que passar em branco.
  for (const idioma of new Set(DOCUMENTOS.map((d) => d.idioma))) {
    const frases = FRASES_PROIBIDAS[idioma];
    if (!frases || frases.length === 0) {
      throw new Error(`falta a coluna de "${idioma}" em FRASES_PROIBIDAS.`);
    }
  }
});

let falhas = 0;
for (const [nome, fn] of casos) {
  try {
    await fn();
    console.log('  ok  ' + nome);
  } catch (e) {
    falhas++;
    console.log('  FALHOU  ' + nome + '  -> ' + e.message);
  }
}
console.log(falhas ? `\n${falhas} falha(s)` : `\n${casos.length} casos, todos passaram`);
process.exit(falhas ? 1 : 0);
