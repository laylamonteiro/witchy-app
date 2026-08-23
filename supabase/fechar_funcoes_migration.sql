-- ============================================================================
-- GRIMÓRIO DE BOLSO — FECHAMENTO DAS FUNÇÕES (`search_path` + EXECUTE)
-- ============================================================================
-- Rode este arquivo INTEIRO no SQL Editor do Supabase
-- (Database → SQL Editor → New query → colar → Run).
--
-- É IDEMPOTENTE: rodar de novo não estraga nada.
--
-- POR QUE ISTO EXISTE
-- -------------------
-- Verificado no projeto ativo em 23/08/2026 (advisor de segurança + catálogo):
--
-- 1. As cinco funções de `public` estão sem `SET search_path` — o advisor
--    acusa "role mutable search_path" em todas. Para função SECURITY
--    DEFINER (handle_new_user, redeem_beta_code) isso é o clássico vetor de
--    sombreamento de tabela; para as demais é higiene barata.
--
-- 2. `reset_daily_counters()` e `reset_monthly_counters()` têm EXECUTE para
--    `anon` e `authenticated`. Como são SECURITY INVOKER e o RLS de
--    `profiles` filtra pela própria linha, o efeito prático é: QUALQUER
--    conta logada zera os PRÓPRIOS limites diários/mensais com um
--    POST /rest/v1/rpc/reset_daily_counters — a mesma classe de furo do
--    PATCH em profiles que o lockdown fecha. Ninguém legítimo as chama
--    hoje: o app não usa (conferido no código) e o pg_cron está sem jobs.
--
-- 3. `handle_new_user()` (SECURITY DEFINER) está executável por anon e
--    authenticated via RPC. Ela é função de GATILHO (on_auth_user_created,
--    em auth.users) — o gatilho NÃO depende do EXECUTE para disparar (o
--    privilégio é checado ao criar o trigger, não a cada signup), então
--    revogar não afeta cadastro nenhum.
--
-- 4. `create_user_policy(text)` é helper de DDL; anon executável. Sem
--    SECURITY DEFINER ela falharia por privilégio de qualquer jeito, mas
--    não há motivo para seguir exposta na API.
--
-- O QUE FICA COMO ESTÁ, DE PROPÓSITO
-- ----------------------------------
-- `redeem_beta_code` MANTÉM o EXECUTE de anon: o resgate de Código Premium
-- sem login depende disso (mesma decisão documentada no
-- profiles_lockdown_migration.sql). Ela só ganha o search_path fixo.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. `search_path` FIXO NAS CINCO
-- ----------------------------------------------------------------------------
-- 'public' (e não '') porque reset_* e create_user_policy referenciam
-- `profiles` e afins sem qualificar — search_path vazio as quebraria.
ALTER FUNCTION public.handle_new_user()                          SET search_path = 'public';
ALTER FUNCTION public.redeem_beta_code(text, text)               SET search_path = 'public';
ALTER FUNCTION public.create_user_policy(text)                   SET search_path = 'public';
ALTER FUNCTION public.reset_daily_counters()                     SET search_path = 'public';
ALTER FUNCTION public.reset_monthly_counters()                   SET search_path = 'public';


-- ----------------------------------------------------------------------------
-- 2. EXECUTE SÓ PARA QUEM PRECISA
-- ----------------------------------------------------------------------------
-- Os resets ficam para o dono do banco (um futuro job do pg_cron roda como
-- postgres e não é afetado). Se um dia uma Edge Function precisar chamá-los
-- com a service key, é um GRANT explícito a service_role — hoje não há.
REVOKE EXECUTE ON FUNCTION public.reset_daily_counters()   FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.reset_monthly_counters() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.create_user_policy(text) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.handle_new_user()        FROM PUBLIC, anon, authenticated;


-- ----------------------------------------------------------------------------
-- Conferência (rode depois e confira a saída)
-- ----------------------------------------------------------------------------
-- Todas as cinco devem mostrar search_path=public; só redeem_beta_code deve
-- seguir executável por anon:
--   SELECT p.proname,
--          p.proconfig,
--          has_function_privilege('anon', p.oid, 'EXECUTE')          AS anon_executa,
--          has_function_privilege('authenticated', p.oid, 'EXECUTE') AS auth_executa
--   FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
--   WHERE n.nspname = 'public'
--     AND p.proname IN ('handle_new_user', 'redeem_beta_code',
--                       'create_user_policy', 'reset_daily_counters',
--                       'reset_monthly_counters')
--   ORDER BY p.proname;
--
-- E o advisor de segurança do painel deve parar de listar as cinco em
-- "Function Search Path Mutable" e o handle_new_user em "Public Can
-- Execute SECURITY DEFINER Function".
