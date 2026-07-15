# 🔮 Guia de Restauração do Supabase — Grimório de Bolso

O projeto Supabase original expirou por inatividade. Este guia recria o
ambiente do zero em ~15 minutos. **Nenhum dado de usuário foi perdido**: o
app usa SQLite local como fonte primária; o Supabase é a camada de conta
(login) e sincronização Premium.

## Como o app se conecta

- As credenciais entram no build via `--dart-define`:
  `SUPABASE_URL` e `SUPABASE_ANON_KEY` (ver `lib/core/config/supabase_config.dart`).
- Sem credenciais, o app roda 100% local (`SupabaseConfig.isConfigured == false`) —
  login de conta, sync e códigos beta cross-device ficam desativados.
- O CI (`.github/workflows/release-parallel.yml`) lê os mesmos valores dos
  **GitHub Secrets**.

## Passo 1 — Criar o projeto

1. Acesse <https://supabase.com/dashboard> e faça login.
2. **New project** → escolha a organização.
3. Nome: `grimorio-de-bolso` (ou outro).
4. **Database password**: gere uma senha forte e guarde (não é usada pelo app,
   só para acesso administrativo ao Postgres).
5. **Region**: `South America (São Paulo)` — menor latência para usuários BR.
6. Aguarde o provisionamento (~2 min).

## Passo 2 — Recriar o banco

1. No painel do projeto: **SQL Editor** → **New query**.
2. Cole o conteúdo COMPLETO de [`supabase/restore_database.sql`](../supabase/restore_database.sql).
3. **Run**. Deve terminar com "Success. No rows returned".
4. O script é idempotente — se algo falhar no meio, corrija e rode de novo
   sem medo de duplicar.

> Sempre que `supabase/restore_database.sql` mudar, execute o arquivo completo
> novamente no SQL Editor do projeto. As funções usam `CREATE OR REPLACE`, então
> a reaplicação é idempotente. Isso inclui a RPC `redeem_beta_code`, que também
> persiste `role = premium` e `plan = lifetime` em `public.profiles` — apenas
> para usuários AUTENTICADOS (id UUID de conta Supabase); resgates de usuários
> anônimos/locais continuam funcionando, mas o premium deles fica só no
> aparelho (SharedPreferences) e não sobrevive a reinstalação. Para persistir,
> o usuário deve estar logado ao resgatar o código.

O script cria:
- as 15 tabelas de dados + `profiles` (com RLS por usuário);
- a coluna `updated_at` em todas as tabelas de sync (**correção** de uma
  inconsistência: o schema antigo não tinha a coluna em ~11 tabelas e o
  `DataSyncService` a exige em todo upsert);
- o trigger que cria o `profile` automaticamente no signup;
- a tabela `beta_codes` (versão multi-uso) com políticas de acesso anônimo;
- a RPC **`redeem_beta_code`** — resgate atômico, elimina a condição de
  corrida de dois usuários resgatando o mesmo código;
- funções `reset_daily_counters` / `reset_monthly_counters`.

## Passo 3 — Configurar autenticação

1. **Authentication → Providers → Email**: deixe habilitado.
   - Para beta fechado, você pode desativar "Confirm email" e reativar depois.
   - Se a confirmação estiver ativa, abra **Authentication → Email Templates →
     Confirm signup** e traduza assunto e conteúdo para PT-BR, usando o branding
     **Grimório de Bolso**.
2. **Google (opcional)** — necessário para o botão "Entrar com Google":
   - **Authentication → Providers → Google** → habilite;
   - preencha Client ID/Secret do console Google Cloud;
   - em **Authorized redirect URIs** no Google Cloud, adicione:
     `https://SEU-PROJETO.supabase.co/auth/v1/callback`;
   - o deep link nativo do app é `io.supabase.grimorio` (já configurado em
     `SupabaseConfig.deepLinkScheme`).

## Passo 4 — Copiar as credenciais

**Settings → API**:
- **Project URL** → `SUPABASE_URL` (ex.: `https://abcdefgh.supabase.co`)
- **anon public** key → `SUPABASE_ANON_KEY` (começa com `eyJ...`)

⚠️ Nunca use a `service_role` key no app.

## Passo 5 — Configurar o ambiente

### Desenvolvimento local
```bash
cp .env.example .env
# edite .env e preencha SUPABASE_URL e SUPABASE_ANON_KEY
flutter run --dart-define-from-file=.env
```

### CI / Releases (GitHub Actions)
No repositório GitHub: **Settings → Secrets and variables → Actions**:
- `SUPABASE_URL` = Project URL
- `SUPABASE_ANON_KEY` = anon key

O workflow `release-parallel.yml` já injeta esses secrets no build.

## Passo 6 — (Opcional) Agendar reset de contadores

**Database → Cron Jobs** (extensão `pg_cron`):
- `reset_daily_counters()` — diário às `0 3 * * *` (03:00 UTC = 00:00 BRT)
- `reset_monthly_counters()` — `0 3 1 * *` (dia 1 de cada mês)

## Passo 7 — Validar

Checklist com o app rodando com o `.env` configurado:

1. **Auth + trigger**: crie uma conta (email/senha). Em **Table Editor →
   profiles** deve aparecer 1 linha com o email.
2. **Códigos beta (admin)**: painel admin → Códigos Beta → criar um código.
   Confira em **Table Editor → beta_codes** que a linha existe **no Supabase**
   (se aparecer erro na UI, o código NÃO foi criado — comportamento novo, sem
   fallback silencioso).
3. **Resgate**: em outro dispositivo/instalação, resgate o código na tela de
   Assinatura. Deve conceder Premium vitalício. Resgatar de novo deve falhar
   com "já foi utilizado".
4. **Invalidar**: invalide um código no painel admin e tente resgatá-lo —
   deve ser recusado (bug antigo corrigido).
5. **Sync Premium**: com usuário premium logado, crie um feitiço e rode a
   sincronização (Configurações → Privacidade). Não pode haver erro de
   "column updated_at not found"; confira a linha em **Table Editor → spells**.

## Solução de problemas

| Sintoma | Causa provável | Correção |
|---|---|---|
| Código beta "criado" mas não aparece no Supabase | Projeto sem as políticas anon (RLS antigo) | Rode `supabase/restore_database.sql` de novo |
| Erro `column updated_at ... not found` no sync | Banco criado com o schema antigo (`docs/supabase_schema.sql`) | Rode o script — os `ALTER TABLE` adicionam a coluna |
| Resgate falha com erro de função | RPC `redeem_beta_code` ausente | Rode o script; o app tem fallback, mas a RPC é o caminho seguro |
| Login Google não volta pro app | Redirect URI errado no Google Cloud | Use `https://SEU-PROJETO.supabase.co/auth/v1/callback` |

## Arquivos relacionados

- `supabase/restore_database.sql` — script único de restauração (este guia).
- `docs/supabase_schema.sql` — schema histórico (mantido para referência;
  **use o restore_database.sql**, que o substitui e corrige).
- `SUPABASE_BETA_CODES_SETUP.md` — histórico da investigação dos códigos beta.
- `.env.example` — template das variáveis de ambiente.
