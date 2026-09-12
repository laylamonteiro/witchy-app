import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';

/// First encounters with each of the 44 cards. A discovery is recorded only
/// when a reading is confirmed; browsing meanings never counts, a repeated
/// card never adds, and nothing here grants XP. The first valid date wins.
class OracleDiscoveryRepository {
  OracleDiscoveryRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _dbHelper;
  static const catalogVersion = 'oracle-44-v1';

  Future<Set<int>> discovered(String userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query('oracle_discoveries', columns: ['card_id'],
        where: 'user_id = ?', whereArgs: [userId]);
    return {for (final r in rows) (r['card_id'] as num).toInt()};
  }

  /// When each card was first met, for the album. Cards never met are absent.
  Future<Map<int, DateTime>> firstSeen(String userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query('oracle_discoveries',
        columns: ['card_id', 'first_seen_at'],
        where: 'user_id = ?', whereArgs: [userId]);
    return {
      for (final r in rows)
        (r['card_id'] as num).toInt():
            DateTime.fromMillisecondsSinceEpoch((r['first_seen_at'] as num).toInt()),
    };
  }

  /// The retrospective on its own transaction, for screens that open without
  /// drawing anything (the album). Silent and idempotent.
  Future<void> backfill(String userId) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) => backfillIn(txn, userId));
  }

  /// Records [cardIds] for [readingId]; returns the ones seen for the first
  /// time, in catalog order of appearance.
  static Future<List<int>> recordIn(
    DatabaseExecutor db, {
    required String userId,
    required Iterable<int> cardIds,
    required String readingId,
    required DateTime seenAt,
  }) async {
    final fresh = <int>[];
    for (final id in cardIds) {
      // Platforms disagree on what insert returns for an ignored conflict,
      // so the existence check is explicit; the caller's transaction keeps
      // it atomic.
      final known = await db.query('oracle_discoveries', columns: ['card_id'],
          where: 'user_id = ? AND card_id = ?', whereArgs: [userId, id], limit: 1);
      if (known.isNotEmpty) continue;
      await db.insert('oracle_discoveries', {
        'user_id': userId,
        'card_id': id,
        'first_seen_at': seenAt.millisecondsSinceEpoch,
        'source_reading_id': readingId,
        'catalog_version': catalogVersion,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      if (!fresh.contains(id)) fresh.add(id);
    }
    return fresh;
  }

  /// Silent retrospective from readings already on this device: earlier
  /// dates first, so the first encounter keeps its date. Never celebrated.
  static Future<void> backfillIn(DatabaseExecutor db, String userId) async {
    final rows = await db.query('oracle_readings',
        columns: ['id', 'reading_data', 'date'],
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'date ASC, id ASC');
    for (final row in rows) {
      final ids = <int>[];
      try {
        final data = jsonDecode(row['reading_data'] as String) as Map;
        for (final p in (data['positions'] as List)) {
          final id = (p as Map)['card']?['id'];
          if (id is num) ids.add(id.toInt());
        }
      } catch (_) {
        continue; // A malformed old row cannot block the consultation.
      }
      if (ids.isEmpty) continue;
      await recordIn(db, userId: userId, cardIds: ids,
          readingId: row['id'] as String,
          seenAt: DateTime.fromMillisecondsSinceEpoch(row['date'] as int));
    }
  }
}
