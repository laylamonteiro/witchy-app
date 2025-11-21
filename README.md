# Grimório de Bolso

Um grimório vivo, agenda mágica e companheiro de jornada para bruxas e bruxos iniciantes.

## Sobre o App

**Grimório de Bolso** é um aplicativo móvel desenvolvido especialmente para bruxas e bruxos iniciantes, principalmente no Brasil, que estão estudando sozinhos e desejam organizar sua prática mágica. O app combina:

- Organização de feitiços e rituais
- Diários de sonhos e desejos
- Calendário lunar adaptado
- Enciclopédia de cristais e cores
- Auto-cuidado e magia natural

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
3. (Opcional) Crie o secret `APK_RECIPIENTS` com o(s) e-mail(s) destino separados por vírgula para definir explicitamente quem recebe o APK. Se não definir, a pipeline envia automaticamente para `layla-sep@hotmail.com`.
4. Salve cada secret. Após isso, basta rodar o workflow via push para `main` ou manualmente em **Actions → Build and Send Android APK → Run workflow**.

> Dica rápida: se você só tem o endereço de e-mail, consulte a documentação do seu provedor para descobrir o host e a porta SMTP. Exemplos comuns:
> - Gmail / Google Workspace: `EMAIL_SERVER=smtp.gmail.com`, `EMAIL_PORT=587` (requer "App Password" com 2FA ativo).
> - Outlook/Office 365: `EMAIL_SERVER=smtp.office365.com`, `EMAIL_PORT=587`.
> - Provedores de hospedagem (cPanel, etc.): procure por "Configurações SMTP" no painel, o host costuma ser `mail.seudominio.com` e a porta 587.

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
