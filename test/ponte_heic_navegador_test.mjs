// A ponte de HEIC num navegador DE VERDADE: o libheif compilado em wasm
// decodificando um HEIC real, servido como na publicação (web/heic/).
//
// Existe porque o teste em Node (ponte_heic_test.mjs) prova o encadeamento
// com um libheif de mentira — e foi justamente o libheif de verdade que
// quebrou na primeira publicação (a variante compilada não buscava o .wasm
// sozinha). Este aqui pega esse tipo de coisa.
//
// Uso: node test/ponte_heic_navegador_test.mjs
// Precisa do playwright-core (npm i --no-save playwright-core) e de um
// Chrome: o do sistema (`channel: 'chrome'`) ou o caminho em PW_EXECUTAVEL.
import fs from 'node:fs';
import http from 'node:http';
import path from 'node:path';
import url from 'node:url';

const raiz = path.dirname(path.dirname(url.fileURLToPath(import.meta.url)));
const pastaWeb = path.join(raiz, 'web');
const amostra = path.join(raiz, 'test', 'fixtures', 'amostra.heic');

const { chromium } = await import('playwright-core').catch(() => {
  console.error('playwright-core ausente: npm i --no-save playwright-core');
  process.exit(2);
});

const tipos = { '.html': 'text/html', '.js': 'text/javascript', '.wasm': 'application/wasm', '.heic': 'image/heic' };
const pagina = `<!doctype html><html><head><meta charset="utf-8"><base href="/">
<script src="heic/decodificador_heic.js" defer></script></head><body>ponte</body></html>`;

// Servidor estático mínimo: a raiz é a pasta web/ (como no site publicado)
// mais a amostra em /amostra.heic.
const servidor = http.createServer((req, res) => {
  const caminho = new URL(req.url, 'http://x').pathname;
  if (caminho === '/') { res.writeHead(200, { 'content-type': 'text/html' }); res.end(pagina); return; }
  const arquivo = caminho === '/amostra.heic' ? amostra : path.join(pastaWeb, caminho);
  if (!arquivo.startsWith(pastaWeb) && arquivo !== amostra) { res.writeHead(403); res.end(); return; }
  fs.readFile(arquivo, (erro, dados) => {
    if (erro) { res.writeHead(404); res.end(); return; }
    res.writeHead(200, { 'content-type': tipos[path.extname(arquivo)] || 'application/octet-stream' });
    res.end(dados);
  });
});
await new Promise((ok) => servidor.listen(0, '127.0.0.1', ok));
const porta = servidor.address().port;

const executavel = process.env.PW_EXECUTAVEL;
const navegador = await chromium.launch(
  executavel ? { executablePath: executavel, args: ['--no-sandbox'] } : { channel: 'chrome', args: ['--no-sandbox'] },
);
let falhas = 0;
try {
  const aba = await navegador.newPage();
  const erros = [];
  aba.on('pageerror', (e) => erros.push(e.message));
  aba.on('requestfailed', (r) => erros.push('rede: ' + r.url()));
  await aba.goto(`http://127.0.0.1:${porta}/`, { waitUntil: 'load' });

  const r = await aba.evaluate(async () => {
    const bytes = new Uint8Array(await (await fetch('amostra.heic')).arrayBuffer());
    const t0 = performance.now();
    const bitmap = await window.grimorioHeic.paraBitmap(bytes);
    const ms = Math.round(performance.now() - t0);
    if (!bitmap) return { ms, motivo: window.grimorioHeic.ultimoMotivo };
    // Um pixel do quadrado verde da amostra: prova que os pixels sao os certos,
    // e nao so' que "veio um bitmap".
    const c = document.createElement('canvas'); c.width = bitmap.width; c.height = bitmap.height;
    const ctx = c.getContext('2d'); ctx.drawImage(bitmap, 0, 0);
    const p = ctx.getImageData(48, 32, 1, 1).data;
    const canto = ctx.getImageData(2, 2, 1, 1).data;
    // Fechar zera width/height: le antes.
    const largura = bitmap.width, altura = bitmap.height;
    bitmap.close();
    return { ms, largura, altura, verde: [p[0], p[1], p[2]], canto: [canto[0], canto[1], canto[2]] };
  });

  const conferir = (ok, msg) => { if (ok) console.log('  ok  ' + msg); else { falhas++; console.log('  FALHOU  ' + msg + '  -> ' + JSON.stringify(r)); } };
  conferir(r.largura === 96 && r.altura === 64, 'decodifica a amostra 96×64 (' + (r.ms ?? '?') + ' ms)');
  conferir(r.verde && r.verde[1] > 150 && r.verde[0] < 80, 'o quadrado verde da amostra esta la');
  conferir(r.canto && r.canto[2] > 100 && r.canto[0] < 60, 'o gradiente do canto esta la');
  conferir(erros.length === 0, 'sem erros de pagina ou de rede' + (erros.length ? ': ' + erros.join('; ') : ''));

  const nada = await aba.evaluate(async () => {
    const r = await window.grimorioHeic.paraBitmap(new Uint8Array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]));
    return { r, motivo: window.grimorioHeic.ultimoMotivo };
  });
  conferir(nada.r === null && nada.motivo === 'sem imagens', 'bytes que nao sao HEIF: null com motivo "sem imagens"');
} finally {
  await navegador.close();
  servidor.close();
}
console.log(falhas ? `\n${falhas} falha(s)` : '\nponte HEIC no navegador: tudo passou');
process.exit(falhas ? 1 : 0);
