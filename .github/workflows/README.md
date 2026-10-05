# CI/CD do Grimório de Bolso

Princípio: **publicar é decisão, nunca efeito colateral de merge** — e o site só
vai ao ar depois que a versão Android passou pela faixa de teste da Play.

| Workflow | Dispara em | O que faz | Toca usuárias? |
|---|---|---|---|
| `branch-validate.yml` | push em qualquer branch, Run workflow | gate, prévia/staging do site, PRs automáticos, APK candidato (botão) | **Nunca** |
| `release.yml` | push na `main` (dry-run), push na `release`, Run workflow | gate + builds assinados; publica Play (teste) e, com aprovação, o site | **Só o site, e só com aprovação** |

## O fluxo

```
branch ──push──▶ gate + prévia do site + PR draft para a main (automático)
   ▼ você mergeia
 main ──push──▶ staging.grimorio-de-bolso.pages.dev
   │            + dry-run do release.yml (gate + AAB/APK assinados + web de produção)
   │            + PR "🚢 Publicar vX.Y.Z" (main → release), aberto/atualizado sozinho
   ▼ você mergeia o PR de publicação
release ──push──▶ preparar → gate ‖ build Android ‖ build web (em paralelo)
   │
   ├─▶ play-interno (AUTOMÁTICO): AAB na faixa de teste → tag vX.Y.Z → Release em rascunho
   │      ▼ você testa pela faixa interna da Play
   └─▶ producao-web (você APROVA o environment `production`):
          site em grimoriodebolso.app → Release publicada
   ▼ quando quiser
 promove teste → produção NA PLAY CONSOLE (manual, de propósito)
```

- Achou um problema na faixa interna? **Rejeite** a aprovação: o site não muda.
  A versão fica gasta (o versionCode já foi à Play) e o próximo merge usa o patch seguinte.
- Patch = mergear o PR. **Minor/major** = Actions → 🚀 Release → *Run workflow* com a
  versão (ex.: `2.1.0`), a partir da `main`.
- Enquanto um release espera aprovação do site, o próximo release espera na fila
  (um por vez). Os dry-runs da `main` não esperam — têm fila própria.

## Jobs do `release.yml`

- **preparar**: versão (`versionName` = X.Y.Z; `versionCode` = `M*100000 + m*1000 + p*10`),
  maior que toda tag, acima do legado (126), secrets presentes, faixa da Play existe
  (`scripts/ci/conferir_faixa_play.py`). Publicar pelo botão só a partir da `main`.
- **validar / build-android (apk, aab) / build-web**: em paralelo, do mesmo SHA. Cada
  binário Android confere a própria assinatura contra o SHA-1 registrado. O APK é só anexo:
  se falhar, a publicação segue sem ele.
- **play-interno**: idempotente — num re-run, a tag existente indica que o upload já foi feito.
- **producao-web**: atrás do environment `production`.
- **Faixa**: variável de repositório `PLAY_TRACK` (sem ela, `internal`); `production` é recusado.

## Composite actions (`.github/actions/`)

Uma receita só para os dois workflows:

| Action | O que faz |
|---|---|
| `setup-flutter` | Java + Flutter **pinado** + pub get + gen-l10n (atualizar o Flutter = mudar o default lá) |
| `credenciais-app` | stubs vazios das credenciais de IA + `google-services.json` opcional |
| `gate` | analyze, catraca de `use_build_context_synchronously`, `flutter test`, testes Node/Chrome, ARBs, scan de PT |
| `build-web` | travas do ambiente (`producao`/`previa`), build, montagem, bundle sem chave de IA/admin, `version.txt` |
| `build-android` | keystore, build apk/aab, sem chave de IA, conferência de assinatura |
| `keystore-android` | decodifica e valida o keystore |

Actions de terceiros são fixadas por SHA de commit (tag no comentário).

## Setup fora do repositório

1. **Secrets** (Settings → Secrets and variables → Actions): `ANDROID_KEYSTORE_*`,
   `GOOGLE_SERVICES_JSON`, `SUPABASE_*`, `REVENUECAT_*` (incl. `REVENUECAT_WEB_KEY_SANDBOX`),
   `ADMIN_*`, `ADMOB_ANDROID_INTERSTITIAL_ID`, `TURNSTILE_SITE_KEY`, `GOOGLE_WEB_CLIENT_ID`,
   `CLOUDFLARE_*`, `PLAY_SERVICE_ACCOUNT_JSON` (ver `docs/PLAY_SERVICE_ACCOUNT.md`).
2. **Variável `PLAY_TRACK`** (aba *Variables*): identificador da faixa de teste.
3. **Environment `production`** (Settings → Environments): *Required reviewers* = você e
   *Deployment branches* = `release` e `main`.
4. **Cloudflare Pages**: Production branch do projeto `grimorio-de-bolso` = `main`
   (os workflows conferem e falham se divergir).
5. **Branch protection na `main`**: required check `🔍 Analyze, Test & Build`.

Endereços novos precisam estar nas allowlists de Turnstile, Supabase e RevenueCat —
ver `docs/AMBIENTES_WEB.md`. Todo site publicado serve `/version.txt` com versão e commit.
