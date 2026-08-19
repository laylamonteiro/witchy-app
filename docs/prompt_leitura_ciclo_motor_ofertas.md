# Prompt de implementação — Leitura do Ciclo & Motor de Ofertas

> **Como usar**: cole este arquivo como prompt inicial de uma sessão de
> implementação (Claude Code) neste repositório. Leia ANTES o brainstorm
> `docs/brainstorm_analise_magica_periodo.md` — a visão de produto vive lá;
> aqui vive a execução. As duas frentes são independentes: implemente a
> Frente B (ofertas) primeiro se quiser resultado rápido — ela é também o
> canal de venda da Frente A.

## Contexto do app (leia e confirme no código)

App Flutter (provider, feature-first em `lib/features/<x>/{data,presentation}`).
Dados: sqflite é a fonte da verdade (`lib/core/database/database_helper.dart`),
espelhado no Supabase via `lib/core/services/data_sync_service.dart`.
Monetização: RevenueCat (`lib/core/services/payment_service.dart`, entitlement
`Grimorio de Bolso Pro` em `lib/core/config/revenuecat_config.dart`); gate por
feature em `lib/features/auth/data/models/feature_access.dart` (`AppFeature`,
`FeatureAccessService`); paywall padrão = `PremiumUpgradeSheet`
(`lib/features/auth/presentation/widgets/premium_blur_widget.dart`).
IA: `lib/core/ai/ai_service.dart` (Groq→Gemini com fallback; prompts por idioma
em `lib/core/ai/prompts/`). Astrologia: `sweph`
(`lib/features/astrology/data/services/chart_calculator.dart`, transit_model).
Compartilhamento como imagem: `lib/core/sharing/` (`ShareCard`,
`showShareCardSheet`). i18n: ARBs pt/pt_BR/en/es + `scripts/check_arb_sync.sh`
(paridade é bloqueante no CI); `flutter analyze --no-fatal-infos` também.

---

## FRENTE A — "Leitura do Ciclo" (compra avulsa)

Análise mágica do período (mês/lunação no MVP) gerada por IA a partir do que a
pessoa registrou, vendida como CONSUMÍVEL no RevenueCat — fora do Premium.

### Fases (cada uma entregável sozinha, nesta ordem)

1. **Agregador** — novo serviço `CycleReadingComposer`: monta um JSON compacto
   do período a partir das tabelas existentes (dreams, gratitudes, desires,
   affirmations favoritas, free_writings/leituras arquivadas, ritual_logs,
   guided_ritual_logs, daily_checkins, daily_magical_weather,
   learning_progress, birth_charts). Anexar fatos do céu calculados NO
   aparelho (trânsitos sobre o mapa natal + fases da lua do período): a IA
   narra, nunca calcula. Respeitar `unknownBirthTime` (sem casas/ascendente).
   Trechos curtos e temas/contagens, não diários inteiros (tokens + intimidade).
2. **Geração** — prompt novo nos 3 idiomas em `lib/core/ai/prompts/`, gerado
   seção a seção (chamadas curtas; um 429 num produto PAGO é inaceitável —
   ver `AiRateLimitException` e considerar chave/rota dedicada). Saída em
   Markdown com as 7 seções do brainstorm (retrato do momento, fios que se
   repetem, o céu sobre você, sua prática, rituais para o próximo ciclo,
   afirmação sob medida, selo do ciclo).
3. **Entrega** — página do relatório (`flutter_markdown`), salvo como
   `free_writings` com `source` próprio (fica no acervo para sempre, sincroniza);
   afirmação e selo do ciclo viram cartões `ShareCard` compartilháveis.
4. **Monetização** — produto consumível `leitura_ciclo_mes` nas lojas; compra
   via `PaymentService` (`Purchases.purchase`); registro da compra + período
   coberto em tabela local nova `cycle_readings` sincronizada. A compra SÓ é
   consumida quando o relatório foi gerado e salvo com sucesso (falha = tentar
   de novo sem nova cobrança). Assinante Pro ganha desconto ou 1 leitura/mês.
5. **Oferta** — ver Frente B (gatilho de regularidade).

### Regras de produto inegociáveis

- Avisar ANTES da compra se o período tem menos de ~5 registros (leitura rasa).
- Tela de compra diz o que é enviado para análise; opção de excluir fontes
  íntimas (ex.: "não usar meus sonhos").
- Tom de acolhimento; nunca previsão determinista de saúde/dinheiro/relações.
- Regeneração da MESMA janela limitada (2×). Gerar no idioma ativo do app.

---

## FRENTE B — "Motor de Ofertas" (degustação + gatilhos)

Princípio: **mostrar valor real no momento em que ele existe**, nunca paywall
frio. Duas mecânicas:

### B1. Degustação de features premium (teaser)

Momento-gatilho → amostra genuína → convite. Candidatas (conferir gates em
`FeatureAccessService`):

| Momento | Feature premium | Degustação sugerida |
|---|---|---|
| Salvou um sonho | `aiDreamAnalysis` | Gerar a interpretação e mostrar as 2 primeiras frases; o resto sob blur com CTA |
| Abriu o Seu Dia | `astrologyDailyWeather` | Clima mágico resumido em 1 linha; versão completa premium |
| Criou o mapa astral | `astrologyMagicalProfile` | 1 parágrafo do perfil mágico; perfil inteiro premium |
| Fez 1ª tiragem grátis do dia | limites de runas/oráculo/pêndulo | "Amanhã tem mais — ou tiragens ilimitadas com Premium" |
| Terminou lição 0 de uma trilha | `interactiveMagicalLearning` | Mostrar o TÍTULO + 1 frase da lição 1 encadeada |
| Perguntou ao conselheiro | `aiMysticCounselor` | 1ª resposta completa grátis (1×/vida), depois teaser |

Implementação: um componente reutilizável `TeaserReveal` (conteúdo real +
gradiente de blur + CTA que abre `PremiumUpgradeSheet` com contexto da feature)
e um serviço `OfferEngine` que decide SE mostra (ver B3). O custo de IA da
degustação é real: gerar 1× e cachear por registro; nunca regerar num rebuild.

### B2. Gatilho de engajamento → Leitura do Ciclo

Sinais já disponíveis: streak (`DailyCheckinRepository.currentStreak`),
contagem de registros do período (mesmas consultas do
`_practiceDaysThisMonth`/analytics). Regra inicial: streak ≥ 7 E ≥ N registros
no ciclo → card discreto no Seu Dia: "Sua lunação rendeu {N} registros. Quer a
leitura dela?" (o número concreto é o gancho). Reaparece no fim de cada ciclo,
nunca mais que 1×/ciclo.

### B3. Guardrails do OfferEngine (obrigatórios)

- Frequency cap global: no máx. 1 oferta visível por dia; cooldown de X dias
  por feature depois de dispensada (persistir em tabela/prefs).
- Dispensar 2× a mesma oferta = silenciar por 30 dias.
- Nunca interromper fluxo de escrita/ritual; ofertas só em telas de leitura.
- Premium nunca vê teaser de algo que já tem.
- Registrar evento de exibição/clique/conversão (base p/ ajustar as regras).

---

## Critérios de aceite (as duas frentes)

- `flutter analyze --no-fatal-infos` limpo; testes de i18n/paridade verdes;
  `bash scripts/check_arb_sync.sh` OK (toda string nova nos 4 ARBs).
- Fluxo de compra testado no sandbox do RevenueCat; falha de geração não
  consome a compra.
- Nenhuma degustação chama IA mais de 1× pelo mesmo registro (cache).
- Guardrails do OfferEngine cobertos por teste de unidade.

---

## Estado da implementação (atualizado pela sessão de execução)

Implementado na branch `claude/cycle-reading-offers-engine-vme4yp`:

### Frente B
- `lib/core/offers/offer_engine.dart` — `OfferEngine` com TODOS os guardrails
  B3 (cap global 1/dia, cooldown de 7 dias por oferta, 2 dispensas = silêncio
  de 30 dias, `alreadyOwned` nunca vê, oferta 1×/ciclo via `periodKey`,
  eventos exposição/clique/dispensa/conversão persistidos em prefs). Testes:
  `test/offer_engine_test.dart`.
- `lib/core/offers/teaser_reveal.dart` — `TeaserReveal` reutilizável
  (amostra REAL + placeholder desfocado FAIL-CLOSED + CTA → paywall).
- `lib/core/offers/teaser_cache.dart` — cache 1×/registro das amostras de IA.
- Degustação de sonhos (`dreamTeaser`): `DreamTeaserCard` na tela do sonho
  salvo sem interpretação (`dream_form_page`), com prompt dedicado de 2
  frases (`dreamTeaserSystemPrompt`, pt/en/es) — a interpretação completa nem
  chega a existir no aparelho. Demais candidatas da tabela B1 usam o mesmo
  `TeaserReveal`/`OfferEngine` e ficam para iterações seguintes (o clima
  mágico de 1 linha exigiria chamada de IA diária por usuária free — custo a
  decidir antes).
- B2: `CycleReadingOfferCard` no Seu Dia (streak ≥ 7 e ≥ 5 registros na
  lunação; 1×/ciclo; some para quem já tem a leitura da janela). Porta
  permanente (prateleira, sem guardrail) nas Estatísticas da Evolução Mágica.

### Frente A
- Fase 1: `lib/features/cycle_reading/data/services/cycle_reading_composer.dart`
  (JSON compacto: trechos ≤160 chars, ≤6 itens/fonte, contagens; céu
  calculado no aparelho — fases da lua da lunação + trânsitos/aspectos sobre
  o natal via `TransitCalculator`; `unknownBirthTime` respeitado; exclusão de
  fontes íntimas via `CycleReadingSourceOptions`). Testes:
  `test/cycle_reading_composer_test.dart`.
- Fase 2: `cycleReadingSystemPrompt` + `cycleReadingSectionInstruction` nos 3
  idiomas; `AIService.generateCycleReadingSection` (chamadas curtas por
  seção, retry com backoff em 429 + fallback de provedor; esgotado, sobe
  `AiRateLimitException` sem consumir a compra).
- Fase 3: `CycleReadingService` (gera as 7 seções, monta o Markdown com
  títulos do app, salva em `free_writings` com source `cycle_reading` — novo
  chip/selinho em Meus Registros) + `CycleReadingReportPage`
  (flutter_markdown + `ShareCard` da afirmação e do selo). Testes:
  `test/cycle_reading_service_test.dart`.
- Fase 4: tabela local `cycle_readings` (migração v21) sincronizada
  (`SyncEntity.cycleReadings` + `supabase/cycle_readings_migration.sql` — 
  rodar no SQL Editor); produto consumível `leitura_ciclo_mes`
  (`RevenueCatConfig.cycleReadingMonthProductId`,
  `PaymentService.purchaseConsumable`); `CycleReadingIntroPage` com aviso de
  poucos registros, transparência do que é enviado + toggles de exclusão,
  crédito `pending` → `generated` (falha nunca consome a compra),
  regeneração 2×/janela.

### Quem paga, lê (decisão de produto que substitui o §5 do brainstorm)
- A leitura é **sempre** comprada. **Nem assinante Premium** recebe leitura
  de graça: a assinatura desbloqueia as features do app, não o produto
  avulso. Não há cortesia mensal, nem origem `pro` no crédito.
- Em compensação, **todo mundo prova um pedaço**: a tela de compra traz uma
  degustação de 2 frases REAIS sobre o período — geradas do mesmo material
  que a leitura paga usaria (`cycleReadingTeaserSystemPrompt`,
  `AIService.generateCycleReadingTeaser`) — com o resto sob véu e o convite
  de compra. Mesmo princípio das degustações da Frente B: valor real no
  momento em que ele existe.
- Fail-closed como as demais: a amostra já nasce do tamanho da amostra (o
  relatório completo nem é gerado para quem não comprou) e fica cacheada
  por janela em `TeaserAiCache` — cada geração custa uma chamada de IA.

### O Vitalício inclui a Leitura da Lunação (e só ela)
- Quem compra o **lifetime** recebe a Leitura da Lunação a cada lunação, sem
  nova cobrança (`CycleReadingOrigin.lifetime`, crédito sem `product_id`). A
  **Leitura da Semana continua avulsa para todo mundo**, inclusive para o
  vitalício: é ela que mantém uma linha de receita viva depois da compra
  única, e a lunação (7 seções + selo) é que faz o Vitalício valer.
- A regra mora em `CycleReadingService.lifetimeCovers(periodType)` — uma
  fonte só, coberta por teste.
- **O gate é `PaymentService.isLifetime`** (entitlement do RevenueCat sem
  data de expiração), NUNCA `SubscriptionPlan.lifetime`: esse último também
  é concedido por Código Premium e vem embutido em `UserModel.admin()`, e
  gatear por ele daria leitura infinita a quem nunca pagou.
- Efeito colateral desejado: quem comprou o lifetime antes das leituras
  existirem passa a ter direito automaticamente, sem trabalho extra.
- Custo a acompanhar: ~87 chamadas de IA por pessoa por ano (7 seções ×
  ~12,4 lunações), perpétuo contra um pagamento único — e até 3× isso se a
  pessoa usar as 2 regerações. Incluir também a semanal levaria a ~295/ano,
  motivo pelo qual ela ficou de fora.
- Preço: com a lunação a R$ 9,90, o Vitalício entrega ~R$ 123/ano de valor.
  Ele precisa estar bem acima da anual (R$ 89,90) para fechar.

### Todo muro pago dá um gostinho (a regra vale no app inteiro)
A regra acima não é só da Leitura do Ciclo: **onde havia paywall frio, agora
há amostra REAL**. Onde o conteúdo pago é gerado por IA, o gate saiu da tela
e foi para a origem — sem acesso, o texto completo **nem chega a ser
gerado**, e no lugar dele roda uma chamada curta de degustação.

| Muro | Antes | Agora |
| --- | --- | --- |
| Previsão Mágica do Dia | títulos + placeholder borrado + botão; **o texto Premium inteiro era gerado e salvo no aparelho do free** | `getDailyWeather(withAiText:)` não gera nem devolve texto sem acesso; a tela mostra 2 frases reais sobre o céu de hoje (`generateDailyWeatherTeaser`) |
| Perfil Mágico | só `kPremiumPlaceholderText` borrado + botão; **a análise inteira era gerada em background para o free** | `generateAIMagicalProfile(hasFullAccess:)` só gera para quem tem acesso; a tela mostra 2 frases reais do mapa (`generateMagicalProfileTeaser`) |
| Lição da trilha (2ª em diante) | `showPaywallThenPop` — a página **fechava na cara** | primeiro parágrafo REAL do ensino sob `TeaserReveal` (conteúdo estático: sem IA, sem custo); o gate é reativo, então assinar destrava sem sair da tela |
| Conselheiro nas tiragens (runas, oráculo, tarô) | botão que só abria o paywall | `CounselorTeaserCard`: 2 frases reais sobre a tiragem que acabou de sair (`generateCounselorTeaser`), cacheadas por tiragem |

- `OfferSlot.drawLimitTeaser` fica **reservado, sem tela, de propósito**: no
  limite diário o que a assinatura vende é quantidade, não conteúdo —
  sortear uma carta extra só para escondê-la seria provocação, não
  degustação. O gostinho daquela tela é o do Conselheiro.
- `OfferEngine.recordWallExposure` registra a exposição de um **muro** sem
  ocupar a vaga de oferta do dia: o cap de 1/dia existe para conter oferta
  que aparece sozinha, e um muro é a própria tela que a pessoa abriu —
  silenciá-lo mostraria menos do que o paywall que ele substituiu.

### Leitura da Semana (o segundo período)
- `CycleReadingPeriodType` (`week` | `lunation`) atravessa modelo, crédito,
  composer e prompts. A janela da semana são os últimos 7 dias, hoje
  incluído (`CycleReadingService.currentWeek`).
- A semana entrega **4 seções** (retrato, fios, céu, afirmação);
  prática, rituais e selo continuam exclusivos da lunação — é essa
  diferença visível que sustenta a diferença de preço (brainstorm §4).
- O crédito é por (janela, tipo): comprar a semana não entrega a lunação.
  Mínimo de registros próprio (3, contra 5 da lunação) no aviso de leitura
  rasa. A tela de compra tem seletor com os dois preços à vista.
- Produto `leitura_ciclo_semana`
  (`RevenueCatConfig.cycleReadingWeekProductId`).

### Adequação à web (port do PR #218)
- A compra avulsa passa por **offering/pacote**, não por produto solto: no
  navegador o SDK do RevenueCat implementa `getOfferings`/`purchasePackage`,
  mas `getProducts` e `purchaseStoreProduct` lançam
  `UnsupportedPlatformException`. `PaymentService.getConsumablePackage`
  procura na offering `cycle_readings` e casa pelo id do produto.
- O paywall nativo não existe na web; a compra da leitura já acontece em
  tela própria do app (`CycleReadingIntroPage`), que funciona nas três
  plataformas.
- Nada em `lib/core/offers/` e `lib/features/cycle_reading/` usa `dart:io`;
  o céu do período cai no cálculo aproximado quando o sweph não responde.
- Os `ShareCard` da leitura herdam o download do navegador que o port
  adicionou ao `showShareCardSheet`.

### Dívidas legadas zeradas nesta passagem
Correções de produção (bugs reais que os testes acusavam):
- `StaggeredEntrance` e `LivingEmblem`: a espera das animações era um
  `Future.delayed` solto, que sobrevivia à saída da tela. Virou `Timer`
  cancelado no `dispose`.
- `StarfieldBackground`: cintilava em ciclo infinito ligado no campo —
  gastava bateria inclusive para quem pediu "reduzir movimento" e deixava
  qualquer `pumpAndSettle` da página preso. Agora começa no primeiro frame
  e respeita a preferência do sistema.
- Privacidade: `ListTile` dentro de `Container` colorido escondia a
  ondulação de toque; a cor passou para um `Material`.
- Signos: seis rótulos em português fixo (sem acento, por isso escapavam do
  scanner) foram para os 4 ARBs.
- Escrita livre: a documentação da classe dizia "salvo apenas por ação
  explícita" enquanto o app salva sozinho — era o comentário que estava
  errado, e é ele que fazia os testes parecerem certos.

### Pendências operacionais (fora do código)
- Criar `leitura_ciclo_mes` e `leitura_ciclo_semana` como consumíveis na
  App Store Connect e no Google Play Console, importar no RevenueCat e
  agrupá-los na offering `cycle_readings`.
- Para a web, cadastrar os mesmos dois produtos no RevenueCat Billing (com
  os mesmos identificadores) e incluí-los na mesma offering.
- Rodar `supabase/cycle_readings_migration.sql` no projeto Supabase.
- Testar o fluxo de compra no sandbox do RevenueCat (critério de aceite que
  exige loja real).
