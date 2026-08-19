# Ambientes web: o que precisa estar em allowlist

O app web é o mesmo bundle Flutter em três endereços diferentes:

| Ambiente | Endereço | Publicado por |
|---|---|---|
| Produção | `https://grimoriodebolso.app` | `release.yml` (tag + aprovação) |
| Staging | `https://staging.grimorio-de-bolso.pages.dev` | `branch-validate.yml`, push em `main` |
| Prévia | `https://<alias>.grimorio-de-bolso.pages.dev` | `branch-validate.yml`, push em branch |

Três serviços externos decidem se aceitam a página **pelo domínio de onde
ela é servida**. Se um endereço novo não estiver na allowlist deles, a
funcionalidade falha só ali — com o app inteiro compilado e correto.

## 1. Cloudflare Turnstile (captcha) — bloqueia o login inteiro

Sintoma: **"A verificação não pôde ser concluída. Tente de novo"** já na tela
de login, antes de qualquer provedor. É `CaptchaGate.resolve()` devolvendo
`null` porque o widget se recusou a resolver o desafio naquele hostname.

Cloudflare → **Turnstile** → o widget do app → *Hostname Management* →
adicione:

```
grimoriodebolso.app
grimorio-de-bolso.pages.dev
```

O Turnstile casa **subdomínios automaticamente**, então
`grimorio-de-bolso.pages.dev` cobre staging e todas as prévias de uma vez.

## 2. Supabase — Redirect URLs (volta do login social)

Sintoma: o Google autentica, mas você volta para o **site de produção** (ou
para lugar nenhum), nunca logada no endereço que estava usando. O app pede
`redirectTo: Uri.base.origin` (`supabase_auth_repository.dart:149`); quando
essa origem não está na allowlist, o Supabase a ignora e usa o *Site URL*.

Supabase → **Authentication → URL Configuration** → *Redirect URLs*:

```
https://grimoriodebolso.app/**
https://*.grimorio-de-bolso.pages.dev/**
```

*Site URL* fica em `https://grimoriodebolso.app`.

> Não adicione o endereço de um deploy específico
> (`https://ee71ec08.grimorio-de-bolso.pages.dev`): esse identificador muda
> a cada build e a autorização quebra no push seguinte. O curinga resolve.
>
> E escope o curinga no projeto, como acima — um `https://*.pages.dev/**`
> genérico autorizaria qualquer projeto Cloudflare do mundo a receber
> tokens de sessão das suas usuárias.

## 3. RevenueCat Billing (compra na web)

Sintoma: a compra não abre ou o checkout recusa a origem. No painel do
RevenueCat, em **Web Billing**, os domínios autorizados precisam incluir os
mesmos endereços.

## Regra prática

Prefira sempre **staging** para testar: é um endereço fixo, autorizado uma
vez e para sempre. As prévias por branch têm alias estável por branch (o
resumo do run imprime como "Endereço do alias") — use esse, nunca o link do
deploy individual.

## O que exige rebuild e o que não

- Mudar **allowlist** (hostname do Turnstile, Redirect URLs do Supabase,
  domínios do RevenueCat): efeito **imediato**, é configuração de servidor.
  Basta recarregar a página.
- Mudar a **chave** (`TURNSTILE_SITE_KEY`, `SUPABASE_ANON_KEY`,
  `REVENUECAT_WEB_KEY`): exige **novo build**, porque elas entram no bundle
  por `--dart-define` no momento da compilação.
