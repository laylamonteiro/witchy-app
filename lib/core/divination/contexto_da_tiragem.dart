import '../database/database_helper.dart';
import '../services/usage_coordinator.dart';
import 'dia_da_pergunta_repository.dart';
import 'regra_da_tiragem.dart';

/// O que a tela precisa saber para dizer, ANTES da escolha, o que aquela
/// pergunta vai custar.
///
/// Carregado de uma vez, e não a cada tecla: as três coisas que exigem banco
/// só mudam quando o dia vira, quando uma tiragem confirma ou quando o app
/// volta do segundo plano. O texto do campo muda a cada letra — e com o
/// contexto em memória a avaliação vira [avaliarTiragem], que é pura e
/// síncrona. Zero I/O por tecla.
class ContextoDaTiragem {
  const ContextoDaTiragem({
    this.perguntaDoDia,
    this.rascunho,
    this.temCota = true,
    this.mesasDeHoje = const {},
  });

  /// A âncora da cota: a pergunta que já foi cobrada hoje NESTA ferramenta.
  /// Repeti-la é livre. Vem normalizada.
  final String? perguntaDoDia;

  /// O que a pessoa digitou por último, na grafia original — é o que repõe o
  /// campo quando ela volta à tela.
  final String? rascunho;

  final bool temCota;

  /// As mesas que já foram confirmadas hoje nesta ferramenta e nesta tiragem,
  /// da pergunta normalizada para o id da sessão. É um punhado de linhas por
  /// dia, então cabe em memória — e é o que permite responder "esta mesa já
  /// está feita" sem ir ao banco a cada letra.
  final Map<String, String> mesasDeHoje;

  /// A pergunta de hoje na grafia em que a pessoa a escreveu.
  ///
  /// A âncora é guardada NORMALIZADA — é ela que a comparação usa —, e devolver
  /// isso ao campo faria a pergunta reaparecer toda em minúsculas, como se o
  /// app tivesse reescrito o que ela digitou. Quando o rascunho é a mesma
  /// pergunta, é a grafia dele que volta; só quando não é (a pessoa começou a
  /// escrever outra coisa) sobra a forma normalizada.
  String? get perguntaDeHojeNoCampo {
    final ancora = perguntaDoDia;
    if (ancora == null) return null;
    final grafia = rascunho;
    if (grafia != null && normalizarPergunta(grafia) == ancora) return grafia;
    return ancora;
  }

  /// O id da mesa já feita com [pergunta], se houver.
  String? mesaFeitaCom(String pergunta) =>
      mesasDeHoje[normalizarPergunta(pergunta)];

  /// O que dizer sobre [pergunta], agora.
  SituacaoDaTiragem situacaoDe(String pergunta, {required bool premium}) =>
      avaliarTiragem(
        premium: premium,
        perguntaDoDia: perguntaDoDia,
        pergunta: pergunta,
        temCota: temCota,
        tiragemJaFeitaHoje: mesaFeitaCom(pergunta) != null,
      );
}

/// Monta o [ContextoDaTiragem] de uma ferramenta e tiragem.
///
/// Serve as três adivinhações: só mudam o `tool`, o `spread` e a categoria de
/// cota (tarô e oráculo dividem a mesma; runas têm a sua).
class ContextoDaTiragemRepository {
  ContextoDaTiragemRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;
  final DatabaseHelper _dbHelper;

  Future<ContextoDaTiragem> carregar({
    required String userId,
    required String tool,
    required String spread,
    required String categoriaDeCota,
    required int legacyUsed,
    required int freeLimit,
    DateTime? now,
  }) async {
    final instante = now ?? DateTime.now();
    final dia = UsageCoordinator.dayKey(instante);
    final seed = await DiaDaPerguntaRepository.legacySeed(userId, instante,
        tool: tool);
    final db = await _dbHelper.database;
    return db.transaction((txn) async {
      final estado = await DiaDaPerguntaRepository.ensureIn(txn,
          userId: userId, dayKey: dia, tool: tool, seed: seed);
      await UsageCoordinator.importBalance(txn,
          userId: userId,
          dayKey: dia,
          legacyUsed: legacyUsed,
          category: categoriaDeCota);
      final usado = await UsageCoordinator.usedIn(txn,
          userId: userId, dayKey: dia, category: categoriaDeCota);
      // Só as mesas CONFIRMADAS: um rascunho aberto não é mesa feita, é a
      // própria sessão em curso.
      final feitas = await txn.query(
        'selection_sessions',
        columns: ['id', 'normalized_question'],
        where: 'user_id = ? AND tool = ? AND spread = ? AND day_key = ? '
            'AND result_id IS NOT NULL',
        whereArgs: [userId, tool, spread, dia],
      );
      return ContextoDaTiragem(
        perguntaDoDia: estado.perguntaDoDia,
        rascunho: estado.ultimaPergunta,
        temCota: usado < freeLimit,
        mesasDeHoje: {
          for (final linha in feitas)
            (linha['normalized_question'] as String? ?? ''):
                linha['id'] as String,
        },
      );
    });
  }
}
