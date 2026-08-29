# Próximos Passos — Avaliação e Plano (agosto/2026)

> Avaliação das 7 ideias levantadas pela Layla em ago/2026, cada uma medida em:
> viabilidade, benefícios, desvantagens/riscos, esforço, ganho pro cliente e
> ganho pro app. As afirmações sobre o código citam arquivo real; as sobre
> serviços externos (Instagram, Flo) foram checadas em ago/2026 e apodrecem —
> reconferir antes de implementar.

## Sumário executivo

| # | Ideia | Viabilidade | Esforço | Ganho cliente | Ganho app | Onda |
|---|---|---|---|---|---|---|
| 1 | Voltar robusto na web | Alta (caminho conhecido) | Alto (3–5 sem) | Alto | Alto | 1 |
| 2 | Notificações no webapp | Alta (Web Push + Supabase) | Médio-alto (MVP 1,5–2,5 sem) | Alto | Alto | 1 |
| 3 | Ciclo Menstrual em Ciclos | Alta (manual); Flo direto inviável | Médio (MVP 2–3 sem) | Alto | Alto | 2 |
| 4 | Acessibilidade visual | Alta | Baixo-médio (incremental) | Médio (essencial p/ quem precisa) | Médio | 2 (contínuo) |
| 5 | Vibrar capa + Salem | Alta (Android); iOS web não vibra | Baixo (1–2 dias) | Baixo | Baixo-médio | 3 |
| 6 | Influencers recomendadas | Alta | Baixo (2–4 dias) | Médio | Médio | 3 |
| 7 | Feed do Instagram | Parcial (só conta própria) | Médio | Baixo-médio | Médio | 4 (estudo) |

**Sequência sugerida:** Onda 1 = fundação da web (itens 1 e 2, nessa ordem — o
clique de uma notificação precisa de uma URL de destino, que só o item 1 cria).
Onda 2 = produto (item 3, com o item 4 correndo em paralelo como higiene
contínua). Onda 3 = polimento e comunidade (itens 5 e 6). Onda 4 = item 7,
que depende de decisão de conta e não de código.

---

## 1. Voltar robusto no web app

### O que já existe

O paliativo atual é um subsistema inteiro: o "corrimão" JS que empurra 8
degraus sintéticos no histórico (`web/index.html:114-254`), o ouvinte de
`popstate` (`lib/core/navigation/corrimao_de_voltar_web.dart`), o interceptador
de `didPopRoute` (`lib/core/navigation/porteiro_do_voltar.dart`) e a escada de
decisão (`lib/features/home/presentation/caminhada_do_voltar.dart`). Ele chegou
ao teto documentado no próprio código: **o Chrome Android para de entregar
`popstate` do 3º gesto em diante e fecha a aba** — entradas sintéticas de mesma
URL não são honradas, "nenhum JavaScript vence isso" (`web/index.html:229-243`).

A causa raiz também está escrita lá: só 5 rotas nomeadas existem
(`lib/main.dart:535-549`); todo o resto são ~447 `Navigator.push` em ~114
arquivos — para o navegador, o app inteiro é uma página só
(`SingleEntryBrowserHistory`: o histórico nunca cresce de verdade).

### Recomendação: migração incremental para go_router

Com a Router API, cada navegação com URL vira entrada **real** de histórico
(`MultiEntriesBrowserHistory`), criada sob gesto — a categoria que o Chrome
honra. Não é preciso migrar os 447 pushes: telas sem URL continuam como pilha
"pageless" e o `PorteiroDoVoltar` deixa de ser curativo e vira **ponte**
(intercepta o voltar e faz `maybePop()` um-a-um nas telas ainda não migradas).

- **Fase 0 — Spike (2–3 dias).** go_router + shell mínimo de 4 abas em staging;
  no aparelho real, 5+ gestos de voltar a partir de pilha profunda. Critério:
  nenhuma aba fechada. Valida a hipótese antes de investir. Manter hash
  strategy (`#/...`) — zero mudança no Cloudflare Pages e nas redirect URLs de
  OAuth.
- **Fase 1 — Shell + auth (1–1,5 semana).** `StatefulShellRoute.indexedStack`
  com 4 branches substitui o `IndexedStack` + `GlobalKey<NavigatorState>` de
  `home_page.dart` (equivalente direto, estado por aba preservado);
  `RequireAuth`/`GuestOnly` viram `redirect` com `refreshListenable`;
  desligar o corrimão de `web/index.html` atrás de flag reversível (os degraus
  sintéticos confundiriam o histórico novo).
- **Fase 2 — Telas de pilha profunda (1–2 semanas).** URL para as ~20 telas
  mais fundas (lições, detalhes da Enciclopédia, rituais guiados, Leitura do
  Ciclo, Configurações, editores dos Diários). Mapear `AppDeepLink`
  (`lib/core/navigation/app_deep_link.dart`) payload→URL — unifica notificação
  e web, em sinergia direta com o item 2.
- **Fase 3 — Contínua.** Pushes restantes podem ficar pageless indefinidamente;
  quando a cobertura de URL bastar, aposentar o Porteiro e os arquivos
  `corrimao_de_voltar_*`.

### Prós, contras, riscos

- **Benefícios:** o voltar para de fechar a aba (a maior fricção da web hoje);
  telas linkáveis e compartilháveis; F5 não perde mais tudo; base para o clique
  de push do item 2.
- **Desvantagens:** é a mudança mais invasiva da lista; ~6 arquivos de teste de
  navegação precisam de ajuste; durante a migração convivem dois regimes (URL
  + pageless).
- **Riscos:** volta do OAuth (testar `recomeco_web.dart` e a detecção em
  `main.dart` com o Router montado; **não** migrar para path strategy agora);
  reproduzir no shell novo o `NotificationListener<NavigationNotification>` do
  predictive back (`home_page.dart:345`).

**Ganho pro cliente:** alto — é o defeito mais visível do canal principal.
**Ganho pro app:** alto — retenção web, pré-requisito de push, fim de um
subsistema paliativo caro de manter. **Esforço total: 3–5 semanas.**

---

## 2. Notificações no webapp

### O que já existe

Só notificações **locais** e só **mobile**: `flutter_local_notifications` em
`lib/core/services/notification_service.dart`, guardado por `!kIsWeb` — na web
(o canal principal!) não existe notificação nenhuma. Zero push no projeto (sem
Firebase Messaging, de propósito: o Firebase foi removido).

### Recomendação: Web Push puro (VAPID) + Supabase — sem reintroduzir Firebase

FCM não resolveria a parte cara (agendar server-side — hoje os agendamentos são
calculados no aparelho); só substituiria a perna barata (enviar). Arquitetura
mínima:

- **Banco** (migrations em `supabase/`, padrão existente): `push_subscriptions`
  (endpoint, chaves, tz, locale; RLS por dono), `push_prefs` (espelho dos
  toggles do `NotificationProvider`), `astro_events` (datas de lua/sabbats
  **semeadas por script Dart a partir dos providers do próprio app** — garante
  que push e app mostram as mesmas datas) e `push_log` (idempotência).
- **Edge function `push-dispatch`** + pg_cron horário: seleciona eventos ×
  assinantes cuja hora local bate com a hora-alvo (mesmos horários do
  `NotificationService`), monta o texto nos idiomas do app, assina VAPID,
  envia, limpa endpoints mortos (404/410). Seria a primeira edge function
  publicada do projeto (a `ia/index.ts` nunca foi — seguir `docs/CHAVES_DE_IA.md`).
- **Cliente:** `web/push_sw.js` com escopo próprio (convive com o SW padrão do
  Flutter); serviço `push_subscription_service_web.dart` no padrão de
  conditional import já usado 3× no repo; permissão pedida **somente sob gesto**
  (toggle nas Configurações — obrigatório no iOS); `NotificationProvider`
  ramifica: mobile mantém o caminho local intacto, web sincroniza prefs e
  subscription. A UI de Configurações não muda.
- **iOS:** Web Push só em PWA **instalada** na tela inicial (16.4+). Detectar
  standalone e orientar a instalação; medir taxa de instalação antes de
  investir na fase 2.

### Fases

1. **MVP (1,5–2,5 semanas):** lua cheia/nova + sabbats server-side.
2. **Personalizados (1–2 semanas):** lembrete do Salem, win-back D3/D7 (via
   `last_seen_at` carimbado a cada abertura), desbloqueio da Leitura do Ciclo.
3. **Opcional, depois:** unificar o mobile no mesmo pipeline (hoje o local
   mobile funciona — não mexer).

### Prós, contras, riscos

- **Benefícios:** reengajamento no canal onde hoje não existe **nenhum** meio de
  chamar a pessoa de volta; win-back e ofertas ganham alcance real.
- **Desvantagens:** infraestrutura nova para operar (função, cron, chaves);
  alcance zero no iOS sem instalação da PWA.
- **Riscos:** endpoints expiram em silêncio (tratar 410 +
  `pushsubscriptionchange`); rotina anual de reposição da seed de
  `astro_events`; estreia do pipeline de deploy de edge functions.

**Ganho pro cliente:** alto — quem quer o aviso da lua cheia passa a recebê-lo
onde usa o app. **Ganho pro app:** alto — retenção e canal de ofertas.

---

## 3. Ciclo Menstrual na aba Ciclos (premium + vitalício)

### O que já existe (tudo a favor)

- A aba Ciclos (`lib/features/cycles/presentation/pages/cycles_tab.dart`) já
  reúne Leitura do Ciclo, Suas Eras e o céu do mês — o Ciclo Menstrual entra
  como mais um cartão na mesma composição.
- **Gênero já existe e persiste**: `UserModel.gender`
  (`lib/features/auth/data/models/user_model.dart:56`) com
  `Gender.feminine/masculine/neutral` (`lib/core/i18n/gender.dart`). A regra
  pedida — opção visível só com **feminino ou neutro** selecionado — é um `if`
  no cartão; esconder do masculino, sem paywall nem provocação.
- **Gate premium+vitalício tem precedente pronto**: o acesso é
  `AuthProvider.isPremiumEffective` (cobre assinatura, código premium e
  vitalício). Atenção à lição registrada em
  `docs/prompt_leitura_ciclo_motor_ofertas.md`: para benefício **exclusivo do
  vitalício** o gate é `PaymentService.isLifetime` (entitlement RevenueCat),
  nunca `SubscriptionPlan.lifetime`. Aqui o pedido é "premium E vitalício têm
  acesso", então `isPremiumEffective` basta.
- **Sync pronto para tabela nova**: SQLite local + espelho Supabase com
  tombstones (`lib/core/services/data_sync_service.dart`) — mesma receita da
  tabela `cycle_readings` (migração local + SQL em `supabase/` + RLS).

### MVP (2–3 semanas): registro manual

1. Tabela `menstrual_logs` (data, tipo: início/fim/dia de fluxo, intensidade,
   sintomas, humor, notas) + sync + RLS.
2. Cartão na aba Ciclos (gate premium, condição de gênero) → página com
   calendário do ciclo, registro do dia e visão do ciclo corrente (dia N,
   duração média, previsão simples de próxima menstruação — sempre com
   linguagem de estimativa, nunca certeza).
3. **A alma da feature no contexto do app:** sobrepor o ciclo pessoal ao ciclo
   lunar (dados que o app já tem) — "sua fase interna × fase da lua" é o que
   nenhum rastreador genérico oferece e o que justifica o lugar na aba Ciclos.
4. Opcional: entrada como fonte do `CycleReadingComposer` para enriquecer a
   Leitura do Ciclo — **desligada por padrão**, com o mesmo toggle de exclusão
   de fontes íntimas que a Leitura já tem.

### Flo: o que é possível de verdade

**Integração direta é inviável — o Flo não tem API pública.** O caminho real é
indireto e parcial:

- **Fase 2 (opcional, só apps nativos):** plugin `health` lendo
  HealthKit (iOS) / Health Connect (Android). Se a pessoa sincroniza o Flo com
  a plataforma de saúde, os dados chegam por lá. Limitações: não funciona na
  web (canal principal); o Flo restringe/mudou a exportação de dados de
  menstruação ao longo do tempo; a direção do sync não é garantida.
- **Recomendação:** vender a feature como "registro manual + importar do app de
  saúde do celular (fase 2)", nunca como "integração com Flo" — promessa que
  não se pode cumprir.

### Prós, contras, riscos

- **Benefícios:** altíssima aderência ao público; motivo concreto e recorrente
  de abrir o app todo dia; argumento forte de venda premium/vitalício.
- **Desvantagens:** responsabilidade nova — **dado de saúde é dado sensível
  (LGPD art. 11)**: consentimento explícito e específico, política de
  privacidade atualizada, exclusão fácil e completa (tombstones já ajudam),
  jamais alimentar IA ou ofertas sem opt-in claro. Considerar criptografia da
  coluna no Supabase.
- **Riscos:** previsão de ciclo tratada como certeza médica (mitigar no texto:
  estimativa, não diagnóstico); escopo crescer para "app de saúde" — manter o
  recorte místico/lunar que é a identidade.

**Ganho pro cliente:** alto. **Ganho pro app:** alto — diferencial premium com
recorrência diária.

---

## 4. Acessibilidade visual (leitura das páginas)

### Resposta à dúvida ("o OS nativo já faz isso?")

**Em parte.** O leitor de tela (TalkBack/VoiceOver) é do sistema, mas ele só lê
**o que o app expõe** na árvore de semântica — e no Flutter (que desenha em
canvas, especialmente na web) essa árvore é construída pelo app, não extraída
do HTML. Ou seja: o motor de leitura já existe de graça; o conteúdo legível é
responsabilidade nossa.

### Estado atual: base boa, cobertura desigual

- **Já certo:** `ExcludeSemantics` nos decorativos; conteúdo premium fail-closed
  (bloqueado nem entra na árvore — o leitor não vaza o que é pago, corrigido em
  `docs/AUDITORIA_JUL2026.md:42`); "reduzir movimento" respeitado; contraste
  WCAG testado de forma bloqueante (`test/contraste_dos_temas_test.dart`).
- **Dívidas conhecidas:** `Semantics(label:)` positivo em só ~6 lugares; emojis
  como conteúdo sem label (ex.: `cycles_tab.dart:579`); barras de progresso e
  chips sem valor semântico; **o Salem e o tour são invisíveis para leitor de
  tela** (`draggable_cat_mascot.dart`, `salem_tour.dart`); pendência registrada
  de contraste `starYellow` 2,25:1 com 145 usos
  (`docs/AUDITORIA_PRODUTO_AGO2026.md:299`).

### Plano incremental (sem "projeto grande")

1. Corrigir o `starYellow` no tema claro (pendência já medida) — 1 dia.
2. Labels nos fluxos principais: Seu Dia, Ciclos, navegação inferior, cartões
   de oferta — 2–3 dias.
3. Semântica do Salem (botão com label e ação) e do tour — 1–2 dias.
4. Sessão de teste real com TalkBack (Android) e VoiceOver (iOS/Safari) — meio
   dia, repetida a cada onda.

**Vale a pena?** Sim: esforço baixo-médio, elimina risco de rejeição nas lojas,
e para quem depende de leitor de tela é a diferença entre usar e não usar o
app. Tratar como higiene contínua (critério de aceite de toda feature nova),
não como projeto separado.

---

## 5. Vibrar ao fechar a capa e ao clicar no Salem ✅ (implementado em ago/2026)

> Entregue: helper `ToqueMagico` (`lib/core/haptics/toque_magico.dart`) com ponte
> `navigator.vibrate` para a web; vibração na capa pousando (junto da poeira, mesmo
> guarda do "reduzir movimento"), no carinho do Salem e nos dois pufs de fumaça
> (sumiço no 5º toque e reaparição pelos 5 toques na tela). Sem toggle
> (decisão: segue o sistema). Testes em `test/toque_magico_test.dart`.

### Viabilidade por plataforma (a parte que engana)

- **Android/iOS nativos:** trivial — `HapticFeedback` do Flutter, já usado em 11
  pontos do app (auth, lições).
- **Web Android/Chrome:** possível via `navigator.vibrate`, com ponte JS no
  padrão de conditional import já estabelecido (`_stub.dart` + `_web.dart`,
  como `corrimao_de_voltar`).
- **Web iOS (Safari/PWA): não vibra.** O Safari não implementa a API de
  vibração. Limitação de plataforma, sem contorno — aceitar.

### Implementação (1–2 dias)

1. Helper único `toque_magico.dart` (nativo → `HapticFeedback`; web →
   `navigator.vibrate` curto; iOS web → no-op silencioso), respeitando uma
   preferência "vibração" nas Configurações.
2. Chamar no fechar da capa — `_closeCover()` em
   `lib/features/encyclopedia/presentation/pages/encyclopedia_index_page.dart:183`
   (um `mediumImpact`: o livro "pousa") — e no toque do Salem em
   `lib/core/widgets/mascot/draggable_cat_mascot.dart` (um `lightImpact`;
   talvez um padrão especial na dissolução em fumaça dos 5 toques).
3. De quebra, os momentos rituais que hoje não têm haptics (tiragens, check-in)
   podem adotar o mesmo helper depois.

**Ganho:** pequeno mas barato — capricho sensorial coerente com o cuidado que o
app já tem (poeira da capa, partículas do Salem). Quick win clássico.

---

## 6. Influencers de bruxaria recomendadas

### Viabilidade e formato

Alta — é conteúdo curado, sem dependência externa. Formato sugerido: seção
"Vozes da Bruxaria" (nome, @, plataforma, bio curta de 2 linhas, link que abre
fora do app), alcançável pela Enciclopédia ou por Ferramentas.

- **Onde moram os dados:** começar como arquivo de conteúdo versionado no
  padrão existente (`life_eras_content_{pt,en,es}.dart`) — zero backend. Se a
  lista precisar mudar sem release, migrar depois para uma tabela Supabase
  pública somente-leitura.
- **Esforço:** 2–4 dias (a curadoria em si é o trabalho de verdade, e é da
  Layla, não do código).

### Prós, contras, riscos

- **Benefícios:** confiança e senso de comunidade sem construir rede social;
  ponte natural para o item 7; conteúdo que diferencia o app de um utilitário.
- **Desvantagens/riscos:** **curadoria é endosso** — definir critérios claros
  (e revisitar a lista periodicamente: pessoas públicas mudam); pedir
  consentimento das indicadas antes de publicar é elegante, evita atrito e
  ainda rende divulgação recíproca; deixar claro que não é conteúdo pago
  (e, se um dia for, sinalizar).

**Ganho pro cliente:** médio — descoberta de referências confiáveis. **Ganho
pro app:** médio — comunidade e possível canal de parceria/divulgação.

---

## 7. Feed do Instagram no app

### O que é possível hoje (checado em ago/2026)

- A API de contas **pessoais** do Instagram morreu em dez/2024. Acesso oficial
  a feed exige conta **profissional** (Business/Creator) e a Instagram Graph
  API, com app registrado na Meta, token renovável e revisão.
- **Feed "anônimo" de @s selecionados oficialmente não existe.** Seria
  scraping: viola os termos do Instagram, quebra sem aviso e arrisca bloqueio.
  **Não recomendado.**

### Os três caminhos reais

| Caminho | Como | Custo | Veredicto |
|---|---|---|---|
| (a) Graph API da própria conta | @grimoriodebolso vira conta profissional; edge function proxy com token + cache; app consome JSON | Setup médio, manutenção de token | O certo a médio prazo |
| (b) Widget de terceiros (Behold, EmbedSocial etc.) | WebView/iframe apontando para o widget | Assinatura mensal; menos controle visual; WebView destoa do app | Atalho, não recomendado |
| (c) Mural curado manualmente | Repostar imagens escolhidas no Supabase Storage + tabela `mural_posts`; app renderiza nativo | Zero API; trabalho editorial recorrente | **Melhor primeiro passo** |

O caminho (c) tem uma virtude escondida: vira um "mural editorial" que pode
incluir conteúdo de terceiros **com permissão explícita** (conectando com o
item 6) — e repostar com permissão resolve também o direito autoral, que no
embed oficial é coberto pelo próprio Instagram mas no repost manual é
responsabilidade nossa.

### Recomendação

Adiar a decisão técnica: primeiro converter a conta em profissional (custo
zero, pré-requisito do caminho (a)) e validar com o mural (c) se o conteúdo do
Instagram dentro do app muda algum número (retenção, cliques). Se mudar,
investir no (a). **Esforço:** (c) ~1 semana; (a) ~2 semanas + manutenção.

**Ganho pro cliente:** baixo-médio — o conteúdo já está no Instagram. **Ganho
pro app:** médio — ponte entre canais e app mais "vivo" entre releases.

---

## Decisões em aberto (para a Layla)

1. **Item 1:** aprovar o spike (Fase 0) antes de qualquer compromisso com a
   migração completa? (Recomendado: sim — 2–3 dias que provam ou derrubam a
   tese no aparelho real.)
2. **Item 3:** o nome público da seção ("Ciclo Menstrual"? "Ciclo Interno"?
   "Lua Interior"?) e se a fase 2 (importar do app de saúde) entra no discurso
   de lançamento ou fica calada até existir.
3. **Item 6:** critérios de curadoria e se haverá pedido de consentimento às
   pessoas indicadas (recomendado: sim).
4. **Item 7:** converter @grimoriodebolso em conta profissional (pré-requisito
   sem custo do caminho oficial).

## Fora do escopo desta avaliação, mas tocado por ela

- A pendência de contraste `starYellow` (item 4) já estava registrada na
  auditoria de produto — este plano só a promove a primeiro passo concreto.
- O item 2 estreia o pipeline de edge functions que a segurança das chaves de
  IA (`docs/CHAVES_DE_IA.md`) também espera — fazer o item 2 primeiro barateia
  aquele conserto.
