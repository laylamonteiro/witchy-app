#!/usr/bin/env bash
# Acusa chave declarada nos ARBs que nenhuma tela consome — e o contrário,
# chave usada no código que não existe nos ARBs.
#
# Órfã não quebra build nem teste: ela só apodrece. E traduzir texto morto em
# quatro idiomas é trabalho jogado fora — pior, esconde as duas que são bug de
# verdade (uma chave certa que a tela deixou de usar) no meio do acervo.
#
# Gate próprio, e não um remendo no check_arb_sync.sh: aquele compara ARB com
# ARB e nunca abre um .dart, então órfã passa batido por construção.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
python3 - "$ROOT" <<'PY'
import json, re, sys
from pathlib import Path

raiz = Path(sys.argv[1])
arb = json.loads((raiz / "lib/l10n/app_pt.arb").read_text(encoding="utf-8"))
# Chaves com '@' são metadados do ARB (@@locale, @@x-nota, @chave de
# placeholder), não geram getter — ficam fora da conta.
declaradas = {k for k in arb if not k.startswith("@")}

# Comentário vira prosa ("...vem sempre do l10n. Na web...") e inventa chave
# que não existe. Some antes da varredura.
COMENTARIO = re.compile(r"^\s*///?.*$", re.M)

# O `\s*` dos dois lados do ponto existe porque a cadeia quebra linha (há
# `.premiumPlaceholderText;` sozinho numa linha). E o prefixo
# `[A-Za-z0-9_]*` cobre os getters privados `_l10n`: `\b` não casa depois de
# um underline, e ignorá-los produziria centenas de órfãs falsas.
PADROES = [
    re.compile(r"[A-Za-z0-9_]*[lL]10[nN]\s*\.\s*([a-zA-Z_][a-zA-Z0-9_]*)"),
    re.compile(
        r"(?:AppLocalizations\s*\.\s*of\s*\([^)]*\)"
        r"|lookupAppLocalizations\s*\([^)]*\))\s*!?\s*\.\s*([a-zA-Z_][a-zA-Z0-9_]*)"
    ),
]

# Membros da própria AppLocalizations, não chaves de ARB.
RUIDO = {"delegate", "of", "supportedLocales",
         "localizationsDelegates", "localeName"}


def varre(pastas):
    achadas = set()
    for pasta in pastas:
        for arquivo in (raiz / pasta).rglob("*.dart"):
            if "l10n/generated" in str(arquivo):
                continue  # gerado: espelha o ARB, não é consumo
            texto = COMENTARIO.sub(
                "", arquivo.read_text(encoding="utf-8", errors="ignore"))
            for p in PADROES:
                achadas.update(p.findall(texto))
    return achadas - RUIDO


usadas_lib = varre(["lib"])
usadas_tudo = usadas_lib | varre(["test"])

ok = True

fantasmas = sorted(usadas_tudo - declaradas)
if fantasmas:
    ok = False
    print(f"{len(fantasmas)} chave(s) usada(s) e NÃO declarada(s):")
    for chave in fantasmas:
        print(f"  {chave}")

orfas = sorted(declaradas - usadas_tudo)
if orfas:
    ok = False
    print(f"{len(orfas)} chave(s) ÓRFÃ(S) (declarada, nenhuma tela usa):")
    for chave in orfas:
        print(f"  {chave}")

# Chave que só o teste usa não é órfã, mas também não é tela: fica como
# aviso, sem derrubar o gate.
so_teste = sorted((declaradas - usadas_lib) - set(orfas))
if so_teste:
    print(f"AVISO: {len(so_teste)} chave(s) só usada(s) em test/: {so_teste}")

if ok:
    print(f"OK: as {len(declaradas)} chaves do template têm uso no código.")
sys.exit(0 if ok else 1)
PY
