-- ============================================================================
-- GRIMÓRIO DE BOLSO — LÁPIDES DA SINCRONIZAÇÃO (`sync_tombstones`)
-- ============================================================================
-- Rode este arquivo INTEIRO no SQL Editor do Supabase
-- (Database → SQL Editor → New query → colar → Run).
--
-- É IDEMPOTENTE: rodar de novo não estraga nada.
--
-- POR QUE ISTO EXISTE
-- -------------------
-- Sem lápide, o item apagado num aparelho ressuscita: o apagar local some
-- com a linha e avisa a nuvem — mas se a rede está fora do ar o aviso morre,
-- a cópia do servidor sobrevive, e o passo de download do sync seguinte
-- ("baixar o que só existe no servidor") traz o registro de volta. Com a
-- sincronização aberta para todo mundo, isso alcança as 116 contas, sobre
-- sonhos, escrita livre e o resto do que há de mais íntimo no app.
--
-- Cada linha aqui diz "a pessoa X apagou o item Y da entidade Z no instante
-- T". O app usa isso para: (1) retentar a purga da linha quando a rede
-- volta; (2) levar a exclusão aos OUTROS aparelhos da pessoa; (3) nunca
-- apagar por cima de uma edição mais nova que a exclusão — nesse caso a
-- edição vence e a lápide cai (a mesma regra mostRecent dos conflitos).
--
-- ATÉ ESTA MIGRAÇÃO RODAR o app continua funcionando: a lápide local já
-- impede a ressurreição no próprio aparelho e a purga da linha remota
-- acontece do mesmo jeito. O que só existe COM a tabela é a propagação da
-- exclusão entre aparelhos — e, enquanto ela não existir, as lápides locais
-- ficam pendentes e são retentadas a cada varredura.
--
-- `entity` guarda o nome do SyncEntity do app (ex.: 'dreams',
-- 'freeWritings'), o mesmo identificador nos dois lados.
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.sync_tombstones (
  user_id    UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  entity     TEXT        NOT NULL,
  item_id    TEXT        NOT NULL,
  deleted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, entity, item_id)
);

ALTER TABLE public.sync_tombstones ENABLE ROW LEVEL SECURITY;

-- Cada pessoa enxerga e mexe só nas próprias lápides. As quatro operações
-- são necessárias: SELECT (aplicar exclusões de outro aparelho), INSERT e
-- UPDATE (o upsert que registra a exclusão) e DELETE (derrubar a lápide
-- quando uma edição mais nova vence).
DROP POLICY IF EXISTS "Users can view own tombstones" ON public.sync_tombstones;
CREATE POLICY "Users can view own tombstones"
  ON public.sync_tombstones FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own tombstones" ON public.sync_tombstones;
CREATE POLICY "Users can insert own tombstones"
  ON public.sync_tombstones FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own tombstones" ON public.sync_tombstones;
CREATE POLICY "Users can update own tombstones"
  ON public.sync_tombstones FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own tombstones" ON public.sync_tombstones;
CREATE POLICY "Users can delete own tombstones"
  ON public.sync_tombstones FOR DELETE
  USING (auth.uid() = user_id);

-- Como em `profiles`: o papel anônimo não tem grant nenhum aqui. O RLS já
-- barraria (auth.uid() nulo não casa linha), mas grant ausente é uma rede a
-- mais contra política permissiva acrescentada no futuro.
REVOKE ALL ON public.sync_tombstones FROM anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.sync_tombstones TO authenticated;

-- ----------------------------------------------------------------------------
-- Conferência (rode depois e confira a saída)
-- ----------------------------------------------------------------------------
-- Deve listar a tabela com rowsecurity = true:
--   SELECT tablename, rowsecurity FROM pg_tables
--   WHERE schemaname = 'public' AND tablename = 'sync_tombstones';
-- Deve listar as quatro políticas:
--   SELECT policyname, cmd FROM pg_policies
--   WHERE schemaname = 'public' AND tablename = 'sync_tombstones';
