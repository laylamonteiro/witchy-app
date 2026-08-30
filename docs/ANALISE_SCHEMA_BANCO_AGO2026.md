# Análise do schema do banco — agosto de 2026

> Análise do banco **ativo** de produção (`zadqmtamrkbvdpmqtexb`, "Grimório de
> Bolso", sa-east-1, Postgres 17). Feita só com consultas de LEITURA
> (`information_schema`, `pg_catalog`, `COUNT`s) e os Advisors do Supabase.
> **Nada foi alterado no banco.** As melhorias vêm como arquivos `.sql` em
> `supabase/`, para você revisar e rodar no SQL Editor — nenhuma delas afeta
> quem já é usuário.
>
> Números medidos em 2026-08-30: **173 perfis**, e o resto da base é pequeno
> (spells 20, free_writings 41, tarot 10, birth_charts 21, magical_profiles
> 21, cycle_readings 11, learning_progress 5).

---

## 1. As colunas de `profiles` que não estão sendo preenchidas

Você observou certo. Contando linha por linha nas **173** de `profiles`:

| Coluna | Preenchidas | Situação |
|---|---|---|
| `email` | 173 / 173 | OK |
| `display_name` | 150 / 173 | OK (23 sem nome — login sem nome) |
| `updated_at` / `created_at` | 173 / 173 | OK |
| `role` / `plan` | 173 (default `free`) | OK — 25 premium/admin |
| `conta_de_teste` | 173 (5 = true) | OK |
| **`signup_platform`** | **117 / 173** | **56 NULL** — ver §1.1 |
| **`photo_url`** | **0 / 173** | **nunca preenchida** — ver §1.2 |
| **`birth_date`** | **0 / 173** | **nunca preenchida** — ver §1.2 |
| **`birth_time`** | **0 / 173** | **nunca preenchida** — ver §1.2 |
| **`birth_place`** | **0 / 173** | **nunca preenchida** — ver §1.2 |
| **`spells_count`** | **0 em todas** | **coluna morta** — ver §1.3 |
| **`diary_entries_this_month`** | **0 em todas** | **coluna morta** — ver §1.3 |
| **`ai_consultations_today`** | **0 em todas** | **coluna morta** — ver §1.3 |
| **`pendulum_uses_today`** | **0 em todas** | **coluna morta** — ver §1.3 |
| **`affirmations_today`** | **0 em todas** | **coluna morta** — ver §1.3 |
| **`rune_readings_today`** | **0 em todas** | **coluna morta** — ver §1.3 |
| **`oracle_readings_today`** | **0 em todas** | **coluna morta** — ver §1.3 |

São **três causas diferentes**, e cada uma pede uma resposta diferente.

### 1.1 `signup_platform` — 56 NULL (bug real, com conserto já no código)

Distribuição: **117 = `android`** (criados 14/07 a 22/08, backfill histórico) e
**56 = NULL** (criados de **20/08 até hoje, 30/08**). Nenhum `ios`, nenhum `web`.

A causa está documentada em `supabase/signup_platform_trigger_migration.sql`:
com confirmação de e-mail exigida, `signUp()` não devolve sessão → o app roda
como `anon` → o `REVOKE ALL ... FROM anon` do lockdown nega o UPDATE de
`signup_platform` que o cliente tentava fazer. A correção (mandar a plataforma
no metadata do `signUp` e deixar o trigger `handle_new_user` gravar) **já está
no banco** — conferi: a função `handle_new_user` grava `signup_platform` e o
trigger `on_auth_user_created` está ativo.

Só que **as 56 NULL vão até hoje**, o que indica que a build publicada ainda
não é a que envia o metadata (a auditoria de 22/08 diz que "nada está em
produção"; isso entra com a v2.0.31). **Ação:** depois que a v2.0.31 subir,
confirme que perfil novo nasce com a coluna preenchida. Os NULL da janela
20/08→publicação são pré-conserto e podem ser marcados como `unknown` (passo
opcional, já escrito no fim daquele arquivo de migração). Backfill é seguro:
muda só um campo de telemetria, não afeta acesso nem dado da pessoa.

### 1.2 `photo_url`, `birth_date`, `birth_time`, `birth_place` — colunas vestigiais

**Zero preenchidas nas 173** porque **nenhum caminho do app escreve nelas**:

- **Dados de nascimento:** o único método que gravaria (`updateProfile` com
  `birthDate/birthTime/birthPlace`) **nunca é chamado com esses argumentos** —
  todas as chamadas de `updateProfile` passam só `displayName` (e raramente
  `email`). Os dados de nascimento de verdade vivem na tabela **`birth_charts`**
  (com `latitude`, `longitude`, `timezone`, `chart_data`), que é o que a
  Astrologia usa. As colunas `birth_*` da `profiles` são de um desenho antigo,
  substituído por `birth_charts`. Estão órfãs.
- **`photo_url`:** existe um seletor de avatar, mas o handler `onPhotoChanged`
  (`profile_page.dart:82`) chama `updateProfile(displayName: ...)` **sem passar
  a foto** — o avatar é salvo como caminho de arquivo local
  (`image_storage_service`, pasta `avatar`), nunca em `profiles.photo_url`. Na
  exibição, a leitura cai em `metadata['photo_url']` (o avatar do Google). Logo
  a coluna nunca recebe nada. (Efeito colateral menor: o avatar escolhido não
  sincroniza entre aparelhos — é bug de app, não de banco, e fica fora do
  escopo "não impactar usuários".)

**O que fazer:** nada agora — ver §4 (por que NÃO derrubar essas colunas).

### 1.3 Os 7 contadores (`*_count`, `*_today`, `*_this_month`) — colunas mortas

**Todas com 0 em todas as 173 linhas.** Isso é *por desenho*, e está escrito em
`supabase/profiles_lockdown_migration.sql` (seção 2b): no repositório inteiro há
**7 leituras** dessas colunas (ao montar o `UserModel` no login) e **zero
escritas**. Quem guarda o uso do dia é o `SharedPreferences` do aparelho. As
colunas foram criadas para um contador no servidor que nunca foi implementado.

Consequência prática (conhecida e aceita): como o contador vive no aparelho,
reinstalar/trocar de aparelho zera o uso do dia — e, no login, o `UserModel`
recebe `0` do servidor antes de o app voltar a contar localmente. Não é erro; é
o limite de guardar contador no cliente.

---

## 2. Que erros podem estar ocorrendo por causa do banco

Da pergunta "que erros o banco pode estar causando", em ordem de relevância:

1. **Telemetria de origem furada (ativo).** Enquanto a build nova não sobe,
   todo cadastro entra com `signup_platform` NULL (56 e contando). Relatórios de
   "de onde vêm as contas" ficam cegos para o período. Ver §1.1.

2. **Exclusão por auth.users trava (latente).** `profiles.profiles_id_fkey`
   está **`NO ACTION`** enquanto as 22 outras tabelas são `ON DELETE CASCADE`.
   Apagar uma pessoa pelo painel do Supabase (ou por uma futura Edge Function
   `delete-user` — hoje comentada em `deleteAccount`) **falha** enquanto a linha
   de `profiles` existir. Corrigível sem tocar em dado — arquivo
   `indices_e_chaves_migration.sql` §3.

3. **Cascatas e JOINs lentos conforme cresce (latente).** Duas FKs sem índice:
   `magical_profiles.birth_chart_id` e `ritual_logs.ritual_id`. Corrigir a data
   de nascimento recria o mapa e dispara cascade no perfil mágico varrendo a
   tabela toda; apagar um ritual varre `ritual_logs`. Hoje são milissegundos
   (tabelas pequenas), mas é dívida que escala. Arquivo
   `indices_e_chaves_migration.sql` §1.

4. **CPU desperdiçado nas políticas RLS (latente).** As 88 políticas avaliam
   `auth.uid()` **uma vez por linha** em vez de uma vez por consulta. Irrelevante
   a 40 linhas; vira O(n) à toa quando cada pessoa acumula dados e o sync está
   aberto para toda a base. Arquivo `rls_initplan_optimization_migration.sql`.

5. **Escrita duplicada em `daily_magical_weather` (menor).** Índice único
   duplicado sobre `(user_id, date)` — dobra o custo de escrita sem ganho.
   Arquivo `indices_e_chaves_migration.sql` §2.

Coisas que **já estão consertadas** e não são mais erro (confiram, mas está OK
no banco ativo):

- **Escalada para admin pela `profiles`** (o achado crítico da auditoria de
  22/08): o lockdown foi aplicado. Conferido — `anon` não tem grant nenhum em
  `profiles`, e `authenticated` só escreve as colunas sem poder (`role`, `plan`
  e os contadores ficaram de fora do GRANT). O PATCH que virava admin agora é
  negado pelo banco.
- **Perfil sobrevivendo à exclusão de conta:** já existe política de DELETE em
  `profiles`, e o app apaga pela chave certa (`id`, não `user_id`).

---

## 3. Melhorias seguras entregues (não impactam usuários existentes)

Dois arquivos idempotentes em `supabase/`, no mesmo padrão dos que já existem
("rode INTEIRO no SQL Editor"). Nenhum altera uma linha de dado de usuário.

| Arquivo | O que faz | Impacto em quem já existe |
|---|---|---|
| `rls_initplan_optimization_migration.sql` | Reescreve as 88 políticas com `(select auth.uid())`. Roda numa transação (nunca fica sem política). | **Zero** — regra de acesso idêntica, só muda como é avaliada |
| `indices_e_chaves_migration.sql` §1 | Cria índice nas 2 FKs sem cobertura | **Zero** — só metadado |
| `indices_e_chaves_migration.sql` §2 | Derruba o índice único duplicado | **Zero** — sobra o que respalda a constraint |
| `indices_e_chaves_migration.sql` §3 | `profiles_id_fkey` → `ON DELETE CASCADE` | **Zero** hoje — só muda o que acontece ao apagar por auth.users |
| `indices_e_chaves_migration.sql` §4 | (opcional, comentado) derruba 14 índices nunca usados | **Zero** — reversível |

Sugestão de ordem: rode primeiro `indices_e_chaves_migration.sql` (rápido e
baixo risco) e depois `rls_initplan_optimization_migration.sql`. Rode
`get_advisors` de novo no fim para ver os avisos sumirem.

---

## 4. O que NÃO fazer (e por quê) — pega-ratos

Estas mudanças *parecem* melhorias, mas quebrariam usuários existentes. Ficam
registradas para ninguém as fazer "de arrumação":

- **NÃO derrube as colunas mortas/vestigiais de `profiles` agora.** É a
  tentação óbvia (11 colunas sempre vazias). Mas o app é cliente instalado, e
  **builds antigas no aparelho das pessoas ainda podem referenciar `photo_url`
  e `birth_*`** num INSERT/UPDATE de perfil — se a coluna sumir, aquela conta
  passa a receber erro ao salvar o perfil. Os 7 contadores são mais seguros de
  remover (nenhuma build escreve neles), mas o ganho é nulo e o risco de mexer
  na tabela mais sensível não compensa. **Recomendação:** deixe como estão,
  marque como *deprecated* no `docs/supabase_schema.sql`, e só planeje remoção
  depois que builds antigas saírem de circulação — nunca sob a restrição atual.

- **NÃO adicione `UNIQUE(user_id, lesson_id)` em `learning_progress`.** A tabela
  não tem essa restrição e, na teoria, aceita duplicata (hoje há 0). Mas o app
  faz *check-then-insert* e o upload remoto é `upsert` com conflito no **`id`**
  (não em `user_id,lesson_id`). Uma UNIQUE nova faria o segundo aparelho a
  concluir a mesma lição **falhar o sync com 409**. Só é seguro junto de uma
  mudança de app (upsert com `onConflict: 'user_id,lesson_id'`) — não é migração
  de banco isolada.

- **NÃO crie trigger de `updated_at` (`moddatetime`).** Parece higiene, mas o
  sync usa `updated_at` gerado **pelo cliente** para resolver conflito
  (`mostRecent`). Um trigger que sobrescrevesse `updated_at` no servidor brigaria
  com a lógica de conflito e poderia fazer o servidor "ganhar" sempre. Deixe o
  `updated_at` sob controle do cliente, como está.

---

## 5. Segurança — estado atual (2 avisos, ambos brandos)

Os Security Advisors trazem 2 avisos `WARN`, nenhum crítico:

1. `redeem_beta_code` é `SECURITY DEFINER` executável por `authenticated`. É
   **intencional** (decisão de produto, documentada no lockdown) — só note que
   o advisor sempre vai apontar; se um dia o resgate deixar de existir, revogue
   o EXECUTE.
2. **Proteção de senha vazada desligada** (HaveIBeenPwned). É um toggle em
   Authentication → Providers → Password. Ligar não afeta ninguém já cadastrado;
   só passa a barrar senha nova sabidamente vazada.

---

## 6. Housekeeping (fora do schema, mas visto no caminho)

- **Há dois projetos Supabase na organização:** o ativo
  (`zadqmtamrkbvdpmqtexb`, sa-east-1, criado 17/05/2026 — o de produção) e um
  **`jdncobtussylzfabrebe`** (us-east-2, criado 22/11/2025, status **INACTIVE**).
  Vale confirmar que o inativo é lixo de um projeto antigo e pode ser
  arquivado/apagado, para não pagar por um banco esquecido nem confundir quem
  for depurar.
- `email` em `profiles` é gravado na criação e não acompanha troca de e-mail no
  Auth — pode ficar desatualizado. Baixa prioridade; só relevante se você usar
  `profiles.email` para suporte/relatório em vez de `auth.users.email`.
