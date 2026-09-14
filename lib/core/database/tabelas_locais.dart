import '../services/data_sync_service.dart';

/// As tabelas do banco local, nomeadas UMA vez.
///
/// Existiam quatro cópias escritas à mão da mesma lista — a exportação, a
/// limpeza do Editar Perfil, a limpeza da Privacidade e o `clearAllTables` da
/// exclusão de conta — e as quatro já tinham divergido. O sintoma era este:
/// "limpar todos os dados deste aparelho" apagava conjuntos DIFERENTES
/// conforme a tela por onde a pessoa entrava, e nenhuma das duas apagava
/// tudo. Depois da mensagem de sucesso continuavam ali o acervo inteiro, as
/// tiragens de tarô, as compras de Leitura do Ciclo e o registro menstrual —
/// numa das telas; na outra, outras.
///
/// Daqui para a frente há uma lista só, e ela se deriva: o que sobe vem de
/// [SyncEntity], o que fica vem de [soNesteAparelho]. Quem confere é
/// test/nenhuma_tabela_esquecida_test.dart, que parte das tabelas que o banco
/// REALMENTE cria — esquecer de nomear uma aqui é teste vermelho, não um dado
/// que some sem ninguém ver.
abstract final class TabelasLocais {
  /// Tudo o que a pessoa registrou neste aparelho.
  ///
  /// É a lista da exportação (levar os dados embora), da limpeza local das
  /// duas telas e da exclusão de conta. As três leem a mesma coisa porque as
  /// três falam do mesmo conjunto: o que é dela.
  ///
  /// Imutável de propósito: ela era `const` nos quatro lugares em que estava
  /// escrita à mão, e quem a consome agora compartilha o MESMO objeto — uma
  /// tela que a alterasse alteraria também o que as outras apagam.
  static final List<String> conteudo = List<String>.unmodifiable([
    for (final entity in SyncEntity.values)
      DataSyncService.localTableFor(entity),
    ...soNesteAparelho,
    ...contadoresDeCota,
  ]);

  /// Conteúdo dela que NÃO tem cópia na nuvem, por decisão registrada aqui.
  ///
  /// Esta lista é uma escolha, não um esquecimento — e é caro: o que está aqui
  /// desaparece na reinstalação do app, na troca de telefone e nos 7 dias de
  /// limpeza de armazenamento do navegador no iOS (ver data_sync_service.dart)
  /// INCLUSIVE para quem tem a sincronização ligada e acredita estar
  /// protegida. Por isso cada linha vem com a frase do que se perde: a decisão
  /// de criar entidade de sync para qualquer uma delas exige tabela nova no
  /// servidor de produção, e é decisão de quem é dona do app — não de quem
  /// está passando por aqui.
  ///
  /// Entrar nesta lista é uma das três saídas que a catraca aceita para uma
  /// tabela de conteúdo; as outras são o [SyncEntity] e [contadoresDeCota]
  /// (que não guarda registro nenhum dela). Uma tabela nova que não faça
  /// nenhuma das três derruba o teste.
  static const Set<String> soNesteAparelho = {
    // Os sabbats, as luas e as águas que ela celebrou. Na reinstalação ela
    // perde o histórico de rituais guiados, o XP que veio deles e o que a
    // Leitura do Ciclo cita do período — e o Grimório volta a tratá-la como
    // quem nunca celebrou nada.
    'guided_ritual_logs',
    // O álbum do Oráculo. Na reinstalação as cartas já reveladas voltam a ser
    // inéditas e o álbum recomeça vazio.
    'oracle_discoveries',
    // As consultas ao Conselheiro. O conselho guardado vira página no acervo e
    // volta com ele; o que se perde é a memória de que aquela pergunta já foi
    // respondida — reabrir a consulta vira pedido novo e gasta cota de IA de
    // novo.
    'advisor_consultations',
    // Os marcos das jornadas já alcançados. Na reinstalação voltam a ser
    // inéditos, e a mesma comemoração acontece uma segunda vez.
    'progress_milestones',
    // A mesa em andamento: as cartas ou pedras escolhidas antes de revelar.
    // Perde-se uma leitura interrompida no meio; a leitura confirmada já vive
    // em `tarot_readings`, `rune_readings` e `oracle_readings`, que sobem.
    'selection_sessions',
    // A pergunta da carta do dia. Perde-se a pergunta do dia corrente; a
    // tiragem em si está em `tarot_readings`.
    'tarot_day_state',
  };

  /// Os contadores de cota de IA do dia: quanto ela gastou hoje, e em quê.
  ///
  /// São tabelas de conteúdo pela forma (têm `user_id`, entram na exportação e
  /// saem nas limpezas, como tudo o mais que vive no banco dela), mas não são
  /// registro de nada que ela queira guardar — e por isso ficam fora de
  /// [soNesteAparelho], que é a lista que a dona lê para decidir o que vale
  /// uma tabela nova no servidor. Aqui não há o que proteger: na reinstalação
  /// o contador volta a zero, e isso é a favor dela. Subir o ritmo de uso ao
  /// servidor seria mandar para lá o que ela não pediu para guardar.
  ///
  /// Ficam também de fora da ADOÇÃO de dados anônimos. Duas razões, e as duas
  /// importam:
  ///
  /// 1. são as únicas tabelas de conteúdo SEM coluna `synced`, e o `UPDATE` da
  ///    adoção carimba `synced` em toda tabela que varre. Incluí-las faria o
  ///    SQLite recusar a coluna e derrubar a TRANSAÇÃO INTEIRA do primeiro
  ///    login, levando junto tudo o que já tinha sido adotado;
  /// 2. mesmo que a coluna existisse: o que ela gastou de cota antes de ter
  ///    conta não é registro dela. Herdar o contador faria a conta nova nascer
  ///    com a cota do dia já consumida.
  static const Set<String> contadoresDeCota = {
    'usage_balances',
    'usage_operations',
  };

  /// As duas tabelas em que o app semeia conteúdo PRÓPRIO, misturado ao dela
  /// na mesma tabela e separado por `is_preloaded`.
  ///
  /// Os feitiços ancestrais e as afirmações do dia não são registro dela, são
  /// o conteúdo que vem com o app. (Também nunca saem do aparelho:
  /// `_isSyncableItem` recusa `is_preloaded = 1`, então não há cópia na conta
  /// de nada disto.)
  static const Set<String> comPreCarregado = {'spells', 'affirmations'};

  /// O que o "Limpar dados locais" NÃO leva, tabela por tabela.
  ///
  /// A condição diz o que SAI: é ela que vai no `where` do `DELETE`, e o que
  /// não casa fica. São as únicas ressalvas que existem, e cada uma está aqui
  /// porque apagar aquelas linhas faria o gesto cobrar um preço que a
  /// confirmação não menciona. A exclusão de conta não tem ressalva nenhuma —
  /// lá a base local inteira deixa de valer.
  ///
  /// Quem acrescentar uma linha aqui acrescenta também o caso em
  /// test/nenhuma_tabela_esquecida_test.dart: o teste compara as chaves deste
  /// mapa com as ressalvas que ele exercita, e uma ressalva sem teste é uma
  /// ressalva que ninguém confere.
  static final Map<String, String> limpezaParcial = Map.unmodifiable({
    // O conteúdo do app fica: apagá-lo abriria o Grimório vazio até a
    // semeadura rodar de novo na abertura seguinte, e a pessoa não pediu para
    // reinstalar o app — pediu para tirar o que é dela daqui.
    for (final tabela in comPreCarregado) tabela: 'is_preloaded = 0',
    // O crédito de Leitura do Ciclo fica. `status = 'pending'` é uma compra
    // PAGA e ainda não usada — a coluna existe justamente para que "falha de
    // geração não consome a compra" —, e quem comprou offline ou está com a
    // nuvem desligada perderia dinheiro num gesto cujo texto não fala de
    // compra nenhuma. Sai o histórico do que já virou relatório: o relatório
    // em si mora em `free_writings`, que esta limpeza esvazia.
    'cycle_readings': "status <> 'pending'",
    // A lápide do ciclo fica, pelo mesmo motivo das lápides da sincronização:
    // a linha com `deleted = 1` é a memória de um dia que ela apagou e que o
    // servidor ainda não sabe. Levá-la faria o download seguinte ressuscitar
    // exatamente o dia que ela mandou sumir.
    'menstrual_days': 'deleted = 0',
  });

  /// As lápides da sincronização: o `id` do que ela apagou, para que outro
  /// aparelho não ressuscite.
  ///
  /// Não é conteúdo — é memória de exclusão — e por isso fica fora de
  /// [conteudo]: a exportação não a inclui (não há o que levar embora) e a
  /// limpeza local não a apaga (apagá-la faria voltar, no download seguinte,
  /// exatamente o que ela mandou sumir). Quem a leva junto é a exclusão de
  /// conta, onde a base local inteira deixa de valer.
  static const String lapides = 'sync_tombstones';

  /// Tabela do app, não dela: o catálogo de Códigos Premium.
  ///
  /// Sobrevive a qualquer limpeza porque não guarda registro dela — e porque
  /// apagá-la invalidaria códigos que ainda valem.
  static const Set<String> doApp = {'beta_codes'};

  /// O que existe no banco e NÃO é conteúdo dela.
  ///
  /// Nomeada para a catraca poder dizer "toda tabela do schema é conteúdo ou
  /// está aqui" — uma tabela nova não tem como ficar de fora das duas listas
  /// em silêncio.
  static const Set<String> foraDoConteudo = {lapides, ...doApp};
}
