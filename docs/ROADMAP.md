# Roadmap - Grimório de Bolso

## Visão Geral das Fases

| Fase | Nome | Status |
|------|------|--------|
| 1 | MVP Local-First | ✅ Completo |
| 2 | Backend + Conta + IA | ✅ Completo (Supabase integrado) |
| 3 | Premium 1.0 | ✅ Completo (RevenueCat configurado) |
| 4 | Premium 2.0: Astrologia + Jornadas | ✅ Completo |
| 5 | Refinos e Conteúdo | ✅ Quase Completo |

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

## Fase 2 - Backend + Conta + IA ✅

### Etapa 2.1 - Infraestrutura de Autenticação ✅
- [x] Modelo de usuário (`UserModel`) - **Implementado localmente**
- [x] `AuthProvider` com SharedPreferences
- [x] Sistema de roles (free, premium, admin)
- [x] `AuthRepository` abstrato (interface para backend)
- [x] `LocalAuthRepository` (implementação local)
- [x] `SupabaseAuthRepository` (integração completa)
- [x] Banco de dados preparado com `user_id` em todas as tabelas
- [x] Projeto Supabase configurado e integrado

### Etapa 2.2 - Telas de Autenticação ✅
- [x] Tela de onboarding com slides explicativos
- [x] Tela de boas-vindas (WelcomePage)
- [x] Tela de login (email/senha) com Supabase
- [x] Tela de cadastro com Supabase
- [x] Tela de recuperação de senha com Supabase
- [x] AuthWrapper para gerenciar fluxo de navegação
- [x] Deep Links configurados (iOS e Android) para OAuth
- [x] **OPCIONAL**: Login social (Google, Apple) - pacotes habilitados (google_sign_in, sign_in_with_apple), requer configuração OAuth no Supabase Dashboard

### Etapa 2.3 - Perfil de Usuário ✅
- [x] Tela de perfil completa com logout
- [x] Edição de nome (displayName)
- [x] Dados de nascimento (para astrologia)
- [x] Foto de perfil (picker + crop)
- [x] Botão de logout com confirmação
- [x] **OPCIONAL**: Configurações de privacidade (PrivacySettingsPage com toggles, export e delete)
- [x] Email verificado via Supabase

### Etapa 2.4 - Sistema de Roles ✅
- [x] Definir roles: `free`, `premium`, `admin`
- [x] Criar modelo `UserRole` e `SubscriptionPlan`
- [x] Implementar verificação de permissões (FeatureAccess)
- [x] Middleware de autorização (checkFeatureAccess)

### Etapa 2.5 - Feature Toggles ✅
- [x] Sistema de feature flags (`AppFeature` enum)
- [x] Configuração por role/plano (`FeatureAccess`)
- [x] Diferentes AccessTypes (full, preview, blocked, limited)
- [ ] **OPCIONAL**: Toggle remoto (Firebase Remote Config)

### Etapa 2.6 - Sincronização ✅
- [x] `DataSyncService` para sincronização SQLite <-> Supabase
- [x] Sync de todas as entidades (feitiços, diários, etc.)
- [x] Upload e download de dados
- [x] Marcação de items sincronizados
- [x] **OPCIONAL**: Tratamento de conflitos avançado (ConflictResolution: serverWins, clientWins, mostRecent, manual)

---

## Fase 3 - Premium 1.0 ✅

### Monetização ✅
- [x] `PaymentService` com RevenueCat integrado
- [x] `RevenueCatConfig` com configuração de API keys
- [x] Suporte a assinaturas mensais, anuais e vitalícias
- [x] Restauração de compras anteriores
- [x] Integração com user ID do Supabase
- [ ] **DEPLOY**: Configurar produtos no RevenueCat Dashboard
- [ ] **DEPLOY**: Configurar produtos no Google Play Console
- [ ] **DEPLOY**: Configurar produtos no App Store Connect

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

### Backup em Nuvem ✅
- [x] Sincronização automática via `DataSyncService`
- [x] Upload/Download de todos os dados
- [x] Dados isolados por usuário (RLS no Supabase)
- [ ] **OPCIONAL**: Exportação de dados (GDPR)

---

## Fase 4 - Premium 2.0: Astrologia ✅

- [x] Mapa astral completo
- [x] Perfil mágico personalizado
- [x] Signos do zodíaco
- [x] Interpretações planeta-em-signo
- [x] Clima mágico diário
- [x] Trânsitos planetários
- [x] Jornadas gamificadas (6 jornadas com XP, níveis e progresso)

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
- [x] Analytics mágicos (MagicalAnalyticsPage com estatísticas de uso)
- [ ] Busca natural por IA
- [ ] Packs mensais de conteúdo
- [ ] Comunidade / Social features
- [x] Scroll position persistence (ScrollPositionService)

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

## O QUE FALTA PARA PRODUÇÃO

### PRIORIDADE ALTA - Deploy

#### 1. Configurar Supabase em Produção ✅
- [x] Criar projeto no Supabase
- [x] Executar schema SQL (`docs/supabase_schema.sql`)
- [x] Configurar URL e API key no código
- [x] **DEPLOY**: Habilitar RLS em todas as tabelas
- [ ] **DEPLOY**: Configurar OAuth providers no Supabase Dashboard (Google, Apple) - pacotes já integrados

#### 2. Configurar RevenueCat ✅
- [x] Criar conta no RevenueCat
- [x] Criar app iOS e Android
- [x] Configurar API keys no código (test_pXihQfrQyXPuOlWoYzUGYCruxym)
- [x] Criar produtos (monthly, yearly, lifetime)
- [ ] Criar Offering com os pacotes (aguardando validação das lojas)

#### 3. Configurar Lojas
- [ ] Google Play Console: criar produtos de assinatura
- [ ] App Store Connect: criar produtos de assinatura
- [ ] Testar compras em sandbox

### PRIORIDADE MÉDIA - Melhorias

#### 4. Analytics ✅
- [x] MagicalAnalyticsPage com estatísticas de uso
- [x] Contadores de streak, categorias, taxas de manifestação
- [ ] Firebase Analytics (opcional, para métricas de negócio)

#### 5. Scroll Position Persistence ✅
- [x] ScrollPositionService com SharedPreferences
- [x] ScrollPositionMixin para fácil integração
- [x] ScrollPositionWrapper widget

### PRIORIDADE BAIXA - Futuro

#### 6. Busca por IA
- [ ] Integrar com IA para busca natural
- [ ] "Encontre feitiços para prosperidade"

#### 7. Social Features
- [ ] Compartilhar feitiços
- [ ] Feed de comunidade
- [ ] Comentários

---

## Arquivos Principais do Sistema

```
lib/
├── core/
│   ├── config/
│   │   ├── supabase_config.dart     # URL e API key do Supabase
│   │   └── revenuecat_config.dart   # API keys do RevenueCat
│   ├── services/
│   │   ├── data_sync_service.dart   # Sincronização SQLite <-> Supabase
│   │   └── payment_service.dart     # Compras in-app com RevenueCat
│   └── database/
│       └── database_helper.dart     # SQLite com user_id em todas tabelas
├── features/auth/
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart      # Modelo do usuário com contadores
│   │   │   └── feature_access.dart  # AppFeature enum e AccessResult
│   │   └── repositories/
│   │       ├── auth_repository.dart          # Interface abstrata
│   │       ├── local_auth_repository.dart    # Implementação local
│   │       └── supabase_auth_repository.dart # Implementação Supabase
│   ├── presentation/
│   │   ├── providers/
│   │   │   └── auth_provider.dart   # Estado do usuário, limites, roles
│   │   ├── pages/
│   │   │   ├── welcome_page.dart    # Tela de boas-vindas
│   │   │   ├── login_page.dart      # Login com Supabase
│   │   │   ├── signup_page.dart     # Cadastro com Supabase
│   │   │   ├── forgot_password_page.dart # Recuperação de senha
│   │   │   ├── onboarding_page.dart # Slides de onboarding
│   │   │   ├── auth_wrapper.dart    # Gerenciador de fluxo auth
│   │   │   └── profile_page.dart    # Perfil com logout
│   │   └── widgets/
│   │       ├── premium_blur_widget.dart     # Blur para conteúdo premium
│   │       ├── usage_limit_widget.dart      # Indicadores de uso
│   │       └── profile_avatar_picker.dart   # Picker de foto de perfil
│   └── auth.dart                    # Exports
└── docs/
    └── supabase_schema.sql          # Schema SQL para Supabase
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

## Status Atual e Próximos Passos

### Implementado ✅
1. **Backend**: Supabase integrado (Auth, Database, RLS habilitado)
2. **Autenticação**: Login/Signup/Logout com email/senha via Supabase
3. **Login Social**: Pacotes google_sign_in e sign_in_with_apple habilitados
4. **Sincronização**: `DataSyncService` com tratamento de conflitos avançado
5. **Pagamentos**: `PaymentService` com RevenueCat (Paywall e Customer Center)
6. **Deep Links**: Configurados para iOS e Android (OAuth callbacks)
7. **Analytics**: MagicalAnalyticsPage com estatísticas de uso
8. **Jornadas**: Sistema gamificado com XP e níveis
9. **Privacidade**: PrivacySettingsPage com toggles e gestão de dados
10. **Scroll Position**: ScrollPositionService para persistência

### Para Deploy
1. Configurar OAuth providers no Supabase Dashboard (Google, Apple)
2. Aguardar validação das lojas para criar Offerings no RevenueCat
3. Testar fluxo completo em ambiente de produção

### Branch
- **Atual**: `claude/pull-from-branch-b-01MkZMHFbRTCa1wsNKQgLTmh`

---

*Última atualização: Novembro 2025*
