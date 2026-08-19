#!/usr/bin/env bash
# Monta o diretório de publicação: site estático na raiz, app em /app/.
#
# A verificação de marca do Google busca a página inicial do domínio. Com o
# app em Flutter na raiz, ela encontrava uma tela desenhada em canvas, sem
# texto legível — daí as recusas por "não explica o propósito" e "o nome não
# confere". Agora a raiz é HTML estático, público e sem JavaScript, e o app
# vive em /app/.
#
# Pré-requisito: `flutter build web ... --base-href /app/` já executado.
# Uso: scripts/assemble_site.sh [diretorio_de_saida]   (padrão: public)

set -euo pipefail

RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
SAIDA="${1:-$RAIZ/public}"

if [ ! -f "$RAIZ/build/web/index.html" ]; then
  echo "ERRO: build/web não encontrado. Rode antes:" >&2
  echo "  flutter build web --release --no-wasm-dry-run --base-href /app/ ..." >&2
  exit 1
fi

# O --base-href precisa bater com o caminho onde o app é servido; sem isso o
# app carrega no endereço errado e fica em tela branca.
if ! grep -q '<base href="/app/">' "$RAIZ/build/web/index.html"; then
  echo "ERRO: o build não usou --base-href /app/." >&2
  echo "Rebuilde com --base-href /app/ antes de montar." >&2
  exit 1
fi

rm -rf "$SAIDA"
mkdir -p "$SAIDA"

cp -R "$RAIZ/site/." "$SAIDA/"
mkdir -p "$SAIDA/app"
cp -R "$RAIZ/build/web/." "$SAIDA/app/"

echo "Publicação montada em $SAIDA"
echo "  raiz  → apresentação, privacidade, termos ($(find "$SAIDA" -maxdepth 1 -name '*.html' | wc -l) página(s) na raiz)"
echo "  /app/ → aplicativo ($(du -sh "$SAIDA/app" | cut -f1))"
