-- De onde a CONTA nasceu: 'android', 'ios' ou 'web'.
-- Rode este script no SQL Editor do Supabase (uma vez).
--
-- Até agora praticamente toda usuária chegou pela Play Store. Com o webapp
-- no ar isso deixa de ser verdade, e sem este campo não há como responder
-- "quantas contas novas vieram do site?" — o RevenueCat não responde, pois
-- só conhece quem pagou.
--
-- IMPORTANTE: este campo é HISTÓRICO, não estado. Quem criou a conta no
-- site e hoje usa o app continua com 'web'. Ele NÃO diz onde a assinatura
-- daquela pessoa é cobrada nem onde ela deve cancelar — isso é o
-- RevenueCat quem sabe (CustomerInfo.managementURL), porque a loja pode
-- ser outra e pode mudar. Ver docs/ORIGEM_E_PAGAMENTO.md.
--
-- As contas anteriores a esta coluna ficam com NULL de propósito: NULL
-- significa "não sabemos", e não "veio da Play". Preencher com um palpite
-- transformaria uma lacuna conhecida num dado falso.

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS signup_platform TEXT
  CHECK (signup_platform IN ('android', 'ios', 'web', 'unknown'));

COMMENT ON COLUMN profiles.signup_platform IS
  'Plataforma onde a conta foi criada (histórico). NULL = anterior ao campo. Não indica a loja da assinatura.';

-- Quantas contas por origem (NULL = anteriores ao campo):
--   SELECT signup_platform, COUNT(*) FROM profiles GROUP BY 1 ORDER BY 2 DESC;
