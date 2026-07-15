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

## 2. Página pós-confirmação (5 min)

Hoje, após clicar no link, o usuário cai em `localhost:3000/?code=...` (o
**Site URL** padrão do Supabase). A confirmação até funciona no banco, mas a
tela é confusa. A solução: hospedar a página pronta
[`docs/email-confirmado.html`](email-confirmado.html) e apontar o Supabase para ela.

### 2a. Hospedar via GitHub Pages (se ainda não estiver ativo)

1. GitHub → repositório `witchy-app` → **Settings → Pages**.
2. **Source**: *Deploy from a branch* → Branch **main** → pasta **/docs** → Save.
3. Em ~2 min a página fica em:
   `https://laylamonteiro.github.io/witchy-app/email-confirmado.html`
   (abra no navegador para confirmar).

### 2b. Apontar o Supabase para a página

Painel do Supabase → **Authentication → URL Configuration**:

| Campo | Valor |
|---|---|
| **Site URL** | `https://laylamonteiro.github.io/witchy-app/email-confirmado.html` |
| **Redirect URLs** (adicionar) | `https://laylamonteiro.github.io/witchy-app/email-confirmado.html` |

Pronto: clique no email → Supabase confirma → usuário cai na página bonita
"Email confirmado! Volte ao app" com o visual do Grimório.

## 3. Testar

1. Crie uma conta nova no app com um email real.
2. Verifique a caixa de entrada: o email deve chegar com o visual roxo/lilás
   do app (verifique também o spam na primeira vez).
3. Clique em **Confirmar meu email** → deve abrir a página "Email confirmado!".
4. Volte ao app e faça login normalmente.

## Observações

- **Remetente**: por padrão o Supabase envia de `noreply@mail.app.supabase.io`
  com limite baixo de envios/hora — suficiente para beta. Para produção,
  configure SMTP próprio em **Authentication → SMTP Settings** (ex.: Resend,
  Brevo, SES) e o remetente vira o seu domínio.
- Se preferir **desativar a confirmação** durante o beta fechado:
  **Authentication → Providers → Email → Confirm email = off** (o template e a
  página continuam prontos para quando reativar).
