-- ============================================================================
-- ACERVO ÚNICO DE ESCRITA: free_writings ganha título e origem
-- ============================================================================
-- Unificação "Meus Registros" + "Reflexões": a tabela free_writings passa a
-- guardar também as páginas GERADAS (lições do Grimório Vivo e leituras de
-- quiromancia/runas/pêndulo/oráculo), distinguidas pela coluna source.
--
-- IMPORTANTE: rode este arquivo no SQL Editor do Supabase ANTES de publicar
-- a versão do app que usa as colunas novas — sem ele, o upload de entradas
-- com title/source falha (PGRST204) até o schema existir.
--
-- Idempotente: pode rodar mais de uma vez.
-- ============================================================================

ALTER TABLE free_writings ADD COLUMN IF NOT EXISTS title TEXT;
ALTER TABLE free_writings ADD COLUMN IF NOT EXISTS source TEXT NOT NULL DEFAULT 'free';

CREATE INDEX IF NOT EXISTS idx_free_writings_source ON free_writings(user_id, source);

-- PostgREST recarrega o schema na hora
NOTIFY pgrst, 'reload schema';
