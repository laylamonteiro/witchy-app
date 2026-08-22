# Auditoria de produto — agosto de 2026

Diagnóstico do Grimório de Bolso contra a régua de app profissional da categoria, cobrindo público-alvo, design, UX/UI, retenção e conversão para Premium

**Base:** versão 2.0.25+126 · 503 arquivos Dart · ~148k linhas · 22 módulos · Android em produção
**Método:** 8 auditorias independentes de código (798 leituras de arquivo), verificação factual das alegações de maior consequência, e calibração contra benchmarks públicos da categoria

---

## A tese

O app não perde para os concorrentes profissionais em conteúdo, em arquitetura nem em capricho — perde em três coisas que não estão dentro dele: **ele não se mede, não fala com quem sumiu, e não deixa a pessoa entrar**

Isso é uma boa notícia disfarçada de má. O caro já foi feito: 88 lições em 9 trilhas, 46 rituais guiados, 78 cartas, 24 runas, 15 seções de enciclopédia, tudo em três idiomas com paridade travada por CI. O que falta é a camada de negócio em volta — e ela custa semanas, não anos

O padrão que se repete nas oito auditorias é o mesmo: **quase tudo que falta já está meio construído no repositório e desligado**

| O que existe pronto | O que falta para valer |
|---|---|
| `OfferEngine` grava exposição, clique, dispensa e conversão por oferta | Os contadores morrem no `SharedPreferences` — `eventCount` não tem um único chamador |
| `BlockedAccessEvent.toAnalyticsParameters()` monta o evento de bloqueio com feature, motivo, limite e janela | `setBlockedAccessAnalyticsHook` nunca é chamado de lugar nenhum |
| `claimLegacyData` migra 19 tabelas de `local_user` para a conta real, com teste | Não existe botão para entrar como convidada |
| Degustação da lição, escrita, localizada em 3 idiomas e instrumentada (`OfferSlot.lessonTeaser`) | Interceptada antes de renderizar — nenhuma usuária jamais viu |
| `bestStreak` é calculado e exposto no provider | Nunca é exibido em nenhuma tela |
| `JourneyProgress` existe como modelo | Não é persistido; as 7 jornadas não dão XP nem badge |
| Chave iOS do RevenueCat e product ids iOS já cadastrados | Não há Podfile, nem time de assinatura, nem job de build |

---

## Notas por dimensão

| Dimensão | Nota | Veredito |
|---|---|---|
| Conteúdo editorial e IA | 6/10 | O maior ativo do produto, e o mais subvendido |
| Design e identidade visual | 6/10 | Identidade forte, sistema incompleto — só cor virou token |
| UX e arquitetura da informação | 5/10 | Navegação bem resolvida, mas o vocabulário colide e há perda de dado |
| Monetização e conversão | 5/10 | Encanamento sólido, estratégia de venda ausente |
| Ativação | 4/10 | Muro de cadastro antes de qualquer valor |
| Retenção | 4/10 | Sequência bem feita, sem nada que a proteja ou que traga de volta |
| Infraestrutura de produto | 4/10 | CI/CD acima da média, observabilidade zero |
| Plataforma e distribuição | 4/10 | Esteira de release profissional para um canal só |

---

## Os seis gargalos, em ordem

Um gargalo bloqueia tudo que vem depois dele. Esta ordem não é de gravidade — é de dependência

### 1. O produto é cego

Não existe nenhum SDK de analytics, crash reporting ou remote config no `pubspec.yaml`. Não há `firebase_analytics`, `posthog_flutter`, `sentry_flutter`, `firebase_crashlytics` nem equivalente

Consequências concretas:

- Não se sabe D1, D7 nem D30. Não se sabe quantas pessoas abandonam na tela de boas-vindas, quantas terminam o cadastro, quantas voltam no dia 2
- Não se sabe qual feature bate no muro, quantas pessoas veem o paywall por dia, qual origem converte
- Os handlers globais de erro (`main.dart:61-96`) capturam tudo e gravam **só localmente**. Como `runZonedGuarded` impede o processo de morrer, nem o Play Console Vitals enxerga: uma exceção que deixa o mapa astral em branco para todas as usuárias de um país nunca aparece em lugar nenhum
- 285 blocos `catch` no `lib/`, 23 terminando em `debugPrint` e 10 vazios

A prova de que isso já custou caro: o onboarding inteiro (474 linhas, 5 slides, 13 chaves de texto) foi removido no commit `d4fa073` em 21/08/2026 **sem um único número** que dissesse se ele ajudava ou atrapalhava

Enquanto o app for cego, toda correção desta lista é aplicada às cegas e ninguém saberá se funcionou

### 2. Ninguém entra sem pagar o pedágio

`welcome_page.dart` tem exatamente dois botões: "Criar conta" e "Já tenho conta". Não existe terceira porta

A pessoa baixou um app de bruxaria por curiosidade e a primeira tela pede e-mail, senha, confirmação de senha, aceite de termos e um captcha Turnstile em WebView — cujo próprio comentário no código admite falhar no primeiro carregamento em app recém-instalado. Tudo isso para ver uma fase da lua que qualquer site mostra de graça

O app se declara local-first e tem uma porta 100% online: sem rede ou sem Supabase configurado, o login lança "sistema não configurado". O `LocalAuthRepository` implementa o contrato inteiro e **nunca é instanciado**

Detalhe correlato: o botão do Google no login não exige aceite de termos, enquanto o cadastro exige — a mesma conta nasce com ou sem aceite dependendo de por onde entrou

### 3. As chaves de IA estão publicadas

`.github/actions/credenciais-app` escreve `groq_credentials.dart` e `gemini_credentials.dart` com os secrets, e o `release.yml:503` usa essa action **dentro do job `build-web`**. Como o Dart compila para JavaScript, a chave da Groq e a do Gemini viram literais dentro do `main.dart.js` servido publicamente em `grimoriodebolso.app`

Qualquer pessoa abre o DevTools, busca por `gsk_` ou `x-goog-api-key`, e leva as duas chaves em menos de um minuto. No Android o custo é maior (unzip do AAB + `strings` no snapshot AOT), o resultado é o mesmo. Não existe `supabase/functions/` — não há proxy

Somado a isso: todos os limites de uso vivem no aparelho e são contornáveis (mudar o fuso ou reinstalar zera os contadores), e as credenciais de admin entram por `--dart-define`, que também vira literal no binário e concede premium vitalício local a quem extrair a string

O workflow já tem uma guarda contra `ADMIN_*` vazar no `main.dart.js` (`branch-validate.yml:381-389`). A mesma preocupação não foi aplicada às chaves que custam dinheiro

### 4. A venda é feita no escuro, uma vez só, com a lista errada

Três falhas somadas:

**Não existe trial.** Nenhuma leitura de `introductoryPrice`, `PeriodType.trial` ou `subscriptionOptions` nas 961 linhas do `payment_service.dart`. O app pede R$ 119,90/ano de alguém que nunca usou o produto pago. Todo o esforço de degustação (teasers, blur, títulos sob véu) existe para simular o que um trial entregaria de graça e melhor

**Um paywall genérico atende ~20 contextos.** `showPremiumUpgradePaywall(BuildContext context)` não recebe origem, e 16 call sites constroem `const PremiumUpgradeSheet()` direto. Quem acabou de desenhar um sigilo e quer salvá-lo recebe a mesma tela de quem esgotou a tiragem de tarot e a mesma de quem tentou abrir a lição 2 de uma trilha. A headline nunca responde a pergunta que a pessoa tem na cabeça naquele segundo

**A lista de benefícios esconde os dois maiores ativos.** Os 5 bullets vendem "leituras ilimitadas" e "enciclopédia completa" — as duas coisas mais fáceis de imitar — e não citam as 88 lições nem os 46 rituais guiados, que são o que ninguém copia em um mês. Pior: "Enciclopédia com conteúdos completos" é impreciso, porque o Free já lê quase tudo; a promessa não se cumpre no valor esperado

### 5. Não há canal de volta

Toda notificação é local, agendada no aparelho, no último dia em que a pessoa abriu o app. Não há `firebase_messaging`. Não há edge function. Logo: **não existe win-back** — não dá para falar com quem sumiu há sete dias

E o lembrete diário é uma única frase estática, agendada com `matchDateTimeComponents: DateTimeComponents.time`: quem fica seis meses no app recebe "🐈‍⬛ O Salem te chama" **180 vezes**. A única alavanca de retorno que existe se autodestrói por repetição

A sequência — que é bem construída, com dia em horário local, tolerância de um dia e reconstrução a partir de 11 tabelas de evidência — não tem aviso de risco, não tem congelamento e não tem luto. A pessoa passa 30 dias construindo um número, esquece um dia, e no dia seguinte o selo mostra "1 dia seguido" sem nenhuma explicação. Enquanto isso, a mesma sequência ≥7 é usada para **vender** a Leitura do Ciclo

### 6. iOS não existe como produto

Não há `ios/Podfile` nem `Podfile.lock` (e o Podfile não está no `.gitignore`). O `project.pbxproj` não tem uma linha de `DEVELOPMENT_TEAM` nem `PROVISIONING_PROFILE`, e usa a identidade legada `"iPhone Developer"`. Não há job de iOS em nenhum workflow. O bundle id iOS (`com.grimoriodebolso.grimorioDeBolso`) diverge do Android (`com.grimoriodebolso.app`)

E há um bloqueio garantido esperando: `signInWithApple()` retorna erro com o comentário "Apple Sign-In não está habilitado neste app", e o pacote `sign_in_with_apple` não está no `pubspec.yaml`. Com o botão do Google presente e o Apple ausente, a Guideline 4.8 rejeita a submissão na primeira revisão

---

## Calibração de mercado

Os números abaixo são benchmarks públicos, não fatos do código:

- A App Store concentrou cerca de **70,5% do gasto do consumidor** entre as duas lojas em 2025, a partir de ~21% dos downloads; **73% da receita de assinatura** veio do iOS. ARPU iOS ~US$ 138 contra ~US$ 72 no Android ([Sensor Tower](https://sensortower.com/blog/2025-state-of-mobile-consumers-usd150-billion-spent-on-mobile-highlights), [Business of Apps](https://www.businessofapps.com/data/app-revenues/))
- **Paywall duro converte ~5x mais que freemium**: mediana de 10,7% contra 2,1% de trial-to-paid em D35. Trials longos (17–32 dias) convertem ~42,5% contra ~25,5% dos trials de menos de 4 dias. **82% dos trials começam no primeiro dia após a instalação** — o que torna a ativação e o trial a mesma conversa ([RevenueCat, State of Subscription Apps](https://www.revenuecat.com/state-of-subscription-apps))
- Na categoria: CHANI é o app de astrologia de maior faturamento nos EUA, a US$ 12/mês ou US$ 108/ano; The Pattern cobra US$ 14,99/mês; Co-Star construiu a retenção em push diário agressivo na tela de bloqueio ([Statista](https://www.statista.com/statistics/1451664/top-horoscope-apps-us-market-revenue/), [Unstar](https://unstar.app/blog/co-star-sanctuary-pattern-nebula-stellium-astrology-apps-ranked-2026))

Três leituras disso para este produto:

1. O preço de reserva no código é **R$ 19,90/mês e R$ 119,90/ano** (`premium_blur_widget.dart:445-449`) — o README ainda anuncia R$ 9,90 e R$ 79,90, e está desatualizado. Mesmo assim o valor está **abaixo** do padrão internacional da categoria. Isso é defensável no Brasil e é dinheiro deixado na mesa em en/es — e o conteúdo já está traduzido
2. O concorrente de referência vence com **uma coisa perecível todo dia, entregue por push**. É exatamente a mecânica que aqui está desligada
3. Como 82% dos trials nascem no dia da instalação, **abrir a porta (gargalo 2) e criar o trial (gargalo 4) são a mesma tarefa**, não duas

---

## O que já está bom, e não deve ser mexido

Vale dizer com clareza, porque a lista de buracos acima não é o retrato inteiro:

- **Paridade trilíngue travada por CI.** `content_parity_test.dart`, `trails_parity_test.dart`, `ai_prompts_parity_test.dart`, `guided_rituals_parity_test.dart` e o scanner de português hardcoded rodam bloqueantes. Quase nenhum app indie faz isso
- **Esteira de release acima da média.** Guarda de semver, versionCode determinístico conferido contra todas as tags, gate no SHA da tag, conferência de assinatura, consulta prévia à API da Play para validar a faixa, aprovação humana no environment `production`, trava simétrica sandbox × produção da chave do RevenueCat
- **Fonte única de verdade de acesso.** `AppFeature` + `FeatureAccess` + `PremiumAccess` evitam a bagunça de checagens espalhadas que mata apps deste tamanho. Os gates são fail-closed de verdade: o conteúdo pago não chega à árvore de widgets atrás do blur
- **Ética de cobrança correta na Leitura do Ciclo.** Crédito gravado antes da geração, falha de IA não consome a compra, aviso de "poucos registros" antes de pagar, opt-out por fonte de dado
- **Motor de ofertas com guardrails reais.** Uma oferta por dia no app inteiro, cooldown de 7 dias, silêncio de 30 dias após duas dispensas
- **Movimento reduzido do sistema respeitado em 16 pontos.** Raríssimo na categoria
- **Arte própria de verdade:** 194 ilustrações, mascote animado com sprites, baralho RWS completo, ícone adaptativo e splash Android 12+ customizados
- **`LanguageGuard`** — solução original e testada para um defeito real de produção, detectando quando a IA escapa do idioma
- **`sync_coverage_test.dart`** — teste institucional exemplar: trava a classe de bug "tabela nova ficou de fora do sync" em vez de testar um caso pontual

Nada disso precisa ser refeito. A recomendação é usar essa base, não substituí-la

---

## Roadmap por ondas

Estimativas para **uma pessoa** desenvolvendo. Cada onda só faz sentido depois da anterior

### Onda 0 — Parar o sangramento · ~1 semana

Coisas que já estão causando dano hoje e não dependem de nenhuma decisão de produto

| Item | O que fazer | Esforço |
|---|---|---|
| Rotacionar as chaves de IA | Considerar as atuais comprometidas. Hoje | baixo |
| Proxy de IA | Edge Function `ai-proxy` no Supabase autenticada por JWT, chaves como secrets, teto por `user_id` numa tabela `ai_usage`. Trocar as 4 chamadas diretas de `ai_service.dart` (linhas 854, 890, 1062, 1116) e apagar os arquivos de credencial do build | médio |
| Escrita Livre perde texto | `AutomaticKeepAliveClientMixin` em `_FreeWritingTabState` + `_save()` no `dispose()` + autosave por timer. Hoje trocar de sub-aba nos Diários apaga o que foi escrito, sem aviso — numa aba vendida como "salvamento automático" | baixo |
| Guarda de trabalho não salvo | `UnsavedChangesGuard` compartilhado aplicado a 8 formulários sem `PopScope` (sonho, desejo, gratidão, afirmação, feitiço, registro, verbete, mapa astral). O gesto de voltar do Android é acidental o tempo todo | baixo |
| Contraste do tema claro | `lavandaNevoa` reprova AA em quase toda a paleta de acento: `starYellow` sobre `surface` dá 2,25:1 e tem 145 usos (XP, conquistas, runas, jornadas). Refazer a partir de um fundo quase branco + `test/theme_contrast_test.dart` bloqueante iterando `AppThemes.all` | médio |
| Rollout gradual | `status: inProgress` + `userFraction: 0.2` no `release.yml` para produção, com workflow de promoção. Hoje uma versão quebrada quebra para 100% da base de uma vez | baixo |

**Critério de saída:** nenhuma chave de API sai no bundle, nenhum formulário perde dado, o tema claro passa no teste de contraste

### Onda 1 — Abrir os olhos · ~2 semanas

Sem esta onda, todas as outras são apostas

| Item | O que fazer | Esforço |
|---|---|---|
| Analytics | PostHog ou Firebase Analytics. Dicionário de no máximo 25 eventos definido **antes** de começar. Respeitar o toggle `privacy_analytics`, que hoje existe na tela e não controla nada | médio |
| Ligar os hooks órfãos | `FeatureAccessService.instance.setBlockedAccessAnalyticsHook(...)` no boot; `OfferEngine._bumpEvent` emitindo evento remoto; `PaymentService` emitindo `purchase_started/completed/cancelled`. **Isso dá o funil completo em menos de um dia** — a instrumentação já está escrita | baixo |
| Crash reporting | `sentry_flutter` plugado nos 4 pontos que já capturam tudo (`main.dart:61`, `:74`, `:82`, e o `debugLog('ERROR')`), com versão, locale, plano e as últimas 30 linhas do `DebugLogService` como breadcrumb | baixo |
| Remote config pobre | Tabela `app_config` no Supabase (chave, valor jsonb, min_version) lida no boot com cache e fallback nas constantes. Move os limites Free para fora do binário e habilita A/B sem release | médio |
| Métrica de ativação declarada | Proposta: *entregou 1 leitura E completou 1 rito nas primeiras 48h* | baixo |

**Critério de saída:** dá para responder, olhando um painel, qual é o D7 e quantas pessoas veem o paywall por dia

### Onda 2 — Abrir a porta · ~2 a 3 semanas

| Item | O que fazer | Esforço |
|---|---|---|
| Modo convidado | Terceiro botão na `welcome_page` gravando `entered_as_guest`, `UserModel.defaultUser()`, ajuste no `RequireAuth`. A conversão depois já está pronta e testada via `claimLegacyData`. **Atenção:** `signOut` apaga o banco quando o usuário é anônimo (`auth_provider.dart:851-861`) — precisa distinguir "sair da conta" de "convidada que nunca teve conta" | médio |
| Primeiro contato em 3 telas | (1) "que caminho te chama?" com as 9 trilhas como chips; (2) **a carta do dia do tarot já sorteada e revelada ali mesmo** — o código existe, é grátis e é isento de anúncio; (3) "quer guardar isso no seu grimório?" → cadastro. Entrega em vez de prometer | médio |
| Priming de notificação | Parar de pedir a permissão a frio em cima do tour. Pedir no último passo do tour, com o Salem falando. No Android 13+ duas negações fecham a porta para sempre | baixo |
| Free consegue fechar o dia | Hoje em 2 de cada 6 dias o rito exploratório cai numa feature Premium e o 3/3 fica matematicamente inalcançável. Filtrar `DailyRites.featuredToday()` pelo plano | baixo |
| Atalhos e mascote pararem de apontar para o muro | Os 6 atalhos padrão priorizam Premium por decisão explícita; as 8 falas diárias do Salem apontam **todas** para o Clima Mágico, que nunca preenche no Free. Diversificar por estado e por dia | baixo |
| Carência de anúncio na 1ª sessão | Nada de intersticial nas primeiras 48h ou nos 3 primeiros resultados | baixo |

**Critério de saída:** dá para instalar, tirar uma carta e completar um rito sem criar conta

### Onda 3 — Fechar a venda · ~3 a 4 semanas

| Item | O que fazer | Esforço |
|---|---|---|
| Trial de 7 dias no anual | Oferta base no Google Play, ligada ao offering `default` do RevenueCat, lida via `storeProduct.introductoryPrice` para trocar o rótulo e o botão. Somado à Onda 2, ataca os 82% de trials que nascem no dia da instalação | médio |
| Paywall contextual | `PremiumUpgradeSheet({this.origin})` com enum de origem. Trocar só duas coisas: a headline e a ordem dos benefícios. Substituir os 16 `showModalBottomSheet` diretos | médio |
| Benefícios certos | Reescrever os 5 bullets para: 88 lições em 9 trilhas · 46 rituais guiados · seus sonhos interpretados · Conselheiro e leituras sem limite · tudo sincronizado. Unificar com a lista de 9 itens da `SubscriptionPage`, que hoje promete coisas diferentes — inclusive "Suporte prioritário", sem contrapartida no código | baixo |
| Destravar a degustação da lição | Remover a interceptação em `trail_page.dart:76-84` e `continue_trail_card.dart:82-90`. Está pronta, localizada e instrumentada, e nunca foi vista | baixo |
| Degustação dos rituais | 2 dos 46 gratuitos permanentes + página de degustação (nome, materiais, duração, passo 1 completo) no lugar do `showPaywallThenPop`. Hoje a home conta os dias até o sabbat e cospe a pessoa numa tela de venda | médio |
| Fim de assinatura | Ler `billingIssueDetectedAt` e `willRenew` no `_onCustomerInfoUpdated`; banner com CTA para o Customer Center antes de qualquer downgrade | médio |
| Inverter os guardrails | O muro de limite diário aparece sem teto, todo dia, com snackbar vermelho; a oferta gentil é silenciada por 30 dias. Passar o muro pelo `OfferEngine` com slot próprio | baixo |

**Critério de saída:** o funil exposição → clique → compra existe por origem, e o trial roda

### Onda 4 — Fazer voltar · ~3 a 4 semanas

| Item | O que fazer | Esforço |
|---|---|---|
| Notificação viva | Trocar a frase única por um pool de 20–30 corpos escolhidos por estado no agendamento (que já roda a cada cold start): sequência em risco, rito do dia pelo nome, lua cheia amanhã. Sem servidor nenhum | médio |
| Sequência protegida | Aviso às 20h quando `currentStreak > 2` e não há check-in; uma "vela de proteção" por mês; `bestStreak` exibido — ele já é calculado e nunca aparece | médio |
| XP ao vivo | `refreshPracticeXp()` chamado dentro de `completeRite` e dos repositórios, com o delta animado subindo no anel. Hoje a pessoa ganha 28 XP e o anel não se mexe um pixel | baixo |
| Jornadas com recompensa | Persistir `journey_progress`, somar `step.xpReward` ao XP unificado, disparar celebração e notificação. Hoje completar "Manifestador" entrega zero | alto |
| "Naquele dia" | Card no Seu Dia com o que a pessoa escreveu há 1, 3, 6 e 12 meses. Uma consulta SQL por dia, zero conteúdo novo, e é a mecânica mais forte de app de diário | baixo |
| Win-back por e-mail | `daily_checkins` **já sobe para o Supabase**. Edge function agendada consultando `MAX(date)` por `user_id`, disparando em D3/D7/D14 com o gancho concreto da pessoa ("sua sequência parou em 12 dias"). Não precisa de FCM | médio |
| Busca nos Diários | Nenhuma das 5 listas tem busca, ordenação ou filtro, e as tags de sonho são criadas e nunca usadas. Depois de 3 meses — exatamente a pessoa candidata a Premium — o próprio acervo fica inencontrável | médio |

**Critério de saída:** D7 e D30 medidos na Onda 1 subiram

### Onda 5 — Sair de um canal só · ~4 a 6 semanas

| Item | O que fazer | Esforço |
|---|---|---|
| iOS | Alinhar o bundle id **antes** de criar o app no App Store Connect (depois é irreversível) · `Podfile` commitado · `DEVELOPMENT_TEAM` e assinatura · produtos com os mesmos identificadores da Play · job `macos-latest` no `release.yml` · TestFlight | alto |
| Sign in with Apple | Pré-requisito, não polimento. Mesma tarefa do iOS | médio |
| Link no compartilhamento | Os três `shareText` não têm URL nenhuma — cada compartilhamento é um beco sem saída. Três chaves de ARB e uma página `/baixar` que decide o destino | baixo |
| App Links | `autoVerify="true"` + `assetlinks.json` (o repo já tem `get_release_sha1.sh`). Hoje quem tem o app instalado e clica num link do domínio cai no app web, numa segunda sessão sem seus dados | médio |
| Landing page de verdade | Mover o app Flutter para `/app/` e colocar uma landing estática na raiz com badge da Play. Todo o plano do `reels.md` termina em "link na bio", e o link na bio não oferece o botão da loja | médio |
| Pedido de avaliação | `in_app_review` disparado em pico de alegria comprovada — ao encadernar uma trilha, ao completar 7 dias de sequência. Hoje o único caminho até a avaliação é a irritação | baixo |
| Cartões compartilháveis certos | O app tem 78 cartas com arte, mapa astral desenhado, 24 runas, sigilo à mão — e nenhum deles gera imagem. Só três superfícies compartilham, e nenhuma é o que as pessoas postam | médio |

**Critério de saída:** o app está no TestFlight e todo compartilhamento leva alguém de volta

---

## O que não fazer agora

| Tentação | Por que não |
|---|---|
| Adicionar mais uma ferramenta mística | O app já tem 22 módulos e 98 telas. O problema não é falta de feature, é que metade do que existe não é encontrada, medida nem vendida |
| Migrar todo o conteúdo para um CMS | A entrega remota resolve-se com uma tabela `content_overrides` e fallback no `const` compilado. Migrar 88 lições e 78 cartas para um CMS é meses e não muda nenhuma métrica |
| Passar de 6 para 10 temas | Já não há teste de tema nenhum e um dos 6 reprova contraste. Multiplicar paletas antes de ter a malha de regressão só multiplica o QA |
| Construir comunidade ou feed social | Moderação em app de nicho espiritual é um problema de operação em tempo integral, e o produto ainda não segura a pessoa sozinha |
| Refatorar a arquitetura | Clean Architecture + feature-first está bem executada, com 2.616 usos de `context.gc.*` contra 3 resíduos. Não é aqui que está o gargalo |
| Cortar mais o Free para forçar conversão | Sem o funil da Onda 1, isso é apostar às cegas. E o Free já tem 2 de 6 dias em que não consegue fechar o dia |

---

## Métricas que deveriam existir e não existem

| Métrica | Como instrumentar | Referência da categoria |
|---|---|---|
| D1 / D7 / D30 | Evento de sessão + coorte de instalação | D30 de 8–12% é bom em lifestyle |
| Time-to-value | `install_ts` → primeiro resultado entregue | Abaixo de 3 min |
| Taxa de conclusão do cadastro | `welcome_visto` → `cadastro_concluido` | Cadastro frio perde 40–70% |
| Ativação | 1 leitura + 1 rito nas primeiras 48h | Definir a linha de base antes de otimizar |
| Funil de paywall por origem | `setBlockedAccessAnalyticsHook` + `OfferEngine` (**já escritos**) | — |
| Trial-to-paid D35 | RevenueCat | 10,7% mediana em paywall duro, 2,1% em freemium |
| Sequência: quebra e recuperação | `daily_checkins` (**já sincronizado**) | — |
| Abertura de notificação por tipo | Payload de deep link (**já existe e é testado**) | Queda acentuada após a 1ª semana com copy fixa |
| Custo de IA por usuária ativa | Tabela `ai_usage` na edge function da Onda 0 | Precisa caber na margem de R$ 19,90/mês |
| Churn involuntário | `billingIssueDetectedAt` do RevenueCat | 20–40% do churn total costuma ser involuntário |

---

## Resposta curta

O que falta para competir com apps profissionais não é conteúdo nem capricho — os dois já estão no nível. Falta, em ordem: **enxergar** (analytics e crash), **deixar entrar** (convidado e primeiro valor antes do cadastro), **fechar a conta com a IA** (proxy e teto por usuária), **vender direito** (trial e paywall contextual), **chamar de volta** (notificação viva e win-back) e **sair do Android**

O caminho mais curto entre hoje e "app profissional" passa por ligar o que já está construído e desligado, não por construir mais
