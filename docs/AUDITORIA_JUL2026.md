# 📋 Auditoria Completa do Projeto — Julho/2026

Auditoria feita para reconstruir o estado do projeto após perda de contexto,
cruzando **código**, **histórico Git** e **histórico de conversas**. Base
auditada: commit `cbba7e1` (v1.0.0+42, main). Este documento é a fonte de
verdade do estado do projeto e registra as correções aplicadas no PR que o
introduz.

---

## 1. ✅ O que já estava correto (não alterado)

| Item | Evidência |
|---|---|
| Imagens de cristais/ervas como assets locais (18+18 jpg) com `Image.asset` + fallback | `assets/images/crystals|herbs/`, `crystals_list_page.dart:86-120`, `pubspec.yaml:106-113` |
| Roda de sigilo com 3 anéis concêntricos (A-F/G-N/O-Z, 6/8/12 divisões) integrada ao fluxo real de 3 etapas | `witch_wheel_painter.dart`, `sigil_wheel_model.dart`; diagnóstico do "APK não muda" em `docs/PROBLEMA_SIGILOS_RESOLVIDO.md` |
| Mascote gatinho — **comportamento congelado por decisão do produto** | `lib/core/widgets/mascot/draggable_cat_mascot.dart` (836 linhas, intocado) |
| Enciclopédia, grimório (incl. IA), diários, divinação, runas, lunar, roda do ano, auth, assinatura RevenueCat | 15 features em `lib/features/` |
| Padrão fail-closed correto já existia em feitiços | `spell_detail_page.dart:108` (`if (isPremium) ...`) |

Nota: o `witchy_images.zip` mencionado em conversas antigas nunca entrou no
Git, mas o conteúdo foi integrado como arquivos individuais — pendência morta.

## 2. ❌ Problemas encontrados e CORRIGIDOS neste PR

### P0.1 — Sistema de códigos beta (confirmado: "não funcionava")

| # | Problema | Evidência (antes) | Correção |
|---|---|---|---|
| a | **"Invalidar" não impedia resgate**: o resgate só checava `current_uses >= max_uses` e ignorava `is_used` | `beta_code_repository.dart:143-152` vs `:197-201` | Resgate agora valida `is_used`; invalidar também seta `current_uses = max_uses` |
| b | **Fallback silencioso**: falha no Supabase (RLS antigo, coluna faltando) caía no SQLite e a UI dizia "sucesso" — o código ficava local-only, inútil para distribuir. **Causa raiz do sintoma relatado** | `beta_code_repository.dart:101-118`, `beta_codes_management_page.dart:99` | Com Supabase configurado, falha de escrita = erro real na UI; SQLite continua como cache de leitura e backend do modo local |
| c | **Condição de corrida**: read + update não atômico permitia dois resgates do mesmo código de uso único | `:134-169` | RPC Postgres `redeem_beta_code` (atômica, `SECURITY DEFINER`) + fallback com UPDATE condicional (`is_used = false AND current_uses < max_uses`) |
| d | **Downgrade indevido**: callback do RevenueCat rebaixava usuário beta-lifetime para free | `auth_provider.dart:144-150` (divergia de `:448`/`:488`) | `_onPaymentStatusChanged` preserva `plan == lifetime` |
| e | `_updateCodeLocal` incrementava `current_uses` ao invalidar (caminho `currentUses == null`) | `:311-317` | Parâmetro obrigatório; invalidação local dedicada |
| f | ~40 `print()` de debug em produção | todo o repositório | Migrados para `debugLog` |
| g | Doc de setup com schema desatualizado (sem `max_uses`/`current_uses`) — seguir o doc criava tabela incompatível | `SUPABASE_BETA_CODES_SETUP.md:73-82` | Doc atualizado + script único consolidado |

### P0.2 — Conteúdo Free x Premium (confirmado: textos premium vazavam)

| # | Problema | Evidência (antes) | Correção |
|---|---|---|---|
| a | **Blur não escondia**: o texto premium REAL era renderizado na árvore com blur sigma 5-6 — legível por leitor de tela e parcialmente a olho | `premium_blur_widget.dart:50-58,114-122,194-208`; `daily_magical_weather_page.dart:438-449`; `magical_profile_page.dart:564`; `personalized_suggestions_page.dart:507-599` | **Fail-closed**: sem acesso, o conteúdo real NUNCA entra na árvore — placeholder místico desfocado + CTA no lugar (`kPremiumPlaceholderText`) |
| b | **Mapa Astral sem gate nenhum** (920 linhas, interpretações 100% abertas para free) | `birth_chart_view_page.dart` | Interpretações de aspectos via `PremiumBlurText` (fail-closed); posições básicas seguem como preview; banner de upgrade para free |
| c | **Duas fontes de verdade de premium**: `PaymentService().isPro` (RevenueCat) vs `AuthProvider`/role. Beta-premium não tinha sync; admin simulando plano não via a experiência real | `pro_feature_gate.dart:43`, `sync_provider.dart:50-131`, `data_sync_service.dart:576,591`, `main.dart:153` | **Fonte única**: `AuthProvider.isPremiumEffective` + singleton `PremiumAccess` (para serviços sem contexto). Todos os consumidores migrados |
| d | **Hub de adivinhação contradizia as páginas**: hub bloqueava oráculo/pêndulo/runas como premium; páginas permitiam free com limite diário | `divination_hub_page.dart:113-187` vs `feature_access.dart:268-286` | Regra única em `FeatureAccess`: `AccessResult.limited` pelos contadores diários (oráculo 1/dia, runas 1/dia, pêndulo 3/dia). Hub libera navegação enquanto há usos |

**Decisão de produto** (escolhida pela consistência com o código existente):
oráculo/pêndulo/runas são **free com limite diário** (era o que as 3 páginas e
o `FeatureAccess.canUseX` já implementavam; só o hub estava inconsistente).
**Código beta = premium completo, incluindo sync** (consequência da fonte
única; beta testers testam tudo).

### P0.3 — Sync Supabase quebrado por schema

- `DataSyncService` envia/lê `updated_at` em TODAS as 13 entidades
  (`data_sync_service.dart:257-258,501`), mas `docs/supabase_schema.sql` só
  tinha a coluna em `profiles`/`spells`/`desires` → upsert falharia em ~11
  tabelas.
- **Correção**: `supabase/restore_database.sql` adiciona
  `updated_at TIMESTAMPTZ DEFAULT NOW()` (idempotente) em todas.

### P1 — Navegação por abas

- Não havia Navigators aninhados: detalhes empilhavam no Navigator raiz e
  **cobriam a bottom bar** (1 único `bottomNavigationBar` no app).
- **Implementado**: um `Navigator` por aba (`home_page.dart`), com:
  - re-toque na aba ativa → `popUntil(isFirst)` + reset da TabBar interna
    para a primeira aba (via `SectionResetNotifier`, mecanismo genérico);
  - bottom bar agora **sempre visível** nas páginas de conteúdo
    (ex.: Enciclopédia → Cristais → Quartzo Rosa);
  - botão voltar do Android desempilha a aba ativa antes de sair (`PopScope`);
  - fluxos de tela cheia (Configurações) usam `rootNavigator: true`;
  - rotas nomeadas (`/subscription`, `/welcome`...) não afetadas — todas
    partem de páginas no Navigator raiz.

### P2 — Qualidade

- `test/widget_test.dart` era o template default do Flutter referenciando
  `MyApp` inexistente (não compilava). **Substituído** por testes reais de
  lógica pura: roda de sigilos (26 letras, 3 anéis, ângulos, processamento de
  texto), `SupabaseConfig`, `UserModel`/premium e a regra única de gating do
  `FeatureAccess`.
- Supabase expirado: **`supabase/restore_database.sql`** (script único
  idempotente: 16 tabelas, RLS, trigger de profile, beta_codes multi-uso,
  RPC `redeem_beta_code`, funções de reset) + guia passo a passo
  **`docs/SUPABASE_RESTORE.md`**.

## 3. ⚠️ Parcial / pendências documentadas (NÃO tratadas neste PR)

| Item | Evidência | Nota |
|---|---|---|
| Cálculo astrológico com placeholders (`Planet.sun // Placeholder`, método simplificado) | `chart_calculator.dart:110,127` | Precisão do mapa astral discutida em `docs/ACURACIDADE_MAPA_ASTRAL.md` |
| Feature `journeys` é só um dashboard | `lib/features/journeys/` | Decidir evolução ou remoção |
| "Backup na nuvem (em breve)" no sheet premium | `premium_blur_widget.dart` (benefícios) | Sync já existe para premium; revisar texto |
| Configurações de notificação "em breve" | `profile_page.dart:758` | — |
| Códigos beta sem expiração (`expires_at` não existe) | schema | Adicionar se virar requisito |
| Premium por código beta não é reidratável após reinstalação (fica só em SharedPreferences; servidor só guarda `used_by` do último uso) | `auth_provider.dart` + schema | Requer vínculo código↔conta no servidor |
| Telas de debug de beta codes acessíveis via painel admin | `beta_codes_debug_page.dart` | Já é admin-only; considerar gate por build debug |

## 4. 🚫 Solicitado em conversas antigas e nunca implementado

Nada pendente: os pedidos antigos (imagens, roda de sigilo, ícones/layout)
foram todos resolvidos ou supersedidos pelo redesign de 3 abas.

---

## 5. 🐱 Balão de conversa do gatinho — ✅ IMPLEMENTADO

**Requisito**: 1x por dia, no primeiro open do app, um chat bubble aparece
acima do gatinho com mensagem rotativa; X fecha; tap leva ao Clima Mágico
Diário. **O comportamento do mascote permanece congelado —
`draggable_cat_mascot.dart` NÃO foi tocado (zero alterações).**

### Implementação (conforme arquitetura aprovada)

- **Novo widget** `lib/core/widgets/mascot/cat_chat_bubble.dart`:
  - `CatBubbleMessages` — lógica pura (mensagens, rotação por
    `dayOfYear % length`, chave de data `yyyy-MM-dd`), coberta por testes
    em `test/widget_test.dart`;
  - `CatChatBubble` — StatefulWidget montado no `Stack` da `HomePage` como
    IRMÃO do `DraggableCatMascot`, `Positioned(left: 12, top: 36)` sobre a
    âncora inicial do gato (x=20, y=120 — no primeiro open do dia o gato
    ainda está na posição inicial); animação própria de fade+scale; hit-test
    restrito à área do balão (drag, tap, partículas e poses do gato
    intocados).
- **Controle diário**: SharedPreferences `cat_bubble_last_shown_date`
  (`yyyy-MM-dd`). Mostra somente se `!= hoje`; fechar no X ou tocar no balão
  grava a data. Mesmo padrão de persistência do app (`last_selected_tab`,
  `encyclopedia_last_tab`).
- **Mensagens rotativas** (determinísticas, mudam a cada dia):
  1. "Que tal olhar o clima mágico do seu dia?"
  2. "Seu clima mágico já foi revelado hoje?"
  3. "Os astros prepararam algo interessante para você."
  4. "Descubra a energia mágica deste dia."
- **Ação do tap**: `Navigator.of(context, rootNavigator: true).push(...)` →
  `DailyMagicalWeatherPage` (tela cheia, acima dos Navigators aninhados).
- **Arquivos alterados**: `cat_chat_bubble.dart` (novo) + 3 linhas em
  `home_page.dart` (import e montagem no Stack). Evolução futura opcional:
  se o balão precisar seguir o gato durante o drag, expor um
  `ValueListenable<Offset>` opcional no mascote (mudança aditiva, sem efeito
  comportamental).

---

## 6. Verificação das correções deste PR

1. `flutter analyze` / `flutter test` (testes novos em `test/widget_test.dart`).
2. Free NÃO vê texto premium em: Clima Mágico, Perfil Mágico, Sugestões,
   Mapa Astral (interpretações), detalhes da Enciclopédia — em todos aparece
   o placeholder desfocado + CTA.
3. Código beta: criar (admin) → linha aparece no Supabase; falha do servidor
   aparece como erro (sem "sucesso" falso); resgatar concede premium completo
   **incluindo sync**; invalidar bloqueia resgate; resgate duplo do mesmo
   código de uso único falha.
4. Navegação: bottom bar visível em páginas de detalhe; re-toque na aba ativa
   volta à raiz da seção; back do Android desempilha a aba antes de sair;
   Configurações continua em tela cheia.
5. Supabase: rodar `supabase/restore_database.sql` num projeto novo sem erro;
   signup cria `profiles` via trigger; sync premium sem erro de coluna.
