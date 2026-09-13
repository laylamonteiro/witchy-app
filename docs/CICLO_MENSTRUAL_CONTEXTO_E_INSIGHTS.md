# Ciclo Menstrual: contexto nos registros e insights futuros

Este documento existe por causa de duas decisões de NÃO implementar agora, e
para que a próxima pessoa não precise redescobrir por quê.

## 1. O que foi implementado

- **Saberes do Sangue**: área de conhecimento com quatro seções, quinze
  verbetes e cinco práticas, toda na camada de conteúdo
  (`lib/features/menstrual_cycle/data/data_sources/blood_lore_content*.dart`),
  em pt/en/es, com etiqueta editorial por verbete.
- **Práticas para este momento**: atalhos contextuais na página do Ciclo que
  abrem **as ferramentas que já existem** — escrita livre do Diário, Diário de
  Sonhos, Oráculo, criador de sigilos — mais a seção de práticas desta área.
  Quem sabe navegar é `MenstrualShortcuts`, o único ponto do módulo que conhece
  rotas de fora dele.
- **A Lua e você** ganhou a leitura do começo mais recente (fase + a
  correspondência que a magia lunar associa a ela + a frase que separa as duas
  rodas) e a contagem de Luas dos começos recentes
  (`LunarComparison.phaseTally`).
- **O consentimento encurtou, sem deixar de ser explícito.** Isto é dado de
  saúde, e a LGPD (art. 5º, II) pede consentimento destacado — o aceite dos
  termos no cadastro não cobre. O que mudou foi a cerimônia: eram DOIS sins
  (registrar, e depois guardar na conta, em telas diferentes) e virou UM,
  dado na porta do Ciclo, que liga os dois. O interruptor para desligar mora
  em **Configurações → Privacidade**, e desligar lá **também apaga a cópia
  que já subiu** — era um botão solto, que ficava à vista mesmo com o envio
  desligado, e virou a outra metade do mesmo gesto.
- **A roda do mês deixou de ser Premium.** As duas visões do mês, calendário
  e roda, são do plano gratuito. O `MenstrualAccess` não conhece mais plano
  nenhum.
- **O ciclo perdeu os botões próprios de apagar.** Apagar o registro deste
  aparelho é o mesmo gesto que apaga o resto: "Limpar Dados Locais", em
  Privacidade, já leva os dias e as páginas-espelho deles no Grimório.

## 2. O que ficou PREPARADO e não implementado

### 2.1 Metadados de contexto nos registros de outras ferramentas

A ideia é que uma entrada criada a partir do Ciclo pudesse carregar, de forma
**opcional**, algo como `menstrualCycleDay`, `menstrualPhase`, `moonPhase` e
`origin = menstrualCycle`.

**Por que não foi feito agora.** A arquitetura atual não comporta isso de
maneira limpa, e forçá-la sairia caro para o que a funcionalidade ganha:

- `FreeWritingModel`, `DreamModel`, e os modelos de tiragem **não têm campo de
  metadados livre**. Cada um é uma tabela com colunas fixas em
  `DatabaseHelper`, replicada no Supabase e coberta pelo funil de
  sincronização. Acrescentar um campo significa: migração de schema local,
  coluna nova no servidor, mapeamento em `toMap`/`fromMap`, revisão do
  `sync_coverage_test` e do `nenhuma_tabela_esquecida_test`;
- `FreeWritingModel.source` **não serve** para isso. Ele diz o QUE a entrada é
  (reflexão livre, lição, leitura, espelho do ciclo), e a regra desta
  funcionalidade é a oposta: uma entrada escrita a partir do Ciclo tem de
  continuar sendo uma reflexão **normal** do Diário. Usar `source` a
  transformaria em outro tipo, tirando-a do fluxo de sempre;
- o dado seria **dado de saúde derivado**. `menstrualPhase` e
  `menstrualCycleDay` num sonho contam, para quem lesse a linha, que aquela
  pessoa estava menstruando naquele dia. O registro do ciclo tem um consentimento
  próprio e uma promessa própria (`FreeWritingSource.neverLeavesDevice`); o
  sonho não tem nenhum dos dois e **sobe para a nuvem**. Implementar o
  contexto sem responder a isso vazaria pela porta de trás o que o módulo
  inteiro foi desenhado para não vazar.

**O que já está pronto para quando isso for feito.** O cálculo do contexto é
uma função pura do domínio, sem tela e sem provider:
`MenstrualMoment.of(today:, history:)` devolve o dia, a fase lunar e se houve
sangue marcado. Quem for implementar a associação tem a fonte do contexto
resolvida; o que falta é a decisão de produto sobre consentimento e o custo de
schema.

### 2.2 Insights a partir dos registros dela

O objetivo futuro é dizer coisas como:

> "Você registrou 7 sonhos durante seus últimos 4 períodos."
> "Você realizou tiragens em 3 dos últimos 5 ciclos."

**O que já existe.** A parte lunar já é real e já está na tela:
`LunarComparison.report` devolve a linha do tempo dos começos, o resumo dos
ciclos completos e `phaseTally` — "3 dos seus últimos 5 começos aconteceram sob
a Lua Crescente". Tudo derivado **exclusivamente** do que ela marcou, e nulo
quando não há histórico suficiente: o app não inventa dado que não existe.

**O que falta.** Cruzar os períodos dela com sonhos e tiragens exige ler outras
tabelas a partir do módulo menstrual. Isso é um acoplamento novo, e depende da
mesma decisão de consentimento do item anterior — ler o Diário de Sonhos para
contar quantos sonhos caíram em dias de sangue é derivar informação sobre o
ciclo a partir de dados que não têm esse consentimento.

**A decisão arquitetural que deixa isso aberto.** Nada no que foi feito agora
fecha esse caminho:

- os períodos saem de `LunarComparison.startsOf`, que já sabe recortar
  intervalos a partir das marcas;
- o contexto do dia sai de `MenstrualMoment`, puro e testável;
- nenhuma tela calcula nada por conta própria — todas leem o domínio.

Um insight futuro é uma função nova no domínio, uma leitura a mais no card e
uma decisão de consentimento. Não é uma refatoração.

## 3. Regras atuais preservadas de propósito

Estas pareceram estranhas durante a implementação e foram mantidas porque são
regras de negócio existentes, não defeitos:

- **nada nesta área é Premium** — calendário, roda, "A Lua e você" e
  "Práticas para este momento" são de todo mundo, por decisão da dona (está
  escrito em `MenstrualAccess`). Nenhuma delas é resultado calculado a partir
  do histórico: o que aparece é o que ela marcou;
- **a área só é oferecida no feminino e no neutro** (`MenstrualAccess.isOffered`);
- **cada dia registrado vira uma página-espelho no Grimório**, escrita e
  apagada pelo repositório, e essa página **nunca sai do aparelho**;
- **escape nunca vira começo** — só a marca "começou" abre um ciclo;
- **a lápide de um dia apagado é descartada nos dois sentidos do interruptor
  de nuvem**, para que uma data que ela apagou não saia daqui por causa de um
  gesto que não era sobre isso — o mesmo par de linhas roda agora também no
  sim da porta, que é onde o envio passa a valer.
