# Brainstorm — Ciclo Menstrual na aba Ciclos

> Como os outros brainstorms do repo (`brainstorm_analise_magica_periodo.md`,
> `brainstorm_aprendizado_premium.md`), este documento vive ANTES da
> implementação: aqui mora a visão de produto e a pesquisa de fundamentação;
> a execução ganha um `prompt_implementacao_*.md` próprio quando for a hora.
> Escrito a pedido da Layla para "atacar o Item 3" do roadmap
> (`docs/PROXIMOS_PASSOS_AGO2026.md`), cobrindo três frentes: o que já foi
> idealizado, como a bruxaria historicamente lida com a menstruação, e como
> transformar isso numa feature real do Grimório de Bolso.

---

## 1. O que já foi idealizado (recapitulando o plano de ago/2026)

Do `docs/PROXIMOS_PASSOS_AGO2026.md`, item 3 — resumo do que já está decidido
e não deveria ser reaberto sem motivo:

- **Onde mora:** mais um cartão na aba Ciclos (`cycles_tab.dart`), ao lado da
  Leitura do Ciclo, Suas Eras e o céu do mês.
- **Quem vê a opção:** só `Gender.feminine` ou `Gender.neutral`
  (`UserModel.gender` já existe e persiste) — nunca `masculine`. Sem paywall
  nem provocação para quem não vê: a opção simplesmente não existe pra ela.
- **Quem tem acesso de verdade:** `AuthProvider.isPremiumEffective` (cobre
  assinatura, código premium e vitalício — o pedido original era "premium E
  vitalício", e esse getter já cobre os dois).
- **Registro:** manual. **Flo não tem API pública** — qualquer promessa de
  "integração com Flo" é uma promessa que não se pode cumprir. O caminho
  parcial e futuro (fase 2, só apps nativos) é `HealthKit`/`Health Connect`
  via plugin `health`, se a pessoa já sincroniza outro app com a plataforma
  de saúde do celular.
- **"A alma da feature"** (frase do próprio plano): sobrepor o ciclo pessoal
  ao ciclo lunar — dado que o app já tem e nenhum rastreador genérico
  oferece. Este documento dá corpo concreto a essa frase na seção 3.
- **Dado sensível:** menstruação é dado de saúde (LGPD art. 11) —
  consentimento explícito, exclusão fácil, nunca alimentar IA/ofertas sem
  opt-in.
- **Infraestrutura já pronta para reaproveitar:** sync com tombstones
  (`DataSyncService`), padrão de toggle de exclusão de fonte íntima
  (`CycleReadingSourceOptions` em `cycle_reading_composer.dart`), padrão de
  arquivo de conteúdo por fase versionado em 3 idiomas
  (`life_eras_content_{pt,en,es}.dart`), cálculo de fase lunar já existente
  (`LunarProvider.phaseOn`/`getCurrentMoonPhase`).

Este brainstorm não muda nada disso — ele preenche o que ainda estava em
aberto: **qual conteúdo e qual voz** a feature tem, para não virar "mais um
Flo com roupa roxa".

---

## 2. Como a bruxaria lida com a menstruação

Pesquisa feita em set/2026 — tradições vivas mudam de interpretação com o
tempo; reconferir antes de citar como fato histórico definitivo. Nenhuma
dessas linhas é "a" bruxaria — são correntes distintas, às vezes
contraditórias entre si, dentro da neopaganismo/bruxaria contemporânea
(majoritariamente ocidental — é o recorte que o app já assume no resto do
conteúdo, então é o recorte seguro para não prometer representar tradições
que não são a do app).

### 2.1 Sangue como magia — a linha mais antiga

Em várias culturas, o sangue menstrual foi historicamente tratado como
força vital visível, e não como impureza: na crença popular irlandesa e
escocesa, uma mulher sangrando em sincronia com a lua tinha "visão de
prata" (uma segunda-visão), e seu sangue, depositado na base de árvores
sagradas ou círculos de pedra, invocava ancestrais ou fadas. Em vilarejos
dos Bálcãs, mulheres passavam linho manchado de sangue nas bordas dos
campos como encantamento para despertar a fertilidade da terra antes do
plantio. A prática de oferecer sangue menstrual à terra aparece em culturas
tão distintas quanto eslavos antigos e povos indígenas — e hoje é retomada
por bruxas contemporâneas como reivindicação de soberania sobre o corpo
([Wild Witch Herbs](https://wildwitchherbs.com/menstrual-blood-earth-ritual/),
[The Moon School](https://www.themoonschool.org/menstruation/red-witch-meaning/)).

**Implicação de produto:** essa linha é linda como *conteúdo educativo/
histórico* ("você sabia que..."), mas o app **não deve instruir rituais
literais com fluido corporal** — risco de saúde, de tom e de moderação de
conteúdo gerado. A seção 3 propõe como honrar essa lore sem virar manual.

### 2.2 Lua Vermelha / Lua Branca — a sincronia com a lua

A distinção mais citada em bruxaria contemporânea vem do livro *Red Moon*,
de Miranda Gray: existem dois padrões tradicionais de sincronia entre o
ciclo menstrual e o ciclo lunar.

- **Lua Branca:** menstruar com a lua nova, ovular com a lua cheia — ligada
  aos níveis mais profundos da própria consciência; o padrão mais comum
  hoje.
- **Lua Vermelha:** menstruar com a lua cheia, ovular com a lua nova —
  historicamente associada às mulheres-medicina, parteiras e guardiãs de
  sabedoria da comunidade; a mulher traz a energia da própria escuridão
  interior para fora, como dádiva.

([Nylon](https://www.nylon.com/entertainment/red-moon-cycle-full-moon-period),
[Yoga Goddess](https://yogagoddess.ca/should-your-period-land-on-the-full-moon-or-the-new-moon-to-be-in-sync-with-nature/))

**Implicação de produto: esta é literalmente "a alma da feature" do plano
original, com nome e mecânica prontos.** Ver seção 3.1.

### 2.3 A Deusa Tripla — arquétipos por fase

Donzela (lua crescente), Mãe (lua cheia) e Anciã/Bruxa (lua minguante) é o
arquétipo central da Deusa Tripla na Wicca e no neopaganismo — e ele espelha
tanto o ciclo lunar quanto o ciclo de vida de uma mulher. Práticas
contemporâneas expandiram para 4 fases (Donzela, Mãe, Feiticeira/Maga,
Anciã), cada uma correspondendo a uma fase do ciclo menstrual, à lua e a uma
estação do ano
([Spells8](https://spells8.com/lessons/the-triple-goddess/),
[Wild Moon Sacred Cycles](https://wildmoonsacredcycles.com/2020/09/30/menstrual-phases-the-maiden/)).

**Implicação de produto:** o app já usa pensamento arquetípico por fase (as
Eras da vida com regentes planetários) — o mesmo molde serve aqui, ver 3.2.

### 2.4 As Quatro Estações Internas — o encaixe perfeito com o app

Fora do vocabulário estritamente wiccano, mas amplamente adotado em
espiritualidade feminina contemporânea (Alexandra Pope, popularizado por
Maisie Hill em *Period Power*): o ciclo menstrual tem 4 fases que espelham
as 4 estações do ano.

| Estação interna | Fase do ciclo | Energia |
|---|---|---|
| **Inverno** | Menstruação | Repouso, introspecção, baixa energia |
| **Primavera** | Pré-ovulatória | Energia nova, entusiasmo, vontade de agir |
| **Verão** | Ovulação | Pico de energia e confiança, risco, conexão |
| **Outono** | Pré-menstrual (lútea) | Irritação, sensibilidade, clareza cortante |

([Mooncup](https://wearemooncup.com/blogs/the-bloody-bulletin/4-seasons-menstruation),
[sobrief.com](https://sobrief.com/books/period-power))

**Implicação de produto: este é o achado mais valioso da pesquisa.** O app
**já tem** uma Roda do Ano com 8 sabbats organizados nas 4 estações (Yule
inverno, Ostara/Imbolc primavera, Litha/Beltane verão, Mabon/Lammas outono —
`lib/features/wheel_of_year/data/models/sabbat_model.dart`). O ciclo
menstrual vira, literalmente, **a Roda do Ano pessoal, em miniatura, a cada
mês** — a mesma linguagem visual e emocional que a pessoa já usa no resto do
app, sem inventar um vocabulário novo do zero.

### 2.5 Correspondências práticas — cristais e ervas

Bruxaria popular associa cristais e ervas específicos ao apoio menstrual:
quartzo rosa (alívio geral, "pedra do amor"), pedra da lua (ligação com o
feminino e a energia lunar, ajuda com hormônios), malaquita (absorve dor
física), jade preto/azeviche (reduz inchaço), citrino (equilíbrio hormonal em
elixir); entre ervas, dong quai/feverfew para regular o fluxo e cólica,
lavanda para relaxamento, aveia em banho calmante
([Fierce Lynx Designs](https://fiercelynxdesigns.com/blogs/articles/crystals-for-period-cramps-ancient-healing-wisdom-for-modern-women),
[Anima Mundi Herbals](https://animamundiherbals.com/blogs/blog/12-rituals-herbs-to-honor-your-bleed)).

**Implicação de produto:** o app **já tem** uma Enciclopédia de Cristais e
Ervas (`CrystalModel.intentions: List<String>`). Cruzar por fase é reaproveitar
conteúdo existente, não criar um do zero — ver 3.3.

### 2.6 Tenda Vermelha e rodas de mulheres — nota de cautela

O "movimento da Tenda Vermelha" (círculos de mulheres para acompanhar a
menstruação juntas) popularizou-se no neopaganismo ocidental a partir do
romance de Anita Diamant, ecoando (mas não reproduzindo com precisão
histórica) costumes reais de reclusão menstrual encontrados em diversas
culturas indígenas ao redor do mundo — costumes com histórias complicadas
(ora praticados como tabu/exclusão, ora como espaço sagrado de descanso).
**Não é uma tradição única nem universal.** Para o app, a recomendação é
tratar isso como inspiração de tom (o convite ao repouso, não a exclusão) e
**não** apresentar como "a" prática ancestral de nenhum povo específico —
o app já opera no recorte wiccano/neopagão ocidental moderno no resto do
conteúdo, e é esse o recorte seguro a manter aqui também.

### 2.7 Panorama competitivo — já existe gente fazendo isso

Vale mapear antes de desenhar: **Lunari — Period & Moon Cycle** é um app já
publicado que sincroniza previsão de período com fase lunar e vende, como
feature premium, rituais lunares guiados por fase, orientação por cartas de
oráculo e um "guia de sabedoria da estação do ciclo"
([App Store](https://apps.apple.com/us/app/-/id6754945046),
[Witch Way From Here](https://witchwayfromhere.com/the-best-witchy-period-app-out-there/)).
Isso não muda a viabilidade — só confirma que o público existe e já paga por
isso — mas significa que **o Grimório de Bolso não entra virgem nesse
nicho**: o diferencial não pode ser só "period tracker com estética de
bruxa", tem que ser a integração de verdade com o que o app já é (mapa
astral, Roda do Ano, Leitura do Ciclo, Enciclopédia) — coisas que um app
dedicado a período não tem histórico de dados para cruzar, e o Grimório já
tem.

---

## 3. Proposta de implementação

### 3.1 O mecanismo central: Lua Vermelha × Lua Branca (a "alma" do plano)

A cada registro de início de menstruação, o app já sabe a fase lunar do dia
(`LunarProvider.phaseOn(data)`, sem cálculo novo). Depois de ~3 ciclos
registrados, o app pode mostrar — **sempre como observação poética, nunca
como fato determinista** — algo como:

> *"Nos últimos 3 ciclos, seu sangramento chegou perto da lua minguante.
> Quem carrega esse padrão é chamada, na tradição, de Bruxa da Lua Vermelha —
> a que traz a própria escuridão como dádiva."*

Regra de produto: só mostrar com dados suficientes (mínimo 3 ciclos
completos), sempre com linguagem de padrão observado ("nos últimos ciclos"),
nunca de destino ou diagnóstico, e nunca escondendo que ciclos variam e o
padrão pode mudar.

### 3.2 O conteúdo por fase: as 4 Estações Internas

Modelo de conteúdo novo, no MESMO padrão de `life_eras_content_{pt,en,es}.dart`
(arquivo de dados versionado, 3 idiomas, sem lógica):

```
enum CyclePhase { menstrual, follicular, ovulatory, luteal }
```

Cada fase carrega: nome poético (Inverno/Primavera/Verão/Outono — reaproveita
o vocabulário que a Roda do Ano já ensinou), 1 parágrafo de energia
esperada, 2-3 sugestões de autocuidado/ritual leve (banho, journaling,
pausa — nunca prescrição médica), um prompt de escrita livre para o dia, e
o cross-link da seção 3.3. **Duração de cada fase é estimada a partir da
duração média do ciclo da própria pessoa** (não um calendário fixo de 28
dias) — atualiza conforme mais ciclos são registrados.

### 3.3 Cross-link com a Enciclopédia (reaproveitamento, não feature nova)

Cada fase aponta para 2-3 entradas já existentes na Enciclopédia de Cristais
e Ervas, filtrando por `CrystalModel.intentions` (ex.: fase menstrual →
pedra da lua, quartzo rosa). Zero conteúdo novo de cristais/ervas — só uma
tela de "hoje, isto pode ajudar" que linka para o que já existe. Mesmo
princípio de reaproveitamento vale para o céu do mês (`MonthSkyCard`, já na
aba Ciclos) e para o calendário lunar (`lunar_calendar_page.dart`).

### 3.4 O que NÃO entra no MVP (e por quê)

- **Rituais literais com sangue menstrual** — vira parágrafo de contexto
  histórico (seção 2.1), nunca instrução passo a passo.
- **"Tenda Vermelha" como feature social** (círculo/comunidade) — o app não
  tem infraestrutura social nenhuma (confirmado no roadmap geral); fora de
  escopo total.
- **Previsão de fertilidade/anticoncepção** — o app é de autoconhecimento
  mágico, não um método contraceptivo; qualquer linguagem de previsão deve
  deixar isso explícito para não virar responsabilidade médica.
- **Integração com Flo** — já descartada no plano original; não reabrir.

### 3.5 Estrutura técnica (reaproveitando o que já existe)

- **Dados:** tabela local `menstrual_logs` (data, tipo, intensidade,
  sintomas, humor, notas) na próxima versão do schema (`database_helper.dart`
  está em `version: 23` — seria a 24), migração Supabase espelhando o padrão
  de `cycle_readings`, sync via `DataSyncService` com tombstones.
- **Gate:** `Gender.feminine || Gender.neutral` E `isPremiumEffective` —
  ambos já existem, é composição de dois `if`s.
- **Conteúdo:** `menstrual_phase_content_{pt,en,es}.dart` no padrão de
  `life_eras_content`.
- **Cálculo de fase:** duração do ciclo e da fase atual = aritmética simples
  sobre os `menstrual_logs` (não precisa de biblioteca nova); fase lunar do
  dia = `LunarProvider` já existente.
- **UI:** 1 cartão novo em `cycles_tab.dart` (mesmo padrão dos outros 3) →
  página com calendário de registro + "sua estação agora" (nome da fase +
  energia + prompt do dia) → tela de insight Lua Vermelha/Branca quando
  houver dados suficientes.
- **Privacidade:** tela de consentimento explícito específico (não genérico
  de conta) antes do primeiro registro, exclusão completa em 1 toque
  (reaproveita o fluxo de exclusão de conta que já existe), nunca entra no
  `CycleReadingComposer` sem opt-in explícito por registro (mesmo padrão de
  `CycleReadingSourceOptions`).

### 3.6 Fases de entrega sugeridas

1. **MVP (registro + estações):** tabela, cartão, registro manual,
   conteúdo das 4 Estações Internas, cross-link com Enciclopédia.
2. **Sincronia lunar:** o insight Lua Vermelha/Branca (precisa de histórico
   — só faz sentido depois que existem dados reais de uso).
3. **Fase 2, opcional, só nativo:** importar de HealthKit/Health Connect.

---

## Fontes (checadas em set/2026 — reconferir antes de citar como definitivo)

- [Wild Witch Herbs — magia de sangue e oferendas](https://wildwitchherbs.com/menstrual-blood-earth-ritual/)
- [The Moon School — Red Witch](https://www.themoonschool.org/menstruation/red-witch-meaning/)
- [Nylon — Red Moon / White Moon](https://www.nylon.com/entertainment/red-moon-cycle-full-moon-period)
- [Yoga Goddess — período e fase lunar](https://yogagoddess.ca/should-your-period-land-on-the-full-moon-or-the-new-moon-to-be-in-sync-with-nature/)
- [Spells8 — Deusa Tripla](https://spells8.com/lessons/the-triple-goddess/)
- [Wild Moon Sacred Cycles — fases menstruais e arquétipos](https://wildmoonsacredcycles.com/2020/09/30/menstrual-phases-the-maiden/)
- [Mooncup — as 4 estações da menstruação](https://wearemooncup.com/blogs/the-bloody-bulletin/4-seasons-menstruation)
- [sobrief.com — resumo de Period Power (Maisie Hill)](https://sobrief.com/books/period-power)
- [Fierce Lynx Designs — cristais para cólica](https://fiercelynxdesigns.com/blogs/articles/crystals-for-period-cramps-ancient-healing-wisdom-for-modern-women)
- [Anima Mundi Herbals — rituais e ervas](https://animamundiherbals.com/blogs/blog/12-rituals-herbs-to-honor-your-bleed)
- [App Store — Lunari, Period & Moon Cycle](https://apps.apple.com/us/app/-/id6754945046)
- [Witch Way From Here — panorama de apps](https://witchwayfromhere.com/the-best-witchy-period-app-out-there/)
