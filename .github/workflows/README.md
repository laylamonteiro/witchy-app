# 🌙 GitHub Actions Workflows - Grimório de Bolso

Este diretório contém os workflows de CI/CD do Grimório de Bolso com **arquitetura paralela** otimizada.

## 📋 Workflows Disponíveis

### 🚀 release-parallel.yml - Build & Release (Paralelo)

**Dispara em:**
- Tags de versão (ex: `v1.0.0`)
- Manualmente via GitHub Actions UI

**O que faz:**
- ✅ Incrementa versão (build/patch/minor/major)
- ✅ Valida código (analyze + tests)
- ✅ **Builda APK e AAB EM PARALELO** ⚡ (~30% mais rápido!)
- ✅ Gera debug symbols
- ✅ Cria GitHub Release
- ✅ Upload para Play Store (opcional)
- ✅ Gera resumo final

**Arquitetura Paralela:**
```
Prepare (1 min) → Validate (3 min) → ┌─ Build APK (7 min) ─┐ → Release → Summary
                                      └─ Build AAB (7 min) ─┘   (1 min)   (<1 min)
                                      ↑                        ↑
                                      Rodam simultaneamente! ⚡

Total: ~14 minutos (vs ~19 min sequencial)
```

**Como usar:**

1. **Via GitHub UI** (Recomendado):
   ```
   GitHub → Actions → 🚀 Build & Release Android (Parallel) → Run workflow
   ```
   - Escolha o tipo de incremento (build/patch/minor/major)
   - Marque opções desejadas (create release, upload to play store)

2. **Via tag**:
   ```bash
   git tag v1.1.0
   git push origin v1.1.0
   ```

**Tempo estimado:** ~14 minutos

---

### 🔄 auto-increment.yml - Auto Increment Version

**Dispara em:**
- Push para `main` (automaticamente)

**O que faz:**
- ✅ Incrementa build number automaticamente (+1)
- ✅ Commita mudança no pubspec.yaml
- ✅ Evita loops infinitos ([skip ci])

**Exemplo:**
```
Merge de PR → workflow roda → versão vai de 1.0.0+5 para 1.0.0+6
```

**Benefício:**
- ❌ NUNCA MAIS: "Version code already used" na Play Store
- ✅ Versionamento automático e sem esforço

**Tempo estimado:** <1 minuto

---

### 🧪 ci.yml - Pull Request Validation

**Dispara em:**
- Pull Requests para `main` ou `develop`

**O que faz:**
- ✅ Valida formatação do código
- ✅ Roda `flutter analyze`
- ✅ Roda testes unitários
- ✅ Testa build de debug APK
- ✅ Gera relatório de coverage (opcional)

**Benefício:**
- Valida código ANTES de mergear
- Previne bugs em produção
- Mantém qualidade do código

**Tempo estimado:** ~5-7 minutos

---

## 🎯 Fluxo de Trabalho Recomendado

### Desenvolvimento Diário

1. **Criar feature branch**
   ```bash
   git checkout -b feature/nova-funcionalidade
   ```

2. **Desenvolver**
   ```bash
   # Código, commits, etc.
   ```

3. **Abrir Pull Request**
   ```bash
   git push origin feature/nova-funcionalidade
   ```
   - ✅ CI roda automaticamente e valida código
   - Vê status no PR: ✅ ou ❌

4. **Merge para main**
   ```bash
   # Após aprovação do PR
   ```
   - ✅ Auto-increment roda automaticamente
   - Versão incrementada: 1.0.0+5 → 1.0.0+6

### Fazer Release

**Opção 1: Via GitHub UI** (Mais fácil)

1. Acesse: `https://github.com/laylamonteiro/witchy-app/actions`
2. Clique em: **🚀 Build & Release Android (Parallel)**
3. Clique em: **Run workflow**
4. Configure:
   - Branch: `main`
   - Increment type: `build` / `patch` / `minor` / `major`
   - Create release: ✅
   - Upload to Play Store: ✅ / ❌
5. Aguarde ~14 minutos
6. Baixe APK/AAB dos artifacts ou da release

**Opção 2: Via tag** (Mais avançado)

```bash
# Cria tag
git tag v1.1.0

# Push da tag
git push origin v1.1.0

# Workflow roda automaticamente
```

---

## 📦 Artifacts Gerados

Cada workflow gera artifacts que ficam disponíveis por 30 dias:

- **apk-release**: APK pronto para instalação direta
- **aab-release**: AAB pronto para Play Store
- **debug-symbols**: Símbolos de depuração para Play Console
- **pubspec-yaml**: pubspec.yaml com versão atualizada

**Onde baixar:**
1. GitHub → Actions → Clica no workflow executado
2. Scroll até o final → Seção "Artifacts"
3. Download do arquivo desejado

---

## 🔐 Secrets Necessários

Configure em: `https://github.com/laylamonteiro/witchy-app/settings/secrets/actions`

### Obrigatórios (para builds funcionarem):

| Secret | Descrição |
|--------|-----------|
| `SUPABASE_URL` | URL do projeto Supabase |
| `SUPABASE_ANON_KEY` | Anon key do Supabase |
| `GOOGLE_SERVICES_JSON` | google-services.json (base64) |

### Para assinatura de AAB (Play Store):

| Secret | Descrição |
|--------|-----------|
| `ANDROID_KEYSTORE_BASE64` | Keystore em base64 |
| `ANDROID_KEY_ALIAS` | Alias da chave (ex: `upload`) |
| `ANDROID_KEY_PASSWORD` | Senha da chave |
| `ANDROID_STORE_PASSWORD` | Senha do keystore |
| `ANDROID_KEYSTORE_TYPE` | Tipo (JKS ou PKCS12) |

### Para upload automático na Play Store (opcional):

| Secret | Descrição |
|--------|-----------|
| `PLAY_STORE_JSON_KEY` | Service Account JSON da Play Console |

### Para coverage reports (opcional):

| Secret | Descrição |
|--------|-----------|
| `CODECOV_TOKEN` | Token do Codecov.io |

---

## ⚙️ Permissões do GitHub Actions

Configure em: `https://github.com/laylamonteiro/witchy-app/settings/actions`

**Workflow permissions:**
- ✅ Read and write permissions
- ✅ Allow GitHub Actions to create and approve pull requests

Sem essas permissões, workflows que fazem commit (auto-increment) falharão.

---

## 🐛 Troubleshooting

### Erro: "Permission denied when pushing"

**Causa:** Permissões do GitHub Actions não configuradas

**Solução:**
1. Settings → Actions → Workflow permissions
2. Marque "Read and write permissions"
3. Salve

### Erro: "Version code already used"

**Causa:** Build number duplicado na Play Store

**Solução:**
- Use o workflow auto-increment (já configurado!)
- Ou: rode `./scripts/bump_version.sh build` localmente antes do build

### Erro: "Keystore password was incorrect"

**Causa:** Secrets de assinatura incorretos

**Solução:**
1. Verifique secrets no GitHub (nomes exatos, valores corretos)
2. Re-gere keystore se necessário
3. Encode em base64: `base64 -w 0 < release.keystore`

### Workflow não dispara

**Causa:** Branch ou path-ignore incorretos

**Solução:**
- Verifique se está fazendo push para branch correta (`main`)
- Commits em `*.md` ou `docs/` são ignorados por padrão

### Build paralelo falha mas o outro passa

**Comportamento:** NORMAL! É o propósito da arquitetura paralela.

**O que fazer:**
- Veja logs do job que falhou
- Corrija o problema específico
- Re-rode apenas aquele job se possível
- O outro build permanece disponível

---

## 🎨 Personalizações

### Desabilitar build de APK

Se você só precisa do AAB (Play Store):

1. Edite `release-parallel.yml`
2. Comente o job `build-apk` inteiro
3. Remova `build-apk` de `needs` no job `create-release`

### Mudar track de upload da Play Store

Edite `release-parallel.yml`, job `upload-play-store`:

```yaml
track: internal  # Opções: internal, alpha, beta, production
```

### Adicionar mais tipos de build

Copie o job `build-apk` ou `build-aab` e modifique:

```yaml
build-debug-apk:
  name: 📱 Build Debug APK
  # ...
  steps:
    - name: Build Debug APK
      run: flutter build apk --debug
```

---

## 📊 Comparação: Sequencial vs Paralelo

### Workflow Antigo (Sequencial):

```
Prepare → Validate → Build APK → Build AAB → Release
1 min     3 min      7 min        7 min       1 min
───────────────────────────────────────────────────
Total: ~19 minutos
```

### Workflow Novo (Paralelo): ⚡

```
Prepare → Validate → ┌─ Build APK (7 min) ─┐ → Release → Summary
1 min     3 min      └─ Build AAB (7 min) ─┘   1 min     <1 min
                     ↑ Rodam ao mesmo tempo! ⚡
───────────────────────────────────────────────────────────────
Total: ~14 minutos (economia de ~5 min / ~30%)
```

### Benefícios da Paralelização:

- ⚡ **30-40% mais rápido**
- 🛡️ **Falhas isoladas** (se APK falhar, AAB continua)
- 📊 **Visibilidade** (logs separados por job)
- 🔧 **Manutenível** (jobs pequenos e focados)
- 🎯 **Flexível** (fácil adicionar/remover builds)

---

## 📚 Mais Documentação

Para guias mais detalhados, veja:

- `docs/actions/COMECE_AQUI.txt` - Visão geral e início rápido
- `docs/actions/ARQUITETURA_PARALELA.txt` - Detalhes da arquitetura
- `docs/actions/FLUXO_PARALELO_JOBS.txt` - Diagrama visual dos jobs
- `docs/actions/GITHUB_ACTIONS_SETUP.txt` - Configuração completa

---

## 💡 Dicas e Boas Práticas

### Versionamento Semântico

- **Major** (1.0.0 → 2.0.0): Breaking changes
- **Minor** (1.0.0 → 1.1.0): Novas funcionalidades
- **Patch** (1.0.0 → 1.0.1): Bug fixes
- **Build** (1.0.0+5 → 1.0.0+6): Builds incrementais

### Quando usar cada tipo:

- **build**: Para cada build de teste interno
- **patch**: Correções de bugs em produção
- **minor**: Nova funcionalidade
- **major**: Mudanças grandes, breaking changes

### Testes antes de release:

1. Sempre rode CI em PRs
2. Teste localmente: `flutter test`
3. Teste build local: `flutter build appbundle --release`
4. Só então dispare o workflow de release

### Otimizando tempo de build:

- Use cache (já configurado!)
- Evite rebuild desnecessários
- Splits de jobs para tarefas independentes (já implementado!)

---

## 🆘 Precisa de Ajuda?

1. **Veja logs**: GitHub Actions → Workflow executado → Logs detalhados
2. **Documentação**: `docs/actions/` tem guias completos
3. **Issues**: https://github.com/laylamonteiro/witchy-app/issues

---

🌙 **Grimório de Bolso** - Builds paralelos com GitHub Actions ⚡

*Feito com magia e automação* ✨
