-- Sincronização em nuvem do registro menstrual.
-- Rode este script no SQL Editor do Supabase (uma vez), ANTES de publicar a
-- versão do app que envia o ciclo.
--
-- Por que ele existe, e por que só agora: este é o dado mais sensível do
-- aplicativo — dado de saúde, sensível na LGPD. Ele ficou fora da nuvem desde
-- que a roda do ciclo nasceu. O que muda é o consentimento: além do sim que
-- autoriza registrar, existe um SEGUNDO sim, só para enviar, desligado por
-- padrão e pedido dentro da própria roda. Sem ele o aplicativo não toca nesta
-- tabela — nem para subir, nem para baixar.
--
-- Observações que valem para quem for mexer aqui:
--
-- - NÃO existe coluna `id`. A identidade de uma linha é (user_id, day_key), e
--   é essa a chave primária. O aplicativo faz upsert com
--   `onConflict: 'user_id,day_key'`, e o PostgREST exige um índice único
--   correspondente — sem a PK abaixo, todo upload responde 42P10.
--
-- - `day_key` é TEXT, não DATE e não TIMESTAMPTZ. É a string 'AAAA-MM-DD' do
--   dia LOCAL dela, e sobe crua: convertê-la para instante faria o dia mudar
--   de data para quem está longe de Greenwich. O registro é de um dia, não de
--   um instante.
--
-- - A exclusão de um dia NÃO usa `sync_tombstones`, e vale dizer com todas as
--   letras o que isso é e o que não é. Apagar um dia com o envio ligado deixa
--   AQUI a linha daquele dia com `deleted = true` e `revision` maior: o
--   conteúdo sai, a data fica. Ela precisa ficar em algum lugar, senão o outro
--   aparelho dela traz o dia de volta. A escolha não foi entre guardar e não
--   guardar a data — foi entre dois lugares. Em `sync_tombstones` a data ficava
--   fora do alcance dela: sobrevivia ao "apagar a cópia da nuvem", sobrevivia
--   ao "apagar meus registros do ciclo", e ainda vinha rotulada com
--   `entity = 'menstrualDays'` numa tabela que não é do ciclo. Dentro da
--   própria linha, os dois gestos e a exclusão de conta a alcançam. Por isso
--   `deleted` é NOT NULL com padrão, e não uma linha ausente.
--
-- - ORDEM: rode este arquivo ANTES de `rls_initplan_optimization_migration.sql`.
--   Aquele arquivo é uma transação só e recria as políticas de `menstrual_days`
--   junto com as das outras 21 tabelas; sem esta tabela existindo, ele aborta e
--   leva as 21 outras no mesmo rollback.
--
-- - A política de DELETE não é opcional. A exclusão de conta varre todas as
--   tabelas do SyncEntity e CONFERE, depois do DELETE, que não sobrou linha;
--   um DELETE barrado pelo RLS responde sucesso tendo apagado zero linhas, e a
--   conferência então reprova a exclusão INTEIRA da conta. Sem as quatro
--   políticas abaixo, ninguém consegue mais excluir a própria conta.
--
-- - `season` e `season_note` não existem aqui, de propósito: são colunas
--   mortas no aparelho desde que a Estação Interna saiu do aplicativo, e o
--   app as remove antes de enviar.

CREATE TABLE IF NOT EXISTS menstrual_days (
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  day_key TEXT NOT NULL,
  mark TEXT NOT NULL,
  flow TEXT,
  symptoms JSONB NOT NULL DEFAULT '[]'::jsonb,
  mood TEXT,
  note TEXT NOT NULL DEFAULT '',
  revision INTEGER NOT NULL DEFAULT 1,
  deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, day_key)
);

-- A chave estrangeira para auth.users precisa de índice de cobertura, senão o
-- ON DELETE CASCADE vira varredura sequencial (indices_e_chaves_migration.sql
-- documenta o caso). A PK já começa por user_id e cobre o filtro do app
-- (`select ... eq('user_id', ...)`), mas o índice explícito segue a regra da
-- casa e não custa nada em tabela deste tamanho.
CREATE INDEX IF NOT EXISTS idx_menstrual_days_user_id
  ON menstrual_days(user_id);

ALTER TABLE menstrual_days ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own menstrual days" ON menstrual_days;
CREATE POLICY "Users can view own menstrual days"
  ON menstrual_days
  FOR SELECT USING ((select auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can insert own menstrual days" ON menstrual_days;
CREATE POLICY "Users can insert own menstrual days"
  ON menstrual_days
  FOR INSERT WITH CHECK ((select auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can update own menstrual days" ON menstrual_days;
CREATE POLICY "Users can update own menstrual days"
  ON menstrual_days
  FOR UPDATE USING ((select auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can delete own menstrual days" ON menstrual_days;
CREATE POLICY "Users can delete own menstrual days"
  ON menstrual_days
  FOR DELETE USING ((select auth.uid()) = user_id);

-- Ninguém anônimo chega perto desta tabela.
REVOKE ALL ON public.menstrual_days FROM anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.menstrual_days TO authenticated;
