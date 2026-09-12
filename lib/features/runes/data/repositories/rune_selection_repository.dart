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

/// Manual rune consultations. The cloth is laid out once per session; a
/// gesture only picks an ID that already exists, and the animation never
/// draws, charges or records anything.
class RuneSelectionRepository {
  RuneSelectionRepository({DatabaseHelper? dbHelper, Random? random})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _random = random ?? Random();

  final DatabaseHelper _dbHelper;
  final Random _random;

  /// Resume the open draft (or today's finished table) for this spread and
  /// question, or lay out a new cloth after checking the daily quota.
  /// [startNew] is an explicit "new reading" and only Premium can use it to
  /// leave a finished table behind; Free keeps one table per spread/question
  /// per day, exactly like the tarot policy.
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
    if (catalog.length != RuneSelectionSession.stoneCount ||
        catalog.map((r) => r.name).toSet().length != catalog.length) {
      throw const FormatException('Expected the complete rune catalog');
    }
    final asked = question.trim();
    final normalized = RuneSelectionSession.normalize(asked);
    final instant = now ?? DateTime.now();
    final key = UsageCoordinator.dayKey(instant);
    final start = DateTime(instant.year, instant.month, instant.day);
    final end = DateTime(instant.year, instant.month, instant.day + 1);
    final db = await _dbHelper.database;
    return db.transaction((txn) async {
      await UsageCoordinator.importBalance(txn, userId: userId, dayKey: key,
          legacyUsed: legacyRuneUsed, category: UsageCoordinator.runes);
      if (!(startNew && premium)) {
        // An unfinished consultation keeps its original day across midnight.
        final existing = await txn.query('selection_sessions',
            where: 'user_id = ? AND tool = ? AND spread = ? '
                'AND normalized_question = ? AND (day_key = ? OR result_id IS NULL)',
            whereArgs: [userId, RuneSelectionSession.tool, spread.name,
              normalized, key],
            orderBy: 'rowid DESC', limit: 1);
        if (existing.isNotEmpty) {
          return RuneSelectionSession.fromRow(existing.single);
        }
      }
      if (!premium) {
        final used = await UsageCoordinator.usedIn(txn, userId: userId,
            dayKey: key, category: UsageCoordinator.runes);
        if (used >= freeLimit) throw const RuneQuotaExceeded();
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
      final premium = isPremium();
      if (!premium) {
        final used = await UsageCoordinator.usedIn(txn, userId: userId,
            dayKey: session.dayKey, category: UsageCoordinator.runes);
        if (used >= freeLimit) throw const RuneQuotaExceeded();
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
