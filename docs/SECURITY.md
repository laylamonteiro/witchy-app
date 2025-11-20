# 🔒 Relatório de Segurança

## Incidente: Exposição de Credenciais OAuth 2.0

### Data do Incidente
20 de Novembro de 2025

### Descrição
Credenciais OAuth 2.0 da API Prokerala foram acidentalmente commitadas e enviadas ao repositório remoto nos commits:
- `f47e25e` - "Configurar autenticação OAuth 2.0 na API Prokerala"
- `47754d3` - Commits anteriores

**Credenciais expostas:**
- Client ID: `1575f4ab-2cde-4be0-9fc9-51d820fbd6e6`
- Client Secret: `CbgSDMjlGuFyEOwLdlMEJXR2MJ6SlFKH2ETbfvpz`
- Client Name: Grimório de Bolso

### Impacto
- **Severidade**: ALTA
- **Escopo**: Acesso não autorizado à API Prokerala usando estas credenciais
- **Duração da exposição**: ~2 horas (até detecção e correção)
- **Histórico do Git**: Credenciais permanecem visíveis no histórico

### Ações Corretivas Tomadas

#### 1. Implementação de Sistema Seguro
✅ **Commit `d45f21f`** - Correções de segurança implementadas:
- Credenciais movidas para arquivo separado (`prokerala_credentials.dart`)
- Arquivo adicionado ao `.gitignore` (não será mais commitado)
- Arquivo exemplo criado sem credenciais reais
- Documentação de segurança completa criada

#### 2. Estrutura de Arquivos Segura
```
lib/features/astrology/data/services/
├── prokerala_credentials.example.dart  ✅ (Git) - Template
├── prokerala_credentials.dart          🔒 (Local) - Credenciais reais
└── external_chart_api.dart             ✅ (Git) - Código limpo
```

#### 3. Documentação
- `CONFIGURAR_API_MAPA_ASTRAL.md`: Guia completo de configuração segura
- `SECURITY.md` (este arquivo): Relatório de incidente

### ⚠️ AÇÃO URGENTE REQUERIDA

**VOCÊ DEVE fazer o seguinte IMEDIATAMENTE:**

1. **Revogar Credenciais Antigas**
   - Acesse: https://api.prokerala.com/
   - Faça login
   - Vá em **"Clients"**
   - Encontre o client **"Grimório de Bolso"** com ID `1575f4ab-2cde-4be0-9fc9-51d820fbd6e6`
   - Clique em **"Delete"** ou **"Regenerate Secret"**

2. **Criar Novas Credenciais**
   - No mesmo painel, crie um novo client
   - Use nome diferente (ex: "Grimório de Bolso v2")
   - Copie as NOVAS credenciais

3. **Configurar Localmente**
   ```bash
   cd lib/features/astrology/data/services/
   cp prokerala_credentials.example.dart prokerala_credentials.dart
   # Edite prokerala_credentials.dart com NOVAS credenciais
   ```

4. **Testar**
   - Compile o app: `flutter build apk --release`
   - Teste o cálculo de mapa astral
   - Verifique se está usando as novas credenciais

### Risco Residual

**Histórico do Git:**
As credenciais antigas permanecem visíveis no histórico do Git. Para removê-las completamente seria necessário:

```bash
# ⚠️ CUIDADO: Isso reescreve o histórico e requer force push
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch lib/features/astrology/data/services/external_chart_api.dart" \
  --prune-empty --tag-name-filter cat -- --all

git push origin --force --all
```

**Decisão pragmática:** NÃO fazer rebase/filter por enquanto, pois:
1. Revogar credenciais antigas é mais rápido e efetivo
2. Force push pode quebrar clones existentes
3. Histórico já foi enviado ao remoto

**Se as credenciais forem revogadas, o risco é NULO.**

### Lições Aprendidas

1. ❌ **NUNCA** commitar credenciais, API keys, ou segredos no código
2. ✅ **SEMPRE** usar arquivos separados + `.gitignore`
3. ✅ **SEMPRE** revisar arquivos antes de commit
4. ✅ Usar arquivos `.example` como templates
5. ✅ Documentar práticas de segurança

### Prevenção Futura

**Ferramentas recomendadas:**
- `git-secrets`: Previne commit de segredos
- `truffleHog`: Detecta segredos no histórico
- Pre-commit hooks: Verificam antes de commitar

**Práticas:**
- Code review antes de push
- Auditoria regular do `.gitignore`
- Rotação periódica de credenciais

### Status Atual

- ✅ Sistema seguro implementado
- ✅ Documentação atualizada
- ✅ `.gitignore` protegendo arquivo de credenciais
- ⏳ **PENDENTE**: Revogar credenciais antigas (VOCÊ deve fazer)
- ⏳ **PENDENTE**: Configurar novas credenciais localmente

### Contato

Se você descobrir qualquer uso não autorizado das credenciais antigas, por favor:
1. Reporte imediatamente à Prokerala: support@prokerala.com
2. Revogue as credenciais
3. Monitore logs de uso no dashboard Prokerala

---

**Última atualização:** 20/11/2025
**Status:** Correções implementadas, aguardando revogação manual

---

## 🔐 Sistema de Credenciais Seguras

### APIs Configuradas

O app utiliza duas APIs externas que requerem credenciais:

#### 1. Prokerala API (Mapas Astrais)
**Arquivo:** `lib/features/astrology/data/services/prokerala_credentials.dart`
- **Client ID**: OAuth 2.0 Client ID
- **Client Secret**: OAuth 2.0 Client Secret
- **Como obter**: https://api.prokerala.com/
- **Custo**: Plano gratuito disponível

#### 2. Groq API (IA para Feitiços)
**Arquivo:** `lib/core/ai/groq_credentials.dart`
- **API Key**: Chave de autenticação Bearer
- **Como obter**: https://console.groq.com/keys
- **Custo**: 100% gratuito

### Estrutura de Arquivos

```
Prokerala:
lib/features/astrology/data/services/
├── prokerala_credentials.example.dart  ✅ (Git) - Template
├── prokerala_credentials.dart          🔒 (Local) - Credenciais reais
└── external_chart_api.dart             ✅ (Git) - Código

Groq:
lib/core/ai/
├── groq_credentials.example.dart       ✅ (Git) - Template
├── groq_credentials.dart               🔒 (Local) - Credenciais reais
└── ai_service.dart                     ✅ (Git) - Código
```

### Proteções no .gitignore

```gitignore
# API Credentials (NEVER commit these!)
**/prokerala_credentials.dart
**/groq_credentials.dart
.env
*.env
```

### Configuração Inicial

Para desenvolvedores que clonarem o repositório:

```bash
# 1. Copiar templates
cd lib/features/astrology/data/services/
cp prokerala_credentials.example.dart prokerala_credentials.dart

cd lib/core/ai/
cp groq_credentials.example.dart groq_credentials.dart

# 2. Editar arquivos com suas credenciais reais
# 3. NUNCA commitar os arquivos *_credentials.dart
```
