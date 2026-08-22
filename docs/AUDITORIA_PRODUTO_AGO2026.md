# Auditoria de produto — agosto de 2026

Diagnóstico do Grimório de Bolso contra a régua de app profissional da categoria: público-alvo, design, UX/UI, retenção e conversão para Premium

**Base:** versão 2.0.25+126 · 503 arquivos Dart · ~148k linhas · Android na Google Play + app web em grimoriodebolso.app
**Método:** 8 auditorias independentes de código (798 leituras de arquivo) + 5 frentes de pesquisa de mercado, com verificação factual hostil de ambas

## Restrições e decisões tomadas

Tudo abaixo já foi decidido pela dona do app. Esta seção é o contrato do plano de implementação — **nada aqui está em aberto**

### Restrições

1. **O login é obrigatório.** Não haverá modo convidado. A confirmação de e-mail não barra o uso — quem se cadastra já entra e usa (confirmado: não existe gate de confirmação no código)
2. **Não haverá iOS nativo.** A aposta é o app web/PWA

### Decisões

| # | Decisão | Consequência de implementação |
|---|---|---|
| 1 | **A sincronização passa a ser gratuita para todos os perfis** | Remover o `if (!isPremium) return false;` de `data_sync_service.dart:233` e a dependência de `isPremium` em `resolveCloudSyncPreference`. **É o item de maior efeito de toda a lista:** devolve visibilidade sobre 83% da base e conserta o iPhone em aba, que hoje perde o diário em 7 dias pelo ITP do Safari |
| 2 | **Persistir o estado da assinatura no servidor**, mudando a categoria ao adquirir, cancelar e expirar | Hoje `payment_service.dart` **não tem uma única referência a `profiles`**: os 4 pagantes da Play (2 anuais, 2 mensais) existem só dentro do RevenueCat, e no banco os quatro são `role='free'`. Desenho: webhook do RevenueCat → Supabase Edge Function → `profiles`/`entitlements`, com o app lendo do servidor e o RevenueCat como confirmação em runtime |
| 3 | **Fim de plano com aviso e carência, não rebaixamento seco** | Ler `billingIssueDetectedAt` e `willRenew`. Falha de cobrança → banner com CTA para o Customer Center **antes** de tirar acesso. Cancelamento → mantém Premium até o fim do período pago. Expiração → rebaixa com aviso |
| 4 | **Liberar cartas e runas; a enciclopédia detalhada continua Premium** | ⚠️ **Precisão apurada no código: não há nada a liberar.** `AppFeature.runesBasic` tem **zero call sites** e o texto das 78 cartas não é barrado em lugar nenhum — os significados já são gratuitos. O trabalho é só publicar. Já `lunarCalendarDetails` **é** aplicado em 5 pontos, então a lua só entra na camada básica |
| 5 | **Publicar como HTML estático: 78 cartas + 24 runas + fases lunares (básico) + 8 sabbats**, nos 3 idiomas | ~110 páginas × 3 ≈ **330 URLs**, com hreflang e JSON-LD. Validar 3 páginas piloto no Search Console **e o roteamento** antes de gerar o resto — as rotas estáticas não podem ser engolidas pelo fallback SPA do Flutter |
| 6 | **Analytics: PostHog + tabelas próprias no Supabase** | PostHog para funil e coorte, e para enxergar quem desiste **antes** de criar conta — que o banco nunca vê. Tabelas próprias para o que é do domínio (ritos, lições, tiragens), que já chegarão de graça com a sincronização aberta. Respeitar o toggle `privacy_analytics`, que hoje existe na tela e não controla nada |
| 7 | **Trial de 7 dias no plano anual** | Oferta base no Google Play ligada ao offering `default` do RevenueCat, lida via `storeProduct.introductoryPrice` para trocar o rótulo do card e o texto do botão, com fallback para o texto atual |
| 8 | **Anúncios: teto de 2-3/dia, cooldown de 15 min, e bloqueio total** durante ritual guiado, tiragem, leitura e resposta do Conselheiro | Configuração em `ad_service.dart` (hoje `_dailyCap = 10` e cooldown de 3 min) mais uma guarda de contexto nos pontos de valor |
| 9 | **Cadastro simplificado + consentimento separado** | Tirar "confirmar senha" (vira olho de mostrar senha) e o checkbox de termos (vira aceite implícito sob o botão, com log de versão e timestamp). Entra **uma caixa própria e destacada** só para o dado sensível de crença — art. 5º II e art. 11 da LGPD. Saldo: menos atrito no total, e o único obstáculo que sobra é o que protege |
| 10 | **Apple Sign-In: adiar, com critério escrito** | Fazer **agora** o SMTP próprio com `grimoriodebolso.app` (SPF, DKIM, DMARC) — vale por si e é pré-requisito. Reavaliar em 60 dias: *se a fatia de tentativas de login vinda de iPhone for relevante, a Apple entra* |
| 11 | **Não trocar o motor de cobrança agora** | Zero assinantes web: nada a migrar, nada a otimizar. Reabrir quando o SEO trouxer tráfego |
| 12 | **Congelar preço** | Sem tráfego, mudar preço é chute |

As restrições não invalidaram o diagnóstico. Elas o **reordenaram** — e uma delas revelou a peça que faltava para o plano fechar

---

## A tese

Sob essas restrições, o produto não é "um app com um site". É um **site de conteúdo com um app acoplado**

Essa inversão resolve a tensão que o login obrigatório parecia criar. **O site estático, sem login e indexável, é o modo convidado que o app está proibido de ter.** A parede de conta continua dura dentro do app — a restrição fica intacta — e o valor demonstrável, compartilhável e rastreável pelo Google passa a morar fora dele, onde não precisa de conta, não precisa de instalação, não sofre a poda de storage do Safari, não depende de push e funciona idêntico no iPhone

Login obrigatório deixa de ser pedágio quando a superfície gratuita não mora atrás dele

E o corte do que publicar não é gosto: é **commodity vs. autoral**. O significado das 78 cartas e das 24 runas está em dez mil sites — publicar o seu não perde nada e ganha a única fonte de descoberta que existe. As 88 lições não existem em lugar nenhum: publicá-las seria entregar o produto

---

## Os números reais

Todas as revisões anteriores deste relatório foram escritas sem denominador. Consultei o Postgres de produção e a conta Stripe. **O diagnóstico muda de ordem**

| | |
|---|---|
| Contas totais | **116** — a primeira em 14/07/2026 |
| Criadas nos últimos 30 dias | 88 |
| Com login nos últimos 30 dias / 7 dias | 42 / 11 |
| E-mail confirmado | 60 de 116 (52%) |
| `signup_platform` | **111 android · 0 web · 5 nulo** |
| `plan` / `role` | 96 free · **20 lifetime/premium** · 1 admin — nenhum mensal, nenhum anual |
| Assinaturas no Stripe (web) | **zero** |
| Cobranças no Stripe (web) | **duas**, ambas de R$ 9,90 da "Leitura Ciclo do Mês", ambas da própria conta da dona (uma aprovada, uma recusada) |

### O que isso derruba

**A aposta do web tem zero usuárias.** Não é "o web converte pouco" — é que **nenhuma conta jamais nasceu no web**. Toda a estratégia de PWA como substituto do iOS, todo o cálculo de Web Billing, Pix no checkout web e Apple Sign-In para o público de iPhone está sendo discutida sobre um canal que ainda não produziu uma única pessoa. Não significa que a decisão esteja errada — significa que ela ainda não foi testada, e que otimizar o checkout desse canal antes de alguém chegar nele é resolver o problema errado

**Os 20 "premium" são códigos beta, não pagantes.** Todos com `plan = lifetime`. Não há um único mensal ou anual gravado no servidor

**Respondido pela dona: há 4 pagantes na Play — 2 anuais e 2 mensais.** Eles não aparecem na consulta porque `PaymentService().isPro` vem do RevenueCat em tempo de execução e **não é persistido em `profiles`**: no banco, os quatro são `role='free'`. É exatamente o buraco que a decisão nº 2 fecha

**O `auth.audit_log_entries` está vazio.** A recomendação de "consultar o audit log para saber se algum iPhone entrou" não funciona neste projeto — a tabela não tem uma única linha. Corrijo isso onde escrevi

### O que isso revela, e que é o achado mais grave de toda a auditoria

**A sincronização é Premium** (`data_sync_service.dart:233` — `if (!isPremium) return false;`). Consequência: os dados das 96 contas gratuitas **nunca saem do aparelho**. Só 15 pessoas têm qualquer dado no servidor, e 12 delas são premium

Ou seja: **ela é cega para 83% da própria base por decisão de arquitetura, não por falta de SDK**. Nenhuma consulta SQL resolve isso

**Está decidido e resolvido pelas decisões 1 e 6:** a sincronização passa a ser gratuita para todos, e entra PostHog ao lado das tabelas próprias. As duas juntas fecham o buraco pelos dois lados — o dado de domínio passa a chegar ao servidor, e o funil de quem desiste **antes** de criar conta passa a ser visível

### E o que isso mostra de bom

Entre as 15 pessoas cujos dados chegam ao servidor, o engajamento é real: **média de 6,4 dias de check-in, máximo de 24 dias, e 13 das 15 ativas nos últimos 7 dias**. Só 2 pessoas registraram um único dia

O produto segura quem entra. O funil de cadastro para cá é que está vazando — e a aquisição é o gargalo, não a retenção

### A leitura correta, agora com denominador

**116 contas · 4 pagantes · 0 vindos do web.** Isso é uma taxa de conversão de ~3,4% sobre a base total — que não é ruim para a categoria. O problema não é o funil de compra: **é que só 116 pessoas passaram por ele.**

O gargalo é **aquisição**, e o SEO é tudo. Isso confirma a onda de descoberta como a que importa, e rebaixa quase tudo que é otimização de conversão — não se otimiza o funil de um tráfego que não existe

Foi essa leitura que sustentou três das decisões: **adiar Apple Sign-In** (US$ 99/ano + rotação semestral para um canal com zero usuárias), **não trocar o motor de cobrança** (zero assinantes web) e **congelar preço**

---

## O padrão que se repete: escrito e desligado

As oito auditorias chegaram ao mesmo achado por caminhos diferentes. Não é código que falta escrever — é código escrito, testado, localizado em três idiomas, sem um fio ligando a ponta

| Existe e está pronto | Sem o fio ligado |
|---|---|
| `OfferEngine` grava exposição, clique, dispensa e conversão por oferta | Morre no `SharedPreferences`; `eventCount` não tem um único chamador |
| `BlockedAccessEvent.toAnalyticsParameters()` monta o evento de bloqueio completo | `setBlockedAccessAnalyticsHook` nunca é chamado de lugar nenhum |
| Degustação da lição: escrita, localizada em 3 idiomas, instrumentada | Interceptada antes de renderizar — nenhuma usuária jamais viu |
| `bestStreak` calculado a partir de 11 tabelas de evidência | Nunca exibido em nenhuma tela |
| `JourneyProgress` existe como modelo | Não é persistido: as 7 jornadas não dão XP, badge nem celebração |
| Notificação com deep link, agendamento e canais, tudo testado | `notification_service.dart:37` — `if (kIsWeb) return false;` e o mesmo nas linhas 351, 359 e 364 |
| `daily_checkins` já sobe para o Supabase com data por usuária | Nenhuma edge function lê isso — win-back nunca foi tentado |
| Dois anos de dados reais no Postgres, com `signup_platform` já migrado | Ninguém rodou um `SELECT` |

Esse último item é o mais caro de todos, e é o mais barato de corrigir

---

## Notas por dimensão

| Dimensão | Nota | Veredito |
|---|---|---|
| Conteúdo editorial e IA | 6/10 | O maior ativo do produto, e o mais subvendido |
| Design e identidade visual | 6/10 | Identidade forte, sistema incompleto — só cor virou token |
| UX e arquitetura da informação | 5/10 | Navegação bem resolvida, mas o vocabulário colide e há perda de dado |
| Monetização e conversão | 5/10 | Encanamento sólido, e o paywall está cobrando pela coisa errada |
| Ativação | 4/10 | Com login obrigatório, a porta única tem um captcha que admite falhar |
| Retenção | 4/10 | Sequência bem feita; o canal de volta existe (e-mail) e nunca foi usado |
| Infraestrutura de produto | 4/10 | CI/CD acima da média, observabilidade zero |
| Plataforma e distribuição | 3/10 | Sem App Store, a descoberta é tudo — e o domínio tem 642 palavras |

Plataforma caiu de 4 para 3 na revisão. Não porque o iOS foi cortado, mas porque a decisão de cortá-lo **transfere todo o peso da descoberta para o canal web**, e é lá que o buraco é maior

---

## Os seis gargalos, em ordem de dependência

### 1. O produto é cego — mas a base já sabe responder

Nenhum SDK de analytics, crash reporting ou remote config. Os handlers globais capturam tudo e gravam só localmente; como `runZonedGuarded` impede o processo de morrer, nem o Play Vitals enxerga. São 285 blocos `catch` no `lib/`, 23 terminando em `debugPrint` e 10 vazios

A prova do custo: o onboarding inteiro — 474 linhas, 5 slides, 13 chaves de texto — foi apagado no commit `d4fa073` em 21/08/2026 **sem um único número** que dissesse se ele ajudava

**O que estava faltando na primeira versão desta auditoria:** existe um app em produção há dois anos, com base real, e ninguém olhou o que essa base já diz. Não é preciso SDK nenhum para responder *quantas contas, quantas ativas em 30 dias, quantas pagando, retenção por coorte, quanto é web e quanto é Android* — isso é SQL no Postgres que já existe. A tabela `profiles` tem `created_at`, e `supabase/signup_platform_migration.sql` já foi escrita exatamente para essa pergunta

Isso muda a ordem de metade das recomendações. Com 2.000 contas e 40 assinantes, o problema é aquisição e o SEO é tudo. Com 40.000 contas e 300 assinantes, o problema é conversão e o paywall é tudo. **São planos diferentes, e a resposta cabe numa tarde**

### 2. Ninguém acha o app

Sem App Store, a descoberta tem que vir de busca e de social. Hoje ela não vem de lugar nenhum

O Flutter removeu o renderer HTML na versão 3.29 — não existe mais a saída de "buildar com `--web-renderer html` para o Google indexar". CanvasKit desenha tudo dentro de um `<canvas>`, e o Googlebot não extrai texto de canvas WebGL. O próprio repositório já reconhece isso, num comentário em `site/sitemap.xml`: *"a raiz é o app: uma tela só, desenhada em canvas, sem conteúdo indexável"*

O resultado medido:

| | |
|---|---|
| Palavras indexáveis em todo o domínio | **642**, numa página só (`/sobre/`) |
| URLs no sitemap | 3 — duas delas jurídicas (privacidade, termos) |
| Lições, cartas, runas, rituais, verbetes indexáveis | **zero** |

E o teste que fecha o diagnóstico: **buscar o nome exato do produto não retorna o domínio dele.** Retorna um item do Genshin Impact, um jogo de tabuleiro e — pior — um concorrente direto chamado **Grimorio** (Blank Tech), que está na App Store *e* na Google Play, funciona offline, e suporta sete idiomas incluindo português, com posicionamento quase idêntico: enciclopédia esotérica, 78 arcanos, runas, numerologia, mapa astral, I Ching e diário de sonhos

Isso desmonta uma defesa que parecia sólida. O trilinguismo protege contra Co-Star, CHANI e The Pattern — que operam só em inglês, confirmado — mas **não protege contra o concorrente posicionalmente idêntico, que já fala português e já está na loja onde você decidiu não estar**. A defesa contra esse é a profundidade pedagógica e a curadoria autoral, não o idioma

### 3. A porta de entrada é única, e pode estar trancada

Com login obrigatório, 100% do público atravessa um único ponto. Esse ponto tem seis obstáculos e um componente que admite falhar

**O inventário:** nome, e-mail, senha, **confirmar senha**, checkbox de termos que desabilita o botão, e captcha Turnstile. Três desses são removíveis sem perda funcional

**O problema grave:** o captcha está posicionado *antes* do caminho de menor atrito. Em `login_page.dart`, `CaptchaGate.resolve` está na linha 616 e `signInWithGoogle` na 630 — o Turnstile roda antes do botão do Google. E o comentário do próprio captcha diz:

> "O Turnstile roda numa WebView; quando ela está 'fria' (app recém instalado, dados limpos, rede lenta) o primeiro carregamento **costuma falhar**. Antes, esse erro fechava a folha devolvendo null (…) quebrando a PRIMEIRA tentativa de quem acabou de instalar"

Já existe mitigação — 3 tentativas de recriar o widget — o que significa que isso quebrou em produção antes. O cenário "WebView fria em app recém-instalado" é o cenário de **100% dos novos usuários**

**E o risco específico do iPhone:** login com Google dentro de PWA standalone no iOS é reconhecidamente frágil. O código já tenta o caminho seguro (Google Identity Services na própria página via `signInWithIdToken`, `supabase_auth_repository.dart:206-265`) mas cai para `signInWithOAuth` com redirect completo quando o GIS falha — e o GIS falha rotineiramente no Safari por bloqueio de cookie de terceiros. No standalone, o redirect abre navegador embutido, o verificador PKCE fica noutro contexto de storage, e a troca de código falha

Com login obrigatório e zero crash reporting, **se isso estiver quebrado a porta de 100% do público iOS está trancada e ninguém descobriria.** É meia hora de teste num iPhone real

*Ressalva de implementação:* o Turnstile pode estar exigido do lado do servidor, no painel do Supabase. Se estiver, remover o gate no cliente não simplifica o login — quebra ele. Verificar o painel antes

### 4. As chaves de IA estão publicadas

A action que escreve `groq_credentials.dart` e `gemini_credentials.dart` roda **dentro do job de build web** (`release.yml:503`). Como o Dart compila para JavaScript, as duas chaves viram literais dentro do `main.dart.js` servido publicamente. DevTools, buscar por `gsk_`, menos de um minuto. Não existe `supabase/functions/` — não há proxy

Os limites de uso vivem todos no aparelho e são contornáveis: mudar o fuso ou reinstalar zera os contadores

**E há um buraco que cresce com o sucesso:** em `user_model.dart`, `canUseAi => isPremium || ...` — o plano pago é ilimitado. Um assinante intenso a R$ 19,90 (líquidos de ~R$ 16,90 depois da Play) consumindo centenas de chamadas ao Groq e ao Gemini fica negativo sozinho. Um teto generoso e invisível resolve numa tarde

**O achado que a aposta do web torna urgente:** `ad_service.dart:54-55` é `!kIsWeb && (Android || iOS)`. A usuária gratuita da **web não gera receita de anúncio nenhuma**. Cada pessoa de iPhone que chega pelo PWA — exatamente o público que a estratégia inteira quer atrair — é 100% custo de Groq e Gemini com zero receita. **Se a aposta do web funcionar, ela piora a economia unitária do Free antes de melhorar a da assinatura**

### 5. A venda é no escuro, e o paywall está invertido

**Não existe trial.** Nenhuma leitura de `introductoryPrice` ou `subscriptionOptions` nas 961 linhas do serviço de pagamento

**Um paywall genérico atende ~20 contextos.** `showPremiumUpgradePaywall(BuildContext)` não recebe origem, e 16 call sites constroem `const PremiumUpgradeSheet()` direto

**A lista de benefícios esconde os dois maiores ativos** — vende "leituras ilimitadas" e "enciclopédia completa" e não cita as 88 lições nem os 46 rituais guiados

**E o achado mais consequente desta revisão: o paywall está cobrando pela coisa errada.** Os detalhes de cristais, ervas, cores e metais são Premium (`feature_access.dart`) — informação commodity que qualquer pessoa acha grátis em três segundos. Enquanto isso, o que é insubstituível — o diário, o registro, a prática acumulada, o grimório que é *seu* — é o que sustentaria a assinatura

Isso quebra três coisas ao mesmo tempo: faz o preço parecer ganancioso, torna o plano de SEO impossível sem canibalizar, e desalinha a história que o app conta. **Inverter — referência de graça, prática e registro pagos — conserta as três numa decisão só.** É a única mudança que alinha conteúdo, aquisição e monetização de uma vez

*Nota de implementação:* a regra de lição gratuita **não está** no `FeatureAccess`, apesar do comentário em `trails_data.dart:33` dizer que está. Ela está duplicada inline em `trail_page.dart:59` e `lesson_page.dart:86`. Mexer nessa política exige dois pontos de edição, ou a tela da trilha e a tela da lição divergem

### 6. Não há canal de volta — e o e-mail está ali, ignorado

Toda notificação é local, agendada no aparelho, no último dia em que a pessoa abriu o app. Não há push remoto. No web, a notificação está desligada **por decisão de código**, não por limitação de plataforma (`notification_service.dart:37`)

O lembrete diário é uma frase única e estática, agendada com `matchDateTimeComponents: DateTimeComponents.time`: quem fica seis meses recebe "🐈‍⬛ O Salem te chama" **180 vezes**

**Mas o login obrigatório entrega um ativo que a primeira versão desta auditoria subestimou: o app tem o e-mail de 100% da base.** E o valor disso não é a cadência lunar. São três coisas:

- É o **único caminho legal** de vender o plano anual pelo checkout web a uma usuária Android sem violar a política anti-steering da Play
- É o **antídoto ao ITP do Safari**, que apaga IndexedDB, localStorage e o registro do service worker após 7 dias sem interação — um link mágico devolve a pessoa ao grimório depois que o Safari apagou tudo
- É a **apólice de seguro contra suspensão de loja**, que é o risco existencial real de um app de bruxaria na Play brasileira

Sobre a sequência, uma correção da primeira versão: **existe uma graça**. `currentStreak()` verifica hoje e, se não há check-in, recua para ontem antes de zerar — o comentário no código diz "quem ainda não abriu o app hoje não perde a sequência antes do dia acabar". O que não existe é congelamento, reparo ou aviso; um dia efetivamente perdido zera em silêncio. E `bestStreak` é calculado e nunca mostrado

---

## A aposta do web: o que precisa ser verdade

A decisão está tomada. O que segue é o que precisa dar certo para ela render, e o que é ilusão

### O que a decisão custa (e o que não custa)

**Não custa margem.** A Apple nunca cobrou nada e nunca vai cobrar, porque não há app na App Store. Todo o noticiário de Epic v. Apple é irrelevante aqui — e, de passagem, ele foi mal relatado em toda parte: o 9º Circuito **afirmou** a condenação em dezembro de 2025 e manteve a injunção; a Apple protocolou certiorari em maio de 2026, ainda pendente, sem decisão antes de 2027

**Custa descoberta.** Não é economia de 30% — é abrir mão da vitrine que traz gente até o produto. Esse é o preço real, e é por isso que o gargalo 2 é o gargalo 2

### O que é ilusão: Web Push no iPhone

Em 2026, a Push API no iOS continua exclusiva de web apps adicionados à Tela de Início. Não há brecha: ela simplesmente não existe numa aba do Safari. O Declarative Web Push (Safari 18.4/18.5) simplificou o envio — dispensa service worker — mas não removeu o requisito de instalação

O funil é multiplicativo e cada portão é estreito: chegar ao site → descobrir "Adicionar à Tela de Início" sem prompt do sistema (o iOS não tem `beforeinstallprompt`) → aceitar a permissão. Sobre uma base que já é ~18% dos aparelhos brasileiros

*(A estimativa de "10-15× menor que push nativo" que circula entre fornecedores é heurística de vendor, não medição. Trate como ordem de grandeza. A direção se sustenta e já basta para a decisão.)*

**Recomendação: não construir Web Push em 2026.** É o pior retorno por esforço de toda a pesquisa, e exige backend de envio que hoje não existe. O canal de retorno é e-mail, que já existe para 100% da base e funciona idêntico nas três plataformas. Se um dia construir, construir para Android primeiro — lá existe `beforeinstallprompt` e o opt-in é de ~67%

### O que é binário e barato: o login funcionar

Se o login com Google quebra em PWA standalone no iOS ou dentro do navegador embutido do Instagram, **a aposta inteira vale zero** — e sem crash reporting ninguém descobre. Testar num iPhone real, hoje, custa meia hora

Se quebrar, o caminho é código OTP de 6 dígitos por e-mail como opção principal nesses contextos, com detecção de navegador embutido e instrução de abrir no Safari

### O que é autoinfligido: o iPhone que volta para um app vazio

O ITP do Safari apaga todo o storage de script após 7 dias sem interação, em aba normal. O app guarda os dados locais em `sqflite`/`sqlite3.wasm`. Uma usuária gratuita de iPhone escreve um diário de sonhos, some por uma semana, e **volta para um app vazio**

O diagnóstico correto não é "insista na instalação". É que **a persistência no servidor é premium**. Vender sincronização quando a plataforma apaga os dados em sete dias é vender proteção contra um dano que o próprio produto permitiu. O login já é obrigatório, a conta já existe, e o custo marginal de guardar texto no Postgres é irrisório

### Higiene de PWA que falta (barata, e uma delas é urgente)

| Item | Estado | Por quê |
|---|---|---|
| `scope` no manifest | **ausente** | **Urgente:** sem ele, uma navegação para fora — exatamente o que o redirect do OAuth faz — pode jogar a pessoa para fora do web app |
| `screenshots` | ausente | Destrava o diálogo de instalação rico do Chrome Android, com cara de loja |
| `id`, `lang` | ausentes | Identidade estável da PWA |
| `start_url` | `"."` | Trocar por `"/"` |
| `apple-mobile-web-app-capable` | ausente no `index.html` | Só há o `mobile-web-app-capable` moderno (linha 45) |
| `apple-touch-startup-image` | ausente | Splash em branco no iOS |
| `description` | **já existe** | Correção da primeira leitura: está no manifest e no `<meta>` |

### O capítulo do dinheiro, corrigido

Este foi o pedaço da pesquisa que mais errou, e ele erra dos dois lados:

- **A taxa reduzida do Google Play não vale aqui.** O Billing Choice Program (10% de serviço) entrou em 30/06/2026 **apenas para EUA, EEE e Reino Unido**. Brasil e o resto do mundo ficam nas taxas antigas — **15% em assinaturas — até 30/09/2027**. A comparação correta hoje é Play 15% contra ~3,9% no web (Stripe 2,9% + US$ 0,30; RevenueCat grátis até US$ 2.500 MTR): **~11 pontos**, não ~6. Em R$ 119,90/ano, da ordem de R$ 12 por assinante
- **Mas esses 11 pontos não podem ser capturados dentro do app Android.** Billing alternativo com escolha do usuário também não existe no Brasil até setembro de 2027. Empurrar a usuária Android para o checkout web não é ganho de margem — é risco de suspensão do único canal nativo que existe. **Play Billing é o único caminho sancionado dentro do app Android.** O Web Billing serve iOS, desktop, e-mail e busca
- **Pix não está disponível no RevenueCat Web Billing.** Ele expõe exatamente cartão, Apple Pay e Google Pay, e **não há como habilitar os métodos locais da Stripe por baixo** — a conta Stripe é da RevenueCat, não dela. Ver a seção *Meios de pagamento* adiante: o caminho certo não é webhook próprio, é trocar o motor de cobrança do web

Num mercado onde o Pix domina e a recorrência por cartão falha muito, a compra avulsa **Leitura do Ciclo** por Pix é provavelmente o produto de maior conversão disponível — e é o único formato em que Pix casa naturalmente

---

## Três decisões pedidas: sem iPhone, login com Apple, mais pagamentos

Esta seção responde a três pedidos feitos depois da revisão 2. Ela também **corrige um erro meu**: escrevi que o RevenueCat é a fonte única de verdade do `isPremiumEffective`. Não é — `auth_provider.dart:89-92` é um OR de três fontes (`PaymentService().isPro || _currentUser.isPremium || plan == lifetime`), e `restorePurchases()` já está ligado à paywall em `subscription_page.dart:728` e `:768`. Isso reduz o tamanho de vários riscos abaixo

### 1. Validar o iPhone sem ter um iPhone

Não é preciso. O plano muda de "provar que funciona uma vez" para "fazer o produto contar todo dia", e sai de graça

**O suspeito número um mudou — e é pior do que eu disse.** Eu apontei o OAuth do Google. Mas `login_page.dart:569-573` mostra que **o fluxo de e-mail e senha também passa pelo `CaptchaGate.resolve`**, e lança se o token vier `null`. Ou seja: as duas portas do app têm a mesma fechadura, e essa fechadura é uma WebView que o próprio código admite falhar em app recém-instalado. Não existe "caminho alternativo" hoje — existe um gargalo único para 100% da base

| Passo | Custo | O que responde |
|---|---|---|
| ~~Perguntar ao `auth.audit_log_entries`~~ — **feito: a tabela está vazia neste projeto.** A resposta veio de `signup_platform`: **0 contas web** | feito | Não existe público de iPhone convertido. Zero, não pouco |
| **Corrigir o `scope` do manifest** (`"scope": "/"`, `start_url: "/"`) | R$ 0 · 10 min | Sem `scope`, o iOS decide sozinho o que é "dentro do app", e o redirect do OAuth é navegação fora da origem — sai do modo standalone |
| **Instrumentar a tentativa de login**, com evento de INÍCIO e chave de correlação, cobrindo `CaptchaGate`, e-mail/senha e Google | R$ 0 · 3-5h | Distingue "ninguém tentou" de "tentou e sumiu no meio". O audit log só enxerga o que chegou ao servidor — captcha que não renderizou e redirect que não voltou morrem no cliente |
| **Healthcheck externo por cron**: uma conta de teste fazendo login em produção de hora em hora, com alerta | R$ 0 · 2h | Pega a classe inteira de morte silenciosa: Supabase fora, chave errada num build, CSP, provider desconfigurado — e, no futuro, o segredo semestral da Apple |
| **O roteiro de 5 minutos para uma amiga com iPhone** | R$ 0 | Cobre os dois cenários que nenhuma fazenda de dispositivos entrega barato: login **dentro do ícone instalado** e link aberto no navegador do Instagram |

Fazenda de dispositivos só depois, e só se o dado apontar falha específica: **TestingBot** dá 60 minutos grátis com aparelho real e sessão manual, sem cartão. BrowserStack e Sauce Labs dão ~30 min de trial. Sauce Labs pago (~US$ 199/mês) é caro demais para este caso. Se um dia precisar do Simulador do Xcode: Mac mini M4 na Scaleway a €0,22/h com mínimo de 24h ≈ **€5,28**

Duas ressalvas honestas: um "não entrou" numa fazenda pode ser IP de datacenter disparando desafio de segurança do Google — conserta-se um bug que não existe. E instrumentar só mede quem chega: se nenhuma usuária de iPhone abrir o app, o dado fica mudo e a conclusão "está tudo bem" é falsa

*(Tentei sondar o app ao vivo daqui: o WebKit do Playwright está bloqueado no allowlist do proxy, e `grimoriodebolso.app` responde 403 no CONNECT. Sondagem remota está descartada neste ambiente.)*

### 2. Login com Apple

**É possível sem app iOS**, e o caminho é curto. Um App ID no portal com a capability ligada, um Services ID como `client_id`, Domains e Return URLs apontando para o Supabase, e no código `signInWithOAuth(OAuthProvider.apple)` — **~20 linhas, zero pacotes novos**. O `form_post` da Apple vai para `https://<ref>.supabase.co/auth/v1/callback`, não para a página: o app só recebe um GET com `?code=`, a mesma forma do fallback do Google que já roda

Não usar o pacote `sign_in_with_apple` na web: a própria documentação do Supabase desaconselha, porque ele exige script no `index.html` e endpoint de servidor próprio. E não usar o caminho popup: popup em PWA instalado no iOS frequentemente não abre, e há relatos de `window.opener` virar `null` em WKWebView desde o iOS 17.5

**O que custa de verdade:**

| Item | Valor |
|---|---|
| Apple Developer Program | **US$ 99/ano, obrigatório.** A isenção existe mas exclui explicitamente quem vende bens ou serviços digitais |
| Rotação do segredo | **A cada 6 meses, para sempre.** A Apple rejeita client secret com `exp` acima de 15.777.000 s. Sem rotação, **o login com Apple morre em silêncio para todo mundo** |
| Implementação | ~meio dia (20 linhas + botão em 2 telas + 8 chaves nos 4 ARBs) |
| Pré-requisitos | SMTP próprio e vinculação de identidades — ver abaixo |

**Três coisas que precisam estar resolvidas antes do botão existir:**

1. **O `scope` e a prova de que o redirect volta.** A Apple usa o mesmo mecanismo de redirect que pode já estar quebrado para o Google em standalone. Entregar um segundo botão pelo mesmo cano antes de consertar o cano é dobrar a aposta num terreno não verificado
2. **SMTP próprio com o domínio registrado na Apple.** Com Hide My Email, o app recebe `@privaterelay.appleid.com`, e **o relay só entrega se o domínio remetente estiver registrado em "Sign in with Apple for Email Communication" com SPF batendo**. Fonte não registrada = bounce. E o canal pode morrer em massa sem aviso: em 09/08/2025 um desenvolvedor viu ~20.000 endereços de relay começarem a dar hard bounce da noite para o dia
3. **Vinculação de identidades por conta, não por e-mail.** O Supabase só vincula automaticamente quando os e-mails batem — e com Hide My Email eles **nunca** batem. O tamanho real do risco é menor do que a pesquisa pintou, porque `restorePurchases()` já existe e resolve quem comprou pela Play; mas para quem comprou pelo **RevenueCat Web Billing não há recibo de dispositivo para restaurar**

**O cenário que nenhuma frente da pesquisa viu, e que é o pior possível neste produto:** a pessoa entra com Apple + Hide My Email, a Apple para de encaminhar, e ela fica sem senha (entrou por social), sem OTP e sem reset. Num app de login obrigatório e diário íntimo, **perder o acesso é perder o conteúdo**. Mitigação: pedir um e-mail de contato a quem entrar com relay, e manter e-mail+senha sempre visível

**Minha recomendação: adiar, não descartar.** Compre o dado antes do compromisso perpétuo, e escreva o critério agora: *se depois de 60 dias de instrumentação a fatia de tentativas de login vinda de iPhone for relevante, a Apple entra.* O que **vale fazer já**, independente da Apple, é o SMTP próprio — ele serve a quatro coisas: sai do limite do SMTP embutido, viabiliza OTP, melhora a entrega de confirmação e reset hoje, e é pré-requisito absoluto do relay

*Antes de tudo isso, um item de 5 minutos:* abrir **Authentication → SMTP Settings** no painel do Supabase e ver se já existe SMTP próprio configurado. Isso é configuração de painel e não aparece no repositório — a pesquisa afirmou que não existe sem poder verificar

### 3. Mais formas de pagamento

**A jogada de melhor retorno pode custar zero, e começa com uma verificação de 20 minutos.** A página oficial do Google Play para o Brasil diz que o Pix serve para "comprar apps e conteúdo digital e **renovar assinaturas automaticamente**". Se isso valer no checkout real do produto de assinatura, o canal que traz a maior parte da receita **já aceita Pix** — e o trabalho vira mudar a copy da paywall e da ficha da loja, sem integrar nada

Verificar antes de anunciar: uma página de ajuda genérica não é contrato de comportamento no checkout, e prometer "aceitamos Pix" sem aceitar gera reembolso e avaliação ruim

**O que está fechado:**

- **Dentro do app Android brasileiro, Play Billing é o único caminho até 30/09/2027.** O Billing Choice liberou EEE/Reino Unido/EUA em 30/06/2026, Austrália em 30/09/2026, Japão e Coreia em 31/12/2026 — o Brasil fica por último
- **RevenueCat Web Billing expõe exatamente três métodos:** cartão, Apple Pay e Google Pay. Não há Pix, não há boleto, e **não dá para habilitar os métodos locais da Stripe por baixo** — a conta Stripe é da RevenueCat
- **Stripe com conta brasileira aceita Pix só como pagamento avulso, e o Pix é *invite-only* para contas BR.** Pix Automático **não existe** para conta brasileira. O produto da Stripe que resolveria isso (Managed Payments) não atende empresa no Brasil
- **Boleto** é o oposto: funciona recorrente na Stripe BR, mas sem Customer Portal, sem Radar, confirmando em até 1 dia útil, liquidando em T+2 e exigindo CPF

**O caminho certo, se quiser mais métodos no web, é trocar o motor — não construir webhook.** O RevenueCat Web tem integrações nativas com **Paddle Billing** (Pix avulso, boleto, PayPal, cartões, carteiras; *merchant of record*, o que resolve imposto nos builds en/es; 5% + US$ 0,50) e com **Stripe Billing usando a conta dela** (com os métodos que ela habilitar). Nos dois casos **o entitlement continua sendo do RevenueCat** — nenhuma segunda fonte de verdade

Construir webhook próprio + tabela de entitlement + OR no cliente é a única opção que cria de fato uma segunda fonte de verdade, e é a que mais quebra em silêncio num app sem crash reporting. Descartar

**Duas correções sobre o Pix que circulam erradas:** ele **tem** estorno forçado e **você não pode contestar** — a Stripe remove os fundos da conta quando o parceiro aceita a devolução. O argumento de margem continua de pé; o de "zero chargeback" cai. E **CPF**: Paddle e boleto exigem CPF no checkout. Um app de diário íntimo que passa a guardar CPF muda de categoria de risco sob a LGPD — o que é um argumento real a favor do *merchant of record*, onde o dado fica com ele

**Ordem sugerida:** verificar o Pix na Play (20 min) → se confirmar, mudar a copy e parar por aqui → se não confirmar, medir quanta gente chega à paywall do web e desiste, e só então escolher **um** motor. Antes de qualquer migração, olhar no painel do RevenueCat quantas assinaturas web existem hoje: com três, é um e-mail; com trezentas, é projeto próprio

---

## Calibração de mercado

Benchmarks públicos, não medições deste app:

- **App Store concentra ~70,5% do gasto** entre as duas lojas e **73% da receita de assinatura**, a partir de ~21% dos downloads. ARPU iOS ~US$ 138 contra ~US$ 72 no Android
- **Paywall duro converte ~5× mais que freemium** (10,7% vs 2,1% de trial-to-paid em D35). **89,4% dos trials começam no dia do install.** Trials de 17-32 dias convertem ~42,5% contra ~25,5% dos de menos de 4 dias; 7 dias convertem ~40%
- **"Barato converte mais" é falso.** Apps de preço alto têm conversão D35 de 9,8% contra 4,3% dos de preço baixo, e RLTV por pagante 3,3× maior
- **IA atrai e não segura:** apps com IA geram 41% mais receita por pagante mas têm churn 30% mais rápido — retenção anual de 21,1% contra 30,7%. **O Conselheiro Místico é argumento de conversão, não de retenção**
- **O Brasil é o melhor lugar para construir e o pior para extrair:** receita mediana por install de US$ 0,06-0,09 na América Latina contra US$ 0,39 na América do Norte
- **A categoria acabou de mudar de dono:** a Midjourney comprou o Co-Star (anunciado em 24/07/2026, ~4,3M MAU) e planeja um gerador de imagens astrológico. A categoria vai ser inundada de conteúdo gerado — o que torna **autoria humana visível** um diferencial defensável, não um detalhe

Sobre os concorrentes: **CHANI** é o de maior faturamento nos EUA (US$ 11,99/mês, US$ 107,99/ano) e retém por conteúdo perecível novo toda semana, escrito e narrado por humanas. **The Pattern** retém por lock-in social (compatibilidade com amigos). **Labyrinthos** é o único concorrente de aprendizado real — e prova que o formato funciona: aulas, quizzes com repetição de erro, avatar que sobe de nível, flashcards. No Brasil, os fortes são de astrologia e de consulta, não de ensino: **Astrolink** (cujo pacote Android é literalmente `com.astrolink.webapp`) e **Personare**, a partir de R$ 9,90

**Sobre preço:** R$ 19,90/mês está no topo da faixa local; o anual de R$ 119,90 (~R$ 10/mês) está bem calibrado. Congelar a discussão de preço internacional até haver leitura da base e tráfego real em es — precificar para mercados onde não há distribuição é resolver o problema errado

---

## O que já está bom, e não deve ser mexido

- **Paridade trilíngue travada por CI.** Testes de paridade de conteúdo, trilhas, prompts e rituais bloqueantes, com scanner de português hardcoded
- **Esteira de release de nível profissional.** Guarda de semver, versionCode determinístico conferido contra todas as tags, gate no SHA da tag, conferência de assinatura, consulta prévia à API da Play, aprovação humana em `production`, trava simétrica sandbox × produção da chave do RevenueCat
- **Fonte única de verdade de acesso** com gates fail-closed de verdade — o conteúdo pago não chega à árvore de widgets atrás do blur
- **Ética de cobrança correta na Leitura do Ciclo.** Crédito gravado antes da geração, falha de IA não consome a compra, aviso de "poucos registros" antes de pagar
- **Motor de ofertas com guardrails reais** — e a graça do dia corrente na sequência
- **Movimento reduzido do sistema respeitado em 16 pontos.** 194 ilustrações próprias, mascote animado por sprites
- **`LanguageGuard` e `sync_coverage_test`** — duas soluções originais que travam classes inteiras de bug em vez de casos pontuais

---

## Roadmap por ondas

Estimativas para **uma pessoa**. Cada onda tem critério de saída verificável

### Onda 0 — Uma tarde, antes de decidir qualquer coisa

| Item | O que fazer |
|---|---|
| **Ler a base que já existe** | SQL no Postgres: contas totais, ativas em 30/90 dias, assinantes ativos, retenção por coorte de mês, quebra por `signup_platform`, quantas contas nunca completaram a lição 1. Sem escrever código de app |
| ~~Consultar o `auth.audit_log_entries`~~ | **Já feito, e a tabela está vazia.** A resposta veio por outro caminho: `signup_platform` mostra 0 contas web, ou seja, nenhum iPhone jamais completou cadastro |
| **Corrigir o `scope` do manifest** | `"scope": "/"` e `start_url: "/"`. Dez minutos, e é o candidato número um a estar quebrando o retorno do OAuth em standalone no iOS |
| **Mandar o roteiro de 5 minutos para uma amiga com iPhone** | Cobre o que nenhuma fazenda de dispositivos entrega barato: login dentro do ícone instalado e link aberto no navegador do Instagram |
| **Rotacionar as chaves de IA** | Considerar as atuais comprometidas |

**Critério de saída:** você sabe se o problema é aquisição ou conversão, e se algum iPhone já conseguiu entrar

### Onda 1 — Parar o sangramento · ~1 a 2 semanas

| Item | Esforço |
|---|---|
| Proxy de IA em Edge Function autenticada por JWT, com teto por `user_id`; apagar os arquivos de credencial do build | médio |
| Teto generoso e invisível de IA **no plano Premium** (hoje é ilimitado e fica negativo com o sucesso) | baixo |
| Escrita Livre: `AutomaticKeepAliveClientMixin` + `_save()` no `dispose()` + autosave — hoje trocar de sub-aba apaga o texto | baixo |
| `UnsavedChangesGuard` nos 8 formulários sem `PopScope` | baixo |
| Contraste do tema claro: `starYellow` sobre surface dá 2,25:1 com 145 usos. Refazer + teste bloqueante iterando `AppThemes.all` | médio |
| `scope` no manifest (urgente pelo OAuth), mais `id`, `lang`, `screenshots`, `start_url: "/"`, `apple-mobile-web-app-capable`, `apple-touch-startup-image` | baixo |
| Rollout gradual (`userFraction: 0.2`) na produção | baixo |

**Critério de saída:** nenhuma chave no bundle, nenhum formulário perde dado, o tema claro passa no teste

### Onda 2 — Abrir os olhos · ~2 semanas

| Item | Esforço |
|---|---|
| Analytics (PostHog ou Firebase), com dicionário de no máximo 25 eventos definido **antes**. Respeitar o toggle `privacy_analytics`, que existe na tela e não controla nada | médio |
| **Ligar os hooks órfãos** — o de bloqueio no boot, o `OfferEngine` emitindo remoto, o pagamento emitindo start/complete/cancel. Dá o funil completo em menos de um dia | baixo |
| Crash reporting nos 4 pontos que já capturam tudo, com versão, locale, plano e breadcrumb do `DebugLogService` | baixo |
| Instrumentar o específico da aposta web: modo de exibição (standalone vs aba), plataforma, instalação da PWA | baixo |
| **Instrumentar a tentativa de login**, com evento de INÍCIO e chave de correlação, cobrindo o `CaptchaGate`, e-mail/senha e Google. O audit log do Supabase só vê o que chegou ao servidor — captcha que não renderizou morre no cliente | médio |
| **Healthcheck externo por cron**: conta de teste logando em produção de hora em hora, com alerta. Pega a morte silenciosa que a instrumentação não pega, porque ela só mede quem chega | baixo |
| Remote config pobre: tabela `app_config` no Supabase lida no boot com fallback nas constantes | médio |

**Critério de saída:** dá para ver D7, o funil de paywall por origem, e quanto do público é web

### Onda 3 — Ser achável · ~3 a 4 semanas

A onda que a decisão de não fazer iOS torna obrigatória

| Item | Esforço |
|---|---|
| **Inverter o paywall primeiro.** Liberar detalhes da enciclopédia e significado de cartas e runas; manter e reforçar o pago em prática, registro, IA, rituais e mapa astral. Sem isso, o item seguinte canibaliza | médio |
| **Publicar HTML estático indexável ao lado do canvas:** 78 cartas, 24 runas, 8 datas da roda do ano, fases lunares, e **exatamente 1 lição por trilha** (9 páginas, como amostra da voz). Nos 3 idiomas, com hreflang e JSON-LD. ~130 URLs ≈ 390 páginas. **Nunca as outras 79 lições, nunca os 46 rituais, nunca o mapa astral** | médio |
| Validar 3 páginas piloto no Search Console antes de gerar as 390 — e testar o **roteamento**: as rotas estáticas não podem ser engolidas pelo fallback SPA do Flutter | baixo |
| Landing estática em HTML puro na raiz, com o app atrás do botão "entrar". Hoje o visitante frio paga o download inteiro do runtime antes de entender o que é o produto | médio |
| **Link em todo compartilhamento:** domínio no rodapé da arte 1080×1350 + URL curta rastreável no texto, apontando para a página estática do verbete exato — a carta que saiu, não a home | baixo |
| Autoria humana visível na abertura das trilhas: quem escreveu, com que fontes, o que é IA e o que não é | baixo |

**Critério de saída:** buscar o nome do produto retorna o domínio, e o compartilhamento tem endereço

### Onda 4 — Fazer a porta abrir · ~2 a 3 semanas

Login obrigatório, mas sem obstáculo desnecessário

| Item | Esforço |
|---|---|
| **Tirar o Turnstile do caminho crítico.** Ele barra as DUAS portas: `login_page.dart:569-573` mostra que e-mail e senha também passam pelo `CaptchaGate`. Conferir antes se está exigido no painel do Supabase e se `grimoriodebolso.app` está no Hostname Management do Turnstile | baixo |
| **Login por OTP de 6 dígitos** (`signInWithOtp` + `verifyOTP`) como caminho que não pode quebrar: um POST e um input, sem popup, sem sair da origem — funciona igual em aba, em standalone e dentro do Instagram. Exige SMTP próprio | médio |
| **SMTP próprio** com `grimoriodebolso.app` (SPF, DKIM, DMARC). Serve a quatro coisas de uma vez e é pré-requisito de OTP e de qualquer login com Apple | médio |
| Reduzir o cadastro a duas opções e um campo: "Continuar com Google" e e-mail com código de 6 dígitos. Eliminar senha, confirmar senha e o checkbox | médio |
| **Termos com aceite implícito** (texto sob o botão, com log de versão e timestamp) **mas caixa própria e destacada para dado sensível** — convicção religiosa é dado sensível pelo art. 5º II da LGPD, e o art. 11 exige consentimento específico | médio |
| Onboarding de personalização **antes** da parede de conta, **no Android**: "o que te trouxe até aqui" com as 9 trilhas como chips + a carta do dia entregue ali. Na web esse papel cabe à página de conteúdo — seis telas sobre um canvas em branco competem com o tempo de carregamento | médio |
| Trocar o `pushNamedAndRemoveUntil('/home')` pós-cadastro por uma tela de chegada com UMA ação | médio |
| Detectar navegador embutido (Instagram/TikTok) e priorizar OTP ali | médio |
| Não pedir permissão de notificação durante o onboarding; adiar para depois da primeira lição ou do segundo dia | baixo |
| Persistência no servidor **grátis** para conta gratuita — sincronização multi-dispositivo pode continuar Premium; guardar o que a pessoa escreveu, não | médio |
| Free consegue fechar o dia (hoje 2 de cada 6 ritos são Premium) e os 6 atalhos param de apontar para o muro | baixo |

**Critério de saída:** a taxa de conclusão do cadastro medida na Onda 2 subiu

### Onda 5 — Fechar a venda e chamar de volta · ~4 semanas

| Item | Esforço |
|---|---|
| **Infra de e-mail antes do conteúdo:** subdomínio dedicado de marketing separado do transacional, SPF/DKIM/DMARC nos dois. Com login obrigatório, e-mail em spam tranca a pessoa **fora** do app | médio |
| Motor de e-mail de ciclo de vida: D0 boas-vindas, D3/D7/D14 win-back com o gancho concreto da pessoa, carta de lua nova e cheia. `daily_checkins` já está no Supabase | médio |
| **Oferta do anual pelo checkout web enviada por e-mail à base Android** — o único caminho legal de capturar os ~11 pontos | baixo |
| Trial de 7 dias no anual, com paywall na primeira sessão logo **depois** do primeiro momento de valor | médio |
| Paywall contextual por origem; benefícios reescritos para 88 lições e 46 rituais | médio |
| Destravar a degustação da lição (2 pontos de edição: `trail_page.dart:59` e `lesson_page.dart:86`) | baixo |
| Notificação viva: pool de 20-30 corpos por estado, **com texto discreto por padrão** | médio |
| Sequência: aviso de risco, "véu de proteção" mensal automático, `bestStreak` exibido | médio |
| Ler `billingIssueDetectedAt`; banner antes de qualquer downgrade | médio |
| Reduzir intersticiais de 10/dia para 2-3 com cooldown de 15 min, e bloqueio total durante ritual, tiragem e resposta do Conselheiro | baixo |
| Blindar o Conselheiro: recusa de saúde/jurídico/financeiro, protocolo de crise com CVV 188, **botão de denúncia em toda saída de IA** — a política de conteúdo gerado por IA da Play **exige** canal de denúncia in-app | médio |

**Critério de saída:** o funil de compra existe por origem, e o e-mail é um canal medido

---

## O que não fazer

| Tentação | Por que não |
|---|---|
| **Web Push no iPhone** | Pior retorno da pesquisa inteira. Funil multiplicativo sobre ~18% dos aparelhos, exige backend que não existe. O canal é e-mail |
| **Publicar as 88 lições** | É entregar a assinatura. São ~1.000 palavras autorais por lição e ninguém busca "a Rede wiccana" em volume — busca "significado da carta A Torre" |
| **Empurrar a usuária Android para o checkout web** | Risco de política, não ganho de margem: billing alternativo não existe no Brasil até set/2027. Uma suspensão derruba o único canal nativo |
| **WhatsApp como canal de retorno** | Parte relevante desse público pratica em segredo, dentro de casa evangélica ou católica. Prévia na tela bloqueada expõe a pessoa. Denúncias de intolerância religiosa subiram 66,8% em 2024. **Discrição é feature neste nicho** |
| **Temporadas com contagem regressiva, FOMO e selo que se perde** | É o caminho mais rápido para virar o que o app diz não ser. Perecibilidade sim, urgência não: a lua cheia acontece e passa — isso é fato do mundo, não pressão de produto |
| **Testar paywall duro agora** | O número vem de apps que não exigem cadastro antes. Login obrigatório + paywall duro é pedir duas coisas antes de dar uma |
| **Precificar en/es** | Otimizar preço para mercados com distribuição zero. Congelar até haver tráfego real |
| **Adicionar o 23º módulo** | 22 módulos e 148k linhas para uma pessoa. Depois da leitura da base: quais 5 concentram 80% das sessões, e o que se congela |
| **Refatorar a arquitetura** | 2.616 usos de `context.gc.*` contra 3 resíduos. Não é aqui que está o gargalo |

---

## Métricas que deveriam existir

| Métrica | Como | Referência |
|---|---|---|
| Contas, ativas, pagantes, coorte | **SQL hoje**, na base que já existe | — |
| Web vs Android | `signup_platform`, já migrado | — |
| Conclusão do cadastro | `welcome_visto` → `criou_conta`, por método | — |
| Login funcionando em iOS standalone | Teste manual + crash reporting | binário |
| Funil de paywall por origem | Hooks que **já estão escritos** | — |
| Trial-to-paid D35 | RevenueCat | 10,7% em paywall duro |
| D1 / D7 / D30 | Coorte de instalação | D30 de 8-12% é bom |
| Custo de IA por usuária ativa | Tabela `ai_usage` no proxy da Onda 1 | Free na web tem **zero** receita de anúncio |
| Instalações da PWA e modo de exibição | `display-mode: standalone` | mede a aposta |
| Abertura e clique de e-mail | ESP | é o canal de retorno |

---

## Impacto em quem já usa o app

A base é de **116 contas: 96 gratuitas, 20 com código beta vitalício e 4 pagantes da Play.** Cinco das doze decisões tocam essas pessoas. Duas podem causar dano se implementadas de forma ingênua

### 🔴 Decisão 2 — pode rebaixar os 20 códigos beta

Hoje as 20 contas de código beta têm `role='premium', plan='lifetime'` em `profiles`. **O RevenueCat nunca ouviu falar delas.** Um webhook que simplesmente grave "o que o RevenueCat disser" marca as 20 como gratuitas — 20 pessoas perdem um acesso vitalício que foi dado a elas

E o espelho disso: os 4 pagantes hoje são `role='free'` no banco. Se o app passar a confiar no servidor **antes** de existir o backfill, eles perdem o Premium até o webhook disparar

**Como evitar, e isso é requisito de projeto, não detalhe:**

1. O entitlement precisa ter **origem** — uma tabela `entitlements(user_id, source, entitlement_id, granted_at, expires_at, external_ref)` com `source` em `beta | play | web`
2. O webhook só escreve linhas cuja origem é a loja. **Nunca toca em `source='beta'`**
3. Rodar o **backfill primeiro** (importar o estado atual dos 4 assinantes do RevenueCat), e só depois virar a chave que faz o app ler do servidor
4. O `isPremiumEffective` continua sendo um OR — servidor **ou** RevenueCat em runtime — para que uma falha do webhook não derrube ninguém

### 🔴 Decisão 1 — o bug de ressurreição escala de 15 para 116 pessoas

Confirmei: **não existe tombstone em lugar nenhum** (`deleted_at`, soft delete ou equivalente: zero ocorrências em `data_sync_service.dart`, `database_helper.dart` e nos SQL do Supabase)

A etapa 4 do `_syncEntity` reinsere localmente qualquer linha remota que não tenha correspondente local. Ou seja: **apagar um sonho no aparelho o traz de volta no próximo sync**, porque a linha continua no servidor e o app a lê como "dado que falta aqui"

Isso **já acontece hoje** para as 15 pessoas que sincronizam. Abrir a sincronização leva o mesmo defeito para 116

**Portanto: o tombstone entra no MESMO PR da sincronização livre, não depois.** `deleted_at` local e remoto, delete virando soft delete com `synced = 0`, a etapa 3 propagando a lápide e a etapa 4 ignorando remotos com `deleted_at` preenchido

Dois cuidados menores no mesmo PR:

- **A primeira sincronização das 96 contas sobe meses de dado de uma vez.** O volume é pequeno em absoluto, mas é lento no aparelho da pessoa — precisa de progresso visível, não de tela travada
- **Respeitar quem desligou de propósito.** O `resolveCloudSyncPreference` já distingue "desligado automaticamente porque era Free" de "desligado pela pessoa" (`cloudSyncUserConfiguredKey`). Ao remover o `isPremium`, essa distinção tem que sobreviver

✅ **Boa notícia: o RLS não precisa mudar.** Conferi as políticas de `dreams`, `spells`, `daily_checkins`, `gratitudes` e `free_writings` — todas as 20 são baseadas só em `user_id`, nenhuma depende de `role` ou de premium

### 🟡 Decisão 6 — as 116 pessoas nunca consentiram com analytics

O toggle `privacy_analytics` existe na tela e **não controla nada**. Introduzir um processador terceiro sem honrar esse toggle é pior do que não ter o toggle

Mínimo: respeitar a preferência desde o primeiro deploy, atualizar a política de privacidade antes de enviar o primeiro evento, e não mandar nada identificável — o público deste app escreve sobre crença e sofrimento nos diários

### 🟡 Decisão 9 — o consentimento de dado sensível não existe para quem já entrou

As 116 contas foram criadas sob o checkbox de termos atual. A caixa destacada de dado sensível (art. 11) não foi apresentada a nenhuma delas, e o aceite antigo não tem versão nem timestamp gravados

Duas saídas: pedir uma vez na próxima abertura, ou tratar a base existente sob os termos anteriores. **Pedir uma vez é mais limpo** e custa uma tela

### 🟡 Decisão 10 — trocar o remetente de e-mail afeta a base inteira

Sair do SMTP embutido significa que os e-mails passam a vir de um domínio sem reputação nenhuma. Redefinição de senha pode cair em spam durante o aquecimento — e, com login obrigatório, e-mail em spam tranca a pessoa **fora** do app

Publicar SPF, DKIM e DMARC **antes** do primeiro envio, e aquecer gradualmente

### ⚪ Sem impacto em quem já usa

| Decisão | Por quê |
|---|---|
| 3 · Carência no fim de plano | Só é mais generoso do que hoje |
| 4 e 5 · Cartas, runas e páginas estáticas | Acontecem fora do app |
| 7 · Trial de 7 dias | Vale só para compras novas. Os 4 pagantes mantêm o preço e não seriam elegíveis de qualquer forma |
| 8 · Anúncio contido | Só melhora para as 96 gratuitas |
| 11 e 12 · Motor de cobrança e preço | Nada muda |

### Três achados de segurança que apareceram na conferência

Não vieram das decisões, mas o linter do Supabase apontou e vale entrar no plano:

- **`redeem_beta_code` é `SECURITY DEFINER` e executável pelo papel `anon`**, via `/rest/v1/rpc/redeem_beta_code`. A chave anônima vive dentro do bundle do app por natureza. Vale revogar o `EXECUTE` do `anon`, exigir sessão e pôr limite de tentativas — códigos beta concedem vitalício
- **`handle_new_user()` também é executável por `anon`** como `SECURITY DEFINER`
- **Proteção contra senha vazada está desligada** no Supabase Auth (checagem contra HaveIBeenPwned). É um toggle no painel
- Cinco funções sem `search_path` fixo (`reset_daily_counters`, `create_user_policy`, `handle_new_user`, `reset_monthly_counters`, `redeem_beta_code`)

---

## O que ainda depende de você

Depois das 12 decisões e da leitura da base, restou **muito pouco**

### Já resolvido

| Era bloqueio | Estado |
|---|---|
| Ler a base (contas, plataforma, planos, coortes) | ✅ consultado nesta sessão |
| Existe assinante pagante na Play? | ✅ **4 — 2 anuais, 2 mensais** |
| Todas as decisões de produto e monetização | ✅ as 12 estão fechadas acima |

### Ainda depende de você — acesso a painel

Nenhuma exige decisão: são coisas que só você consegue abrir ou comprar

| O que | Onde | Bloqueia |
|---|---|---|
| **Webhook do RevenueCat** | Painel do RevenueCat → Integrations | A decisão 2. Preciso da URL da Edge Function cadastrada lá e do segredo de autenticação |
| **Chave do PostHog** | Criar o projeto | A decisão 6 |
| **SMTP próprio + DNS** | Supabase → SMTP Settings, e SPF/DKIM/DMARC no DNS | A decisão 10, e o e-mail de win-back inteiro |
| **O Turnstile é exigido no servidor?** | Supabase → Auth → Attack Protection | Mexer no captcha. Se estiver ligado lá, remover o gate no cliente **quebra** o login |
| **Oferta base de 7 dias** | Google Play Console → produto `grimorio_pro_yearly` | A decisão 7. O código lê `introductoryPrice`, mas a oferta nasce no Console |
| **Teto de anúncio** | AdMob | A decisão 8 (parte é código, parte é painel) |
| **Aval para migração em produção** | — | Tabelas novas (`login_attempts`, `entitlements`) e a coluna de estado de assinatura rodam no Postgres de produção |

### Ainda não sabido — e não bloqueia

- **O Pix aparece no checkout de assinatura da Play?** 20 minutos com uma conta BR. Se sim, "mais formas de pagamento" vira mudança de copy e a decisão 11 fica ainda mais confortável
- **Alguém de iPhone já abriu o app web?** Não há como saber hoje (zero contas web, sem analytics). O PostHog da decisão 6 responde isso em dias
- **A busca do Google indexa as páginas estáticas?** Só o piloto de 3 páginas responde

### O que eu implemento sem mais nada

Sem credencial nova, sem decisão pendente:

**As decisões que são só código** — sincronização livre (1) · fim de plano com carência (3, a parte do cliente) · anúncios (8, a parte do código) · cadastro simplificado com caixa de dado sensível (9)

**Correções de dano** — Escrita Livre com `AutomaticKeepAliveClientMixin` + autosave · `UnsavedChangesGuard` nos 8 formulários sem `PopScope` · contraste do tema claro com teste bloqueante iterando `AppThemes.all`

**Higiene de PWA** — `scope`, `id`, `lang`, `screenshots`, `start_url: "/"` no manifest · `apple-mobile-web-app-capable` e `apple-touch-startup-image` no `index.html`

**Justiça no Free** — rito do dia filtrado por plano (hoje 2 de cada 6 dias são impossíveis de fechar) · carência de anúncio na primeira sessão · atalhos padrão que a pessoa consegue terminar · o balão do Salem deixando de apontar sempre para o mesmo paywall

**Coisas que existem e não aparecem** — exibir `bestStreak` · XP ao vivo no anel · busca nos 5 Diários · busca de feitiços insensível a acento · reordenar os cards do Seu Dia · destravar a degustação da lição (`trail_page.dart:59` e `lesson_page.dart:86`)

**Limpeza** — remover os product ids iOS mortos de `revenuecat_config.dart` e o `signInWithFacebook()` que só retorna erro

**Gerador estático** — as ~330 páginas da decisão 5, a partir dos mesmos `*_data_{pt,en,es}.dart` que alimentam o app, com o piloto de 3 páginas primeiro

### A sequência que eu proporia ao chat de implementação

1. **PR 1 — o que não depende de nada:** correções de dano, higiene de PWA, justiça no Free, coisas invisíveis, limpeza
2. **PR 2 — sincronização livre + persistência de assinatura:** decisões 1, 2 e 3 juntas, porque a segunda depende da primeira estar aberta. Precisa do webhook e do aval de migração
3. **PR 3 — instrumentação:** PostHog + tabelas próprias + `login_attempts` + healthcheck de login. Precisa da chave
4. **PR 4 — descoberta:** gerador estático, piloto de 3 páginas, landing na raiz, link no compartilhamento
5. **PR 5 — conversão:** trial de 7 dias, paywall contextual, benefícios reescritos, cadastro simplificado. Precisa da oferta base no Console

O PR 1 pode começar hoje. O 2 e o 3 destravam com dois acessos de painel. O 4 é a onda que mais importa para o gargalo real


## Resposta curta

O que falta não é conteúdo nem capricho. E agora que a base foi lida, a ordem encurtou: com **116 contas, nenhuma vinda do web e nenhum assinante pagante visível no servidor**, o gargalo é **aquisição** — e tudo que é otimização de conversão pode esperar

Falta, nesta ordem: **ser achável**, **fazer a porta abrir**, **enxergar as 96 contas gratuitas que hoje são invisíveis**, e só então **cobrar pela coisa certa**

As duas decisões de produto não atrapalham nenhuma delas. A do login obrigatório entrega o e-mail de 100% da base, que é o canal de retorno mais valioso que este app pode ter. A de não fazer iOS obriga o site a virar produto — e é exatamente ali que mora o modo convidado que o app não vai ter

O caminho mais curto entre hoje e "app profissional" continua passando por ligar o que já está construído e desligado
