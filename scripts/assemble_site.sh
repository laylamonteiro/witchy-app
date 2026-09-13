#!/usr/bin/env bash
# Monta o diretório de publicação: o app na raiz, as páginas estáticas ao lado.
#
#   /                 → aplicativo (Flutter Web)
#   /sobre/           → apresentação: o que é o app, o que faz, links legais
#   /privacidade/     → política de privacidade (pt), /en/ e /es/ ao lado
#   /termos/          → termos de uso (pt), /en/ e /es/ ao lado
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

echo "Publicação montada em $SAIDA"
echo "  /       → aplicativo ($(du -sh "$SAIDA" | cut -f1) no total)"
echo "  /sobre/ → apresentação, privacidade, termos (pt, en, es)"
