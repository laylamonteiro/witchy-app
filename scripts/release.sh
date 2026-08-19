#!/usr/bin/env bash
# Publica uma versão: cria e envia a tag vX.Y.Z, que dispara o workflow
# release.yml (gate bloqueante → builds assinados → aprovação humana no
# environment `producao` → site + Play interna + GitHub Release).
#
# Uso:  bash scripts/release.sh 2.1.0
#
# Nada além da tag: sem commit de bot, sem bump de pubspec. A tag é a fonte
# de verdade da versão (versionName = X.Y.Z; versionCode = derivado dela no
# workflow). O pubspec.yaml é informativo — atualize-o quando quiser, mas o
# release não depende dele.
set -euo pipefail

VERSAO="${1:-}"
if [ -z "$VERSAO" ]; then
  echo "Uso: bash scripts/release.sh X.Y.Z   (ex.: 2.1.0)" >&2
  exit 1
fi
VERSAO="${VERSAO#v}"

if ! echo "$VERSAO" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "❌ Versão inválida: '$VERSAO'. Use X.Y.Z (ex.: 2.1.0)." >&2
  exit 1
fi

# Working tree limpa: uma tag deve apontar para um commit reproduzível.
if [ -n "$(git status --porcelain)" ]; then
  echo "❌ Working tree suja — commite ou descarte as mudanças antes de publicar." >&2
  exit 1
fi

# A tag nasce do que está no REMOTO, não do estado local.
git fetch --tags --quiet origin

BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" != "main" ]; then
  echo "❌ Publique a partir da main (você está em '$BRANCH')." >&2
  exit 1
fi
if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ]; then
  echo "❌ Sua main local difere da origin/main — sincronize antes (git pull)." >&2
  exit 1
fi

# Maior que toda tag existente (legadas vX.Y.Z+N contam pelo nome).
MAIOR=$(git tag -l 'v*' | sed -e 's/^v//' -e 's/+.*//' | sort -V | tail -1)
if [ -n "$MAIOR" ]; then
  TOPO=$(printf '%s\n%s\n' "$MAIOR" "$VERSAO" | sort -V | tail -1)
  if [ "$TOPO" != "$VERSAO" ] || [ "$MAIOR" = "$VERSAO" ]; then
    echo "❌ $VERSAO não é maior que a última versão publicada ($MAIOR)." >&2
    exit 1
  fi
fi

git tag "v$VERSAO"
git push origin "v$VERSAO"

echo
echo "✅ Tag v$VERSAO enviada. O workflow 'Release' está rodando:"
echo "   https://github.com/$(git remote get-url origin | sed -E 's#.*github.com[:/]##; s#\.git$##')/actions/workflows/release.yml"
echo
echo "Depois dos builds, aprove a publicação no environment 'producao'."
echo "Nada chega a usuários antes desse clique."
