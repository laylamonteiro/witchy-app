import 'dart:convert';
import 'dart:math';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/services/usage_coordinator.dart';
import '../../domain/rune_selection_session.dart';
import '../models/rune_model.dart';
import '../models/rune_spread_model.dart';
import 'rune_reading_repository.dart';

class RuneSelectionRepository {
  RuneSelectionRepository({DatabaseHelper? dbHelper, Random? random})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _random = random ?? Random();
  final DatabaseHelper _dbHelper;
  final Random _random;

  Future<RuneSelectionSession> read(String userId, String sessionId) async =>
      _read(await _dbHelper.database, userId, sessionId);

  Future<RuneSelectionSession?> latest(String userId, {DateTime? now}) async {
    final db = await _dbHelper.database;
    final rows = await db.query('selection_sessions',
        where: 'user_id = ? AND tool = ? AND (day_key = ? OR result_id IS NULL)',
        whereArgs: [userId, 'runes', UsageCoordinator.dayKey(now ?? DateTime.now())],
        orderBy: 'rowid DESC', limit: 1);
    return rows.isEmpty ? null : RuneSelectionSession.fromRow(rows.single);
  }

  Future<RuneSelectionSession> prepare({
    required String userId,
    required RuneSpreadType spread,
    required String question,
    required List<Rune> catalog,
    required bool premium,
    required int legacyRuneUsed,
    required int freeLimit,
    bool startNew = false,
    DateTime? now,
  }) async {
    if (catalog.length != 24 || catalog.map((r) => r.id).toSet().length != 24) {
      throw const FormatException('Expected the complete rune catalog');
    }
    final instant = now ?? DateTime.now();
    final key = UsageCoordinator.dayKey(instant);
    final start = DateTime(instant.year, instant.month, instant.day);
    final end = DateTime(instant.year, instant.month, instant.day + 1);
    final asked = question.trim();
    final db = await _dbHelper.database;
    return db.transaction((txn) async {
      await UsageCoordinator.importBalance(txn, userId: userId, dayKey: key,
          legacyUsed: legacyRuneUsed, category: UsageCoordinator.runes);
      if (!startNew) {
        final rows = await txn.query('selection_sessions',
            where: 'user_id = ? AND tool = ? AND spread = ? '
                'AND normalized_question = ? AND (day_key = ? OR result_id IS NULL)',
            whereArgs: [userId, 'runes', spread.name, asked.toLowerCase(), key],
            orderBy: 'rowid DESC', limit: 1);
        if (rows.isNotEmpty) return RuneSelectionSession.fromRow(rows.single);
      }
      final used = await UsageCoordinator.usedIn(txn, userId: userId,
          dayKey: key, category: UsageCoordinator.runes);
      if (!premium && used >= freeLimit) throw const RuneQuotaExceeded();
      final shuffled = [...catalog]..shuffle(_random);
      final deck = [for (final rune in shuffled)
        HiddenRune(id: rune.id, reversed: _random.nextBool())];
      final row = <String, Object?>{
        'id': const Uuid().v4(), 'user_id': userId, 'tool': 'runes',
        'spread': spread.name, 'question': asked, 'normalized_question': asked.toLowerCase(),
        'day_key': key, 'day_start': start.millisecondsSinceEpoch,
        'day_end': end.millisecondsSinceEpoch,
        'deck_version': RuneSelectionSession.deckVersion,
        'deck_json': jsonEncode(deck.map((r) => r.toJson()).toList()),
        'selected_json': '[]', 'created_at': instant.millisecondsSinceEpoch,
        'updated_at': instant.millisecondsSinceEpoch,
      };
      final session = RuneSelectionSession.fromRow(row);
      await txn.insert('selection_sessions', row);
      return session;
    });
  }

  Future<RuneSelectionUpdate> select({
    required String userId,
    required String sessionId,
    required String stoneId,
    required int expectedCount,
    required List<Rune> catalog,
    required List<String> positionLabels,
    required bool Function() isCurrentUser,
    required bool Function() isPremium,
    required int freeLimit,
  }) async {
    final db = await _dbHelper.database;
    final chosen = await db.transaction((txn) async {
      _account(isCurrentUser);
      final session = await _read(txn, userId, sessionId);
      if (positionLabels.length != session.spread.runeCount) {
        throw ArgumentError('Position labels do not match the spread');
      }
      if (session.isCommitted || session.isComplete) return session;
      session.stone(stoneId);
      if (session.selectedIds.length != expectedCount || session.selectedIds.contains(stoneId)) {
        return session;
      }
      await txn.update('selection_sessions', {
        'selected_json': jsonEncode([...session.selectedIds, stoneId]),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ? AND user_id = ?', whereArgs: [sessionId, userId]);
      _account(isCurrentUser);
      return _read(txn, userId, sessionId);
    });
    if (!chosen.isComplete || chosen.isCommitted) return RuneSelectionUpdate(chosen);

    // Keep all choices if persisting the result fails; retry the same operation.
    return db.transaction((txn) async {
      _account(isCurrentUser);
      final session = await _read(txn, userId, sessionId);
      if (session.isCommitted) return RuneSelectionUpdate(session);
      final used = await UsageCoordinator.usedIn(txn, userId: userId,
          dayKey: session.dayKey, category: UsageCoordinator.runes);
      final premium = isPremium();
      if (!premium && used >= freeLimit) throw const RuneQuotaExceeded();
      final reading = RuneReading(
        id: session.id, question: session.question, spreadType: session.spread,
        date: session.startedAt,
        positions: [for (var i = 0; i < session.selectedIds.length; i++)
          RunePosition(position: i,
            rune: catalog.firstWhere((r) => r.id == session.selectedIds[i]),
            isReversed: session.stone(session.selectedIds[i]).reversed,
            positionMeaning: positionLabels[i],
          )],
      );
      if (!premium) {
        await UsageCoordinator.recordIn(txn, userId: userId, dayKey: session.dayKey,
            operationId: session.id, category: UsageCoordinator.runes);
      }
      await RuneReadingRepository().saveReading(reading, userId, executor: txn);
      await txn.update('selection_sessions', {
        'result_id': reading.id, 'result_signature': 'runes-session:${session.id}',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ? AND user_id = ?', whereArgs: [session.id, userId]);
      _account(isCurrentUser);
      return RuneSelectionUpdate(await _read(txn, userId, sessionId), created: true);
    });
  }

  static Future<RuneSelectionSession> _read(DatabaseExecutor db, String userId, String id) async {
    final rows = await db.query('selection_sessions',
        where: 'id = ? AND user_id = ? AND tool = ?',
        whereArgs: [id, userId, 'runes'], limit: 1);
    if (rows.isEmpty) throw const RuneAccountChanged();
    return RuneSelectionSession.fromRow(rows.single);
  }

  static void _account(bool Function() isCurrentUser) {
    if (!isCurrentUser()) throw const RuneAccountChanged();
  }
}
