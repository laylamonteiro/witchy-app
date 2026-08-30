-- ============================================================================
-- GRIMÓRIO DE BOLSO — OTIMIZAÇÃO DAS POLÍTICAS RLS (initplan)
-- ============================================================================
-- Rode este arquivo INTEIRO no SQL Editor do Supabase
-- (Database → SQL Editor → New query → colar → Run).
--
-- É IDEMPOTENTE: rodar de novo não estraga nada, e roda dentro de UMA
-- transação — nunca há um instante sem política (a tabela nunca fica aberta).
--
-- NÃO MUDA COMPORTAMENTO NENHUM. Não afeta usuários existentes: a regra de
-- acesso continua exatamente a mesma ("cada pessoa só enxerga/edita as
-- próprias linhas"). A única diferença é COMO o Postgres avalia `auth.uid()`.
--
-- POR QUE ISTO EXISTE
-- -------------------
-- O Performance Advisor do Supabase aponta 88 ocorrências de
-- `auth_rls_initplan` — as 4 políticas (SELECT/INSERT/UPDATE/DELETE) de cada
-- uma das 22 tabelas. Todas foram criadas com `auth.uid() = user_id` (ou
-- `= id`, na profiles). Escrito assim, o Postgres RE-AVALIA `auth.uid()`
-- UMA VEZ POR LINHA varrida. Envolvendo a chamada num subselect —
-- `(select auth.uid())` — o planejador a resolve UMA VEZ por consulta e
-- reaproveita o valor (InitPlan).
--
-- Hoje, com dezenas de linhas por tabela, o custo é irrelevante. Mas o sync
-- abriu para toda a base e o volume tende a crescer; a diferença entre "uma
-- vez por linha" e "uma vez por consulta" vira O(n) desnecessário à medida
-- que cada pessoa acumula feitiços, diários e leituras. É a correção
-- recomendada pela própria Supabase e não tem contraindicação.
--   https://supabase.com/docs/guides/database/database-linter?lint=0003_auth_rls_initplan
--
-- MÉTODO
-- ------
-- Para cada tabela, derrubamos TODAS as políticas atuais e recriamos as 4
-- canônicas com `(select auth.uid())`. O "derruba todas" é de propósito: os
-- nomes das políticas divergem no banco (algumas com espaço — "own cycle
-- readings" —, outras com underscore — "own daily_rituals"). Recriar por
-- nome derivado deixaria a política antiga de pé ao lado da nova, DUPLICANDO
-- a permissiva (o oposto do que se quer). Conferido antes de escrever isto:
-- cada uma das 22 tabelas tem exatamente 4 políticas, todas do papel
-- `public`. A `beta_codes` (que tem política de papel próprio) NÃO é tocada.
--
-- As formas preservadas são IDÊNTICAS às de hoje:
--   · tabelas por dono (user_id): SELECT/DELETE com USING, INSERT com
--     WITH CHECK, UPDATE só com USING (sem WITH CHECK — como o
--     create_user_policy original em docs/supabase_schema.sql criou).
--   · profiles (chave `id`): igual, mas o UPDATE mantém o WITH CHECK que o
--     lockdown adicionou (profiles_lockdown_migration.sql). Os GRANTS por
--     coluna da profiles NÃO são tocados aqui — o lockdown continua de pé.
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- 1. As 21 tabelas cuja posse é pela coluna `user_id`
-- ----------------------------------------------------------------------------
DO $$
DECLARE
  t   text;
  pol text;
  tabelas text[] := ARRAY[
    'spells', 'dreams', 'desires', 'gratitudes', 'affirmations',
    'free_writings', 'learning_progress', 'daily_rituals', 'ritual_logs',
    'sigils', 'birth_charts', 'magical_profiles', 'rune_readings',
    'pendulum_consultations', 'oracle_readings', 'daily_magical_weather',
    'user_encyclopedia_entries', 'daily_checkins', 'cycle_readings',
    'tarot_readings', 'sync_tombstones'
  ];
BEGIN
  FOREACH t IN ARRAY tabelas LOOP
    -- derruba todas as políticas atuais desta tabela (qualquer nome)
    FOR pol IN
      SELECT policyname FROM pg_policies
       WHERE schemaname = 'public' AND tablename = t
    LOOP
      EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', pol, t);
    END LOOP;

    -- recria as 4 canônicas com (select auth.uid()) — mesma semântica de hoje
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR SELECT USING ((select auth.uid()) = user_id)',
      'Users can view own ' || t, t);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR INSERT WITH CHECK ((select auth.uid()) = user_id)',
      'Users can insert own ' || t, t);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR UPDATE USING ((select auth.uid()) = user_id)',
      'Users can update own ' || t, t);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR DELETE USING ((select auth.uid()) = user_id)',
      'Users can delete own ' || t, t);
  END LOOP;
END $$;

-- ----------------------------------------------------------------------------
-- 2. profiles — chave `id`, e o UPDATE mantém o WITH CHECK do lockdown
-- ----------------------------------------------------------------------------
DO $$
DECLARE
  pol text;
BEGIN
  FOR pol IN
    SELECT policyname FROM pg_policies
     WHERE schemaname = 'public' AND tablename = 'profiles'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.profiles', pol);
  END LOOP;

  CREATE POLICY "Users can view own profile"   ON public.profiles
    FOR SELECT USING ((select auth.uid()) = id);
  CREATE POLICY "Users can insert own profile" ON public.profiles
    FOR INSERT WITH CHECK ((select auth.uid()) = id);
  CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING ((select auth.uid()) = id)
            WITH CHECK ((select auth.uid()) = id);
  CREATE POLICY "Users can delete own profile" ON public.profiles
    FOR DELETE USING ((select auth.uid()) = id);
END $$;

COMMIT;

-- ============================================================================
-- 3. CONFERÊNCIA — rode depois e leia a saída
-- ============================================================================
-- (a) Toda política deve mostrar `(select auth.uid())` no qual/with_check,
--     e continua havendo 4 por tabela (nenhuma sobra, nenhuma falta):
--
--   SELECT tablename, cmd, qual, with_check
--     FROM pg_policies
--    WHERE schemaname = 'public'
--    ORDER BY tablename, cmd;
--
-- (b) O advisor de performance não deve mais listar `auth_rls_initplan`.
--     Rode "get_advisors(type=performance)" de novo, ou no painel:
--     Advisors → Performance.
-- ============================================================================
