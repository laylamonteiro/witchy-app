// O service worker do app web, gerado a partir do build.
//
// O PORQUÊ: o Flutter 3.35 descontinuou o service worker que ele mesmo
// gerava, e o 3.47 escreve um flutter_service_worker.js que é um STUB — no
// `activate` ele se desregistra e recarrega as abas. Resultado: o app web não
// tinha service worker nenhum, nada ficava em cache, e sem rede o navegador
// mostrava a própria página de erro — para uma pessoa logada, com todos os
// dados no SQLite local, e que no iPhone não tem outro caminho para o app.
//
// Este gerador faz o que o Flutter deixou de fazer: lê build/web, calcula o
// md5 de cada arquivo, escolhe o NÚCLEO (a casca que se baixa de uma vez) e
// grava um sw.js = cabeçalho com as constantes desta publicação + a lógica
// fixa de scripts/service_worker/logica.js. Um arquivo só, porque o
// navegador reinstala o SW quando os BYTES do script mudam — e o manifesto
// embutido garante que eles mudem a cada build diferente.
//
// Pré-requisitos do build (assemble_site.sh confere os dois):
//   --pwa-strategy=none     → o stub do Flutter sai vazio e o
//                             flutter_bootstrap.js não toca em service worker.
//   --no-web-resources-cdn  → o CanvasKit é servido da própria origem; da CDN
//                             (www.gstatic.com) ele não entraria neste cache.
//
// Uso: node scripts/gerar_service_worker.mjs <dir do build/web> <arquivo de saída sw.js>
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import url from 'node:url';
import vm from 'node:vm';

const RAIZ = path.dirname(path.dirname(url.fileURLToPath(import.meta.url)));
const LOGICA = path.join(RAIZ, 'scripts', 'service_worker', 'logica.js');

/// Os prefixos de caminho que NÃO são o app: as páginas estáticas de site/ e
/// das legais geradas, e a Pages Function do QR. Uma navegação para eles não
/// recebe a casca do app — nem online (seria a página errada) nem offline
/// (o navegador mostra o erro dele, que é a verdade: essas páginas só existem
/// com rede). test/service_worker_test.mjs confere esta lista contra o
/// repositório, para uma pasta nova em site/ derrubar o teste em vez de virar
/// uma página que o SW engole.
export const ROTAS_ESTATICAS = ['/sobre', '/privacidade', '/termos', '/baixar'];

/// O que fica de fora do manifesto: o stub do Flutter (0 bytes com o flag
/// certo; com conteúdo, a montagem já parou antes), o próprio sw.js, os
/// mapas e símbolos de depuração (só o DevTools os pede) e lixo de sistema.
const NOMES_EXCLUIDOS = new Set(['flutter_service_worker.js', 'sw.js', '.last_build_id', '.DS_Store']);
const EXTENSOES_EXCLUIDAS = ['.map', '.symbols'];

/// O NÚCLEO: o que o `install` baixa de uma vez, antes de a versão valer.
///
/// É a casca mínima para o app subir: o índice, os carregadores, o código
/// compilado, o SQLite em wasm (os dados vivem nele), os manifestos de assets
/// e fontes, os ícones. Fica de FORA o CanvasKit — são três variantes de ~7
/// MB e o navegador só usa uma; ele entra no cache quando a página o pede
/// (ou pelo aquecimento do index.html) — e ficam de fora as imagens de
/// conteúdo, que entram conforme a pessoa as vê.
export const NUCLEO = {
  exatos: [
    'index.html',
    'flutter_bootstrap.js',
    'flutter.js',
    'main.dart.js',
    'main.dart.mjs',
    'main.dart.wasm',
    'manifest.json',
    'favicon.png',
    'version.json',
    'sqlite3.wasm',
    'sqflite_sw.js',
    'assets/FontManifest.json',
  ],
  prefixos: [
    'icons/',
    'assets/AssetManifest',
    'assets/fonts/',
    'assets/packages/cupertino_icons/',
    'assets/shaders/',
  ],
  inclui(caminho) {
    return (
      this.exatos.includes(caminho) || this.prefixos.some((prefixo) => caminho.startsWith(prefixo))
    );
  },
};

function md5(conteudo) {
  return crypto.createHash('md5').update(conteudo).digest('hex');
}

/// Todos os arquivos do build, como caminhos relativos POSIX, ordenados —
/// menos os excluídos. Ordenado porque a ordem entra no JSON, e o JSON entra
/// na versão: dois builds iguais têm de dar o mesmo sw.js byte a byte.
export function listarArquivos(dirBuild) {
  const arquivos = [];
  const percorrer = (dir) => {
    for (const entrada of fs.readdirSync(dir, { withFileTypes: true })) {
      const caminho = path.join(dir, entrada.name);
      if (entrada.isDirectory()) {
        percorrer(caminho);
        continue;
      }
      if (!entrada.isFile()) continue;
      if (NOMES_EXCLUIDOS.has(entrada.name)) continue;
      if (EXTENSOES_EXCLUIDAS.some((ext) => entrada.name.endsWith(ext))) continue;
      arquivos.push(path.relative(dirBuild, caminho).split(path.sep).join('/'));
    }
  };
  percorrer(dirBuild);
  return arquivos.sort();
}

/// O manifesto desta publicação: md5 por arquivo, o núcleo (só o que existe
/// no build) e a versão — md5 do JSON estável de `recursos`. A versão muda se
/// QUALQUER arquivo mudar, e só então: é ela que nomeia o cache e que faz o
/// navegador enxergar um sw.js novo.
export function calcularManifesto(dirBuild) {
  const recursos = {};
  for (const caminho of listarArquivos(dirBuild)) {
    recursos[caminho] = md5(fs.readFileSync(path.join(dirBuild, caminho)));
  }
  const nucleo = Object.keys(recursos).filter((caminho) => NUCLEO.inclui(caminho));
  const versao = md5(JSON.stringify(recursos));
  return { recursos, nucleo, versao };
}

/// O sw.js inteiro: cabeçalho com as constantes + a lógica lida do disco.
export function gerarServiceWorker(manifesto) {
  const cabecalho = [
    '// GERADO por scripts/gerar_service_worker.mjs a partir do build — não edite.',
    '// A lógica vive em scripts/service_worker/logica.js; as constantes abaixo',
    '// são desta publicação e mudam a cada build diferente.',
    `const VERSAO = ${JSON.stringify(manifesto.versao)};`,
    `const RECURSOS = ${JSON.stringify(manifesto.recursos)};`,
    `const NUCLEO = ${JSON.stringify(manifesto.nucleo)};`,
    `const ROTAS_ESTATICAS = ${JSON.stringify(ROTAS_ESTATICAS)};`,
    '',
  ].join('\n');
  return cabecalho + fs.readFileSync(LOGICA, 'utf8');
}

// Execução direta: gera o sw.js dentro do diretório de publicação.
if (process.argv[1] && path.resolve(process.argv[1]) === url.fileURLToPath(import.meta.url)) {
  const [dirBuild, saida] = process.argv.slice(2);
  if (!dirBuild || !saida) {
    console.error('Uso: node scripts/gerar_service_worker.mjs <dir do build/web> <arquivo de saída sw.js>');
    process.exit(2);
  }
  if (!fs.existsSync(path.join(dirBuild, 'index.html'))) {
    console.error(`ERRO: ${dirBuild}/index.html não existe — isso não é um build web do Flutter.`);
    console.error('Rode `flutter build web --release --pwa-strategy=none --no-web-resources-cdn …` antes.');
    process.exit(1);
  }

  const manifesto = calcularManifesto(dirBuild);
  const codigo = gerarServiceWorker(manifesto);

  // Um sw.js com erro de sintaxe não derruba nada visível: o navegador
  // recusa o registro em silêncio e o app volta a não ter cache. Compilar
  // aqui é o que transforma isso em publicação que PARA.
  try {
    new vm.Script(codigo, { filename: 'sw.js' });
  } catch (e) {
    console.error('ERRO: o sw.js gerado não compila — o navegador recusaria o registro:');
    console.error(`  ${e.message}`);
    process.exit(1);
  }

  try {
    fs.mkdirSync(path.dirname(saida), { recursive: true });
    fs.writeFileSync(saida, codigo, 'utf8');
  } catch (e) {
    console.error(`ERRO: não foi possível gravar ${saida}:`);
    console.error(`  ${e.message}`);
    process.exit(1);
  }
  const tamanhoKb = (Buffer.byteLength(codigo, 'utf8') / 1024).toFixed(1);
  console.log(
    `Service worker gerado em ${saida}: ${Object.keys(manifesto.recursos).length} recursos, ` +
      `${manifesto.nucleo.length} no núcleo, ${tamanhoKb} KB (versão ${manifesto.versao.slice(0, 12)}).`
  );
}
