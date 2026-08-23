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

# O scanner depende do ripgrep. Sem esta checagem, um ambiente sem `rg`
# produzia busca VAZIA e o script concluía "OK" — o gate passava sem ter
# verificado nada, que é pior do que não existir.
if ! command -v rg >/dev/null 2>&1; then
  echo "ERRO: ripgrep (rg) não encontrado — o scanner não tem como rodar." >&2
  echo "Instale (apt-get install ripgrep / brew install ripgrep) e repita." >&2
  exit 2
fi

PATTERN='[ãõáéíóúâêôçÃÕÁÉÍÓÚÂÊÔÇ]'

# Segunda rede: português SEM acento.
#
# O scanner detectava português pela acentuação, e por isso deixou passar
# "Compra cancelada", "Nenhuma compra encontrada para restaurar", "Erro ao
# fazer login" e quinze irmãs — todas chegando à tela em inglês e espanhol.
# Uma delas ainda era comparada como string literal em duas telas, então
# traduzi-la faria o app acusar erro num cancelamento normal.
#
# A regra é conservadora de propósito: só olha DENTRO de literais de string,
# e só acusa com DUAS palavras distintas da lista. Palavra solta não basta —
# "para" aparece em identificador, "dia" em nome de variável. As palavras
# foram escolhidas por não colidirem com inglês nem com fragmento de domínio
# (por isso "com" não está aqui).
PALAVRAS='nenhum|nenhuma|nenhuns|nenhumas|cancelada|cancelado|canceladas|cancelados|encontrada|encontrado|encontradas|encontrados|restaurar|novamente|tentar|tente|seu|sua|seus|suas|voce|seja|esta|este|isso|aqui|agora|hoje|ontem|amanha|sem|para|pelo|pela|pelos|pelas|dos|das|uma|umas|foi|eram|sao|salvar|apagar|excluir|enviar|entrar|sair|falha|falhou|erro|erros|conta|contas|senha|senhas|compra|compras|leitura|leituras|dia|dias|mes|meses|ainda|depois|antes|quando|porque|mas|nao|sim|tudo|nada|algo|alguns'

matches=$(rg -n "$PATTERN|(?i:\\b($PALAVRAS)\\b)" "$ROOT/lib" \
  --glob '!lib/l10n/**' \
  --glob '!**/*_pt.dart' \
  --glob '!**/*_en.dart' \
  --glob '!**/*_es.dart' \
  | python3 -c "
import linecache, re, sys
accent = re.compile(r'$PATTERN')
logcall = re.compile(r'(unawaited\s*\(\s*)?(await\s+)?(print|debugPrint|debugLog|_log|_addLog)\s*\(')
assertopen = re.compile(r'.*\bassert\s*\(')

ASPA = chr(39)
ASPAS = chr(34)
palavra = re.compile(r'\b($PALAVRAS)\b', re.IGNORECASE)


def sem_comentario(code):
    # Tira o comentário de fim de linha quando ele está fora de string
    # (contagem par de aspas antes dele).
    m = re.search(r'(?<!:)//', code)
    if m is None:
        return code
    antes = code[:m.start()]
    if antes.count(ASPA) % 2 == 0 and antes.count(ASPAS) % 2 == 0:
        return antes
    return code


def literais(code):
    # Aproximação: pedaços entre aspas simples e entre aspas duplas. Não
    # entende escape, e não precisa — o que interessa é a frase lá dentro.
    trecho = sem_comentario(code)
    for aspa in (ASPA, ASPAS):
        for m in re.finditer(aspa + '([^' + aspa + ']*)' + aspa, trecho):
            yield m.group(1)


def maior_contagem(code):
    # Quantas palavras DISTINTAS da lista cabem no literal mais suspeito.
    maior = 0
    for texto in literais(code):
        if not texto or ' ' not in texto:
            continue
        maior = max(maior, len({w.lower() for w in palavra.findall(texto)}))
    return maior


def in_log_continuation(path, lineno):
    # Continuação multilinha de chamada de log/assert: procura, até 5 linhas
    # acima, uma abertura ainda não fechada até a linha anterior à atual.
    # O balanço de parênteses é contado a partir da PRÓPRIA chamada, para não
    # ser confundido por fechamentos anteriores na mesma linha (ex. '}) :').
    for start in range(lineno - 1, max(lineno - 6, 0), -1):
        opening = linecache.getline(path, start)
        stripped_open = opening.lstrip()
        m = logcall.match(stripped_open)
        offset = None
        if m:
            offset = len(opening) - len(stripped_open)
        else:
            am = re.search(r'\bassert\s*\(', opening)
            if am:
                offset = am.start()
        if offset is None:
            continue
        span = opening[offset:] + ''.join(
            linecache.getline(path, n) for n in range(start + 1, lineno))
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
    if accent.search(code):
        # Comentário no fim da linha: só conta se houver acento ANTES do '//'
        # (fora de string, aproximado ignorando '//' precedido por ':', ex. URLs).
        m = re.search(r'(?<!:)//', code)
        if m and not accent.search(code[:m.start()]):
            continue
        print(line)
        continue
    # Sem acento: só acusa DENTRO de literal de string, e só com DUAS
    # palavras distintas da lista. Palavra solta não basta — 'para' aparece
    # em identificador, 'dia' em nome de variável.
    if maior_contagem(code) >= 2:
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
