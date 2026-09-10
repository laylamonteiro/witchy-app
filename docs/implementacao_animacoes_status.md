# Implementação das animações — primeira entrega

Iniciada em 09/09/2026, a partir da `main` em
`69dbc61c7d5d7a40c1dc5d1dc7aff6972ed2b880`.
Especificação de produto: [plano completo](plano_implementacao_animacoes.md).

Atualizada com a `main` em `2968ed8ca5290337baa10fa1e1c26b20c0348b7b`,
incluindo o novo salvamento automático de leituras em Meus Registros. A carta
do dia manual também cria/atualiza essa página, com o mesmo ID do resultado e
o dia original da sessão; a cópia do acervo segue o gravador best-effort da main.

## Escopo desta branch

Esta é a primeira fatia vertical de P03, com a infraestrutura mínima de
P01/P02. Não encerra esses pacotes nem o lote inteiro.

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

As tiragens de três e cinco cartas ainda usam seu fluxo anterior. A nova
transação completa é exclusiva da carta do dia nesta entrega; os demais
consumidores passam pelo mesmo ledger, mas serão migrados para sessões nas
próximas fatias.

## Verificação

- `daily_tarot_repository_test.dart`: sessão estável, 78 IDs sem repetição,
  confirmação concorrente, rollback, retomada, migração de cota/pergunta,
  cota consumida pelo Oráculo durante a escolha, Premium, virada do dia,
  isolamento de conta e adoção de resultados antigos.
- `daily_tarot_migration_test.dart`: banco real v23 preserva registros ao migrar.
- `daily_tarot_selection_page_test.dart`: toque duplo, bloqueio de voltar
  durante a gravação, retorno após sucesso, retry e troca de conta na rota.
- `daily_tarot_flow_test.dart`: fluxo completo na tela de Tarot, incluindo
  escolha, revelação, cópia automática em Meus Registros e reabertura sem duplicar.
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

1. P03: seleção de três cartas e cruz de cinco, com posições e retomada.
2. P04–P14: runas, Oráculo, Conselheiro e demais ações/rituais do plano.
3. P16/P17: registro menstrual manual Free; dados derivados e análises Premium.
4. P18: registros menstruais autorizados entram na análise completa do ciclo.
5. P15: integração e validação final do lote.

As decisões mais recentes sobre menstruação estão mantidas no plano:
registro, leitura dos dados inseridos, edição, exclusão e exportação Free;
análises, estações estimadas e cruzamentos Premium; consentimento específico
para participar da análise completa. Health/Flo é uma evolução secundária.
