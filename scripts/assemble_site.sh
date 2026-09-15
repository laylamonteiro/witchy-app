#!/usr/bin/env bash
# Monta o diretório de publicação: o app na raiz, as páginas estáticas ao lado.
#
#   /                 → aplicativo (Flutter Web)
#   /sw.js            → service worker do app, GERADO aqui a partir do build
#   /sobre/           → apresentação: o que é o app, o que faz, links legais
#   /privacidade/     → política de privacidade (pt), /en/ e /es/ ao lado
#   /termos/          → termos de uso (pt), /en/ e /es/ ao lado
#
# O sw.js é o que faz o app abrir sem rede: o Flutter 3.35 descontinuou o
# service worker dele e a 3.47 gera um stub que se desregistra. O nosso é
# escrito por scripts/gerar_service_worker.mjs (md5 de cada arquivo do build
# + a lógica de scripts/service_worker/logica.js) e exige dois flags no
# build, conferidos abaixo: --pwa-strategy=none e --no-web-resources-cdn.
#
# O endereço /baixar (o QR: Android → Play, iOS/resto → app web) NÃO é
# montado aqui. Ele é uma Cloudflare Pages Function e vive em `functions/` na
# raiz do repositório, de onde o `wrangler pages deploy` a compila sozinho —
# ver docs/QR_CODE.md.
#
# As páginas estáticas existem porque o app é desenhado em canvas: um
# rastreador (prévia de link, verificação de marca do Google) não lê nada
# dentro dele. Elas são HTML puro, sem JavaScript, e ficam no mesmo domínio.
#
# As duas legais deixaram de ser escritas à mão: elas são GERADAS de
# assets/legal/*.md, a mesma fonte que o app exibe. Enquanto eram HTML
# digitado, divergiram — a página prometia sincronização "apenas para quem é
# Premium" muito depois de o paywall ter saído do código, e nenhuma catraca
# alcançava o site porque o site não vinha do documento. Agora vem, nos três
# idiomas, e a frase desmentida derruba a montagem antes de virar página.
#
# Pré-requisito: `flutter build web --pwa-strategy=none --no-web-resources-cdn`
# já executado (base href na raiz).
# Uso: scripts/assemble_site.sh [diretorio_de_saida]   (padrão: public)

set -euo pipefail

RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
SAIDA="${1:-$RAIZ/public}"

if [ ! -f "$RAIZ/build/web/index.html" ]; then
  echo "ERRO: build/web não encontrado. Rode antes:" >&2
  echo "  flutter build web --release --no-wasm-dry-run --pwa-strategy=none --no-web-resources-cdn ..." >&2
  exit 1
fi

# O app é servido na raiz; um base href diferente deixaria a tela branca,
# porque o Flutter buscaria os próprios arquivos no caminho errado.
if ! grep -qE '<base href="/"' "$RAIZ/build/web/index.html"; then
  echo "ERRO: o build não está com base href na raiz." >&2
  echo "Rebuilde sem --base-href (ou com --base-href /)." >&2
  exit 1
fi

# Daqui para a frente, falhou = não sobra diretório.
#
# O PORQUÊ: as páginas legais são geradas por ÚLTIMO, depois de o app e de
# site/ já estarem copiados. Se o gerador parar — e ele para de propósito,
# diante de uma construção que não sabe converter ou de uma frase que o código
# já desmentiu —, o que fica em $SAIDA é um site inteiro MENOS /privacidade/ e
# /termos/, com o sitemap ainda anunciando as seis páginas. No CI isso não
# publica: o passo falha e o job morre antes do deploy. Mas a publicação à mão
# (`wrangler pages deploy public`) não tem como saber que a montagem parou no
# meio — ela vê um diretório pronto e sobe um site cuja política de
# privacidade dá 404. Apagar o diretório é a diferença entre "a montagem
# falhou" e "a montagem falhou e deixou uma armadilha do lado".
montagem_concluida=0
apagar_montagem_pela_metade() {
  if [ "$montagem_concluida" -eq 0 ] && [ -d "$SAIDA" ]; then
    rm -rf "$SAIDA"
    echo "ERRO: montagem interrompida — $SAIDA foi apagado, para ninguém publicar um site sem as páginas legais." >&2
  fi
}
trap apagar_montagem_pela_metade EXIT

rm -rf "$SAIDA"
mkdir -p "$SAIDA"

# O app primeiro: ele traz index.html, favicon e ícones para a raiz.
cp -R "$RAIZ/build/web/." "$SAIDA/"

# O service worker — duas catracas e um gerador.
#
# (a) O flutter_service_worker.js precisa existir e ter 0 bytes: é o que
# `--pwa-strategy=none` produz. Com conteúdo, o build veio SEM o flag, e o que
# há dentro é o stub da 3.47 — que, registrado, se desregistra e derruba as
# abas; e o flutter_bootstrap.js desse build ainda o registraria por cima do
# nosso. Melhor parar aqui do que publicar um site que se desliga do offline.
if [ ! -f "$RAIZ/build/web/flutter_service_worker.js" ]; then
  echo "ERRO: build/web/flutter_service_worker.js não existe — esse build não saiu do Flutter esperado." >&2
  exit 1
fi
if [ -s "$RAIZ/build/web/flutter_service_worker.js" ]; then
  echo "ERRO: build/web/flutter_service_worker.js tem conteúdo — o build veio sem --pwa-strategy=none." >&2
  echo "Com ele o Flutter escreve um arquivo vazio e deixa o campo livre para o nosso sw.js." >&2
  echo "Rebuilde com: flutter build web --release --no-wasm-dry-run --pwa-strategy=none --no-web-resources-cdn ..." >&2
  exit 1
fi
# (b) O CanvasKit tem de vir da própria origem: sem `--no-web-resources-cdn`
# o renderizador inteiro (~7 MB) é baixado de www.gstatic.com, e um recurso
# de outra origem não entra no cache do nosso service worker — o app abriria
# offline sem ter com que desenhar.
if ! grep -q '"useLocalCanvasKit":true' "$RAIZ/build/web/flutter_bootstrap.js"; then
  echo "ERRO: build/web/flutter_bootstrap.js não tem \"useLocalCanvasKit\":true — o build veio sem --no-web-resources-cdn." >&2
  echo "Sem ele o CanvasKit vem da CDN do Google e o app não abre offline." >&2
  echo "Rebuilde com: flutter build web --release --no-wasm-dry-run --pwa-strategy=none --no-web-resources-cdn ..." >&2
  exit 1
fi
# (c) O stub vazio não é publicado: ninguém deve encontrá-lo — nem um
# navegador com o registro antigo do Flutter.
rm -f "$SAIDA/flutter_service_worker.js"
# (d) O nosso, gerado do build (o gerador precisa de Node; conferido abaixo,
# junto com as legais, mas aqui o erro tem de ser o certo).
if ! command -v node >/dev/null 2>&1; then
  echo "ERRO: node não encontrado — o service worker é gerado por" >&2
  echo "scripts/gerar_service_worker.mjs e não há como montar o site sem ele." >&2
  echo "(O runner do CI já traz Node; localmente, instale-o.)" >&2
  exit 1
fi
node "$RAIZ/scripts/gerar_service_worker.mjs" "$RAIZ/build/web" "$SAIDA/sw.js"
# (e) Gravou mesmo: um sw.js ausente ou vazio registra sem erro nenhum e o
# app volta, em silêncio, a não ter cache.
if [ ! -s "$SAIDA/sw.js" ]; then
  echo "ERRO: $SAIDA/sw.js não foi gravado (ou está vazio)." >&2
  exit 1
fi

# Depois as páginas estáticas, que ocupam caminhos próprios e não colidem.
cp -R "$RAIZ/site/." "$SAIDA/"

# Por último as legais, geradas dos documentos. DEPOIS da cópia de propósito:
# se um dia alguém devolver um index.html escrito à mão a site/privacidade/,
# o gerado o substitui em vez de os dois brigarem pelo mesmo caminho.
if ! command -v node >/dev/null 2>&1; then
  echo "ERRO: node não encontrado — as páginas legais são geradas por" >&2
  echo "scripts/gerar_paginas_legais.mjs e não há como montar o site sem ele." >&2
  echo "(O runner do CI já traz Node; localmente, instale-o.)" >&2
  exit 1
fi
echo "Páginas legais geradas de assets/legal/*.md:"
node "$RAIZ/scripts/gerar_paginas_legais.mjs" "$SAIDA"

# O gerador confere o conteúdo antes de gravar; isto confere que gravou. São
# coisas diferentes: um erro de escrita (disco cheio, permissão) sairia daqui
# com o código certo e o arquivo ausente, e o sitemap continuaria prometendo
# seis endereços.
for rota in privacidade termos; do
  for idioma in "" en/ es/; do
    if [ ! -s "$SAIDA/$rota/${idioma}index.html" ]; then
      echo "ERRO: /$rota/$idioma não foi gravada. O sitemap anuncia as seis." >&2
      exit 1
    fi
  done
done

montagem_concluida=1
echo "Publicação montada em $SAIDA"
echo "  /       → aplicativo ($(du -sh "$SAIDA" | cut -f1) no total)"
echo "  /sw.js  → service worker (offline), gerado do build"
echo "  /sobre/ → apresentação, privacidade, termos (pt, en, es)"
