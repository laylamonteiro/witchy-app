#!/usr/bin/env bash
# Verifica strings em português hardcoded fora da camada de i18n.
#
# Uso: scripts/check_hardcoded_pt.sh [--all]
#   --all  mostra todas as ocorrências (por padrão mostra as 200 primeiras)
#
# O scanner procura caracteres acentuados do português em lib/, excluindo:
#   - lib/l10n/ (ARBs e código gerado);
#   - arquivos de conteúdo por locale (*_pt.dart, *_en.dart, *_es.dart),
#     cuja paridade é garantida por test/content_parity_test.dart;
#   - linhas de comentário (// e ///);
#   - padrões da allowlist (nomes próprios etc.) em scripts/i18n_allowlist.txt.
#
# Sai com código != 0 se encontrar ocorrências — é a prova de completude
# usada no gate de validação da internacionalização (F4).
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ALLOWLIST="$ROOT/scripts/i18n_allowlist.txt"
LIMIT=200
[ "${1:-}" = "--all" ] && LIMIT=0

PATTERN='[ãõáéíóúâêôçÃÕÁÉÍÓÚÂÊÔÇ]'

matches=$(rg -n "$PATTERN" "$ROOT/lib" \
  --glob '!lib/l10n/**' \
  --glob '!**/*_pt.dart' \
  --glob '!**/*_en.dart' \
  --glob '!**/*_es.dart' \
  | python3 -c "
import linecache, re, sys
accent = re.compile(r'$PATTERN')
logcall = re.compile(r'(await\s+)?(print|debugPrint|debugLog|_log|_addLog)\s*\(')

def in_log_continuation(path, lineno):
    # Continuação multilinha de chamada de log: procura, até 5 linhas acima,
    # uma abertura de log ainda não fechada até a linha anterior à atual.
    for start in range(lineno - 1, max(lineno - 6, 0), -1):
        opening = linecache.getline(path, start)
        if not logcall.match(opening.lstrip()):
            continue
        span = ''.join(
            linecache.getline(path, n) for n in range(start, lineno))
        return span.count('(') > span.count(')')
    return False

for line in sys.stdin:
    line = line.rstrip('\n')
    path, lineno, code = line.split(':', 2)
    stripped = code.lstrip()
    # Linha inteira de comentário.
    if stripped.startswith('//'):
        continue
    # Exceções internas de programação (guards) não são UI.
    if re.match(r'throw\s+(ArgumentError|StateError|UnsupportedError)\(', stripped):
        continue
    # Chamadas de log/debug não são texto visível ao usuário.
    if logcall.match(stripped):
        continue
    if in_log_continuation(path, int(lineno)):
        continue
    # Argumentos nomeados por locale de ContentLocale.select(pt:/es:) —
    # conteúdo já localizado inline; o EN fica ao lado sem acentos.
    if re.match(r\"(pt|pt_BR|es)\s*:\s*['\\\"]\", stripped):
        continue
    # Comentário no fim da linha: só conta se houver acento ANTES do '//'
    # (fora de string, aproximado ignorando '//' precedido por ':', ex. URLs).
    m = re.search(r'(?<!:)//', code)
    if m and not accent.search(code[:m.start()]):
        continue
    print(line)
" || true)

if [ -s "$ALLOWLIST" ]; then
  # Remove linhas em branco e comentários da allowlist antes de aplicar.
  filtered_allow=$(grep -vE '^\s*(#|$)' "$ALLOWLIST" || true)
  if [ -n "$filtered_allow" ]; then
    matches=$(printf '%s\n' "$matches" | grep -vEf <(printf '%s\n' "$filtered_allow") || true)
  fi
fi

matches=$(printf '%s\n' "$matches" | sed '/^$/d')

if [ -z "$matches" ]; then
  echo "OK: nenhuma string hardcoded em português encontrada fora da camada de i18n."
  exit 0
fi

count=$(printf '%s\n' "$matches" | wc -l)
echo "ERRO: $count linha(s) com possível texto em português fora da camada de i18n:"
echo
if [ "$LIMIT" -gt 0 ]; then
  printf '%s\n' "$matches" | head -n "$LIMIT"
  [ "$count" -gt "$LIMIT" ] && echo "... (+$((count - LIMIT)) linhas; use --all para ver todas)"
else
  printf '%s\n' "$matches"
fi
exit 1
