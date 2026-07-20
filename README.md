# Grimório de Bolso

Um grimório vivo, agenda mágica e companheiro de jornada para bruxas e bruxos iniciantes.

## Sobre o App

**Grimório de Bolso** é um aplicativo móvel desenvolvido especialmente para bruxas e bruxos iniciantes, principalmente no Brasil, que estão estudando sozinhos e desejam organizar sua prática mágica. O app combina:

- Organização de feitiços, rituais e registros (Meu Grimório)
- Diários de sonhos, desejos, gratidão, afirmações e reflexões
- Calendário lunar adaptado e astrologia completa (mapa astral, clima mágico)
- Enciclopédia mágica (cristais, ervas, cores, deusas, arquétipos, anjos, demônios, símbolos...)
- Ferramentas místicas: Tarot, Oráculo, Runas, Pêndulo, Sigilos, Numerologia, Quiromancia
- Grimório Vivo: trilhas de aprendizado gamificadas que escrevem o próprio grimório
- Conselheiro Místico (IA) com respostas no idioma e gênero da pessoa usuária

## Identidade Visual

### Estilo
- **Mood**: Whimsical + Whimsigoth + Pastel Goth
- **Sensação**: Magia aconchegante, bruxa de quarto com velas, gatos, plantas
- **Elementos**: Lua, estrelas, cristais, gatos, velas, pentagrama, roda da lua

### Paleta de Cores

#### Fundos e bases
- Fundo principal: `#0B0A16` - quase preto com tom roxo profundo
- Cards/superfícies: `#171425` - roxo bem escuro para cards
- Bordas: `#26213A` - roxo mais claro para separar seções

#### Pastéis principais
- Lilás: `#C9A7FF` - magia, espiritualidade, lua
- Rosa: `#F1A7C5` - amor próprio, afeto, fofura
- Menta: `#A7F0D8` - cura, natureza, bruxaria verde
- Amarelo estrela: `#FFE8A3` - brilho, glitter, feedback positivo

#### Texto
- Principal: `#F6F4FF` - branquinho suave
- Secundário: `#B7B2D6` - texto secundário/placeholder

#### Status
- Sucesso/proteção: `#7EE08A`
- Alerta/cuidado: `#FF6B81`
- Info/neutro: `#A7C7FF`

### Tipografia
- Títulos: Nunito (bold/semibold)
- Corpo de texto: Nunito (regular)

## Funcionalidades - Fase 1 (MVP Local-First)

### Calendário Lunar
- Fases da lua (nova, crescente, cheia, minguante)
- Datas das próximas fases importantes
- Significado de cada fase
- Recomendações para tipos de feitiços

### Grimório Digital
- CRUD completo de feitiços
- Campos: nome, propósito, tipo (atração/banimento), fase lunar, ingredientes, passos, duração, observações
- Busca e filtros por tipo, propósito, fase lunar
- Visualização detalhada de cada feitiço

### Diários

#### Diário de Sonhos
- Registro de sonhos com título, descrição, data
- Tags para categorização (pesadelo, recorrente, lúcido, etc.)
- Campo para sentimentos ao acordar
- Busca por conteúdo e tags

#### Diário de Desejos
- Lista de desejos/intenções
- Status: Em Aberto, Manifestando, Manifestado, Liberado
- Campo de evolução para acompanhar progresso
- Possibilidade de criar feitiços a partir de desejos

### Enciclopédia Mágica

#### Cristais
- Nome, descrição, elemento
- Intenções e correspondências
- Formas de uso
- Métodos de limpeza e recarga
- 6 cristais básicos incluídos: Quartzo Rosa, Ametista, Citrino, Turmalina Negra, Quartzo Transparente, Selenita

#### Cores
- Significado mágico de cada cor
- Intenções associadas
- Dicas de uso em velas, roupas, objetos
- 12 cores incluídas: Branco, Preto, Vermelho, Rosa, Laranja, Amarelo, Verde, Azul, Roxo/Violeta, Marrom, Dourado, Prateado

## Arquitetura

O app foi desenvolvido seguindo princípios de Clean Architecture e Feature-First:

```
lib/
├── core/
│   ├── database/         # SQLite database helper
│   ├── theme/            # App theme e paleta de cores
│   └── widgets/          # Componentes UI reutilizáveis
│
├── features/
│   ├── home/             # Tela principal e navegação
│   ├── lunar/            # Calendário lunar
│   │   ├── data/
│   │   └── presentation/
│   │       ├── providers/
│   │       └── pages/
│   │
│   ├── grimoire/         # Grimório digital
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── providers/
│   │       └── pages/
│   │
│   ├── diary/            # Diários (sonhos e desejos)
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── providers/
│   │       └── pages/
│   │
│   └── encyclopedia/     # Enciclopédia de cristais e cores
│       ├── data/
│       │   ├── models/
│       │   └── data_sources/
│       └── presentation/
│           ├── providers/
│           └── pages/
│
└── main.dart
```

## Tecnologias Utilizadas

### Framework e Linguagem
- Flutter 3.x
- Dart 3.x

### Gerenciamento de Estado
- Provider

### Persistência Local
- SQLite (sqflite)
- SharedPreferences

### Cálculos Lunares
- lunar package (cálculos de fases da lua)

### Utilitários
- intl (formatação de datas)
- uuid (geração de IDs únicos)
- google_fonts (tipografia Nunito)

### Notificações
- flutter_local_notifications
- timezone

## Como Executar

### Pré-requisitos
- Flutter SDK 3.0 ou superior
- Android Studio / Xcode (para emuladores)
- Dispositivo físico ou emulador Android/iOS

### Instalação

1. Clone o repositório:
```bash
git clone https://github.com/laylamonteiro/witchy-app.git
cd witchy-app
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute o app:
```bash
flutter run
```

## Como configurar os secrets do GitHub Actions (pipeline do APK)

Para a esteira de build e envio de APK funcionar, configure os secrets do repositório no GitHub:

1. Acesse **Settings → Secrets and variables → Actions** no repositório.
2. Clique em **New repository secret** e crie os seguintes itens obrigatórios (fornecidos pelo seu provedor SMTP):
   - `EMAIL_SERVER` (endereço do servidor SMTP, ex.: `smtp.gmail.com` ou `smtp.office365.com`)
   - `EMAIL_PORT` (porta de envio, geralmente `587` para STARTTLS ou `465` para SSL)
   - `EMAIL_USERNAME`
   - `EMAIL_PASSWORD`
   - `EMAIL_FROM`
3. (Opcional) Crie o secret `APK_RECIPIENTS` com o(s) e-mail(s) destino separados por vírgula para definir explicitamente quem recebe o APK. Se não definir, a pipeline tenta usar o e-mail do push (pusher/autor/committer) e, se indisponível, usa o endereço `noreply` do seu usuário GitHub.
4. Salve cada secret. Após isso, basta rodar o workflow via push para `main` ou manualmente em **Actions → Build and Send Android APK → Run workflow**.

> Dica rápida: se você só tem o endereço de e-mail, consulte a documentação do seu provedor para descobrir o host e a porta SMTP. Exemplos comuns:
> - Gmail / Google Workspace: `EMAIL_SERVER=smtp.gmail.com`, `EMAIL_PORT=587` (requer "App Password" com 2FA ativo).
> - Outlook/Office 365: `EMAIL_SERVER=smtp.office365.com`, `EMAIL_PORT=587`.
> - Provedores de hospedagem (cPanel, etc.): procure por "Configurações SMTP" no painel, o host costuma ser `mail.seudominio.com` e a porta 587.

## Diretrizes de Desenvolvimento

### Tradução (i18n) é obrigatória em TODA alteração

O app é multilíngue (pt, pt_BR, en, es). **Nenhum texto visível ao usuário
pode ser escrito direto no código.** Ao criar ou alterar qualquer elemento
de interface:

1. **Adicione a chave nos 4 arquivos ARB** em `lib/l10n/`:
   `app_pt.arb` (template), `app_pt_BR.arb`, `app_en.arb` e `app_es.arb`.
   Os quatro devem ter sempre o mesmo conjunto de chaves.
2. **Use no código** via `AppLocalizations.of(context)!.suaChave`
   (import: `package:grimorio_de_bolso/l10n/generated/app_localizations.dart`).
   Os getters são gerados automaticamente pelo `flutter run` / `flutter gen-l10n`.
3. **Placeholders**: valores dinâmicos usam `{nome}` no ARB e exigem um
   bloco `@suaChave` com `placeholders` no `app_pt.arb` (template).
4. **Nunca use `const`** em um widget/lista que contenha um valor de
   `AppLocalizations` — é valor de runtime e quebra o build.
5. **Widgets sem `BuildContext`** (ex.: `CustomPainter`, helpers estáticos)
   recebem os textos prontos pelo construtor — nunca chame
   `AppLocalizations.of(context)` onde não há `context` válido.
6. **Conteúdo editorial** (verbetes da Enciclopédia, significados de cartas/
   runas/números, lições das trilhas) permanece em PT por enquanto —
   a regra acima vale para o *chrome* da interface (títulos, botões,
   rótulos, diálogos, mensagens, dicas).
7. A IA (Conselheiro Místico) já responde no idioma ativo: novos prompts
   devem usar `_localizedInstruction()` e `GenderText`, como os existentes.

> O seletor de idioma está temporariamente oculto nas Configurações
> (`_showLanguageOption` em `settings_page.dart`) até a tradução total do
> app ser concluída.

### Outras regras do projeto

- **Cores**: sempre via tema (`context.gc.*`), nunca hardcoded — o app tem
  presets de tema selecionáveis.
- **Termos de IA**: na interface o recurso se chama "Conselheiro Místico";
  nunca exiba "IA/AI" para o usuário (painel de admin pode ser técnico).
- **Novas funcionalidades místicas/IA**: exclusivas Premium (paywall via
  `FeatureAccess`/`PremiumUpgradeSheet`); as pré-existentes mantêm limites
  Free diários.
- **Banco de dados**: migrações SQLite sempre aditivas (nova versão em
  `database_helper.dart`) + espelho idempotente em
  `supabase/restore_database.sql`; novas tabelas sincronizáveis entram em
  `SyncEntity`/`SupabaseTables` e nas listas de `claimLegacyData`/
  `clearAllTables`.
- **Credenciais de admin**: via `--dart-define` (`ADMIN_EMAIL`/
  `ADMIN_PASSWORD`, secrets do GitHub Actions); em builds de debug
  `admin`/`admin` funciona automaticamente.

## Próximas Fases

### Fase 2 - Backend + Conta + IA Básica
- Cadastro/login de usuários
- Sincronização na nuvem
- Assistente IA para criação de feitiços
- Feature toggles para planos

### Fase 3 - Premium 1.0
- Monetização com assinaturas
- Planos free vs premium
- Limites ajustados por plano
- Backup em nuvem

### Fase 4 - Premium 2.0: Astrologia
- Mapa astral completo
- Perfil mágico personalizado
- Clima mágico diário
- Jornadas gamificadas

### Fase 5 - Refinos e Conteúdo
- Analytics mágicos
- Busca natural por IA
- Runas e divinação
- Packs mensais de conteúdo

## Contribuindo

Este é um projeto em desenvolvimento. Sugestões e melhorias são bem-vindas!

## Licença

Este projeto está sob licença proprietária. Todos os direitos reservados.

## Contato

Para dúvidas ou sugestões sobre o app:
- GitHub: [laylamonteiro](https://github.com/laylamonteiro)

---

Feito com magia e código por bruxas, para bruxas
