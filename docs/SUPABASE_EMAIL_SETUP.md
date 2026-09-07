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

## 4. SMTP próprio (produção) — Resend + Cloudflare

**Por que isto é obrigatório agora.** O Supabase avisou (ago/2026) que a
reputação de envio do projeto `zadqmtamrkbvdpmqtexb` está em risco por
bounces. Nos dados: 83 de 170 usuários (49%) nunca confirmaram o e-mail, com
domínios legítimos (92% Gmail) — ou seja, o problema é entregabilidade do
**SMTP embutido** (IP compartilhado entre milhares de projetos, sem SLA,
"não destinado a produção" nas palavras da própria doc). Se o Supabase
restringir o envio, param a confirmação de cadastro **e** a redefinição de
senha. SMTP próprio dá ao app reputação de envio própria e SPF/DKIM/DMARC no
nosso domínio.

**Nada aqui toca usuário existente.** Muda só *por onde* o e-mail sai.

### 4.1 Resend (conta + domínio) — ~10 min, só você

1. Crie a conta em <https://resend.com> (plano grátis: 3.000 e-mails/mês —
   folga enorme para o volume atual, ~6 cadastros/dia).
2. **Domains → Add Domain** → `grimoriodebolso.app`.
   Região: **South America (sa-east-1)** — mesma região do projeto Supabase e
   dos usuários.
3. O Resend mostra 3 registros DNS para adicionar. Como o domínio está na
   **Cloudflare**, use o botão **"Sign in with Cloudflare"** que o Resend
   oferece: ele cria os registros sozinho. Se preferir manual, no painel da
   Cloudflare (DNS → Records) adicione exatamente o que o Resend exibir:
   - `TXT  resend._domainkey`  → o valor DKIM gerado pelo Resend (copie dele);
   - `MX   send`               → `feedback-smtp.sa-east-1.amazonses.com`, prioridade 10;
   - `TXT  send`               → `v=spf1 include:amazonses.com ~all`.
   Todos **DNS only** (nuvem cinza, não proxied). Não conflita com SPF que
   já exista na raiz, porque o SPF do Resend fica no subdomínio `send`.
4. (Recomendado) DMARC na raiz, se ainda não houver:
   `TXT  _dmarc` → `v=DMARC1; p=none; rua=mailto:postmaster@grimoriodebolso.app`.
   `p=none` só monitora — não rejeita nada; aperte depois, com dados.
5. Volte ao Resend e clique **Verify**. Costuma verificar em minutos
   (propagação da Cloudflare é rápida).
6. **API Keys → Create API Key** → nome `supabase-auth-smtp`, permissão
   **Sending access**, domínio `grimoriodebolso.app`. Copie a chave (`re_...`)
   — ela aparece **uma vez só**.

### 4.2 Supabase — a configuração em si (~2 min)

Há dois jeitos. O **A** é o mais simples e não exige compartilhar segredo.

**A) Pelo painel** — Supabase → **Authentication → SMTP Settings**
(<https://supabase.com/dashboard/project/zadqmtamrkbvdpmqtexb/auth/smtp>):

| Campo | Valor |
|---|---|
| Enable Custom SMTP | **ligado** |
| Sender email | `noreply@grimoriodebolso.app` |
| Sender name | `Grimório de Bolso` |
| Host | `smtp.resend.com` |
| Port number | `465` |
| Username | `resend` (literalmente essa palavra) |
| Password | a API key do Resend (`re_...`) |
| Minimum interval between emails | deixe o padrão |

**Save.**

**B) Pela Management API** (equivalente, para quem prefere script). Gere um
token pessoal em <https://supabase.com/dashboard/account/tokens> (pode revogar
logo depois). Os segredos ficam em variáveis de ambiente — nunca no repo:

```bash
export SUPABASE_ACCESS_TOKEN="sbp_..."   # token pessoal do Supabase
export RESEND_API_KEY="re_..."           # API key do Resend (Sending access)

curl -sS -X PATCH "https://api.supabase.com/v1/projects/zadqmtamrkbvdpmqtexb/config/auth" \
  -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$(cat <<JSON
{
  "external_email_enabled": true,
  "mailer_secure_email_change_enabled": true,
  "mailer_autoconfirm": false,
  "smtp_admin_email": "noreply@grimoriodebolso.app",
  "smtp_host": "smtp.resend.com",
  "smtp_port": 465,
  "smtp_user": "resend",
  "smtp_pass": "$RESEND_API_KEY",
  "smtp_sender_name": "Grimório de Bolso"
}
JSON
)"
```

> `mailer_autoconfirm: false` **mantém a confirmação de e-mail ligada** —
> é o estado atual e é ela que barra os endereços ruins. Não desligue sob
> pressão de bounce; a doc do Supabase é explícita nisso.

### 4.3 Limite de envio — não é bug

Ao ativar SMTP próprio o Supabase impõe **30 e-mails/hora** de fábrica, para
proteger a reputação nova. Para o volume atual sobra, mas dá um folga em
**Authentication → Rate Limits → "Rate limit for sending emails"**
(<https://supabase.com/dashboard/project/zadqmtamrkbvdpmqtexb/auth/rate-limits>):
**60/hora** é um bom teto para um dia bom com reenvios e resets.

### 4.4 Verificar (faça, não pule)

1. Crie uma conta de teste no app com um e-mail real seu.
2. O e-mail deve chegar **de `noreply@grimoriodebolso.app`** (não mais de
   `noreply@mail.app.supabase.io`). Nos cabeçalhos ("mostrar original" no
   Gmail): `SPF: PASS`, `DKIM: PASS`.
3. Resend → **Emails**: o envio aparece como *Delivered*.
4. Teste também **"Esqueci a senha"** — é o outro fluxo que depende disto.
5. (Opcional) <https://www.mail-tester.com>: mande um cadastro para o
   endereço que ele gera e veja a nota (meta ≥ 9/10).
6. Nos logs do Supabase (Logs → Auth), os `mail.send` seguem sem `error`.

Se algo falhar, **desligar "Enable Custom SMTP" volta ao embutido na hora** —
é reversível sem tocar em dados.

### 4.5 Depois de ligar

- O aviso "Email Sending Privileges at risk" deve parar de chegar.
- O reforço de validação do cadastro (`lib/core/utils/validacao_email.dart`)
  continua valendo: SMTP próprio conserta a *entregabilidade*; a validação
  corta os endereços *malformados* na origem. Um não substitui o outro.
- Erro de digitação em caixa que existe (`joaosila@gmail.com`) continua
  possível — só a confirmação de e-mail pega. Por isso ela fica ligada.

## Observações

- **Remetente**: por padrão o Supabase envia de `noreply@mail.app.supabase.io`
  pelo SMTP embutido — que **não é para produção**. A configuração de SMTP
  próprio está na **seção 4** acima.
- Se preferir **desativar a confirmação** durante o beta fechado:
  **Authentication → Providers → Email → Confirm email = off** (o template e a
  página continuam prontos para quando reativar).
