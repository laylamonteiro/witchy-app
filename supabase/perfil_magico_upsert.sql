-- ============================================================================
-- GRIMÓRIO DE BOLSO — A ESCRITA VELHA NÃO VENCE A NOVA
-- ============================================================================
-- Rode este arquivo INTEIRO no SQL Editor do Supabase
-- (Database → SQL Editor → New query → colar → Run).
--
-- É IDEMPOTENTE: rodar de novo não estraga nada.
--
-- POR QUE ISTO EXISTE
-- -------------------
-- A Análise Personalizada é UM markdown que cresce: cada seção tecida é
-- acrescentada ao texto guardado e a linha inteira sobe num upsert.
--
-- O acúmulo em memória já é atômico (o texto acumulado é lido DEPOIS da
-- chamada de IA), e o app agora enfileira as gravações — mas a fila só ordena
-- dentro de UM processo. Duas seções terminando juntas em aparelhos
-- diferentes, ou uma reconexão que reenvia, continuam colocando dois upsert no
-- ar sem alvo de conflito e sem guarda: o servidor fica com o que CHEGAR por
-- último, que pode ser o mais VELHO.
--
-- O estrago é silencioso do pior jeito: no aparelho o texto fica certo e a
-- linha é marcada como sincronizada, então nada corrige depois. A seção
-- perdida só reaparece quando alguém sujar a linha de novo.
--
-- A guarda abaixo descarta a escrita cujo `updated_at` é mais ANTIGO que o
-- gravado. Não devolve erro: o app não tem o que fazer com um erro aqui, e
-- falhar o sync por causa de uma escrita obsoleta seria trocar um problema
-- por outro.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. A GUARDA
-- ----------------------------------------------------------------------------
-- `RETURN OLD` num gatilho BEFORE UPDATE aplica a linha ANTIGA — ou seja,
-- descarta a atualização sem erro e sem barulho. É o idioma padrão para
-- "ignore esta escrita".
--
-- As duas conferências de nulo importam: linha antiga sem `updated_at`
-- (gravada antes de a coluna existir) não pode bloquear escrita nova.
CREATE OR REPLACE FUNCTION public.descartar_escrita_obsoleta()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  IF OLD.updated_at IS NOT NULL
     AND NEW.updated_at IS NOT NULL
     AND NEW.updated_at < OLD.updated_at THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$;


-- ----------------------------------------------------------------------------
-- 2. ONDE ELA VALE
-- ----------------------------------------------------------------------------
-- `magical_profiles` é o caso relatado, e o mais caro: o texto é gerado por
-- IA, custa dez chamadas para ficar completo, e a perda é invisível.
DROP TRIGGER IF EXISTS magical_profiles_escrita_obsoleta
  ON public.magical_profiles;
CREATE TRIGGER magical_profiles_escrita_obsoleta
  BEFORE UPDATE ON public.magical_profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.descartar_escrita_obsoleta();

-- `birth_charts` vem junto por ser a outra tabela de blob que o app reescreve
-- inteira (o recálculo silencioso por versão do algoritmo).
DROP TRIGGER IF EXISTS birth_charts_escrita_obsoleta
  ON public.birth_charts;
CREATE TRIGGER birth_charts_escrita_obsoleta
  BEFORE UPDATE ON public.birth_charts
  FOR EACH ROW
  EXECUTE FUNCTION public.descartar_escrita_obsoleta();


-- ============================================================================
-- 3. CONFERÊNCIA — rode depois e leia a saída
-- ============================================================================
-- (a) Os dois gatilhos precisam aparecer:
--
--   SELECT event_object_table, trigger_name, action_timing, event_manipulation
--     FROM information_schema.triggers
--    WHERE trigger_schema = 'public'
--      AND trigger_name LIKE '%escrita_obsoleta'
--    ORDER BY event_object_table;
--
-- (b) O teste que importa, numa linha sua. A segunda escrita é mais VELHA e
--     tem de ser ignorada — o texto precisa continuar sendo 'novo':
--
--   UPDATE public.magical_profiles
--      SET profile_data = '{"t":"novo"}'::jsonb, updated_at = now()
--    WHERE id = '<um id seu>';
--
--   UPDATE public.magical_profiles
--      SET profile_data = '{"t":"velho"}'::jsonb,
--          updated_at = now() - interval '1 hour'
--    WHERE id = '<o mesmo id>';
--
--   SELECT profile_data, updated_at FROM public.magical_profiles
--    WHERE id = '<o mesmo id>';
--
-- ----------------------------------------------------------------------------
-- LIMITE CONHECIDO: dois upsert com o MESMO `updated_at` (mesmo milissegundo)
-- continuam resolvendo por ordem de chegada. Na prática não acontece — o
-- carimbo vem de `DateTime.now()` no aparelho, entre duas chamadas de IA —, e
-- resolver isso exigiria número de versão por linha, que é projeto à parte.
-- ============================================================================
