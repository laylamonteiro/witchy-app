# Páginas Públicas - Grimório de Bolso

Este diretório contém páginas HTML públicas necessárias para publicação na Google Play Store.

## 📄 Arquivos

### 1. `privacy-policy.html`
Política de Privacidade completa do aplicativo.

**URL pública (após configurar GitHub Pages):**
```
https://laylamonteiro.github.io/witchy-app/privacy-policy.html
```

### 2. `data-deletion.html`
Página com instruções para exclusão de conta e dados pessoais.

**URL pública (após configurar GitHub Pages):**
```
https://laylamonteiro.github.io/witchy-app/data-deletion.html
```

## 🚀 Como Configurar GitHub Pages

Para disponibilizar essas páginas publicamente de forma gratuita via GitHub Pages:

### Passo 1: Ativar GitHub Pages

1. Vá até o repositório no GitHub: `https://github.com/laylamonteiro/witchy-app`
2. Clique em **Settings** (Configurações)
3. No menu lateral, clique em **Pages**
4. Em **Source** (Origem), selecione:
   - **Branch**: `main`
   - **Folder**: `/docs`
5. Clique em **Save** (Salvar)

### Passo 2: Aguardar Deploy

- O GitHub levará alguns minutos para processar
- Uma mensagem verde aparecerá com a URL:
  `Your site is live at https://laylamonteiro.github.io/witchy-app/`

### Passo 3: Verificar URLs

Teste as URLs em um navegador:

- **Política de Privacidade:**
  `https://laylamonteiro.github.io/witchy-app/privacy-policy.html`

- **Exclusão de Dados:**
  `https://laylamonteiro.github.io/witchy-app/data-deletion.html`

## 📱 Como Usar na Play Store

Quando estiver publicando ou atualizando o app na Google Play Console:

### 1. Política de Privacidade (OBRIGATÓRIO)

**Onde configurar:**
- Play Console → Seu App → **App content** (Conteúdo do app) → **Privacy policy** (Política de privacidade)

**URL para inserir:**
```
https://laylamonteiro.github.io/witchy-app/privacy-policy.html
```

### 2. Exclusão de Dados (OBRIGATÓRIO)

**Onde configurar:**
- Play Console → Seu App → **App content** → **Data safety** (Segurança de dados)
- Na seção "Data deletion" (Exclusão de dados), selecione:
  - ✅ "Sim, os usuários podem solicitar que seus dados sejam excluídos"

**URL para inserir:**
```
https://laylamonteiro.github.io/witchy-app/data-deletion.html
```

**OU email de contato:**
```
privacidade@grimoriodebolso.com.br
```

## ⚠️ Importante

### Email de Privacidade

As páginas HTML referenciam o email: `privacidade@grimoriodebolso.com.br`

**Se este email não existir ainda:**

1. **Opção 1 (Recomendada):** Crie o email `privacidade@grimoriodebolso.com.br` e configure redirecionamento para seu email pessoal

2. **Opção 2:** Substitua todas as ocorrências nas páginas HTML por um email que você já use:
   ```bash
   # Edite os arquivos e substitua:
   privacidade@grimoriodebolso.com.br
   # Por:
   seu-email@gmail.com
   ```

3. **Opção 3:** Use apenas o formulário in-app (mas ainda precisa de uma URL pública na Play Store)

### Domínio Próprio (Opcional)

Se você tiver um domínio próprio (ex: `www.grimoriodebolso.com.br`), pode configurar:

1. No GitHub Pages Settings, adicione **Custom domain**: `www.grimoriodebolso.com.br`
2. Configure DNS do domínio para apontar para GitHub Pages
3. As URLs ficariam:
   - `https://www.grimoriodebolso.com.br/privacy-policy.html`
   - `https://www.grimoriodebolso.com.br/data-deletion.html`

**Mas isso é OPCIONAL** - GitHub Pages gratuito funciona perfeitamente!

## 🔄 Atualizações

Para atualizar as políticas:

1. Edite os arquivos HTML nesta pasta (`docs/`)
2. Faça commit e push:
   ```bash
   git add docs/
   git commit -m "Atualizar política de privacidade"
   git push
   ```
3. GitHub Pages atualizará automaticamente em alguns minutos

## ✅ Checklist Play Store

Antes de submeter para revisão na Play Store:

- [ ] GitHub Pages ativado e funcionando
- [ ] Testei ambas as URLs no navegador
- [ ] Configurei URL da política de privacidade na Play Console
- [ ] Configurei URL/email de exclusão de dados na Play Console
- [ ] Email de privacidade existe ou foi substituído por um válido
- [ ] Revisei o conteúdo das políticas para garantir que reflete o app

## 📞 Dúvidas?

Se tiver problemas ao configurar, verifique:

- [Documentação GitHub Pages](https://docs.github.com/en/pages)
- [Play Console Help - Privacy Policy](https://support.google.com/googleplay/android-developer/answer/9859455)
- [Play Console Help - Data Safety](https://support.google.com/googleplay/android-developer/answer/10787469)

---

✨ **Pronto!** Com essas páginas configuradas, você atende todos os requisitos de privacidade da Play Store.
