// `/baixar` — o endereço único do QR code.
//
// Um QR impresso não pode ser trocado depois. Então ele aponta para ESTE
// endereço, e é aqui — no servidor, a cada leitura — que se decide para onde
// a pessoa vai:
//
//   Android          → Google Play (com.grimoriodebolso.app)
//   iPhone/iPad      → o app web, na mesma origem de onde veio a leitura
//   qualquer outro   → o app web
//
// O iOS cai no app web porque não existe publicação na App Store; no dia em
// que existir, é só acrescentar o ramo aqui e todo QR já impresso passa a
// levar para lá. Essa é a razão de o QR não apontar direto para a Play.
//
// Por que uma Function e não uma página com JavaScript: o leitor de QR abre o
// navegador já no destino, sem tela intermediária piscando, sem depender de
// JavaScript e sem um segundo salto. A decisão sai do `User-Agent`, que só o
// servidor vê.
//
// Como isto chega ao ar: `wrangler pages deploy public` compila o diretório
// `functions/` da RAIZ do repositório (não o de dentro de `public/`) e gera o
// roteamento sozinho — só `/baixar` passa por aqui, todo o resto continua
// sendo arquivo estático servido direto. Ver `.github/workflows/*.yml`.

// O pacote na Play. Espelha `android/app/build.gradle` (applicationId).
const PACOTE_ANDROID = 'com.grimoriodebolso.app';

const PLAY_STORE = 'https://play.google.com/store/apps/details';

// De onde veio a leitura, quando `?origem=` não diz.
const ORIGEM_PADRAO = 'qr';

// `?origem=` vira `utm_source` DENTRO do link da Play, então só aceita o que
// é seguro num parâmetro: sem espaço, sem acento, sem `<`. Um valor fora
// disso não derruba nada — cai no padrão.
const ORIGEM_ACEITA = /^[a-z0-9_-]{1,32}$/i;

// `Android` aparece em toda UA de Android, inclusive nos navegadores embutidos
// do Instagram e do WhatsApp — que é por onde muita gente abre um QR.
const E_ANDROID = /android/i;

// iPadOS em "modo desktop" mente e se diz Macintosh. Não tem conserto pelo
// User-Agent — e aqui não faz falta: Mac e iPad vão para o mesmo lugar.
const E_IOS = /iphone|ipad|ipod/i;

// `android` | `ios` | `outra` — o que o `User-Agent` entrega.
export function plataformaDe(userAgent) {
  const ua = userAgent ?? '';
  if (E_ANDROID.test(ua)) return 'android';
  if (E_IOS.test(ua)) return 'ios';
  return 'outra';
}

// O link da Play com o rastro de instalação embutido.
//
// O `referrer` é uma query string INTEIRA codificada como um único valor — é
// esse formato que a Play repassa ao app e mostra no relatório de aquisição.
// Daí os dois `URLSearchParams`: o de dentro monta as UTMs, o de fora as
// escapa.
function linkDaPlay(origem) {
  const rastro = new URLSearchParams({
    utm_source: origem,
    utm_medium: 'qr',
    utm_campaign: 'baixar',
  }).toString();

  const parametros = new URLSearchParams({
    id: PACOTE_ANDROID,
    referrer: rastro,
  });

  return `${PLAY_STORE}?${parametros}`;
}

// Para onde esta leitura vai. Recebe a URL pedida para responder na MESMA
// origem: em produção o app web é grimoriodebolso.app, na prévia de uma
// branch é o endereço da prévia — e assim o `/baixar` de um deploy de teste
// não joga ninguém no site publicado.
//
// `?destino=play` e `?destino=web` forçam um dos lados, para conferir os dois
// caminhos de qualquer aparelho (e para um QR que deva ir sempre à Play).
export function decidirDestino(userAgent, url) {
  const origemPedida = url.searchParams.get('origem');
  const origem = ORIGEM_ACEITA.test(origemPedida ?? '')
    ? origemPedida
    : ORIGEM_PADRAO;

  const appWeb = new URL('/', url).toString();

  switch (url.searchParams.get('destino')) {
    case 'play':
      return linkDaPlay(origem);
    case 'web':
      return appWeb;
  }

  return plataformaDe(userAgent) === 'android' ? linkDaPlay(origem) : appWeb;
}

// O destino entra num atributo HTML no corpo do redirecionamento. O link da
// Play já vem com `&` de verdade (que num atributo precisa virar `&amp;`), e o
// endereço do app web nasce do cabeçalho `Host` — que a Cloudflare valida
// antes de chegar aqui, mas não é motivo para confiar nele por aqui também.
function escaparHtml(texto) {
  return texto
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}

export async function onRequest({ request }) {
  const url = new URL(request.url);
  const destino = decidirDestino(request.headers.get('user-agent'), url);

  // 302, nunca 301: um 301 fica gravado no navegador para sempre, e no dia em
  // que o iOS ganhar destino próprio (ou o app sair da Play) quem já leu o QR
  // continuaria indo para o endereço antigo, sem nada a fazer a respeito.
  //
  // `no-store` + `Vary` pelo mesmo motivo, de outro ângulo: sem eles, um cache
  // no caminho poderia servir a um iPhone a resposta que foi calculada para um
  // Android.
  //
  // O corpo só aparece se algo não seguir o redirecionamento (certos
  // navegadores embutidos): melhor um link para tocar do que uma tela vazia.
  return new Response(
    `<!DOCTYPE html><html lang="pt-BR"><meta charset="utf-8">` +
      `<title>Grimório de Bolso</title>` +
      `<p>Abrindo o Grimório de Bolso… ` +
      `<a href="${escaparHtml(destino)}">toque aqui se nada acontecer</a>.`,
    {
      status: 302,
      headers: {
        Location: destino,
        'Content-Type': 'text/html; charset=utf-8',
        'Cache-Control': 'no-store',
        Vary: 'User-Agent',
      },
    },
  );
}
