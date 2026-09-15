import 'dart:convert';
import 'dart:math';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/divination/dia_da_pergunta_repository.dart';
import '../../../../core/divination/regra_da_tiragem.dart';
import '../../../../core/services/usage_coordinator.dart';
import '../../domain/rune_selection_session.dart';
import '../models/rune_model.dart';
import '../models/rune_spread_model.dart';
import 'rune_reading_repository.dart';

/// Manual rune consultations. The cloth is laid out once per session; a
/// gesture only picks an ID that already exists, and the animation never
/// draws, charges or records anything.
class RuneSelectionRepository {
  RuneSelectionRepository({DatabaseHelper? dbHelper, Random? random})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _random = random ?? Random();

  final DatabaseHelper _dbHelper;
  final Random _random;

  /// Estende o pano: retoma o rascunho aberto do dia, ou lança um novo.
  ///
  /// NÃO recebe pergunta e NÃO cobra nada. A pergunta passou a ser escrita na
  /// tela de escolha, em cima do pano, e continua editável enquanto a pessoa
  /// escolhe — então quando o pano é estendido ainda não se sabe qual pergunta
  /// vai valer. Quem decide e cobra é [select], no instante em que a mesa
  /// fecha. O rascunho nasce com a última pergunta do dia, que é o que repõe o
  /// texto no campo.
  ///
  /// [startNew] é um "nova leitura" explícito: deixa para trás a mesa aberta e
  /// começa outra.
  Future<RuneSelectionSession> prepare({
    required String userId,
    required RuneSpreadType spread,
    required List<Rune> catalog,
    bool startNew = false,
    DateTime? now,
  }) async {
    if (catalog.length != RuneSelectionSession.stoneCount ||
        catalog.map((r) => r.name).toSet().length != catalog.length) {
      throw const FormatException('Expected the complete rune catalog');
    }
    final instant = now ?? DateTime.now();
    final key = UsageCoordinator.dayKey(instant);
    final start = DateTime(instant.year, instant.month, instant.day);
    final end = DateTime(instant.year, instant.month, instant.day + 1);
    final seed = await DiaDaPerguntaRepository.legacySeed(userId, instant,
        tool: DiaDaPerguntaRepository.runas);
    final db = await _dbHelper.database;
    return db.transaction((txn) async {
      final dia = await DiaDaPerguntaRepository.ensureIn(txn,
          userId: userId,
          dayKey: key,
          tool: DiaDaPerguntaRepository.runas,
          seed: seed);
      final asked = dia.ultimaPergunta?.trim() ?? '';
      final normalized = RuneSelectionSession.normalize(asked);
      if (!startNew) {
        // Um rascunho aberto por tiragem: a pergunta ainda pode mudar, então
        // ele não é mais identificado por ela. Uma consulta inacabada mantém o
        // dia em que começou, mesmo depois da meia-noite.
        final aberto = await txn.query('selection_sessions',
            where: 'user_id = ? AND tool = ? AND spread = ? '
                'AND result_id IS NULL',
            whereArgs: [userId, RuneSelectionSession.tool, spread.name],
            orderBy: 'rowid DESC', limit: 1);
        if (aberto.isNotEmpty) {
          return RuneSelectionSession.fromRow(aberto.single);
        }
        // Sem rascunho: se a mesa de hoje já foi feita com a pergunta que a
        // pessoa deixou escrita, é ELA que volta — reabrir o que já se viu
        // não estende pano novo.
        final feita = await txn.query('selection_sessions',
            where: 'user_id = ? AND tool = ? AND spread = ? AND day_key = ? '
                'AND normalized_question = ? AND result_id IS NOT NULL',
            whereArgs: [
              userId,
              RuneSelectionSession.tool,
              spread.name,
              key,
              normalized,
            ],
            orderBy: 'rowid DESC', limit: 1);
        if (feita.isNotEmpty) {
          return RuneSelectionSession.fromRow(feita.single);
        }
      }
      final shuffled = [...catalog]..shuffle(_random);
      // The existing domain gives every stone a 50% chance of being reversed.
      final deck = [for (final r in shuffled)
        HiddenRune(id: r.name, reversed: _random.nextBool())];
      final row = <String, Object?>{
        'id': const Uuid().v4(), 'user_id': userId,
        'tool': RuneSelectionSession.tool, 'spread': spread.name,
        'question': asked, 'normalized_question': normalized,
        'day_key': key, 'day_start': start.millisecondsSinceEpoch,
        'day_end': end.millisecondsSinceEpoch,
        'deck_version': RuneSelectionSession.deckVersion,
        'deck_json': jsonEncode(deck.map((r) => r.toJson()).toList()),
        'selected_json': '[]',
        'created_at': instant.millisecondsSinceEpoch,
        'updated_at': instant.millisecondsSinceEpoch,
      };
      await txn.insert('selection_sessions', row);
      return RuneSelectionSession.fromRow(row);
    });
  }

  /// Guarda a pergunta que está sendo escrita em cima do pano.
  ///
  /// Não cobra e não move a âncora da cota: digitar nunca pode custar nada. A
  /// âncora só se mexe quando uma mesa fecha e é de fato cobrada.
  ///
  /// Uma mesa já confirmada não muda mais de pergunta — a leitura gravada
  /// citaria uma pergunta que não foi a dela.
  Future<void> atualizarPergunta({
    required String userId,
    required String sessionId,
    required String pergunta,
  }) async {
    final asked = pergunta.trim();
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      final linhas = await txn.query('selection_sessions',
          columns: ['day_key', 'result_id'],
          where: 'id = ? AND user_id = ?',
          whereArgs: [sessionId, userId],
          limit: 1);
      if (linhas.isEmpty || linhas.single['result_id'] != null) return;
      await txn.update('selection_sessions', {
        'question': asked,
        'normalized_question': RuneSelectionSession.normalize(asked),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ? AND user_id = ?', whereArgs: [sessionId, userId]);
      await DiaDaPerguntaRepository.ensureIn(txn,
          userId: userId,
          dayKey: linhas.single['day_key'] as String,
          tool: DiaDaPerguntaRepository.runas,
          seed: const EstadoDoDia());
      await txn.update('day_question_state', {'last_question': asked},
          where: 'user_id = ? AND day_key = ? AND tool = ?',
          whereArgs: [
            userId,
            linhas.single['day_key'],
            DiaDaPerguntaRepository.runas,
          ]);
    });
  }

  /// Persist one choice. When the table is complete, confirm usage and the
  /// reading in a single transaction; a failed write keeps every stone.
  Future<RuneSelectionUpdate> select({
    required String userId,
    required String sessionId,
    required String runeId,
    required int expectedCount,
    required List<Rune> catalog,
    required List<String> positionLabels,
    required String emptyQuestionLabel,
    required bool Function() isCurrentUser,
    required bool Function() isPremium,
    required int freeLimit,
    required int legacyRuneUsed,
  }) async {
    final db = await _dbHelper.database;
    final chosen = await db.transaction((txn) async {
      _account(isCurrentUser);
      final session = await _read(txn, userId, sessionId);
      if (positionLabels.length != session.stonesNeeded) {
        throw ArgumentError('Position labels do not match the spread');
      }
      if (session.isCommitted || session.isComplete) return session;
      session.stone(runeId);
      // A stale/double command cannot fill a second position, even for another ID.
      if (session.selectedIds.length != expectedCount ||
          session.selectedIds.contains(runeId)) {
        return session;
      }
      await txn.update('selection_sessions', {
        'selected_json': jsonEncode([...session.selectedIds, runeId]),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ? AND user_id = ?', whereArgs: [sessionId, userId]);
      _account(isCurrentUser);
      return _read(txn, userId, sessionId);
    });
    if (!chosen.isComplete || chosen.isCommitted) {
      return RuneSelectionUpdate(chosen);
    }

    Map<String, dynamic>? payload;
    final update = await db.transaction((txn) async {
      _account(isCurrentUser);
      final session = await _read(txn, userId, sessionId);
      if (session.isCommitted) return RuneSelectionUpdate(session);
      // A cota é por PERGUNTA: repetir a do dia sai livre, uma nova é que
      // gasta. A MESMA regra que a tela usou para avisar antes da escolha —
      // se as duas divergissem, o aviso mentiria.
      final dia = await DiaDaPerguntaRepository.ensureIn(txn,
          userId: userId,
          dayKey: session.dayKey,
          tool: DiaDaPerguntaRepository.runas,
          seed: const EstadoDoDia());
      // O pano já não semeia o dia — ele nem olha a cota. Semear aqui deixa o
      // fechamento da mesa de pé sozinho, sem depender de quem abriu a tela.
      await UsageCoordinator.importBalance(txn,
          userId: userId,
          dayKey: session.dayKey,
          legacyUsed: legacyRuneUsed,
          category: UsageCoordinator.runes);
      final used = await UsageCoordinator.usedIn(txn,
          userId: userId,
          dayKey: session.dayKey,
          category: UsageCoordinator.runes);
      final decisao = decidirTiragem(
        premium: isPremium(),
        perguntaDoDia: dia.perguntaDoDia,
        pergunta: session.question,
        tiragemJaFeitaHoje: false,
        temCota: used < freeLimit,
      );
      // Rede de segurança, não caminho normal: a tela já desligou o pano neste
      // caso. Só sobra a corrida — a cota gasta em outra aba entre o desenho
      // da tela e o fechamento da mesa.
      if (decisao == DecisaoDaTiragem.bloquear) {
        throw const RuneQuotaExceeded();
      }
      if (decisao == DecisaoDaTiragem.cobrar) {
        await UsageCoordinator.recordIn(txn, userId: userId,
            dayKey: session.dayKey, operationId: session.id,
            category: UsageCoordinator.runes);
      }
      final reading = RuneReading(
        id: const Uuid().v4(),
        question: session.question.isEmpty ? emptyQuestionLabel : session.question,
        spreadType: session.spread,
        positions: [for (var i = 0; i < session.selectedIds.length; i++)
          RunePosition(
            position: i,
            rune: catalog.firstWhere((r) => r.name == session.selectedIds[i]),
            isReversed: session.stone(session.selectedIds[i]).reversed,
            positionMeaning: positionLabels[i],
          )],
        date: session.startedAt,
        sessionId: session.id,
      );
      _account(isCurrentUser);
      payload = await RuneReadingRepository(dbHelper: _dbHelper)
          .insertReading(reading, userId, executor: txn);
      await txn.update('day_question_state', {
        if (decisao == DecisaoDaTiragem.cobrar || dia.perguntaDoDia == null)
          'daily_question': normalizarPergunta(session.question),
        'last_question': session.question,
      }, where: 'user_id = ? AND day_key = ? AND tool = ?',
          whereArgs: [
            userId,
            session.dayKey,
            DiaDaPerguntaRepository.runas,
          ]);
      await txn.update('selection_sessions', {
        'result_id': reading.id,
        'result_signature': 'rune-session:${session.id}',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ? AND user_id = ?', whereArgs: [session.id, userId]);
      _account(isCurrentUser);
      return RuneSelectionUpdate(await _read(txn, userId, sessionId), created: true);
    });
    if (payload != null) {
      // Same best-effort upload as saveReading; the local row is already final.
      await RuneReadingRepository(dbHelper: _dbHelper).syncReading(payload!);
    }
    return update;
  }

  /// The reading confirmed for [session], as stored (positions, orientation
  /// and any counselor interpretation attached later).
  Future<RuneReading?> reading(RuneSelectionSession session) async {
    if (!session.isCommitted) return null;
    final db = await _dbHelper.database;
    final rows = await db.query('rune_readings', columns: ['reading_data'],
        where: 'id = ? AND user_id = ?',
        whereArgs: [session.resultId, session.userId], limit: 1);
    if (rows.isEmpty) return null;
    return RuneReading.fromJsonString(rows.single['reading_data'] as String);
  }

  static Future<RuneSelectionSession> _read(
      DatabaseExecutor db, String userId, String id) async {
    final rows = await db.query('selection_sessions',
        where: 'id = ? AND user_id = ? AND tool = ?',
        whereArgs: [id, userId, RuneSelectionSession.tool], limit: 1);
    if (rows.isEmpty) throw const RuneAccountChanged();
    return RuneSelectionSession.fromRow(rows.single);
  }

  static void _account(bool Function() isCurrentUser) {
    if (!isCurrentUser()) throw const RuneAccountChanged();
  }
}
