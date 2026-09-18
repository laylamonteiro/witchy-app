import 'dart:convert';
import 'dart:math';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/services/usage_coordinator.dart';
import '../../domain/daily_tarot_session.dart';
import '../../../../core/divination/regra_da_tiragem.dart';
import '../../domain/tarot_spread_session.dart';
import '../models/tarot_card_model.dart';
import '../../../../core/divination/dia_da_pergunta_repository.dart';
import 'tarot_reading_repository.dart';

class TarotSpreadRepository {
  TarotSpreadRepository({DatabaseHelper? dbHelper, Random? random})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _random = random ?? Random();

  final DatabaseHelper _dbHelper;
  final Random _random;

  /// Estende a mesa: retoma o rascunho aberto do dia, ou lança uma nova.
  ///
  /// NÃO recebe pergunta e NÃO cobra nada. A pergunta passou a ser escrita na
  /// tela de escolha, em cima da mesa, e continua editável enquanto a pessoa
  /// escolhe — então quando a mesa é estendida ainda não se sabe qual pergunta
  /// vai valer. Quem decide e cobra é [select], quando a mesa fecha.
  Future<TarotSpreadSession> prepare({
    required String userId,
    required String spread,
    required List<TarotCard> catalog,
    bool startNew = false,
    DateTime? now,
  }) async {
    if (!TarotSpreadSession.counts.containsKey(spread)) {
      throw ArgumentError.value(spread, 'spread', 'Unsupported spread');
    }
    if (catalog.length != 78 || catalog.map((c) => c.id).toSet().length != 78) {
      throw const FormatException('Expected the complete tarot catalog');
    }
    final instant = now ?? DateTime.now();
    final key = UsageCoordinator.dayKey(instant);
    final start = DateTime(instant.year, instant.month, instant.day);
    final end = DateTime(instant.year, instant.month, instant.day + 1);
    final seed = await DiaDaPerguntaRepository.legacySeed(userId, instant,
        tool: DiaDaPerguntaRepository.tarot);
    final db = await _dbHelper.database;
    return db.transaction((txn) async {
      final day = await DiaDaPerguntaRepository.ensureIn(txn,
          userId: userId,
          dayKey: key,
          tool: DiaDaPerguntaRepository.tarot,
          seed: seed);
      final asked = day.ultimaPergunta?.trim() ?? '';
      final normalizada = normalizarPergunta(asked);

      Map<String, Object?>? legacy;
      if (!startNew) {
        // Um rascunho aberto por tiragem: a pergunta ainda pode mudar, então
        // ele não é mais identificado por ela. Uma consulta inacabada mantém o
        // dia em que começou, mesmo depois da meia-noite.
        final aberta = await txn.query('selection_sessions',
            where: 'user_id = ? AND tool = ? AND spread = ? '
                'AND result_id IS NULL',
            whereArgs: [userId, 'tarot', spread],
            orderBy: 'rowid DESC', limit: 1);
        if (aberta.isNotEmpty) return TarotSpreadSession.fromRow(aberta.single);
        // Sem rascunho: se a mesa de hoje já foi feita com a pergunta que a
        // pessoa deixou escrita, é ELA que volta.
        final feita = await txn.query('selection_sessions',
            where: 'user_id = ? AND tool = ? AND spread = ? AND day_key = ? '
                'AND normalized_question = ? AND result_id IS NOT NULL',
            whereArgs: [userId, 'tarot', spread, key, normalizada],
            orderBy: 'rowid DESC', limit: 1);
        if (feita.isNotEmpty) return TarotSpreadSession.fromRow(feita.single);
        final oldDraws = await txn.query('tarot_readings',
            where: 'user_id = ? AND spread_type = ? AND date >= ? AND date < ?',
            whereArgs: [userId, spread, start.millisecondsSinceEpoch,
              end.millisecondsSinceEpoch], orderBy: 'date DESC, id DESC');
        for (final row in oldDraws) {
          if (normalizarPergunta((row['question'] as String?) ?? '') ==
              normalizada) {
            legacy = row;
            break;
          }
        }
      }

      final shuffled = [...catalog]..shuffle(_random);
      final deck = [for (final c in shuffled)
        HiddenTarotCard(id: c.id, reversed: _random.nextInt(4) == 0)];
      final selected = <String>[];
      String? signature;
      if (legacy != null) {
        final payload = jsonDecode(legacy['reading_data'] as String) as Map;
        final savedCards = (payload['cards'] as List).cast<Map>();
        if (savedCards.length != TarotSpreadSession.counts[spread]) {
          throw const FormatException('Invalid existing spread');
        }
        for (final saved in savedCards) {
          final card = catalog.firstWhere((c) =>
              (c.suit.name == saved['suit'] && c.number == saved['number']) ||
              (saved['suit'] == null && c.name == saved['name']));
          selected.add(card.id);
          final index = deck.indexWhere((c) => c.id == card.id);
          deck[index] = HiddenTarotCard(id: card.id, reversed: saved['reversed'] == true);
        }
        signature = legacy['signature'] as String? ?? 'spread-legacy:${legacy['id']}';
        if (legacy['signature'] == null) {
          await txn.update('tarot_readings', {'signature': signature},
              where: 'id = ? AND user_id = ?', whereArgs: [legacy['id'], userId]);
        }
      }
      final row = <String, Object?>{
        'id': const Uuid().v4(), 'user_id': userId, 'tool': 'tarot',
        'spread': spread, 'question': asked,
        'normalized_question': normalizada,
        'day_key': key, 'day_start': start.millisecondsSinceEpoch,
        'day_end': end.millisecondsSinceEpoch, 'deck_version': DailyTarotSession.deckVersion,
        'deck_json': jsonEncode(deck.map((c) => c.toJson()).toList()),
        'selected_json': jsonEncode(selected), 'result_id': legacy?['id'],
        'result_signature': signature,
        'created_at': legacy?['date'] ?? instant.millisecondsSinceEpoch,
        'updated_at': instant.millisecondsSinceEpoch,
      };
      final session = TarotSpreadSession.fromRow(row);
      await txn.insert('selection_sessions', row);
      await txn.update('day_question_state', {'last_question': asked},
          where: 'user_id = ? AND day_key = ? AND tool = ?',
          whereArgs: [userId, key, DiaDaPerguntaRepository.tarot]);
      return session;
    });
  }

  /// Guarda a pergunta que está sendo escrita em cima da mesa.
  ///
  /// Não cobra e não move a âncora da cota: digitar nunca pode custar nada. Uma
  /// mesa já confirmada não muda mais de pergunta — a leitura gravada citaria
  /// uma pergunta que não foi a dela.
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
      final dia = linhas.single['day_key'] as String;
      await txn.update('selection_sessions', {
        'question': asked,
        'normalized_question': normalizarPergunta(asked),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ? AND user_id = ?', whereArgs: [sessionId, userId]);
      await DiaDaPerguntaRepository.ensureIn(txn,
          userId: userId,
          dayKey: dia,
          tool: DiaDaPerguntaRepository.tarot,
          seed: const EstadoDoDia());
      await txn.update('day_question_state', {'last_question': asked},
          where: 'user_id = ? AND day_key = ? AND tool = ?',
          whereArgs: [userId, dia, DiaDaPerguntaRepository.tarot]);
    });
  }

  Future<TarotSpreadUpdate> select({
    required String userId,
    required String sessionId,
    required String cardId,
    required int expectedCount,
    required List<TarotCard> catalog,
    required List<String> positionLabels,
    required bool Function() isCurrentUser,
    required bool Function() isPremium,
    required int freeLimit,
    required int legacyOracleUsed,
  }) async {
    final db = await _dbHelper.database;
    final chosen = await db.transaction((txn) async {
      _account(isCurrentUser);
      final session = await _read(txn, userId, sessionId);
      if (positionLabels.length != session.cardCount) {
        throw ArgumentError('Position labels do not match the spread');
      }
      if (session.isCommitted || session.isComplete) return session;
      session.card(cardId);
      // A stale/double command cannot fill a second position, even for another ID.
      if (session.selectedIds.length != expectedCount || session.selectedIds.contains(cardId)) {
        return session;
      }
      await txn.update('selection_sessions', {
        'selected_json': jsonEncode([...session.selectedIds, cardId]),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ? AND user_id = ?', whereArgs: [sessionId, userId]);
      _account(isCurrentUser);
      return _read(txn, userId, sessionId);
    });
    if (!chosen.isComplete || chosen.isCommitted) return TarotSpreadUpdate(chosen);

    // A result failure rolls back the debit, but every chosen card survives.
    return db.transaction((txn) async {
      _account(isCurrentUser);
      final session = await _read(txn, userId, sessionId);
      if (session.isCommitted) return TarotSpreadUpdate(session);
      final day = await DiaDaPerguntaRepository.ensureIn(txn,
          userId: userId,
          dayKey: session.dayKey,
          tool: DiaDaPerguntaRepository.tarot,
          seed: const EstadoDoDia());
      // A mesa já não semeia o dia — ela nem olha a cota. Semear aqui deixa o
      // fechamento de pé sozinho, sem depender de quem abriu a tela.
      await UsageCoordinator.importBalance(txn,
          userId: userId,
          dayKey: session.dayKey,
          legacyUsed: legacyOracleUsed);
      final used = await UsageCoordinator.usedIn(txn,
          userId: userId, dayKey: session.dayKey);
      final premium = isPremium();
      if (!premium) {
        // A second Premium draft cannot bypass Free reuse after a downgrade.
        final day = session.dayStart;
        final end = DateTime(day.year, day.month, day.day + 1);
        final recorded = await txn.query('tarot_readings', columns: ['question'],
            where: 'user_id = ? AND spread_type = ? AND date >= ? AND date < ?',
            whereArgs: [userId, session.spread, day.millisecondsSinceEpoch,
              end.millisecondsSinceEpoch]);
        if (recorded.any((row) => (row['question'] as String?)?.trim().toLowerCase() ==
            session.question.toLowerCase())) throw const TarotQuotaExceeded();
      }
      _account(isCurrentUser);
      final decision = _quota(premium, day.perguntaDoDia, session.question, used, freeLimit);
      if (decision == DecisaoDaTiragem.cobrar) {
        await UsageCoordinator.recordIn(txn, userId: userId,
            dayKey: session.dayKey, operationId: session.id);
      }
      final drawn = [for (var i = 0; i < session.selectedIds.length; i++)
        TarotDrawnCard(
          card: catalog.firstWhere((c) => c.id == session.selectedIds[i]),
          isReversed: session.card(session.selectedIds[i]).reversed,
          positionLabel: positionLabels[i],
        )];
      final signature = 'spread-session:${session.id}';
      final resultId = await TarotReadingRepository(dbHelper: _dbHelper).recordDraw(
        userId: userId, spreadName: session.spread, signature: signature,
        drawn: drawn, question: session.question, executor: txn,
        sessionId: session.id, date: session.startedAt,
      );
      await txn.update('day_question_state', {
        if (decision == DecisaoDaTiragem.cobrar || day.perguntaDoDia == null)
          'daily_question': normalizarPergunta(session.question),
        'last_question': session.question,
      }, where: 'user_id = ? AND day_key = ? AND tool = ?',
          whereArgs: [userId, session.dayKey, DiaDaPerguntaRepository.tarot]);
      await txn.update('selection_sessions', {
        'result_id': resultId, 'result_signature': signature,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ? AND user_id = ?', whereArgs: [session.id, userId]);
      _account(isCurrentUser);
      return TarotSpreadUpdate(await _read(txn, userId, sessionId), created: true);
    });
  }

  Future<String?> interpretation(TarotSpreadSession session) async {
    if (!session.isCommitted) return null;
    final db = await _dbHelper.database;
    final rows = await db.query('tarot_readings', columns: ['reading_data'],
        where: 'id = ? AND user_id = ?', whereArgs: [session.resultId, session.userId], limit: 1);
    if (rows.isEmpty) return null;
    return (jsonDecode(rows.single['reading_data'] as String) as Map)['interpretation'] as String?;
  }

  static Future<TarotSpreadSession> _read(DatabaseExecutor db, String userId, String id) async {
    final rows = await db.query('selection_sessions',
        where: 'id = ? AND user_id = ? AND tool = ? AND spread IN (?, ?)',
        whereArgs: [id, userId, 'tarot', 'threeCards', 'cross'], limit: 1);
    if (rows.isEmpty) throw const TarotAccountChanged();
    return TarotSpreadSession.fromRow(rows.single);
  }

  static void _account(bool Function() isCurrentUser) {
    if (!isCurrentUser()) throw const TarotAccountChanged();
  }

  static DecisaoDaTiragem _quota(bool premium, String? remembered,
      String question, int used, int limit) {
    final decision = decidirTiragem(premium: premium, perguntaDoDia: remembered,
        pergunta: question, tiragemJaFeitaHoje: false, temCota: used < limit);
    if (decision == DecisaoDaTiragem.bloquear) throw const TarotQuotaExceeded();
    return decision;
  }
}
