-- Sincronização em nuvem das tiragens de Tarô.
-- Rode este script no SQL Editor do Supabase (uma vez).
--
-- Por que só agora: runas, pêndulo e oráculo sempre tiveram tabela própria,
-- e o tarô não — as tiragens só existiam na tela. Com a Leitura do Ciclo
-- lendo tudo que a pessoa registra, o tarô passou a ser registro de
-- verdade (tabela local `tarot_readings`, migração v22 do app), e sem esta
-- tabela na nuvem ele se perderia em toda reinstalação.
--
-- `signature` identifica a tiragem para reaproveitar a interpretação da IA
-- sem gastar cota de novo; `question` é opcional (nem toda tiragem nasce de
-- uma pergunta).

CREATE TABLE IF NOT EXISTS tarot_readings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  question TEXT,
  spread_type TEXT NOT NULL,
  signature TEXT,
  reading_data JSONB NOT NULL,
  date TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tarot_readings_user_id
  ON tarot_readings(user_id);

ALTER TABLE tarot_readings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own tarot readings"
  ON tarot_readings
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own tarot readings"
  ON tarot_readings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own tarot readings"
  ON tarot_readings
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own tarot readings"
  ON tarot_readings
  FOR DELETE USING (auth.uid() = user_id);
