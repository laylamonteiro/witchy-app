-- ============================================================
-- SCHEMA DA TABELA beta_codes PARA SUPABASE
-- ============================================================
-- Execute este script no Supabase SQL Editor ANTES das políticas RLS
-- ============================================================

-- 1. CRIAR TABELA beta_codes
-- Esta tabela armazena códigos beta que concedem acesso Premium vitalício
CREATE TABLE IF NOT EXISTS beta_codes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code TEXT NOT NULL UNIQUE,
  is_used BOOLEAN NOT NULL DEFAULT false,
  used_by TEXT,  -- Armazena ID do usuário que usou o código
  used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. CRIAR ÍNDICES para melhor performance
CREATE INDEX IF NOT EXISTS idx_beta_codes_code ON beta_codes(code);
CREATE INDEX IF NOT EXISTS idx_beta_codes_is_used ON beta_codes(is_used);
CREATE INDEX IF NOT EXISTS idx_beta_codes_created_at ON beta_codes(created_at DESC);

-- 3. COMENTÁRIOS da tabela
COMMENT ON TABLE beta_codes IS 'Códigos beta que concedem acesso Premium vitalício aos usuários';
COMMENT ON COLUMN beta_codes.id IS 'Identificador único do código';
COMMENT ON COLUMN beta_codes.code IS 'Código beta em formato texto (ex: BETA2025)';
COMMENT ON COLUMN beta_codes.is_used IS 'Indica se o código já foi resgatado';
COMMENT ON COLUMN beta_codes.used_by IS 'ID do usuário que resgatou o código';
COMMENT ON COLUMN beta_codes.used_at IS 'Data/hora em que o código foi resgatado';
COMMENT ON COLUMN beta_codes.created_at IS 'Data/hora de criação do código';

-- 4. VERIFICAÇÃO
-- Execute para verificar se a tabela foi criada corretamente:
-- SELECT * FROM beta_codes;
