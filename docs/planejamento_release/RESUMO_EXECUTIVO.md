# 📊 RESUMO EXECUTIVO - Grimório de Bolso
## Dashboard de Progresso dos Ajustes Finais

---

## 🎯 Visão Geral do Projeto

**Status Atual**: 🟡 Fase 1 (MVP Local-First) → Transição para Fase 2 (Backend + Premium)

**Objetivo**: Finalizar 11 ajustes críticos para lançamento beta

**Timeline Estimado**: 6-10 dias de desenvolvimento focado

**Prioridade**: 🔴 4 críticos | 🟠 4 importantes | 🟡 3 melhorias

---

## 📈 Dashboard de Progresso

### 🔴 Sprint 1: Fundação Crítica (P0) - Bloqueadores

| # | Ajuste | Complexidade | Tempo | Status | Progresso |
|---|--------|--------------|-------|--------|-----------|
| 1 | ✅ Sistema de Autenticação Obrigatório | Alta | 1-2 dias | ⬜ TODO | 0% █░░░░░░░░░ |
| 5 | ⚠️ Revogação de Acesso Premium | Muito Alta | 2 dias | ⬜ TODO | 0% █░░░░░░░░░ |
| 8 | 🐛 Bug do Grimório Vazio | Média | 0.5 dia | ⬜ TODO | 0% █░░░░░░░░░ |
| 10 | 💾 Sincronização na Nuvem | Muito Alta | 2-3 dias | ⬜ TODO | 0% █░░░░░░░░░ |

**Status Sprint 1**: 0/4 completos • 0% de progresso

---

### 🟠 Sprint 2: Experiência Premium (P1) - UX e Conversão

| # | Ajuste | Complexidade | Tempo | Status | Progresso |
|---|--------|--------------|-------|--------|-----------|
| 2 | 👤 UI Condicional para OAuth | Baixa | 0.5 dia | ⬜ TODO | 0% █░░░░░░░░░ |
| 3 | 💳 Status Premium na UI | Média | 1 dia | ⬜ TODO | 0% █░░░░░░░░░ |
| 4 | 🎨 Padronização de CTAs Premium | Média | 0.5 dia | ⬜ TODO | 0% █░░░░░░░░░ |
| 11 | 🎟️ Sistema de Beta Access | Alta | 1-2 dias | ⬜ TODO | 0% █░░░░░░░░░ |

**Status Sprint 2**: 0/4 completos • 0% de progresso

---

### 🟡 Sprint 3: Polimento e UX (P2) - Melhorias

| # | Ajuste | Complexidade | Tempo | Status | Progresso |
|---|--------|--------------|-------|--------|-----------|
| 6 | 🎭 Consistência de Fontes | Muito Baixa | 0.5 dia | ⬜ TODO | 0% █░░░░░░░░░ |
| 7 | 🎮 Jornadas sem Feitiços Default | Média | 0.5 dia | ⬜ TODO | 0% █░░░░░░░░░ |
| 9 | 🚪 Remover "Entrar sem conta" | Muito Baixa | 0.25 dia | ⬜ TODO | 0% █░░░░░░░░░ |

**Status Sprint 3**: 0/3 completos • 0% de progresso

---

## 🎯 Progresso Global

```
TOTAL: 0/11 ajustes completos

█░░░░░░░░░ 0%

Estimativa de conclusão: -
Tempo investido: 0h
Tempo restante: ~48-80h
```

---

## ✅ Checklist Detalhado por Sprint

### 🔴 SPRINT 1: FUNDAÇÃO CRÍTICA

#### Ajuste #1: Sistema de Autenticação Obrigatório
- [ ] Criar `SplashPage` com verificação de token
- [ ] Atualizar `main.dart` para usar `/splash` como rota inicial
- [ ] Refatorar `AuthProvider` para não persistir sessão local
- [ ] Implementar logout completo (Firebase + Google + SharedPreferences)
- [ ] Testar: install → login → reopen (manter sessão)
- [ ] Testar: install → login → logout → reopen (pedir login)
- [ ] Testar: install → login → uninstall → reinstall (pedir login)
- [ ] Documentar fluxo de autenticação

**Entregáveis**:
- ✅ `lib/features/auth/presentation/pages/splash_page.dart`
- ✅ `lib/core/providers/auth_provider.dart` (refatorado)
- ✅ `lib/main.dart` (atualizado)

---

#### Ajuste #5: Revogação de Acesso Premium
- [ ] Criar `SubscriptionService` com verificação Google Play
- [ ] Implementar método `checkSubscriptionStatus()`
- [ ] Implementar método `verifyWithBackend()`
- [ ] Criar job periódico de sincronização (6h)
- [ ] Integrar no app startup (após login)
- [ ] Implementar backend: endpoint `/webhook/google-play`
- [ ] Implementar backend: endpoint `/subscription/verify`
- [ ] Configurar Google Play Real-time Developer Notifications
- [ ] Testar: compra → acesso concedido
- [ ] Testar: cancelamento → acesso removido
- [ ] Testar: refund → acesso removido imediatamente
- [ ] Documentar integração com payment providers

**Entregáveis**:
- ✅ `lib/core/services/subscription_service.dart`
- ✅ Backend: `/webhook/google-play`
- ✅ Backend: `/subscription/verify`
- ✅ Documentação de integração

---

#### Ajuste #8: Bug do Grimório Vazio
- [ ] Adicionar logs detalhados no `GrimoireProvider`
- [ ] Implementar retry logic (3 tentativas)
- [ ] Garantir inicialização do DB antes de carregar
- [ ] Adicionar seed de feitiços default no primeiro uso
- [ ] Atualizar UI com estados: loading, error, empty, success
- [ ] Testar: abrir app 50x seguidas (stress test)
- [ ] Testar: alternar abas rapidamente
- [ ] Testar: adicionar/remover → reabrir grimório
- [ ] Documentar states e error handling

**Entregáveis**:
- ✅ `lib/features/grimoire/presentation/providers/grimoire_provider.dart` (corrigido)
- ✅ Logs de diagnóstico
- ✅ Testes de carga

---

#### Ajuste #10: Sincronização na Nuvem
- [ ] Criar modelo de sincronização (last-write-wins)
- [ ] Criar `SyncService` com métodos upload/download
- [ ] Implementar fila de sincronização offline
- [ ] Adicionar campos `updatedAt`, `syncedAt`, `isSynced` aos modelos
- [ ] Criar `SyncRepository` para persistência
- [ ] Implementar backend: `/sync/upload`
- [ ] Implementar backend: `/sync/download`
- [ ] Implementar backend: `/sync/conflicts`
- [ ] Adicionar indicador visual de sync status na UI
- [ ] Integrar no app startup (após login)
- [ ] Criar job periódico (30min)
- [ ] Listener de conectividade (sync ao voltar online)
- [ ] Testar: criar offline → sync online
- [ ] Testar: 2 dispositivos → edição simultânea → conflito
- [ ] Testar: sincronizar 100+ itens
- [ ] Documentar estratégia de sync

**Entregáveis**:
- ✅ `lib/core/services/sync_service.dart`
- ✅ `lib/core/repositories/sync_repository.dart`
- ✅ Backend: `/sync/upload`, `/sync/download`, `/sync/conflicts`
- ✅ UI de status de sincronização
- ✅ Documentação de sincronização

---

### 🟠 SPRINT 2: EXPERIÊNCIA PREMIUM

#### Ajuste #2: UI Condicional para OAuth
- [ ] Adicionar campo `authMethod` ao modelo `User`
- [ ] Criar enum `AuthMethod` (emailPassword, google, apple)
- [ ] Detectar método no login (Google vs Email)
- [ ] Criar widget `PasswordSection` condicional
- [ ] Integrar em `SettingsPage`
- [ ] Testar: login Google → não mostrar "Alterar senha"
- [ ] Testar: login Email → mostrar "Alterar senha"

**Entregáveis**:
- ✅ `lib/core/models/user.dart` (com authMethod)
- ✅ `lib/features/settings/presentation/widgets/password_section.dart`

---

#### Ajuste #3: Status Premium na UI
- [ ] Criar widget `PremiumStatusCard`
- [ ] Mostrar status: Premium Ativo vs Free
- [ ] Exibir tipo de assinatura (mensal/anual)
- [ ] Exibir data de renovação
- [ ] Botão "Gerenciar" (deep link para Google Play)
- [ ] Botão "Cancelar" com confirmação
- [ ] Implementar lógica de cancelamento
- [ ] Integrar em `SettingsPage`
- [ ] Testar: usuário Premium → ver status correto
- [ ] Testar: usuário Free → ver CTA de upgrade
- [ ] Testar: cancelar assinatura → confirmação

**Entregáveis**:
- ✅ `lib/features/settings/presentation/widgets/premium_status_card.dart`
- ✅ Deep links para stores

---

#### Ajuste #4: Padronização de CTAs Premium
- [ ] Criar componente `PremiumButton` reutilizável
- [ ] Definir estilo padrão (cor lilás, texto escuro)
- [ ] Mapear todas as instâncias de botões Premium no app
- [ ] Substituir por `PremiumButton`
- [ ] Garantir navegação para `/premium` (PaywallPage)
- [ ] Adicionar analytics de cliques (opcional)
- [ ] Testar: todos os CTAs funcionam
- [ ] Testar: design consistente em todos os locais

**Locais para atualizar**:
- [ ] SettingsPage
- [ ] GrimoirePage (limite atingido)
- [ ] DiaryPage (features bloqueadas)
- [ ] EncyclopediaPage (conteúdo bloqueado)
- [ ] AstralMapPage (feature completa)

**Entregáveis**:
- ✅ `lib/core/widgets/premium_button.dart`
- ✅ Lista de locais atualizados

---

#### Ajuste #11: Sistema de Beta Access
- [ ] Criar tabela `beta_codes` no backend
- [ ] Criar tabela `beta_code_redemptions`
- [ ] Implementar backend: `POST /admin/beta-codes`
- [ ] Implementar backend: `POST /beta/redeem`
- [ ] Adicionar rate limiting (1 código/IP/hora)
- [ ] Criar `RedeemCodePage` no app
- [ ] Adicionar acesso em `SettingsPage`
- [ ] Criar script de geração de códigos em lote
- [ ] Gerar 50 códigos beta para testes
- [ ] Testar: resgatar código → obter Premium
- [ ] Testar: código inválido → erro
- [ ] Testar: código expirado → erro
- [ ] Testar: rate limiting funcionando
- [ ] Documentar uso do sistema

**Entregáveis**:
- ✅ Backend: `/admin/beta-codes`, `/beta/redeem`
- ✅ `lib/features/premium/presentation/pages/redeem_code_page.dart`
- ✅ Script de geração de códigos
- ✅ Documentação

---

### 🟡 SPRINT 3: POLIMENTO E UX

#### Ajuste #6: Consistência de Fontes
- [ ] Criar `AppTextStyles.cardTitle()` no tema
- [ ] Auditar uso de fontes em cards da enciclopédia
- [ ] Atualizar `CrystalCard`
- [ ] Atualizar `HerbCard`
- [ ] Atualizar `MetalCard`
- [ ] Atualizar `ColorCard`
- [ ] Validar contra `GoddessCard` (referência)
- [ ] Documentar no design system
- [ ] Testar visualmente todos os cards

**Entregáveis**:
- ✅ `lib/core/theme/text_styles.dart` (atualizado)
- ✅ Documentação de tipografia

---

#### Ajuste #7: Jornadas sem Feitiços Default
- [ ] Adicionar campo `source` ao modelo `Spell`
- [ ] Criar enum `SpellSource` (user, default, imported)
- [ ] Criar migration: `ALTER TABLE spells ADD COLUMN source`
- [ ] Atualizar seeds para marcar como `default`
- [ ] Atualizar `GrimoireProvider` para filtrar por source
- [ ] Atualizar `JourneyProvider` para contar apenas `user`
- [ ] Testar: feitiços default não contam
- [ ] Testar: criar feitiço → progresso da jornada atualiza

**Entregáveis**:
- ✅ `lib/features/grimoire/data/models/spell.dart` (com source)
- ✅ Migration SQL
- ✅ `lib/features/gamification/presentation/providers/journey_provider.dart` (atualizado)

---

#### Ajuste #9: Remover "Entrar sem conta"
- [ ] Atualizar `AuthPage` para remover botão
- [ ] Remover lógica de usuário anônimo
- [ ] Buscar e remover referências: `isAnonymous`, `guestMode`, `skipLogin`
- [ ] Atualizar copy e CTAs
- [ ] Testar: apenas Google e Email disponíveis
- [ ] Atualizar onboarding/documentação

**Entregáveis**:
- ✅ `lib/features/auth/presentation/pages/auth_page.dart` (simplificado)

---

## 📊 Métricas de Sucesso

### Sprint 1 (P0) - Meta: 100%
- [ ] ✅ 0 usuários conseguem entrar sem login
- [ ] ✅ 0 reports de grimório vazio após fix
- [ ] ✅ 100% dos cancelamentos removem acesso Premium
- [ ] ✅ 95%+ de sucesso em sincronizações

### Sprint 2 (P1) - Meta: 95%+
- [ ] ✅ 0 usuários OAuth veem opção de senha
- [ ] ✅ 100% dos usuários Premium veem status correto
- [ ] ✅ 100% dos CTAs Premium funcionam
- [ ] ✅ 30+ beta testers com acesso controlado

### Sprint 3 (P2) - Meta: 100%
- [ ] ✅ 100% consistência tipográfica em cards
- [ ] ✅ Jornadas progridem apenas com feitiços do usuário
- [ ] ✅ 0 confusão sobre modelo de negócio (sem entrada anônima)

---

## 🧪 Plano de Testes Completo

### Testes de Autenticação (após Sprint 1)
- [ ] Instalar app novo → Deve pedir login
- [ ] Login → Fechar → Reabrir → Deve manter sessão
- [ ] Logout → Reabrir → Deve pedir login
- [ ] Desinstalar → Reinstalar → Deve pedir login
- [ ] Background 24h → Reabrir → Verificar token

### Testes de Premium (após Sprint 2)
- [ ] Comprar Premium → Acesso concedido
- [ ] Cancelar Premium → Acesso mantido até fim
- [ ] Fim do período → Acesso removido
- [ ] Refund → Acesso removido imediatamente
- [ ] Resgatar código beta → Premium concedido
- [ ] Usuário Premium → Status correto na UI
- [ ] Todos os CTAs Premium funcionam

### Testes de Sincronização (após Sprint 1)
- [ ] Criar feitiço offline → Conectar → Sync
- [ ] 2 dispositivos → Edição simultânea → Conflito
- [ ] Sincronizar 100+ itens → Performance OK
- [ ] Desconectar no meio → Recovery OK
- [ ] Novo dispositivo → Baixar todos os dados

### Testes de Grimório (após Sprint 1)
- [ ] Abrir 50x seguidas → Nunca vazio
- [ ] Adicionar feitiço → Reabrir → Aparece
- [ ] Vazio → Empty state correto
- [ ] 100+ feitiços → Performance OK

### Testes de UI (após Sprint 3)
- [ ] Fontes consistentes em todos os cards
- [ ] Paleta de cores respeitada
- [ ] Espaçamentos consistentes
- [ ] Dark mode funcionando

---

## 🚀 Próximos Passos

### Após Conclusão dos Ajustes
1. **Code Review Completo**
   - [ ] Revisar todos os PRs
   - [ ] Verificar cobertura de testes
   - [ ] Validar documentação

2. **QA e Testes**
   - [ ] Rodar suite de testes completa
   - [ ] Testes manuais em dispositivos reais
   - [ ] Stress tests e performance

3. **Deploy Beta**
   - [ ] Gerar APK/AAB de teste
   - [ ] Distribuir 50 códigos beta
   - [ ] Convidar 20-30 beta testers
   - [ ] Configurar analytics e crash reporting

4. **Coleta de Feedback**
   - [ ] Formulário de feedback estruturado
   - [ ] Sessões 1-on-1 com beta testers
   - [ ] Monitorar métricas de uso
   - [ ] Ajustar com base no feedback (1-2 semanas)

5. **Preparação para Lançamento**
   - [ ] Screenshots e assets para lojas
   - [ ] Descrição e marketing copy
   - [ ] Vídeo de demonstração
   - [ ] Press kit e comunicados

---

## 📅 Timeline Estimado

```
Semana 1:
├─ Dias 1-2: Sprint 1 (parte 1) - Auth + Bug Grimório
├─ Dias 3-4: Sprint 1 (parte 2) - Premium + Sync
└─ Dia 5: Testes Sprint 1

Semana 2:
├─ Dias 1-2: Sprint 2 - UX Premium
├─ Dia 3: Sprint 3 - Polimento
├─ Dia 4: Testes finais
└─ Dia 5: Deploy beta + documentação

Semana 3-4:
└─ Beta testing + ajustes + preparação para lançamento
```

---

## 💡 Dicas de Implementação

### Priorização Dinâmica
Se encontrar bloqueios ou complexidade inesperada:
1. **Ajustes P0** são inegociáveis - resolver primeiro
2. **Ajustes P1** podem ser simplificados (versão MVP)
3. **Ajustes P2** podem ser adiados para próxima versão

### Commits e Branches
Sugestão de organização:
```
feature/p0-auth-obrigatorio
feature/p0-revogacao-premium
feature/p0-bug-grimorio-vazio
feature/p0-sincronizacao-nuvem
feature/p1-ui-oauth
feature/p1-status-premium
feature/p1-ctas-padronizados
feature/p1-beta-access
feature/p2-fontes-consistentes
feature/p2-jornadas-source
feature/p2-remover-entrada-anonima
```

### Documentação Contínua
Para cada ajuste concluído, atualizar:
- [ ] README.md (se aplicável)
- [ ] CHANGELOG.md
- [ ] Comentários de código
- [ ] Documentação técnica

---

## ✅ Status Final

**Data de Início**: ___/___/2024
**Data de Conclusão**: ___/___/2024
**Tempo Total**: ___ dias

**Ajustes Completos**: 0/11
**Progresso Global**: 0%

**Próxima Etapa**: 🚀 Lançamento Beta

---

**Última Atualização**: 10/12/2024
**Responsável**: Layla Monteiro
**Status**: 🟡 Aguardando início da implementação
