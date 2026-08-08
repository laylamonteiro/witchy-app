-- ============================================================================
-- CONSERTO: "Falha ao sincronizar: dailyCheckins"
-- ============================================================================
-- O app sobe o check-in do dia com upsert(onConflict: 'user_id,date') — isso
-- EXIGE a constraint UNIQUE(user_id, date) na tabela. Uma tabela criada por
-- versão antiga (sem a constraint, sem updated_at ou sem as políticas RLS)
-- faz a LEITURA funcionar e TODA escrita falhar, que é exatamente o sintoma
-- dos logs (auto-sync pós-login "ok", uploads seguintes sempre falhando).
--
-- Rode este arquivo inteiro no SQL Editor do Supabase. É idempotente:
-- pode rodar mais de uma vez sem efeito colateral.
-- ============================================================================

-- 1. A tabela (caso nem exista ainda)
CREATE TABLE IF NOT EXISTS daily_checkins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  date DATE NOT NULL,
  rites TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- 2. Colunas que versões antigas não tinham
ALTER TABLE daily_checkins ADD COLUMN IF NOT EXISTS rites TEXT NOT NULL DEFAULT '';
ALTER TABLE daily_checkins ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- 3. A UNIQUE(user_id, date) numa tabela que nasceu sem ela.
--    Antes, remove duplicatas do mesmo dia (senão o ALTER falha).
DELETE FROM daily_checkins a
USING daily_checkins b
WHERE a.user_id = b.user_id
  AND a.date = b.date
  AND a.ctid < b.ctid;

DO $$
BEGIN
  ALTER TABLE daily_checkins
    ADD CONSTRAINT daily_checkins_user_id_date_key UNIQUE (user_id, date);
EXCEPTION
  WHEN duplicate_object THEN NULL; -- já existe: nada a fazer
  WHEN duplicate_table  THEN NULL; -- (nome do índice já usado)
END $$;

-- 4. RLS + políticas (mesmos nomes do create_user_policy do restore)
ALTER TABLE daily_checkins ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own daily_checkins"   ON daily_checkins;
DROP POLICY IF EXISTS "Users can insert own daily_checkins" ON daily_checkins;
DROP POLICY IF EXISTS "Users can update own daily_checkins" ON daily_checkins;
DROP POLICY IF EXISTS "Users can delete own daily_checkins" ON daily_checkins;

CREATE POLICY "Users can view own daily_checkins"   ON daily_checkins FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own daily_checkins" ON daily_checkins FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own daily_checkins" ON daily_checkins FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own daily_checkins" ON daily_checkins FOR DELETE USING (auth.uid() = user_id);

-- 5. Índice de consulta por usuário
CREATE INDEX IF NOT EXISTS idx_daily_checkins_user_id ON daily_checkins(user_id);

-- 6. PostgREST recarrega o schema na hora (sem isto o erro persiste até o
--    servidor reiniciar, mesmo com o banco já correto)
NOTIFY pgrst, 'reload schema';
