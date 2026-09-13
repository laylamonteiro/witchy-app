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
- O CI lê os mesmos valores do repositório (**Variables** ou, como reserva,
  **Secrets**), nos dois workflows que compilam o app:
  `.github/workflows/branch-validate.yml` (validação e site) e
  `.github/workflows/release.yml` (publicação).

## Passo 1 — Criar o projeto

1. Acesse <https://supabase.com/dashboard> e faça login.
2. **New project** → escolha a organização.
3. Nome: `grimorio-de-bolso` (ou outro).
4. **Database password**: gere uma senha forte e guarde (não é usada pelo app,
   só para acesso administrativo ao Postgres).
5. **Region**: `South America (São Paulo)` — menor latência para usuários BR.
6. Aguarde o provisionamento (~2 min).

## Passo 2 — Recriar o banco (o arquivo base)

1. No painel do projeto: **SQL Editor** → **New query**.
2. Cole o conteúdo COMPLETO de [`supabase/restore_database.sql`](../supabase/restore_database.sql).
3. **Run**. Deve terminar com "Success. No rows returned".
4. O script é idempotente — se algo falhar no meio, corrija e rode de novo
   sem medo de duplicar.

⚠️ **Este arquivo é a BASE, não o banco inteiro.** Ele deixou de dar conta
sozinho quando o app passou a sincronizar mais tabelas do que ele cria. Um
projeto que pare aqui nasce com furos de sync: continue no Passo 2b, e trate
o cabeçalho de `restore_database.sql` como a lista que vale — é ele que
acompanha o código.

> Sempre que `supabase/restore_database.sql` mudar, execute o arquivo completo
> novamente no SQL Editor do projeto. As funções usam `CREATE OR REPLACE`, então
> a reaplicação é idempotente. Isso inclui a RPC `redeem_beta_code`, que também
> persiste `role = premium` e `plan = lifetime` em `public.profiles` — apenas
> para usuários AUTENTICADOS (id UUID de conta Supabase); resgates de usuários
> anônimos/locais continuam funcionando, mas o premium deles fica só no
> aparelho (SharedPreferences) e não sobrevive a reinstalação. Para persistir,
> o usuário deve estar logado ao resgatar o código.

O script cria:
- `profiles` + **17 das 21 tabelas sincronizadas** (com RLS por usuário). As 21
  saem do código, não de contagem à mão: são os valores de `SyncEntity`
  (`lib/core/services/data_sync_service.dart`), com os nomes de tabela em
  `SupabaseTables` (`lib/core/config/supabase_config.dart`). As **quatro que
  faltam** — `tarot_readings`, `user_encyclopedia_entries`, `cycle_readings` e
  `menstrual_days` — têm arquivo próprio, no Passo 2b;
- a coluna `updated_at` nas 15 tabelas deste arquivo que o schema antigo criava
  sem ela (**correção** de uma inconsistência: `docs/supabase_schema.sql` só a
  tinha em `profiles`, `spells` e `desires`, e o `DataSyncService` a exige em
  todo upsert e na resolução de conflito);
- o trigger que cria o `profile` automaticamente no signup;
- a tabela `beta_codes` (versão multi-uso) com políticas de acesso anônimo;
- a RPC **`redeem_beta_code`** — resgate atômico, elimina a condição de
  corrida de dois usuários resgatando o mesmo código;
- funções `reset_daily_counters` / `reset_monthly_counters`.

O que ele **não** cria: as quatro tabelas acima, a tabela de lápides
(`sync_tombstones`, que não é entidade de sync mas sem a qual toda exclusão
ressuscita no download seguinte), o bucket privado de imagens, o fechamento
por coluna da `profiles` e a guarda de escrita da Análise Personalizada.

## Passo 2b — Os arquivos que completam o banco

Cada um INTEIRO no SQL Editor, **nesta ordem**:

| # | Arquivo | Por quê |
|---|---|---|
| 1 | `profiles_lockdown_migration.sql` | Fecha `profiles` por coluna (role/plan/contadores fora do alcance do cliente) e endurece as funções SECURITY DEFINER. **Primeiro** por ser o único cuja ausência é falha de segurança, não de dados: sem ele qualquer conta logada se promove a admin. |
| 2 | `tarot_readings_migration.sql` | Sem ela, `syncAll` erra nessa entidade a cada varredura e as tiragens de tarô se perdem na reinstalação. |
| 3 | `user_encyclopedia_entries_migration.sql` | Idem, para os verbetes pessoais da Enciclopédia. |
| 4 | `cycle_readings_migration.sql` | Idem, para as compras de Leitura do Ciclo. |
| 5 | `sync_tombstones_migration.sql` | Sem ela as exclusões ressuscitam no download seguinte. |
| 6 | `menstrual_days_migration.sql` | O registro menstrual. Só é tocada por quem der o SEGUNDO sim (o consentimento de envio, desligado por padrão), mas a tabela precisa existir **antes** de sair a versão do app que envia o ciclo. |
| 7 | `storage_user_images_migration.sql` | O bucket privado `user-images` e as políticas por pasta da conta. Sem ele as fotos dos verbetes pessoais e da Quiromancia falham no envio. |
| 8 | `perfil_magico_upsert.sql` | A guarda que impede uma escrita velha da Análise Personalizada de sobrescrever uma mais nova. |

Do 2 ao 4 **não é opcional**: um projeto restaurado só com o arquivo base nasce
com esses três furos, e a pessoa só descobre quando perde os dados.

Quem confere que toda entidade de sync tem tabela em algum `.sql` da pasta é
`test/nenhuma_tabela_esquecida_test.dart` — é ele que reprova a tabela nova que
ninguém criou.

Os outros arquivos de `supabase/` são **manutenção de um projeto que já existe**
(índices, otimização de RLS, marcação de contas de teste) e não fazem parte de
subir um projeto novo. Se você for rodá-los de todo modo, vale uma ordem:
`menstrual_days_migration.sql` **antes** de
`rls_initplan_optimization_migration.sql`. A otimização é uma transação só que
recria as políticas das 22 tabelas de uma vez; com `menstrual_days` ausente ela
aborta e leva as outras 21 no mesmo rollback.

## Passo 3 — Configurar autenticação

1. **Authentication → Providers → Email**: deixe habilitado.
   - Para beta fechado, você pode desativar "Confirm email" e reativar depois.
   - Com confirmação ativa, siga **[docs/SUPABASE_EMAIL_SETUP.md](SUPABASE_EMAIL_SETUP.md)**:
     template HTML pronto com o visual do app
     (`docs/email_templates/confirm_signup.html`) e página pós-confirmação
     (`docs/email-confirmado.html`) para substituir o redirect padrão
     `localhost:3000`.
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

Os dois workflows que compilam o app já injetam esses valores:
`branch-validate.yml` e `release.yml`. Ambos leem
`vars.SUPABASE_URL || secrets.SUPABASE_URL` (idem para a anon key), então
serve preencher em **Variables** ou em **Secrets** — não nos dois.

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
6. **Passo 2b de fato aplicado**: a sincronização não pode reclamar de NENHUMA
   entidade. Em **Table Editor**, as quatro do Passo 2b (`tarot_readings`,
   `user_encyclopedia_entries`, `cycle_readings`, `menstrual_days`) e
   `sync_tombstones` precisam existir. Tabela que falta não dá erro na hora:
   aparece depois, como dado perdido na reinstalação.

## Solução de problemas

| Sintoma | Causa provável | Correção |
|---|---|---|
| Código beta "criado" mas não aparece no Supabase | Projeto sem as políticas anon (RLS antigo) | Rode `supabase/restore_database.sql` de novo |
| Erro `column updated_at ... not found` no sync | Banco criado com o schema antigo (`docs/supabase_schema.sql`) | Rode o script — os `ALTER TABLE` adicionam a coluna |
| Sync erra sempre nas MESMAS entidades (tarô, verbetes da Enciclopédia, Leitura do Ciclo, ciclo menstrual) | Projeto subiu só com o arquivo base | Rode os arquivos do **Passo 2b** — a tabela dessas quatro não está no base |
| O que foi apagado num aparelho volta no próximo download | `sync_tombstones` ausente | `supabase/sync_tombstones_migration.sql` (Passo 2b, nº 5) |
| `rls_initplan_optimization_migration.sql` aborta inteiro | `menstrual_days` não existe; o arquivo é uma transação só | Rode `menstrual_days_migration.sql` primeiro |
| Resgate falha com erro de função | RPC `redeem_beta_code` ausente | Rode o script; o app tem fallback, mas a RPC é o caminho seguro |
| Login Google não volta pro app | Redirect URI errado no Google Cloud | Use `https://SEU-PROJETO.supabase.co/auth/v1/callback` |

## Arquivos relacionados

- `supabase/restore_database.sql` — o arquivo BASE da restauração (Passo 2). Já
  não é o script único: o cabeçalho dele lista o que rodar depois, e é essa
  lista que vale — o Passo 2b aqui é a mesma, em prosa.
- os outros `.sql` de `supabase/` — as peças do Passo 2b e as de manutenção de
  um projeto que já existe. Cada arquivo diz no cabeçalho para que serve e o
  que precisa vir antes dele.
- `docs/supabase_schema.sql` — schema histórico (mantido para referência;
  **use o restore_database.sql**, que o substitui e corrige).
- `SUPABASE_BETA_CODES_SETUP.md` — histórico da investigação dos códigos beta.
- `.env.example` — template das variáveis de ambiente.
