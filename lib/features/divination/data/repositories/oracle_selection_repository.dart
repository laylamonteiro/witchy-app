import 'dart:convert';
import 'dart:math';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/services/usage_coordinator.dart';
import '../../domain/oracle_selection_session.dart';
import '../models/oracle_card_model.dart';
import 'oracle_discovery_repository.dart';
import 'oracle_reading_repository.dart';

/// Manual Oracle consultations on the tarot's selection infrastructure.
/// The Oracle shares the tarot/oracle daily quota category; it has no
/// question, so Free keeps one table per spread per day and can reopen it.
class OracleSelectionRepository {
  OracleSelectionRepository({DatabaseHelper? dbHelper, Random? random})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _random = random ?? Random();

  final DatabaseHelper _dbHelper;
  final Random _random;

  Future<OracleSelectionSession> prepare({
    required String userId,
    required OracleSpreadType spread,
    required List<OracleCard> catalog,
    required bool premium,
    required int legacyOracleUsed,
    required int freeLimit,
    bool startNew = false,
    DateTime? now,
  }) async {
    if (catalog.length != OracleSelectionSession.cardCount ||
        catalog.map((c) => c.id).toSet().length != catalog.length) {
      throw const FormatException('Expected the complete oracle catalog');
    }
    final instant = now ?? DateTime.now();
    final key = UsageCoordinator.dayKey(instant);
    final start = DateTime(instant.year, instant.month, instant.day);
    final end = DateTime(instant.year, instant.month, instant.day + 1);
    final db = await _dbHelper.database;
    return db.transaction((txn) async {
      await UsageCoordinator.importBalance(txn,
          userId: userId, dayKey: key, legacyUsed: legacyOracleUsed);
      // Discoveries recoverable from the local history are adopted quietly.
      await OracleDiscoveryRepository.backfillIn(txn, userId);
      if (!(startNew && premium)) {
        final existing = await txn.query('selection_sessions',
            where: 'user_id = ? AND tool = ? AND spread = ? '
                'AND (day_key = ? OR result_id IS NULL)',
            whereArgs: [userId, OracleSelectionSession.tool, spread.name, key],
            orderBy: 'rowid DESC', limit: 1);
        if (existing.isNotEmpty) {
          return OracleSelectionSession.fromRow(existing.single);
        }
      }
      if (!premium) {
        final used = await UsageCoordinator.usedIn(txn, userId: userId, dayKey: key);
        if (used >= freeLimit) throw const OracleQuotaExceeded();
      }
      final deck = [for (final c in [...catalog]..shuffle(_random))
        OracleSelectionSession.idOf(c)];
      final row = <String, Object?>{
        'id': const Uuid().v4(), 'user_id': userId,
        'tool': OracleSelectionSession.tool, 'spread': spread.name,
        'question': '', 'normalized_question': '',
        'day_key': key, 'day_start': start.millisecondsSinceEpoch,
        'day_end': end.millisecondsSinceEpoch,
        'deck_version': OracleSelectionSession.deckVersion,
        'deck_json': jsonEncode(deck), 'selected_json': '[]',
        'created_at': instant.millisecondsSinceEpoch,
        'updated_at': instant.millisecondsSinceEpoch,
      };
      await txn.insert('selection_sessions', row);
      return OracleSelectionSession.fromRow(row);
    });
  }

  Future<OracleSelectionUpdate> select({
    required String userId,
    required String sessionId,
    required String cardId,
    required int expectedCount,
    required List<OracleCard> catalog,
    required List<String> positionLabels,
    required bool Function() isCurrentUser,
    required bool Function() isPremium,
    required int freeLimit,
  }) async {
    final db = await _dbHelper.database;
    final chosen = await db.transaction((txn) async {
      _account(isCurrentUser);
      final session = await _read(txn, userId, sessionId);
      if (positionLabels.length != session.cardsNeeded) {
        throw ArgumentError('Position labels do not match the spread');
      }
      if (session.isCommitted || session.isComplete) return session;
      if (!session.deck.contains(cardId)) {
        throw StateError('Card is not part of this session');
      }
      if (session.selectedIds.length != expectedCount ||
          session.selectedIds.contains(cardId)) {
        return session;
      }
      await txn.update('selection_sessions', {
        'selected_json': jsonEncode([...session.selectedIds, cardId]),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ? AND user_id = ?', whereArgs: [sessionId, userId]);
      _account(isCurrentUser);
      return _read(txn, userId, sessionId);
    });
    if (!chosen.isComplete || chosen.isCommitted) {
      return OracleSelectionUpdate(chosen);
    }

    Map<String, dynamic>? payload;
    final update = await db.transaction((txn) async {
      _account(isCurrentUser);
      final session = await _read(txn, userId, sessionId);
      if (session.isCommitted) return OracleSelectionUpdate(session);
      if (!isPremium()) {
        final used = await UsageCoordinator.usedIn(txn,
            userId: userId, dayKey: session.dayKey);
        if (used >= freeLimit) throw const OracleQuotaExceeded();
        await UsageCoordinator.recordIn(txn, userId: userId,
            dayKey: session.dayKey, operationId: session.id);
      }
      final cards = [for (final id in session.selectedIds)
        catalog.firstWhere((c) => OracleSelectionSession.idOf(c) == id)];
      final reading = OracleReading(
        id: const Uuid().v4(),
        spreadType: session.spread,
        positions: [for (var i = 0; i < cards.length; i++)
          OracleCardPosition(position: i, card: cards[i],
              positionMeaning: positionLabels[i])],
        date: session.startedAt,
        sessionId: session.id,
      );
      _account(isCurrentUser);
      payload = await OracleReadingRepository(dbHelper: _dbHelper)
          .insertReading(reading, userId, executor: txn);
      final fresh = await OracleDiscoveryRepository.recordIn(txn,
          userId: userId, cardIds: cards.map((c) => c.id),
          readingId: reading.id, seenAt: session.startedAt);
      await txn.update('selection_sessions', {
        'result_id': reading.id,
        'result_signature': 'oracle-session:${session.id}',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ? AND user_id = ?', whereArgs: [session.id, userId]);
      _account(isCurrentUser);
      return OracleSelectionUpdate(await _read(txn, userId, sessionId),
          created: true, newDiscoveries: fresh);
    });
    if (payload != null) {
      await OracleReadingRepository(dbHelper: _dbHelper).syncReading(payload!);
    }
    return update;
  }

  Future<OracleReading?> reading(OracleSelectionSession session) async {
    if (!session.isCommitted) return null;
    return OracleReadingRepository(dbHelper: _dbHelper)
        .reading(session.resultId!, session.userId);
  }

  static Future<OracleSelectionSession> _read(
      DatabaseExecutor db, String userId, String id) async {
    final rows = await db.query('selection_sessions',
        where: 'id = ? AND user_id = ? AND tool = ?',
        whereArgs: [id, userId, OracleSelectionSession.tool], limit: 1);
    if (rows.isEmpty) throw const OracleAccountChanged();
    return OracleSelectionSession.fromRow(rows.single);
  }

  static void _account(bool Function() isCurrentUser) {
    if (!isCurrentUser()) throw const OracleAccountChanged();
  }
}
