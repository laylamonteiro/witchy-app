# Roadmap - Grimório de Bolso

## Visão Geral das Fases

| Fase | Nome | Status |
|------|------|--------|
| 1 | MVP Local-First | ✅ Completo |
| 2 | Backend + Conta + IA | ⏳ Próxima |
| 3 | Premium 1.0 | 📋 Planejado |
| 4 | Premium 2.0: Astrologia | ✅ Antecipado |
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
- [x] Busca e filtros
- [x] Visualização detalhada

### Diários ✅
- [x] Diário de Sonhos (título, descrição, tags, sentimentos)
- [x] Diário de Desejos (status, evolução, manifestação)

### Enciclopédia Mágica ✅
- [x] Cristais (6 básicos)
- [x] Cores (12 cores)
- [x] Ervas
- [x] Metais
- [x] Deusas
- [x] Elementos
- [x] Altar

---

## Fase 2 - Backend + Conta + IA ⏳

### Etapa 2.1 - Infraestrutura de Autenticação
- [ ] Escolher backend (Firebase Auth / Supabase / Custom)
- [ ] Configurar projeto no backend escolhido
- [ ] Criar modelo de usuário (`UserModel`)
- [ ] Implementar `AuthRepository`
- [ ] Criar `AuthProvider`

### Etapa 2.2 - Telas de Autenticação
- [ ] Tela de boas-vindas/onboarding
- [ ] Tela de login (email/senha)
- [ ] Tela de cadastro
- [ ] Tela de recuperação de senha
- [ ] Login social (Google, Apple)

### Etapa 2.3 - Perfil de Usuário
- [ ] Tela de perfil
- [ ] Edição de dados pessoais
- [ ] Foto de perfil
- [ ] Dados de nascimento (para astrologia)
- [ ] Configurações de privacidade

### Etapa 2.4 - Sistema de Roles
- [ ] Definir roles: `user`, `premium`, `admin`
- [ ] Criar modelo `UserRole`
- [ ] Implementar verificação de permissões
- [ ] Middleware de autorização

### Etapa 2.5 - Feature Toggles
- [ ] Sistema de feature flags
- [ ] Configuração por role/plano
- [ ] Toggle remoto (Firebase Remote Config ou similar)

### Etapa 2.6 - Sincronização Básica
- [ ] Estrutura de dados na nuvem
- [ ] Sync de feitiços do usuário
- [ ] Sync de diários
- [ ] Tratamento de conflitos

---

## Fase 3 - Premium 1.0 📋

### Monetização
- [ ] Integração com loja (Google Play / App Store)
- [ ] Definir planos (Free / Premium)
- [ ] Implementar paywall
- [ ] Gerenciamento de assinaturas

### Limites por Plano
| Feature | Free | Premium |
|---------|------|---------|
| Feitiços salvos | 10 | Ilimitado |
| Entradas de diário | 30/mês | Ilimitado |
| Backup em nuvem | ❌ | ✅ |
| Conselheiro IA | 3/dia | Ilimitado |
| Mapa Astral completo | ❌ | ✅ |

### Backup em Nuvem
- [ ] Backup automático para premium
- [ ] Restauração de dados
- [ ] Exportação de dados (GDPR)

---

## Fase 4 - Premium 2.0: Astrologia ✅ (Antecipado)

- [x] Mapa astral completo
- [x] Perfil mágico personalizado
- [x] Signos do zodíaco
- [x] Interpretações planeta-em-signo
- [ ] Clima mágico diário
- [ ] Jornadas gamificadas

---

## Fase 5 - Refinos e Conteúdo 🔄

### Implementado
- [x] Runas (alfabeto, significados, divinação)
- [x] Sigilos (criação com Roda das Bruxas)
- [x] Divinação (pêndulo, oracle cards)
- [x] Sabbats / Roda do Ano
- [x] Conselheiro Místico (IA)
- [x] Mascote interativo

### Pendente
- [ ] Analytics mágicos (estatísticas de uso)
- [ ] Busca natural por IA
- [ ] Packs mensais de conteúdo
- [ ] Comunidade / Social features

---

## Sistema de Usuários e Admin (Detalhado)

### Modelo de Dados

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
  final Map<String, dynamic>? settings;
}

enum UserRole {
  user,      // Usuário comum
  premium,   // Assinante
  admin,     // Administrador
}

enum SubscriptionPlan {
  free,
  monthly,
  yearly,
  lifetime,
}
```

### Painel Admin

#### Dashboard
- Total de usuários
- Usuários ativos (7d, 30d)
- Conversão free → premium
- Features mais usadas

#### Gerenciamento de Usuários
- Lista de usuários com filtros
- Visualizar perfil de usuário
- Alterar role/plano
- Suspender/banir conta

#### Gerenciamento de Conteúdo
- CRUD de feitiços do app (Grimório Ancestral)
- CRUD de cristais, ervas, etc.
- Moderação de conteúdo (futuro social)

#### Feature Flags
- Ligar/desligar features por ambiente
- A/B testing
- Rollout gradual

---

## Prioridades Imediatas

1. **Escolher e configurar backend** (Firebase recomendado para MVP)
2. **Implementar autenticação básica** (email/senha)
3. **Criar tela de perfil**
4. **Implementar roles básicos** (user/admin)
5. **Esconder Diagnóstico** para usuários não-admin

---

## Notas Técnicas

### Backend Recomendado: Firebase
- Auth: Firebase Authentication
- Database: Cloud Firestore
- Storage: Firebase Storage (fotos)
- Remote Config: Feature flags
- Analytics: Firebase Analytics

### Alternativa: Supabase
- Auth: Supabase Auth
- Database: PostgreSQL
- Storage: Supabase Storage
- Mais controle, menos vendor lock-in

---

*Última atualização: Novembro 2025*
