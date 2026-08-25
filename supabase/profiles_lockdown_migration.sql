-- ============================================================================
-- GRIMÓRIO DE BOLSO — FECHAMENTO DA TABELA `profiles`
-- ============================================================================
-- Rode este arquivo INTEIRO no SQL Editor do Supabase
-- (Database → SQL Editor → New query → colar → Run).
--
-- É IDEMPOTENTE: rodar de novo não estraga nada.
--
-- POR QUE ISTO EXISTE
-- -------------------
-- Hoje a política de escrita de `profiles` é
--   FOR UPDATE USING (auth.uid() = id)
-- sem WITH CHECK e sem restrição de coluna, e o papel `authenticated` tem
-- grant de UPDATE na tabela inteira. Quem passa no USING (a dona da linha)
-- reescreve QUALQUER coluna da própria linha — inclusive `role` e `plan`.
--
-- Consequência concreta: qualquer pessoa logada faz
--   PATCH /rest/v1/profiles?id=eq.<seu uid>
--   {"role":"admin","plan":"lifetime"}
-- e no login seguinte o app lê `role` do servidor, `isAdmin` vira verdadeiro
-- e o feature_access devolve acesso total — com a tela de Diagnóstico e a de
-- Códigos Premium dentro. Os contadores diários (*_today, spells_count,
-- diary_entries_this_month) estão no mesmo balaio: dá para zerar os próprios
-- limites por requisição.
--
-- O corte abaixo é por COLUNA, não por linha: a pessoa continua editando o
-- que é dela (nome, foto, dados de nascimento) e perde o alcance sobre o que
-- decide acesso e cobrança.
--
-- ORDEM: este arquivo é PRÉ-REQUISITO de abrir a sincronização para todo
-- mundo. Abrir o sync com `profiles` em aberto multiplica o alcance da
-- escalada de privilégio.
--
-- Conteúdo:
--   1. `anon` perde todo grant em profiles
--   2. `authenticated` passa a ter grant por COLUNA em INSERT/UPDATE
--   3. WITH CHECK na política de UPDATE + política de DELETE que faltava
--   4. Endurecimento das funções SECURITY DEFINER que escrevem em profiles
--   5. Consultas de conferência (rode depois e confira a saída)
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. `anon` NÃO DEVE TOCAR EM `profiles`
-- ----------------------------------------------------------------------------
-- Hoje o papel anônimo tem SELECT/INSERT/UPDATE em profiles e só o RLS o
-- segura (para o anônimo auth.uid() é nulo e não casa nenhuma linha). É uma
-- rede única: qualquer política permissiva acrescentada no futuro abriria a
-- tabela ao mundo — e-mail e data de nascimento incluídos. Grant nenhum aqui.
--
-- Isto NÃO afeta o resgate de Código Premium sem login: a RPC
-- `redeem_beta_code` é SECURITY DEFINER e roda como dona do banco, acima
-- deste REVOKE.
REVOKE ALL ON public.profiles FROM anon;


-- ----------------------------------------------------------------------------
-- 2. `authenticated` SÓ EDITA AS COLUNAS SEM PODER
-- ----------------------------------------------------------------------------
-- SELECT continua inteiro de propósito: o card de "Uso do Plano Gratuito"
-- exibe os contadores, então a LEITURA precisa sobreviver ao corte. O que sai
-- do alcance do cliente é a ESCRITA.
--
-- Fora das duas listas abaixo, e portanto fora do alcance do cliente:
--   role, plan                      → quem decide acesso
--   spells_count, diary_entries_this_month,
--   ai_consultations_today, pendulum_uses_today, affirmations_today,
--   rune_readings_today, oracle_readings_today
--                                   → quem decide limite
--   created_at                      → histórico
REVOKE INSERT, UPDATE ON public.profiles FROM authenticated;

-- INSERT: o que `_createProfile` (supabase_auth_repository.dart) grava ao
-- criar a linha, mais as colunas de dados que a pessoa preenche depois.
GRANT INSERT (
  id,
  email,
  display_name,
  photo_url,
  birth_date,
  birth_time,
  birth_place,
  signup_platform,
  updated_at
) ON public.profiles TO authenticated;

-- UPDATE: `updateProfile` grava display_name/photo_url/birth_*; o upsert de
-- `_createProfile` reescreve email/display_name quando a linha já existe
-- (login social de conta antiga); e signup_platform é preenchido logo em
-- seguida. `id` fica FORA: reatribuir a linha para outro dono não é edição
-- de perfil.
GRANT UPDATE (
  email,
  display_name,
  photo_url,
  birth_date,
  birth_time,
  birth_place,
  signup_platform,
  updated_at
) ON public.profiles TO authenticated;


-- ----------------------------------------------------------------------------
-- 2b. SOBRE OS CONTADORES DIÁRIOS — O QUE A AUDITORIA SUPÔS E O CÓDIGO NEGA
-- ----------------------------------------------------------------------------
-- A auditoria decidiu mover os contadores para uma função SECURITY DEFINER
-- "como o resgate", partindo de que "hoje o app escreve esses contadores do
-- cliente". Isso NÃO se confirma: no repositório inteiro há sete leituras das
-- colunas de contador (supabase_auth_repository, ao montar o UserModel no
-- login) e ZERO escritas. Quem guarda o uso do dia é o SharedPreferences do
-- aparelho, via `_saveUser` do auth_provider.
--
-- Ou seja: não existe escrita do cliente para mover para o servidor. Uma
-- função SECURITY DEFINER de contador criaria um caminho de escrita que hoje
-- não existe — o oposto do que se quer aqui.
--
-- O buraco em si é real e continua fechado: as colunas de contador ficaram de
-- fora do GRANT da seção 2, então o PATCH que zerava os próprios limites
-- passa a ser negado pelo banco. É o mesmo resultado, sem código novo.
--
-- Fica um efeito colateral conhecido e anterior a tudo isto: como o contador
-- vive no aparelho, desinstalar e reinstalar zera o uso do dia. Consertar
-- isso é escrever contador no servidor — projeto à parte, não este.


-- ----------------------------------------------------------------------------
-- 3. AS POLÍTICAS QUE FALTAVAM
-- ----------------------------------------------------------------------------
-- (a) WITH CHECK no UPDATE. Sem ele o Postgres valida só a linha ANTIGA:
--     a linha resultante nunca é conferida. O grant de coluna acima já tira
--     `id` do alcance, mas a política é a segunda rede — e é ela que aparece
--     no painel, onde alguém vai procurar por que a tabela está segura.
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- (b) DELETE. Não existia política nenhuma de DELETE em profiles, então a
--     exclusão de conta do app NUNCA apagou a linha: o erro caía num catch
--     que o ignorava, e o perfil sobrevivia à exclusão com e-mail e data de
--     nascimento dentro. As 20 tabelas de dados já têm a política; profiles
--     era a única sem.
DROP POLICY IF EXISTS "Users can delete own profile" ON public.profiles;
CREATE POLICY "Users can delete own profile" ON public.profiles
  FOR DELETE
  USING (auth.uid() = id);

GRANT DELETE ON public.profiles TO authenticated;


-- ----------------------------------------------------------------------------
-- 4. AS FUNÇÕES QUE ESCREVEM `profiles` COMO DONAS DO BANCO
-- ----------------------------------------------------------------------------
-- Depois do REVOKE, estas duas são o único caminho de escrita em `role` e
-- `plan`. Uma função SECURITY DEFINER sem `SET search_path` resolve nomes
-- pelo search_path de quem chama: dá para plantar um `profiles` num schema
-- próprio e fazer a função escrever lá. Nenhuma das duas tinha o `SET`.

-- (a) Resgate de Código Premium. Mantido como está por decisão de produto —
--     é o que dá autonomia de criar e distribuir cupons pelo app. Duas
--     mudanças, nenhuma altera o comportamento do caminho feliz:
--       · SET search_path = public
--       · quando há sessão, o premium vai para auth.uid() e o p_user_id é
--         ignorado. Sem isso, quem tem um código válido escolhe em QUAL
--         perfil ele cai. O parâmetro continua na assinatura porque o resgate
--         sem login (usuária local, id 'local_user') também é suportado.
CREATE OR REPLACE FUNCTION public.redeem_beta_code(p_code TEXT, p_user_id TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_row    beta_codes%ROWTYPE;
  v_target TEXT;
BEGIN
  -- Sessão manda; o parâmetro só vale para o resgate sem login.
  v_target := COALESCE(auth.uid()::text, p_user_id);

  UPDATE beta_codes
     SET current_uses = current_uses + 1,
         is_used      = (current_uses + 1 >= max_uses),
         used_by      = v_target,
         used_at      = NOW()
   WHERE code = UPPER(TRIM(p_code))
     AND is_used = false
     AND current_uses < max_uses
  RETURNING * INTO v_row;

  IF NOT FOUND THEN
    -- Distinguir "não existe" de "já usado/invalidado"
    IF EXISTS (SELECT 1 FROM beta_codes WHERE code = UPPER(TRIM(p_code))) THEN
      RETURN jsonb_build_object(
        'success', false,
        'message', 'Este código já foi utilizado'
      );
    END IF;
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Código inválido'
    );
  END IF;

  -- Persiste o premium no perfil, MAS somente quando o alvo é um UUID de
  -- conta Supabase. Usuárias anônimas/locais (ex.: 'local_user') também
  -- resgatam códigos — sem este guard o cast ::uuid lançaria exceção e
  -- reverteria a transação inteira, queimando o cupom sem entregar nada.
  IF v_target ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN
    UPDATE public.profiles
       SET role       = 'premium',
           plan       = 'lifetime',
           updated_at = NOW()
     WHERE id = v_target::uuid;
  END IF;

  -- Não expor usos restantes na mensagem: evita que a pessoa repasse o
  -- código sabendo que outras ainda podem usá-lo.
  RETURN jsonb_build_object(
    'success', true,
    'message', 'Código resgatado! Você agora tem acesso Premium vitalício 🎉',
    'current_uses', v_row.current_uses,
    'max_uses', v_row.max_uses
  );
END;
$$;

-- ANON NÃO EXECUTA. Esta função é SECURITY DEFINER e concede Premium
-- VITALÍCIO — e `anon` significa "qualquer pessoa com a chave anônima", que
-- vive dentro do bundle por natureza e é pública por desenho. Com o grant
-- para `anon`, qualquer um chama /rest/v1/rpc/redeem_beta_code sem conta e
-- sem rastro, quantas vezes quiser, chutando código.
--
-- Não é escalada direta (precisa acertar um código), é força bruta — e a
-- função não tem limite de tentativas. Sem sessão também não há a quem
-- atribuir a tentativa.
--
-- Exigir sessão fecha os dois de uma vez, e casa com a decisão de produto
-- de que o app exige conta: quem resgata um código já está logada.
REVOKE EXECUTE ON FUNCTION public.redeem_beta_code(TEXT, TEXT) FROM anon, PUBLIC;
GRANT EXECUTE ON FUNCTION public.redeem_beta_code(TEXT, TEXT) TO authenticated;

-- ATENÇÃO ao rodar: se alguma tela oferecer o resgate ANTES do login, ela
-- passa a receber 403. Confira o fluxo antes — hoje o resgate vive na
-- página de Assinatura, que já exige conta.

-- (b) Criação automática da linha no signup. Roda como dona do banco (é
--     trigger em auth.users), então o REVOKE acima não a atinge — mas ela
--     também estava sem `SET search_path`.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'display_name',
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;


-- ============================================================================
-- 5. CONFERÊNCIA — rode depois e leia a saída
-- ============================================================================
-- (a) `anon` não deve aparecer NENHUMA vez, e `authenticated` deve aparecer
--     só nas colunas das listas acima (mais SELECT/DELETE na tabela).
--
--   SELECT grantee, privilege_type, column_name
--     FROM information_schema.column_privileges
--    WHERE table_schema = 'public' AND table_name = 'profiles'
--      AND grantee IN ('anon', 'authenticated')
--    ORDER BY grantee, privilege_type, column_name;
--
-- (b) A política de UPDATE precisa mostrar with_check preenchido, e deve
--     existir uma linha de DELETE.
--
--   SELECT cmd, qual, with_check
--     FROM pg_policies
--    WHERE schemaname = 'public' AND tablename = 'profiles'
--    ORDER BY cmd;
--
-- (c) O teste que importa: logada como uma conta comum, isto tem que FALHAR
--     com "permission denied for column role of relation profiles".
--
--   UPDATE public.profiles SET role = 'admin' WHERE id = auth.uid();
--
-- (d) E isto tem que continuar funcionando (é o que a tela de perfil faz):
--
--   UPDATE public.profiles SET display_name = 'teste' WHERE id = auth.uid();
--
-- ----------------------------------------------------------------------------
-- DEPOIS DE RODAR: quem já se promoveu a admin continua admin. Confira e
-- rebaixe quem não deveria estar lá:
--
--   SELECT id, email, role, plan, created_at FROM public.profiles
--    WHERE role = 'admin' OR plan = 'lifetime'
--    ORDER BY created_at;
-- ============================================================================
