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

## Oráculo manual (P05)

Entregue em 10/09, com o seletor de cartas compartilhado do Tarot.

- **Seleção:** o mesmo leque (`CardSelectionSurface`, versos `TarotCardBack`)
  com as 44 cartas; mesas de 1, 3 e 5 posições (Segunda/Terça, Quarta,
  Quinta/Sexta, Fim de Semana e Foco) em `OracleSpreadBoard`, usada na
  escolha e no resultado. O Oráculo não tem pergunta.
- **Sessão e cota:** `selection_sessions` com `tool = 'oracle'`; cota na
  categoria compartilhada Tarot/Oráculo, revalidada na confirmação. Free
  conserva uma mesa por tiragem no dia e pode revisitá-la; Premium só inicia
  outra por “Nova Leitura”. Resultado em `oracle_readings` (com `session_id`
  e o conselho do Conselheiro dentro de `reading_data`), consumo e vínculo
  na mesma transação.
- **Arte:** `OracleArtRegistry` resolve os 44 IDs (ID desconhecido recebe a
  moldura comum). Sem assets ilustrados ainda: `OracleCardFace` desenha a
  moldura vetorial na paleta ativa com o emoji como figura e o nome renderizado
  pela UI; quando as frentes estáticas existirem, entram por `assetPath` com
  o mesmo fallback. As seis cenas iniciais (Vela acende, Caldeirão borbulha,
  Gato abre os olhos, Semente brota, Chave gira, Porta entreabre) são
  vetoriais, executam uma vez e só na carta em foco; as demais recebem a
  revelação comum. Movimento reduzido mostra o quadro final.
- **Revelação:** o leque fica à frente até a mesa estar pronta; as cartas
  viram no lugar (teto de 1,2 s); depois entram o palco com a carta em foco e
  os textos. Tocar na mesa antecipa; tocar numa carta a leva ao palco e
  destaca sua interpretação.
- **Descobertas (dados para P11):** tabela local `oracle_discoveries`
  (schema 25), uma linha por pessoa/carta com a primeira data e a leitura de
  origem, gravada só na confirmação; carta repetida não adiciona nada e nada
  gera XP. Ao preparar uma consulta, o histórico local de `oracle_readings`
  é adotado em silêncio (data mais antiga vence). A confirmação mostra uma
  linha discreta “Nova(s) carta(s) no seu Oráculo”; revisitas não a mostram.
  O álbum em si continua em P11; sync das descobertas fica para P15.
- **Verificação:** `oracle_selection_repository_test.dart` (1/3/5, comandos
  concorrentes, rollback sem descoberta, cota compartilhada com o Tarot,
  Premium, meia-noite, descobertas repetidas e adoção do histórico com linha
  corrompida), `oracle_art_registry_test.dart` (44 IDs, seis cenas nas cartas
  certas, 44 frentes em todos os progressos, cena única e movimento reduzido),
  `oracle_reading_flow_test.dart` (guia semanal do leque à revelação, retomada,
  descoberta, acervo, foco por toque, revisita e “Nova Leitura”; mensagem do
  dia sob movimento reduzido). `daily_tarot_migration_test.dart` passa a
  esperar o schema 25.

## Conselheiro Místico (P06)

Entregue em 10/09.

- **Estado da requisição separado da animação:** cada pergunta vira uma
  linha em `advisor_consultations` (schema 26): pendente antes da chamada,
  respondida ou falha depois. A bola de cristal vetorial (`CrystalBallView`)
  enevoa apenas enquanto a requisição real dura e cede espaço ao teclado;
  não há espera mínima nem typewriter. A resposta entra em parágrafos
  (`StaggeredParagraphs`, teto de 1,2 s) e está inteira na árvore desde o
  primeiro quadro; movimento reduzido mostra tudo de imediato.
- **Pergunta capturada:** o texto enviado vira citação acima da resposta e é
  exatamente o que a operação usou; o campo continua livre para outra
  pergunta. Falha mantém a pergunta e oferece “Tentar novamente”, que é uma
  nova consulta explícita. Uma resposta atrasada de outra consulta não
  substitui a atual; sair e voltar durante a espera reencontra a mesma
  requisição em voo e mostra a resposta quando ela chega. Uma consulta que
  ficou pendente num processo anterior aparece como falha; nada é reenviado
  ao reabrir a tela.
- **Guardar conselho:** origem `FreeWritingSource.advisor`, página com o
  mesmo ID da consulta (idempotente por resposta), título localizado e data
  da pergunta; a confirmação “Conselho guardado” só aparece após a gravação.
  “Meus Registros” ganha o selo e o filtro “Conselheiro”. A página não entra
  em `readings`/`autoRecorded`: não é leitura de adivinhação nem registro
  automático.
- **Cota e anúncio:** preservados (contador do Conselheiro em preferências,
  consumo só após resposta, anúncio antes de revelar). Troca de conta recria
  a tela.
- **Painel compacto para outras ferramentas:** o mesmo par (estado persistido
  + entrada em parágrafos) fica disponível para Tarot/Runas/Oráculo em P12/P13;
  nesta entrega eles conservam o card atual.
- **Verificação:** `advisor_consultation_repository_test.dart` (pendente →
  respondida/falha, resposta atrasada ignorada, abandono de pendentes,
  salvar idempotente com data da consulta, página apagada, isolamento de
  conta) e `mystic_advisor_page_test.dart` (resposta imediata inteira,
  guardar uma vez e restaurar, espera real que sobrevive a sair da tela,
  falha com retry explícito, pendente de processo anterior, teclado aberto).

## Progresso e marcos (P07)

Entregue em 10/09.

- **Uma avaliação por ação:** `ProgressCoordinator` (provider global) recebe
  cada gravação confirmada e produz um `ActionOutcome`: XP antes e depois
  pela fórmula existente (`LearningProvider.refreshPracticeXp`), nível
  identificado pelo limiar (nunca pelo título traduzido), marcos das
  jornadas alcançados pela primeira vez e fechamento do dia. Avaliações são
  serializadas por conta; nenhuma animação credita pontos.
- **Marcos estáveis:** `progress_milestones` (schema 27) guarda cada etapa
  de jornada por pessoa, com a primeira data e a ação de origem. Uma contagem
  que cai e volta não concede de novo. Ao entrar na conta, as etapas já
  alcançadas pelo histórico são adotadas em silêncio (origem nula), sem
  apresentação. `JourneyStatsRepository` concentra as contagens que a tela
  de Jornadas e a detecção usam, agora com `tarot_readings` no total de
  leituras.
- **Dia completo fora da UI:** `DayCompletionService` avalia os três
  requisitos (gratidão e sonho de hoje, mais o rito em destaque) a partir do
  banco e sela o dia pelo mesmo `completeRite` idempotente. O card de ritos
  conserva sua detecção; P09 o faz consumir o evento comum.
- **Feedback único acima do app:** `ActionFeedbackHost` fica no `builder`
  do `MaterialApp`, acima do router. Mostra uma composição por ação
  (confirmação, “+XP”, marcos, novo título, dia completo), uma por vez, com
  toque ou tempo para sair; uma confirmação que chega com a rota fechando
  ainda aparece. Só resultados desta sessão são apresentados; carregar
  histórico ou sincronizar muda números em silêncio. Celebrações (marco,
  nível, dia) pedem a reação do gatinho por `MascotProvider.react`, que já
  respeita arraste e ocultação.
- **Primeira ligação:** salvar um sonho novo aguarda a persistência,
  registra a ação e só então fecha o formulário; editar não conta. As demais
  criações, ritos e rituais entram em P08/P09.
- **Verificação:** `progress_coordinator_test.dart` (décimo sonho gera o
  marco uma vez; repetir, recarregar e editar não repetem; adoção silenciosa;
  contagem perdida e recuperada; nível por limiar; ações concorrentes;
  tarô no total de leituras; dia completo pelo serviço com bônus certo) e
  `action_feedback_host_test.dart` (uma composição com XP, marcos, nível e
  dia; fila e saída automática; host sem coordenador).

## Lições e trilhas (P08)

Entregue em 10/09.

- **Uma cena por lição:** `LessonCelebrationCard` substitui o diálogo
  anterior. A página selada recebe o selo de cera vetorial (`WaxSealStamp`:
  desce, assenta e brilha uma vez); a última página de uma trilha fecha o
  livro (`BoundBookCover`, com as folhas se juntando e a capa descendo). O
  XP mostrado é o de `LessonReward` (25 por página e o bônus de 100 uma vez);
  o novo título, os marcos das jornadas e o dia completo avaliados pelo
  `ProgressCoordinator` (com `present: false`) entram na mesma composição,
  sem outra caixa. Movimento reduzido mostra o estado final.
- **Capas por trilha:** `TrailCoverRegistry` associa o acento da capa ao ID
  da trilha; título e emblema são renderizados pela UI no idioma atual.
- **Estante:** o Grimório Vivo mostra os volumes encadernados numa fileira
  derivada do progresso existente (só aparece quando há algum), e o card de
  trilha concluída usa o mesmo livro em miniatura.
- **Verificação:** `lesson_celebration_card_test.dart` (página selada com
  selo e XP da lição; trilha encadernada com livro, bônus contado uma vez,
  nível, marcos e dia na mesma cena; capas distintas por trilha e selo
  reproduzível).

## Rituais, diário, desejos e mascote (P09)

Entregue em 10/09.

- **Gravações aguardadas:** sonho, gratidão, desejo, afirmação e feitiço
  novos esperam a persistência (`addX` devolve se gravou), registram a ação
  pelo `ActionRecorder` (que lê os providers antes de qualquer `await` e não
  quebra sem eles) e só então fecham o formulário; falha mantém a tela e
  avisa. Editar não conta como criação.
- **Desejos:** a transição para `manifested` recebe o selo “Desejo realizado”
  e para `released` o fio de luz “liberado ao vento”, ambos na composição
  comum (`desireTransitionOrigin`); editar o título de um desejo já realizado
  não repete a celebração; as etapas de manifestação das jornadas entram
  pelo mesmo caminho.
- **Ritual guiado:** `RitualCircle` substitui a barra: um arco por passo,
  aceso ao concluir; o último fecha o círculo com um brilho. A conclusão só é
  anunciada depois do sucesso de `logCompletion`; falha oferece “Tentar
  novamente” sem celebrar; a ocorrência da sessão é única mesmo desmarcando e
  marcando de novo. O registro entra na jornada e na composição comum (XP,
  marcos).
- **Dia completo:** quando o fechamento é apresentado pela composição comum,
  `DailyCheckinProvider.markDayCelebrationShown` avisa o card de ritos, que
  assenta o selo em silêncio em vez de celebrar de novo. O card conserva sua
  própria detecção para o caso em que ele mesmo sela o dia.
- **Mascote:** as celebrações (marco, nível, dia) pedem `MascotProvider.react`,
  que já ignora arraste e ocultação. O tour continua com prioridade por
  construção: o overlay do tour cobre a tela, e a reação é curta.
- **Autosave:** nenhuma cena por tecla; reflexões livres continuam fora do
  fluxo de resultados.
- **Verificação:** `desire_transition_test.dart` e
  `ritual_player_page_test.dart` (círculo acompanha os passos, gravação
  falha → retry sem anúncio, sucesso → conclusão anunciada uma vez;
  desmarcar/marcar não regrava).

## Dados e compatibilidade

O schema local sobe de 23 para 24 (sessões e ledger), 25 (descobertas do
Oráculo), 26 (consultas do Conselheiro) e 27 (marcos). As tabelas novas são
`selection_sessions`, `tarot_day_state`, `usage_balances`, `usage_operations`,
`oracle_discoveries`, `advisor_consultations` e `progress_milestones`. Instalação nova e
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
consultas distintas com as mesmas cartas. Runas (P04) e Oráculo (P05) já
usam sessões.

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

1. P10–P14: sigilos, álbum do Oráculo/quiz/arquétipos, fluxos com foto, numerologia/pêndulo e navegação.
2. P16/P17: registro menstrual manual Free; dados derivados e análises Premium.
3. P18: registros menstruais autorizados entram na análise completa do ciclo.
4. P15: integração e validação final do lote.

As decisões mais recentes sobre menstruação estão mantidas no plano:
registro, leitura dos dados inseridos, edição, exclusão e exportação Free;
análises, estações estimadas e cruzamentos Premium; consentimento específico
para participar da análise completa. Health/Flo é uma evolução secundária.
