# 🔮 Grimório de Bolso

Um grimório vivo, agenda mágica e companheiro de jornada para bruxas e bruxos iniciantes

**Versão atual:** 2.0.0 · **Plataforma:** Android (Google Play, produção) · **Idiomas:** 🇧🇷 pt-BR · 🇺🇸 en · 🇪🇸 es

---

## Sobre o app

**Grimório de Bolso** é um aplicativo Flutter para quem está começando na bruxaria e estuda sozinho — organizando a prática, guardando registros e aprendendo com conteúdo curado, sem dogma e sem sensacionalismo

O app é **local-first**: tudo funciona offline no SQLite do aparelho, com sincronização opcional na nuvem (Supabase) para quem cria conta. A pessoa usuária escolhe o idioma, o tema visual e como quer ser tratada (feminino, masculino ou neutro) — e todo o conteúdo, inclusive as respostas da IA, respeita essas escolhas

---

## As quatro abas

| Aba | O que vive nela |
|---|---|
| ✨ **Seu Dia** | O ritual diário: saudação com nível e sequência, clima mágico do dia, contagem regressiva do próximo sabbat, carrossel lunar, ritos de hoje, continue sua trilha e atalhos personalizáveis |
| 📖 **Enciclopédia** | 15 seções de conteúdo mágico curado, abertas por um índice em papel envelhecido, com busca global |
| 🔮 **Grimório** | Astrologia mística, ferramentas de prática e adivinhação, e o seu grimório pessoal de feitiços e registros |
| 📕 **Diários** | Sonhos, desejos, gratidão, afirmações e escrita livre |

---

## Funcionalidades

### ✨ Seu Dia — o ritual diário
- **Nível e sequência** no topo: XP unificado (Aprendiz 🕯️ → Iniciada 🌙 → Praticante ⭐ → Adepta 🔮 → Mestra 👑 → Guardiã 📜) e dias seguidos de prática
- **Ritos de hoje**: gratidão e sonho fixos + um rito exploratório que se reveza a cada dia entre tarot, oráculo, quiromancia, runas, identificação na natureza e pêndulo
- **Clima mágico do dia** e **Momento Mágico** (dias e horas planetárias)
- **Contagem regressiva** do próximo sabbat com atalho para o ritual guiado
- **Continue sua trilha**: retoma a próxima lição do Grimório Vivo
- **Atalhos editáveis**: a pessoa escolhe quais ferramentas ficam à mão
- **Salem**, o gato mascote, que guia o tour e aparece com dicas — e pode sumir em fumaça quando não for bem-vindo

### 📖 Enciclopédia Mágica
Índice ilustrado (livro de papel envelhecido, com animação de abertura e virada de página) dando acesso a 15 seções:

🌙 Lua · ☀️ Sol · 🔥 Sabbats · 💎 Cristais · 🌿 Ervas · 🎨 Cores · 🏛️ Deusas · 🌍 Elementos · 🗿 Runas · 🕯️ Altar · 🔩 Metais · 🎭 Arquétipos · ✨ Símbolos Sagrados · 😇 Anjos · 😈 Demônios

- **Busca global** que atravessa todas as seções e também as entradas pessoais
- **Enciclopédia pessoal** (Premium): fotografe uma planta, pedra ou cor, a IA identifica e monta o verbete no formato da categoria — com a sua foto guardada no aparelho
- Verbetes arcanos com perspectivas por tradição (religiosa, folclórica, ocultista, literária) e tags "Veja também" clicáveis

### 🔮 Grimório Digital

**Astrologia Mística**
- Mapa astral completo (efemérides Swiss Ephemeris), signos, casas e aspectos
- Perfil mágico personalizado e sugestões a partir do mapa
- Clima mágico diário baseado em trânsitos

**Ferramentas Mágicas**
- 🎴 Tarot (78 cartas, tiragens, biblioteca e tutor de estudo)
- 🃏 Oráculo · ᚱ Runas (24 do Futhark Antigo) · ⟟ Pêndulo
- ✨ Sigilos (desenho na tela, salvar na galeria ou no Diário de Desejos)
- 🖐️ Quiromancia por foto · 🍃 Guia da Natureza (identificação por foto)
- 🔢 Numerologia · 🌟 Mapa Astral · 🔮 Conselheiro Místico

**Meu Grimório**
- Feitiços por categoria, com fase lunar recomendada, ingredientes e passos
- Criação assistida por IA a partir de uma intenção
- Registros e páginas do Grimório Vivo

### 📕 Diários
Sonhos (com interpretação por IA em duas camadas: símbolo tradicional + leitura aplicada ao seu sonho), desejos com status de manifestação, gratidão, afirmações e escrita livre com salvamento automático

### 📚 Grimório Vivo — trilhas de aprendizado
9 trilhas com 88 lições no total: Magia Branca, Magia Negra, Magia Verde, Wicca, Bruxaria Tradicional, Magia do Caos, Tarot, Quiromancia e Águas Mágicas

Cada lição tem três atos — **Ensino → Prática → A Página** — e termina com uma página escrita pela própria pessoa, guardada no lugar certo do app (feitiço, registro, diário ou junto de uma ferramenta). Completar uma trilha "encaderna o capítulo" no grimório. A primeira lição de cada trilha é gratuita

### 🕯️ Rituais guiados
46 rituais passo a passo (sabbats, fases lunares e momentos mágicos) com player guiado que registra a prática

### 📊 Estatísticas Mágicas
Total de práticas por período, grid por categoria, sequências (prática diária e gratidão), calendário do mês com os dias praticados, manifestações e o progresso do Grimório Vivo — com atalho para as Jornadas Mágicas (conquistas)

---

## Conteúdo curado

Todo o conteúdo editorial existe nos três idiomas, com paridade verificada por testes bloqueantes no CI:

| Seção | Entradas |
|---|---|
| Cristais · Ervas · Cores | 18 cada |
| Deusas | 15 |
| Anjos · Demônios | 16 · 15 |
| Arquétipos · Símbolos Sagrados | 11 cada |
| Metais | 9 |
| Runas | 24 |
| Cartas de tarot | 78 |
| Rituais guiados | 46 |
| Lições das trilhas | 88 |
| Chaves de interface | 1.400 × 4 arquivos |

---

## Planos

**Free** — enciclopédia completa, calendário lunar, sabbats, grimório pessoal, diários, ferramentas de adivinhação com limites diários e a primeira lição de cada trilha. Anúncios intersticiais aparecem antes de resultados (tarot, runas, oráculo, pêndulo, feitiço por IA, conselheiro, mapa astral), com intervalo mínimo de 3 minutos e teto diário

**Premium** — mapa astral e perfil mágico, interpretação de sonhos por IA, quiromancia, enciclopédia pessoal, trilhas completas, rituais guiados e sincronização na nuvem. Assinaturas via RevenueCat

O acesso a cada recurso é decidido em um lugar só: `AppFeature` + `FeatureAccess` (`lib/features/auth/data/models/feature_access.dart`)

---

## Inteligência artificial

Na interface o recurso se chama **Conselheiro Místico** — a sigla "IA" nunca aparece para a pessoa usuária

O provedor de cada ponto do app é **parametrizado** no topo de `lib/core/ai/ai_service.dart`:

```dart
static const AiProvider defaultTextProvider = AiProvider.groq;   // texto
static const Map<String, AiProvider> textProviders = {};         // exceções por tag
static const AiProvider visionProvider = AiProvider.gemini;      // foto
```

- **Texto** (sonhos, conselheiro, feitiços, tarot, numerologia, clima, afirmações, perfil mágico, verbetes): Groq `llama-3.3-70b-versatile`
- **Visão** (quiromancia, identificação de plantas/pedras/cores): Google Gemini `gemini-3.6-flash`
- Toda chamada cai automaticamente para o outro provedor se o principal falhar, e os logs de debug (tag `AI`) registram quem respondeu
- Os prompts vivem por idioma em `lib/core/ai/prompts/ai_prompts_{pt,en,es}.dart`, com tratamento de gênero

---

## Identidade visual

**Mood:** Whimsical + Whimsigoth + Pastel Goth — magia aconchegante, bruxa de quarto com velas, gatos e plantas

O app tem **6 temas selecionáveis** (Vinho Orquídea, Azul Celeste, Esmeralda Jade, Ardósia Lavanda, Clássico e Lavanda Névoa). As cores **nunca** são escritas direto no código: vêm sempre dos tokens do tema via `context.gc.*` — `lilac`, `pink`, `mint`, `starYellow`, `textPrimary`, `textSecondary`, `surface`, `alert`, `success`

**Tipografia:** Nunito no corpo e Cinzel Decorative nos títulos ornamentais (nomes de verbetes, capa do índice)

---

## Arquitetura

Clean Architecture + Feature-First: cada módulo carrega os próprios `data/` (models, repositories, data_sources) e `presentation/` (providers, pages, widgets)

```
lib/
├── core/
│   ├── ai/              # AIService (provedores parametrizados) + prompts por idioma
│   ├── content/         # ContentLocale: seleciona o conteúdo do idioma ativo
│   ├── database/        # SQLite (v18) + migrações aditivas
│   ├── i18n/            # Gênero e helpers de linguagem
│   ├── navigation/      # Deep links e EncyclopediaSection (ordem canônica)
│   ├── services/        # Anúncios, sync, notificações, pagamentos, logs
│   ├── theme/           # Presets de tema e tokens de cor
│   └── widgets/         # MagicalCard, MagicalFAB, Salem (mascote), tour...
│
├── features/            # 22 módulos
│   ├── your_day/        # A aba inicial: ritos, clima, atalhos
│   ├── encyclopedia/    # 15 seções + enciclopédia pessoal
│   ├── grimoire/        # Feitiços, registros, ferramentas
│   ├── diary/           # Sonhos, desejos, gratidão, afirmações, escrita livre
│   ├── learning/        # Grimório Vivo (trilhas e lições)
│   ├── guided_rituals/  # Rituais passo a passo
│   ├── astrology/       # Mapa astral, perfil mágico, clima
│   ├── tarot/ runes/ divination/ sigils/ numerology/ palmistry/
│   ├── lunar/ sun/ wheel_of_year/
│   ├── analytics/ journeys/   # Estatísticas e conquistas
│   ├── auth/ subscription/    # Conta, planos e paywall
│   ├── home/ settings/
│
├── l10n/                # 4 arquivos ARB (pt, pt_BR, en, es)
└── main.dart
```

---

## Tecnologias

**Flutter 3.x · Dart 3** com `provider` para estado

| Área | Pacotes |
|---|---|
| Persistência | `sqflite`, `shared_preferences`, `path_provider` |
| Backend | `supabase_flutter` (auth + sync), `firebase_auth` + `google_sign_in` (login social) |
| Assinaturas | `purchases_flutter` / `purchases_ui_flutter` (RevenueCat) |
| Anúncios | `google_mobile_ads` (AdMob) |
| IA | `dio` (Groq e Gemini via REST) |
| Astrologia | `sweph` (Swiss Ephemeris), `geocoding`, `geolocator` |
| Lua | `lunar` |
| Mídia | `image_picker`, `image_cropper`, `flutter_image_compress`, `gal` |
| Interface | `google_fonts`, `flutter_svg`, `flutter_markdown`, `flutter_drawing_board` |
| Sistema | `flutter_local_notifications`, `timezone`, `share_plus`, `url_launcher`, `package_info_plus` |

---

## Como executar

**Pré-requisitos:** Flutter SDK 3.24+, Android Studio ou Xcode, e um aparelho ou emulador

```bash
git clone https://github.com/laylamonteiro/witchy-app.git
cd witchy-app
flutter pub get
flutter run
```

### Credenciais

Os arquivos de credencial são **gitignorados** e precisam existir localmente:

```
lib/core/ai/groq_credentials.dart
lib/core/ai/gemini_credentials.dart
lib/features/astrology/data/services/prokerala_credentials.dart
```

Cada um expõe uma classe com as chaves (ex.: `class GroqCredentials { static const apiKey = '...'; }`). No CI eles são gerados vazios — analyze e testes não chamam APIs reais

Admin e AdMob entram por `--dart-define`:

```bash
flutter run \
  --dart-define=ADMIN_EMAIL=... \
  --dart-define=ADMIN_PASSWORD=... \
  --dart-define=ADMOB_ANDROID_INTERSTITIAL_ID=...
```

Em builds de debug, `admin`/`admin` funciona automaticamente. Sem o id do AdMob, o app usa os anúncios de teste do Google

---

## CI/CD

Dois workflows, ambos em `.github/workflows/`:

**✅ `branch-validate.yml`** — gate de qualidade em `main` e `claude/**`
`flutter analyze` → testes de i18n e conteúdo → suíte completa → paridade dos ARBs → scanner de português hardcoded (tudo bloqueante). Toda branch ganha prévia do site; `main` publica em **staging** (`staging.grimorio-de-bolso.pages.dev`) e gera um **APK candidato assinado** como artifact para instalar e testar. **Nunca toca produção.**

**🚀 `release.yml`** — tag `vX.Y.Z` (via `bash scripts/release.sh 2.1.0`)
Guardas de versão → gate bloqueante → APK+AAB assinados + site, tudo do commit da tag → **aprovação humana** (environment `production`) → site em produção + AAB na faixa de teste da Play (variável `PLAY_TRACK`) + GitHub Release. A promoção para produção é manual na Play Console. Detalhes: `.github/workflows/README.md`

**Scripts de apoio:**

```bash
bash scripts/release.sh 2.1.0        # publica uma versão (cria a tag)
bash scripts/check_arb_sync.sh       # paridade das chaves nos 4 ARBs
bash scripts/check_hardcoded_pt.sh   # nenhum texto PT fora da camada de i18n
```

---

## Diretrizes de desenvolvimento

### Tradução (i18n) é obrigatória em TODA alteração

O app é multilíngue (pt, pt_BR, en, es). **Nenhum texto visível ao usuário pode ser escrito direto no código.** Ao criar ou alterar qualquer elemento de interface:

1. **Adicione a chave nos 4 arquivos ARB** em `lib/l10n/`: `app_pt.arb` (template), `app_pt_BR.arb`, `app_en.arb` e `app_es.arb` — os quatro devem ter sempre o mesmo conjunto de chaves
2. **Use no código** via `AppLocalizations.of(context).suaChave` (import: `package:grimorio_de_bolso/l10n/generated/app_localizations.dart`); os getters são gerados pelo `flutter run` / `flutter gen-l10n`
3. **Placeholders**: valores dinâmicos usam `{nome}` no ARB e exigem um bloco `@suaChave` com `placeholders` no template; plurais usam a sintaxe ICU (`{count, plural, one{...} other{...}}`)
4. **Nunca use `const`** em um widget que contenha um valor de `AppLocalizations` — é valor de runtime e quebra o build
5. **Widgets sem `BuildContext`** (ex.: `CustomPainter`, helpers estáticos) recebem os textos prontos pelo construtor
6. **Conteúdo editorial** (verbetes, cartas, runas, números, trilhas, feitiços, prompts de IA) vive em arquivos por locale — `*_pt.dart` / `*_en.dart` / `*_es.dart` — selecionados em runtime pelo `ContentLocale`. Ao alterar conteúdo, edite as TRÊS variantes; a paridade é verificada por testes bloqueantes (`test/*_parity_test.dart`)
7. **A IA responde no idioma ativo**: os prompts por idioma vivem em `lib/core/ai/prompts/` e usam os helpers de gênero. Conteúdo escrito pela pessoa usuária NUNCA é traduzido
8. **Identidades persistidas são invariantes**: seeds de feitiços e afirmações ficam congeladas em PT (tradução só na exibição, via `SpellLocalizer`/`AffirmationLocalizer`); ids, enums e slugs de assets não mudam com o idioma

#### Como adicionar um novo idioma

1. Crie `lib/l10n/app_<código>.arb` com TODAS as chaves do template traduzidas
2. Adicione o locale em `LanguageProvider.supportedLocales` e no seletor (`settings_page.dart`)
3. Acrescente o parâmetro em `ContentLocale.select` e crie as variantes `*_<código>.dart` de cada arquivo de conteúdo — o compilador aponta todos os pontos pendentes
4. Crie `ai_prompts_<código>.dart` e os títulos do clima diário no novo idioma
5. Estenda os testes de paridade e o smoke (`test/i18n_smoke_test.dart`)

### Outras regras do projeto

- **Cores**: sempre via tema (`context.gc.*`), nunca hardcoded — o app tem 6 presets selecionáveis e cor fixa quebra em tema claro
- **Termos de IA**: na interface o recurso se chama "Conselheiro Místico"; nunca exiba "IA/AI" para a pessoa usuária (o painel de admin pode ser técnico)
- **Novas funcionalidades místicas ou de IA**: exclusivas Premium (paywall via `FeatureAccess`/`PremiumUpgradeSheet`); as pré-existentes mantêm limites Free diários
- **Banco de dados**: migrações SQLite sempre aditivas (nova versão em `database_helper.dart`) + espelho idempotente em `supabase/restore_database.sql`; novas tabelas sincronizáveis entram em `SyncEntity`/`SupabaseTables` e nas listas de `claimLegacyData`/`clearAllTables`
- **Salvar leva à entrada criada**: fluxos que geram um registro (sonho interpretado, leitura de quiromancia, feitiço de IA, verbete da enciclopédia) navegam direto para a página recém-criada em vez de travar na tela de origem
- **Textos do app não terminam em ponto final** e nunca levam ponto antes de emoji

---

## Licença

Projeto sob licença proprietária. Todos os direitos reservados

## Contato

GitHub: [@laylamonteiro](https://github.com/laylamonteiro)

---

Feito com magia e código por bruxas, para bruxas 🌙
