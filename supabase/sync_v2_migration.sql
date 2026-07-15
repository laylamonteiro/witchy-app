-- Migração idempotente exigida pelo DataSyncService v2.
-- Preserva todas as tabelas e linhas existentes.

ALTER TABLE public.spells                 ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.dreams                 ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.desires                ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.gratitudes             ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.affirmations           ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.daily_rituals          ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.ritual_logs            ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.sigils                 ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.birth_charts           ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.magical_profiles       ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.rune_readings          ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.pendulum_consultations ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.oracle_readings        ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.daily_magical_weather  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

CREATE UNIQUE INDEX IF NOT EXISTS daily_magical_weather_user_date_key
  ON public.daily_magical_weather (user_id, date);

CREATE INDEX IF NOT EXISTS idx_spells_updated_at ON public.spells(updated_at);
CREATE INDEX IF NOT EXISTS idx_dreams_updated_at ON public.dreams(updated_at);
CREATE INDEX IF NOT EXISTS idx_desires_updated_at ON public.desires(updated_at);
CREATE INDEX IF NOT EXISTS idx_gratitudes_updated_at ON public.gratitudes(updated_at);
CREATE INDEX IF NOT EXISTS idx_affirmations_updated_at ON public.affirmations(updated_at);
CREATE INDEX IF NOT EXISTS idx_daily_rituals_updated_at ON public.daily_rituals(updated_at);
CREATE INDEX IF NOT EXISTS idx_ritual_logs_updated_at ON public.ritual_logs(updated_at);
CREATE INDEX IF NOT EXISTS idx_sigils_updated_at ON public.sigils(updated_at);
CREATE INDEX IF NOT EXISTS idx_birth_charts_updated_at ON public.birth_charts(updated_at);
CREATE INDEX IF NOT EXISTS idx_magical_profiles_updated_at ON public.magical_profiles(updated_at);
CREATE INDEX IF NOT EXISTS idx_rune_readings_updated_at ON public.rune_readings(updated_at);
CREATE INDEX IF NOT EXISTS idx_pendulum_updated_at ON public.pendulum_consultations(updated_at);
CREATE INDEX IF NOT EXISTS idx_oracle_updated_at ON public.oracle_readings(updated_at);
CREATE INDEX IF NOT EXISTS idx_weather_updated_at ON public.daily_magical_weather(updated_at);
