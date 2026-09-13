#!/usr/bin/env bash
#
# Deploy do Grimório de Bolso (site inteiro) para S3 + CloudFront.
#
# Sobe a montagem de scripts/assemble_site.sh — o aplicativo na raiz e as oito
# páginas estáticas ao lado (/sobre/, /privacidade/ e /termos/ em pt, en e es),
# com as legais geradas de assets/legal/*.md.
#
# Pré-requisitos:
#   - AWS CLI configurado (`aws configure`) com permissão de escrita no bucket
#     e de criar invalidação na distribuição CloudFront.
#   - Flutter no PATH.
#   - Node no PATH (as páginas legais são geradas por
#     scripts/gerar_paginas_legais.mjs; assemble_site.sh para sem ele).
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

# O que sobe é a MONTAGEM, não o build cru.
#
# O PORQUÊ: até aqui este script sincronizava build/web/ direto, e build/web/ é
# só o aplicativo. Faltavam nele /privacidade/, /termos/ (nos três idiomas),
# /sobre/, sitemap.xml, robots.txt e _headers — e o --delete logo abaixo ainda
# apagava do bucket as que lá estivessem de uma publicação anterior. Quem
# rodasse este script publicava um site cuja política de privacidade dá 404,
# que é exatamente o acidente que assemble_site.sh foi escrito para impedir:
# ele monta as oito páginas, gera as legais de assets/legal/*.md e PARA se o
# documento não converter ou se trouxer de volta uma frase que o código já
# desmentiu. Publicar por fora dele era manter a catraca com a porta ao lado
# aberta. Agora há uma montagem só, e as duas saídas (Cloudflare Pages no CI,
# S3 aqui) sobem o mesmo diretório.
echo "==> Montagem do site (app + paginas estaticas + legais)"
bash scripts/assemble_site.sh public

# 1) Assets com hash no nome: cache longo e imutavel.
#    Exclui os .html, os arquivos de entrada e os arquivos de raiz (cache
#    curto, abaixo) e todos os .wasm (precisam de content-type explícito, mais
#    abaixo). O *.html cobre de uma vez o index do app e as oito páginas
#    estáticas: nenhuma delas pode ficar presa um ano no cache, porque a
#    política de privacidade muda.
echo "==> Sync de assets (cache longo)"
aws s3 sync public/ "s3://$S3_BUCKET/" --delete \
  --cache-control "public,max-age=31536000,immutable" \
  --exclude "*.html" \
  --exclude "flutter_service_worker.js" \
  --exclude "flutter_bootstrap.js" \
  --exclude "sitemap.xml" \
  --exclude "robots.txt" \
  --exclude "_headers" \
  --exclude "*.wasm"

# 2) Todos os .wasm (sqlite3, canvaskit, skwasm) precisam de
#    Content-Type: application/wasm — senao o WebAssembly.instantiate falha.
echo "==> .wasm com content-type application/wasm"
find public -name "*.wasm" -type f | while read -r wasmfile; do
  key="${wasmfile#public/}"
  aws s3 cp "$wasmfile" "s3://$S3_BUCKET/$key" \
    --content-type "application/wasm" \
    --cache-control "public,max-age=31536000,immutable"
done

# 3) Páginas e arquivos de entrada: sem cache, senão usuárias ficam presas em
#    versão velha — e, no caso das legais, num documento que já mudou.
echo "==> Paginas HTML e arquivos de entrada (sem cache)"
find public -name "*.html" -type f | while read -r pagina; do
  key="${pagina#public/}"
  aws s3 cp "$pagina" "s3://$S3_BUCKET/$key" --cache-control "no-cache,max-age=0"
done
for f in flutter_service_worker.js flutter_bootstrap.js sitemap.xml robots.txt _headers; do
  if [ -f "public/$f" ]; then
    aws s3 cp "public/$f" "s3://$S3_BUCKET/$f" \
      --cache-control "no-cache,max-age=0"
  fi
done

# 4) Invalida o cache do CloudFront para publicar imediatamente.
echo "==> Invalidacao CloudFront"
aws cloudfront create-invalidation --distribution-id "$CF_DIST_ID" --paths "/*" >/dev/null

echo "==> Pronto. https://grimoriodebolso.app"
