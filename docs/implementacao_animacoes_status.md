# Implementação das animações — Tarot manual

Iniciada em 09/09/2026, a partir da `main` em
`69dbc61c7d5d7a40c1dc5d1dc7aff6972ed2b880`.
Especificação de produto: [plano completo](plano_implementacao_animacoes.md).

Atualizada com a `main` em `2968ed8ca5290337baa10fa1e1c26b20c0348b7b`,
incluindo o novo salvamento automático de leituras em Meus Registros. A carta
do dia manual também cria/atualiza essa página, com o mesmo ID do resultado e
o dia original da sessão; a cópia do acervo segue o gravador best-effort da main.

## Escopo desta branch

Esta entrega cobre a seleção manual de 1, 3 e 5 cartas de P03, com a
infraestrutura mínima de P01/P02. Os demais pacotes continuam no plano.

- **Carta do dia:** leque com acesso às 78 posições. Arrastar horizontalmente
  explora sem selecionar; toque, retirada para cima, botão ou teclado confirmam
  a carta correspondente àquela posição. As faces permanecem ocultas durante
  a escolha. Apenas uma janela do leque é renderizada.
- **Ajuste visual de 10/09:** contornos sobre o verso separam as cartas
  sobrepostas, com borda mais espessa na carta em foco. Removido o aviso de
  retomada abaixo do botão após o teste visual da Layla na web.
- **Versos de 10/09:** substituído o padrão claro por arte vetorial na paleta
  ativa do app: superfície, acento principal e detalhes dourados. Lua, sol,
  estrela, olho, cristal e ramo se alternam pelas 78 posições (13 de cada),
  com desenhos no centro e nos cantos visíveis na sobreposição. A sequência
  acompanha a posição original da sessão, inclusive na retomada e na virada
  da carta escolhida; não depende da identidade ou orientação da frente.
- **Três cartas e cruz de cinco:** cada escolha preenche sua posição e sai
  do leque. Os versos mantêm seus símbolos originais ao fechar os espaços;
  as faces só aparecem depois de completar e confirmar a mesa. Resultado
  em linha de três ou cruz (Tendência acima, Conselho/Situação/Desafio no
  meio, Raiz abaixo). A entrada de cada carta usa movimento reduzido quando
  solicitado, e não há pausa artificial antes de revelar.
- **Transição para a revelação:** nas três tiragens, o leque permanece aberto
  enquanto a mesa é preparada, incluindo a leitura salva e o carregamento das
  imagens. O retorno já encontra os versos escolhidos, sem um quadro com o menu
  de tiragens; a virada começa após a saída da seleção. Os controles ficam
  bloqueados até terminar essa saída.
- **Retomada:** a ordem do baralho, as orientações e a pergunta ficam em SQLite
  antes de abrir a superfície. Reabrir a mesma pergunta no mesmo dia restaura a
  sessão. Se já existe uma carta do dia legada, ela é adotada, sem nova escolha.
- **Confirmação:** primeiro persiste a escolha, depois grava resultado, consumo,
  memória da pergunta e vínculo da sessão em uma transação. Falha no resultado
  preserva a escolha para retry; confirmação duplicada não cobra outra vez.
- **Dia e conta:** a sessão conserva o dia em que começou, inclusive se for
  concluída depois da meia-noite. Uma nova consulta começa no dia atual. Troca
  de conta recria a tela de Tarot e fecha a seleção da conta anterior.
- **Motion:** usa `GrimoireMotion`, `TarotCardBack` e `TarotFlipCard` existentes.
  `ToolSceneFrame` pausa tickers fora da rota ativa ou em segundo plano.
  Movimento reduzido vai ao estado final. Sem novas dependências ou assets.
- **Acessibilidade:** rótulos de posição, botões alternativos, setas/Home/End e
  Enter/espaço, texto ampliado e conteúdo rolável. Traduções nos quatro ARBs.

## Runas manuais (P04)

Entregue em 10/09, sobre a mesma infraestrutura de sessões do Tarot.

- **Tecido de pedras:** as 24 runas ficam viradas para baixo em quatro
  fileiras de seis, cada uma no lugar sorteado ao preparar a sessão. Toque,
  Enter/espaço, setas (inclusive entre fileiras), Home/End e o botão
  “Escolher esta pedra” confirmam a pedra em foco; segurar e puxar para cima
  é a alternativa por gesto, e soltar cedo ou fora do tecido devolve a pedra.
  Pedras escolhidas deixam o lugar vazio, sem reembaralhar as demais. A
  árvore de acessibilidade descreve “Pedra N de M”, nunca a identidade.
- **Mesas:** uma pedra; linha de três; cruz nórdica (Resultado acima,
  Passado/Situação/Futuro no meio, Desafio abaixo); nove mundos em 3×3.
  A mesma disposição serve à escolha (versos) e ao resultado (glifos).
- **Sessão:** `selection_sessions` com `tool = 'runes'`, sem migração nova.
  Identidade e orientação (50% invertida, como antes) ficam fixas antes de
  abrir o tecido; a animação nunca sorteia. Cada escolha parcial é gravada;
  a última confirma resultado (`rune_readings`, com `session_id` dentro de
  `reading_data`), consumo e vínculo em uma transação. Falha na gravação
  conserva as pedras para retry; confirmação repetida não cobra outra vez.
- **Cota:** categoria própria `runes` no ledger `usage_balances`/
  `usage_operations`, importando o contador antigo uma vez por conta/dia.
  `AuthProvider.refreshRuneUsage` espelha o saldo em preferências;
  `incrementRuneReadings` passa a gravar no ledger. Free conserva uma mesa
  por tiragem/pergunta no dia e pode revisitá-la sem consumo; Premium usa
  `isPremiumEffective` e só inicia outra mesa pela ação explícita “Nova
  Leitura”. Anúncio apenas numa mesa recém-confirmada, antes da revelação.
- **Revelação:** o tecido permanece à frente enquanto a mesa é preparada;
  as pedras viram no lugar (`TarotFlipCard`, passo de até 90 ms, teto de
  1,2 s) e só depois os significados entram. Tocar na mesa antecipa o texto;
  tocar numa pedra destaca e rola até a interpretação correspondente.
  Movimento reduzido mostra glifos e texto de imediato. A interpretação do
  Conselheiro fica gravada na leitura e volta na revisita.
- **Conta e retomada:** a tela é recriada por `user_id`; sair no meio
  preserva o rascunho (inclusive após a meia-noite, no dia original).
  Pergunta vazia continua gravada com o rótulo “Sem pergunta” do idioma
  ativo, como antes. Nome e glifo são invariantes; descrição e palavras-chave
  acompanham o idioma atual ao reabrir.
- **Verificação:** `rune_selection_repository_test.dart` (1/3/5/9 pedras,
  comandos concorrentes, rollback, Free/Premium, contador legado, cota
  alterada durante a escolha, meia-noite, pergunta vazia, isolamento de
  conta); `rune_selection_surface_test.dart` (toque, lacunas, teclado por
  fileiras, levantar/cancelar, escolha travada, semântica sem identidade,
  movimento reduzido e texto ampliado); `rune_reading_flow_test.dart`
  (nove pedras do tecido à revelação, retomada com três escolhas, acervo,
  revisita sem nova leitura, “Nova Leitura” no Premium e pedra única sob
  movimento reduzido). A galeria `motion_gallery.dart` inclui pedras e tecido.
  Analyze e testes rodam no CI; este ambiente não tem Flutter.

## Dados e compatibilidade

O schema local sobe de 23 para 24. As tabelas novas são `selection_sessions`,
`tarot_day_state`, `usage_balances` e `usage_operations`. Instalação nova e
migração usam a mesma definição. Exportação e limpeza local incluem as tabelas;
sessões e memória da pergunta participam da adoção de conteúdo anônimo.

O registro final continua em `tarot_readings` e usa a sincronização existente.
O vínculo `session_id` fica dentro de `reading_data`; não há coluna remota nova.
Rascunhos e ledger de uso são locais. Esta entrega **não oferece unicidade
global entre dois aparelhos offline**, nem sincroniza o leque em andamento.
As cotas continuam vinculadas à identidade autenticada original.

A política vigente está preservada: a primeira pergunta Free consome um uso
da categoria compartilhada Tarot/Oráculo; rever uma consulta concluída não
consome. A pergunta lembrada conserva a regra de reaproveitamento existente.
Premium usa `isPremiumEffective`. O ledger importa o contador antigo uma única
vez por conta/dia, revalida a cota na confirmação e restaura o espelho do
`AuthProvider` antes de consultas do Tarot/Oráculo.

Três cartas e cruz reutilizam `selection_sessions`, sem nova migração. Cada
escolha parcial é persistida sem consumir; o conjunto completo confirma
resultado, consumo e vínculo em uma transação. Um comando atrasado não
preenche outra posição. Falha na confirmação conserva todas as cartas para
retry e reinício do app. A consulta conserva seu dia e data originais.

Reabrir uma tiragem restaura a sessão/resultado mais recente da pergunta.
Rascunhos podem atravessar a meia-noite. Free conserva a regra de uma mesa
por tipo/pergunta do dia; Premium pode iniciar outra consulta pela ação
explícita “Nova tiragem”. Resultados antigos são adotados com orientação,
interpretação e data preservadas. Anúncios só são elegíveis depois de uma
confirmação nova e antes da revelação, respeitando a política existente.
As assinaturas das três tiragens passam a identificar a sessão, permitindo
consultas distintas com as mesmas cartas. Runas já usam sessões (P04);
o Oráculo ainda aguarda a migração de seu fluxo.

## Verificação

- `tarot_spread_repository_test.dart`: escolhas parciais e ordenadas, comandos
  concorrentes, rollback, Free/Premium, mudança de acesso, cotas compartilhadas,
  meia-noite e adoção de resultados legados de três e cinco cartas.
- `tarot_spread_flow_test.dart`: dois fluxos completos em largura de celular;
  extremos do leque, reinício após duas escolhas, símbolos preservados,
  geometria da cruz, fonte a 150%, acervo, revisita e nova consulta explícita
  no Premium. Preparação retardada e quadros da transição também são verificados:
  o menu não reaparece e as faces não surgem sob o leque.

- `daily_tarot_repository_test.dart`: sessão estável, 78 IDs sem repetição,
  confirmação concorrente, rollback, retomada, migração de cota/pergunta,
  cota consumida pelo Oráculo durante a escolha, Premium, virada do dia,
  isolamento de conta e adoção de resultados antigos.
- `daily_tarot_migration_test.dart`: banco real v23 preserva registros ao migrar.
- `daily_tarot_selection_page_test.dart`: toque duplo, bloqueio de voltar
  durante a gravação, retorno após sucesso, retry e troca de conta na rota.
- `daily_tarot_flow_test.dart`: fluxo completo na tela de Tarot, incluindo
  escolha, preparação retardada e transição sem retorno ao menu, revelação,
  cópia automática em Meus Registros e reabertura sem duplicar.
- `card_selection_surface_test.dart`: toque, navegação horizontal sem sorteio,
  retirada/cancelamento, extremos por teclado, escolha travada, semântica,
  fonte ampliada e movimento reduzido.
- Gates locais disponíveis: paridade ARB, órfãs ARB, scanner de português e
  `git diff --check`. Analyze e testes Flutter rodam no CI com o SDK pinado
  pelo repositório; o ambiente de edição não tem Flutter instalado.

Alvo de demonstração isolado, sem banco, conta, IA, anúncio ou consumo:

```sh
flutter run -t lib/dev/motion_gallery.dart
```

Validação visual em Android e web e medição de frames em aparelho continuam
pendentes. Os testes automatizados não substituem essa avaliação.

## Continuação do lote

1. P05–P14: Oráculo, Conselheiro e demais ações/rituais do plano.
2. P16/P17: registro menstrual manual Free; dados derivados e análises Premium.
3. P18: registros menstruais autorizados entram na análise completa do ciclo.
4. P15: integração e validação final do lote.

As decisões mais recentes sobre menstruação estão mantidas no plano:
registro, leitura dos dados inseridos, edição, exclusão e exportação Free;
análises, estações estimadas e cruzamentos Premium; consentimento específico
para participar da análise completa. Health/Flo é uma evolução secundária.
