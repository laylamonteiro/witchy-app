-- Sincronização em nuvem das Leituras do Ciclo (compra avulsa).
-- Rode este script no SQL Editor do Supabase (uma vez).
--
-- Observações:
-- - Cada linha é o registro de UM crédito de leitura e o período coberto por
--   ele. O relatório em si vive em `free_writings`
--   (source = 'cycle_reading'), referenciado por `writing_id`.
-- - `status` = 'pending' enquanto a compra ainda não virou relatório salvo:
--   falha de geração NÃO consome a compra (o app tenta de novo sem cobrar).
-- - `origin` = 'purchase' (consumível comprado na loja) ou 'lifetime' (a
--   Leitura da Lunação inclusa na compra vitalícia; nesse caso
--   `product_id` fica nulo). Assinar Premium NÃO dá leitura — só o
--   Vitalício, e só a lunação.

CREATE TABLE IF NOT EXISTS cycle_readings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  period_type TEXT NOT NULL DEFAULT 'lunation',
  period_start TIMESTAMPTZ NOT NULL,
  period_end TIMESTAMPTZ NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  origin TEXT NOT NULL DEFAULT 'purchase',
  product_id TEXT,
  writing_id UUID,
  regenerations_used INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_cycle_readings_user_id
  ON cycle_readings(user_id);

ALTER TABLE cycle_readings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own cycle readings"
  ON cycle_readings
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own cycle readings"
  ON cycle_readings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own cycle readings"
  ON cycle_readings
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own cycle readings"
  ON cycle_readings
  FOR DELETE USING (auth.uid() = user_id);
