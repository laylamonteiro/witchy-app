import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';

/// Registros de rituais guiados concluídos, no banco local.
/// Local-only na v1 (fora do pipeline de sync — exigiria migração Supabase);
/// as contagens alimentam o XP das Jornadas.
class GuidedRitualLogRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> logCompletion({
    required String userId,
    required String ritualId,
    required int xp,
    DateTime? eventDate,
    String? notes,
  }) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert(
      'guided_ritual_logs',
      {
        'id': const Uuid().v4(),
        'user_id': userId,
        'ritual_id': ritualId,
        'event_date': eventDate?.millisecondsSinceEpoch,
        'xp': xp,
        'notes': notes,
        'completed_at': now,
        'updated_at': now,
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> countForUser(String userId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM guided_ritual_logs WHERE user_id = ?',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Última conclusão de um ritual específico (null se nunca concluído).
  Future<DateTime?> lastCompletion(String userId, String ritualId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'guided_ritual_logs',
      columns: ['completed_at'],
      where: 'user_id = ? AND ritual_id = ?',
      whereArgs: [userId, ritualId],
      orderBy: 'completed_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DateTime.fromMillisecondsSinceEpoch(rows.first['completed_at'] as int);
  }
}
