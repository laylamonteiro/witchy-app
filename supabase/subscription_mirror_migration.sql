-- ============================================================================
-- GRIMÓRIO DE BOLSO — ESPELHO DA ASSINATURA EM `profiles`
-- ============================================================================
-- Rode este arquivo INTEIRO no SQL Editor do Supabase (ou aplique como
-- migração). É IDEMPOTENTE.
--
-- NÃO afeta usuários existentes: só ACRESCENTA colunas anuláveis (as 173
-- linhas atuais ficam com NULL) e cria uma função. Nada de dado é alterado.
--
-- POR QUE ISTO EXISTE
-- -------------------
-- Hoje `profiles.role`/`plan` só é escrito pelo resgate de Código Premium e
-- pelo admin — a COMPRA de assinatura (mensal/anual/vitalício) nunca chega ao
-- banco (fica no RevenueCat e no aparelho). Prova no banco: 148 free/free, 24
-- premium/lifetime (códigos), 1 admin, e ZERO monthly/yearly.
--
-- Resultado: o servidor não sabe quem comprou. Na web e em reinstalação, onde
-- o RevenueCat demora ou nem carrega, o assinante pode ficar sem acesso — e
-- suporte/relatório por `profiles.plan` mente.
--
-- A REGRA DE OURO CONTINUA VALENDO (docs/ORIGEM_E_PAGAMENTO.md): quem MANDA é
-- o RevenueCat. Estas colunas são um ESPELHO VIVO dele, mantido por webhook a
-- cada evento (compra/renovação/expiração) — então não envelhecem como uma
-- cópia feita uma vez. O app segue lendo `role`/`plan` na entrada, e agora o
-- assinante entra Premium na hora, sem depender do RevenueCat carregar.
--
-- SEGURANÇA
-- ---------
-- Quem escreve o espelho é o WEBHOOK (Edge Function `revenuecat-webhook`),
-- com a service_role, validado por segredo compartilhado. O cliente continua
-- SEM poder escrever `role`/`plan` (o lockdown fica intacto). A função abaixo
-- é a ÚNICA porta desse write e é `SECURITY INVOKER` concedida SÓ à
-- service_role: mesmo que um dia alguém a conceda a `authenticated` por
-- engano, o RLS + o REVOKE de coluna do lockdown barram a escrita — não há
-- como o cliente declarar o próprio plano (o buraco que o lockdown fechou).
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. COLUNAS DO ESPELHO (anuláveis → seguras para as linhas que já existem)
-- ----------------------------------------------------------------------------
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS plan_expires_at timestamptz,
  ADD COLUMN IF NOT EXISTS plan_updated_at timestamptz,
  ADD COLUMN IF NOT EXISTS plan_source text;

-- CHECK do plan_source, idempotente (fora do ADD COLUMN para poder existir
-- mesmo se a coluna já tiver sido criada num run anterior).
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
     WHERE conname = 'profiles_plan_source_check'
       AND conrelid = 'public.profiles'::regclass
  ) THEN
    ALTER TABLE public.profiles
      ADD CONSTRAINT profiles_plan_source_check
      CHECK (plan_source IS NULL OR plan_source IN ('revenuecat', 'beta_code', 'admin'));
  END IF;
END $$;

COMMENT ON COLUMN public.profiles.plan_expires_at IS
  'Espelho do RevenueCat: quando a assinatura vigente expira. NULL para vitalício/free. Mantido pelo webhook revenuecat-webhook; RevenueCat continua sendo a fonte de verdade.';
COMMENT ON COLUMN public.profiles.plan_updated_at IS
  'Quando o EVENTO que atualizou o espelho ocorreu (event_timestamp do RevenueCat). Usado para ordenar eventos e ignorar re-entrega atrasada.';
COMMENT ON COLUMN public.profiles.plan_source IS
  'Origem do plano atual: revenuecat (compra), beta_code (Código Premium), admin. NULL em linhas anteriores ao espelho.';

-- SELECT já é de tabela para `authenticated` (o lockdown só revogou
-- INSERT/UPDATE); reforça-se explicitamente para as colunas novas. INSERT e
-- UPDATE NÃO são concedidos: o cliente não escreve o espelho — quem escreve é
-- a service_role via a função abaixo.
GRANT SELECT (plan_expires_at, plan_updated_at, plan_source)
  ON public.profiles TO authenticated;


-- ----------------------------------------------------------------------------
-- 2. A ÚNICA PORTA DE ESCRITA DO ESPELHO
-- ----------------------------------------------------------------------------
-- Recebe o estado autoritativo (vindo do RevenueCat, via webhook) e aplica na
-- linha da pessoa, com TRÊS travas que valem dinheiro:
--   · NUNCA rebaixa admin.
--   · NUNCA rebaixa um `lifetime` (Código Premium OU compra vitalícia): o
--     RevenueCat não conhece o lifetime de Código Premium, então um evento de
--     expiração/cancelamento não pode derrubar o acesso vitalício de ninguém.
--   · NUNCA aplica um evento mais VELHO que o último já aplicado (ordenação por
--     tempo de evento): uma RENEWAL atrasada, re-entregue DEPOIS de uma
--     EXPIRATION, não ressuscita o acesso.
--
-- SECURITY INVOKER de propósito (o oposto do redeem_beta_code): esta função
-- NÃO precisa escalar para o cliente — só a service_role a chama, e a
-- service_role já tem privilégio. Assim, se um dia for concedida a
-- `authenticated` por engano, ela roda com o privilégio do cliente e o
-- lockdown (REVOKE UPDATE das colunas role/plan) a barra. Defesa em
-- profundidade.

-- Remove a versão de 4 argumentos (sem ordenação por tempo), se um run
-- anterior a criou — a assinatura ganhou `p_event_at`. Chamadas com 4
-- argumentos nomeados continuam funcionando: casam com a de 5 (o default).
DROP FUNCTION IF EXISTS public.apply_subscription_state(uuid, text, timestamptz, text);

CREATE OR REPLACE FUNCTION public.apply_subscription_state(
  p_user_id    uuid,
  p_plan       text,          -- 'free' | 'monthly' | 'yearly' | 'lifetime'
  p_expires_at timestamptz,   -- NULL para vitalício/free
  p_source     text,          -- 'revenuecat' | 'beta_code' | 'admin'
  p_event_at   timestamptz DEFAULT NULL  -- quando o EVENTO ocorreu (ordenação)
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_role       text;
  v_plan       text;
  v_updated_at timestamptz;
BEGIN
  IF p_plan IS NULL OR p_plan NOT IN ('free', 'monthly', 'yearly', 'lifetime') THEN
    RETURN jsonb_build_object('ok', false, 'reason', 'invalid_plan');
  END IF;
  IF p_source IS NULL OR p_source NOT IN ('revenuecat', 'beta_code', 'admin') THEN
    RETURN jsonb_build_object('ok', false, 'reason', 'invalid_source');
  END IF;

  SELECT role, plan, plan_updated_at
    INTO v_role, v_plan, v_updated_at
    FROM public.profiles
   WHERE id = p_user_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'reason', 'no_profile');
  END IF;

  -- Trava 1: admin não é tocado por evento de assinatura.
  IF v_role = 'admin' THEN
    RETURN jsonb_build_object('ok', true, 'reason', 'admin_untouched');
  END IF;

  -- Trava 2: lifetime não é rebaixado por nada que não seja lifetime.
  IF v_plan = 'lifetime' AND p_plan <> 'lifetime' THEN
    RETURN jsonb_build_object('ok', true, 'reason', 'lifetime_kept');
  END IF;

  -- Trava 3: ordenação. Evento mais velho que o último aplicado é ignorado —
  -- é a re-entrega atrasada que ressuscitaria estado. Sem tempo de evento não
  -- há como ordenar, então aplica (melhor esforço).
  IF p_event_at IS NOT NULL AND v_updated_at IS NOT NULL
     AND p_event_at < v_updated_at THEN
    RETURN jsonb_build_object('ok', true, 'reason', 'stale_event');
  END IF;

  IF p_plan = 'free' THEN
    UPDATE public.profiles
       SET role            = 'free',
           plan            = 'free',
           plan_expires_at = NULL,
           plan_source     = p_source,
           plan_updated_at = COALESCE(p_event_at, now()),
           updated_at      = now()
     WHERE id = p_user_id;
  ELSE
    UPDATE public.profiles
       SET role            = 'premium',
           plan            = p_plan,
           plan_expires_at = CASE WHEN p_plan = 'lifetime' THEN NULL ELSE p_expires_at END,
           plan_source     = p_source,
           plan_updated_at = COALESCE(p_event_at, now()),
           updated_at      = now()
     WHERE id = p_user_id;
  END IF;

  RETURN jsonb_build_object('ok', true, 'reason', 'applied', 'plan', p_plan);
END;
$$;

-- ATENÇÃO: NUNCA conceda EXECUTE desta função a `authenticated`/`anon`. Ela
-- confia nos argumentos; o cliente declarar o próprio plano é exatamente a
-- escalada que o lockdown fechou. Só a service_role (servidor) a chama.
REVOKE ALL ON FUNCTION public.apply_subscription_state(uuid, text, timestamptz, text, timestamptz)
  FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.apply_subscription_state(uuid, text, timestamptz, text, timestamptz)
  TO service_role;


-- ============================================================================
-- 3. CONFERÊNCIA
-- ============================================================================
-- (a) As colunas existem e são anuláveis:
--   SELECT column_name, is_nullable FROM information_schema.columns
--    WHERE table_schema='public' AND table_name='profiles'
--      AND column_name IN ('plan_expires_at','plan_updated_at','plan_source');
--
-- (b) `authenticated` NÃO pode escrever role/plan/plan_* (só SELECT):
--   SELECT privilege_type, column_name FROM information_schema.column_privileges
--    WHERE table_name='profiles' AND grantee='authenticated'
--      AND column_name IN ('role','plan','plan_expires_at','plan_source')
--    ORDER BY privilege_type, column_name;   -- deve aparecer só SELECT
--
-- (c) A função só é executável pela service_role:
--   SELECT grantee, privilege_type FROM information_schema.routine_privileges
--    WHERE routine_name='apply_subscription_state';
-- ============================================================================
