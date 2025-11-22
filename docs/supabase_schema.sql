-- Schema do Supabase para Grimório de Bolso
-- Execute este SQL no Supabase SQL Editor

-- Habilitar extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabela de perfis de usuário
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

-- Tabela de feitiços
CREATE TABLE IF NOT EXISTS spells (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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

-- Tabela de sonhos
CREATE TABLE IF NOT EXISTS dreams (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  tags TEXT,
  feeling TEXT,
  date TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de desejos
CREATE TABLE IF NOT EXISTS desires (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  status TEXT NOT NULL,
  evolution TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de gratidões
CREATE TABLE IF NOT EXISTS gratitudes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  tags TEXT,
  date TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de afirmações
CREATE TABLE IF NOT EXISTS affirmations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  text TEXT NOT NULL,
  category TEXT NOT NULL,
  is_preloaded BOOLEAN DEFAULT FALSE,
  is_favorite BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de rituais diários
CREATE TABLE IF NOT EXISTS daily_rituals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  time TEXT NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de logs de rituais
CREATE TABLE IF NOT EXISTS ritual_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  ritual_id UUID REFERENCES daily_rituals(id) ON DELETE CASCADE NOT NULL,
  notes TEXT,
  completed_at TIMESTAMPTZ NOT NULL
);

-- Tabela de sigilos
CREATE TABLE IF NOT EXISTS sigils (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  intention TEXT NOT NULL,
  image_path TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de mapas astrais
CREATE TABLE IF NOT EXISTS birth_charts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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

-- Tabela de perfis mágicos
CREATE TABLE IF NOT EXISTS magical_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  birth_chart_id UUID REFERENCES birth_charts(id) ON DELETE CASCADE NOT NULL,
  profile_data JSONB NOT NULL,
  generated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de leituras de runas
CREATE TABLE IF NOT EXISTS rune_readings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  question TEXT NOT NULL,
  spread_type TEXT NOT NULL,
  reading_data JSONB NOT NULL,
  date TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de consultas ao pêndulo
CREATE TABLE IF NOT EXISTS pendulum_consultations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  date TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de leituras de oracle
CREATE TABLE IF NOT EXISTS oracle_readings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  spread_type TEXT NOT NULL,
  reading_data JSONB NOT NULL,
  date TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de clima mágico diário
CREATE TABLE IF NOT EXISTS daily_magical_weather (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  date DATE NOT NULL,
  ai_generated_text TEXT NOT NULL,
  weather_data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_spells_user_id ON spells(user_id);
CREATE INDEX IF NOT EXISTS idx_dreams_user_id ON dreams(user_id);
CREATE INDEX IF NOT EXISTS idx_desires_user_id ON desires(user_id);
CREATE INDEX IF NOT EXISTS idx_gratitudes_user_id ON gratitudes(user_id);
CREATE INDEX IF NOT EXISTS idx_affirmations_user_id ON affirmations(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_rituals_user_id ON daily_rituals(user_id);
CREATE INDEX IF NOT EXISTS idx_ritual_logs_user_id ON ritual_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_sigils_user_id ON sigils(user_id);
CREATE INDEX IF NOT EXISTS idx_birth_charts_user_id ON birth_charts(user_id);
CREATE INDEX IF NOT EXISTS idx_magical_profiles_user_id ON magical_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_rune_readings_user_id ON rune_readings(user_id);
CREATE INDEX IF NOT EXISTS idx_pendulum_user_id ON pendulum_consultations(user_id);
CREATE INDEX IF NOT EXISTS idx_oracle_readings_user_id ON oracle_readings(user_id);
CREATE INDEX IF NOT EXISTS idx_weather_user_id ON daily_magical_weather(user_id);

-- Row Level Security (RLS) - Cada usuário só vê seus próprios dados

-- Habilitar RLS em todas as tabelas
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE spells ENABLE ROW LEVEL SECURITY;
ALTER TABLE dreams ENABLE ROW LEVEL SECURITY;
ALTER TABLE desires ENABLE ROW LEVEL SECURITY;
ALTER TABLE gratitudes ENABLE ROW LEVEL SECURITY;
ALTER TABLE affirmations ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_rituals ENABLE ROW LEVEL SECURITY;
ALTER TABLE ritual_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE sigils ENABLE ROW LEVEL SECURITY;
ALTER TABLE birth_charts ENABLE ROW LEVEL SECURITY;
ALTER TABLE magical_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE rune_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE pendulum_consultations ENABLE ROW LEVEL SECURITY;
ALTER TABLE oracle_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_magical_weather ENABLE ROW LEVEL SECURITY;

-- Políticas RLS para profiles
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Função para criar política de usuário padrão
CREATE OR REPLACE FUNCTION create_user_policy(table_name TEXT) RETURNS VOID AS $$
BEGIN
  EXECUTE format('CREATE POLICY "Users can view own %I" ON %I FOR SELECT USING (auth.uid() = user_id)', table_name, table_name);
  EXECUTE format('CREATE POLICY "Users can insert own %I" ON %I FOR INSERT WITH CHECK (auth.uid() = user_id)', table_name, table_name);
  EXECUTE format('CREATE POLICY "Users can update own %I" ON %I FOR UPDATE USING (auth.uid() = user_id)', table_name, table_name);
  EXECUTE format('CREATE POLICY "Users can delete own %I" ON %I FOR DELETE USING (auth.uid() = user_id)', table_name, table_name);
END;
$$ LANGUAGE plpgsql;

-- Aplicar políticas em todas as tabelas de dados
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

-- Trigger para criar perfil automaticamente quando usuário se registra
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
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Criar trigger se não existir
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Função para resetar contadores diários (executar via cron)
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

-- Função para resetar contadores mensais (executar via cron)
CREATE OR REPLACE FUNCTION reset_monthly_counters()
RETURNS VOID AS $$
BEGIN
  UPDATE profiles SET
    diary_entries_this_month = 0,
    updated_at = NOW();
END;
$$ LANGUAGE plpgsql;
