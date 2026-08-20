-- De onde a CONTA nasceu: 'android', 'ios' ou 'web'.
-- Rode este script no SQL Editor do Supabase. É idempotente: rodar de novo
-- não estraga nada (a coluna só é criada se faltar, e o preenchimento só
-- toca linhas ainda vazias).
--
-- Sem este campo não há como responder "quantas contas novas vieram do
-- site?" — o RevenueCat não responde, pois só conhece quem pagou.
--
-- IMPORTANTE: este campo é HISTÓRICO, não estado. Quem criou a conta no
-- site e hoje usa o app continua com 'web'. Ele NÃO diz onde a assinatura
-- daquela pessoa é cobrada nem onde ela deve cancelar — isso é o
-- RevenueCat quem sabe (CustomerInfo.managementURL), porque a loja pode
-- ser outra e pode mudar. Ver docs/ORIGEM_E_PAGAMENTO.md.

-- 1) A coluna
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS signup_platform TEXT
  CHECK (signup_platform IN ('android', 'ios', 'web', 'unknown'));

COMMENT ON COLUMN profiles.signup_platform IS
  'Plataforma onde a conta foi criada (histórico). Não indica a loja da assinatura.';

-- 2) ANTES de preencher: veja o que você vai carimbar.
--    Rode SÓ esta consulta primeiro e confira se as datas batem com a sua
--    memória de quando o webapp passou a aceitar cadastro.
--
--   SELECT date_trunc('month', created_at) AS mes, COUNT(*)
--   FROM profiles
--   WHERE signup_platform IS NULL
--   GROUP BY 1 ORDER BY 1;

-- 3) O preenchimento das contas antigas.
--
-- Até o webapp existir, a Play Store era a ÚNICA porta de entrada: toda
-- conta anterior a ele veio de lá. Isso é fato conhecido, não estimativa —
-- por isso vale carimbar, em vez de deixar como desconhecido.
--
-- A DATA DE CORTE existe para não carimbar por engano quem já entrou pelo
-- site. Ajuste-a para o dia em que o cadastro pela web passou a funcionar
-- de verdade (inclusive as SUAS contas de teste na web, que também são
-- 'web' e não 'android').
--
-- Se tiver certeza de que nenhuma conta nasceu na web até agora, use
-- NOW() no lugar da data.
UPDATE profiles
SET signup_platform = 'android'
WHERE signup_platform IS NULL
  AND created_at < TIMESTAMPTZ '2026-08-01';

-- 4) Confira o resultado (NULL restante = criada depois do corte e ainda
--    sem carimbo; some sozinho conforme as pessoas entram no app novo).
--   SELECT signup_platform, COUNT(*) FROM profiles GROUP BY 1 ORDER BY 2 DESC;
