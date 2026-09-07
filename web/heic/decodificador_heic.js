// Ponte para o libheif: bytes HEIC/HEIF -> ImageBitmap que a tela consegue
// desenhar.
//
// O Chrome nao decodifica HEIC/HEIF, que e' o formato padrao da camera de
// muitos Androids e de todo iPhone. Sem isto, `createImageBitmap` recusa a
// foto, a previa nem aparece e a pessoa recebe um "converta para JPG" que
// ela nao deveria ter de resolver.
//
// A biblioteca (1,5 MB) so' e' baixada quando uma foto HEIC aparece de fato:
// quem so' usa JPEG nunca paga por ela.
//
// Contrato com o Dart: paraBitmap(bytes) devolve um ImageBitmap ou null.
// NUNCA lanca e NUNCA fica pendurada. Devolver ImageBitmap, e nao um JPEG,
// evita uma codificacao e uma decodificacao inteiras no meio do caminho —
// numa foto de 12 MP isso e' ~100 MB de pico a menos.
(function () {
  // O caminho sai do proprio endereco deste arquivo, e nao de uma constante:
  // assim vale com qualquer <base href> e em qualquer subpasta.
  var meuEndereco =
    (document.currentScript && document.currentScript.src) || '';
  var PASTA = meuEndereco ? meuEndereco.replace(/[^/]*$/, '') : 'heic/';
  var CAMINHO_DO_SCRIPT = PASTA + 'libheif.js';
  var CAMINHO_DO_WASM = PASTA + 'libheif.wasm';

  // Menor que o tempo-limite de quem chama, para a resposta ser "nao deu"
  // em vez de um estouro de prazo la' em cima. Cabe o download de 1,5 MB em
  // rede movel mais a decodificacao de uma foto de 12 MP num celular
  // (~0,3 s por megapixel no desktop; um celular modesto leva 3-4x isso).
  var LIMITE_MS = 45000;

  var promessaDoScript = null;
  var promessaDoWasm = null;
  var promessaDoModulo = null;

  // Por que o ultimo pedido devolveu null. O Dart le e registra no log de
  // diagnostico: sem isto, "nao abriu" nao dizia em que passo morreu — e
  // foi exatamente assim que a primeira versao desta ponte quebrou em
  // silencio na mao da usuaria.
  var ultimoMotivo = '';
  function anotar(motivo) { ultimoMotivo = motivo; }

  function carregarScript() {
    if (window.libheif) return Promise.resolve();
    if (!promessaDoScript) {
      promessaDoScript = new Promise(function (ok, falhou) {
        var tag = document.createElement('script');
        tag.src = CAMINHO_DO_SCRIPT;
        tag.async = true;
        tag.onload = function () { ok(); };
        tag.onerror = function () {
          // Sai da arvore: sem isto, cada tentativa deixaria uma tag morta.
          if (tag.parentNode) tag.parentNode.removeChild(tag);
          promessaDoScript = null;
          falhou(new Error('script'));
        };
        document.head.appendChild(tag);
      });
    }
    return promessaDoScript;
  }

  // Esta variante do libheif foi compilada para instanciar o wasm de forma
  // SINCRONA: ela nao busca o .wasm sozinha — espera os bytes prontos em
  // Module.wasmBinary, e sem eles lanca na hora ("sync fetching of the wasm
  // failed"). Foi o que aconteceu na primeira publicacao: null em 28 ms, sem
  // nenhum pedido de rede. Entao quem baixa o binario e' a ponte.
  function carregarWasm() {
    if (!promessaDoWasm) {
      promessaDoWasm = fetch(CAMINHO_DO_WASM).then(function (resposta) {
        if (!resposta.ok) throw new Error('wasm ' + resposta.status);
        return resposta.arrayBuffer();
      });
      promessaDoWasm.catch(function () { promessaDoWasm = null; });
    }
    return promessaDoWasm;
  }

  // A fabrica do emscripten devolve o modulo de forma SINCRONA, com o wasm
  // ainda compilando; quem avisa que ficou pronto e' onRuntimeInitialized. E
  // como o objeto de configuracao VIRA o modulo, da' para escutar sem
  // depender do retorno. Instanciado UMA vez: um modulo por foto vazaria um
  // heap de wasm inteiro a cada uma.
  function instanciar() {
    if (promessaDoModulo) return promessaDoModulo;
    promessaDoModulo = Promise.all([carregarScript(), carregarWasm()])
      .then(function (partes) {
        var wasmBinary = partes[1];
        var fabrica = window.libheif;
        if (!fabrica) throw new Error('script');
        if (typeof fabrica !== 'function') return fabrica;
        return new Promise(function (ok, falhou) {
          var config = { wasmBinary: wasmBinary };
          // Com o binario em maos a compilacao e' sincrona: o aviso dispara
          // DENTRO da chamada da fabrica. Por isso os ganchos vao antes.
          config.onRuntimeInitialized = function () { ok(config); };
          config.onAbort = function (motivo) {
            falhou(new Error('fabrica: ' + motivo));
          };
          var modulo;
          try {
            modulo = fabrica(config);
          } catch (e) {
            falhou(new Error('fabrica: ' + (e && e.message)));
            return;
          }
          if (modulo && modulo.calledRun) ok(modulo);
        });
      });
    promessaDoModulo.catch(function () { promessaDoModulo = null; });
    return promessaDoModulo;
  }

  function decodificar(bytes) {
    return instanciar().then(function (modulo) {
      var decodificador = new modulo.HeifDecoder();
      // decode() nunca lanca: devolve [] quando nao e' HEIC.
      var imagens = decodificador.decode(bytes) || [];
      var tela = null;

      // A tralha do libheif nao mora no heap do JavaScript, entao o coletor
      // de lixo nao a alcanca. Pior: o CONTEXTO guarda o arquivo inteiro
      // copiado para a memoria do wasm e so' seria solto se decode() rodasse
      // de novo no MESMO decodificador — o que nunca acontece aqui. Uma
      // funcao so' solta tudo, e ela roda em TODAS as saidas.
      function soltarTudo() {
        for (var i = 0; i < imagens.length; i++) {
          try { imagens[i].free(); } catch (e) { /* nada a fazer */ }
        }
        imagens = [];
        try {
          if (decodificador.decoder) {
            modulo.heif_context_free(decodificador.decoder);
            decodificador.decoder = null;
          }
        } catch (e) { /* nada a fazer */ }
        if (tela) {
          tela.width = 0;
          tela.height = 0;
          tela = null;
        }
      }

      return new Promise(function (ok) {
        var acabou = false;
        // O relogio e' a UNICA garantia de que isto termina: se o wasm
        // estourar por dentro, a excecao morre no setTimeout do display() e
        // a chamada de volta nunca vem. Sem ele, nada seria solto — nunca.
        var relogio = setTimeout(function () {
          anotar('tempo');
          terminar(null);
        }, LIMITE_MS);

        function terminar(valor) {
          if (acabou) return;
          acabou = true;
          clearTimeout(relogio);
          soltarTudo();
          ok(valor);
        }

        try {
          if (!imagens.length) { anotar('sem imagens'); terminar(null); return; }
          // A primeira nem sempre e' a foto: rajada e Live Photo trazem
          // auxiliares na mesma lista.
          var imagem = imagens[0];
          for (var i = 0; i < imagens.length; i++) {
            try {
              if (imagens[i].is_primary()) { imagem = imagens[i]; break; }
            } catch (e) { /* nada a fazer */ }
          }

          var largura = imagem.get_width();
          var altura = imagem.get_height();
          if (!largura || !altura) { anotar('tamanho'); terminar(null); return; }

          tela = document.createElement('canvas');
          tela.width = largura;
          tela.height = altura;
          var pincel = tela.getContext('2d');
          if (!pincel) { anotar('canvas'); terminar(null); return; }
          var pixels = pincel.createImageData(largura, altura);

          imagem.display(pixels, function (pronto) {
            if (acabou) return;
            if (!pronto) { anotar('display'); terminar(null); return; }
            try {
              // O ImageData ja' tem os pixels: virar ImageBitmap direto
              // dispensa desenhar na tela e ler de volta.
              createImageBitmap(pronto).then(
                function (bitmap) { terminar(bitmap); },
                function () { anotar('bitmap'); terminar(null); }
              );
            } catch (e) {
              anotar('bitmap');
              terminar(null);
            }
          });
        } catch (e) {
          anotar('decodificar: ' + (e && e.message));
          terminar(null);
        }
      });
    });
  }

  window.grimorioHeic = {
    paraBitmap: function (bytes) {
      ultimoMotivo = '';
      try {
        return decodificar(bytes).then(
          function (v) { return v; },
          function (e) {
            // Falha ANTES de decodificar: script, wasm ou fabrica.
            anotar((e && e.message) || 'carregar');
            return null;
          }
        );
      } catch (e) {
        anotar('inesperado');
        return Promise.resolve(null);
      }
    },
    get ultimoMotivo() { return ultimoMotivo; },
  };
})();
