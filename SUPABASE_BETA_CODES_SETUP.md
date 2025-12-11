# 🔧 Configuração dos Códigos Beta no Supabase

## 📋 Problema Identificado

Os códigos beta não estão sendo salvos nem consultados no Supabase porque:

**🎯 CAUSA RAIZ: Políticas RLS (Row Level Security) bloqueando acesso**

- ❌ As políticas RLS atuais exigem autenticação (`TO authenticated`)
- ❌ O app não implementa autenticação Supabase (usa autenticação local)
- ❌ Resultado: INSERT e SELECT são bloqueados silenciosamente

## ✅ Solução

As políticas RLS foram atualizadas para permitir **acesso anônimo** (sem autenticação), pois:

1. Códigos beta são compartilhados entre usuários (não são dados sensíveis)
2. O app atual não usa autenticação Supabase
3. A validação de regras de negócio (código já usado, etc.) é feita no app

## 🚀 Instruções de Instalação

### Passo 1: Acessar o Supabase SQL Editor

1. Acesse o dashboard do Supabase: https://supabase.com/dashboard
2. Selecione o projeto: **jdncobtussylzfabrebe**
3. Vá para: **SQL Editor** (menu lateral esquerdo)

### Passo 2: Executar o Script de Políticas RLS

1. No SQL Editor, clique em **"+ New query"**
2. Copie TODO o conteúdo do arquivo `supabase_rls_policies_beta_codes.sql`
3. Cole no editor SQL
4. Clique em **"Run"** (ou pressione Ctrl+Enter)
5. Aguarde a mensagem de sucesso ✅

### Passo 3: Verificar as Políticas

Execute esta query para verificar se as políticas foram criadas:

```sql
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies
WHERE tablename = 'beta_codes';
```

**Resultado esperado:** 4 políticas criadas:
- ✅ `Permitir acesso anônimo para SELECT`
- ✅ `Permitir acesso anônimo para INSERT`
- ✅ `Permitir acesso anônimo para UPDATE`
- ✅ `Permitir acesso anônimo para DELETE`

### Passo 4: Testar no App

1. Abra o app
2. Vá para **Configurações → Gerenciar Códigos Beta**
3. Crie um código de teste (ex: `TESTE123`)
4. Clique no botão **Debug** (ícone de bug no topo)
5. Execute **"Diagnóstico Completo"**

**Resultado esperado:**
```
3️⃣ CÓDIGOS NO SUPABASE:
   Total: 1 códigos  (ou mais se já houver códigos)
   Últimos 3:
     • TESTE123 (usado: false)
```

## 📊 Estrutura da Tabela

A tabela `beta_codes` deve ter esta estrutura:

```sql
CREATE TABLE beta_codes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code TEXT NOT NULL UNIQUE,
  is_used BOOLEAN NOT NULL DEFAULT false,
  used_by TEXT,
  used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**NOTA:** Se a tabela não existir ou estiver diferente, execute também o arquivo `supabase_beta_codes_schema.sql` ANTES das políticas RLS.

## 🔒 Notas de Segurança

### Acesso Público
Este setup permite acesso público total à tabela `beta_codes`. Isso é **aceitável** porque:
- Códigos beta são compartilhados (não contêm dados sensíveis de usuário)
- A validação de regras de negócio está no app
- O volume de códigos é baixo

### Melhorias Futuras (Opcional)
Para produção de alta escala, considere:
1. Implementar autenticação Supabase no app
2. Criar Edge Function para criar códigos (restringir INSERT a admins)
3. Adicionar rate limiting no Supabase
4. Implementar validações adicionais nas políticas RLS

## ❓ Troubleshooting

### Problema: Ainda não salva no Supabase após aplicar as políticas

**Solução:**
1. Verifique se RLS está habilitado:
   ```sql
   SELECT tablename, rowsecurity FROM pg_tables
   WHERE tablename = 'beta_codes';
   ```
   - Se `rowsecurity = false`, execute: `ALTER TABLE beta_codes ENABLE ROW LEVEL SECURITY;`

2. Verifique as variáveis de ambiente:
   - `SUPABASE_URL` deve estar configurada
   - `SUPABASE_ANON_KEY` deve estar configurada

3. Execute o diagnóstico no app (botão Debug) e verifique os logs

### Problema: Erro "permission denied" ao executar SQL

**Solução:**
- Certifique-se de estar logado com uma conta que tem permissões de admin no projeto Supabase
- Se estiver usando service_role key, troque por anon key temporariamente

### Problema: Códigos aparecem no SQLite mas não no Supabase

**Solução:**
- Isso significa que o INSERT no Supabase está falhando
- Execute o diagnóstico e procure por mensagens de erro detalhadas nos logs do repositório
- Verifique se as políticas RLS foram aplicadas corretamente

## 📞 Suporte

Se o problema persistir:
1. Exporte os logs completos do diagnóstico (botão copiar)
2. Verifique os logs do Supabase (Dashboard → Logs)
3. Confira se há erros no console do Flutter (`flutter logs`)
