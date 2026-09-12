#!/bin/bash
# Põe o Flutter de pé nas sessões do Claude Code na web.
#
# Sem ele, o agente não roda `flutter analyze` nem `flutter test` e precisa
# fazer o papel do compilador lendo o código — o que já custou três CIs
# vermelhos por coisas que o analisador acusaria em segundos.
#
# O script é deliberadamente TOLERANTE A FALHA: se a política de rede do
# ambiente não liberar os hosts do Flutter, ele avisa e sai com 0. Um hook
# que falha derruba a abertura de TODA sessão, e ficar sem SDK é ruim; ficar
# sem sessão é pior.
set -uo pipefail

# A mesma versão que o CI usa. Fonte única: .github/actions/setup-flutter.
VERSAO_PADRAO='3.47.0'
VERSAO="$(sed -n "s/.*default: '\([0-9][0-9.]*\)'.*/\1/p" \
  "${CLAUDE_PROJECT_DIR:-.}/.github/actions/setup-flutter/action.yml" 2>/dev/null \
  | head -1)"
VERSAO="${VERSAO:-$VERSAO_PADRAO}"

RAIZ="${CLAUDE_PROJECT_DIR:-$PWD}"
SDK="$HOME/flutter"
export PUB_CACHE="$HOME/.pub-cache"

aviso() { printf '%s\n' "$*" >&2; }

# Só na web: numa máquina local o Flutter é assunto de quem senta nela.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

instalar_sdk() {
  [ -x "$SDK/bin/flutter" ] && return 0

  local url="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${VERSAO}-stable.tar.xz"
  aviso "Baixando o Flutter ${VERSAO}…"
  if ! curl -fsSL --max-time 600 "$url" -o /tmp/flutter.tar.xz; then
    aviso ''
    aviso '────────────────────────────────────────────────────────────'
    aviso 'Não consegui baixar o Flutter: a política de rede deste'
    aviso 'ambiente não libera os hosts necessários.'
    aviso ''
    aviso 'Para ligar, o ambiente precisa permitir:'
    aviso '  · storage.googleapis.com  (o SDK e os artefatos do engine)'
    aviso '  · pub.dev                 (os metadados dos pacotes)'
    aviso '  · github.com              (pacotes buscados de repositório)'
    aviso ''
    aviso 'Enquanto isso, a sessão abre normalmente — só sem analyze'
    aviso 'nem test locais.'
    aviso '────────────────────────────────────────────────────────────'
    return 1
  fi

  mkdir -p "$HOME" && tar -xJf /tmp/flutter.tar.xz -C "$HOME" && rm -f /tmp/flutter.tar.xz || return 1
  # O SDK vem de outro dono que não o usuário da sessão; sem isto o
  # `flutter` recusa rodar ("dubious ownership").
  git config --global --add safe.directory "$SDK" 2>/dev/null || true
}

if ! instalar_sdk; then
  exit 0
fi

export PATH="$SDK/bin:$PATH"

# A partir daqui nada é fatal: o SDK já é mais do que havia antes.
flutter --version >/dev/null 2>&1 || aviso 'flutter --version falhou; sigo assim mesmo.'

cd "$RAIZ" || exit 0
aviso 'Resolvendo dependências (flutter pub get)…'
flutter pub get >/dev/null 2>&1 || aviso 'pub get falhou — provavelmente pub.dev bloqueado.'

# O app não compila sem isto: lib/l10n/generated/ é gitignored e nasce daqui.
aviso 'Gerando a camada de i18n (flutter gen-l10n)…'
flutter gen-l10n >/dev/null 2>&1 || aviso 'gen-l10n falhou.'

# Deixa o SDK no PATH da sessão inteira.
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  {
    echo "export PATH=\"$SDK/bin:\$PATH\""
    echo "export PUB_CACHE=\"$PUB_CACHE\""
  } >> "$CLAUDE_ENV_FILE"
fi

aviso 'Flutter pronto.'
