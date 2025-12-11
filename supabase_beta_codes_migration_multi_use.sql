-- ============================================================
-- MIGRAÇÃO: Adicionar suporte a múltiplos usos nos códigos beta
-- ============================================================
-- Execute este script no Supabase SQL Editor para atualizar
-- a tabela beta_codes existente
-- ============================================================

-- 1. ADICIONAR novos campos
ALTER TABLE beta_codes
  ADD COLUMN IF NOT EXISTS max_uses INTEGER NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS current_uses INTEGER NOT NULL DEFAULT 0;

-- 2. MIGRAR dados existentes
-- Códigos já usados (is_used = true) devem ter current_uses = 1
UPDATE beta_codes
SET current_uses = 1, max_uses = 1
WHERE is_used = true AND current_uses = 0;

-- Códigos não usados mantêm max_uses = 1 e current_uses = 0
UPDATE beta_codes
SET max_uses = 1, current_uses = 0
WHERE is_used = false AND current_uses = 0;

-- 3. ADICIONAR comentários aos novos campos
COMMENT ON COLUMN beta_codes.max_uses IS 'Número máximo de usos permitidos (1 = uso único, >1 = múltiplos usos)';
COMMENT ON COLUMN beta_codes.current_uses IS 'Contador de quantas vezes o código já foi usado';

-- 4. CRIAR índice para consultas por disponibilidade
CREATE INDEX IF NOT EXISTS idx_beta_codes_available ON beta_codes(current_uses, max_uses)
WHERE current_uses < max_uses;

-- ============================================================
-- VERIFICAÇÃO
-- ============================================================
-- Execute para verificar os dados migrados:
-- SELECT code, is_used, current_uses, max_uses,
--        (current_uses < max_uses) as disponivel
-- FROM beta_codes
-- ORDER BY created_at DESC;
-- ============================================================
