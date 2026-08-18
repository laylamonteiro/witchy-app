#!/usr/bin/env bash
#
# Deploy do Grimório de Bolso (Flutter Web) para S3 + CloudFront.
#
# Pré-requisitos:
#   - AWS CLI configurado (`aws configure`) com permissão de escrita no bucket
#     e de criar invalidação na distribuição CloudFront.
#   - Flutter no PATH.
#   - Um arquivo de env de PRODUÇÃO (padrão: .env.prod) no formato CHAVE=VALOR,
#     SEM ADMIN_EMAIL/ADMIN_PASSWORD (senão vira backdoor de admin público).
#
# Uso:
#   S3_BUCKET=grimoriodebolso-app CF_DIST_ID=E123ABC456 ./scripts/deploy_web.sh
#
# Variáveis:
#   S3_BUCKET   (obrigatória) nome do bucket S3.
#   CF_DIST_ID  (obrigatória) id da distribuição CloudFront.
#   ENV_FILE    (opcional) arquivo de env de produção; padrão .env.prod.

set -euo pipefail

: "${S3_BUCKET:?defina S3_BUCKET (ex.: grimoriodebolso-app)}"
: "${CF_DIST_ID:?defina CF_DIST_ID (id da distribuicao CloudFront)}"
ENV_FILE="${ENV_FILE:-.env.prod}"

cd "$(git rev-parse --show-toplevel)"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERRO: arquivo de env '$ENV_FILE' nao encontrado." >&2
  exit 1
fi

if grep -qE '^\s*ADMIN_(EMAIL|PASSWORD)=' "$ENV_FILE"; then
  echo "ERRO: '$ENV_FILE' contem ADMIN_EMAIL/ADMIN_PASSWORD." >&2
  echo "Isso embutiria um admin no bundle publico. Remova antes de subir." >&2
  exit 1
fi

echo "==> Build web (release)"
flutter build web --release --no-wasm-dry-run --dart-define-from-file="$ENV_FILE"

# 1) Assets com hash no nome: cache longo e imutavel.
#    Exclui os arquivos de entrada (cache curto, abaixo) e todos os .wasm
#    (precisam de content-type explicito, mais abaixo).
echo "==> Sync de assets (cache longo)"
aws s3 sync build/web/ "s3://$S3_BUCKET/" --delete \
  --cache-control "public,max-age=31536000,immutable" \
  --exclude "index.html" \
  --exclude "flutter_service_worker.js" \
  --exclude "flutter_bootstrap.js" \
  --exclude "*.wasm"

# 2) Todos os .wasm (sqlite3, canvaskit, skwasm) precisam de
#    Content-Type: application/wasm — senao o WebAssembly.instantiate falha.
echo "==> .wasm com content-type application/wasm"
find build/web -name "*.wasm" -type f | while read -r wasmfile; do
  key="${wasmfile#build/web/}"
  aws s3 cp "$wasmfile" "s3://$S3_BUCKET/$key" \
    --content-type "application/wasm" \
    --cache-control "public,max-age=31536000,immutable"
done

# 3) Arquivos de entrada: sem cache, senao usuarias ficam presas em versao velha.
echo "==> Arquivos de entrada (sem cache)"
for f in index.html flutter_service_worker.js flutter_bootstrap.js; do
  if [ -f "build/web/$f" ]; then
    aws s3 cp "build/web/$f" "s3://$S3_BUCKET/$f" \
      --cache-control "no-cache,max-age=0"
  fi
done

# 4) Invalida o cache do CloudFront para publicar imediatamente.
echo "==> Invalidacao CloudFront"
aws cloudfront create-invalidation --distribution-id "$CF_DIST_ID" --paths "/*" >/dev/null

echo "==> Pronto. https://grimoriodebolso.app"
