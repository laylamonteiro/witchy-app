# Roadmap - Grimório de Bolso

## Visão Geral das Fases

| Fase | Nome | Status |
|------|------|--------|
| 1 | MVP Local-First | ✅ Completo |
| 2 | Backend + Conta + IA | 🔄 Parcial (Local) |
| 3 | Premium 1.0 | 🔄 Parcial (Local) |
| 4 | Premium 2.0: Astrologia | ✅ Completo |
| 5 | Refinos e Conteúdo | 🔄 Parcial |

---

## Fase 1 - MVP Local-First ✅

### Calendário Lunar ✅
- [x] Fases da lua (nova, crescente, cheia, minguante)
- [x] Datas das próximas fases importantes
- [x] Significado de cada fase
- [x] Recomendações para tipos de feitiços

### Grimório Digital ✅
- [x] CRUD completo de feitiços
- [x] Campos: nome, propósito, tipo, fase lunar, ingredientes, passos
- [x] Busca e filtros (com feedback visual)
- [x] Visualização detalhada

### Diários ✅
- [x] Diário de Sonhos (título, descrição, tags, sentimentos)
- [x] Diário de Desejos (status, evolução, manifestação)
- [x] Diário de Gratidão
- [x] Afirmações

### Enciclopédia Mágica ✅
- [x] Cristais (6 básicos)
- [x] Cores (12 cores)
- [x] Ervas
- [x] Metais
- [x] Deusas
- [x] Elementos
- [x] Altar

---

## Fase 2 - Backend + Conta + IA 🔄

### Etapa 2.1 - Infraestrutura de Autenticação (LOCAL) ✅
- [x] Modelo de usuário (`UserModel`) - **Implementado localmente**
- [x] `AuthProvider` com SharedPreferences
- [x] Sistema de roles (free, premium, admin)
- [ ] **FALTA**: Escolher backend (Firebase Auth / Supabase)
- [ ] **FALTA**: Configurar projeto no backend escolhido
- [ ] **FALTA**: Implementar `AuthRepository` com backend real

### Etapa 2.2 - Telas de Autenticação ❌
- [ ] Tela de boas-vindas/onboarding
- [ ] Tela de login (email/senha)
- [ ] Tela de cadastro
- [ ] Tela de recuperação de senha
- [ ] Login social (Google, Apple)

### Etapa 2.3 - Perfil de Usuário 🔄
- [x] Tela de perfil básica
- [x] Edição de nome (displayName)
- [x] Dados de nascimento (para astrologia)
- [ ] **FALTA**: Foto de perfil
- [ ] **FALTA**: Configurações de privacidade
- [ ] **FALTA**: Email verificado

### Etapa 2.4 - Sistema de Roles ✅
- [x] Definir roles: `free`, `premium`, `admin`
- [x] Criar modelo `UserRole` e `SubscriptionPlan`
- [x] Implementar verificação de permissões (FeatureAccess)
- [x] Middleware de autorização (checkFeatureAccess)

### Etapa 2.5 - Feature Toggles ✅ (Local)
- [x] Sistema de feature flags (`AppFeature` enum)
- [x] Configuração por role/plano (`FeatureAccess`)
- [x] Diferentes AccessTypes (full, preview, blocked, limited)
- [ ] **FALTA**: Toggle remoto (Firebase Remote Config)

### Etapa 2.6 - Sincronização ❌
- [ ] Estrutura de dados na nuvem
- [ ] Sync de feitiços do usuário
- [ ] Sync de diários
- [ ] Tratamento de conflitos

---

## Fase 3 - Premium 1.0 🔄

### Monetização ❌
- [ ] Integração com loja (Google Play / App Store)
- [ ] Implementar paywall real
- [ ] Gerenciamento de assinaturas reais

### UI Premium ✅
- [x] `PremiumUpgradeSheet` (tela de upgrade)
- [x] Preços definidos (R$ 9,90/mês, R$ 79,90/ano)
- [x] Botão "Seja Premium" nas seções bloqueadas
- [x] Blur para conteúdo premium (título visível, conteúdo blur)

### Limites por Plano ✅ (Implementado Localmente)

| Feature | Free | Premium | Admin |
|---------|------|---------|-------|
| Feitiços salvos | 10 | Ilimitado | Ilimitado |
| Entradas de diário | 30/mês | Ilimitado | Ilimitado |
| Conselheiro Místico | 1/dia | Ilimitado | Ilimitado |
| Leitura de Runas | 1/dia | Ilimitado | Ilimitado |
| Cartas do Oráculo | 1/dia | Ilimitado | Ilimitado |
| Afirmações | 3/dia | Ilimitado | Ilimitado |
| Pêndulo | 1/dia | 1/dia | Ilimitado |
| Perfil Mágico (análise IA) | Blur | ✅ | ✅ |
| Clima Mágico (previsão) | Blur | ✅ | ✅ |
| Sugestões Personalizadas | Blur | ✅ | ✅ |
| Fase Lunar nos feitiços | ❌ | ✅ | ✅ |

### Backup em Nuvem ❌
- [ ] Backup automático para premium
- [ ] Restauração de dados
- [ ] Exportação de dados (GDPR)

---

## Fase 4 - Premium 2.0: Astrologia ✅

- [x] Mapa astral completo
- [x] Perfil mágico personalizado
- [x] Signos do zodíaco
- [x] Interpretações planeta-em-signo
- [x] Clima mágico diário
- [x] Trânsitos planetários
- [ ] Jornadas gamificadas

---

## Fase 5 - Refinos e Conteúdo 🔄

### Implementado ✅
- [x] Runas (alfabeto, significados, divinação)
- [x] Sigilos (criação com Roda das Bruxas)
- [x] Divinação (pêndulo, Cartas do Oráculo)
- [x] Sabbats / Roda do Ano
- [x] Conselheiro Místico (IA)
- [x] Mascote interativo
- [x] Notificações (Lua cheia, Lua nova, Sabbats)
- [x] Restauração de estado do app (tab persistida, sem splash ao voltar)
- [x] Formatadores de data/hora amigáveis
- [x] Pre-fill do mapa astral com dados anteriores

### Pendente ❌
- [ ] Analytics mágicos (estatísticas de uso)
- [ ] Busca natural por IA
- [ ] Packs mensais de conteúdo
- [ ] Comunidade / Social features
- [ ] Scroll position persistence (parcial)

---

## Sistema de Usuários e Admin (Status Atual)

### Modelo de Dados ✅

```dart
class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? birthDate;
  final String? birthTime;
  final String? birthPlace;
  final UserRole role;
  final SubscriptionPlan plan;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  // Contadores de uso
  final int spellsCount;
  final int diaryEntriesThisMonth;
  final int aiConsultationsToday;
  final int pendulumUsesToday;
  final int affirmationsToday;
  final int runeReadingsToday;
  final int oracleReadingsToday;
}

enum UserRole { free, premium, admin }
enum SubscriptionPlan { free, monthly, yearly, lifetime }
```

### Painel Admin/Debug ✅

#### Implementado
- [x] Diagnóstico completo (na página de diagnóstico)
- [x] Alternância de roles (Free/Premium/Admin)
- [x] Estatísticas de uso do usuário
- [x] Reset de dados
- [x] `isOriginalAdmin` para manter acesso ao painel ao simular outros roles

#### Pendente (requer backend)
- [ ] Dashboard com métricas reais
- [ ] Lista de usuários com filtros
- [ ] Alterar role/plano de outros usuários
- [ ] Gerenciamento de conteúdo centralizado

---

## O QUE FALTA IMPLEMENTAR (Detalhado)

### PRIORIDADE ALTA - Para App Funcional com Monetização

#### 1. Backend Real (Escolher um)
```
Opção A - Firebase (Recomendado para MVP rápido):
- Firebase Authentication (email, Google, Apple)
- Cloud Firestore (dados do usuário)
- Firebase Storage (fotos de perfil)
- Remote Config (feature flags)

Opção B - Supabase (Mais controle):
- Supabase Auth
- PostgreSQL
- Storage
```

#### 2. Autenticação Real
- Criar telas: Login, Cadastro, Recuperação de senha
- Implementar AuthRepository com backend
- Migrar dados locais para nuvem no primeiro login
- Login social (Google Sign-In, Apple Sign-In)

#### 3. Integração com Lojas
- Google Play Billing (Android)
- StoreKit 2 (iOS)
- Usar pacote `purchases_flutter` (RevenueCat) ou `in_app_purchase`
- Webhook para validar compras no backend

#### 4. Sincronização de Dados
- Sincronizar feitiços, diários, configurações
- Tratamento de conflitos (last-write-wins ou merge)
- Modo offline com sync posterior

### PRIORIDADE MÉDIA - Melhorias de UX

#### 5. Foto de Perfil
- Picker de imagem (câmera/galeria)
- Crop circular
- Upload para Storage
- Cache local

#### 6. Onboarding
- Tela de boas-vindas com slides
- Explicação das funcionalidades
- Coleta de dados iniciais (nome, data nascimento)
- Skip para usuários que já usaram

#### 7. Scroll Position Persistence
- Salvar posição de scroll das listas
- Restaurar ao voltar para a página

### PRIORIDADE BAIXA - Futuro

#### 8. Analytics
- Firebase Analytics ou similar
- Eventos: uso de features, conversão, retenção
- Funnel de upgrade

#### 9. Busca por IA
- Integrar com IA para busca natural
- "Encontre feitiços para prosperidade"

#### 10. Social Features
- Compartilhar feitiços
- Feed de comunidade
- Comentários

---

## Arquivos Principais do Sistema de Monetização

```
lib/
├── features/auth/
│   ├── data/models/
│   │   ├── user_model.dart          # Modelo do usuário com contadores
│   │   └── feature_access.dart      # AppFeature enum e AccessResult
│   ├── presentation/
│   │   ├── providers/
│   │   │   └── auth_provider.dart   # Estado do usuário, limites, roles
│   │   ├── pages/
│   │   │   └── profile_page.dart    # Tela de perfil
│   │   └── widgets/
│   │       ├── premium_blur_widget.dart     # PremiumBlurWidget, PremiumContentSection
│   │       └── usage_limit_widget.dart      # Indicadores de uso
│   └── auth.dart                    # Exports
├── features/settings/
│   └── presentation/pages/
│       └── settings_page.dart       # Configurações com notificações
└── core/diagnostic/
    └── diagnostic_page.dart         # Debug/Admin com role switcher
```

---

## Comandos Úteis para Continuar

```bash
# Verificar status do código
git status

# Build para testar
flutter build apk --release

# Rodar em debug
flutter run

# Gerar ícones (se necessário)
flutter pub run flutter_launcher_icons
```

---

## Notas para Próximo Chat

1. **Estado atual**: Sistema de monetização/roles funciona localmente com SharedPreferences
2. **Próximo passo lógico**: Escolher e configurar backend (Firebase ou Supabase)
3. **Branch atual**: `claude/implement-roadmap-phases-019ftQAa3BvDcZhd2UUksGSM`
4. **Sem erros de build conhecidos**: Último build bem-sucedido

---

*Última atualização: Novembro 2025*
