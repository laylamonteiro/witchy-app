# P04 — Runas: seleção manual e mesa

Iniciada em 10/09/2026 na branch `codex/runes-manual-selection`, a partir de
`3e5a8d0` de `codex/tarot-manual-daily` (PR #281). Usa a infraestrutura de
sessões e cotas do Tarot. O [plano completo](plano_implementacao_animacoes.md)
continua sendo a especificação do lote.

## Comportamento

- Escolha manual das 24 pedras, com mesas de 1, 3, 5 e 9 peças. O saquinho abre
  e as pedras se espalham sobre um tecido, sem espera obrigatória para escolher.
- As posições e imperfeições das pedras são estáveis. O verso não mostra a runa,
  nem por texto de acessibilidade. A pedra em foco se eleva discretamente.
  Toque confirma; deslizar horizontalmente apenas explora. Rolagem vertical,
  botões, setas, Home/End e Enter/espaço continuam disponíveis.
- Cada retirada preenche a posição indicada na mesa e deixa seu lugar vazio no
  tecido. Os símbolos só aparecem após concluir e persistir o conjunto.
- Uma pedra central, linha de três, cruz nórdica (Resultado acima,
  Passado/Situação/Futuro ao centro, Desafio abaixo) e nove mundos em grade 3×3.
  Posições e significados seguem `RuneSpreadType`.
- Só as pedras se movem na revelação, que dura até 1.010 ms para nove itens e
  pode ser antecipada por toque ou pelo botão. Textos permanecem estáveis;
  tocar uma runa destaca seu significado. A Enciclopédia continua acessível.
- Preparação e escolha são estados da mesma página: a cena da escolha permanece
  durante a preparação do resultado, sem retorno intermediário ao menu.
- Arte vetorial usa `context.gc`: superfície, acento e detalhes dourados do tema
  ativo. Não há bitmap, dependência, som ou motor de física novo.

## Persistência e acesso

- Reutiliza `selection_sessions`, `usage_balances` e `usage_operations` do
  schema 24; **não acrescenta migração de banco ou tabela remota**.
- Categoria `runes` independente de Tarot/Oráculo. Importa o contador anterior
  uma vez por pessoa/dia. `AuthProvider.refreshRuneUsage` recupera o espelho de
  preferências; a confirmação usa a transação local como autoridade.
- Preserva o limite Free existente e usa `isPremiumEffective`. Escolhas parciais
  não consomem; completar a mesa grava resultado, consumo e vínculo juntos.
  Comandos duplicados/atrasados não preenchem outra posição.
- O ID estável de cada runa é seu caractere do Futhark, comum aos três catálogos.
  Embaralhamento e orientação (a chance atual de 50%) ficam definidos antes da
  escolha. A geometria não decide resultado ou orientação.
- A consulta conserva pergunta, ordem, escolhas e data inicial. Reentrada recupera
  o rascunho ou resultado mais recente do dia; rascunhos podem atravessar a
  meia-noite e confirmar sob o dia original. “Nova leitura” é a ação explícita
  para iniciar outra consulta e revalida a cota.
- Uma falha ao gravar o resultado mantém as escolhas; tentar novamente não
  permite substituir a última pedra. Troca de conta descarta a apresentação e
  invalida callbacks da conta anterior.
- A leitura continua em `rune_readings`, com formato compatível. ID e data
  originais também identificam a página automática em Meus Registros. Sync e
  cópia do acervo ocorrem após a confirmação local. Interpretação do Conselheiro
  é atualizada no mesmo resultado/acervo e volta na retomada; respostas antigas
  não substituem outra consulta.
- Rascunhos e cotas permanecem locais. Isso não garante unicidade entre aparelhos
  offline. Registros antigos e sua sincronização continuam no formato existente;
  não são transformados em novas seleções nem apagam créditos consumidos.

## Validação

- `rune_selection_repository_test.dart`: mesas de 1/3/5/9, ordem e orientação,
  restart, consumo único, concorrência, rollback, cota legada e independente,
  Free/Premium, nova consulta explícita, meia-noite, idioma e isolamento de conta.
- `rune_selection_surface_test.dart`: toque, exploração horizontal, rolagem
  vertical, posições extremas, retomada, semântica, estado desabilitado, fonte
  ampliada e movimento reduzido.
- `rune_selection_flow_test.dart`: quatro fluxos completos em largura de celular;
  Free na mesa simples, fonte a 150% em nove, movimento reduzido em cinco,
  reinício após duas escolhas, atraso na preparação, resultado sem flash do menu,
  inspeção de todas as posições, acervo, reentrada e nova consulta Premium.
- Galeria local ampliada com pedras e nove posições:
  `flutter run -t lib/dev/motion_gallery.dart`.
- Verificações locais: ARBs em paridade e sem órfãs, scanner de português,
  `git diff --check`. Analyze, testes Flutter e build usam o SDK pinado no CI.

Revisão visual e medição de frames em aparelho continuam pendentes. Movimento
reduzido conserva estados finais; `ToolSceneFrame` pausa tickers quando a tela
fica encoberta ou o app vai para segundo plano.

## Continuação

P05: Oráculo, reutilizando seleção de cartas com composição própria e registros
de descoberta. Os demais pacotes, incluindo registro menstrual Free e análises
Premium integradas à Leitura do Ciclo, permanecem no plano.
