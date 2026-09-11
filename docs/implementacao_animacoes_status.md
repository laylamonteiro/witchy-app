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

## Sigilos (P10)

Entregue em 10/09.

- **Traçado com progresso:** `SigilTrace` mede o percurso uma vez por
  intenção/tamanho e o reaproveita; `SigilDrawingPainter` ganhou `progress` e
  revela só um prefixo do caminho, com a ponta acesa enquanto anda e os pontos
  aparecendo à medida que são percorridos. `progress` igual a 1 é sempre o
  símbolo inteiro.
- **Mesmo resultado em qualquer velocidade:** a animação normal, o movimento
  reduzido (símbolo pronto no primeiro quadro) e a antecipação por toque
  terminam no mesmo desenho, porque todos usam os pontos que a regra da roda
  já calculava.
- **Reorganização das letras:** embaralhar e restaurar interpolam do arranjo
  anterior para o novo — cada letra desliza pelo caminho mais curto do seu
  próprio anel (`WitchWheelPainter.angleFor`) e o traço acompanha a geometria
  interpolada. Terminada a viagem, o arranjo antigo é solto e o percurso
  medido volta a ser reaproveitado.
- **Intenção → letras:** a etapa 2 mostra as letras normalizadas, dissipa as
  repetidas e deixa as restantes se aproximarem pelo próprio layout. Quem
  decide o que fica continua sendo `SigilWheel.textToSigilSequence`;
  `normalizedLetters` e `keptIndexes` só descrevem a regra para a tela.
- **Exportação sempre completa:** salvar na galeria e guardar no Diário de
  Desejos passam por `_settleForCapture()`, que leva o traço ao fim e espera
  um quadro antes de ler os pixels — nunca uma captura pela metade.
- **Quadro responsivo:** o desenho era fixo em 360 e estourava o cartão num
  telefone de 390dp; agora ele acompanha a largura disponível, e a roda e os
  pontos escalam juntos porque saem do tamanho real do canvas.
- **Salvamento:** “Finalizar” espera a gravação do sigilo e só então fecha a
  tela, registrando a ação pelo `ActionRecorder` (`ActionOrigin.sigil`); a
  confirmação aparece no receptor acima do roteador, mesmo com a tela já
  fechada. Guardar no Diário de Desejos confere se o desejo foi gravado,
  avisa quando não foi e registra a criação.
- **Verificação:** `sigil_trace_test.dart` (percurso medido e reaproveitado,
  prefixo, símbolo final estável, interpolação entre arranjos, intenção de
  uma letra, regra de repetição intacta) e `sigil_drawing_page_test.dart`
  (traçado até o fim, movimento reduzido, antecipação por toque, viagem das
  letras, gravação antes de sair, letras da etapa 2).

## Álbum do Oráculo, quiz e arquétipos (P11)

Entregue em 11/09.

- **Álbum das 44 cartas:** uma vaga por carta do catálogo. As que já
  apareceram numa tiragem confirmada abrem a face e guardam a data do
  primeiro encontro; as demais ficam de verso, sem entregar nome, mensagem
  nem emoji. Tocar numa carta aberta mostra mensagem, orientação e palavras.
- **Retrospectiva:** abrir o álbum roda o `backfill` silencioso das leituras
  que já existem no aparelho — nada é celebrado e nada rende XP. Uma carta
  repetida não muda a contagem, e o primeiro encontro conserva a data mais
  antiga mesmo quando a leitura mais nova é lida primeiro.
- **Constelação da sessão:** o resultado do teste desenha uma estrela por
  arquétipo que recebeu respostas, mais perto do centro quanto mais pontos,
  ligadas na ordem do catálogo, com halo no vencedor. A figura é
  determinística: vem da chave invariante (o emoji) e da contagem, sem
  sorteio, então as mesmas respostas dão sempre o mesmo céu.
- **Revelação do arquétipo:** o emoji e o nome entram uma vez, só na sessão
  que acabou de terminar. Um resultado guardado abre direto no estado final
  — e sem constelação, porque ela pertence à sessão respondida.
- **Guardar antes de revelar:** a última resposta grava o resultado e só
  então a tela muda; a data exibida é a que ficou no aparelho, e uma falha de
  gravação mostra o arquétipo sem inventar data. A pontuação é a mesma de
  sempre (um ponto por resposta, empate para quem chegou primeiro) e o
  progresso do teste continua fora do XP unificado.
- **Verificação:** `oracle_album_test.dart` (retrospectiva idempotente, data
  do primeiro encontro, álbum sem vazar carta fechada, álbum vazio) e
  `archetype_quiz_test.dart` (constelação determinística, estrela só para
  quem pontuou, gravação antes da revelação, resultado guardado abrindo
  direto).

## Foto e relato: Quiromancia, Sonhos e Natureza (P12)

Entregue em 11/09.

- **Falha visível, com retomada:** quiromancia e interpretação de sonho
  trocaram o aviso que some por um estado de falha na própria tela. A
  quiromancia guarda a foto já comprimida em memória e “Tentar de novo”
  reanalisa a MESMA foto — sem pedir outra, sem segunda compressão. O sonho
  conserva o relato escrito e tenta de novo com um toque.
- **Nada de sucesso falso:** a cota e o rito do dia só mudam quando a
  leitura chega; uma falha não conta leitura, não cumpre rito e não anuncia
  resultado. Desistir da foto não deixa rastro: nem análise em curso, nem
  erro, nem chamada de visão.
- **Superfície própria:** `PalmScanView` desenha a mão e as três linhas na
  paleta ativa, com uma faixa de luz que percorre a palma **apenas** enquanto
  a requisição real dura; com movimento reduzido a ilustração fica parada. O
  ticker é suspenso fora da tela.
- **Gates preservados:** acesso Premium, limite diário, limites de tamanho
  da imagem, compressão com correção de EXIF e descarte da foto continuam
  como estavam. A tela ganhou costuras de teste (`choosePhoto`,
  `analyzePalm`) que só os testes usam.
- **Verificação:** `palmistry_page_test.dart` (desistir da foto não muda
  nada; falha mostra o erro, guarda a foto e só uma retomada explícita
  reanalisa; a cota é gasta uma vez, quando a leitura chega; foto pequena é
  recusada antes de qualquer chamada; a varredura só dura o que a
  requisição durar).
- **Sonho guardado entra na jornada:** salvar a interpretação grava o sonho,
  confere a falha do provider e só então registra a ação pelo
  `ActionRecorder` — o mesmo caminho do diário, sem XP duplicado.
- **Guia da Natureza:** a revisão de candidatos pedida pelo pacote já existe
  em `add_entry_page.dart` e foi conferida: mais de um candidato pergunta em
  vez de escolher sozinho, um único já vem marcado, "nenhuma dessas" libera o
  campo manual e nenhum estado anuncia identificação que não houve. Sem
  mudança nesta entrega.

## Numerologia e pêndulo (P13)

Entregue em 11/09.

- **Números que chegam contando:** `NumberReveal` percorre o caminho até o
  valor **calculado** e para nele, nas duas telas de numerologia. A animação
  não decide nada: com movimento reduzido o número já aparece pronto, e um
  mestre (11, 22, 33) chega inteiro porque quem o preserva é
  `NumerologyCalculator.reduce`. A semântica anuncia sempre o valor final,
  mesmo enquanto a contagem anda.
- **Pêndulo fora da tela:** a assinatura do acelerômetro passou a depender
  também do `TickerMode`. Com outra rota por cima, o sensor para — antes só
  o segundo plano o desligava — e voltar para a tela religa sozinho. Movimento
  reduzido continua dispensando o sensor por completo, e o sorteio da
  resposta segue separado da inclinação: o efeito muda, a resposta não.
- **Verificação:** `number_reveal_test.dart` (a contagem termina no valor
  calculado, movimento reduzido mostra o resultado no primeiro quadro,
  mestres não são reduzidos pela animação, semântica anuncia o final) e
  `pendulo_fora_da_tela_test.dart` (rota coberta desliga o sensor, voltar
  religa, movimento reduzido nem assina).
- **Fora desta entrega:** unificar o painel de explicação de IA entre as
  ferramentas continua pendente — é refatoração de conteúdo, não de
  movimento, e não muda nenhum resultado.

## Ferramentas: feedback uniforme (P14, primeira parte)

Entregue em 11/09.

- **Uma falha, um cartão:** `RetryNotice` passou a ser o estado de erro do
  Conselheiro, da Quiromancia e da interpretação de sonho — o mesmo ícone, o
  mesmo espaçamento, a mesma região viva para leitores de tela e o mesmo
  convite de retomada. Cada ferramenta conserva a chave do seu botão, então
  nenhum fluxo mudou. Sem nada a repetir, a mensagem fica sem convite em vez
  de oferecer um botão que não faria nada.
- **Rótulos que dizem só o que importa:** o emblema do círculo de ritual é
  decoração e saiu da semântica; o círculo anuncia o progresso e nada mais.
- **Falta para fechar P14:** integrar as artes dos cards às cenas de
  destino, revisar tamanhos e hierarquia e percorrer as 12 entradas com
  retorno e re-toque de aba. É trabalho de tela, que pede aparelho: os
  testes automatizados não substituem essa avaliação.

## Ferramentas: identidade das entradas (P14, segunda parte)

Entregue em 11/09.

- **Um emblema por ferramenta:** `ToolId` nomeia as doze e `ToolIdentity`
  guarda o símbolo de cada uma. O card de entrada e o cabeçalho da tela
  passam a desenhar o MESMO símbolo, pelo mesmo caminho — antes o card tinha
  um emoji e a tela abria sem nada que a ligasse a ele.
- **A arte do card continua na cena:** o emblema voa do card para o
  cabeçalho ao abrir a ferramenta (`Hero`), e volta ao fechar. A etiqueta do
  voo vem da identidade, nunca do nome traduzido, então trocar de idioma não
  quebra o par. O Guia da Natureza abre um seletor antes da ficha: lá o
  emblema aparece parado, porque não há de onde voar.
- **Título que encolhe, emblema que fica:** o cabeçalho mantém o
  `ResponsiveAppBarTitle`, agora ao lado do emblema; um nome comprido diminui
  em vez de empurrar o símbolo para fora.
- **Navegação preservada:** as entradas continuam em `MaterialPageRoute`, com
  a transição e o gesto de voltar da plataforma. Nada de rota customizada só
  para animar.
- **Verificação:** `tool_identity_test.dart` (doze ferramentas, símbolos e
  etiquetas distintos, símbolo igual nos três idiomas, o voo do card ao
  cabeçalho e de volta, título comprido sem estourar).

## Ciclo menstrual: registro próprio (P16, primeira parte)

Entregue em 11/09.

- **Tabela própria (v28):** `menstrual_days`, por conta e por dia, guarda a
  marca que a pessoa escolheu (começo, fluxo, escape, fim ou só uma
  anotação), a intensidade quando ela quis dizer, sintomas, humor e nota.
  Nenhuma coluna derivada: dia do ciclo, duração, média e estimativa são
  resultado de quem lê, e é lá que o gate Premium se aplica.
- **Escolha explícita:** um escape nunca vira começo, e um dia sem linha
  significa “sem registro”, nunca “sem sintomas”.
- **Corrigir não é registrar de novo:** a data de criação fica, a revisão
  sobe, e a contagem de dias não muda.
- **Apagar deixa lápide:** o dia sai do histórico e a linha permanece com uma
  revisão maior, então a cópia antiga de outro aparelho não o ressuscita.
  Escrever ali de novo traz o dia de volta — porque foi a pessoa que pediu.
  `purge` apaga tudo de verdade, e só da conta que pediu.
- **Fora dos caminhos indiretos:** o registro não entra na Leitura do Ciclo
  (nem na contagem, nem no mapa de calor), não soma XP, não alimenta ofertas
  nem telemetria, e não é enviado à IA — isso é assunto do P18, com
  consentimento próprio. Entrar numa conta no mesmo aparelho leva o registro
  junto, como as demais tabelas anônimas.
- **Quem vê e o que vê:** `MenstrualAccess` responde três perguntas, nesta
  ordem — a funcionalidade é oferecida a esta pessoa (só feminino e neutro;
  no masculino não há cartão, teaser nem oferta), houve consentimento para
  registrar, e o que está na tela é dado inserido ou derivado. Registrar,
  consultar, corrigir, exportar e apagar são do plano gratuito; dia do ciclo,
  duração, média, intervalo, estimativa e cruzamento lunar são resultados, e
  ficam no Premium. Nada derivado é calculado para depois ser borrado.
- **Levar embora e apagar não dependem de assinatura** — nem de o
  consentimento continuar de pé: quem mudou de ideia precisa poder apagar
  depois.
- **Dois consentimentos separados:** manter o registro no aparelho é um;
  enviá-lo para a conta é outro, desligado até haver um sim explícito.
  Retirar o primeiro fecha o segundo, e a resposta de uma conta não responde
  por outra.
- **Cartão em Ciclos:** depois da Leitura do Ciclo e antes das Eras, e só
  para quem a funcionalidade é oferecida. Antes de ativar ele apresenta a
  área com as próprias palavras, sem “dados de exemplo” que pareçam registros
  de alguém; depois continua discreto, sem dia nem estação — isso dependeria
  de uma escolha explícita que ainda não existe.
- **Primeira abertura:** a tela pede o consentimento e explica o que é
  gratuito e o que é Premium antes de qualquer campo. Aceitar abre o registro
  na hora, sem etapa de compra; o envio para a conta continua desligado.
- **Hoje e calendário:** o cabeçalho mostra o que foi realmente registrado
  hoje (ou “sem registro hoje”), e o calendário do mês marca só os dias com
  registro. Tocar um dia abre o painel; os botões de mês fazem a mesma coisa
  que deslizar. Nenhuma média, dia do ciclo ou comparação aparece no
  gratuito — esses números não são calculados.
- **Registrar:** a escolha é explícita (começou, dia de fluxo, escape,
  terminou ou só uma anotação) e a intensidade só é oferecida onde houve
  sangramento. A data em edição fica ao lado de salvar, inclusive num dia
  retroativo. Gravar primeiro, fechar depois: “registro salvo” significa
  gravação local concluída, e uma falha mantém o painel aberto com o texto.
- **O que o histórico mostra (Premium):** dia do ciclo, média e faixa
  observadas entre começos, e duração dos episódios. Um intervalo existe
  entre dois começos marcados pela pessoa; escape não abre intervalo, e um
  dia sem registro interrompe o episódio. O resumo aparece com três
  intervalos completos, e antes disso a tela diz quantos existem.
- **Referência de próxima data:** opcional dentro do Premium e desligada por
  padrão. É o último começo mais a média observada, apresentada como
  referência do histórico — não é previsão e não diz nada sobre fertilidade
  ou ovulação, que estão fora deste trabalho.
- **No gratuito o histórico nem é lido:** a tela só monta a lista completa
  para quem pode ver o que se calcula dela.
- **Levar embora:** `menstrual_days` entra na exportação de dados como
  qualquer outra tabela dela — o arquivo sai completo, sem assinatura e sem
  depender de o consentimento continuar de pé.
- **Apagar só isto:** Privacidade ganha uma porta própria para o registro do
  ciclo, visível apenas quando existe registro, dizendo quantos dias serão
  apagados antes de confirmar. Apagar de verdade (`purge`) e esquecer as duas
  respostas de consentimento andam juntos: quem retirou o sim continua
  podendo apagar o que já tinha escrito, sem limpar o aparelho inteiro. A
  limpeza geral do aparelho também leva a tabela junto.
- **As quatro Estações Internas (Premium):** Inverno, Primavera, Verão e
  Outono são vocabulário simbólico, escolhido por ela. O app nunca deduz uma
  estação a partir de data, fluxo, humor ou média, e não escolher nenhuma é
  uma resposta inteira. Tocar de novo na estação escolhida a desmarca, e
  desmarcar não apaga o resto do registro. Quando o dia tem marca de
  sangramento, o Inverno aparece como convite — e preferir outra, ou nenhuma,
  está igualmente certo.
- **Escolher já é registrar:** um dia sem linha ganha uma, com a marca de
  anotação — que não diz nada sobre sangramento.
- **Conteúdo em três idiomas:** `menstrual_phase_content_pt/en/es.dart` seguem
  o padrão de LifeErasContent — título, convite, duas ou três práticas leves,
  pergunta de escrita, correspondências e versão editorial. Nenhum texto
  prevê humor, afirma fase do corpo, promete hormônio, ovulação, fertilidade
  ou gravidez, e nada aqui trata dor ou fluxo.
- **Correspondências simbólicas:** duas ou três entradas da Enciclopédia por
  estação. Como o modelo de cristal não tem ID, cada correspondência carrega
  uma chave estável (igual nos três idiomas) ao lado do nome do verbete
  naquele idioma; o destino é resolvido por `resolveRelatedLink`, preservando
  as telas que já existem. São ligações por afinidade simbólica: nenhuma
  promessa de ingestão, elixir, alívio de cólica ou regulação hormonal.
- **A escrita da estação fica onde foi escrita:** guardada no registro do dia
  (`season_note`), com um selo discreto. Não vai para o Diário, para o acervo
  nem para a IA, e apagar o dia leva a escrita junto.
- **Vinheta por estação:** repouso, broto, flor aberta ou folha, trocando por
  camadas em 450 ms. Sem laço, sem partícula e sem respiração obrigatória — o
  estado parado é o estado normal, e com movimento reduzido a troca é
  imediata.
- **Verificação:** `menstrual_insights_test.dart` (intervalo entre começos,
  escape que não abre intervalo, episódio que conta as duas pontas e para no
  buraco, resumo com três intervalos, referência só com opt-in, dia do ciclo
  e contagem que atravessa horário de verão), `menstrual_cycle_page_test.dart` (nada antes do sim,
  escrever/reler/apagar um dia, escape que continua escape, ausência de
  resultados no gratuito, cartão invisível no masculino, falha que preserva o
  formulário), `menstrual_access_test.dart` (a matriz de acesso e os dois
  consentimentos) e `menstrual_cycle_repository_test.dart` (o que foi escrito
  e nada além, escape que continua escape, correção com revisão, ausência de
  registro, lápide que resiste ao aparelho antigo, revisão maior que vence,
  isolamento entre contas, apagar tudo, e a Leitura do Ciclo sem ver nada) e
  `daily_tarot_migration_test.dart` (um telefone vindo da v23 ganha a tabela),
  `menstrual_season_content_parity_test.dart` (quatro estações nos três
  idiomas, mesmas chaves de correspondência na mesma ordem, todo destino
  existindo no catálogo daquele idioma, e a fronteira do que o texto não pode
  prometer) e `menstrual_season_migration_test.dart` (um telefone na v28 ganha
  as colunas da estação sem perder o que já estava escrito).

## Ciclo menstrual: a Lua nas datas que ela marcou (P17, primeira parte)

Entregue em 11/09.

- **Uma conta só, compartilhada:** a posição contínua dentro da lunação sai
  do mesmo cálculo do calendário lunar (`LunarProvider.lunationPositionOn`),
  exposta sem os degraus das fases. A comparação de proximidade usa essa
  função e a constante do ciclo médio que já existiam — nada foi duplicado.
- **Convenção de cálculo:** um registro não tem hora, então a comparação usa
  o meio-dia local do dia observado. É convenção, não o horário de nada que
  aconteceu com ela, e trocar o fuso do aparelho não reclassifica o
  histórico.
- **Janela simétrica de ±2 dias** em torno da Nova e da Cheia estimadas, com
  versão de algoritmo registrada. A tela informa a janela e que as fases são
  estimativas do app.
- **Lua estimada por dia no calendário (Premium):** cada dia do mês mostra a
  fase estimada, com o nome em texto para quem ouve a tela, e uma legenda diz
  o que é aquilo. No gratuito a Lua nem é calculada — cruzar registro com
  fase é comparação, e comparação é Premium.
- **Você e a Lua:** as datas dos começos com a fase estimada de cada uma
  aparecem desde o primeiro começo. O resumo exige quatro começos — três
  intervalos completos — e conta quantos ficaram dentro da janela: "Em 2 de 3
  ciclos completos observados...". O quarto começo fecha o terceiro intervalo,
  continua visível e diz na tela que não entra na contagem.
- **O que não existe aqui:** porcentagem de sincronia, pontuação, ranking,
  previsão de repetição, título de Lua Branca ou Vermelha (só com revisão
  editorial confirmada) e qualquer frase de causa. Datas próximas autorizam
  uma comparação e uma leitura poética.
- **Média, faixa e referência, revisadas:** os números falam de até seis
  intervalos recentes e a tela diz o tamanho da amostra. A referência de
  próxima data passa a usar a **mediana** dessa janela — um único intervalo
  muito diferente não arrasta a referência inteira — e, quando a data passa,
  a tela diz apenas que a estimativa está desatualizada: sem somar ciclo
  fictício, sem falar em atraso, gravidez ou anormalidade.
- **A roda do mês (Premium):** dois anéis na mesma escala de datas — o
  externo com a Lua estimada de cada dia, do escuro ao claro; o interno só
  com o que ela registrou, com forma por tipo de marca (bolinha cheia é
  começo ou fluxo, contorno é escape, barra é fim, quadrado é anotação). Não
  existe anel de 28 dias esticado até coincidir com uma lunação: o intervalo
  é o mês que está na tela. O centro mostra o dia em foco, a Lua estimada e a
  estação escolhida, quando existe.
- **Calendário continua sendo a alternativa explícita:** a troca entre roda e
  calendário é um botão, e quem não quiser explorar a roda não perde nada. No
  gratuito só existe o calendário — a roda mostra comparação.
- **Percorrer sem atropelar:** o dedo percorre as datas na horizontal, para
  não disputar com a rolagem vertical nem com o gesto de voltar; o cursor
  acompanha o gesto no mesmo quadro, sem easing; soltar nunca altera
  registro. O teclado percorre com as setas e abre com Enter, e tocar na roda
  entrega o teclado a ela. A árvore semântica anuncia o dia em foco, se há
  registro nele e a fase estimada — uma etiqueta por seleção, não por quadro.
- **Verificação:** `menstrual_wheel_test.dart` (tocar escolhe e abre o dia
  tocado; as setas percorrem sem abrir; o cursor não passa do primeiro nem do
  último dia do mês; a semântica fala do dia, do registro e da Lua),
  `menstrual_lunar_comparison_test.dart` (perto da Nova,
  perto da Cheia e nem uma coisa nem outra; a janela simétrica dos dois
  lados; sem quatro começos não há resumo; o quarto fecha e não conta; com
  mais histórico o resumo olha os três mais recentes) e as novas histórias de
  `menstrual_insights_test.dart` (a janela de seis intervalos com o tamanho
  da amostra, a mediana em vez da média na referência, e a referência que
  passou).

## Dados e compatibilidade

O schema local sobe de 23 para 24 (sessões e ledger), 25 (descobertas do
Oráculo), 26 (consultas do Conselheiro), 27 (marcos), 28 (registro menstrual,
em tabela própria) e 29 (a estação escolhida e a escrita que vem com ela, duas
colunas na mesma tabela). As tabelas novas são
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
- `number_reveal_test.dart` e `pendulo_fora_da_tela_test.dart`: número final
  igual com e sem animação; sensor e controladores parados fora da tela.
- `palmistry_page_test.dart`: cancelamento sem rastro, falha com retomada,
  cota gasta só no sucesso e varredura limitada à requisição real.
- `oracle_album_test.dart` e `archetype_quiz_test.dart`: álbum, retrospectiva
  silenciosa, constelação determinística e revelação depois da gravação.
- `tool_identity_test.dart`: emblema único por ferramenta e a passagem do
  card para o cabeçalho.
- `sigil_trace_test.dart` e `sigil_drawing_page_test.dart`: percurso do
  sigilo, estado final para exportação, interpolação do embaralhamento e
  gravação antes de fechar a tela.
- Os testes de tela que dirigem SQLite dentro do tempo falso encurtam o
  limite por teste (`useShortTestTimeout`, em `test/support/`): uma falha no
  meio de uma gravação deixa o cadeado do SQLite preso para os testes
  seguintes do mesmo arquivo, e com o padrão de dez minutos isso vira dezenas
  de minutos de CI em vez de uma falha legível. A anotação `@Timeout` do
  arquivo não serve sozinha: `testWidgets` passa o próprio limite e vence a
  anotação, então o valor é ajustado no binding.
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

1. P14: revisão de tamanhos e hierarquia e o percurso completo pelas 12
   entradas em aparelho — o que resta do pacote é avaliação visual.
2. P16: cartão em Ciclos, consentimento, formulário e calendário do registro;
   P17: roda comparativa e estações, com os cálculos atrás do Premium.
3. P18: registros menstruais autorizados entram na análise completa do ciclo.
4. P15: integração e validação final do lote.

As decisões mais recentes sobre menstruação estão mantidas no plano:
registro, leitura dos dados inseridos, edição, exclusão e exportação Free;
análises, estações estimadas e cruzamentos Premium; consentimento específico
para participar da análise completa. Health/Flo é uma evolução secundária.
