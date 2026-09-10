import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';

/// Journey steps already reached, one row per person and step. A milestone is
/// acquired once: a count that drops (a deleted record) and recovers never
/// re-grants it, and rows adopted from existing history have no source
/// action, so they are never presented as fresh.
class ProgressMilestoneRepository {
  ProgressMilestoneRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _dbHelper;

  Future<Set<String>> acquired(String userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query('progress_milestones', columns: ['milestone_id'],
        where: 'user_id = ?', whereArgs: [userId]);
    return {for (final r in rows) r['milestone_id'] as String};
  }

  /// Records [milestoneIds] and returns the ones that were not there yet, in
  /// the given order. [sourceActionId] null means a silent adoption.
  Future<List<String>> record({
    required String userId,
    required Iterable<String> milestoneIds,
    String? sourceActionId,
    DateTime? at,
  }) async {
    final db = await _dbHelper.database;
    final when = (at ?? DateTime.now()).millisecondsSinceEpoch;
    return db.transaction((txn) async {
      final known = await txn.query('progress_milestones', columns: ['milestone_id'],
          where: 'user_id = ?', whereArgs: [userId]);
      final have = {for (final r in known) r['milestone_id'] as String};
      final fresh = <String>[];
      for (final id in milestoneIds) {
        if (have.contains(id) || fresh.contains(id)) continue;
        await txn.insert('progress_milestones', {
          'user_id': userId,
          'milestone_id': id,
          'first_reached_at': when,
          'source_action_id': sourceActionId,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        fresh.add(id);
      }
      return fresh;
    });
  }
}
