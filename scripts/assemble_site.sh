#!/usr/bin/env bash
# Monta o diretório de publicação: o app na raiz, as páginas estáticas ao lado.
#
#   /             → aplicativo (Flutter Web)
#   /sobre/       → apresentação: o que é o app, o que faz, links legais
#   /privacidade/ → política de privacidade
#   /termos/      → termos de uso
#
# As páginas estáticas existem porque o app é desenhado em canvas: um
# rastreador (prévia de link, verificação de marca do Google) não lê nada
# dentro dele. Elas são HTML puro, sem JavaScript, e ficam no mesmo domínio.
#
# Pré-requisito: `flutter build web` já executado (base href na raiz).
# Uso: scripts/assemble_site.sh [diretorio_de_saida]   (padrão: public)

set -euo pipefail

RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
SAIDA="${1:-$RAIZ/public}"

if [ ! -f "$RAIZ/build/web/index.html" ]; then
  echo "ERRO: build/web não encontrado. Rode antes:" >&2
  echo "  flutter build web --release --no-wasm-dry-run ..." >&2
  exit 1
fi

# O app é servido na raiz; um base href diferente deixaria a tela branca,
# porque o Flutter buscaria os próprios arquivos no caminho errado.
if ! grep -qE '<base href="/"' "$RAIZ/build/web/index.html"; then
  echo "ERRO: o build não está com base href na raiz." >&2
  echo "Rebuilde sem --base-href (ou com --base-href /)." >&2
  exit 1
fi

rm -rf "$SAIDA"
mkdir -p "$SAIDA"

# O app primeiro: ele traz index.html, favicon e ícones para a raiz.
cp -R "$RAIZ/build/web/." "$SAIDA/"
# Depois as páginas estáticas, que ocupam caminhos próprios e não colidem.
cp -R "$RAIZ/site/." "$SAIDA/"

echo "Publicação montada em $SAIDA"
echo "  /       → aplicativo ($(du -sh "$SAIDA" | cut -f1) no total)"
echo "  /sobre/ → apresentação, privacidade, termos"
