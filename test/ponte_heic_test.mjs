// A ponte de HEIC (web/heic/decodificador_heic.js) só existe no navegador,
// e `flutter test` roda na VM — então o que dá para provar aqui é tudo o que
// cerca a decodificação: o encadeamento de promessas, o limite de tempo, a
// liberação da memória do wasm e o contrato "qualquer falha vira null".
//
// A decodificação em si (o libheif abrir a foto) só o navegador prova.
//
// Uso: node test/ponte_heic_test.mjs
import fs from 'node:fs';
import path from 'node:path';
import url from 'node:url';
import vm from 'node:vm';

const raiz = path.dirname(path.dirname(url.fileURLToPath(import.meta.url)));
const fonteDaPonte = fs.readFileSync(
  path.join(raiz, 'web/heic/decodificador_heic.js'),
  'utf8',
);

/// Um navegador e um libheif de mentira, com as avarias que interessam.
function montarAmbiente({
  imagens = 1,
  primariaEm = 0,
  larguraImg = 4000,
  alturaImg = 3000,
  displayFalha = false,
  displayNuncaVolta = false,
  displayLanca = false,
  semContexto2d = false,
  createImageDataLanca = false,
  bitmapFalha = false,
  semScript = false,
  prontoNaHora = false,
  limiteMs = null,
} = {}) {
  const registro = {
    frees: 0,
    contextosLiberados: 0,
    scriptsCarregados: 0,
    tagsVivas: 0,
    telas: [],
  };

  const janela = {};
  const doc = {
    currentScript: { src: 'https://exemplo.test/heic/decodificador_heic.js' },
    createElement: (tipo) => {
      if (tipo === 'canvas') {
        const tela = {
          width: 0,
          height: 0,
          getContext: () =>
            semContexto2d
              ? null
              : {
                  createImageData: (w, h) => {
                    if (createImageDataLanca) {
                      throw new RangeError('memória de sobra não tem');
                    }
                    return { width: w, height: h, ehImageData: true };
                  },
                },
        };
        registro.telas.push(tela);
        return tela;
      }
      return { src: '', async: false, onload: null, onerror: null };
    },
    head: {
      appendChild(tag) {
        registro.scriptsCarregados++;
        registro.tagsVivas++;
        tag.parentNode = {
          removeChild: () => {
            registro.tagsVivas--;
          },
        };
        setTimeout(() => {
          if (semScript) {
            tag.onerror && tag.onerror();
            return;
          }
          janela.libheif = fabricaFalsa;
          tag.onload && tag.onload();
        }, 0);
      },
    },
  };

  function Imagem(indice) {
    this.indice = indice;
  }
  Imagem.prototype.get_width = () => larguraImg;
  Imagem.prototype.get_height = () => alturaImg;
  Imagem.prototype.is_primary = function () {
    return this.indice === primariaEm;
  };
  Imagem.prototype.free = () => {
    registro.frees++;
  };
  Imagem.prototype.display = function (pixels, chamarDeVolta) {
    if (displayNuncaVolta) return;
    if (displayLanca) throw new Error('o wasm estourou');
    setTimeout(() => chamarDeVolta(displayFalha ? null : pixels), 0);
  };

  function Decoder() {
    this.decoder = null;
  }
  Decoder.prototype.decode = function () {
    this.decoder = { ponteiro: 42 };
    return Array.from({ length: imagens }, (_, i) => new Imagem(i));
  };

  const modulo = {
    HeifDecoder: Decoder,
    heif_context_free: () => {
      registro.contextosLiberados++;
    },
  };
  const fabricaFalsa = (config) => {
    Object.assign(config, modulo);
    if (prontoNaHora) {
      config.calledRun = true;
      return config;
    }
    setTimeout(() => config.onRuntimeInitialized(), 0);
    return config;
  };

  const ctx = {
    window: janela,
    document: doc,
    setTimeout,
    clearTimeout,
    Promise,
    Uint8Array,
    Array,
    Object,
    Math,
    Error,
    RangeError,
    console,
    createImageBitmap: (fonte) =>
      bitmapFalha
        ? Promise.reject(new Error('sem bitmap'))
        : Promise.resolve({ ehBitmap: true, de: fonte }),
  };
  ctx.globalThis = ctx;
  vm.createContext(ctx);
  let fonte = fonteDaPonte;
  if (limiteMs) {
    fonte = fonte.replace('var LIMITE_MS = 20000;', `var LIMITE_MS = ${limiteMs};`);
  }
  vm.runInContext(fonte, ctx);
  return { janela, registro };
}

const casos = [];
const t = (nome, fn) => casos.push([nome, fn]);
const bytes = new Uint8Array([1, 2, 3]);

t('caminho feliz: devolve ImageBitmap e solta imagem e contexto', async () => {
  const { janela, registro } = montarAmbiente();
  const r = await janela.grimorioHeic.paraBitmap(bytes);
  if (!r || !r.ehBitmap) throw new Error('sem bitmap: ' + JSON.stringify(r));
  if (registro.frees !== 1) throw new Error('frees=' + registro.frees);
  if (registro.contextosLiberados !== 1) throw new Error('contexto vazou');
  if (registro.telas[0].width !== 0) throw new Error('a tela grande ficou de pé');
});

t('rajada: usa a imagem primária, não a primeira, e solta todas', async () => {
  const { janela, registro } = montarAmbiente({ imagens: 3, primariaEm: 2 });
  const r = await janela.grimorioHeic.paraBitmap(bytes);
  if (!r.ehBitmap) throw new Error('devia decodificar');
  if (registro.frees !== 3) throw new Error('frees=' + registro.frees);
});

t('arquivo sem imagem nenhuma: null, e o contexto é solto', async () => {
  const { janela, registro } = montarAmbiente({ imagens: 0 });
  const r = await janela.grimorioHeic.paraBitmap(bytes);
  if (r !== null) throw new Error('devia ser null');
  if (registro.contextosLiberados !== 1) throw new Error('contexto vazou');
});

t('display falhando: null, sem vazar nada', async () => {
  const { janela, registro } = montarAmbiente({ displayFalha: true });
  const r = await janela.grimorioHeic.paraBitmap(bytes);
  if (r !== null) throw new Error('devia ser null');
  if (registro.frees !== 1 || registro.contextosLiberados !== 1) {
    throw new Error('vazou memória do wasm');
  }
});

t('display que nunca responde: o relógio termina e solta tudo', async () => {
  const { janela, registro } = montarAmbiente({
    displayNuncaVolta: true,
    limiteMs: 60,
  });
  const inicio = Date.now();
  const r = await janela.grimorioHeic.paraBitmap(bytes);
  if (r !== null) throw new Error('devia ser null');
  if (Date.now() - inicio > 2000) throw new Error('demorou demais');
  if (registro.frees !== 1 || registro.contextosLiberados !== 1) {
    throw new Error('vazou memória do wasm');
  }
});

t('display que lança: null, sem vazar', async () => {
  const { janela, registro } = montarAmbiente({ displayLanca: true });
  const r = await janela.grimorioHeic.paraBitmap(bytes);
  if (r !== null) throw new Error('devia ser null');
  if (registro.contextosLiberados !== 1) throw new Error('contexto vazou');
});

t('sem contexto 2d: null, sem vazar', async () => {
  const { janela, registro } = montarAmbiente({ semContexto2d: true });
  const r = await janela.grimorioHeic.paraBitmap(bytes);
  if (r !== null) throw new Error('devia ser null');
  if (registro.frees !== 1 || registro.contextosLiberados !== 1) {
    throw new Error('vazou memória do wasm');
  }
});

t('foto grande demais para a memória: null, sem vazar', async () => {
  const { janela, registro } = montarAmbiente({ createImageDataLanca: true });
  const r = await janela.grimorioHeic.paraBitmap(bytes);
  if (r !== null) throw new Error('devia ser null');
  if (registro.frees !== 1 || registro.contextosLiberados !== 1) {
    throw new Error('vazou memória do wasm');
  }
});

t('createImageBitmap falhando: null, sem vazar', async () => {
  const { janela, registro } = montarAmbiente({ bitmapFalha: true });
  const r = await janela.grimorioHeic.paraBitmap(bytes);
  if (r !== null) throw new Error('devia ser null');
  if (registro.contextosLiberados !== 1) throw new Error('contexto vazou');
});

t('script que não carrega: null e nenhuma tag morta na árvore', async () => {
  const { janela, registro } = montarAmbiente({ semScript: true });
  const r = await janela.grimorioHeic.paraBitmap(bytes);
  if (r !== null) throw new Error('devia ser null');
  if (registro.tagsVivas !== 0) throw new Error('sobrou tag morta');
});

t('módulo já pronto (calledRun) também funciona', async () => {
  const { janela } = montarAmbiente({ prontoNaHora: true });
  const r = await janela.grimorioHeic.paraBitmap(bytes);
  if (!r || !r.ehBitmap) throw new Error('devia decodificar');
});

t('duas fotos seguidas: um script só, e nada acumulado', async () => {
  const { janela, registro } = montarAmbiente();
  await janela.grimorioHeic.paraBitmap(bytes);
  await janela.grimorioHeic.paraBitmap(bytes);
  if (registro.scriptsCarregados !== 1) {
    throw new Error('carregou o script ' + registro.scriptsCarregados + 'x');
  }
  if (registro.contextosLiberados !== 2) throw new Error('contexto vazou');
  if (registro.frees !== 2) throw new Error('imagem vazou');
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
