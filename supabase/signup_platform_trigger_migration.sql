-- ============================================================================
-- GRIMÓRIO DE BOLSO — `signup_platform` PREENCHIDO PELO TRIGGER
-- ============================================================================
-- Rode este arquivo INTEIRO no SQL Editor do Supabase
-- (Database → SQL Editor → New query → colar → Run).
--
-- É IDEMPOTENTE: rodar de novo não estraga nada.
--
-- POR QUE ISTO EXISTE
-- -------------------
-- Verificado no projeto ativo em 27/08/2026: TODO cadastro por e-mail desde
-- ~20/08 está com `profiles.signup_platform` NULL. A causa é a combinação
-- de duas coisas certas que juntas deixaram um buraco:
--
-- 1. Com confirmação de e-mail exigida, `signUp()` NÃO devolve sessão — o
--    app roda como `anon` até a pessoa confirmar e entrar.
-- 2. O lockdown (profiles_lockdown_migration.sql) fez, corretamente,
--    `REVOKE ALL ON profiles FROM anon`.
--
-- Resultado: o UPDATE de `signup_platform` que o app faz logo após o
-- cadastro (supabase_auth_repository.dart, _createProfile) é negado em
-- silêncio para cadastros por e-mail. Só login social (que tem sessão na
-- hora) ainda preenchia — os dados confirmam: de 20/08 a 27/08, apenas as
-- contas autoconfirmadas (Google) têm o campo.
--
-- A CORREÇÃO
-- ----------
-- O app agora manda a plataforma no metadata do signUp()
-- (`raw_user_meta_data->>'signup_platform'`), e o trigger handle_new_user —
-- que roda como dono do banco, com ou sem sessão — grava a coluna ao criar
-- a linha do perfil. O caminho do cliente continua existindo como reforço
-- para login social de conta antiga (lá há sessão e o grant de
-- `authenticated` cobre a coluna).
--
-- O CHECK da coluna aceita ('android','ios','web','unknown') — ver
-- signup_platform_migration.sql. O trigger valida contra essa lista para a
-- linha inteira não falhar por um metadata inesperado: metadata inválido
-- vira NULL, nunca erro de signup.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles
    (id, email, display_name, signup_platform, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'display_name',
    CASE
      WHEN NEW.raw_user_meta_data->>'signup_platform'
           IN ('android', 'ios', 'web', 'unknown')
      THEN NEW.raw_user_meta_data->>'signup_platform'
      ELSE NULL
    END,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

-- ----------------------------------------------------------------------------
-- Conferência (rode depois e confira a saída)
-- ----------------------------------------------------------------------------
-- A função deve citar signup_platform:
--   SELECT prosrc FROM pg_proc WHERE proname = 'handle_new_user';
--
-- E um cadastro novo por e-mail (sem confirmar nada) deve nascer com a
-- coluna preenchida:
--   SELECT id, signup_platform, created_at FROM public.profiles
--    ORDER BY created_at DESC LIMIT 5;

-- ----------------------------------------------------------------------------
-- BACKFILL OPCIONAL dos NULL recentes (rode só se quiser)
-- ----------------------------------------------------------------------------
-- Os cadastros de ~20/08 a 27/08 ficaram NULL. Não dá para saber a
-- plataforma deles com certeza; se quiser marcá-los como 'unknown' para
-- separá-los dos antigos backfillados como 'android':
--
--   UPDATE public.profiles
--      SET signup_platform = 'unknown'
--    WHERE signup_platform IS NULL
--      AND created_at >= '2026-08-19';
