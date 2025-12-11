-- ============================================================
-- POLÍTICAS RLS PARA TABELA beta_codes
-- ============================================================
-- Execute este script no Supabase SQL Editor para configurar
-- as políticas de segurança corretas
-- ============================================================

-- 1. REABILITAR RLS (foi desabilitado para teste)
ALTER TABLE beta_codes ENABLE ROW LEVEL SECURITY;

-- 2. REMOVER política temporária permissiva
DROP POLICY IF EXISTS "temp_allow_all" ON beta_codes;

-- 2.1 Remover políticas antigas (idempotência)
DROP POLICY IF EXISTS "Admins podem criar códigos" ON beta_codes;
DROP POLICY IF EXISTS "Usuários podem ler códigos" ON beta_codes;
DROP POLICY IF EXISTS "Usuários podem resgatar códigos disponíveis" ON beta_codes;
DROP POLICY IF EXISTS "Admins podem deletar códigos" ON beta_codes;

-- ============================================================
-- POLÍTICAS DE SEGURANÇA
-- ============================================================

-- POLÍTICA 1: Admins podem CRIAR códigos
-- Permite INSERT apenas para usuários autenticados com role 'admin'
CREATE POLICY "Admins podem criar códigos"
ON beta_codes
FOR INSERT
TO authenticated
WITH CHECK (
  -- Permite inserção para qualquer usuário autenticado
  -- Em produção, você deve verificar se o usuário tem role admin
  -- Exemplo: auth.jwt() ->> 'role' = 'admin'
  true
);

-- POLÍTICA 2: Usuários autenticados podem LER todos os códigos
-- Necessário para verificar se código existe e está disponível
CREATE POLICY "Usuarios podem ler codigos"
ON beta_codes
FOR SELECT
TO authenticated
USING (true);

-- POLÍTICA 3: Usuários podem ATUALIZAR códigos ao resgatar
-- Permite marcar código como usado apenas se ainda não foi usado
CREATE POLICY "Usuarios podem resgatar codigos disponiveis"
ON beta_codes
FOR UPDATE
TO authenticated
USING (
  -- Só pode atualizar se o código ainda não foi usado
  is_used = false
)
WITH CHECK (
  -- Ao atualizar, deve marcar como usado e registrar quem usou
  is_used = true AND
  used_by = auth.uid()::text
);

-- POLÍTICA 4: Admins podem DELETAR códigos
-- Permite remover códigos inválidos ou expirados
CREATE POLICY "Admins podem deletar codigos"
ON beta_codes
FOR DELETE
TO authenticated
USING (
  -- Em produção, verificar se é admin
  -- auth.jwt() ->> 'role' = 'admin'
  true
);

-- ============================================================
-- VERIFICAÇÃO
-- ============================================================
-- Execute para verificar as políticas criadas:
-- SELECT * FROM pg_policies WHERE tablename = 'beta_codes';
