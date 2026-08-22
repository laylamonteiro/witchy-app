# Ambientes web: o que precisa estar em allowlist

O app web é o mesmo bundle Flutter em três endereços diferentes:

| Ambiente | Endereço | Publicado por |
|---|---|---|
| Produção | `https://grimoriodebolso.app` | `release.yml` (tag + aprovação) |
| Staging | `https://staging.grimorio-de-bolso.pages.dev` | `branch-validate.yml`, push em `main` |
| Prévia | `https://<alias>.grimorio-de-bolso.pages.dev` | `branch-validate.yml`, push em branch |

Quatro serviços externos decidem se aceitam a página **pelo domínio de onde
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

Sintoma: o Google autentica, mas você volta para o **site de produção**,
nunca logada no endereço que estava usando — e como os dois sites são
idênticos por fora, a troca passa despercebida. Você loga de novo (agora a
partir de produção, então funciona) e passa a testar o app ANTIGO achando
que está no staging. Foi assim que "a novidade não aparece" sobreviveu a
uma dezena de investigações.

O app pede `redirectTo: '${Uri.base.origin}/'`
(`supabase_auth_repository.dart:149`); quando essa origem não casa com
nenhum padrão da allowlist, o Supabase a ignora **em silêncio** e usa o
*Site URL*. O código PKCE chega no domínio errado, onde o segredo da troca
não existe — daí o "tem que logar duas vezes".

> **A barra final não é detalhe.** Os padrões são globs literais:
> `https://*.grimorio-de-bolso.pages.dev/**` só casa se a URL tiver a barra
> depois do domínio. `Uri.base.origin` não a tem — por isso o app a
> acrescenta. Se algum dia alguém tirar essa barra do código, o login volta
> a cair em produção sem erro nenhum no console.

Supabase → **Authentication → URL Configuration** → *Redirect URLs*:

```
https://grimoriodebolso.app/**
https://grimorio-de-bolso.pages.dev/**
https://*.grimorio-de-bolso.pages.dev/**
```

As três linhas: produção, o domínio-raiz do projeto Pages, e o curinga que
cobre `staging.` e as prévias por branch. O curinga do Supabase casa **um
nível** de subdomínio, então o domínio-raiz precisa da própria entrada.

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

### Duas chaves web: sandbox × produção (automático)

O RevenueCat Billing tem **duas** chaves públicas para a web e cada estágio
da esteira usa a sua — não precisa trocar id na mão:

| Secret do GitHub            | Prefixo   | Onde é usada                                     |
| --------------------------- | --------- | ------------------------------------------------ |
| `REVENUECAT_WEB_KEY_SANDBOX`| `rcb_sb_` | `branch-validate.yml` → staging e prévias        |
| `REVENUECAT_WEB_KEY`        | `rcb_`    | `release.yml` → produção (grimoriodebolso.app)   |

A sandbox aceita **cartão de teste** e não cobra nada; a de produção cobra
de verdade. Cada workflow tem uma **trava**: o staging aborta se a chave não
começar com `rcb_sb_`, e a produção aborta se começar com `rcb_sb_`. Assim
uma prévia nunca cobra cartão real e o site de produção nunca fica preso em
cartão de teste, mesmo que os secrets sejam trocados por engano.

> As chaves de Android/iOS **não** têm par sandbox/produção — a própria loja
> decide o ambiente (license tester → sandbox). Só a web precisa das duas.

## 4. Google Cloud — Authorized JavaScript origins (entrada sem sair da aba)

Sintoma: **"Access blocked: origin_mismatch"** numa tela do Google no meio do
login — ou, quando o app se protege antes de tentar, nenhum sintoma: a
entrada acontece pelo **redirecionamento** de sempre, e o único rastro é o
voltar do navegador passando a sair do app.

Google Cloud → **APIs & Services → Credentials** → o client OAuth **Web** →
*Authorized JavaScript origins*:

```
https://grimoriodebolso.app
https://staging.grimorio-de-bolso.pages.dev
```

> **O Google não aceita curinga aqui.** Nada de `https://*.pages.dev` — cada
> endereço entra na mão. É a diferença desta lista para as três de cima, e é
> o motivo de as **prévias por branch ficarem de fora**: o endereço nasce
> com a branch, autorizá-lo exigiria mexer no painel e recompilar, e a
> recompilação publica noutro endereço. Prévia cai no redirecionamento, que
> funciona em qualquer origem.

> ⏳ A propagação leva de **5 minutos a algumas horas**. Não precisa
> rebuildar — é configuração de servidor, como as outras três.

**Esta lista existe DUAS vezes**, e as duas precisam concordar:

| Onde | O que acontece se faltar |
|---|---|
| Painel do Google Cloud | Tela de bloqueio no meio do login |
| `GoogleSignInConfig.origensAutorizadas` (no código) | Cai no redirecionamento — inofensivo |

A assimetria é de propósito: **na dúvida, deixe de fora do código.** O pior
que acontece é a pessoa entrar pelo caminho antigo. Mexer no código exige
build novo (`--dart-define`), o painel não.

E o `GOOGLE_WEB_CLIENT_ID` é secret de GitHub: sem ele no build, o caminho
novo não existe em lugar nenhum. O `release.yml` **aborta** se ele faltar,
justamente porque a ausência não tem sintoma próprio.

## Regra prática

Prefira sempre **staging** para testar: é um endereço fixo, autorizado uma
vez e para sempre. As prévias por branch têm alias estável por branch (o
resumo do run imprime como "Endereço do alias") — use esse, nunca o link do
deploy individual.

## O que exige rebuild e o que não

- Mudar **allowlist** (hostname do Turnstile, Redirect URLs do Supabase,
  domínios do RevenueCat, origens do Google Cloud): efeito **imediato**, é
  configuração de servidor. Basta recarregar a página — no caso do Google,
  depois da propagação.
- Mudar a lista de origens **no código** (`GoogleSignInConfig`): exige build
  novo, como qualquer código.
- Mudar a **chave** (`TURNSTILE_SITE_KEY`, `SUPABASE_ANON_KEY`,
  `REVENUECAT_WEB_KEY`): exige **novo build**, porque elas entram no bundle
  por `--dart-define` no momento da compilação.
