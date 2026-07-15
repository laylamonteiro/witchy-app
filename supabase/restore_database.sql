-- ============================================================================
-- GRIMÓRIO DE BOLSO — SCRIPT ÚNICO DE RESTAURAÇÃO DO BANCO SUPABASE
-- ============================================================================
-- Uso: crie um projeto novo no Supabase e execute este arquivo INTEIRO no
-- SQL Editor (Database → SQL Editor → New query → colar → Run).
--
-- O script é IDEMPOTENTE: pode ser executado mais de uma vez sem erro e sem
-- perder dados (CREATE IF NOT EXISTS / ADD COLUMN IF NOT EXISTS /
-- DROP POLICY IF EXISTS antes de cada CREATE POLICY).
--
-- Conteúdo:
--   1. Extensões
--   2. Tabelas de dados sincronizados (16 tabelas — ver SupabaseTables em
--      lib/core/config/supabase_config.dart)
--   3. Coluna updated_at em TODAS as tabelas de sync (exigida pelo
--      DataSyncService para resolução de conflitos — o schema antigo em
--      docs/supabase_schema.sql só tinha em profiles/spells/desires, o que
--      quebrava o upsert das demais)
--   4. Índices
--   5. Row Level Security (RLS)
--   6. Trigger de criação automática de profile no signup
--   7. Tabela beta_codes + RLS anônimo + RPC atômica redeem_beta_code
--   8. Funções de reset de contadores (agendar via cron do Supabase)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. EXTENSÕES
-- ----------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ----------------------------------------------------------------------------
-- 2. TABELAS PRINCIPAIS
-- ----------------------------------------------------------------------------

-- Perfis de usuário (1:1 com auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT,
  display_name TEXT,
  photo_url TEXT,
  birth_date TIMESTAMPTZ,
  birth_time TEXT,
  birth_place TEXT,
  role TEXT DEFAULT 'free' CHECK (role IN ('free', 'premium', 'admin')),
  plan TEXT DEFAULT 'free' CHECK (plan IN ('free', 'monthly', 'yearly', 'lifetime')),
  spells_count INTEGER DEFAULT 0,
  diary_entries_this_month INTEGER DEFAULT 0,
  ai_consultations_today INTEGER DEFAULT 0,
  pendulum_uses_today INTEGER DEFAULT 0,
  affirmations_today INTEGER DEFAULT 0,
  rune_readings_today INTEGER DEFAULT 0,
  oracle_readings_today INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Feitiços
CREATE TABLE IF NOT EXISTS spells (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  purpose TEXT NOT NULL,
  type TEXT NOT NULL,
  category TEXT NOT NULL,
  moon_phase TEXT,
  ingredients TEXT,
  steps TEXT NOT NULL,
  duration INTEGER,
  observations TEXT,
  is_preloaded BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sonhos
CREATE TABLE IF NOT EXISTS dreams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  tags TEXT,
  feeling TEXT,
  date TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Desejos
CREATE TABLE IF NOT EXISTS desires (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  status TEXT NOT NULL,
  evolution TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Gratidões
CREATE TABLE IF NOT EXISTS gratitudes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  tags TEXT,
  date TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Afirmações
CREATE TABLE IF NOT EXISTS affirmations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  text TEXT NOT NULL,
  category TEXT NOT NULL,
  is_preloaded BOOLEAN DEFAULT FALSE,
  is_favorite BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Rituais diários
CREATE TABLE IF NOT EXISTS daily_rituals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  time TEXT NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Logs de rituais
CREATE TABLE IF NOT EXISTS ritual_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  ritual_id UUID REFERENCES daily_rituals(id) ON DELETE CASCADE NOT NULL,
  notes TEXT,
  completed_at TIMESTAMPTZ NOT NULL
);

-- Sigilos
CREATE TABLE IF NOT EXISTS sigils (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  intention TEXT NOT NULL,
  image_path TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Mapas astrais
CREATE TABLE IF NOT EXISTS birth_charts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  birth_date TIMESTAMPTZ NOT NULL,
  birth_time_hour INTEGER NOT NULL,
  birth_time_minute INTEGER NOT NULL,
  birth_place TEXT NOT NULL,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  timezone TEXT NOT NULL,
  unknown_birth_time BOOLEAN DEFAULT FALSE,
  chart_data JSONB NOT NULL,
  calculated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Perfis mágicos
CREATE TABLE IF NOT EXISTS magical_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  birth_chart_id UUID REFERENCES birth_charts(id) ON DELETE CASCADE NOT NULL,
  profile_data JSONB NOT NULL,
  generated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Leituras de runas
CREATE TABLE IF NOT EXISTS rune_readings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  question TEXT NOT NULL,
  spread_type TEXT NOT NULL,
  reading_data JSONB NOT NULL,
  date TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Consultas ao pêndulo
CREATE TABLE IF NOT EXISTS pendulum_consultations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  date TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Leituras de oráculo
CREATE TABLE IF NOT EXISTS oracle_readings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  spread_type TEXT NOT NULL,
  reading_data JSONB NOT NULL,
  date TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Clima mágico diário
CREATE TABLE IF NOT EXISTS daily_magical_weather (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  date DATE NOT NULL,
  ai_generated_text TEXT NOT NULL,
  weather_data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- ----------------------------------------------------------------------------
-- 3. COLUNA updated_at EM TODAS AS TABELAS DE SYNC
-- ----------------------------------------------------------------------------
-- O DataSyncService (lib/core/services/data_sync_service.dart) envia
-- `updated_at` em TODO upsert e usa a coluna na resolução de conflitos.
-- Sem ela o PostgREST rejeita o upsert ("column not found in schema cache").
ALTER TABLE dreams                 ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE gratitudes             ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE affirmations           ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE daily_rituals          ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE ritual_logs            ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE sigils                 ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE birth_charts           ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE magical_profiles       ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE rune_readings          ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE pendulum_consultations ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE oracle_readings        ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE daily_magical_weather  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- ----------------------------------------------------------------------------
-- 4. ÍNDICES
-- ----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_spells_user_id            ON spells(user_id);
CREATE INDEX IF NOT EXISTS idx_dreams_user_id            ON dreams(user_id);
CREATE INDEX IF NOT EXISTS idx_desires_user_id           ON desires(user_id);
CREATE INDEX IF NOT EXISTS idx_gratitudes_user_id        ON gratitudes(user_id);
CREATE INDEX IF NOT EXISTS idx_affirmations_user_id      ON affirmations(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_rituals_user_id     ON daily_rituals(user_id);
CREATE INDEX IF NOT EXISTS idx_ritual_logs_user_id       ON ritual_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_sigils_user_id            ON sigils(user_id);
CREATE INDEX IF NOT EXISTS idx_birth_charts_user_id      ON birth_charts(user_id);
CREATE INDEX IF NOT EXISTS idx_magical_profiles_user_id  ON magical_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_rune_readings_user_id     ON rune_readings(user_id);
CREATE INDEX IF NOT EXISTS idx_pendulum_user_id          ON pendulum_consultations(user_id);
CREATE INDEX IF NOT EXISTS idx_oracle_readings_user_id   ON oracle_readings(user_id);
CREATE INDEX IF NOT EXISTS idx_weather_user_id           ON daily_magical_weather(user_id);

-- ----------------------------------------------------------------------------
-- 5. ROW LEVEL SECURITY — cada usuário só acessa os próprios dados
-- ----------------------------------------------------------------------------
ALTER TABLE profiles               ENABLE ROW LEVEL SECURITY;
ALTER TABLE spells                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE dreams                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE desires                ENABLE ROW LEVEL SECURITY;
ALTER TABLE gratitudes             ENABLE ROW LEVEL SECURITY;
ALTER TABLE affirmations           ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_rituals          ENABLE ROW LEVEL SECURITY;
ALTER TABLE ritual_logs            ENABLE ROW LEVEL SECURITY;
ALTER TABLE sigils                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE birth_charts           ENABLE ROW LEVEL SECURITY;
ALTER TABLE magical_profiles       ENABLE ROW LEVEL SECURITY;
ALTER TABLE rune_readings          ENABLE ROW LEVEL SECURITY;
ALTER TABLE pendulum_consultations ENABLE ROW LEVEL SECURITY;
ALTER TABLE oracle_readings        ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_magical_weather  ENABLE ROW LEVEL SECURITY;

-- Políticas de profiles (id = auth.uid())
DROP POLICY IF EXISTS "Users can view own profile"   ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
CREATE POLICY "Users can view own profile"   ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Função utilitária: cria as 4 políticas padrão (user_id = auth.uid())
-- de forma idempotente para uma tabela de dados.
CREATE OR REPLACE FUNCTION create_user_policy(table_name TEXT) RETURNS VOID AS $$
BEGIN
  EXECUTE format('DROP POLICY IF EXISTS "Users can view own %I" ON %I', table_name, table_name);
  EXECUTE format('DROP POLICY IF EXISTS "Users can insert own %I" ON %I', table_name, table_name);
  EXECUTE format('DROP POLICY IF EXISTS "Users can update own %I" ON %I', table_name, table_name);
  EXECUTE format('DROP POLICY IF EXISTS "Users can delete own %I" ON %I', table_name, table_name);
  EXECUTE format('CREATE POLICY "Users can view own %I" ON %I FOR SELECT USING (auth.uid() = user_id)', table_name, table_name);
  EXECUTE format('CREATE POLICY "Users can insert own %I" ON %I FOR INSERT WITH CHECK (auth.uid() = user_id)', table_name, table_name);
  EXECUTE format('CREATE POLICY "Users can update own %I" ON %I FOR UPDATE USING (auth.uid() = user_id)', table_name, table_name);
  EXECUTE format('CREATE POLICY "Users can delete own %I" ON %I FOR DELETE USING (auth.uid() = user_id)', table_name, table_name);
END;
$$ LANGUAGE plpgsql;

SELECT create_user_policy('spells');
SELECT create_user_policy('dreams');
SELECT create_user_policy('desires');
SELECT create_user_policy('gratitudes');
SELECT create_user_policy('affirmations');
SELECT create_user_policy('daily_rituals');
SELECT create_user_policy('ritual_logs');
SELECT create_user_policy('sigils');
SELECT create_user_policy('birth_charts');
SELECT create_user_policy('magical_profiles');
SELECT create_user_policy('rune_readings');
SELECT create_user_policy('pendulum_consultations');
SELECT create_user_policy('oracle_readings');
SELECT create_user_policy('daily_magical_weather');

-- ----------------------------------------------------------------------------
-- 6. TRIGGER: cria profile automaticamente no signup
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'display_name',
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ----------------------------------------------------------------------------
-- 7. BETA CODES — tabela, RLS anônimo e RPC atômica de resgate
-- ----------------------------------------------------------------------------
-- Já na versão final multi-uso (max_uses/current_uses). O app acessa esta
-- tabela com a anon key SEM login Supabase, por isso as políticas liberam
-- anon (decisão documentada em SUPABASE_BETA_CODES_SETUP.md).
CREATE TABLE IF NOT EXISTS beta_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  is_used BOOLEAN NOT NULL DEFAULT false,
  used_by TEXT,
  used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  max_uses INTEGER NOT NULL DEFAULT 1,
  current_uses INTEGER NOT NULL DEFAULT 0
);

-- Migração para projetos antigos (pré multi-uso)
ALTER TABLE beta_codes
  ADD COLUMN IF NOT EXISTS max_uses INTEGER NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS current_uses INTEGER NOT NULL DEFAULT 0;
UPDATE beta_codes SET current_uses = 1 WHERE is_used = true AND current_uses = 0;

CREATE INDEX IF NOT EXISTS idx_beta_codes_code       ON beta_codes(code);
CREATE INDEX IF NOT EXISTS idx_beta_codes_is_used    ON beta_codes(is_used);
CREATE INDEX IF NOT EXISTS idx_beta_codes_created_at ON beta_codes(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_beta_codes_available  ON beta_codes(current_uses, max_uses)
  WHERE current_uses < max_uses;

ALTER TABLE beta_codes ENABLE ROW LEVEL SECURITY;

-- Remover políticas antigas (todas as variações históricas)
DROP POLICY IF EXISTS "temp_allow_all" ON beta_codes;
DROP POLICY IF EXISTS "Admins podem criar códigos" ON beta_codes;
DROP POLICY IF EXISTS "Usuários podem ler códigos" ON beta_codes;
DROP POLICY IF EXISTS "Usuarios podem ler codigos" ON beta_codes;
DROP POLICY IF EXISTS "Usuários podem resgatar códigos disponíveis" ON beta_codes;
DROP POLICY IF EXISTS "Usuarios podem resgatar codigos disponiveis" ON beta_codes;
DROP POLICY IF EXISTS "Admins podem deletar códigos" ON beta_codes;
DROP POLICY IF EXISTS "Permitir acesso anônimo para SELECT" ON beta_codes;
DROP POLICY IF EXISTS "Permitir acesso anônimo para INSERT" ON beta_codes;
DROP POLICY IF EXISTS "Permitir acesso anônimo para UPDATE" ON beta_codes;
DROP POLICY IF EXISTS "Permitir acesso anônimo para DELETE" ON beta_codes;

CREATE POLICY "Permitir acesso anônimo para SELECT" ON beta_codes
  FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Permitir acesso anônimo para INSERT" ON beta_codes
  FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "Permitir acesso anônimo para UPDATE" ON beta_codes
  FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Permitir acesso anônimo para DELETE" ON beta_codes
  FOR DELETE TO anon, authenticated USING (true);

-- RPC atômica de resgate: elimina a condição de corrida do fluxo antigo
-- (read + update no cliente). O UPDATE condicional roda em uma única
-- transação no servidor; dois resgates simultâneos do mesmo código de uso
-- único nunca passam os dois.
CREATE OR REPLACE FUNCTION public.redeem_beta_code(p_code TEXT, p_user_id TEXT)
RETURNS JSONB AS $$
DECLARE
  v_row beta_codes%ROWTYPE;
  v_remaining INTEGER;
BEGIN
  UPDATE beta_codes
     SET current_uses = current_uses + 1,
         is_used      = (current_uses + 1 >= max_uses),
         used_by      = p_user_id,
         used_at      = NOW()
   WHERE code = UPPER(TRIM(p_code))
     AND is_used = false
     AND current_uses < max_uses
  RETURNING * INTO v_row;

  IF NOT FOUND THEN
    -- Distinguir "não existe" de "já usado/invalidado"
    IF EXISTS (SELECT 1 FROM beta_codes WHERE code = UPPER(TRIM(p_code))) THEN
      RETURN jsonb_build_object(
        'success', false,
        'message', 'Este código já foi utilizado'
      );
    END IF;
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Código inválido'
    );
  END IF;

  -- Persiste o premium no perfil do usuário, MAS somente quando p_user_id é
  -- um UUID de conta Supabase. Usuários anônimos/locais (ex.: 'local_user')
  -- também podem resgatar códigos — sem este guard, o cast ::uuid lançaria
  -- exceção e reverteria a transação inteira, quebrando o resgate anônimo.
  IF p_user_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN
    UPDATE public.profiles
       SET role       = 'premium',
           plan       = 'lifetime',
           updated_at = NOW()
     WHERE id = p_user_id::uuid;
  END IF;

  v_remaining := v_row.max_uses - v_row.current_uses;
  RETURN jsonb_build_object(
    'success', true,
    'message', CASE
      WHEN v_remaining > 0 THEN
        'Código resgatado! Você agora tem acesso Premium vitalício 🎉' ||
        E'\n(Restam ' || v_remaining || ' uso' ||
        CASE WHEN v_remaining > 1 THEN 's' ELSE '' END || ' deste código)'
      ELSE
        'Código resgatado! Você agora tem acesso Premium vitalício 🎉'
    END,
    'current_uses', v_row.current_uses,
    'max_uses', v_row.max_uses
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- O app chama a RPC com a anon key
-- Reexecute este script no Supabase após alterações nesta função.
-- CREATE OR REPLACE torna a atualização idempotente.
GRANT EXECUTE ON FUNCTION public.redeem_beta_code(TEXT, TEXT) TO anon, authenticated;

-- ----------------------------------------------------------------------------
-- 8. FUNÇÕES DE RESET DE CONTADORES (agendar no cron do Supabase)
-- ----------------------------------------------------------------------------
-- Diário (agendar 00:00 America/Sao_Paulo → '0 3 * * *' UTC)
CREATE OR REPLACE FUNCTION reset_daily_counters()
RETURNS VOID AS $$
BEGIN
  UPDATE profiles SET
    ai_consultations_today = 0,
    pendulum_uses_today = 0,
    affirmations_today = 0,
    rune_readings_today = 0,
    oracle_readings_today = 0,
    updated_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- Mensal (agendar dia 1 de cada mês → '0 3 1 * *' UTC)
CREATE OR REPLACE FUNCTION reset_monthly_counters()
RETURNS VOID AS $$
BEGIN
  UPDATE profiles SET
    diary_entries_this_month = 0,
    updated_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- VERIFICAÇÃO RÁPIDA (opcional — rode após o script)
-- ============================================================================
-- SELECT table_name FROM information_schema.tables
--   WHERE table_schema = 'public' ORDER BY table_name;
-- SELECT column_name FROM information_schema.columns
--   WHERE table_name = 'dreams' AND column_name = 'updated_at';
-- SELECT proname FROM pg_proc WHERE proname = 'redeem_beta_code';
-- SELECT policyname, cmd FROM pg_policies WHERE tablename = 'beta_codes';
-- ============================================================================
