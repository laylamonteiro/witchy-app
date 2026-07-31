#!/usr/bin/env bash
# Verifica paridade de chaves entre os quatro ARBs (pt = template).
# Sai com código != 0 se algum locale tiver chave faltando ou sobrando,
# ou se houver valor vazio.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
python3 - "$ROOT/lib/l10n" <<'PY'
import json, sys
from pathlib import Path

l10n = Path(sys.argv[1])
template = "app_pt.arb"
locales = ["app_pt_BR.arb", "app_en.arb", "app_es.arb"]

def keys(path):
    data = json.loads(path.read_text(encoding="utf-8"))
    return data, {k for k in data if not k.startswith("@")}

base_data, base = keys(l10n / template)
ok = True

for name in locales:
    data, ks = keys(l10n / name)
    missing = base - ks
    extra = ks - base
    empty = [k for k in ks if isinstance(data[k], str) and not data[k].strip()]
    if missing:
        ok = False
        print(f"{name}: {len(missing)} chave(s) FALTANDO: {sorted(missing)[:20]}")
    if extra:
        ok = False
        print(f"{name}: {len(extra)} chave(s) SOBRANDO: {sorted(extra)[:20]}")
    if empty:
        ok = False
        print(f"{name}: {len(empty)} chave(s) VAZIA(S): {sorted(empty)[:20]}")

empty_base = [k for k in base if isinstance(base_data[k], str) and not base_data[k].strip()]
if empty_base:
    ok = False
    print(f"{template}: {len(empty_base)} chave(s) VAZIA(S): {sorted(empty_base)[:20]}")

if ok:
    print(f"OK: {len(base)} chaves em paridade nos 4 ARBs.")
sys.exit(0 if ok else 1)
PY
