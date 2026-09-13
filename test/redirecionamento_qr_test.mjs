// O `/baixar` (functions/baixar.js) é uma Cloudflare Pages Function: roda no
// servidor, não no app, e `flutter test` nunca chega perto dele. Este é o
// único gate que o exercita — e o que ele protege é caro de descobrir depois:
// um QR impresso não pode ser corrigido, então um destino errado só aparece
// quando alguém já imprimiu o cartaz.
//
// Uso: node test/redirecionamento_qr_test.mjs
import assert from 'node:assert/strict';
import test from 'node:test';

import { decidirDestino, onRequest, plataformaDe } from '../functions/baixar.js';

const PLAY = 'https://play.google.com/store/apps/details';
const SITE = 'https://grimoriodebolso.app';

// User-Agents reais, copiados de aparelhos, não inventados: é a forma exata
// deles que o código lê.
const UA = {
  androidChrome:
      'Mozilla/5.0 (Linux; Android 14; SM-S911B) AppleWebKit/537.36 ' +
      '(KHTML, like Gecko) Chrome/125.0.0.0 Mobile Safari/537.36',
  // O navegador embutido do Instagram — por onde muita leitura de QR passa.
  androidInstagram:
      'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 ' +
      '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 ' +
      'Instagram 316.0.0.0.0 Android (33/13; 420dpi; 1080x2211; Google/google)',
  iphone:
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) ' +
      'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 ' +
      'Safari/604.1',
  ipad:
      'Mozilla/5.0 (iPad; CPU OS 17_5 like Mac OS X) AppleWebKit/605.1.15 ' +
      '(KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1',
  // iPadOS em "modo desktop": diz Macintosh. Indistinguível de um Mac — e não
  // precisa ser distinguido, porque os dois vão para o app web.
  ipadModoDesktop:
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 ' +
      '(KHTML, like Gecko) Version/17.5 Safari/605.1.15',
  windows:
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 ' +
      '(KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
};

const destinoDe = (userAgent, endereco = `${SITE}/baixar`) =>
    decidirDestino(userAgent, new URL(endereco));

test('Android vai para a Play', () => {
  for (const ua of [UA.androidChrome, UA.androidInstagram]) {
    const destino = destinoDe(ua);
    assert.ok(destino.startsWith(PLAY), `esperava a Play, veio ${destino}`);
    assert.equal(
        new URL(destino).searchParams.get('id'), 'com.grimoriodebolso.app');
  }
});

test('iPhone e iPad vão para o app web — não existe App Store', () => {
  for (const ua of [UA.iphone, UA.ipad, UA.ipadModoDesktop]) {
    assert.equal(destinoDe(ua), `${SITE}/`);
  }
});

test('desktop e User-Agent ausente vão para o app web', () => {
  assert.equal(destinoDe(UA.windows), `${SITE}/`);
  assert.equal(destinoDe(''), `${SITE}/`);
  assert.equal(destinoDe(null), `${SITE}/`);
  assert.equal(destinoDe(undefined), `${SITE}/`);
});

test('o app web fica na origem que recebeu a leitura', () => {
  // Sem isto, o /baixar de uma prévia mandaria quem testa para o site
  // publicado — e o teste "a novidade não aparece" nasceria de novo.
  const previa = 'https://staging.grimorio-de-bolso.pages.dev';
  assert.equal(destinoDe(UA.iphone, `${previa}/baixar`), `${previa}/`);
});

test('?destino força o lado, para conferir os dois de qualquer aparelho', () => {
  assert.ok(destinoDe(UA.iphone, `${SITE}/baixar?destino=play`).startsWith(PLAY));
  assert.equal(destinoDe(UA.androidChrome, `${SITE}/baixar?destino=web`), `${SITE}/`);
  // Valor sem sentido não vira um terceiro comportamento: volta a decidir pelo
  // aparelho.
  assert.ok(
      destinoDe(UA.androidChrome, `${SITE}/baixar?destino=marte`).startsWith(PLAY));
});

test('?origem vira o utm_source dentro do referrer da Play', () => {
  const destino = destinoDe(UA.androidChrome, `${SITE}/baixar?origem=panfleto`);

  // O referrer é uma query string inteira dentro de UM parâmetro. Se ele não
  // for escapado como valor único, a Play recebe utm_medium como parâmetro
  // dela e o rastro se perde.
  assert.ok(
      destino.includes('referrer=utm_source%3Dpanfleto%26utm_medium%3Dqr'),
      `referrer mal escapado: ${destino}`);

  const referrer = new URL(destino).searchParams.get('referrer');
  const utms = new URLSearchParams(referrer);
  assert.equal(utms.get('utm_source'), 'panfleto');
  assert.equal(utms.get('utm_medium'), 'qr');
  assert.equal(utms.get('utm_campaign'), 'baixar');
});

test('origem inválida cai no padrão em vez de entrar crua no link', () => {
  for (const suja of ['<script>', 'com espaço', 'a'.repeat(33), '', 'acentuação']) {
    const destino =
        destinoDe(UA.androidChrome, `${SITE}/baixar?origem=${encodeURIComponent(suja)}`);
    const utms = new URLSearchParams(new URL(destino).searchParams.get('referrer'));
    assert.equal(utms.get('utm_source'), 'qr', `origem "${suja}" vazou`);
  }
});

test('plataformaDe classifica sem depender do resto', () => {
  assert.equal(plataformaDe(UA.androidChrome), 'android');
  assert.equal(plataformaDe(UA.iphone), 'ios');
  assert.equal(plataformaDe(UA.windows), 'outra');
  assert.equal(plataformaDe(undefined), 'outra');
});

test('a resposta é um 302 que nenhum cache pode reaproveitar', async () => {
  const resposta = await onRequest({
    request: new Request(`${SITE}/baixar`, {
      headers: { 'user-agent': UA.androidChrome },
    }),
  });

  // 301 ficaria gravado no navegador para sempre — e o destino deste endereço
  // muda no dia em que houver App Store.
  assert.equal(resposta.status, 302);
  assert.ok(resposta.headers.get('location').startsWith(PLAY));
  assert.equal(resposta.headers.get('cache-control'), 'no-store');
  assert.equal(resposta.headers.get('vary'), 'User-Agent');
});

test('o corpo de emergência traz o link escapado como HTML', async () => {
  // Só aparece se algo não seguir o 302. O `&` do link da Play precisa virar
  // `&amp;` dentro do atributo, senão o href chega truncado.
  const resposta = await onRequest({
    request: new Request(`${SITE}/baixar`, {
      headers: { 'user-agent': UA.androidChrome },
    }),
  });

  const corpo = await resposta.text();
  assert.ok(corpo.includes('href="https://play.google.com'), corpo);
  assert.ok(corpo.includes('&amp;referrer='), corpo);
  assert.ok(!/href="[^"]*[^m]&referrer/.test(corpo), corpo);
});
