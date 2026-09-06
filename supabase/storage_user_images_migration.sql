-- Bucket privado das fotos das usuárias (`user-images`) e as políticas de
-- acesso por pasta da conta. Rode no SQL Editor do Supabase; é idempotente
-- (pode rodar de novo sem efeito colateral).
--
-- O bucket já existe em produção — foi criado no painel — e este arquivo fixa
-- no repositório o que antes só vivia lá. Caminho dos objetos:
-- `{uid}/{pasta}/{id}.jpg`. A PRIMEIRA pasta é o auth.uid(), e é ela que
-- isola uma conta da outra. `pasta` é `herbs`/`crystals` (verbetes pessoais
-- da Enciclopédia; `id` = id do verbete, então a foto e a linha do banco se
-- encontram sem coluna extra) ou `avatar` (foto de perfil, com uuid).
--
-- UPDATE é obrigatório: o app envia com upsert (caminho determinístico), e
-- reenviar a mesma foto — retry sem rede, migração de foto antiga do celular
-- — é um UPDATE do objeto, não um INSERT.
--
-- `(select auth.uid())` em vez de `auth.uid()`: a mesma forma de
-- rls_initplan_optimization_migration.sql (avalia uma vez por consulta).

INSERT INTO storage.buckets (id, name, public)
VALUES ('user-images', 'user-images', false)
ON CONFLICT (id) DO UPDATE SET public = false;

DROP POLICY IF EXISTS "user-images: ler a própria pasta" ON storage.objects;
CREATE POLICY "user-images: ler a própria pasta"
  ON storage.objects FOR SELECT TO authenticated
  USING (
    bucket_id = 'user-images'
    AND (storage.foldername(name))[1] = (select auth.uid())::text
  );

DROP POLICY IF EXISTS "user-images: enviar na própria pasta" ON storage.objects;
CREATE POLICY "user-images: enviar na própria pasta"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'user-images'
    AND (storage.foldername(name))[1] = (select auth.uid())::text
  );

DROP POLICY IF EXISTS "user-images: regravar na própria pasta" ON storage.objects;
CREATE POLICY "user-images: regravar na própria pasta"
  ON storage.objects FOR UPDATE TO authenticated
  USING (
    bucket_id = 'user-images'
    AND (storage.foldername(name))[1] = (select auth.uid())::text
  )
  WITH CHECK (
    bucket_id = 'user-images'
    AND (storage.foldername(name))[1] = (select auth.uid())::text
  );

DROP POLICY IF EXISTS "user-images: apagar da própria pasta" ON storage.objects;
CREATE POLICY "user-images: apagar da própria pasta"
  ON storage.objects FOR DELETE TO authenticated
  USING (
    bucket_id = 'user-images'
    AND (storage.foldername(name))[1] = (select auth.uid())::text
  );
