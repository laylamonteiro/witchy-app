# CI/CD do Grimório de Bolso

Dois workflows, papéis sem sobreposição:

| Workflow | Dispara em | O que faz | Toca usuários? |
|---|---|---|---|
| `branch-validate.yml` | push em `main` e `claude/**` | gate de qualidade + prévia/staging do site + APK candidato | **Nunca** |
| `release.yml` | tag `vX.Y.Z` ou botão Run workflow | gate de novo + builds assinados + publica site, Play e Release | **Só com aprovação** |

O princípio: **publicar é decisão, nunca efeito colateral de merge.**

## O fluxo do dia a dia

```
branch claude/** ──push──▶ validação + prévia própria do site
        │
        ▼ merge (PR)
      main ──push──▶ validação + STAGING (staging.grimorio-de-bolso.pages.dev)
        │                        + APK candidato assinado (artifact, 14 dias)
        │
        │  baixa o candidato, instala no aparelho, testa
        ▼
bash scripts/release.sh 2.1.0
        │
        ▼
   release.yml: guardas → gate bloqueante → APK+AAB+web do commit da tag
        │
        ▼ aprovação humana (environment `production`)
   site em produção + AAB na faixa INTERNA da Play + GitHub Release
        │
        ▼ testa pela faixa interna e, quando aprovar,
   promove para produção NA PLAY CONSOLE (manual, de propósito)
```

## branch-validate.yml

- **Gate** (bloqueante): `flutter analyze`, suíte completa de testes,
  paridade dos 4 ARBs, scanner de PT hardcoded. Build de APK debug só
  quando `android/` ou `pubspec` mudam.
- **Site**: toda branch ganha prévia própria; `main` publica no alias fixo
  `staging` — **grimoriodebolso.app não muda nunca por este workflow** (ele
  jamais passa `--branch=main` ao wrangler, e um passo confere via API que
  a Production branch do projeto Cloudflare segue `main`; divergência é
  erro).
- **APK candidato** (só em `main`): APK de **release assinado**, versionName
  `X.Y.Z-rc.<sha>`, como artifact — para instalar e testar antes de decidir
  publicar.

## release.yml

- **Versão**: a tag é a fonte de verdade. `versionName` = tag sem o `v`;
  `versionCode` = `major*100000 + minor*1000 + patch*10` (2.1.0 → 201000).
  Determinístico, monotônico (verificado contra todas as tags, incluindo as
  legadas `vX.Y.Z+N`), sem commit de bot e sem tocar no pubspec.
- **Guardas antes de buildar**: semver estrito, versão maior que toda tag
  existente, versionCode acima do legado (piso 126), secrets presentes.
- **Gate bloqueante**: os mesmos testes do branch-validate, no commit exato
  da tag — sem `|| echo`.
- **Builds do mesmo SHA**: APK+AAB assinados (assinatura conferida contra o
  SHA-1 registrado — divergência é erro fatal, nos dois artefatos) e o site.
  Nada publica sem Android **e** web verdes juntos.
- **Publicação** (job único, atrás do environment `production`):
  tag (se veio do botão) → site (`--branch=main`) → AAB na faixa `internal`
  da Play → GitHub Release com `target_commitish` no SHA buildado.
- **Dry-run**: Run workflow com `somente_validar: true` exercita tudo até os
  builds sem criar tag nem publicar nada.

## Como publicar uma versão

```bash
git checkout main && git pull
bash scripts/release.sh 2.1.0
# → acompanhe em Actions, aprove o environment "production",
# → teste pela faixa interna da Play e promova na Play Console.
```

## Setup que vive fora do repositório

1. **Secrets** (Settings → Secrets and variables → Actions): os já
   existentes (`ANDROID_KEYSTORE_*`, `GOOGLE_SERVICES_JSON`, `GROQ/GEMINI/
   PROKERALA`, `SUPABASE_*`, `REVENUECAT_*`, `ADMIN_*`, `TURNSTILE_SITE_KEY`,
   `CLOUDFLARE_*`) mais **`PLAY_SERVICE_ACCOUNT_JSON`** — ver
   `docs/PLAY_SERVICE_ACCOUNT.md`.
2. **Environment `production`** (Settings → Environments): criar com
   *Required reviewers* = você. É o clique que separa "buildou" de
   "usuários viram".
3. **Cloudflare Pages**: Production branch do projeto `grimorio-de-bolso`
   precisa ser `main` (Workers & Pages → Settings → Builds & deployments).
4. **Branch protection na `main`** (Settings → Branches, DEPOIS do primeiro
   run verde dos workflows novos): require status check
   `🔍 Analyze, Test & Build`, require branch up to date, block force
   pushes, restrict deletions, sem bypass — nenhum bot commita mais na main.

## Versões

- Flutter/Java do CI: pinados em `.github/actions/setup-flutter/action.yml`
  (um lugar só). Para atualizar o Flutter do CI, mude o default lá.
- As composite actions em `.github/actions/` (`setup-flutter`,
  `credenciais-app`, `keystore-android`) são compartilhadas pelos dois
  workflows — mudou num, valeu nos dois.
