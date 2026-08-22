# 🔑 Configurar o Login com Google — Grimório de Bolso

Guia passo a passo para resolver o erro
`Erro no login com Google: PlatformException(sign_in_failed, ...: 10: ...)`
(o famoso **`ApiException: 10` / DEVELOPER_ERROR**).

---

## 🧭 Resumo: por que dá o erro 10

O app usa **login nativo** do Google: `google_sign_in` obtém um *idToken* no
aparelho e o envia ao Supabase (`signInWithIdToken`). Para o Google emitir esse
token, o **Google Play Services valida o app no dispositivo**, comparando:

> **package name** (`com.grimoriodebolso.app`) **+ SHA-1 da assinatura do APK**

com os **Android OAuth clients** cadastrados no seu projeto do Google Cloud.
Se essa dupla não bater com nenhum cadastro → **erro 10**, antes de qualquer
token ser emitido. Ou seja: **não é senha nem rede — é assinatura/registro.**

### O que estava causando no seu caso (2 problemas)

1. **O APK estava assinado em modo _debug_.** No CI (`.github/workflows/release-parallel.yml`),
   só o build do **AAB** preparava o keystore de release; o build do **APK** (que
   você instalou no celular) não preparava — e, por
   `android/app/build.gradle`, ele caía no **fallback de assinatura debug**. O
   SHA-1 debug não bate com o registrado → erro 10.
   ✅ **Corrigido nesta branch**: o job `build-apk` agora assina com o keystore
   de release e **imprime o SHA-1 no log da Action** (passo "🔎 Print APK signing SHA-1").
2. **Campo errado no Supabase.** Em *Authentication → Providers → Google*, o
   campo **Authorized Client IDs** recebeu `com.grimoriodebolso.app`. Ali vai o
   **Web client ID**, não o package. (Detalhes na Etapa 3.)

### ⚡ DIAGNÓSTICO CONFIRMADO (logs da Action de 15/07/2026, run v46)

O passo "🔎 Print APK signing SHA-1" revelou que existem **dois certificados
diferentes** em jogo:

| Origem | SHA-1 |
|---|---|
| **APK real** (keystore dos GitHub Secrets `ANDROID_KEYSTORE_*`) | **`54:84:54:75:7F:A8:37:1C:21:F4:B9:71:E7:B7:F8:05:25:85:FB:60`** |
| Registro antigo no Google Cloud (`google-services.json`) | `8B:D7:BB:97:B9:5C:8D:5E:54:9D:55:84:A0:1F:E2:7A:EC:85:DA:98` |

O keystore cadastrado nos Secrets **não é** o que gerou o registro antigo —
por isso o `ApiException: 10` persiste mesmo com o APK assinado em release.

> **✅ AÇÃO NECESSÁRIA**: registrar o SHA-1 do APK real
> (`54:84:54:75:7F:A8:37:1C:21:F4:B9:71:E7:B7:F8:05:25:85:FB:60`) como um novo
> OAuth client Android no Google Cloud (Etapa 2 abaixo). Nada muda no app.

---

## Etapa 1 — Obter o SHA-1 (3 caminhos)

Escolha **um**. O caminho A é o mais fácil e não exige nada instalado.

### Caminho A — pelo log da GitHub Action (recomendado) ✅

Depois que esta branch for mergeada, rode o workflow de release. No job
**📱 Build APK**, abra o passo **"🔎 Print APK signing SHA-1"**. Ele mostra algo como:

```
Signer #1 certificate SHA-1: 8b:d7:bb:97:b9:5c:8d:5e:54:9d:55:84:a0:1f:e2:7a:ec:85:da:98
```

Copie esse valor. Pronto — pule para a Etapa 2 (comparar) ou 3 (Supabase).

### Caminho B — direto do arquivo APK (sem saber alias nem senha)

Serve para conferir com **qual** certificado um APK foi assinado. Precisa do
**JDK** (que traz o `keytool`). Instale se necessário:

- Windows: [Adoptium Temurin JDK](https://adoptium.net/) → instalar → reabrir o terminal.
- macOS: `brew install temurin`
- Linux: `sudo apt install default-jdk`

Com o APK baixado (ex.: `grimorio-de-bolso-1.0.0.apk`):

```bash
keytool -printcert -jarfile grimorio-de-bolso-1.0.0.apk
```

Procure a linha `SHA1:`. (Se der "não assinado com v1", use o `apksigner` do
Android SDK: `apksigner verify --print-certs SEU.apk`.)

> 💡 Se você rodar isso no **APK atual** (o que falhou), vai ver um SHA-1 que
> **não** é o `8B:D7:…` — justamente a prova de que ele foi assinado em debug.

### Caminho C — direto do keystore (descobre o alias sozinho)

Use se quiser o SHA-1 **oficial** do keystore de release sem depender da Action.
Você definiu esse keystore no secret `ANDROID_KEYSTORE_BASE64` do GitHub e a
senha em `ANDROID_STORE_PASSWORD`.

1. Recupere o arquivo do keystore. Se você tem o `.jks`/`.keystore` original,
   use-o. Se só tem o valor base64 do secret, decodifique:
   ```bash
   # cole o conteúdo do secret ANDROID_KEYSTORE_BASE64 em um arquivo base64.txt
   base64 -d base64.txt > release.keystore
   ```
2. Liste o conteúdo — **isto mostra todos os aliases** (você não precisa saber
   o "SEU_ALIAS" de antemão; ele é o valor do secret `ANDROID_KEY_ALIAS`):
   ```bash
   keytool -list -v -keystore release.keystore -storepass A_SUA_SENHA_STORE
   ```
3. Na saída, cada `Alias name:` traz logo abaixo `SHA1:` e `SHA256:`. Copie o `SHA1`.

> **Não sabe a senha?** Ela é o secret `ANDROID_STORE_PASSWORD` que você mesmo
> cadastrou no GitHub. Sem ela não há como abrir o keystore — nesse caso use o
> Caminho A (log da Action) ou B (do APK).

---

## Etapa 2 — Registrar o SHA-1 no Google Cloud (só se for diferente)

Abra o **mesmo** projeto do app (não crie outro — o `google-services.json` e o
código estão amarrados a ele):

- Console: <https://console.cloud.google.com/>
- Projeto: **`grimorio-de-bolso`** (número `625869809120`) — selecione no topo.

1. Menu → **APIs & Services → Credentials**
   (<https://console.cloud.google.com/apis/credentials>).
2. Em **OAuth 2.0 Client IDs**, veja se já existe um do tipo **Android** com o
   package `com.grimoriodebolso.app`. Clique nele e compare o **SHA-1** com o
   que você obteve na Etapa 1.
   - **Igual a `8B:D7:BB:97:…`?** Nada a fazer aqui — vá para a Etapa 3.
   - **Diferente?** Continue:
3. **+ CREATE CREDENTIALS** (topo) → **OAuth client ID**.
4. **Application type**: **Android**.
5. **Name**: algo como `Grimorio Android release`.
6. **Package name**: `com.grimoriodebolso.app`
7. **SHA-1 certificate fingerprint**: cole o SHA-1 da Etapa 1.
8. **Create**. (Cada client Android aceita 1 SHA-1; se você usa mais de uma
   assinatura — release, Play, debug local — crie um client para cada.)
9. **OAuth consent screen** (menu lateral): se o app estiver em **Testing**,
   vá em **Audience/Test users** e adicione o seu email do Google, senão o
   login é barrado.

> ⏳ Pode levar de alguns minutos a algumas horas para propagar. **Não precisa
> rebuildar o APK** — é só tentar o login de novo.

---

## Etapa 3 — Corrigir o provider Google no Supabase

Painel do Supabase → seu projeto → **Authentication → Providers → Google**.

| Campo | O que colocar |
|---|---|
| **Enable** | Ligado |
| **Authorized Client IDs** | O **Web client ID**: `625869809120-vekqjnltlccc7llalu6adgl1js8tngob.apps.googleusercontent.com` — **corrija** o valor `com.grimoriodebolso.app` que está aí hoje |
| **Client ID (OAuth)** | O mesmo Web client ID acima |
| **Client Secret (OAuth)** | O secret **do Web client**, copiado do Google Cloud (formato `GOCSPX-…`). ⚠️ O valor `WqKf%M6-QuU+pDU` que você tinha **não** parece um secret Google — troque pelo correto |
| **Skip nonce checks** | **Deixe DESLIGADO.** Ver o aviso abaixo — esta instrução estava invertida |

> ### ⚠️ "Skip nonce checks" — esta página mandava o contrário
>
> A versão anterior deste documento dizia para **ativar** a opção. Estava
> errado, e o erro é do tipo que não aparece: com ela ligada, o Supabase
> **para de comparar o nonce** — e o nonce é justamente o que amarra um ID
> token à tentativa de login que o pediu. Sem a comparação, um token
> interceptado pode ser usado em outra sessão.
>
> A instrução nasceu do fluxo **nativo do Android**, que nem sempre manda
> nonce. Mas a opção **não é por provedor nem por plataforma: vale para o
> projeto inteiro** — inclusive para a entrada web dentro da página, que
> manda o nonce corretamente (o cru para o Supabase, o `sha256` para o
> Google; ver `_entrarSemSairDaAba`).
>
> **O que fazer:** abra o painel e confira. Se estiver ligada, desligue e
> teste os dois caminhos — a entrada web e a nativa do Android. Se a nativa
> passar a recusar, o certo é fazê-la mandar nonce, não voltar a desligar a
> conferência do projeto todo.
>
> *(Conferir e mudar isso exige o painel do Supabase — não dá para fazer
> pelo repositório.)*

**Por que o Web client ID?** O app pede o token com
`serverClientId = 625869809120-vekqjnltlccc7llalu6adgl1js8tngob…`
(`lib/features/auth/data/repositories/supabase_auth_repository.dart:22`), então
o token vem com **essa** audiência. O Supabase só aceita o token se esse ID
estiver em *Authorized Client IDs*. O **Android** client (Etapa 2) serve para o
Google Play Services liberar o app no aparelho; o **Web** client serve para o
Supabase validar o token. Você precisa dos **dois**.

Onde achar o **Client Secret do Web client**: Google Cloud → **Credentials** →
em *OAuth 2.0 Client IDs* clique no client **Web** (`…-vekqjnltlccc7llalu6adgl1js8tngob`)
→ o secret aparece à direita (ou baixe o JSON).

> O **Callback URL** que o Supabase mostra
> (`https://zadqmtamrkbvdpmqtexb.supabase.co/auth/v1/callback`) só é usado no
> fluxo **web** (`kIsWeb`). Para o app Android nativo ele não é necessário, mas
> não atrapalha deixá-lo cadastrado no client Web (em *Authorized redirect URIs*).

---

## ✅ Checklist de verificação

1. Merge desta branch → rodar o workflow de release.
2. No job **📱 Build APK**, passo **"🔎 Print APK signing SHA-1"**, o valor bate
   com `8B:D7:BB:97:…` (ou é o SHA-1 que você registrou na Etapa 2).
3. Supabase → Google provider: **Authorized Client IDs** = Web client ID.
4. Instalar o **novo** APK (o desta pipeline, já assinado em release).
5. Abrir o app → **Entrar com Google** → escolher a conta.
6. Esperado: **sem `ApiException: 10`**, login conclui e cria a linha em
   `profiles` (via trigger do banco). Confira em Supabase → Table Editor → `profiles`.

### Se ainda falhar

| Sintoma | Verifique |
|---|---|
| `ApiException: 10` persiste | O SHA-1 do APK realmente está no Google Cloud (Android client, package exato `com.grimoriodebolso.app`); propagação pode levar horas |
| Login abre mas Supabase recusa | *Authorized Client IDs* = Web client ID. **Não** ligue "Skip nonce checks" para resolver isto — ver o aviso da Etapa 3 |
| `ApiException: 12500`/consent | Adicionar seu email em *Test users* na OAuth consent screen |
| Funciona no APK direto mas não na Play Store | A Play Store **re-assina** o app (Play App Signing); registre também o SHA-1 de **Play Console → Test and release → App integrity** |

---

## 🔐 Nota de segurança — acesso admin (pendência)

Hoje o acesso admin é feito na tela de login com **email `admin` + senha `admin`**
(`lib/features/auth/presentation/pages/login_page.dart:361-374`), marcado no
código como *"REMOVER EM PRODUÇÃO"*. Isso permite que **qualquer pessoa** com o
APK vire admin. Antes de publicar, recomenda-se:

1. Remover o bypass fixo `admin/admin`.
2. Usar o caminho já existente `AdminConfig` (`ADMIN_EMAIL`/`ADMIN_PASSWORD`),
   injetando os valores como secrets no CI
   (`--dart-define=ADMIN_EMAIL=… --dart-define=ADMIN_PASSWORD=…` nos passos de
   build do `release-parallel.yml`) — hoje esses defines **não** são passados,
   então esse caminho está inativo nos builds.

Mantido como está por decisão atual (prático para testes). Registrado aqui para
não ser esquecido no release.
