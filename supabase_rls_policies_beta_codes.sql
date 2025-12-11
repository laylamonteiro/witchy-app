-- ============================================================
-- POLÍTICAS RLS PARA TABELA beta_codes
-- ============================================================
-- Execute este script no Supabase SQL Editor DEPOIS de criar a tabela
-- com o script supabase_beta_codes_schema.sql
-- ============================================================
-- IMPORTANTE: Este script permite acesso ANÔNIMO (sem autenticação)
-- porque os códigos beta são compartilhados e não específicos de usuário.
-- O app atual não implementa autenticação Supabase, apenas local.
-- ============================================================

-- 1. HABILITAR RLS na tabela
ALTER TABLE beta_codes ENABLE ROW LEVEL SECURITY;

-- 2. REMOVER todas as políticas antigas (idempotência)
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

-- ============================================================
-- POLÍTICAS DE SEGURANÇA (ACESSO ANÔNIMO)
-- ============================================================

-- POLÍTICA 1: Permitir SELECT anônimo
-- Necessário para verificar se código existe e se está disponível
CREATE POLICY "Permitir acesso anônimo para SELECT"
ON beta_codes
FOR SELECT
TO anon, authenticated
USING (true);

-- POLÍTICA 2: Permitir INSERT anônimo
-- Permite criar códigos beta sem autenticação
-- ⚠️ Em produção, considere restringir isso ou criar Edge Function
CREATE POLICY "Permitir acesso anônimo para INSERT"
ON beta_codes
FOR INSERT
TO anon, authenticated
WITH CHECK (true);

-- POLÍTICA 3: Permitir UPDATE anônimo
-- Permite resgatar códigos (marcar como usado)
-- A validação de regras de negócio (se código já foi usado)
-- é feita no app, não no RLS
CREATE POLICY "Permitir acesso anônimo para UPDATE"
ON beta_codes
FOR UPDATE
TO anon, authenticated
USING (true)
WITH CHECK (true);

-- POLÍTICA 4: Permitir DELETE anônimo
-- Permite deletar códigos inválidos ou expirados
-- ⚠️ Em produção, considere restringir isso apenas para admins
CREATE POLICY "Permitir acesso anônimo para DELETE"
ON beta_codes
FOR DELETE
TO anon, authenticated
USING (true);

-- ============================================================
-- VERIFICAÇÃO
-- ============================================================
-- Execute para verificar as políticas criadas:
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
-- FROM pg_policies
-- WHERE tablename = 'beta_codes';

-- ============================================================
-- NOTAS DE SEGURANÇA
-- ============================================================
-- 1. Este setup permite acesso público total à tabela beta_codes
-- 2. Isso é aceitável porque:
--    - Códigos beta são compartilhados (não dados sensíveis de usuário)
--    - A lógica de validação (código já usado, etc.) está no app
--    - O app atual não implementa autenticação Supabase
-- 3. MELHORIAS FUTURAS (opcional):
--    - Implementar autenticação Supabase no app
--    - Criar Edge Function para criar códigos (restringir INSERT)
--    - Adicionar rate limiting no Supabase
--    - Adicionar validações adicionais nas políticas RLS
-- ============================================================
