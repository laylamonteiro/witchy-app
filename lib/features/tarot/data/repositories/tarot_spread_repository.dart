import 'dart:convert';
import 'dart:math';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/services/usage_coordinator.dart';
import '../../domain/daily_tarot_session.dart';
import '../../domain/regra_da_carta_do_dia.dart';
import '../../domain/tarot_spread_session.dart';
import '../models/tarot_card_model.dart';
import 'tarot_day_repository.dart';
import 'tarot_reading_repository.dart';

class TarotSpreadRepository {
  TarotSpreadRepository({DatabaseHelper? dbHelper, Random? random})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _random = random ?? Random();

  final DatabaseHelper _dbHelper;
  final Random _random;

  Future<TarotSpreadSession> prepare({
    required String userId,
    required String spread,
    required String question,
    required List<TarotCard> catalog,
    required bool premium,
    required int legacyOracleUsed,
    required int freeLimit,
    bool startNew = false,
    DateTime? now,
  }) async {
    final asked = question.trim();
    if (asked.isEmpty || !TarotSpreadSession.counts.containsKey(spread)) {
      throw ArgumentError('Expected a question and a supported spread');
    }
    if (catalog.length != 78 || catalog.map((c) => c.id).toSet().length != 78) {
      throw const FormatException('Expected the complete tarot catalog');
    }
    final instant = now ?? DateTime.now();
    final key = UsageCoordinator.dayKey(instant);
    final start = DateTime(instant.year, instant.month, instant.day);
    final end = DateTime(instant.year, instant.month, instant.day + 1);
    final seed = await TarotDayRepository.legacySeed(userId, instant);
    final db = await _dbHelper.database;
    return db.transaction((txn) async {
      final day = await TarotDayRepository.ensureIn(txn,
          userId: userId, dayKey: key, seed: seed);
      await UsageCoordinator.importBalance(txn,
          userId: userId, dayKey: key, legacyUsed: legacyOracleUsed);

      Map<String, Object?>? legacy;
      if (!(startNew && premium)) {
        // An unfinished consultation keeps its original day across midnight.
        final existing = await txn.query('selection_sessions',
            where: 'user_id = ? AND tool = ? AND spread = ? '
                'AND normalized_question = ? AND (day_key = ? OR result_id IS NULL)',
            whereArgs: [userId, 'tarot', spread, asked.toLowerCase(), key],
            orderBy: 'rowid DESC', limit: 1);
        if (existing.isNotEmpty) return TarotSpreadSession.fromRow(existing.single);
        final oldDraws = await txn.query('tarot_readings',
            where: 'user_id = ? AND spread_type = ? AND date >= ? AND date < ?',
            whereArgs: [userId, spread, start.millisecondsSinceEpoch,
              end.millisecondsSinceEpoch], orderBy: 'date DESC, id DESC');
        for (final row in oldDraws) {
          if ((row['question'] as String?)?.trim().toLowerCase() == asked.toLowerCase()) {
            legacy = row;
            break;
          }
        }
      }
      if (legacy == null) {
        final used = await UsageCoordinator.usedIn(txn, userId: userId, dayKey: key);
        _quota(premium, day.dailyQuestion, asked, used, freeLimit);
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
        'spread': spread, 'question': asked, 'normalized_question': asked.toLowerCase(),
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
      await txn.update('tarot_day_state', {'last_question': asked},
          where: 'user_id = ? AND day_key = ?', whereArgs: [userId, key]);
      return session;
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
      final day = await TarotDayRepository.ensureIn(txn,
          userId: userId, dayKey: session.dayKey, seed: const TarotDayState());
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
      final decision = _quota(premium, day.dailyQuestion, session.question, used, freeLimit);
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
      await txn.update('tarot_day_state', {
        if (decision == DecisaoDaTiragem.cobrar || day.dailyQuestion == null)
          'daily_question': session.question.toLowerCase(),
        'last_question': session.question,
      }, where: 'user_id = ? AND day_key = ?', whereArgs: [userId, session.dayKey]);
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
