-- Sincronização em nuvem das entradas pessoais da Enciclopédia (foto + IA).
-- Rode este script no SQL Editor do Supabase (uma vez).
--
-- Observações:
-- - `image_path` guarda a referência da foto no bucket privado `user-images`
--   (`supabase://{uid}/{herbs|crystals}/{id}.jpg`, ver
--   storage_user_images_migration.sql) — a foto sincroniza entre aparelhos.
--   Linhas antigas do celular ainda podem trazer um caminho LOCAL
--   (`/data/...`): o app sobe essas fotos no próximo sync bem-sucedido e
--   troca a referência; até lá, mostra o ícone da categoria em outro aparelho
-- - `data` é o verbete completo gerado pela IA (jsonb)

CREATE TABLE IF NOT EXISTS user_encyclopedia_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  category TEXT NOT NULL,
  name TEXT NOT NULL,
  image_path TEXT,
  data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_ency_entries_user_id
  ON user_encyclopedia_entries(user_id);

ALTER TABLE user_encyclopedia_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own encyclopedia entries"
  ON user_encyclopedia_entries
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own encyclopedia entries"
  ON user_encyclopedia_entries
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own encyclopedia entries"
  ON user_encyclopedia_entries
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own encyclopedia entries"
  ON user_encyclopedia_entries
  FOR DELETE USING (auth.uid() = user_id);
