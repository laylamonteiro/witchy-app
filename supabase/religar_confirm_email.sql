-- ============================================================================
-- GRIMÓRIO DE BOLSO — RUNBOOK PARA RELIGAR O "Confirm email"
-- ============================================================================
-- Contexto (27/08/2026): a chave "Confirm email" foi DESLIGADA no painel
-- porque a exigência de confirmação + o bug do "falso login" no app deixava
-- a maioria das contas novas sem sessão e sem sincronização. O app foi
-- corrigido (branch claude/premium-code-redemption-error): cadastro sem
-- sessão mostra "confirme seu e-mail" e leva ao login; login barrado por
-- não confirmado oferece o reenvio do link; o diálogo de re-login idem.
--
-- A decisão de produto é religar a chave (e-mail verificado desde o dia 1).
-- ESTE ARQUIVO É O CHECKLIST PARA FAZER ISSO SEM QUEBRAR NINGUÉM.
--
-- ORDEM (não pule etapas):
--
--   1. Merge da branch + deploy do webapp + release Android publicado.
--   2. ESPERAR a adoção da versão Android subir (builds antigos ainda
--      tratam cadastro como login — religar cedo demais recria o limbo
--      para quem cadastrar num app desatualizado; o diálogo de re-login
--      resgata essas pessoas quando atualizarem, mas melhor não criá-las).
--   3. Conferir no painel: Authentication → URL Configuration →
--      https://grimoriodebolso.app está nas Redirect URLs (o link de
--      confirmação volta a ser enviado e precisa aterrissar no app).
--   4. Rodar o UPDATE abaixo (confirma em lote as contas EXISTENTES).
--   5. Religar a chave: Authentication → Sign In / Providers → Email →
--      "Confirm email".
--
-- POR QUE O PASSO 4 EXISTE: logar com a chave desligada NÃO confirma a
-- conta (`email_confirmed_at` continua NULL). Sem o lote, religar a chave
-- volta a barrar no login TODA conta antiga não confirmada — inclusive as
-- que o diálogo de re-login acabou de resgatar — na próxima troca de
-- aparelho ou expiração de sessão. Confirmar em lote anistia o passado; a
-- regra nova vale só para cadastros novos.
--
-- Escrever em auth.users é excepcional e este UPDATE é o único aprovado
-- neste projeto: equivale ao `email_confirm: true` da Admin API, coluna a
-- coluna. Não mexa em outras colunas de auth.users por SQL.
-- ============================================================================

-- Conferência antes (quantas contas serão anistiadas):
--   SELECT count(*) FROM auth.users
--    WHERE email_confirmed_at IS NULL AND deleted_at IS NULL;

UPDATE auth.users
   SET email_confirmed_at = NOW()
 WHERE email_confirmed_at IS NULL
   AND deleted_at IS NULL;

-- Conferência depois (deve retornar 0):
--   SELECT count(*) FROM auth.users
--    WHERE email_confirmed_at IS NULL AND deleted_at IS NULL;
