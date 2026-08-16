# Brainstorm — "Análise Mágica do Período" (compra avulsa)

> Produto de venda separada (one-time purchase, fora do Premium): a pessoa
> compra, quando quiser, uma análise mágica profunda da sua semana ou do seu
> mês, gerada a partir de TUDO que ela registrou no app naquele período +
> mapa astral + trânsitos do céu no período.

---

## 1. O conceito em uma frase

**"O oráculo leu o seu grimório."** Todo mundo escreve no app — sonhos,
gratidões, desejos, ritos, leituras — mas ninguém relê. A análise costura
esses registros em uma narrativa única do momento de vida, com linguagem
mágica, sugestões de rituais e o céu (natal + trânsitos) como pano de fundo.

Nomes candidatos:
- **"Leitura do Ciclo"** (semana = ciclo curto, mês = ciclo lunar completo)
- "Espelho Mágico do Mês"
- "Balanço do Grimório"
- "Retrato do Momento"

"Leitura do Ciclo" conversa bem com o vocabulário do app (ritos, ciclos
lunares, trilhas) e escala para os dois períodos: *Leitura da Semana* /
*Leitura da Lunação*.

## 2. Que dados já temos para alimentar a análise

Tudo abaixo já existe no sqflite local (e espelhado no Supabase via
`DataSyncService`) — nenhuma coleta nova é necessária:

| Fonte (tabela) | O que conta sobre a pessoa |
|---|---|
| `dreams` | temas recorrentes de sonho, carga emocional do período |
| `gratitudes` | para onde a atenção positiva está indo |
| `desires` | o que ela está tentando manifestar (incl. sigilos ligados) |
| `affirmations` (favoritas) | as frases que ela escolheu guardar = autoimagem desejada |
| `free_writings` | escrita livre + **leituras arquivadas de tarot/runas/oráculo/pêndulo** (`ReadingArchiveComposer`) |
| `rune_readings`, `oracle_readings`, `pendulum_consultations` | perguntas feitas ao oráculo = as dúvidas reais do período |
| `spells` + `ritual_logs` + `guided_ritual_logs` | prática mágica efetiva: o que ela fez, com que frequência |
| `daily_checkins` | constância (streak), quais ritos ela prefere |
| `daily_magical_weather` | o "clima" que o app já narrou dia a dia |
| `learning_progress` | em que trilha ela está estudando, nível/XP (Aprendiz → Guardião) |
| `birth_charts` + `magical_profiles` | mapa natal completo (sweph), perfil mágico gerado |
| `user_encyclopedia_entries` | os saberes que ela mesma está catalogando |

E o céu do período: com o `sweph` já embarcado (há `transit_model.dart`),
dá para calcular **trânsitos relevantes sobre o mapa natal no intervalo
analisado** (ex.: "Marte transitou sua casa 10 nesta semana") e as fases da
lua do período (`lunar`) — sem chamada externa.

## 3. O que a análise entrega (estrutura do relatório)

Um "capítulo especial" do grimório, em seções:

1. **Abertura — o retrato do momento.** Síntese narrativa: "Sua semana foi
   de raiz e recolhimento…", amarrando volume e tom dos registros.
2. **Os fios que se repetem.** Temas recorrentes cruzando fontes: o sonho
   com água + a pergunta ao pêndulo sobre mudança + o desejo de casa nova
   = um único fio narrativo. (É aqui que mora o "uau".)
3. **O céu sobre você.** Trânsitos do período sobre o mapa natal + fase
   lunar dominante, explicando o *porquê* astrológico do clima vivido.
   Respeitar `unknownBirthTime` (sem casas/ascendente nesse caso).
4. **Sua prática.** Balanço da magia feita: ritos, constância, trilha em
   estudo, nível — com reconhecimento ("você encadernou a trilha de Magia
   Verde em plena lua crescente…").
5. **Rituais sugeridos para o próximo ciclo.** 2–3 rituais escolhidos em
   função do que foi lido (e das próximas fases da lua), linkando para os
   rituais guiados do app.
6. **Uma afirmação para levar.** Gerada sob medida para o período — que a
   pessoa pode favoritar e **compartilhar como imagem** (reusa o
   `ShareCard` novo → marketing orgânico do produto).
7. **Selo do ciclo.** Um cartão-resumo visual compartilhável (período,
   emoji do nível, 3 palavras-chave do ciclo) — de novo `ShareCard`.

O relatório vira um registro permanente (proposta: salvar como
`free_writings` com `source` próprio, ex. `leituraDoCiclo`) — a pessoa
paga uma vez e a análise fica no acervo dela para sempre, sincronizada.

### O que MAIS os dados permitem dizer (ideias além do óbvio)

- **Correlação lua × comportamento**: "seus sonhos mais intensos deste mês
  caíram na lua cheia" (data dos registros × fase lunar é cálculo local).
- **Evolução da linguagem**: comparar as palavras dos desejos no início e
  no fim do período (de "quero sair de" para "estou construindo").
- **Perguntas sem resposta**: temas consultados no oráculo repetidas vezes
  → sugerir a trilha/ritual que trabalha exatamente aquilo.
- **Dia de poder pessoal**: o dia do período com mais registros/ritos
  completos, batizado como o "dia de poder" do ciclo.
- **Aniversário lunar / retorno solar** quando cair dentro do período.
- **Comparação com o ciclo anterior** (se a pessoa já comprou antes):
  "em relação à sua última Leitura, a gratidão migrou do trabalho para os
  afetos" — cria recompra natural.

## 4. Semanal × mensal (e preço)

| | Leitura da Semana | Leitura da Lunação (mês) |
|---|---|---|
| Janela | últimos 7 dias | ~30 dias / lunação completa |
| Profundidade | 4 seções, mais direta | 7 seções + comparativo de ciclos |
| Trânsitos | só os exatos no período | mapa do mês + próximos aportes |
| Preço âncora (BR) | R$ 9,90 | R$ 19,90–24,90 |

A diferença de preço se sustenta na diferença visível de profundidade (o
mensal contém tudo do semanal e mais). Regra honesta de dados mínimos: se o
período tiver menos de N registros (ex. 5), avisar ANTES da compra que a
leitura sairá rasa — confiança vale mais que uma venda.

## 5. Monetização — como encaixar no RevenueCat atual

Hoje: entitlement único `Grimorio de Bolso Pro` (monthly/yearly/lifetime).
A análise avulsa NÃO entra nesse entitlement — é **produto consumível**:

- Novos produtos nas lojas: `leitura_ciclo_semana` e `leitura_ciclo_mes`
  (consumable no App Store / consumível no Play).
- Compra via `Purchases.purchaseStoreProduct(...)` no `PaymentService`;
  como consumível não gera entitlement, o "crédito" é registrado pelo
  app: gravar a compra (transaction id, tipo, período coberto) em tabela
  local nova (ex. `cycle_readings`) sincronizada no Supabase — a própria
  análise gerada é o recibo permanente.
- **Premium continua tendo valor**: assinante ganha desconto (oferta
  RevenueCat separada) ou 1 leitura mensal inclusa — vira argumento de
  upgrade nos dois sentidos (quem compra avulso 2× descobre que o anual
  compensa; quem é Pro sente o benefício).
- Gate de código: fora do `FeatureAccessService` de limites — é compra
  pontual, não feature limitada.

Pontos de oferta no app (sem poluir):
- Card discreto no "Seu Dia" no fim da semana/lunação ("Sua semana rendeu
  23 registros. Quer a leitura dela?") — o número concreto é o gancho.
- Na Evolução Mágica (`MagicalProgressPage`), aba Estatísticas.
- Após encadernar uma trilha ou fechar um streak longo (momento de brilho).

## 6. Pipeline técnico (MVP)

1. **Agregador local** (novo serviço, ex. `CycleReadingComposer`): consulta
   as tabelas do período, monta um JSON compacto e **anonimizado no
   possível** (títulos/temas/contagens + trechos curtos, não os diários
   inteiros) — controla tokens e exposição de dados.
2. **Céu do período**: trânsitos (sweph) + fases da lua calculados no
   aparelho e anexados ao JSON como fatos prontos ("Vênus trígono Sol natal
   dia 12") — a IA narra, não calcula (mesma filosofia dos docs de
   acuracidade do mapa astral).
3. **Geração**: `AIService` (Groq→Gemini com fallback) com prompt novo em
   `lib/core/ai/prompts/` nos 3 idiomas, saída em Markdown seccionado
   (render já existe via `flutter_markdown`).
   - Atenção: a chave Groq é compartilhada e o relatório mensal é longo —
     gerar seção a seção (chamadas menores) e considerar chave/rota
     dedicada para o produto pago, já que aqui há receita direta por
     chamada (um 429 num produto pago é inaceitável; ver
     `AiRateLimitException`).
4. **Entrega**: página própria com o relatório + salvar em `free_writings`
   + cartões `ShareCard` (afirmação do ciclo e selo do ciclo).
5. **Regeneração**: compra dá direito a regenerar a MESMA janela (ex. 2×)
   se a pessoa não gostar do tom — sem virar gerador infinito.

Esforço estimado de MVP: agregador + prompt + página de relatório +
1 produto consumível (começar SÓ pelo mensal, que tem margem melhor e mais
matéria-prima; o semanal entra depois como porta de entrada barata).

## 7. Cuidados

- **Sensibilidade**: sonhos e escrita livre são íntimos. Deixar claro na
  tela de compra o que é enviado para análise; oferecer opção de excluir
  fontes (ex. "não usar meus sonhos").
- **Tom**: linguagem de acolhimento e autoconhecimento, nunca previsão
  determinista de saúde/dinheiro/relacionamento ("o céu sugere", "seus
  registros mostram").
- **Sem dados suficientes**: avisar antes de cobrar (ver §4).
- **Offline/erro**: a compra só é consumida quando o relatório é gerado e
  salvo com sucesso; em falha, tentar de novo sem nova cobrança.
- **Idioma**: gerar no idioma ativo do app (pt/en/es), como o resto.
