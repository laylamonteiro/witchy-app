-- ============================================================================
-- GRIMÓRIO DE BOLSO — ÍNDICES DE CHAVE ESTRANGEIRA, ÍNDICE DUPLICADO E
-- CASCADE FALTANTE EM `profiles`
-- ============================================================================
-- Rode este arquivo INTEIRO no SQL Editor do Supabase
-- (Database → SQL Editor → New query → colar → Run).
--
-- É IDEMPOTENTE (tudo com IF [NOT] EXISTS / DROP+ADD).
--
-- NÃO afeta usuários existentes: nenhuma linha de dado é alterada. São
-- mudanças de metadado do banco (índices e a ação de exclusão de uma FK).
--
-- POR QUE ISTO EXISTE
-- -------------------
-- O Performance Advisor apontou:
--   · 2 chaves estrangeiras SEM índice de cobertura (seção 1)
--   · 1 índice DUPLICADO em daily_magical_weather (seção 2)
-- E a auditoria do schema encontrou:
--   · profiles é a ÚNICA tabela cuja FK para auth.users está sem
--     ON DELETE CASCADE (seção 3)
-- ============================================================================

-- Tudo numa transação explícita: a seção 3 derruba e readiciona a FK da
-- profiles, e o BEGIN/COMMIT garante que uma falha reverta o DROP — a tabela
-- nunca fica sem a FK, independente de como o editor agrupa o buffer. (Nada
-- aqui usa CREATE INDEX CONCURRENTLY, então rodar em transação é seguro; a
-- limpeza OPCIONAL da seção 4 fica de fora, depois do COMMIT.)
BEGIN;


-- ----------------------------------------------------------------------------
-- 1. ÍNDICES QUE FALTAM NAS CHAVES ESTRANGEIRAS
-- ----------------------------------------------------------------------------
-- Toda coluna de FK deveria ter índice: sem ele, apagar/atualizar a linha PAI
-- faz um seq scan na tabela FILHA para achar as linhas dependentes, e os JOINs
-- por essa coluna ficam lentos. As demais FKs do banco já têm índice
-- (idx_<tabela>_user_id); estas duas nasceram sem:
--
--   · magical_profiles.birth_chart_id → birth_charts(id) ON DELETE CASCADE
--       Sem o índice, corrigir a data de nascimento (que recria o mapa e
--       aciona o cascade no perfil mágico) varre magical_profiles inteira.
--   · ritual_logs.ritual_id → daily_rituals(id) ON DELETE CASCADE
--       Sem o índice, apagar um ritual diário varre ritual_logs inteira.
--
-- As tabelas são pequenas hoje (milissegundos), então CREATE INDEX comum
-- basta; se algum dia forem grandes, troque por CREATE INDEX CONCURRENTLY
-- (fora de transação) para não travar escrita.
CREATE INDEX IF NOT EXISTS idx_magical_profiles_birth_chart_id
  ON public.magical_profiles (birth_chart_id);

CREATE INDEX IF NOT EXISTS idx_ritual_logs_ritual_id
  ON public.ritual_logs (ritual_id);


-- ----------------------------------------------------------------------------
-- 2. ÍNDICE DUPLICADO EM daily_magical_weather
-- ----------------------------------------------------------------------------
-- A tabela tem DOIS índices únicos idênticos sobre (user_id, date):
--   · daily_magical_weather_user_id_date_key  ← respalda a CONSTRAINT UNIQUE
--   · daily_magical_weather_user_date_key      ← índice solto e redundante
-- Mantemos o que respalda a constraint (o app faz upsert onConflict
-- 'user_id,date', que depende dela) e derrubamos o solto. Índice duplicado só
-- custa: dobra o trabalho de escrita e o espaço, sem ganho de leitura.
--
-- Guarda de segurança: só derruba se NÃO for o índice de uma constraint
-- (constraint-backed index não se apaga com DROP INDEX). Conferido na
-- auditoria: 'daily_magical_weather_user_date_key' não respalda constraint.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_class i
      JOIN pg_namespace n ON n.oid = i.relnamespace
     WHERE i.relname = 'daily_magical_weather_user_date_key'
       AND n.nspname = 'public'
       AND NOT EXISTS (
         SELECT 1 FROM pg_constraint c WHERE c.conindid = i.oid
       )
  ) THEN
    EXECUTE 'DROP INDEX public.daily_magical_weather_user_date_key';
  END IF;
END $$;


-- ----------------------------------------------------------------------------
-- 3. profiles: ON DELETE CASCADE NA FK PARA auth.users
-- ----------------------------------------------------------------------------
-- Todas as 22 outras tabelas referenciam auth.users com ON DELETE CASCADE.
-- Só a profiles_id_fkey está como NO ACTION. Consequência:
--   · Apagar uma pessoa por auth.users (painel Supabase, ou uma futura Edge
--     Function de exclusão) FALHA enquanto a linha de profiles existir —
--     porque a Fk barra. Todas as outras tabelas somem no cascade; a profiles
--     fica travando a operação.
--   · Alinhar com o resto torna a exclusão por auth.users atômica e completa.
--
-- Seguro para quem já existe: só muda o que acontece QUANDO uma linha de
-- auth.users é apagada; não toca em nenhum dado atual. As 173 linhas de
-- profiles já apontam para auth.users válidos (nasceram do trigger em
-- auth.users), então a revalidação ao readicionar a FK é instantânea.
--
-- (A exclusão de conta pelo app continua apagando a linha de profiles
-- explicitamente — ver _deleteUserData; isto é a rede de segurança para a
-- exclusão feita pelo lado do Auth.)
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_id_fkey;
ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_id_fkey
  FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;

COMMIT;


-- ----------------------------------------------------------------------------
-- 4. (OPCIONAL) ÍNDICES NUNCA USADOS — descomente para limpar
-- ----------------------------------------------------------------------------
-- O advisor lista 14 índices que nunca foram usados (INFO). São todos
-- idx_<tabela>_updated_at mais dois de beta_codes. O servidor consulta por
-- user_id (linhasDoUsuario), nunca por updated_at, então eles só custam
-- escrita e espaço. Derrubá-los é seguro e reversível (é só recriar). Fica
-- comentado para você decidir — nada aqui roda sem você descomentar.
--
-- DROP INDEX IF EXISTS public.idx_dreams_updated_at;
-- DROP INDEX IF EXISTS public.idx_desires_updated_at;
-- DROP INDEX IF EXISTS public.idx_gratitudes_updated_at;
-- DROP INDEX IF EXISTS public.idx_affirmations_updated_at;
-- DROP INDEX IF EXISTS public.idx_daily_rituals_updated_at;
-- DROP INDEX IF EXISTS public.idx_ritual_logs_updated_at;
-- DROP INDEX IF EXISTS public.idx_sigils_updated_at;
-- DROP INDEX IF EXISTS public.idx_birth_charts_updated_at;
-- DROP INDEX IF EXISTS public.idx_magical_profiles_updated_at;
-- DROP INDEX IF EXISTS public.idx_rune_readings_updated_at;
-- DROP INDEX IF EXISTS public.idx_pendulum_updated_at;
-- DROP INDEX IF EXISTS public.idx_oracle_updated_at;
-- DROP INDEX IF EXISTS public.idx_beta_codes_created_at;
-- DROP INDEX IF EXISTS public.idx_beta_codes_available;


-- ============================================================================
-- 5. CONFERÊNCIA
-- ============================================================================
-- (a) Os dois índices de FK devem existir:
--   SELECT indexname FROM pg_indexes
--    WHERE schemaname='public'
--      AND indexname IN ('idx_magical_profiles_birth_chart_id',
--                        'idx_ritual_logs_ritual_id');
--
-- (b) daily_magical_weather deve ter só UM índice único de (user_id,date):
--   SELECT indexname FROM pg_indexes
--    WHERE schemaname='public' AND tablename='daily_magical_weather';
--
-- (c) profiles_id_fkey deve mostrar ON DELETE CASCADE:
--   SELECT pg_get_constraintdef(oid) FROM pg_constraint
--    WHERE conname='profiles_id_fkey';
-- ============================================================================
