# 📧 Email de Confirmação — Grimório de Bolso

Como deixar o email de confirmação do Supabase com o visual do app e dar um
destino claro ao usuário depois do clique (em vez de `localhost:3000/?code=...`).

## 1. Template do email (2 min)

1. Painel do Supabase → **Authentication → Email Templates** → aba **Confirm signup**.
2. **Subject heading**:
   ```
   Confirme seu email — Grimório de Bolso ✨
   ```
3. No corpo, troque TODO o conteúdo pelo HTML de
   [`docs/email_templates/confirm_signup.html`](email_templates/confirm_signup.html)
   (abra o arquivo, copie tudo, cole no editor do Supabase).
4. **Save**. O placeholder `{{ .ConfirmationURL }}` é preenchido pelo Supabase
   automaticamente — não renomeie.

> Os outros templates (Reset password, Magic link, Change email) podem ser
> adaptados do mesmo HTML trocando título/texto/botão.

## 2. Destino após o clique — abrir o app via deep link (2 min, SEM hospedagem)

Ao clicar no link, o Supabase confirma o email no banco e depois **redireciona**
para uma URL. Por padrão essa URL é o **Site URL** (que estava apontando para
uma página não publicada → erro **404**).

O app **já está pronto** para receber o retorno por **deep link** — não precisa
hospedar nada nem expor nenhum site:
- `AndroidManifest.xml` tem o intent-filter do esquema `io.supabase.grimorio`;
- o cadastro já pede retorno em `io.supabase.grimorio://email-confirm`
  (`supabase_auth_repository.dart`);
- o `supabase_flutter` processa esse link automaticamente ao abrir o app.

Basta **autorizar esse deep link** no Supabase para ele ser usado no lugar do
Site URL:

Painel do Supabase → **Authentication → URL Configuration**:

| Campo | Valor |
|---|---|
| **Redirect URLs** (clique em *Add URL* e adicione os dois) | `io.supabase.grimorio://email-confirm` e `io.supabase.grimorio://reset-password` |
| **Site URL** | troque a URL do GitHub por `io.supabase.grimorio://email-confirm` (evita qualquer 404 no fallback) |

**Save.** Agora: clicar no email → Supabase confirma → **o app abre
automaticamente** já com a conta confirmada (e, na maioria dos casos, já
logado). Nenhuma página web, nenhum link do GitHub.

> **Por que estava dando 404**: o deep link não estava na allowlist de
> *Redirect URLs*, então o Supabase ignorava o `emailRedirectTo` do app e caía
> no *Site URL* (a página do GitHub Pages, que não está publicada).

> A página `docs/email-confirmado.html` fica guardada para o futuro: se um dia
> você tiver um domínio próprio (ex.: `grimoriodebolso.app`), dá para hospedá-la
> lá e usar como destino web. Por enquanto o deep link resolve sem hospedagem.

## 3. Testar

1. Crie uma conta nova no app (no **celular**) com um email real.
2. Verifique a caixa de entrada: o email deve chegar com o visual roxo/lilás
   do app (verifique também o spam na primeira vez).
3. Abra o email **no celular** e toque em **Confirmar meu email**.
4. O aparelho deve abrir o **app Grimório de Bolso** (pode aparecer um "Abrir
   com Grimório de Bolso?" — confirme). A conta já está confirmada.
5. Se o app não logar sozinho, é só entrar com email e senha — a confirmação
   já foi feita no passo 3.

## Observações

- **Remetente**: por padrão o Supabase envia de `noreply@mail.app.supabase.io`
  com limite baixo de envios/hora — suficiente para beta. Para produção,
  configure SMTP próprio em **Authentication → SMTP Settings** (ex.: Resend,
  Brevo, SES) e o remetente vira o seu domínio.
- Se preferir **desativar a confirmação** durante o beta fechado:
  **Authentication → Providers → Email → Confirm email = off** (o template e a
  página continuam prontos para quando reativar).
