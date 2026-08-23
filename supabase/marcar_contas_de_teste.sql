-- ============================================================================
-- GRIMÓRIO DE BOLSO — SEPARAR O QUE É TESTE DO QUE É GENTE
-- ============================================================================
-- Rode no SQL Editor do Supabase (Database → SQL Editor → New query).
-- É IDEMPOTENTE: rodar de novo não estraga nada.
--
-- POR QUE ISTO EXISTE, E POR QUE AGORA
-- ------------------------------------
-- A base tem 116 contas. Cinco delas são contas de TESTE da dona, e mais ou
-- menos 20 são testadoras que ela recrutou com código vitalício. Isso é
-- quase um terço da base — e enquanto ninguém as separa, toda taxa que
-- alguém calcular nasce torta.
--
-- O momento é este porque a decisão 6 do relatório de produto liga um
-- analytics de verdade (PostHog + tabelas próprias). Marcar ANTES é uma
-- linha de SQL; descobrir DEPOIS que a conversão estava 5% suja custa
-- refazer a leitura inteira e desconfiar de tudo.
--
-- O QUE ESTE ARQUIVO **NÃO** FAZ
-- ------------------------------
-- Não apaga nada. Nem conta de teste, nem conta fantasma. A seção 3 só
-- MOSTRA quem são as suspeitas — o que fazer com elas é decisão de quem lê,
-- e apagar conta é irreversível.
--
-- ⚠️ CONTÉM E-MAILS PESSOAIS. Estão aqui porque o arquivo não funciona sem
--    eles. Se preferir que não fiquem versionados, edite a lista antes de
--    rodar e reverta o arquivo depois — ou rode direto no editor sem commit.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. A MARCA
-- ----------------------------------------------------------------------------
-- Coluna própria, e não um `role` novo: `role` decide ACESSO, e uma conta de
-- teste tem que continuar se comportando exatamente como a conta que ela
-- imita. Misturar as duas coisas faria o teste deixar de testar.
--
-- Fica FORA do alcance do cliente de propósito. A migração de lockdown
-- (profiles_lockdown_migration.sql) corta as colunas por GRANT, e esta não
-- entra em nenhum: ninguém marca ou desmarca a própria conta pelo app.
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS conta_de_teste BOOLEAN NOT NULL DEFAULT FALSE;

COMMENT ON COLUMN public.profiles.conta_de_teste IS
  'Conta da equipe, não usuária. Excluir de toda métrica de produto.';


-- ----------------------------------------------------------------------------
-- 2. QUEM É TESTE
-- ----------------------------------------------------------------------------
-- `lower()` dos dois lados: e-mail não diferencia maiúscula, e uma conta
-- criada com "Layla@..." passaria batido numa comparação literal.
UPDATE public.profiles
   SET conta_de_teste = TRUE
 WHERE lower(email) IN (
   'suporte.grimoriodebolso@gmail.com',
   'layla.ferreira.itau.unibanco@gmail.com',
   'estoicismo000@gmail.com',
   'layla-sep@hotmail.com',
   'laylamonteiroferreira@gmail.com'
 );

-- Confira o resultado — o esperado é 5.
-- Se vier menos, alguma conta usa outro e-mail do que o listado.
SELECT COUNT(*) AS marcadas_como_teste
  FROM public.profiles
 WHERE conta_de_teste;

-- E as testadoras convidadas, que são outra coisa: gente de verdade, com
-- código vitalício. NÃO devem ser marcadas como teste — elas usam o app.
-- Ficam aqui só para você ver o tamanho do grupo ao lado do outro.
SELECT plan, role, COUNT(*)
  FROM public.profiles
 GROUP BY plan, role
 ORDER BY 3 DESC;


-- ----------------------------------------------------------------------------
-- 3. AS CONTAS FANTASMA — diagnóstico, não faxina
-- ----------------------------------------------------------------------------
-- O endpoint do Supabase é público por natureza, e robô de varredura bate
-- nas rotas conhecidas. Foi por isso que o captcha entrou.
--
-- LEIA ISTO ANTES DE MEXER NO CAPTCHA. São duas peças, e só uma barra robô:
--
--   1. O gate do cliente (CaptchaGate → Turnstile → `captchaToken`) roda
--      DENTRO do app Flutter. Um crawler não roda o seu app: ele chama
--      POST /auth/v1/signup direto, e esse gate é invisível para ele.
--   2. A exigência no SERVIDOR (Authentication → Attack Protection) recusa
--      a chamada que chega sem token, venha ela de onde vier.
--
-- CONFERIDO NO PAINEL EM 23/08/2026: a peça 2 está LIGADA, com Turnstile e
-- secret preenchida. Ou seja, foi ela que fechou a porta dos fantasmas — o
-- que aparecer na consulta abaixo é, muito provavelmente, de ANTES de ela
-- ser ligada. Repare na data das linhas.
--
-- E a consequência que dói: com a peça 2 ligada, um app publicado SEM a
-- site key compilada não consegue mais entrar nem cadastrar — nenhuma
-- conta, nem por e-mail nem por senha. Por isso a esteira de release agora
-- PARA quando o secret TURNSTILE_SITE_KEY falta (release.yml). Não desligue
-- essa trava sem antes desligar a peça 2 no painel.
--
-- A consulta abaixo mostra as suspeitas. Sinal usado: nunca confirmou o
-- e-mail E nunca voltou depois de criar a conta. Robô cria e some; pessoa
-- que desistiu no meio também — por isso é SUSPEITA, não sentença.
SELECT u.id,
       u.email,
       u.created_at,
       u.last_sign_in_at,
       u.email_confirmed_at,
       u.raw_app_meta_data->>'provider' AS provedor
  FROM auth.users u
  LEFT JOIN public.profiles p ON p.id = u.id
 WHERE u.email_confirmed_at IS NULL
   AND (u.last_sign_in_at IS NULL
        OR u.last_sign_in_at <= u.created_at + interval '2 minutes')
   AND COALESCE(p.conta_de_teste, FALSE) = FALSE
 ORDER BY u.created_at DESC;

-- O contorno do problema, em uma linha: quantas contas por dia, e quantas
-- delas nunca confirmaram. Um pico num dia só é assinatura de robô; um
-- gotejar constante é gente desistindo no cadastro — e aí o problema é a
-- porta, não o robô.
SELECT date_trunc('day', u.created_at)::date AS dia,
       COUNT(*) AS criadas,
       COUNT(*) FILTER (WHERE u.email_confirmed_at IS NULL) AS sem_confirmar
  FROM auth.users u
 GROUP BY 1
 ORDER BY 1 DESC
 LIMIT 60;


-- ============================================================================
-- 4. DEPOIS DISTO
-- ============================================================================
-- Toda consulta de produto passa a levar o filtro:
--
--   WHERE COALESCE(p.conta_de_teste, FALSE) = FALSE
--
-- E quando o analytics entrar (decisão 6), a mesma marca vai junto no
-- identify da pessoa, para o funil nascer limpo em vez de ser limpo depois.
-- ============================================================================
