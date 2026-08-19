#!/usr/bin/env python3
"""Confere que a faixa configurada existe de verdade na Play, ANTES de buildar.

A faixa vem de uma variável de repositório (PLAY_TRACK) e, para uma faixa
fechada criada à mão, o identificador não é o rótulo que aparece na tela —
é um id que só se descobre na URL da Play Console. Errar é fácil.

Sem esta conferência, o erro só apareceria no upload, que acontece DEPOIS
do deploy do site: produção já teria mudado e o app não. Aqui o release
morre em ~20 segundos, antes de qualquer build e de qualquer publicação.

Entra por ambiente (nada em argv, para o JSON da service account não vazar
em `ps` nem no log do runner):
    PLAY_SERVICE_ACCOUNT_JSON   conteúdo bruto do JSON da service account
    PLAY_TRACK                  identificador da faixa esperada
    PLAY_PACKAGE                applicationId (ex.: com.grimoriodebolso.app)
"""

import json
import os
import sys
import urllib.error
import urllib.request

import google.auth.transport.requests
from google.oauth2 import service_account

API = "https://androidpublisher.googleapis.com/androidpublisher/v3/applications"
ESCOPO = "https://www.googleapis.com/auth/androidpublisher"


def erro(msg: str) -> "None":
    print(f"::error::{msg}")
    sys.exit(1)


def chamar(metodo: str, url: str, token: str) -> dict:
    req = urllib.request.Request(url, method=metodo)
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("Content-Length", "0")
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            corpo = resp.read().decode("utf-8")
            return json.loads(corpo) if corpo else {}
    except urllib.error.HTTPError as e:
        detalhe = e.read().decode("utf-8", "replace")[:400]
        if e.code in (401, 403):
            erro(
                f"A Play recusou o acesso ({e.code}). A service account foi "
                "convidada e a permissão 'Lançar em faixas de teste' já "
                f"propagou? Ver docs/PLAY_SERVICE_ACCOUNT.md. Detalhe: {detalhe}"
            )
        erro(f"Play API {metodo} {e.code}: {detalhe}")
    except urllib.error.URLError as e:
        erro(f"Play API inacessível: {e.reason}")
    return {}


def main() -> None:
    sa_json = os.environ.get("PLAY_SERVICE_ACCOUNT_JSON", "")
    faixa = os.environ.get("PLAY_TRACK", "")
    pacote = os.environ.get("PLAY_PACKAGE", "")
    if not (sa_json and faixa and pacote):
        erro("PLAY_SERVICE_ACCOUNT_JSON, PLAY_TRACK e PLAY_PACKAGE são obrigatórios.")

    try:
        info = json.loads(sa_json)
    except json.JSONDecodeError:
        erro(
            "PLAY_SERVICE_ACCOUNT_JSON não é um JSON válido — o secret guarda o "
            "conteúdo bruto do arquivo baixado, sem base64."
        )
        return

    creds = service_account.Credentials.from_service_account_info(
        info, scopes=[ESCOPO]
    )
    creds.refresh(google.auth.transport.requests.Request())
    token = creds.token

    # Listar faixas exige um "edit" aberto. Ele é descartado no fim: nada
    # deste script altera o app — é leitura, com um rascunho como veículo.
    edit = chamar("POST", f"{API}/{pacote}/edits", token)
    edit_id = edit.get("id")
    if not edit_id:
        erro(f"A Play não devolveu um edit para {pacote}.")

    try:
        faixas = chamar("GET", f"{API}/{pacote}/edits/{edit_id}/tracks", token)
        nomes = sorted(t.get("track", "") for t in faixas.get("tracks", []))
        if faixa not in nomes:
            erro(
                f"A faixa '{faixa}' não existe em {pacote}. "
                f"Faixas disponíveis: {', '.join(nomes) or '(nenhuma)'}. "
                "Corrija a variável PLAY_TRACK (Settings → Secrets and "
                "variables → Actions → Variables) — o valor é o identificador "
                "do fim da URL em Manage track, não o rótulo da faixa."
            )
        print(f"✅ Faixa '{faixa}' existe em {pacote}.")
        print(f"   Faixas do app: {', '.join(nomes)}")
    finally:
        # Rascunho aberto e nunca fechado fica pendurado na conta.
        chamar("DELETE", f"{API}/{pacote}/edits/{edit_id}", token)


if __name__ == "__main__":
    main()
