# Grimório de Bolso — plano de implementação de movimento e interações

Versão 1.2 · 9 de setembro de 2026 · registro menstrual Free, análises Premium e integração à Leitura do Ciclo

Repositório: [laylamonteiro/witchy-app](https://github.com/laylamonteiro/witchy-app). Base analisada: [commit 6ea85d98cab5d5429617badbb606608cbc290567](https://github.com/laylamonteiro/witchy-app/tree/6ea85d98cab5d5429617badbb606608cbc290567), branch main.

Este documento consolida as propostas da conversa e acrescenta as decisões técnicas necessárias para implementá-las. É um plano; as alterações ainda não foram executadas. A análise examinou o código, sem executar o app. As medidas de movimento abaixo são valores iniciais a ajustar em aparelho.

O objetivo é tornar ações, resultados e conquistas perceptíveis, com identidade visual de bruxaria: manipular cartas e pedras, transformar uma pergunta em orientação, traçar um sigilo, selar uma página e ver o próprio progresso.

## 1. Escopo e decisões adotadas

O projeto cobre as 12 entradas da aba Ferramentas, os fluxos relacionados de diário, desejos, rituais, jornadas e salvamento, e agora o **Ciclo Menstrual na aba Ciclos**. A inclusão preserva o brainstorm como visão de produto e transforma suas decisões em requisitos executáveis neste plano. O redesenho geral de Astrologia e das demais áreas de Ciclos continua fora deste lote. **Decisão adicional da Layla: os registros menstruais participam da análise completa da Leitura do Ciclo já neste lote**, quando a pessoa autorizar as fontes da leitura. Essa integração é uma entrega obrigatória de P18, restrita ao Premium. O registro manual é gratuito, conforme a decisão posterior da Layla; essa regra substitui o gate integral do brainstorm original.

Esta revisão consolida o registro manual gratuito, reserva os dados derivados e análises ao Premium e mantém Health/Flo como evolução secundária. Acrescenta a seção 5.4, a experiência 6.15 e os pacotes P16/P17/P18; amplia assets, testes e critérios de entrega. Os IDs P00–P15 foram preservados. P15 continua sendo a integração final e passa a ocorrer depois dos novos pacotes habilitados para lançamento.

### 1.1 Decisões de produto para esta implementação

| Tema | Decisão |
|---|---|
| Tarô | Escolha manual das cartas em leque nas tiragens de 1, 3 e 5 cartas. |
| Runas | Escolha manual de pedras viradas para baixo, sobre um tecido; mesas de 1, 3, 5 e 9 runas. |
| Oráculo | Compartilhar a mecânica de seleção de cartas com o tarô; usar arte autoral e cenas de revelação próprias. |
| Escolha | Embaralhar uma vez por sessão. Cada posição corresponde a um item concreto. Retirar exatamente o item escolhido. |
| Revelação | Montar toda a mesa antes de revelar símbolos ou cartas. A última escolha inicia a confirmação e a revelação; não acrescentar um botão obrigatório só para prolongar a cena. |
| Gestos | Toque sempre funciona. Arraste é uma alternativa. Deslizar para explorar não seleciona ao soltar. |
| Reentrada | Voltar à mesma sessão recupera sua seleção ou resultado; não embaralha novamente. Uma nova consulta é uma ação explícita. |
| Carta do dia | A primeira seleção concluída fixa a carta por pessoa, dia local e pergunta. Reaberturas mostram essa carta, inclusive para Premium. |
| Conselheiro | Manter pergunta e resposta única. Transformar envio, espera e apresentação; acrescentar “Guardar conselho”. |
| Oráculo colecionável | Álbum das 44 cartas encontradas. Descobertas são registros persistentes e não geram XP adicional automaticamente. |
| Recompensas | Usar o XP atual. Apresentar o avanço real após a persistência. Nenhuma animação credita pontos. |
| Conquistas simultâneas | Uma composição por ação agrega salvamento, XP, marco, nível e reação do gatinho. |
| Experiência recorrente | Cenas podem ser antecipadas por toque. Reabrir histórico e sincronizar dados não reproduzem festas antigas. |
| Tecnologia | Partir de Flutter/Dart e dependências existentes. Arte em camadas quando necessária. Adotar Rive, Lottie ou shaders só se um protótipo demonstrar necessidade concreta. |
| Entrega | Implementar por pacotes pequenos, com recursos ativáveis separadamente e compatibilidade com dados existentes. |
| Ciclo Menstrual | Novo cartão em Ciclos, registro manual, calendário pessoal e lunar, Estações Internas e correspondências simbólicas. |
| Elegibilidade menstrual | Cartão apenas para Gender.feminine/neutral. Registrar, consultar os dados inseridos, editar e excluir é Free. Dados derivados, insights e análises exigem isPremiumEffective. |
| Estações Internas | Linguagem simbólica ajustável pela pessoa. Registros de sangramento e estimativas ficam identificados; datas não confirmam ovulação. |
| Lua e ciclo | Comparação descritiva de datas; leitura simbólica opcional, sem medir “alinhamento ideal” ou criar identidade corporal permanente. |
| Feedback menstrual | Confirmação suave e exploração visual. Sem XP, streak, conquistas ou ofertas motivadas por registros de saúde. |
| Análise completa | Incluir registros menstruais autorizados como quinta família de fontes da Leitura do Ciclo, integrada ao relatório completo e também à versão semanal. Implementar neste lote para Premium, com seleção de registros e campos. |
| Entrada de dados | O caminho principal e completo é manual, inclusive no Free. Health/Flo é secundário e não condiciona nenhuma entrega deste lote. |

### 1.2 Evoluções funcionais incluídas

Além de animações, o plano inclui: sessões retomáveis, seleção real, identidade persistente da carta do dia escolhida, controle idempotente do consumo local, notificações de marcos, álbum do Oráculo e salvamento do Conselheiro. Inclui também registro menstrual, consentimento específico, gestão e sincronização desses dados, exploração lunar, conteúdo simbólico por estação e integração menstrual à análise completa da Leitura do Ciclo.

Chat contínuo com o Conselheiro, streaming real de IA, novos preços, novos limites de uso e uma nova economia de XP não são pré-requisitos. Uma versão futura pode tratar esses temas separadamente.

## 2. Base existente e pontos de atenção

| Componente atual | O que foi confirmado | Consequência para o plano |
|---|---|---|
| GrimoireMotion | Tempos e curvas comuns, mais consulta a movimento reduzido. | Estender o padrão existente; não criar outro vocabulário concorrente. |
| TarotFlipCard | Giro em perspectiva no nativo, escala horizontal na web, entrada escalonada e suporte a movimento reduzido. | Reutilizar a virada; acrescentar seleção e montagem da mesa. |
| TarotPage | Pergunta obrigatória; tipos daily, threeCards e cross; cartas escolhidas pelo código; resultado em Wrap. | Separar domínio da sessão e criar layouts próprios. |
| TarotReadingRepository | Salva cartas, posições e interpretação; restaura a mesa por dia/pergunta. A assinatura atual não inclui a data. | Acrescentar identidade por sessão; não usar conteúdo como identidade de uma ocorrência. |
| Runas | 1, 3, 5 ou 9 itens; entrada animada dos cards completos. | Dar movimento às pedras e apresentar texto depois. |
| Oráculo | 44 cartas; 1, 3 ou 5 itens; imagens representadas por emojis. | Produzir artes e acrescentar o catálogo visual por ID. |
| Conselheiro | Recebe resposta completa, depois executa typewriter de 0,8 a 6 segundos. | Usar a espera real e uma revelação breve; parar efeitos quando o resultado estiver disponível. |
| LearningProvider | XP unificado; LessonReward retorna ganho, trilha concluída e novo nível. | Expandir a coordenação para práticas sem duplicar a fórmula de XP. |
| Jornadas | Marcos derivados de contagens; all_readings soma runas, oráculo e pêndulo. | Incluir tarô e detectar transições de marco após ações. |
| DailyRitesCard | Selo, estrelas e resposta tátil; detecta fechamento do dia na própria UI. | Extrair a avaliação para serviço compartilhado e evitar dupla celebração. |
| Sigilos | Traçado e posições são desenhados imediatamente; salvamento e exportação já existem. | Animar o progresso do caminho e a reorganização das letras. |
| SaveToRecordsButton | Já muda ícone, texto e cor após salvar. | Acrescentar a cena da página e coordenar a confirmação existente. |
| Mascote | Já possui reações e múltiplos controladores internos. | Expor um comando externo limitado, respeitando interação e preferência de visibilidade. |

Fontes: [movimento](https://github.com/laylamonteiro/witchy-app/blob/6ea85d98cab5d5429617badbb606608cbc290567/lib/core/theme/grimoire_motion.dart), [tarô](https://github.com/laylamonteiro/witchy-app/blob/6ea85d98cab5d5429617badbb606608cbc290567/lib/features/tarot/presentation/pages/tarot_page.dart), [repositório de tarô](https://github.com/laylamonteiro/witchy-app/blob/6ea85d98cab5d5429617badbb606608cbc290567/lib/features/tarot/data/repositories/tarot_reading_repository.dart), [XP](https://github.com/laylamonteiro/witchy-app/blob/6ea85d98cab5d5429617badbb606608cbc290567/lib/features/learning/presentation/providers/learning_provider.dart), [jornadas](https://github.com/laylamonteiro/witchy-app/blob/6ea85d98cab5d5429617badbb606608cbc290567/lib/features/journeys/presentation/pages/journeys_page.dart).

### 2.1 Regras que exigem atenção antes de refatorar

1. O texto de alguns comentários de cota diverge da implementação. Na função decidirTiragem, uma pergunta nova para Free depende de temCota e retorna cobrar ou bloquear; não existe ali uma exceção automática de “primeira pergunta grátis”. A referência para caracterização é o código executado e seus testes.
2. Para Free, a função atual reutiliza uma mesa existente quando a pergunta é a lembrada do dia. Para Premium, retorna liberar antes dessa verificação. A implementação deve distinguir “retomar esta sessão” de “iniciar nova tiragem”; não transformar toda consulta Premium de 3/5 cartas em uma mesa imutável por dia.
3. Os contadores de uso são gravados em SharedPreferences pelo AuthProvider. Uma transação SQLite não torna uma gravação em preferências atômica. A solução de retomada precisa resolver essa fronteira explicitamente.
4. A assinatura de tarô baseada em cartas/pergunta não identifica a data. Duas consultas legítimas podem ter exatamente as mesmas cartas em dias diferentes; ambas precisam existir no histórico.
5. O XP de práticas é derivado de registros existentes. Excluir um registro pode diminuir essa parcela. Preservar essa regra nesta entrega; um marco histórico já alcançado pode continuar adquirido sem conceder pontos de novo.
6. Os valores xpReward mostrados nas definições de etapas das Jornadas não são somados automaticamente pela fórmula unificada de LearningProvider. Não usar esses valores como novos créditos durante a animação.
7. Tarô e logs de rituais guiados têm persistência local nos repositórios examinados. O plano não deve anunciar que esses históricos já sincronizam entre aparelhos.

Fonte da política de tarô: [regra_da_carta_do_dia.dart](https://github.com/laylamonteiro/witchy-app/blob/6ea85d98cab5d5429617badbb606608cbc290567/lib/features/tarot/domain/regra_da_carta_do_dia.dart). Fonte dos contadores: [auth_provider.dart](https://github.com/laylamonteiro/witchy-app/blob/6ea85d98cab5d5429617badbb606608cbc290567/lib/features/auth/presentation/providers/auth_provider.dart).


### 2.2 Constatações adicionais sobre Ciclos

O item 3 do roadmap confirma a regra de gênero, o registro manual e o reaproveitamento de sync. O acesso foi refinado pela Layla nesta conversa: registro Free, dados derivados e análises Premium. A referência de código foi reconferida em 8 de setembro de 2026 e era a ponta de main naquela consulta; não houve execução do app nesta revisão.

| Ponto conferido | Implicação concreta |
|---|---|
| CyclesTab monta Leitura do Ciclo, Eras e MonthSkyCard. | Inserir cartão independente do carregamento do mapa astral; não exigir dados de nascimento para registrar. |
| CycleReadingSourceOptions inicia as quatro fontes atuais em true. | A nova fonte menstrual nasce false e exige seleção explícita dos registros. Copiar apenas o padrão de UI não basta. |
| CycleReadingMaterial.recordCount também atende ao gatilho de oferta. | Contagens menstruais não entram nesse agregado comercial, mesmo quando forem autorizadas para uma leitura específica. |
| compactJsonFor usa o material inteiro para seções sem lista específica. | A integração menstrual com IA precisa de lista positiva de destinos; a fonte íntima não pode herdar esse fallback. |
| LunarProvider.phaseOn é estático e usa um ciclo médio de 29,53059 dias. | Reutilizar sua convenção como estimativa lunar do app, sem anunciar precisão de efemérides. |
| A janela de newMoon é bem menor que a de fullMoon. | Contar os enums diretamente produziria uma comparação desequilibrada entre “Lua Branca” e “Lua Vermelha”; usar janelas simétricas para esse recurso. |
| CrystalModel possui name e intentions, sem id no modelo lido. | Criar um resolvedor com chaves estáveis para os poucos links curados; nomes traduzidos não servem como identidade. |
| DataExportService possui lista fixa e exporta JSON; Privacidade tem limpeza local e exclusão de conta. | Criar exportação com escolha explícita de incluir saúde e exclusão específica do módulo. Limpar o aparelho não substitui apagar a cópia sincronizada. |
| CycleReadingSections.ordered tem 11 seções de IA; weekly tem 8. | A integração deve acompanhar as listas executáveis; comentários antigos ainda citam sete. A seção de números é montada em Dart. |
| Rascunhos de leitura ficam em SharedPreferences e o resultado vai a free_writings. | Relatórios com conteúdo menstrual precisam de proteção e proveniência também no rascunho/acervo, além da tabela de registros. |

Fontes do código: [roadmap, item 3](https://github.com/laylamonteiro/witchy-app/blob/6ea85d98cab5d5429617badbb606608cbc290567/docs/PROXIMOS_PASSOS_AGO2026.md), [Ciclos](https://github.com/laylamonteiro/witchy-app/blob/6ea85d98cab5d5429617badbb606608cbc290567/lib/features/cycles/presentation/pages/cycles_tab.dart), [composição da Leitura do Ciclo](https://github.com/laylamonteiro/witchy-app/blob/6ea85d98cab5d5429617badbb606608cbc290567/lib/features/cycle_reading/data/services/cycle_reading_composer.dart), [cálculo lunar](https://github.com/laylamonteiro/witchy-app/blob/6ea85d98cab5d5429617badbb606608cbc290567/lib/features/lunar/presentation/providers/lunar_provider.dart), [exportação](https://github.com/laylamonteiro/witchy-app/blob/6ea85d98cab5d5429617badbb606608cbc290567/lib/core/services/data_export_service.dart).

## 3. Linguagem de movimento

### 3.1 Tempos iniciais

| Uso | Referência inicial | Comportamento |
|---|---|---|
| Pressão e seleção | GrimoireMotion.tap: 140 ms | Resposta curta, ligada ao dedo. |
| Alteração de estado | state: 260 ms | Cor, confirmação, atualização de espaço. |
| Revelação | reveal: 450 ms | Giro, acendimento ou entrada de conteúdo. |
| Celebração | celebration: 900 ms | Selo, marco ou livro; pode ser antecipada. |
| Navegação | route: 220 ms | Continuidade entre card e tela. |
| Mesa com vários itens | Meta inicial: até 1,2 s para a revelação conjunta | Reduzir o intervalo entre itens em mesas maiores; nunca somar nove pausas completas. |
| Espera de IA | Duração da operação real | Loop discreto interrompível, sem espera mínima artificial. |

Os números são parâmetros do projeto, não promessas de desempenho. Interpolação e trajetória podem variar: cartas deslizam e giram; pedras têm assentamento curto; tinta percorre caminhos; névoa se dispersa.

### 3.2 Hierarquia e interrupção

- Uma ação comum recebe feedback próximo ao elemento tocado.
- Um marco recebe uma composição breve sobre a tela atual.
- Conclusão de trilha e mudança de nível podem ocupar uma área maior, com saída imediata disponível.
- Cenas não removem o texto necessário para continuar usando a tela.
- Movimento reduzido mantém seleção, informação de conclusão e resultado; substitui deslocamentos e giros por estados finais ou mudanças discretas.
- Pausar loops quando a rota estiver encoberta, a aba não estiver visível ou o app estiver em segundo plano. Cancelar timers e listeners no descarte.
- Não acrescentar som nesta rodada. Resposta tátil é curta e respeita a preferência do app/aparelho; não disparar vibração contínua ao percorrer o baralho.
- Não usar piscadas intensas nem clarões ocupando toda a tela.

### 3.3 Layout e gestos

- Tratar 360 dp de largura como cenário compacto de referência; incluir teclado aberto e fonte ampliada.
- A área do baralho tem seu próprio gesto horizontal. O texto abaixo mantém rolagem vertical.
- Reconhecer exploração horizontal e retirada vertical depois do limiar de gesto; um mesmo gesto não executa as duas ações.
- Arrastar para fora da área válida devolve o item ao lugar.
- Ao navegar para um detalhe, a carta/pedra selecionada continua sendo o mesmo item. Usar IDs estáveis para transições.
- Na web, oferecer mouse, teclado e foco visível. Setas percorrem itens; Enter/Espaço selecionam. A pessoa não depende de arrastar.

## 4. Arquitetura proposta

Manter Provider, repositórios e infraestrutura atual. Os nomes abaixo são sugestões para novos componentes e devem acompanhar as convenções vigentes no repositório.

| Peça | Responsabilidade | Local sugerido |
|---|---|---|
| GrimoireMotion | Tempos, curvas e política de movimento. | Estender lib/core/theme/grimoire_motion.dart |
| ToolSceneFrame | Composição de preparação, resultado e área de ações. | lib/core/widgets/motion/tool_scene_frame.dart |
| DeckSelectionController | Estado de seleção por IDs, sem sortear em build ou depender de animação. | lib/features/divination/domain/deck_selection_controller.dart |
| ReadingSessionRepository | Rascunho, ordem do baralho, escolhas, status e resultado vinculado. | lib/features/divination/data/repositories/reading_session_repository.dart |
| UsageCoordinator | Validar política e consumir uma vez por operação, com recuperação após interrupção. | lib/core/services/usage_coordinator.dart |
| CardSelectionSurface | Leque, foco, hit testing e escolha das cartas. | lib/features/divination/presentation/widgets/card_selection_surface.dart |
| RuneSelectionSurface | Pedras e interação específica, usando o mesmo contrato de sessão. | lib/features/runes/presentation/widgets/rune_selection_surface.dart |
| SpreadBoard | Posições identificadas e seus layouts por ferramenta. | lib/features/divination/presentation/widgets/spread_board.dart |
| ActionOutcome | Resultado de uma ação persistida: entidade, XP, marcos, nível e origem. | lib/features/journeys/domain/action_outcome.dart |
| ProgressCoordinator | Calcular antes/depois e detectar marcos; reaproveitar a fórmula atual. | lib/features/journeys/domain/progress_coordinator.dart |
| ActionFeedbackHost | Apresentar uma sequência de feedback por ação e controlar sobreposições. | lib/core/widgets/motion/action_feedback_host.dart |
| MascotReactionController | Solicitar uma reação externa ao gatinho. | lib/core/widgets/mascot/mascot_reaction_controller.dart |
| OracleArtRegistry | Mapear ID da carta para arte, camadas e tipo de animação. | lib/features/divination/presentation/oracle_art_registry.dart |
| OracleDiscoveryRepository | Registrar primeiras descobertas e alimentar o álbum. | lib/features/divination/data/repositories/oracle_discovery_repository.dart |

Evitar uma abstração que obrigue pedras, cartas e respostas textuais a renderizar da mesma maneira. Compartilhar contratos de estado e componentes que de fato se repetem.

### 4.1 Contrato das sessões de seleção

Uma sessão guarda: ID, usuário, ferramenta, tiragem, versão do baralho, dia local de início, pergunta original/normalizada quando existir, IDs dos itens na ordem embaralhada, orientações, posições escolhidas, estado, datas e ID do resultado.

A orientação também deve ficar definida na sessão. Para tarô, preservar a chance atual de invertida; para runas, preservar as regras atuais do domínio. O gesto, a inclinação visual e a física nunca recalculam esse valor.

| Estado | Entrada | Saída permitida |
|---|---|---|
| preparing | Abertura de consulta autorizada ou retomada | Restaurar resultado; restaurar rascunho; criar ordem e ir a selecting; informar bloqueio. |
| selecting | Baralho/pedras disponíveis | Escolher um ID disponível; persistir posição; retomar; concluir conjunto. |
| committing | Todas as posições preenchidas | Revalidar acesso, confirmar consumo, persistir resultado, vincular sessão. |
| revealing | Resultado já persistido | Apresentar a cena ou antecipá-la. |
| reading | Mesa pronta | Interpretar, guardar, inspecionar item ou iniciar outra consulta quando permitido. |
| recoverableError | Falha de gravação ou operação incompleta | Retomar a operação identificada, mantendo as escolhas. |

Sair da tela preserva selecting; não equivale a confirmar a tiragem. A animação de abertura é um detalhe de UI e não precisa virar um estado persistido.

### 4.2 Fluxo de confirmação

1. Travar o comando da sessão para impedir dois commits simultâneos.
2. Confirmar que existem exatamente N IDs únicos do baralho correto.
3. Revalidar a política de acesso vigente e a conta ativa.
4. Executar a confirmação idempotente de uso e resultado pela chave da sessão.
5. Salvar resultado e relação com o rascunho; manter informação suficiente para recuperar qualquer operação interrompida.
6. Registrar rito e descoberta aplicáveis. Atualizar progresso após o sucesso, uma única vez.
7. Executar a oportunidade de anúncio prevista pela política existente e só então apresentar a revelação. O anúncio não gera outra consulta.
8. Se o app fechar nesse intervalo, reabrir o resultado confirmado; não cobrar, sortear ou forçar outro anúncio pela simples retomada.

Nas tiragens, abandonar antes de completar a seleção não consome uso. Uma consulta confirmada permanece registrada mesmo que a pessoa antecipe ou não assista à animação.

O salvamento em “Meus Registros” continua sendo uma ação distinta do histórico técnico da leitura.

### 4.3 Cotas locais e recuperação

Para tarô, Oráculo e Runas, migrar os contadores afetados para uma pequena fonte local transacional de consumo, lida por AuthProvider. Usar um registro por usuário/operação com UNIQUE(user_id, operation_id), mais categoria e day_key. Importar uma única vez o total atual das preferências como saldo inicial do dia; não zerar o consumo existente.

O saldo pode ser calculado como base importada + operações válidas do dia. Resultado local, consumo e status final da sessão devem usar a mesma transação SQLite sempre que seus repositórios compartilhem o banco. Preferências passam a espelhar o valor para compatibilidade, sem continuar sendo outra fonte de escrita.

Se alguma política realmente for governada pelo servidor, manter o servidor como autoridade e exigir uma chave idempotente no contrato antes de prometer recuperação sem duplicação remota. As transações locais não garantem atomicidade com API.

Conselheiro e demais chamadas de IA não são automaticamente refeitas ao reabrir uma tela. Enquanto o endpoint não oferecer retomada/idempotência, distinguir requisição pendente, resposta recebida e erro. Preservar os critérios atuais de cobrança por sucesso; não reexecutar para reproduzir animações.

## 5. Dados, identidade e migrações

O banco analisado está na versão 23. Cada pacote usa a próxima migração disponível no momento da implementação, sem presumir que 24 continuará livre.

| Estrutura proposta | Conteúdo mínimo | Persistência |
|---|---|---|
| selection_sessions | session_id, user_id, tool, spread, deck_version, day_key, pergunta quando houver, deck_json, selections_json, status, result_id, timestamps | Local; rascunhos pertencem ao aparelho nesta primeira versão. |
| usage_operations e saldo inicial | operation_id, user_id, categoria, day_key, valor, sessão; saldo importado por categoria/dia | Local; unificar as escritas afetadas. |
| tarot_day_state | user_id, day_key, pergunta lembrada e última pergunta original | Local; atualizar junto à confirmação e importar as preferências atuais. |
| tarot_readings.session_id | ID estável da ocorrência, com unicidade quando preenchido | Migração aditiva; registros antigos continuam legíveis. |
| advisor_consultations | consultation_id, user_id, pergunta capturada, resposta recebida, estado e timestamps | Local; retomada do resultado recebido, sem reenvio automático à IA nem nova tela de histórico obrigatória. |
| progress_milestones | user_id, milestone_id, first_reached_at, source_action_id | Local e sincronizável; unicidade por usuário/marco. |
| oracle_discoveries | user_id, card_id, first_seen_at, source_reading_id, catalog_version | Local e sincronizável; unicidade por usuário/carta. |
| Apresentações vistas | action_id, tipo de apresentação, estado local | Local; não transformar sync de histórico em fila de animações. |
| FreeWritingSource.advisor | Origem da página do Conselheiro | Reutilizar free_writings; atualizar filtros e composição de títulos. |
| free_writings.source_ref | ID da leitura/consulta de origem, quando houver | Unicidade parcial por user_id, source e source_ref não nulo; textos livres e registros antigos continuam sem vínculo. |

### 5.1 Identidade e compatibilidade

- Usar UUID para sessão e ocorrência. Usar IDs estáveis de cartas/runas; nomes traduzidos não são chaves.
- Normalizar pergunta conforme o comportamento atual: trim e lowercase, preservando o original para exibir. Congelar versão dessa regra.
- Persistir a ordem, além de eventual seed. Não depender de String.hashCode para reproduzir consultas após atualização do app.
- Ao encontrar uma carta do dia antiga já registrada, adotá-la como resultado do dia. Se não existe leitura registrada, a primeira escolha manual define o novo resultado.
- Leituras antigas sem session_id mantêm seu formato. Não descartar registros durante migração.
- A leitura de dados com arte ainda não disponível usa fallback legível, incluindo carta e posição corretas.
- Registros no acervo precisam de vínculo/idempotência por origem quando se pretende evitar duplicação ao reabrir a leitura. Um bool no widget protege apenas aquela montagem.
- Para guardar uma leitura, usar source_ref e retornar o registro já existente em caso de repetição. Não inferir que dois textos idênticos são a mesma consulta. Atualizar o payload/sync e verificar constraints remotas; preservar linhas antigas sem source_ref.

### 5.2 Dia, usuário e interrupções

- Uma sessão fixa o dia local de início. Ao atravessar a meia-noite antes de confirmar, informar que pertence à consulta iniciada no dia anterior e concluir sob essa identidade; uma nova consulta usa o novo dia.
- Revalidar e resolver o consumo com o mesmo day_key da operação; não debitar silenciosamente o dia seguinte.
- Ao trocar de conta, descartar a apresentação atual e isolar rascunhos/resultados por user_id.
- Na migração de convidado para conta, incorporar as novas tabelas ao fluxo de migração existente. Resolver conflitos por chave estável, sem copiar conquistas de outra pessoa.
- Fechar a tela não apaga um rascunho com escolhas. Oferecer descarte explícito antes da confirmação, quando necessário.
- Invalidar callbacks antigos com operation_id/request generation. Resposta atrasada não substitui uma consulta mais recente.

### 5.3 Sincronização e retrospectiva

Descobertas do Oráculo e marcos novos devem acompanhar a conta na entrega final. Acrescentar tabelas remotas, políticas por usuário e integração ao DataSyncService pelo padrão do projeto; primeira data válida vence. A implantação remota é uma etapa concreta de release, não uma ação implícita deste documento.

Rascunhos e controle de apresentações ficam locais. Manter as limitações atuais dos históricos que ainda não sincronizam; uma expansão desse sync pode ser um pacote separado.

Ao instalar a atualização, calcular silenciosamente as descobertas/marcos recuperáveis a partir do histórico disponível. Não reconstruir dados que o aparelho não possui, nem apresentar conquistas antigas como se tivessem acabado de acontecer.


### 5.4 Dados e privacidade do Ciclo Menstrual

Os registros são dados de saúde. A LGPD os classifica como sensíveis e disciplina consentimento específico, revogação e direitos de acesso/eliminação. As escolhas de interface e arquitetura abaixo são decisões propostas para o produto; não constituem uma certificação de conformidade. [LGPD, arts. 5, 8, 11 e 18](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm).

**Modelo proposto.** Usar a próxima migração disponível, coordenada com P02. Uma linha diária evita múltiplas notas concorrentes para a mesma data; início e fim podem coexistir quando a pessoa registra um episódio de um dia.

| Estrutura | Campos e responsabilidade |
|---|---|
| menstrual_logs | id, user_id, local_date, timezone/offset de referência, is_period_start, is_period_end, bleeding_kind (none/spotting/flow), intensidade opcional, sintomas opcionais, humor/energia opcionais, nota opcional, symbolic_season opcional, source=manual, revisão e timestamps. |
| menstrual_settings | Modo de estimativa (desligado/ativado), lacunas informadas no histórico, período de acompanhamento, preferência de simbolismo e resumo privado no cartão. Separar permissões das preferências visuais. |
| sensitive_consents | user_id, finalidade, versão do texto, idioma, granted_at/revoked_at e revisão. Registro local e consentimento de sincronização são finalidades distintas; não guardar notas clínicas nessa trilha. |
| Estado remoto do módulo | Geração de dados por usuário e estado de exclusão/sync. Impedir que uma restauração antiga ressuscite dados apagados. |
| Cache de cálculo | Derivado dos logs, revisão do conjunto, timezone de referência e versão do algoritmo. Pode ser descartado e recalculado; não é uma nova fonte de verdade. |
| reading_source_manifest | reading_id, generation_id, user_id, fonte, IDs/versões selecionados, campos autorizados e versão/revisão do consentimento. Metadado protegido, atualizado em cada geração. |
| Relatórios e rascunhos sensíveis | Marcação containsSensitiveSources em registros de leitura/acervo, proveniência por geração e armazenamento que herda as regras de privacidade do módulo. Nunca reaproveitar rascunho íntimo como conteúdo genérico. |

Unicidade lógica por usuário/data para registros ativos. Uma edição atualiza a mesma ocorrência. Resolver colisão entre dois aparelhos por revisão: se ambos mudaram a mesma linha, preservar as duas versões até resolução visível, sem concatenar notas nem descartar silenciosamente sintomas. Tombstone vence atualização de uma revisão anterior. Um novo registro após exclusão usa nova identidade/geração.

Datas de saúde são datas civis: armazenar YYYY-MM-DD e a referência temporal usada no registro. Viajar ou trocar de fuso não desloca o dia já informado. Diferenças de dias usam calendário, sem truncar intervalos de 23/25 horas por horário de verão. Impedir datas futuras como fatos observados. Não preencher dias de fluxo entre início/fim automaticamente: oferecer preenchimento de intervalo com prévia e confirmação, ou manter dias sem informação.

**Consentimento e acesso.** Antes do primeiro registro, explicar quais dados serão guardados e para quê. Recusar mantém o acesso ao conteúdo simbólico genérico permitido pelo plano, sem gravar saúde. Sincronização é uma opção separada, inicialmente desligada; ativá-la permite enviar o histórico local após prévia do escopo. O uso em IA recebe consentimento próprio antes da geração, inicialmente desmarcado; ligar sync não autoriza IA e autorizar IA não liga sync. Nenhuma informação menstrual alimenta segmentação comercial, pontuação de uso ou ofertas.

Separar os gates: elegibilidade de gênero controla a entrada do módulo; criação/consulta/edição de registros exige consentimento e acesso à própria conta, mas não Premium. Cálculos, dados derivados, comparações e participação menstrual na análise exigem isPremiumEffective. Aplicar a regra às rotas, providers, serviços de cálculo, serialização de resultados e geração de IA, incluindo abertura de caches e relatórios. O servidor aplica autenticação/RLS por proprietário e valida o benefício no ponto confiável que autoriza processamento pago; esconder UI não substitui isolamento ou autorização.

Após expirar Premium, o registro manual continua funcionando e os dados inseridos permanecem consultáveis. Interromper novos cálculos/envios menstruais à IA e impedir apresentação analítica pelo cache, deep link, prévia ou acervo. A gestão/exportação dos próprios dados e a exclusão continuam acessíveis em Privacidade, inclusive se o gênero mudar ou a feature for desligada; esse canal não libera as telas de análise Premium. Não mostrar contagem ou resumo íntimo durante carregamento de autenticação, antes de consentimento ou no cartão de oferta.

**Proteção e alcance do sync.** Não adicionar a tabela à sincronização genérica sem filtro de consentimento por usuário. Rever também backup automático, exportação, migração de convidado e limpeza de sessão. Na associação de convidado a conta, pedir a decisão sobre transferir este histórico; não presumir que o consentimento da conta anterior se aplica. Nesta primeira entrega, registros continuam manuais; nenhuma permissão de plataforma de saúde é solicitada.

P16 deve documentar e verificar a proteção efetivamente implementada no dispositivo, navegador, servidor e backups. Campos sensíveis não podem aparecer em logs, URLs, relatórios de crash, cache de imagens ou snapshots de demonstração. Usar TLS, RLS e armazenamento protegido; avaliar o arquivo local real, pois o uso atual de SQLite não demonstra criptografia. Se for necessário um adaptador de armazenamento criptografado, usar biblioteca mantida e APIs da plataforma, com gestão de chaves por usuário; não criar criptografia própria nem prometer proteção de ponta a ponta sem implementá-la. Registrar o desenho de chaves, recuperação e limites da web antes de liberar dados reais. Esta verificação é trabalho do pacote, não motivo para interromper o planejamento.

**Exportação e exclusão.** Oferecer “Exportar meus registros do ciclo”; a exportação geral deve apresentar a escolha de incluir esses dados, desmarcada inicialmente. Avisar no momento do download que o arquivo contém informações íntimas. No nativo, usar arquivo temporário e removê-lo após o compartilhamento quando possível; o exportador atual grava no diretório de documentos e precisa desse ajuste para saúde.

“Apagar dados do ciclo” abre uma confirmação curta com escopo explícito; a ação final apaga logs, preferências íntimas, insights/cache e rascunhos sem excluir a conta. Limpar localmente e enfileirar a exclusão remota em uma transação. Offline, mostrar “apagados deste aparelho; exclusão dos dados sincronizados pendente”. Só declarar conclusão remota após confirmação do servidor. Na reconexão, processar a exclusão antes de qualquer upload/download do módulo. A geração remota invalida gravações antigas de outros aparelhos; tombstones sozinhos não devem ser assumidos suficientes para esse caso. Retenção de backups e eventual evidência mínima de consentimento precisam estar descritas na política, sem prometer apagamento instantâneo de cópias indisponíveis.

Desligar sincronização interrompe novos envios; oferecer separadamente apagar a cópia da nuvem. Revogar o tratamento permite exportar/apagar sem novos cálculos ou chamadas de IA. Identificar os relatórios e rascunhos derivados criados em P18 e incluí-los na gestão de exclusão; revogar uma autorização não desfaz uma transmissão já concluída.

## 6. Experiências detalhadas

### 6.1 Tarô — escolher e montar a mesa

**Ação:** selecionar cada carta entre as 78 disponíveis, com faces ocultas.

**Cena:** pergunta → leque → carta em foco acompanha o dedo → carta escolhida vai para um espaço da mesa → próxima posição se destaca → mesa completa vira → leitura.

**Layouts:**

| Tiragem | Posições | Layout proposto |
|---|---|---|
| Carta do dia | Carta do dia | Uma carta central, maior após a escolha. |
| Três cartas | Passado, Presente, Futuro | Linha de três cartas; apresentação compacta adaptável. |
| Cruz de cinco | Situação, Desafio, Raiz, Conselho, Tendência | Composição em cruz com rótulos; mapa visual próprio desta tiragem, sem apresentá-la como Cruz Celta. |

**Implementação:**

- Extrair a lógica de _startSpread para o controlador/repositórios.
- Renderizar apenas a faixa visível e uma margem do leque. Todas as 78 posições precisam ser alcançáveis.
- Desenhar verso compartilhado; carregar as frentes escolhidas na resolução necessária.
- Preservar o ID ao animar da origem ao destino. Calcular hit testing com a mesma geometria que posiciona as cartas.
- Tocar seleciona; exploração horizontal só muda a posição do leque. Retirada vertical confirma quando cruza a zona válida.
- Remover a carta escolhida sem reembaralhar as restantes. Bloquear a escolha repetida do mesmo ID.
- Reutilizar TarotFlipCard e seu comportamento web. Precarregar a frente antes de virar.
- Ao voltar de detalhes ou de interpretação, manter foco, posição da rolagem e mesa.
- Tornar “Nova tiragem” explícito para consultas que permitem novo resultado. Em Free, a política continua decidindo reutilização/bloqueio; a carta do dia escolhida permanece fixa.

**Aceite:** 1/3/5 seleções funcionam por toque e arraste; toda carta é acessível; nenhuma escolha é substituída por outro sorteio; retomada preserva ordem e resultado; uma mesa confirmada produz no máximo um consumo e um registro por sessão.

### 6.2 Runas — pedras e assentamento

**Ação:** selecionar pedras viradas sobre um tecido.

**Cena:** saquinho abre brevemente → pedras se espalham → pedra sob o dedo se eleva → escolha encaixa na mesa → símbolos se revelam → tocar uma pedra mostra seu significado.

**Layouts:** uma pedra central; linha de três; cruz nórdica de cinco; mesa de nove com disposição compacta 3×3 e rótulos de Eu interior, Mente, Espírito, Recursos, Obstáculos, Oportunidades, Passado, Presente e Futuro.

**Implementação:**

- Compartilhar o contrato de sessão; criar RuneSelectionSurface própria.
- Usar trajetórias controladas e pequenas variações visuais estáveis. Um motor completo de colisões não é requisito.
- A orientação do significado é um dado da sessão; a rotação de assentamento é decorativa.
- Exibir a pedra/símbolo como área central. Evitar que parágrafos inteiros sejam arremessados junto com ela.
- Não revelar a identidade de pedras ainda disponíveis, inclusive em rótulos de acessibilidade.
- Seleção da mesa destaca a interpretação correspondente; acesso à enciclopédia continua disponível.
- A revelação das nove runas cabe numa sequência conjunta breve, com antecipação.

**Aceite:** escolher 1/3/5/9 IDs sem repetição; respeitar a orientação já sorteada; manter a associação entre posição e interpretação; retomar sem novo consumo.

Fonte das posições: [rune_spread_model.dart](https://github.com/laylamonteiro/witchy-app/blob/6ea85d98cab5d5429617badbb606608cbc290567/lib/features/runes/data/models/rune_spread_model.dart).

### 6.3 Oráculo — cartas autorais e descoberta

**Ação:** selecionar 1/3/5 cartas e descobrir sua pequena cena.

**Cena:** seleção com a mesma física de cartas do tarô → carta chega à mesa → face ilustrada se revela → uma breve ação da ilustração → interpretação.

**Layouts:** mensagem do dia; passado/presente/futuro; orientação semanal com segunda/terça, quarta, quinta/sexta, fim de semana e foco. São cinco posições, não sete cartas.

**Catálogo de arte:**

- Produzir 44 frentes estáticas coerentes, um verso e uma moldura reutilizável. IDs, conteúdo e nomes continuam os existentes.
- Primeira entrega animada: A Vela, O Caldeirão, O Gato Preto, A Semente, A Chave e A Porta.
- Vela acende; caldeirão borbulha; gato abre os olhos; semente brota; chave gira; porta entreabre.
- As demais recebem revelação comum de moldura/luz. Animar todas individualmente não bloqueia a entrega completa do catálogo.
- A animação especial é breve. Em mesas grandes, a carta focalizada recebe a cena completa; as outras mostram a revelação comum.
- Não executar cinco cenas complexas em loop ao mesmo tempo.

**Álbum:**

- 44 espaços com arte encontrada ou verso/silhueta. Exibir a contagem real.
- Descobrir somente após a confirmação da leitura; olhar um catálogo de significados não equivale a tirar aquela carta.
- Uma carta repetida não gera nova descoberta, popup ou crédito de XP.
- Primeira carta recém-encontrada pode apresentar “Nova carta no seu Oráculo”; várias descobertas da mesma tiragem entram juntas na confirmação.
- Estado da coleção separado de “Salvar nos Registros”.
- Arte incompleta usa fallback; IDs desconhecidos não derrubam a leitura.

**Aceite:** todas as 44 cartas existem no registro visual; 1/3/5 seleções respeitam posições; álbum conta cartas únicas; retomada, sync e revisita não duplicam descobertas.

Fontes: [cartas](https://github.com/laylamonteiro/witchy-app/blob/6ea85d98cab5d5429617badbb606608cbc290567/lib/features/divination/data/data_sources/oracle_cards_data_pt.dart), [tiragens](https://github.com/laylamonteiro/witchy-app/blob/6ea85d98cab5d5429617badbb606608cbc290567/lib/features/divination/data/models/oracle_card_model.dart).

### 6.4 Conselheiro Místico — a consulta

**Ação:** escrever uma pergunta, consultar e guardar a orientação.

**Cena:** bola de cristal reduz ao abrir teclado → pergunta enviada vira citação → fio de luz chega à bola → névoa durante a requisição → névoa se abre e resposta ocupa a tela → guardar transforma resposta em página.

**Implementação:**

- Separar estado da requisição do estado da animação.
- Manter pergunta original visível e garantir que a operação use a versão capturada no envio.
- Substituir a espera artificial do typewriter por entrada breve dos parágrafos. Se houver typewriter como preferência futura, disponibilizar “Mostrar tudo”.
- Apresentar todo o conteúdo recebido sem depender da duração da névoa.
- Erro mantém a pergunta e uma ação de tentar novamente. Nenhuma resposta antiga é apresentada como nova.
- “Guardar conselho” usa FreeWritingSource.advisor, título identificável e data; atualizar filtros e renderização de “Meus Registros”.
- Persistir localmente a resposta recebida em advisor_consultations com seu ID. Uma consulta cuja resposta não chegou não é retomada por novo envio automático; o usuário vê o estado e pode iniciar uma nova tentativa explícita.
- Guardar é idempotente por resposta/sessão. A confirmação só aparece após sucesso.
- Preservar os gates e consumo existentes. Envio de nova pergunta é explícito.
- Nas interpretações de tarô/runas/oráculo, usar uma versão compacta da mesma área de consulta. Manter a mesa visível e entrada da explicação abaixo.

**Aceite:** teclado não encobre a ação; requisição rápida produz resultado rápido; falha preserva texto; uma resposta atrasada não substitui outra; guardar não duplica; resposta é legível com movimento reduzido.

Fonte: [mystic_advisor_page.dart](https://github.com/laylamonteiro/witchy-app/blob/6ea85d98cab5d5429617badbb606608cbc290567/lib/features/grimoire/presentation/pages/mystic_advisor_page.dart).

### 6.5 Grimório Vivo, trilhas e rituais guiados

**Lição:** ao selar, a página recebe selo de cera; o ganho confirmado aparece; o progresso avança.

**Trilha:** a última página se junta às demais, o livro fecha e recebe a capa/título da trilha. O livro concluído fica visível numa coleção de trilhas, derivada do progresso já existente.

**Ritual guiado:** cada passo concluído acende um trecho do círculo ritual. Ao completar, o círculo fecha e o registro confirmado entra na jornada.

**Implementação:**

- Reutilizar LessonReward como origem do resultado das lições.
- Preservar 25 XP por lição e o bônus atual de 100 por trilha; não somar novamente esse bônus no overlay.
- Se lição, trilha e nível acontecem juntos, priorizar a cena do livro e incluir os demais resultados nela.
- Checkboxes dos rituais continuam editáveis. A conclusão registrada é identificada; reabrir ou desmarcar/marcar não cria outra ocorrência da mesma sessão.
- Antes de anunciar conclusão de ritual, aguardar o sucesso de logCompletion. Falha oferece retomada da gravação.
- Capas são associadas a IDs de trilha, com títulos localizados renderizados pela UI.
- Subida de nível durante uma prática usa a mesma apresentação da subida durante lições.

**Aceite:** bônus correto e único; livro só aparece concluído quando a trilha realmente está completa; falha de salvamento não celebra sucesso; animação pode ser antecipada.

### 6.6 Sigilos e desejos

**Sigilo:** intenção → letras removidas se dissipam → letras restantes se organizam → traço percorre os pontos → símbolo assenta → salvamento.

**Implementação:**

- Manter as regras existentes de processamento da intenção. Animação apresenta a transformação; não recalcula outra regra.
- Estender SigilDrawingPainter com progresso do caminho. Medir e reutilizar o percurso quando dados/tamanho mudam.
- Embaralhar letras interpola posições antigas e novas; o caminho acompanha a geometria correta.
- Exportar e salvar imagem sempre usa o estado final, sem capturar um traçado pela metade.
- Respeitar as decisões atuais sobre intenção secreta e título fixo em desejos de sigilo.
- Disparar efeito de salvamento após persistência; o componente receptor pode continuar a confirmação quando a tela de criação fechar.

**Desejos:** transição para manifested recebe selo “Realizado”; transição para released solta um fio de luz. Editar o título de um desejo já realizado não repete a celebração.

**Aceite:** desenho final e exportação iguais ao resultado esperado; rotação/reorganização não altera intenção; mudança de status tem feedback próprio e não gera XP artificial.

### 6.7 Progresso, jornadas, diário e gatinho

Criar uma composição de resultado por ação confirmada.

Exemplo: ao salvar o décimo sonho, a entrada se acomoda na lista, uma constelação se completa e aparece “Sonhador Dedicado — 10 sonhos registrados”. Se a ação também fecha o dia ou muda o nível, incluir a informação no mesmo conjunto.

**Fórmula existente a preservar:**

| Origem | Regra atual |
|---|---|
| Lição concluída | 25 XP |
| Trilha concluída | Bônus de 100 XP |
| Ritual guiado registrado | 10 XP por ocorrência na fórmula de práticas |
| Criações elegíveis | 5 XP por registro elegível |
| Rito exploratório registrado | 3 XP |
| Dia completo | Bônus de 15 XP |
| Free writings / guardar conselho ou leitura | Não fazem parte da lista atual de criações que gera 5 XP |
| Descobrir carta do álbum | Sem XP adicional nesta entrega |

Criações elegíveis atuais: feitiços próprios, sonhos, gratidões, afirmações próprias, desejos, sigilos e entradas pessoais da enciclopédia. Pré-carregados continuam excluídos onde a fórmula já os exclui.

**Implementação:**

- Capturar progresso antes da mutação, persistir a ação, recalcular e produzir ActionOutcome. Serializar a avaliação por conta para não atribuir a uma ação os pontos de outra concorrente.
- ActionOutcome inclui action_id, user_id, origem, entidade, confirmação de persistência, XP antes/depois, novo nível e marcos novos.
- Identificar níveis por chave estável ou limiar, nunca pelo título traduzido. Uma troca de idioma não representa mudança de nível.
- Extrair o cálculo de dia completo da UI para serviço chamado pelas ações pertinentes. Manter exatamente os três requisitos e a política atual de acesso.
- Atualizar jornadas incluindo tarot_readings em all_readings. Retrospectiva silenciosa corrige o total disponível, sem mostrar uma conquista antiga como recém-obtida.
- Guardar marcos adquiridos por ID; não conceder novamente ao reduzir e recuperar uma contagem.
- Mostrar somente as apresentações originadas por ações desta sessão de uso; sync e load inicial atualizam a UI silenciosamente.
- Se uma confirmação ocorrer em rota que está fechando, entregar o feedback ao destino adequado. Não depender de um BuildContext descartado.
- O gatinho recebe comando happy/celebrate curto por outcome. Não reaparece se foi ocultado, não interrompe arraste nem atropela o tour; reação pode ser omitida se inadequada.
- Autosave de texto recebe confirmação discreta; não gerar uma cena por tecla, perda de foco ou edição.

**Aceite:** ganho exibido corresponde ao cálculo persistido; marco é único; dia completo não depende de visitar a home; mesma ação não produz várias caixas de celebração.

### 6.8 Quiz de tarô e arquétipos

**Quiz de tarô:** acerto acende uma estrela; sequências conectam estrelas; resultado reúne a constelação da sessão.

- Usar os acertos/combos existentes, sem inventar níveis novos.
- Texto explicativo e próxima ação continuam acessíveis; permitir avançar quando pronto em vez de depender sempre de atraso fixo.
- Erro destaca a resposta correta e reseta o combo conforme regra atual; não retira XP nem usa uma animação de punição.
- Concluir sessão não concede XP extra sem regra existente.

**Arquétipos:** respostas selecionadas convergem para uma composição que revela arte e nome do resultado. Não apresentar opções como certas/erradas.

- Retomar resultado salvo é imediato.
- Refazer o quiz cria uma nova execução; a animação não altera a pontuação.
- Registrar um marco de descoberta somente se previsto no catálogo de conquistas, uma vez por usuário.

**Aceite:** scores iguais aos atuais com e sem animação; nada selecionável durante uma transição representa a pergunta anterior; revisita não refaz a apresentação.

### 6.9 Guia da Natureza

**Ação:** escolher erva ou cristal, fornecer foto, identificar/revisar e salvar o verbete.

**Cena:** categoria expande para moldura da foto → indicação de processamento real → candidatos ou ficha aparecem → ao salvar, a ficha entra no acervo.

- Reutilizar o fluxo atual de AddEntryPage e seus gates. Na identificação de ervas, múltiplos candidatos devem continuar sendo uma escolha explícita.
- A animação de análise usa apenas a moldura/ambiente; não desenha detecções, contornos ou percentuais que o serviço não retorna.
- A ficha resultante acompanha os dados reais e mantém sua possibilidade de edição.
- “Descoberta salva” e rito só são confirmados após o salvamento efetivo, conforme o fluxo atual.
- Falha/cancelamento mantém a foto e campos quando aplicável. Trocar foto invalida o resultado anterior.

**Aceite:** candidatos e confiança reais preservados; nenhuma escolha de imagem dispara upload por causa da animação; preview Premium mantém o fluxo autorizado.

### 6.10 Sonhos em Ferramentas

**Ação:** consultar temas/interpretação e guardar o sonho.

**Cena:** relato vira página em foco → névoa de espera no cabeçalho → interpretação aparece em blocos → página se acomoda no diário após salvar.

- Manter o texto e a data informados, limites atuais e classificação da entrada salva.
- Termos ou símbolos só recebem destaque se existirem nos dados retornados; não inventar análise extra para preencher a cena.
- Usar o mesmo feedback de salvamento do diário. Se fechar os ritos do dia, consolidar a celebração.
- Navegação por temas recebe expansão e continuidade, sem obrigar uma consulta de IA.

**Aceite:** não perder rascunho ao falhar; salvar uma vez; revisão de um sonho existente não conta como novo registro.

### 6.11 Quiromancia

**Ação:** fornecer foto e solicitar leitura.

**Cena:** foto entra numa moldura → brilho percorre a borda durante a análise → resultado abre abaixo → salvamento vira registro.

- O serviço atual devolve uma leitura textual. Não desenhar linhas “detectadas” na mão sem coordenadas reais fornecidas pelo serviço.
- Manter os limites de imagem, compressão, gates e política de uso; a animação não altera uploads.
- Não abrir o seletor nem enviar foto quando o fluxo atual só permite mostrar a prévia.
- Renderizar a leitura ao chegar. Trocar de conta/cancelar impede um resultado antigo de aparecer no contexto errado.

**Aceite:** preview, erro, foto inválida e sucesso possuem estados visuais distintos; a UI nunca apresenta uma análise que não recebeu.

### 6.12 Numerologia

**Perfil:** após calcular, os valores retornados ocupam medalhões; uma sequência curta destaca cada resultado.

**Consulta de número:** o número digitado se desloca para o cabeçalho do significado.

**Horas iguais e sequências:** o item escolhido expande para sua explicação, mantendo o número como elemento de continuidade.

- Valores finais vêm de NumerologyCalculator. Se a animação mostrar etapas aritméticas, o domínio deve fornecer essas etapas e respeitar suas regras, inclusive números que não são reduzidos.
- Não simular cálculos aleatórios em roletas.
- Explicação por IA usa o mesmo painel assíncrono do Conselheiro, sem refazer a chamada quando só a animação reinicia.
- Nome/data alterados invalidam a explicação conforme o comportamento atual.

**Aceite:** resultados matemáticos inalterados; revisita de perfil salvo sem nova geração; textos extensos legíveis.

### 6.13 Pêndulo

O pêndulo já possui oscilação, desaceleração, revelação e integração decorativa com o sensor. Concentrar a melhoria na continuidade entre pergunta, instrumento, resposta e registro.

- Ao enviar, a pergunta se acomoda acima da área do instrumento.
- A resposta ganha foco no final da oscilação; detalhes entram em seguida.
- Durante a leitura, reduzir a competição visual do instrumento.
- Preservar a separação entre sorteio da resposta e sensor, que é decorativo.
- Guardar usa a confirmação compartilhada; não gerar outra consulta para rever a cena.

**Aceite:** resposta independente do movimento do aparelho; sensores e animações param fora de cena; limites atuais preservados.

### 6.14 Entrada de Ferramentas e navegação

O catálogo tem 12 entradas: Grimório Vivo, Conselheiro, Sigilos, Guia da Natureza, Tarô, Sonhos, Quiromancia, Runas, Oráculo, Pêndulo, Arquétipos e Numerologia.

- Substituir progressivamente emojis de destaque por pequenas artes coerentes com cada ferramenta.
- No toque, o objeto visual do card pode continuar na tela de destino. A animação não atrasa a navegação por uma sequência obrigatória.
- Manter grupos, títulos e explicações existentes; priorizar espaço para conteúdo.
- Entradas escalonadas não reexecutam a cada retorno à aba.
- Só usar transições de elemento compartilhado quando a mesma identidade e o destino estão disponíveis; senão usar GrimoireRoute.
- Respeitar histórico, gesto de voltar, re-toque da aba, teclado e rotas existentes.

**Aceite:** as 12 ferramentas continuam acessíveis pelos mesmos caminhos; voltar preserva o contexto; nenhum elemento interativo depende apenas de hover.

Fonte do catálogo: [grimoire_page.dart](https://github.com/laylamonteiro/witchy-app/blob/6ea85d98cab5d5429617badbb606608cbc290567/lib/features/grimoire/presentation/pages/grimoire_page.dart).


### 6.15 Ciclo Menstrual — a roda pessoal dentro de Ciclos

**Intenção:** transformar o registro em um gesto de atenção ao próprio corpo e permitir explorar sua relação simbólica com o céu. A identidade principal é um calendário vivo com uma roda pessoal. As descobertas vêm da exploração do histórico; registrar sangramento não vira obrigação, competição ou tarefa para ganhar pontos.

#### A. Escopo e regras preservadas

| Tema | Decisão deste lote |
|---|---|
| Local | Cartão “Ciclo Menstrual” na aba Ciclos, depois da Leitura do Ciclo e antes de Suas Eras. Rótulo poético secundário: “Sua roda pessoal”. |
| Visibilidade | Apenas Gender.feminine ou Gender.neutral; Gender.masculine não recebe cartão, teaser ou oferta dessa funcionalidade. |
| Registro Free | Registrar e consultar datas/fluxo/sintomas/humor/notas informados, editar, excluir e exportar. Histórico e calendário mostram apenas os dados inseridos. |
| Análise Premium | AuthProvider.isPremiumEffective, incluindo assinatura, código e vitalício: cálculos, médias, estimativas, estações personalizadas, cruzamentos lunares e uso menstrual na Leitura do Ciclo. |
| Registro | Manual, com início/fim, fluxo/escape e campos opcionais. Nenhuma integração direta com Flo. |
| Núcleo | Calendário com Lua do dia, registros pessoais, Estações Internas e links curados da Enciclopédia. |
| Conteúdo | PT/EN/ES versionado, voz acolhedora, espiritualidade apresentada como simbolismo. |
| Histórico | Free consulta os registros originais. Premium recebe comparação lunar desde os primeiros registros e resumo de três ciclos completos quando houver histórico suficiente. |
| IA | Integração obrigatória neste lote para Premium com a análise completa da Leitura do Ciclo; dados selecionados entram após consentimento específico. O registro e calendário bruto funcionam sem IA. |
| Fora do lote | Fertilidade/anticoncepção, diagnóstico, instruções com fluidos corporais, comunidade social e importação HealthKit/Health Connect. |


**Matriz de acesso que prevalece sobre o brainstorm:**

| Capacidade | Free | Premium efetivo |
|---|---|---|
| Inserir menstruação, início/fim, fluxo/escape e campos opcionais | Sim | Sim |
| Consultar, corrigir e excluir os próprios registros | Sim | Sim |
| Calendário/lista com datas e dados digitados | Sim | Sim |
| Animações de entrada, edição e confirmação de salvamento | Sim | Sim |
| Sincronizar registros manuais mediante consentimento | Sim, pelo mecanismo de conta existente | Sim |
| Gestão de consentimento e exportação dos dados pessoais | Sim | Sim |
| Dia calculado do ciclo, duração de episódios, médias, intervalos e tendências | Não | Sim |
| Estimativas de próximas datas e resumos do histórico | Não | Sim |
| Cruzamento pessoal com a Lua, roda comparativa e Lua Branca/Vermelha | Não | Sim |
| Estações, conteúdo e correspondências personalizados nessa área | Não | Sim |
| Uso dos registros na Leitura do Ciclo completa ou semanal | Não | Sim, com consentimento e acesso à leitura |

**Dado inserido versus derivado:** “você marcou fluxo no dia 8” é consulta ao registro; “dia 4 do ciclo”, “média de 30 dias”, “três dias de sangramento” ou “o início coincidiu com a Lua Cheia” já são resultados derivados e ficam no Premium. Uma contagem técnica na confirmação de exportação/exclusão serve para informar o alcance da operação, não é um painel analítico. Recursos gerais do app, como consultar a Lua sem relacioná-la ao histórico menstrual, mantêm suas regras atuais.

O Free abre direto a experiência de registro após consentimento, sem comprar assinatura primeiro. Exibir um convite genérico para conhecer os recursos Premium quando a pessoa abrir uma área paga; não calcular um insight pessoal para escondê-lo atrás de blur nem usar sintomas/ausência de registro para ofertas. As animações básicas têm o mesmo acabamento nos dois planos. Após upgrade, os registros manuais já existentes ficam disponíveis para os cálculos sem nova digitação; o envio à IA ainda requer autorização própria.

#### B. Jornada de uso e composição da tela

1. **Cartão em Ciclos.** Miniatura da roda e CTA claro. Antes da ativação, texto de apresentação sem “dados de exemplo” que pareçam pessoais. Após ativar, o cartão segue discreto; mostrar dia/estação no cartão exige preferência explícita. A feature não depende do mapa astral nem de terminar o carregamento de Eras.
2. **Primeira abertura.** Explicar que o registro manual é gratuito e análises são Premium. Solicitar consentimento de registro e abrir o formulário/calendário Free sem etapa de compra. O acesso às áreas pagas segue a matriz; não coletar dados no fluxo de oferta.
3. **Visão “Hoje”.** No Free, cabeçalho com data, dados realmente registrados, calendário simples e botão “Registrar”. No Premium, acrescentar roda comparativa, Lua relacionada aos registros, Estação Interna e convites personalizados. Os rótulos distinguem fase celeste, observação corporal e metáfora. Notas livres permanecem acessíveis no formulário Free.
4. **Registrar.** Painel inferior com data e escolha explícita: início, dia de fluxo, escape, fim ou somente anotação. Fluxo, sintomas, humor e nota são opcionais. “Começou hoje” é atalho, sem presumir início a partir de um escape. Editar data retroativa mantém a data visível junto ao botão de salvar.
5. **Salvamento.** Validar e persistir primeiro; então integrar uma marca ao dia correspondente. “Registro salvo” significa gravação local concluída. Se o sync estiver ativo, seu estado aparece separadamente. Em falha, preservar o formulário em memória, manter edição e permitir tentar novamente.
6. **Calendário.** Tocar um dia abre seu detalhe; deslizar percorre datas e dados inseridos. No Premium, habilitar linha do tempo comparativa e atualizar a Lua relacionada às observações. Botões anterior/próximo fazem a mesma ação. Um dia vazio significa “sem registro”, nunca “sem sintomas”. Free não recebe médias, dia calculado do ciclo ou comparações dentro do calendário.
7. **Sua estação — Premium.** A pessoa escolhe o vocabulário que combina com o dia, lê um convite e pode escrever ali mesmo. Essa escrita permanece dentro do registro íntimo no MVP. Não enviá-la silenciosamente ao Diário geral, ao acervo ou à IA.
8. **Você e a Lua — Premium.** Histórico comparável dos inícios, com datas e fase lunar estimada. Com três intervalos completos elegíveis, um resumo aparece na própria página. Sem popup ao abrir outra ferramenta e sem notificação que revele saúde.

**Roda visual — Premium.** Usar a mesma escala de datas nos dois anéis: o externo mostra a Lua estimada para cada dia; o interno mostra somente registros reais nesse intervalo. O centro mostra o dia selecionado e a estação escolhida, quando existir. Não desenhar um anel de 28 dias esticado até coincidir com uma lunação. O calendário mensal é a alternativa explícita para quem não quiser explorar a roda. Indicadores e legenda distinguem registro, estimativa e escolha simbólica também por forma/texto, além de cor.

#### C. Animações ligadas a ações

Entrada da página, calendário bruto, edição e confirmação de registro funcionam também no Free. Cenas que apresentam dados derivados, estações, comparação lunar ou análise só são montadas após o gate Premium; o Free usa um calendário simples bem acabado.

| Ação | Resposta visual | Regras de execução |
|---|---|---|
| Abrir o módulo | A pequena roda do cartão amplia e se acomoda no cabeçalho. | 300–450 ms; respeitar retorno, teclado e movimento reduzido. Sem sequência obrigatória em toda visita. |
| Salvar registro | Uma marca de tinta suave preenche o dia; um arco curto a conecta à posição do calendário. | 220–350 ms, após commit. Sem simulação realista de sangue; cor não indica gravidade. |
| Percorrer datas com o dedo | Cursor acompanha a posição; Lua e detalhe transitam juntos. | Resposta direta ao gesto, sem atraso de easing no cursor. Nunca alterar registros ao soltar. |
| Mudar de mês | Datas deslizam e a roda recompõe o intervalo escolhido. | 220–300 ms; seleção e foco previsíveis. Sem giro de várias voltas. |
| Escolher estação | Vinheta muda por camadas: repouso, broto, flor aberta ou folha. | Transição de 350–500 ms. Animação reage à escolha, não altera dados de fase. |
| Abrir prática simbólica | Um pequeno cartão se expande junto ao conteúdo. | Reaproveitar transição de conteúdo; texto imediatamente acessível. Não usar leque de cartas nesta área. |
| Guardar escrita íntima | Um selo discreto aparece no próprio registro. | Reutilizar linguagem visual do diário, com armazenamento e origem separados. Sem XP. |
| Abrir comparação lunar | Marcadores de inícios aparecem sobre o calendário; uma linha destaca a data em foco. | Entrada única de 400–600 ms, antecipável. Não conectar pontos como prova de causalidade. |
| Editar ou apagar um dia | Atualizar/recolher a marca e recalcular o resumo. | Após persistência; sem celebração, sem reexecutar “descoberta”. |

**Atmosfera por estação.** Inverno: brilho pequeno e repouso visual; Primavera: broto que se abre uma vez; Verão: flor/luz difusa se acomoda; Outono: folha muda de posição suavemente. Manter a paleta dos temas existentes, com acentos por estação e contraste suficiente. O estado parado precisa continuar bonito. Evitar loops de partículas, respiração obrigatória, efeitos de tela inteira e sons automáticos. Haptics são opcionais e, no calendário, limitados à mudança de dia com frequência controlada.

**Movimento reduzido:** marca aparece pronta, detalhe troca por fade curto ou imediatamente, roda permanece estática. TalkBack/VoiceOver e teclado recebem data, tipo de registro, valor selecionado e Lua em texto. A árvore semântica não anuncia cada frame. O gesto horizontal deve ter área própria para não competir com scroll vertical ou gesto de voltar.

#### D. O que é observado, estimado e simbólico

O brainstorm associa quatro fases biológicas a quatro estações. Essa correspondência pode orientar conteúdo educativo, mas o app não deve apresentar uma fase ovulatória confirmada a partir de datas de sangramento. O intervalo entre ovulação e a próxima menstruação varia, e ovulação pode não acontecer em determinados ciclos. Essa limitação fundamenta separar os modelos e os rótulos de produto. [Office on Women’s Health — ciclo menstrual](https://womenshealth.gov/menstrual-cycle/your-menstrual-cycle).

**Decisão para o MVP:** manter as quatro Estações Internas como escolhas simbólicas ajustáveis. Ao registrar menstruação, o app pode convidar a explorar Inverno; a pessoa pode preferir outra estação ou nenhuma. Nas demais datas, oferecer as quatro escolhas, sem deduzir humor, hormônios ou fase do corpo. A automatização das quatro fases por média, proposta no brainstorm, fica substituída por este modelo explícito; uma média pessoal é útil para observar intervalos, não confirma quatro fases fisiológicas.

| Estação simbólica | Convite de conteúdo | Exemplo de pergunta |
|---|---|---|
| Inverno | Pausa, abrigo e atenção ao que precisa de cuidado. | “O que você gostaria de acolher hoje?” |
| Primavera | Curiosidade e pequenos começos, se fizerem sentido. | “Que intenção merece um primeiro gesto?” |
| Verão | Expressão e conexão como possibilidades. | “O que você quer compartilhar ou celebrar?” |
| Outono | Revisão, limites e escolha do que deixar ir. | “O que pode ficar mais leve para você?” |

Usar `InternalSeason { winter, spring, summer, autumn }` para apresentação e conteúdo. Se `CyclePhase` for usado no material educativo, mantê-lo separado do estado observado. Campos desconhecidos são desconhecidos; não usar um enum obrigatório que force a seleção de uma fase biológica. Não exigir informar contraceptivo, gravidez ou diagnóstico para desligar estimativas. “Acompanhar sem estimativas” atende também quem tem ciclos irregulares, sangramentos ausentes ou prefere apenas registrar.

**Estimativa simples de próxima menstruação, opt-in:**

- Um ciclo completo entre inícios é a diferença entre dois inícios consecutivos válidos. Três intervalos completos requerem pelo menos **quatro inícios**, com continuidade confirmada do histórico. Três episódios de sangramento encerrados não são automaticamente três intervalos completos.
- Inícios duplicados, dados futuros e intervalos marcados como incompletos não entram no cálculo. Não remover intervalos longos só por parecerem diferentes. Se há menstruações não registradas, permitir marcar a lacuna; não interpretar o intervalo inteiro como ciclo confirmado.
- Quando ativada e com pelo menos três intervalos elegíveis, mostrar média e faixa observadas em até seis intervalos recentes; para referência central da próxima data, usar a mediana. Identificar o tamanho da amostra. Exibir a faixa como “seus intervalos registrados”, sem chamá-la de intervalo de confiança ou prometer que a próxima data cairá ali.
- Não renovar a previsão somando ciclos fictícios se a data passar. Continuar registrando e informar que a estimativa está desatualizada, sem mensagem de atraso, gravidez ou anormalidade. A pessoa pode desligá-la a qualquer momento.
- No MVP, nenhuma janela fértil, dia de ovulação, chance de gravidez ou recomendação contraceptiva. A ferramenta mantém finalidade de registro e autoconhecimento. O NHS descreve acompanhamento de fertilidade com outros sinais e orientação própria; este módulo não implementa esse método. [NHS — natural family planning](https://www.nhs.uk/contraception/methods-of-contraception/natural-family-planning/).

As regras numéricas acima são heurísticas de produto propostas, versionadas e testáveis; não são validação clínica. Editar/apagar um início invalida os cálculos dependentes imediatamente. Sem histórico suficiente, continuar mostrando calendário, Lua e conteúdo escolhido, sem fabricar datas.

#### E. Comparação lunar e Lua Branca/Vermelha

Para Premium, o valor inicial é concreto: “qual era a Lua nas datas que registrei?”. Ele existe desde o primeiro início, sem esperar meses para a feature fazer sentido. No Free, o valor imediato é registrar e recuperar o histórico manual; não executar ou apresentar esse cruzamento. O resumo de recorrência respeita o mínimo de três ciclos completos do brainstorm.

1. Usar `LunarProvider.phaseOn` para a Lua do calendário, preservando sua convenção aproximada. Para registros sem hora, usar o meio-dia no fuso de referência guardado, identificado internamente como convenção de cálculo; não é o horário do sangramento. Mudança de fuso do aparelho não reclassifica o histórico por acidente.
2. Para comparar proximidade de Lua Nova/Cheia, expor em uma função pura compartilhada a posição contínua já usada no cálculo lunar. Evitar duplicar constantes. A assimetria dos enums atuais não deve escolher a categoria simbólica.
3. Adotar uma janela simétrica inicial de **±2 dias** em torno de Nova e Cheia. É uma convenção de apresentação, não uma definição histórica ou fisiológica. Testar limites e versionar o algoritmo; a UI informa a janela usada e que as fases são estimativas do app.
4. O resumo usa os inícios dos três intervalos completos elegíveis mais recentes. O quarto início fecha o terceiro intervalo e permanece visível na linha do tempo; não entra silenciosamente como uma quarta observação no denominador de três.
5. Exibir contagens e datas: “Em 2 dos 3 ciclos completos observados, o início ficou até 2 dias da Lua Cheia estimada pelo app”. Sempre permitir abrir as observações. Nenhum percentual de “sincronia”, pontuação, ranking ou previsão de que isso voltará a acontecer.
6. “Lua Branca” perto da Nova e “Lua Vermelha” perto da Cheia são a convenção simbólica proposta no brainstorm. Apresentar, quando editorialmente validada, em “Explorar este simbolismo”; não atribuir automaticamente “você é uma Bruxa X”. Repetição de 2/3 pode destacar um conteúdo, mas não demonstra um padrão estatístico.
7. Corrigir o exemplo do brainstorm: início perto da **minguante não significa Lua Vermelha** nessa convenção. Para outras fases ou distribuição variada, mostrar o que foi observado e oferecer conteúdo lunar genérico, sem forçar uma categoria.
8. A linguagem não afirma que a Lua controla o ciclo, que há alinhamento correto, que um padrão é mais comum ou que ele define maternidade, vocação, poder ou saúde. Datas próximas autorizam uma comparação e uma leitura poética, não uma conclusão causal.

O resumo é calculado localmente, sem IA. Com histórico importado manualmente pela pessoa, pode ficar disponível imediatamente quando os critérios forem atendidos. A cena aparece ao abrir o resumo, uma vez por revisão; edição e sincronização não criam conquistas. Se a revisão cair abaixo do mínimo, retirar o resumo e explicar a mudança sem apagar os registros restantes.

#### F. Conteúdo, Enciclopédia e revisão do brainstorm

Criar `menstrual_phase_content.dart` e variantes `_pt/_en/_es.dart` conforme o padrão de LifeErasContent. Cada estação tem chave estável, título, texto de convite, duas ou três práticas leves, pergunta de escrita, links curados e versão editorial. Os nomes técnicos dos arquivos podem preservar “phase”, mas o contrato público usa estação simbólica. Não produzir previsões psicológicas obrigatórias como “você estará irritada” ou “sua confiança está no pico”.

**Correspondências:** duas ou três entradas existentes por estação, com título “Correspondências simbólicas”. `intentions` serve para procurar candidatos durante curadoria; não é recomendador clínico em runtime. O modelo de cristal lido não possui ID: criar uma pequena camada de chaves estáveis e resolução por catálogo/idioma, preservando URLs e telas existentes. Validar se descrição e uso da entrada de destino são adequados antes de incluí-la. Não copiar sugestões de ingestão, elixires, tratamento de cólica ou regulação hormonal para este módulo.

| Afirmação do brainstorm | Tratamento neste plano |
|---|---|
| “Visão de prata” irlandesa/escocesa, práticas dos Bálcãs e generalizações sobre povos indígenas | Não verificadas por esta revisão. Não publicar como fato histórico com base apenas nos blogs citados. Exigir fonte identificável e contexto antes de usar. |
| Lua Vermelha/Branca e atribuição a Miranda Gray | Referência editorial fornecida no brainstorm; confirmar trecho, edição e atribuição antes de publicar. O app pode lançar a comparação de datas sem esses títulos. |
| Quatro estações e arquétipos | Linguagem simbólica contemporânea do produto, opcional e sem equivalência fisiológica obrigatória. A Roda do Ano inspira a forma visual; não determina a fase corporal. |
| Cristais ou ervas que “ajudam hormônios”, “absorvem dor” ou “regulam fluxo” | Retirar essas promessas do conteúdo menstrual. Links por afinidade simbólica, com revisão também da página de destino. |
| Ritos com fluido corporal e Tenda Vermelha | Fora das ações do módulo; eventual conteúdo cultural depende de contexto e fontes, sem instrução prática com fluidos. |
| Concorrente Lunari e alegação de exclusividade | Não sustentam requisitos nem publicidade deste plano. A vantagem proposta é a integração com o Grimório existente; não afirmar exclusividade de mercado. |

Não é necessário resolver toda a pesquisa histórica para lançar o calendário. Conteúdo incerto pode ficar fora do catálogo público enquanto os textos originais de autocuidado simbólico e exploração lunar entram completos em três idiomas. Nenhuma afirmação do brainstorm é tratada como verificada apenas por declarar que foi pesquisada em setembro de 2026.

#### G. Integrações e limites do primeiro lançamento

**Roda do Ano:** compartilhar traços, materiais e animação de abertura quando houver componentes adequados. Não reutilizar o cálculo de sabbats para estimar corpo. Estação interna não muda por hemisfério nem implica coincidir com a estação externa; ambas podem ser mostradas com nomes distintos.

**Calendário lunar e céu do mês:** abrir a data escolhida e preservar o retorno. Preferir função pura para consultar a Lua, sem alterar globalmente `selectedDate` só por passar o dedo na roda pessoal. Não copiar dados de saúde para MonthSkyCard ou para telas públicas de calendário.

**Diário:** convite de escrita reutiliza componentes de editor, mas persiste em `menstrual_logs` no MVP. Uma futura ação “Copiar para meu diário” precisará explicar o novo destino e preservar a origem íntima nos filtros; copiar para free_writings e deixar includeJournals=true abriria um caminho indireto para a IA. Essa cópia não é pré-requisito do lote.

**Leitura do Ciclo — incluída neste lote por decisão da Layla.** O módulo menstrual é a quinta família de fontes da análise completa, com o mesmo valor narrativo das outras fontes autorizadas. O relatório deve poder relacionar registros do corpo, diário, práticas, escolhas e contexto lunar. Não limitar essa integração a um cartão isolado ou apêndice. A seção H especifica como incorporá-la às seções existentes, mantendo fatos observados e simbolismo identificáveis.

**Gatinho e gamificação:** Salem pode manter sua presença habitual e reagir a uma interação direta com ele. O registro menstrual não gera fala pública, badge, XP, tarefa diária ou punição por ausência. A sensação de evolução vem da roda se tornar pessoal e do histórico ficar explorável. Nenhuma estação vale mais que outra.

**Health/Flo — secundário:** o registro manual é o caminho principal e completo do produto. Manter HealthKit/Health Connect fora das dependências e permissões do lote; nenhuma tela, cálculo ou animação espera por essa integração. Uma fase futura nativa precisa verificar os tipos de dados efetivamente disponíveis, consentimento de leitura, origem, IDs de importação, duplicação e reconciliação com registros manuais. Não prometer que dados de qualquer app específico chegarão por essa via. Web mantém registro manual.


#### H. Análise completa da Leitura do Ciclo — contrato de P18

**Resultado de produto.** Uma pessoa com Premium efetivo pode autorizar, por exemplo, dias em que registrou fluxo, cansaço e uma preferência de repouso. A leitura poderá relacionar essas observações às práticas ou escritos dos mesmos dias e à Lua calculada pelo app, quando os dados sustentarem a relação. O texto não deve afirmar que o ciclo causou um conflito ou que a Lua provocou um sintoma. A escolha de Inverno, por exemplo, é uma preferência simbólica registrada pela pessoa, não uma fase hormonal detectada.

**Acesso à análise.** Exigir Premium efetivo para incluir a fonte menstrual, além do consentimento e das regras de crédito/direito de leitura já existentes. Premium libera esta fonte; este plano não concede créditos de Leitura do Ciclo nem altera seus preços. Quem usa Free e tem acesso a uma leitura pelas regras atuais continua podendo usar as outras fontes, sem registros ou dados derivados menstruais. Revalidar o benefício ao iniciar, antes de cada capítulo, ao salvar e ao abrir conteúdo analítico; expiração ou revogação bloqueia continuidade e resultados atrasados da fonte paga.

**Seleção antes de gerar.** Acrescentar “Ciclo Menstrual” à tela de fontes em `cycle_reading_intro_page.dart`. `includeMenstrual` começa false; somente com Premium efetivo acioná-lo abre uma prévia dos registros dentro da janela da leitura. Oferecer seleção individual e “Incluir todos deste período”, como ação explícita sobre os registros atualmente mostrados. Informar a quantidade e os campos; notas livres vêm desmarcadas e podem ser incluídas separadamente. O botão final confirma o escopo e inicia a geração. Não pedir a mesma autorização a cada capítulo: revalidar sua vigência silenciosamente antes de cada request.

Depois de autorizado, o escopo vale para aquela geração e seus retries compatíveis; não abrange novos registros futuros. Uma nova geração mostra novamente a seleção anterior para revisão e exige confirmar o escopo atual. A tela também informa que a análise será guardada no acervo e poderá conter os dados selecionados. Participar da análise não depende de ter três ciclos completos: esse mínimo só limita estimativas/resumos históricos. Um único registro autorizado pode enriquecer uma leitura, sem que o modelo invente o restante do ciclo.

**Composição do material.** Criar `MenstrualReadingContext` com IDs/versões autorizados localmente, datas civis, observações selecionadas, estação escolhida opcional, correspondências lunares calculadas e cobertura dos registros. Incluir no request somente os campos efetivamente autorizados e necessários, dentro de um orçamento documentado de tamanho. Não enviar IDs de conta, trilha de consentimento ou histórico inteiro como conveniência. Datas retroativas são filtradas pela data observada, não pelo created_at da digitação.

O intervalo da leitura mantém a convenção existente `[start, end)`, convertido para datas civis de forma consistente com o fuso da leitura. Limitar os registros à janela selecionada. Qualquer resumo que use histórico anterior precisa aparecer na prévia com o período e as fontes abrangidas; não consultar meses extras silenciosamente. Estação sugerida, campo ausente e dado observado têm marcadores distintos; um dia vazio não significa ausência de sintomas.

**Integração por seção.** O código atual gera 11 seções de IA na lunação e oito na semana; manter essa estrutura e os preços existentes. O conteúdo menstrual é distribuído pela finalidade de cada seção. “Análise completa” significa que o relatório incorpora a fonte onde houver relação sustentada, sem repetir detalhes íntimos em todos os capítulos.

| Seção existente | Uso dos registros autorizados |
|---|---|
| Retrato — portrait | Integrar o que a pessoa registrou sobre seu corpo e suas escolhas ao relato do período, com atribuição explícita. |
| Fios — threads | Relacionar observações datadas a temas presentes em diário/práticas; distinguir coincidência, relato da pessoa e interpretação simbólica. |
| Céu — sky | Cruzar datas observadas com a Lua/contexto celeste calculados; sem causalidade lunar sobre saúde. |
| Prática — practice | Contextualizar pausas e práticas relatadas. Registro menstrual não soma prática mágica, produtividade ou streak. |
| Amor, trabalho e família — love/work/family | Usar contexto autorizado somente quando os relatos trazem relação com a área. Não deduzir desempenho, libido, conflito ou capacidade pelo fluxo, humor ou estação. |
| O que se anuncia — forecast | Respeitar preferências de cuidado declaradas ao propor possibilidades; manter previsões baseadas em skyAhead, sem prever menstruação, ovulação ou sintomas pela IA. |
| Rituais — rituals | Sugerir práticas simbólicas leves compatíveis com preferências registradas; não tratar dor, hormônios ou condições clínicas. |
| Afirmação — affirmation | Acolher temas escolhidos pela pessoa sem expor datas/sintomas nem afirmar cura. |
| Selo — seal | Síntese simbólica neutra, sem codificar condição de saúde ou tipo corporal. |
| Números — numbers, montada em Dart | Bloco separado de “registros do corpo incluídos”, com cobertura e contagens autorizadas; não transformar menstruação em atividade, constância ou nota. |

Manter um registro explícito de seções permitidas para a fonte íntima, com projeção de dados apropriada a cada chave acima. Para afirmação/selo, fornecer temas minimizados; para sky, datas e contexto lunar; notas íntimas só vão às seções que precisam delas e quando selecionadas. Uma chave futura desconhecida não recebe dados menstruais por fallback. A versão semanal usa as oito seções que já possui, sem ganhar capítulos cobrados ou inventar dados faltantes.

**Contagens separadas.** O `recordCount` e os números atuais desconsideram os toggles para certas contagens e também atendem ofertas. Não inserir saúde nesses caminhos. Introduzir distinção explícita entre material autorizado da leitura e sinais comerciais: `readingIncludedRecordCount` pode incluir registros menstruais autorizados; `offerEligibleRecordCount` nunca inclui saúde. Mostrar a cobertura dessa fonte em bloco próprio, sem alterar practiceDays, streak ou XP. A ausência de Premium ou de autorização remove a fonte, seus trechos, timeline e contagens privadas do payload. Conferir também totais, fontes principais e comparação com período anterior para impedir inclusão indireta.

**Persistência e retomada.** Criar um snapshot autorizado por generation_id com versão de conteúdo, registros/versões, máscaras de campos e revisão do consentimento. O fingerprint precisa ser estável e derivado desse contrato; não depender apenas de String.hashCode. Reutilizar capítulos prontos somente quando snapshot, pessoa, autorização e versão de prompt forem compatíveis. Antes de cada request e antes de salvar, revalidar o escopo. Edição/exclusão de fonte, troca de conta ou revogação invalidam a geração: interromper próximas chamadas, descartar resultados atrasados e limpar rascunhos afetados. Explicar a alteração e permitir retomar com nova prévia, preservando as regras de crédito existentes. Não afirmar que isso recolhe dados já enviados.

Os rascunhos atuais estão em SharedPreferences e os relatórios em free_writings. Quando tiverem fonte menstrual, ambos recebem a proteção do módulo, `containsSensitiveSources` e vínculo ao manifest. Exportação geral e sync do acervo precisam respeitar essa marcação, inclusive quando o relatório mistura fontes. Consentir no envio à IA não habilita backup na nuvem. Nenhum relatório sensível volta como fonte de outra análise por includeJournals/includeDivination sem autorização explícita para aquele conteúdo derivado. Excluir apenas o registro original não basta se suas observações continuam no relatório.

**Atualização e exclusão de relatórios.** Uma edição nos logs atualiza as marcas inseridas no calendário imediatamente e invalida resultados derivados; o recálculo analítico só executa com Premium, mas não reenvia IA nem reescreve um relatório concluído em silêncio. Marcar a leitura como baseada em uma versão anterior e oferecer regeneração com prévia. Apagar todos os dados do módulo inclui rascunhos/relatórios com fonte íntima, com esse alcance descrito na confirmação; preservar os créditos de leitura para permitir gerar novamente sem saúde conforme as regras existentes. Apagar um registro individual mostra quais leituras o utilizaram e oferece excluir essas cópias derivadas também. O manifesto é atualizado atomicamente ao substituir a leitura do mesmo período, preservando sua identidade de acervo.

**Movimento na análise.** Ao confirmar a seleção, o resumo “Ciclo Menstrual · N registros incluídos” se acomoda no conjunto de fontes. A geração revela cada capítulo somente quando a resposta real chega; nada deve indicar que todos os dados foram processados antes disso. Ao abrir uma observação relacionada ao corpo, expandir o contexto e as datas autorizadas com transição curta. O salvamento sela o relatório após persistência, mantendo os controles de fonte acessíveis. Não acrescentar uma cerimônia obrigatória, espera extra ou confete por incluir informações íntimas.

**Verificação editorial e técnica.** Atualizar os prompts PT/EN/ES, a composição determinística e a apresentação das fontes. Usar casos fictícios com dados coerentes, contraditórios, mínimos e ausentes. O modelo deve reconhecer limites, não inferir hormônios, gravidez, fertilidade ou diagnósticos, e não atribuir ao ciclo relatos que pertencem a outra data/pessoa. Avaliar o texto final de cada tipo de leitura, além de comprovar por testes que requests, rascunhos, relatórios, backups e ofertas respeitam o escopo.

Fontes do código: [seções e geração da leitura](https://github.com/laylamonteiro/witchy-app/blob/6ea85d98cab5d5429617badbb606608cbc290567/lib/features/cycle_reading/data/services/cycle_reading_service.dart), [rascunhos](https://github.com/laylamonteiro/witchy-app/blob/6ea85d98cab5d5429617badbb606608cbc290567/lib/features/cycle_reading/data/services/cycle_reading_draft_store.dart), [fontes na tela de geração](https://github.com/laylamonteiro/witchy-app/blob/6ea85d98cab5d5429617badbb606608cbc290567/lib/features/cycle_reading/presentation/pages/cycle_reading_intro_page.dart).

## 7. Plano de produção dos assets

Separar a produção de arte da implementação dos gestos, para que protótipos funcionais não dependam da conclusão de todo o catálogo.

| Conjunto | Entrega mínima | Camadas / estados |
|---|---|---|
| Tarô | Artes atuais, verso e mesa | Reutilizar imagens; sombra e brilho por código. |
| Oráculo | 44 frentes, verso, moldura | Frente estática para cada ID; camadas extras nas seis cenas iniciais. |
| Runas | Saquinho, tecido e pequeno conjunto de formatos de pedra | Corpo/sombra separados; glifo vetorial ou texto existente sobreposto. |
| Conselheiro | Bola de cristal com base | Base, reflexo, névoa e luz; estado parado sempre disponível. |
| Lições | Página, selo e carimbo | Papel, relevo/selo, brilho breve. |
| Trilhas | Livro e capas associadas às trilhas | Páginas, capa, lombada; título renderizado pela UI. |
| Conquistas | Constelações e molduras de marcos | Pontos, ligações e medalhão; textos localizados fora da arte. |
| Rituais | Círculo com segmentos | Caminhos vetoriais que recebem progresso. |
| Ferramentas | Objetos de entrada coerentes com as cenas | Miniatura estática e transição simples. |
| Ciclo Menstrual | Roda, marcador de registro e quatro vinhetas de estação | Anéis/marcadores por código; repouso, broto, flor e folha em camadas leves. Versões estáticas em todos os temas. |

Regras de produção:

1. Usar a paleta e os temas do app. Não fixar toda a experiência a um único fundo escuro; testar as cores existentes.
2. Textos e nomes não ficam embutidos nos bitmaps. Manter português, inglês e espanhol pela infraestrutura de localização.
3. Toda animação tem um frame final estático. O asset estático também serve para movimento reduzido, erro de carregamento e exportação.
4. Para imagens em camadas, registrar canvas, pontos de pivô, recortes e ordem de composição. Camadas do mesmo conjunto precisam usar coordenadas compatíveis.
5. Dimensionar imagens para o uso real e carregar apenas o necessário. Definir orçamento após medir a primeira cena; não distribuir 44 imagens enormes por conveniência.
6. Manter os arquivos-fonte editáveis junto ao projeto de arte e exportações otimizadas no app.
7. Cada asset recebe ID, ferramenta/cartas relacionadas, versão, origem/licença quando aplicável e caminho da versão estática.
8. Arte provisória é aceitável no protótipo interno. Na entrega pública, cada carta deve ter uma frente coerente e fallback revisado; apenas as cenas especiais podem ser incrementais.

O primeiro lote visual deve conter: verso do Oráculo, três frentes representativas, uma pedra/runa, bola de cristal e selo de página. Conferir juntos o estilo antes de multiplicar o catálogo. Para Ciclos, acrescentar uma roda e uma vinheta representativa ao estudo; o componente lunar deve aproveitar a linguagem do calendário existente. Esse conjunto não depende de ilustração anatômica nem de novos personagens.

## 8. Sequência de implementação

P00 a P18 são **19 pacotes** sugeridos para branches/PRs. P16/P17/P18 foram acrescentados nesta revisão, com os IDs anteriores preservados; P15 continua como integração final. Cada pacote precisa produzir algo verificável. O tamanho é relativo: P = pequeno, M = médio, G = grande; não é uma estimativa de prazo. Arte, resultado do protótipo e estado real da branch podem mudar o esforço.

| Pacote | Entrega | Depende de | Tamanho |
|---|---|---|---|
| P00 | Baseline, fixtures e galeria interna de cenas | — | M |
| P01 | Componentes comuns de movimento, visibilidade e feedback | P00 | M |
| P02 | Sessões persistentes e consumo local idempotente | P00 | G |
| P03 | Tarô manual: carta do dia, três cartas e cruz | P01, P02 | G |
| P04 | Runas manuais e mesas de até nove pedras | P01, P02 | G |
| P05 | Oráculo manual, catálogo de arte e seis cenas | P03, primeiro lote de arte | G |
| P06 | Conselheiro e “Guardar conselho” | P01 | M |
| P07 | Coordenação de progresso, marcos e ritos | P01 | G |
| P08 | Selos de lição e encadernação de trilhas | P07 | M |
| P09 | Rituais guiados, diário, desejos e reações do gatinho | P07 | M |
| P10 | Formação, reorganização e conclusão de sigilos | P01, P07 | M |
| P11 | Álbum do Oráculo, quiz e revelação de arquétipos | P05, P07 | M |
| P12 | Guia da Natureza, Sonhos e Quiromancia | P06, P07 | M |
| P13 | Numerologia e refinamento do Pêndulo | P01, P06 | M |
| P14 | Ferramentas: artes de entrada e transições de navegação | P03–P06, P08–P13 | M |
| P16 | Ciclo Menstrual: registro manual Free, privacidade e cálculos/conteúdo Premium | P00; coordenar migrações com P02 | G |
| P17 | Ciclo Menstrual: animações Free e roda/experiência analítica Premium | P16, P01 | G |
| P18 | Fonte menstrual Premium na análise completa e semanal, consentimento e acervo | P16, P01; projeção lunar de P17 quando utilizada | G |
| P15 | Migrações finais, sync das coleções, QA e ativação | Todos os pacotes habilitados, incluindo P16/P17/P18 | G |

A ordem de trabalho pode seguir a tabela. P16 pode começar após o levantamento inicial, sem aguardar todas as Ferramentas; lançar o registro antes permite formar histórico real. O calendário manual Free e a primeira sobreposição lunar Premium entram em P16. P17 acrescenta a experiência visual completa e o resumo que aparece apenas com histórico suficiente. P18 integra registros autorizados à análise completa e semanal; pode ser desenvolvido sem esperar três ciclos reais, usando fixtures. O lote não está concluído sem essa integração. P04 e P06, por exemplo, não exigem que o catálogo completo do Oráculo esteja pronto. Isso é uma dependência de projeto, não uma instrução para criar agentes ou executar tarefas concorrentes.

### P00 — conhecer e congelar a base

- Atualizar a referência da branch e ler AGENTS.md/instruções locais que existirem.
- Conferir versões de Flutter/Dart usadas no CI e no projeto. Não alterar framework ou gerenciador de estado junto deste trabalho.
- Registrar uma navegação real pelas 12 ferramentas, Ciclos/Privacidade e pelos principais fluxos de conclusão.
- Para o módulo menstrual, criar somente dados fictícios: sem histórico, quatro inícios, lacunas, escape, edição, exclusão pendente, Premium expirado e mudança de gênero. Conferir filtros de sync/exportação/ofertas e o cálculo lunar existente.
- Identificar assets existentes aproveitáveis: vela, caldeirão, gato, emblemas e fundos.
- Criar fixtures locais para resposta imediata, resposta lenta, falha, sem acesso, resultado salvo e todas as tiragens. Essas fixtures não chamam IA nem anúncios.
- Criar uma galeria interna Flutter para cenas/gestos, disponível apenas no ambiente de desenvolvimento.
- Rodar os testes existentes relevantes como baseline. Registrar falhas anteriores sem atribuí-las às mudanças.

**Saída verificável:** catálogo de telas e comportamentos, fixtures e uma forma de comparar uma cena antes/depois.

### P01 — infraestrutura visual

- Implementar política de visibilidade: rota, aba e ciclo de vida do app.
- Criar ToolSceneFrame e ActionFeedbackHost mínimos, sem colocar regras de XP nesses widgets.
- Encapsular transições de resultado e antecipação da animação.
- Adicionar alternativas para movimento reduzido e sem suporte tátil.
- Criar previews de foco, seleção, erro, sucesso, selo e marco.

**Saída verificável:** uma mesma confirmação funciona dentro da tela, após retorno de navegação e sob movimento reduzido.

### P02 — sessões, migração e consumo

- Implementar tabelas/contratos da seção 5 e migrações aditivas.
- Colocar os dados de pergunta lembrada/última pergunta do tarô na mesma unidade de consistência usada pela confirmação. Migrar as preferências existentes uma vez e manter leitura compatível.
- Criar política de reutilização da carta do dia e chaves únicas apropriadas para impedir dois resultados finais da mesma pessoa/dia/pergunta.
- Adaptar AuthProvider para consumir/ler a fonte única de uso nas categorias afetadas. Auditar todos os chamadores para impedir um caminho antigo e outro novo debitando separadamente.
- Manter saldo inicial importado e reset diário compatíveis.
- Acrescentar ID de sessão aos repositórios de resultado, sem quebrar payloads antigos.
- Implementar recuperação de erro no commit, conta trocada e encerramento do processo.

**Saída verificável:** testes demonstram seleção estável, commit repetido inofensivo, migração sem zerar cota e leitura antiga preservada.

### P03 — tarô em fatias verticais

1. Carta do dia completa, do leque à retomada.
2. Três cartas com indicação de posição.
3. Cruz de cinco com layout próprio.
4. Teclado/mouse, fonte ampliada e comportamento web.

**Saída verificável:** gravação no aparelho das três tiragens, com teste de reentrada e seleção de cartas nos extremos do leque.

### P04 — runas

- Criar a superfície de pedras e a mesa.
- Implementar primeiro 1 e 3 pedras; depois 5 e 9.
- Reutilizar contratos de resultado, orientação, cota, rito e salvamento.
- Desacoplar o movimento da pedra da apresentação do texto.

**Saída verificável:** nove pedras podem ser escolhidas rapidamente e cada uma continua ligada ao significado correto.

### P05 — Oráculo

- Integrar os 44 IDs ao registro de arte.
- Usar o seletor compartilhado, com composição e material próprios.
- Implementar os layouts diário, três cartas e orientação semanal.
- Implementar as seis cenas iniciais, em execução exclusiva na carta focalizada.
- Emitir os dados de descoberta para P11 sem criar XP.

**Saída verificável:** todas as cartas podem aparecer e nenhuma precisa de uma cena exclusiva para funcionar.

### P06 — Conselheiro

- Refatorar _askAdvisor para um estado de requisição isolado.
- Implementar a bola de cristal e o deslocamento de pergunta/teclado.
- Remover o atraso adicional obrigatório do typewriter.
- Acrescentar origem advisor, composição de registro e salvamento único.
- Preparar o painel compacto de interpretação para as outras ferramentas.

**Saída verificável:** consultar, falhar, tentar novamente e guardar funcionam sem perder a pergunta ou fazer chamadas extras.

### P07 — progresso e marcos

- Extrair a avaliação de marcos para fora de JourneysPage.
- Introduzir ActionOutcome e ProgressCoordinator usando a fórmula atual.
- Incluir tarô no total de leituras.
- Extrair avaliação de ritos/dia completo da dependência de build.
- Registrar marcos estáveis e agrupar resultados por action_id.
- Migrar o estado anterior silenciosamente.

**Saída verificável:** salvar o décimo sonho produz um marco; repetir salvamento, carregar histórico ou sincronizar não repete o evento.

### P08 — lições e trilhas

- Adaptar _celebrate para a apresentação coordenada.
- Criar selo de página, livro encadernado e coleção de trilhas concluídas.
- Usar títulos, tratamento e idioma atuais.
- Consolidar ganho de lição, bônus e nível no mesmo resultado.

**Saída verificável:** última lição da trilha mostra o ganho correto e um único momento de conclusão.

### P09 — rituais, diário, desejos e mascote

- Garantir await/resultado explícito nas mutações que hoje navegam imediatamente após iniciar o salvamento.
- Integrar o círculo de ritual, confirmação de diário e transições de desejo.
- Atualizar a apresentação existente de dia completo para consumir o evento comum.
- Expor reações externas do gato e definir precedência: interação/tour da pessoa têm prioridade.
- Agregar feedback quando uma ação alcança múltiplos marcos.

**Saída verificável:** uma conclusão que fecha o dia e sobe nível permanece compreensível, sem várias sobreposições.

### P10 — sigilos

- Adicionar progresso do traçado e interpolação das posições.
- Integrar a passagem entre intenção, letras e desenho.
- Garantir estado final para exportação.
- Conectar salvamento e eventual marco ao resultado persistido.

**Saída verificável:** mesma intenção gera o mesmo resultado final com animação normal, reduzida e antecipada.

### P11 — descobertas, quiz e arquétipos

- Implementar o álbum das 44 cartas e primeira descoberta.
- Fazer retrospectiva a partir das leituras de Oráculo disponíveis.
- Implementar constelação de sessão do quiz e cena de revelação do arquétipo.
- Manter progresso específico do quiz separado do XP unificado.

**Saída verificável:** carta repetida não aumenta o álbum; quiz continua com a mesma pontuação; arquétipo salvo abre diretamente.

### P12 — fluxos com foto e relato

- Reutilizar o estado assíncrono de P06, com superfícies visuais próprias.
- Natureza: revisar candidatos, confirmar e guardar ficha.
- Sonhos: relato, interpretação, registro e integração aos ritos.
- Quiromancia: foto, estado de análise e resposta textual.
- Preservar gates de acesso, limites de imagem, dados retornados e caminhos de cancelamento.

**Saída verificável:** falha de IA ou cancelamento de imagem não deixa a UI presa nem apresenta sucesso.

### P13 — numerologia e pêndulo

- Animar os valores efetivamente calculados e as transições dos catálogos.
- Compartilhar o painel de explicação de IA.
- Refinar o resultado do pêndulo, preservando sorteio e sensor separados.

**Saída verificável:** números e respostas iguais com animação ligada/desligada; controladores e sensor inativos fora da tela.

### P14 — navegação e identidade das Ferramentas

- Integrar as artes dos cards às cenas de destino.
- Revisar tamanhos, hierarquia, estados de retorno e navegação.
- Uniformizar feedback de seleção, salvamento e erro.

**Saída verificável:** percurso completo pelas 12 entradas, incluindo retorno, re-toque de aba e links existentes.

### P16 — Ciclo Menstrual: registro, conteúdo e privacidade

- Criar domínio e repositório próprios em `features/menstrual_cycle`, com registros diários, observações separadas de simbolismo e regras de data/continuidade da seção 6.15.
- Implementar migração local/remota, RLS, índice lógico por usuário/data, revisões, consentimentos e mecanismo de exclusão entre aparelhos. Coordenar versão com P02; não fixar versão 24.
- Implementar consentimento específico, sync opcional e gestão permanente dos próprios dados em Privacidade. Liberar CRUD e calendário de dados inseridos no Free; proteger todos os cálculos e dados derivados pelo gate Premium, inclusive caches e deep links.
- Documentar e verificar armazenamento, chaves se aplicáveis, backup, exportação e isolamento. Testar em nativo e web antes de habilitar dados reais.
- Entregar o cartão, formulário, histórico/calendário funcional com Lua estimada por dia, edição, exclusão e estados vazios/erro/offline.
- Entregar editor íntimo Free e, no Premium, as quatro estações escolhidas pela pessoa, conteúdo PT/EN/ES e links curados da Enciclopédia.
- Implementar média/faixa observadas e referência de próxima data opt-in exclusivamente Premium, com critérios explícitos, sem inferir ovulação.
- Manter envio menstrual à IA fechado até a integração de P18. Excluir a fonte de contagens comerciais, XP, ofertas e telemetria; revisar caminhos indiretos de exportação/Diário.

**Saída verificável:** uma conta Free registra, reabre, edita, exporta e exclui dados fictícios sem assinatura; não recebe resultados derivados. Premium acessa a comparação diária com a Lua e cálculos locais sem IA. Upgrade reutiliza os registros; expiração preserva o fluxo manual e bloqueia análise. Segunda conta e consentimento recusado recebem os estados corretos. Exclusão feita offline não volta por sync de aparelho antigo.

### P17 — Ciclo Menstrual: experiência visual e comparação lunar

- Construir calendário Free com dados inseridos e, no Premium, roda com dois anéis na mesma escala de datas, controle por toque/arraste/teclado e alternativa em calendário.
- Implementar as cenas de registro, navegação, estação, escrita e edição da seção 6.15.C, depois do sucesso real das operações.
- Expor cálculo lunar contínuo compartilhado para comparação com janelas simétricas; documentar a aproximação e a convenção de fuso.
- Implementar resumo de três intervalos completos com quatro inícios válidos, contagens verificáveis e recálculo após edição/exclusão.
- Manter títulos Lua Branca/Vermelha condicionados à revisão editorial; lançar as observações lunares sem títulos se a fonte não estiver confirmada.
- Validar retorno ao calendário lunar, ausência de mutação global indevida, movimento reduzido e semântica do cursor de datas.
- Medir o calendário em aparelho de referência; cálculos/cache fora de paint/build e sem consultar o banco a cada frame.

**Saída verificável:** vídeo do fluxo abrir → registrar → percorrer datas → escolher estação → consultar histórico, e versão equivalente sem animação. Nenhum gesto altera dados sem salvar; resumo corresponde exatamente aos registros e não gera XP, ofertas ou envio à IA.

### P18 — fonte menstrual na análise completa da Leitura do Ciclo

- Implementar gate Premium, seleção de registros/campos e consentimento específico em CycleReadingIntroPage; incluir todos os registros da janela exige ação explícita, sem autorização automática para dados futuros. Revalidar benefício durante geração e apresentação, inclusive relatório/cache.
- Criar contexto e manifesto por geração, com datas observadas, revisões e escopo. Integrar a fonte ao compositor, timeline e cobertura sem consultar histórico extra não autorizado.
- Aplicar as projeções por seção de 6.15.H às 11 seções da lunação e às oito da semana; atualizar prompts PT/EN/ES e números determinísticos.
- Separar contagens de material autorizado e contagens comerciais; preservar práticas, streak, XP, preços e crédito.
- Revalidar escopo antes de cada request; proteger rascunhos, invalidar geração incompatível e bloquear respostas atrasadas após revogação/troca de conta.
- Marcar e proteger relatórios derivados no acervo, sync e exportação; impedir sua reentrada silenciosa como fonte genérica de IA.
- Implementar gestão de origem, regeneração explícita após edição e exclusão de cópias derivadas, preservando identidade de leitura e regras de crédito.
- Integrar resumo visual das fontes, progresso real por capítulo e expansão do contexto relacionado aos registros.

**Saída verificável:** em uma conta Premium, a mesma janela produz uma análise completa coerente com a fonte menstrual ligada e outra sem qualquer conteúdo/contagem dessa fonte quando desligada. Registros autorizados influenciam os capítulos pertinentes; um registro já pode participar, sem exigir três ciclos. A versão semanal também funciona. Free não envia ou recebe conteúdo analítico menstrual, mesmo com crédito avulso de leitura. Troca de conta, perda de Premium, revogação, edição durante geração, retry e exclusão não reutilizam material íntimo incompatível. Ofertas nunca recebem essa fonte.

### P15 — entrega integrada

- Finalizar migrações e sincronização das novas coleções, com isolamento por usuário.
- Fazer QA de atualização sobre base antiga, conta convidada e conta existente.
- Para Ciclos, concluir a revisão de conteúdo, privacidade, sync/exclusão e exportação; verificar uso autorizado de saúde na análise de P18 e sua ausência em ofertas e envios não autorizados. Esses gates são independentes do acabamento visual de P17.
- Medir desempenho nos cenários mais caros.
- Ativar cada grupo de recursos após verificar seus gates.
- Preparar descrição da entrega, gravações de demonstração e limitações materiais verificadas.

**Saída verificável:** pacote apto a revisão/publicação pelo fluxo normal do projeto, com resultados das validações e rollback de interface preparado.

## 9. Matriz de validação

Reutilizar os testes existentes de regras e repositórios. Escrever testes novos para seleção, persistência, consumo, migração, navegação e eventos; avaliar a estética por revisão visual. Não criar testes que apenas confirmem constantes de animação.

| Área | Caso | Resultado esperado |
|---|---|---|
| Seleção | Escolher todas as cartas de 1/3/5 | IDs únicos, ordem de escolha preservada e posição correta. |
| Seleção | Escolher 9 runas | Nove itens do baralho, sem repetição, com interpretação correspondente. |
| Gestos | Explorar horizontalmente e soltar | Nenhuma carta confirmada por acidente. |
| Gestos | Arrastar e cancelar | Item retorna ao lugar, sem consumir posição ou cota. |
| Gestos | Selecionar cartas nos extremos da faixa | Todo o baralho é alcançável. |
| Concorrência | Dois toques rápidos na última carta | Uma confirmação, um registro e no máximo um consumo. |
| Retomada | Fechar com 2 de 5 itens escolhidos | Mesma ordem, mesmos IDs e mesma orientação ao voltar. |
| Retomada | Fechar depois de confirmar, antes da revelação | Resultado salvo, sem novo sorteio/consumo/anúncio de retomada. |
| Falha | Interromper cada fronteira de gravação | Retomar a mesma operação ou apresentar erro recuperável; nunca trocar as cartas. |
| Carta do dia | Reabrir mesma pessoa/dia/pergunta | Recuperar a primeira carta escolhida. |
| Histórico | Mesmas cartas/pergunta em outro dia | Ocorrência distinta preservada no histórico. |
| Premium | Voltar à mesma sessão versus iniciar nova tiragem | Retomar conserva; nova consulta explicitamente autorizada cria sessão distinta. |
| Free | Pergunta lembrada, nova pergunta com/sem cota | Política caracterizada preservada; não conceder gratuidade por comentário. |
| Migração de uso | Atualizar app com cota já consumida | Saldo existente mantido; importação executada uma vez. |
| Dia | Selecionar antes e confirmar após meia-noite | Identidade e consumo vinculados ao dia de início, com informação clara. |
| Conta | Trocar usuário durante operação | Nenhum resultado, saldo, rascunho ou conquista atribuído à outra conta. |
| Convidado | Associar dados à conta | Mesas e marcos migrados conforme política do app, sem duplicação. |
| IA | Resposta imediata | Conteúdo disponível sem espera artificial obrigatória. |
| IA | Resposta lenta, timeout ou falha | Espera acompanha a operação; texto/foto/seleção preservados conforme o fluxo. |
| IA | Resposta antiga chega após nova solicitação | Não substitui o resultado ativo. |
| Salvamento | Reabrir e guardar a mesma resposta | Um registro vinculado àquela resposta, salvo apenas após sucesso. |
| Progresso | Lição fecha trilha e muda nível | Ganho correto, uma apresentação coordenada. |
| Progresso | Décimo sonho ou primeiro desejo realizado | Marco adquirido uma vez após persistência. |
| Progresso | Carregar histórico/sync/editar registro | Sem celebração de nova criação ou XP duplicado. |
| Ritos | Completar terceiro requisito fora da home | Fechamento registrado e feedback no contexto adequado. |
| Álbum | Encontrar carta repetida | Contagem de únicas inalterada; sem novo popup. |
| Álbum | Duas leituras ou aparelhos descobrem a mesma carta | Um registro por usuário/carta, primeira data válida mantida. |
| Sigilo | Antecipar/exportar durante traçado | Imagem final correta, sem captura parcial. |
| Foto | Vários candidatos ou ausência de identificação | Exibir o estado real, sem “descoberta confirmada” falsa. |
| Pêndulo | Variar sensor com o mesmo resultado | Efeito decorativo muda; resposta não. |
| Acessibilidade | Movimento reduzido, fonte ampliada, teclado | Funcionalidade e legibilidade completas. |
| Lifecycle | Encobrir rota ou pôr app em segundo plano | Loops, timers e sensores pertinentes suspensos. |
| Navegação | Voltar durante todas as fases | Estado coerente, sem setState em widget descartado. |
| Ciclos / gate | Feminine/neutral/masculine; gratuito, Premium, código e vitalício | Cartão conforme gênero; registro Free, dados derivados Premium; sem vazamento durante carregamento. |
| Ciclos / Free | Registrar, consultar, editar, exportar e apagar | Acesso sem assinatura; nenhuma média, dia calculado, previsão ou comparação lunar. |
| Ciclos / upgrade | Free acumula dados e depois ativa Premium | Histórico manual reutilizado, sem redigitar ou autorizar IA automaticamente. |
| Ciclos / bypass | Abrir rota, cache, widget, acervo ou geração diretamente no Free | Nenhum conteúdo analítico menstrual exposto, mesmo se já havia sido calculado. |
| Ciclos / direitos | Premium expira ou gênero muda após uso | Dados pessoais e sua gestão preservados; expiração mantém registro Free e bloqueia resultados analíticos. |
| Ciclos / consentimento | Recusar, aceitar local, ativar sync, revogar | Nenhum envio fora da finalidade autorizada; decisões persistidas por pessoa. |
| Ciclos / registro | Dois salvamentos no mesmo dia, escape e início explícito | Linha lógica única; escape não inicia ciclo automaticamente; retries idempotentes. |
| Ciclos / datas | Data futura, início/fim no mesmo dia, viagem e horário de verão | Validação coerente e data civil original preservada. |
| Ciclos / histórico | Três inícios, quatro inícios e intervalo com lacuna | Dois intervalos com três inícios; três elegíveis apenas com quatro e continuidade. |
| Ciclos / estimativa | Modo desligado, histórico insuficiente e data prevista passada | Sem fase ovulatória ou ciclos fabricados; estimativa identificada e não renovada automaticamente. |
| Ciclos / Lua | Limites de ±2 dias perto de Nova/Cheia; fase minguante | Janelas simétricas e determinísticas; minguante não recebe rótulo Lua Vermelha. |
| Ciclos / recálculo | Editar/apagar um início usado no resumo | Recalcular contagens e elegibilidade; nenhuma celebração de nova descoberta. |
| Ciclos / gesto | Percorrer roda e soltar; leitor de tela e teclado | Só navegação de data; nenhuma edição ou registro involuntário. |
| Ciclos / sync | Editar o mesmo dia em dois aparelhos | Conflito detectável sem perda silenciosa; exclusão vence revisão antiga. |
| Ciclos / exclusão | Apagar offline e reconectar aparelho com cópia antiga | Estado pendente correto; geração/tombstones impedem ressurreição. |
| Ciclos / exportação | Exportação geral e específica, ambos os pontos de entrada | Escolha explícita, escopo correto, dados só da pessoa e arquivo temporário tratado. |
| Ciclos / IA desligada | Defaults antigos true, conta Free ou fonte menstrual não autorizada | Zero conteúdo, timeline ou contagens dessa fonte nos requests. |
| Ciclos / análise completa | Fonte autorizada, notas selecionadas ou excluídas, um único registro | Material correto nas 11 seções da lunação e oito da semana; limites de cada projeção respeitados. |
| Ciclos / datas da análise | Registro retroativo e registro fora da janela | Filtrar pela data observada; não usar created_at nem histórico extra sem autorização. |
| Ciclos / consentimento em geração | Revogar/editar/apagar entre capítulos; resposta atrasada | Interromper novas chamadas e gravação incompatível, limpar rascunho e preservar crédito. |
| Ciclos / derivados | Relatório sensível no acervo, exportação, sync e fonte de outra leitura | Origem e permissões mantidas; nenhuma inclusão indireta automática. |
| Ciclos / ofertas | Saúde autorizada na leitura, mas não nas ofertas | Nenhuma contagem ou detalhe menstrual nos sinais comerciais ou logs técnicos. |
| Ciclos / progresso | Salvar, editar, apagar, sincronizar e abrir resumo | Sem XP, streak, badges ou notificação de saúde. |
| Ciclos / conteúdo | PT/EN/ES e todos os links de correspondências | Chaves resolvidas, linguagem simbólica e destinos revisados. |

### 9.1 Testes automatizados que valem o custo

- Domínio: seleção de IDs, associação às posições, reutilização, política de dia, regras de acesso e resultados determinísticos com RNG controlado.
- Repositórios: migrações, índices únicos, operações repetidas, recuperação de consumo/resultado, saldos iniciais, isolamento entre contas.
- Widgets: gestos concorrentes com scroll, fallback de acessibilidade, retomada de uma sessão, resultado antigo ignorado e dados corretos após navegação.
- Integração: um percurso completo por família (cartas, pedras, consulta IA, conclusão/progresso), mais o fluxo de atualização de banco.
- Ciclos: datas civis e continuidade, cálculo lunar simétrico, isolamento/RLS, consentimento, exportação e exclusão em dois aparelhos; paridade de chaves de conteúdo PT/EN/ES. Inspecionar requests e agregados para comprovar inclusão de saúde somente no escopo de IA autorizado e exclusão completa de ofertas.
- Snapshot/golden: somente composições determinísticas essenciais, com animação em tempos controlados; não depender de timing de rede ou partículas aleatórias.

### 9.2 Revisão visual obrigatória

Em cada experiência, conferir preparação, interação, resultado, falha e estado final sem movimento. Gravar um vídeo curto do fluxo no aparelho e comparar com a intenção da seção 6.

Dispositivos/cenários: Android intermediário de referência, web estreita e desktop; incluir iOS se o projeto tiver ambiente de build disponível. Ausência de ambiente iOS deve ser registrada, não substituída por uma afirmação de compatibilidade verificada.

Revisar idioma PT/EN/ES, temas existentes, teclado aberto, fonte ampliada, gesto de voltar, leitor de tela e resposta tátil opcional.

## 10. Desempenho e implementação Flutter

Critérios iniciais do projeto:

- Buscar quadros dentro do orçamento do display em modo profile; para 60 Hz, usar 16,7 ms como referência por etapa de UI/raster e observar também frames perdidos. Medir no aparelho de referência, não em debug.
- Registrar duração de UI/raster e frames perdidos durante exploração do leque, revelação de nove runas, uma cena do Oráculo e o percurso de datas na roda pessoal.
- Em Ciclos, pré-calcular somente o intervalo de calendário visível; isolar cursor e Lua animados do formulário, notas e consultas ao banco. Dados de demonstração/perfil devem ser fictícios.
- Comparar memória antes/depois de repetir abertura e fechamento das cenas. A quantidade de controllers, listeners e imagens retidas deve estabilizar.
- Construir apenas itens visíveis mais uma margem; guardar os 78 IDs em memória não exige 78 árvores complexas animadas.
- Não reconstruir a página de texto inteira a cada frame. Isolar elementos animados e cachear filhos estáticos quando apropriado.
- Usar RepaintBoundary de forma localizada e medida; muitos boundaries também têm custo.
- Preferir brilho desenhado com composição simples; medir blur, ShaderMask, Opacity e saveLayer antes de espalhá-los pela tela.
- Evitar recálculo de paths, sorteio, consulta de banco ou geração de conteúdo dentro de paint/build.
- Usar uma pequena quantidade de controladores por cena; não um loop permanente por item do baralho.
- Pré-carregar faces escolhidas antes da virada, na resolução necessária.
- TickerMode ajuda a silenciar tickers; timers, streams, sensores e tarefas externas exigem controle de ciclo de vida separado.

Referências técnicas: [práticas de desempenho do Flutter](https://docs.flutter.dev/perf/best-practices), [gestos e disputa entre reconhecedores](https://docs.flutter.dev/ui/interactivity/gestures), [MediaQuery.disableAnimationsOf](https://api.flutter.dev/flutter/widgets/MediaQuery/disableAnimationsOf.html), [TickerMode](https://api.flutter.dev/flutter/widgets/TickerMode-class.html). As metas numéricas acima são critérios propostos para este app; nenhuma medição de desempenho foi feita nesta etapa de planejamento.

## 11. Ativação, compatibilidade e manutenção

### 11.1 Recursos independentes

Manter controles internos para ativar famílias, por exemplo: seleção manual, cartas autorais, cenas especiais do Oráculo, Conselheiro visual, feedback de progresso e álbum. Em Ciclos, separar registro, roda animada, resumo lunar e conteúdo Lua Branca/Vermelha; a fonte menstrual na análise é ativada com P18, após verificar seus contratos; a flag não substitui o benefício Premium nem o consentimento de cada pessoa.

As flags controlam apresentação/caminhos de entrada; não desativam leitura de dados já gravados. Ao desligar uma cena, mostrar seu estado final. Ao desligar seleção manual para novas consultas, continuar abrindo resultados e rascunhos existentes por um caminho de compatibilidade.

Migrar dados de forma aditiva. Em Ciclos, desligar animações conserva calendário e registros conforme a matriz Free/Premium; desligar novas entradas conserva gestão de dados em Privacidade. Flags nunca concedem consentimento nem religam sync.

Um rollback visual usa o mesmo binário capaz de ler o schema novo; instalar um binário antigo sobre um banco novo não é automaticamente seguro.

### 11.2 Telemetria útil, se a infraestrutura já existir

Eventos técnicos mínimos: início/retomada/confirmação de sessão, abandono, antecipação da animação, falha de persistência, frames perdidos em teste e conclusão do salvamento.

Evitar registrar perguntas, interpretações, nomes, sonhos, fotos e intenções de sigilo na telemetria. IDs de operação servem para deduplicação e diagnóstico. Não criar um sistema analítico novo só para medir esta rodada. O módulo menstrual fica fora dos eventos analíticos de ações e dos contadores de engajamento deste lote: nem datas, sintomas, notas, estação escolhida ou disponibilidade de resumo devem gerar sinais de perfil. Diagnóstico técnico deve ser sanitizado e não carregar payloads íntimos.

Métricas de avaliação: taxa de conclusão da seleção, seleções canceladas acidentalmente, tempo entre abrir e confirmar, uso de antecipação, falhas de retomada e problemas de desempenho. O número de brilhos ou de animações não é uma métrica de sucesso.

### 11.3 Definição de pronto de cada pacote

1. A ação produz o comportamento descrito e preserva o resultado do domínio.
2. Estado final, erro e retomada funcionam.
3. Acessibilidade e localização estão completas para o escopo do pacote.
4. Os testes necessários passaram e os testes relevantes existentes continuam válidos.
5. A cena foi revisada visualmente; quando depender de aparelho indisponível, a limitação está registrada.
6. Arquivos, migrações e flags estão documentados na PR.
7. Não há espera artificial, novo consumo ou nova chamada de IA causada por replay de animação.
8. Risco conhecido de compatibilidade/dados tem resolução ou limitação claramente documentada.

## 12. Mapa dos principais arquivos existentes

Usar estes caminhos para localizar os pontos de integração; se a branch evoluir, procurar as classes/métodos equivalentes.

| Área | Arquivos existentes |
|---|---|
| Movimento | lib/core/theme/grimoire_motion.dart; lib/core/widgets/staggered_entrance.dart; lib/core/navigation/grimoire_route.dart |
| Catálogo | lib/features/grimoire/presentation/pages/grimoire_page.dart |
| Tarô | lib/features/tarot/presentation/pages/tarot_page.dart; presentation/widgets/tarot_card_view.dart; domain/regra_da_carta_do_dia.dart; data/repositories/tarot_reading_repository.dart |
| Runas | lib/features/runes/presentation/pages/rune_reading_page.dart; data/models/rune_spread_model.dart |
| Oráculo | lib/features/divination/presentation/pages/oracle_cards_page.dart; data/models/oracle_card_model.dart; data/data_sources/oracle_cards_data_pt.dart |
| Conselheiro | lib/features/grimoire/presentation/pages/mystic_advisor_page.dart |
| Uso e dados | lib/features/auth/presentation/providers/auth_provider.dart; lib/core/database/database_helper.dart; lib/core/services/data_sync_service.dart |
| Progresso | lib/features/learning/presentation/providers/learning_provider.dart; lib/features/journeys/presentation/pages/journeys_page.dart; data/models/journey_model.dart |
| Lições | lib/features/learning/presentation/pages/lesson_page.dart; trail_page.dart; learning_home_page.dart |
| Rituais | lib/features/guided_rituals/presentation/pages/ritual_player_page.dart; data/repositories/guided_ritual_log_repository.dart |
| Dia completo | lib/features/your_day/presentation/widgets/daily_rites_card.dart; presentation/providers/daily_checkin_provider.dart |
| Sigilos | lib/features/sigils/presentation/pages/sigil_step2_letters_page.dart; sigil_step3_drawing_page.dart; presentation/widgets/sigil_drawing_painter.dart |
| Diário/desejos | lib/features/diary/presentation/pages/dream_form_page.dart; desire_form_page.dart; free_writing_tab.dart |
| Acervo | lib/features/diary/presentation/widgets/save_to_records_button.dart; data/models/free_writing_model.dart; data/services/reading_archive_composer.dart |
| Gatinho | lib/core/widgets/mascot/draggable_cat_mascot.dart |
| Quiz/arquétipo | lib/features/tarot/presentation/pages/tarot_learn_tab.dart; lib/features/encyclopedia/presentation/pages/archetype_quiz_page.dart |
| Natureza | lib/features/encyclopedia/presentation/widgets/nature_guide_launcher.dart; presentation/pages/add_entry_page.dart |
| Sonhos | lib/features/diary/presentation/pages/dream_tools_page.dart; dream_interpretation_page.dart |
| Quiromancia | lib/features/palmistry/presentation/pages/palmistry_page.dart |
| Numerologia | lib/features/numerology/presentation/pages/numerology_page.dart; numerology_profile_page.dart |
| Pêndulo | lib/features/divination/presentation/pages/pendulum_page.dart |
| Ciclos | lib/features/cycles/presentation/pages/cycles_tab.dart; presentation/widgets/month_sky_card.dart; data/data_sources/life_eras_content.dart e variantes PT/EN/ES |
| Lua e estações externas | lib/features/lunar/presentation/providers/lunar_provider.dart; lib/features/wheel_of_year/data/models/sabbat_model.dart |
| Fontes íntimas e leitura | lib/features/cycle_reading/data/services/cycle_reading_composer.dart; cycle_reading_service.dart; cycle_reading_draft_store.dart; presentation/pages/cycle_reading_intro_page.dart |
| Prompts da análise | lib/core/ai/prompts/ai_prompts.dart e variantes PT/EN/ES |
| Privacidade/exportação | lib/features/settings/presentation/pages/privacy_settings_page.dart; lib/core/services/data_export_service.dart |
| Correspondências | lib/features/encyclopedia/data/models/crystal_model.dart; herb_model.dart |

**Estrutura nova proposta:** `lib/features/menstrual_cycle/`, com `data/models/menstrual_log.dart`, `data/repositories/menstrual_repository.dart`, `domain/menstrual_history_calculator.dart`, `domain/lunar_observation_calculator.dart`, `domain/internal_season.dart`, `data/data_sources/menstrual_phase_content{,_pt,_en,_es}.dart`, provider próprio e páginas/widgets de registro, calendário, roda e comparação. Os nomes são propostas; aplicar as convenções encontradas em P00. Compartilhar primitives visuais sem colocar lógica menstrual no provider de Lua ou na Roda do Ano.

### 12.1 Decisões para revalidar no início da execução

Estas verificações são tarefas de P00/P02, não perguntas que impedem o planejamento:

- Confirmar o comportamento de cota por testes contra a branch atual, especialmente a diferença entre comentário e função de tarô.
- Conferir novos chamadores de consumo antes de migrar a fonte local de contadores.
- Verificar se tarô e logs de rituais passaram a sincronizar após o commit analisado.
- Confirmar quais assets da vela/caldeirão/gato podem ser compartilhados sem acoplar widgets inteiros.
- Conferir o esquema remoto e os filtros do acervo ao acrescentar advisor.
- Conferir migrations recentes para atribuir versões novas sem colisão.
- Em P16, revisar proteção real do armazenamento, consentimentos, upload/download, exportação e limpeza; não considerar tombstones genéricos uma prova de exclusão completa.
- Em P17, conferir precisão e convenções do provider lunar, resolução dos links de Enciclopédia e revisão editorial dos nomes simbólicos antes de ativá-los.

## 13. Orientação de execução para o Codex

Este documento pode ser entregue diretamente ao agente que trabalhará no repositório. A instrução operacional é:

> Use este plano como especificação do trabalho no witchy-app. Comece por P00, confira a branch atual e as instruções locais e estabeleça os comportamentos existentes antes de alterar as regras. Execute os pacotes na ordem de dependência, entregando uma fatia funcional e verificável por vez. Preserve os resultados de domínio, políticas de acesso e dados existentes, aplicando somente as mudanças de produto explicitadas neste plano. Não repita a fase de brainstorming. Resolva escolhas rotineiras de implementação conforme as convenções do projeto. Se algum detalhe da branch tornar uma proposta incompatível, documente a diferença e implemente o ajuste compatível mais próximo; questões de produto realmente incompatíveis devem ser apresentadas com a alternativa concreta já preparada.
>
> Inclua o módulo menstrual conforme 5.4/6.15/P16/P17/P18: registro manual Free e dados derivados/análises Premium, consentimento específico, calendário e estações simbólicas, exclusão verificável e registros menstruais presentes na análise completa Premium mediante autorização, sem alimentar ofertas. P18 é parte obrigatória do lote. As correções explícitas sobre estimativas e Lua prevalecem sobre os exemplos do brainstorm. Mantenha o brainstorm original como visão; esta revisão é a especificação de execução.
>
> Separe estado da operação, dados persistidos e animação. A animação nunca sorteia, cobra, concede XP ou dispara IA por conta própria. Priorize seleção real, retomada, idempotência e estado final legível. Aproveite os componentes existentes; novas abstrações devem resolver repetição comprovada entre telas.
>
> Ao concluir cada pacote, informe: comportamento entregue, arquivos alterados, migrações, verificações realizadas, limites reais de validação e próximo pacote desbloqueado. Use o fluxo de branches/PRs do projeto. Ativação em produção segue o processo normal de release do repositório.

A primeira entrega executável é P00 + a infraestrutura mínima de P01/P02 necessária para a carta do dia em P03. A primeira demonstração de produto deve permitir abrir o leque, escolher uma carta real, vê-la revelar e reabrir a mesma consulta com o resultado preservado. Para o módulo menstrual, a primeira fatia é uma conta Free registrar um dia fictício, vê-lo no calendário de dados inseridos, reabrir e excluir; no Premium, habilitar o cruzamento com a Lua; P17 evolui essa base até a roda interativa. P18 completa a integração menstrual à análise completa e semanal neste lote. HealthKit/Health Connect permanece evolução opcional com especificação própria.
