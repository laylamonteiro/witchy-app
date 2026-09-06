#!/usr/bin/env bash
# Rotação das chaves de IA (Groq/Gemini).
#
# Depois que web E Android passam pela Edge Function `ia`, a chave mora SÓ
# nos secrets do Supabase. Rotacionar virou três passos, sem rebuild, sem
# release e sem impacto em quem já instalou o app:
#   1. criar a chave nova no painel do provedor;
#   2. rodar este script (troca o secret; a função usa a nova na próxima chamada);
#   3. revogar a chave antiga no provedor — depois de ver a IA responder.
#
# Uso (pode passar só uma das duas; a outra fica como está):
#   GROQ_API_KEY=gsk_... GEMINI_API_KEY=AIza... scripts/rotacionar_chaves_ia.sh
# Exige a CLI do Supabase autenticada (`supabase login`).
# Nunca imprime as chaves.
set -euo pipefail

REF="${SUPABASE_PROJECT_REF:-zadqmtamrkbvdpmqtexb}"
args=()

if [ -n "${GROQ_API_KEY:-}" ]; then
  [[ "$GROQ_API_KEY" == gsk_* ]] || { echo "GROQ_API_KEY não parece uma chave da Groq (esperado gsk_...)." >&2; exit 1; }
  args+=("GROQ_API_KEY=$GROQ_API_KEY")
fi
if [ -n "${GEMINI_API_KEY:-}" ]; then
  [[ "$GEMINI_API_KEY" == AIza* ]] || { echo "GEMINI_API_KEY não parece uma chave do Google AI (esperado AIza...)." >&2; exit 1; }
  args+=("GEMINI_API_KEY=$GEMINI_API_KEY")
fi
[ "${#args[@]}" -gt 0 ] || { echo "Passe GROQ_API_KEY e/ou GEMINI_API_KEY no ambiente." >&2; exit 1; }
command -v supabase >/dev/null || { echo "CLI do Supabase não encontrada (npm i -g supabase)." >&2; exit 1; }

supabase secrets set --project-ref "$REF" "${args[@]}"

echo
echo "Secrets atualizados no projeto $REF. A função ia usa a chave nova na próxima chamada."
echo "Agora REVOGUE a chave antiga no painel do provedor — só depois de ver a IA responder."
