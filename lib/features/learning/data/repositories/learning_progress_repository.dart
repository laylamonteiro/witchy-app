import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';

/// Progresso do Grimório Vivo no banco local, sincronizado com a nuvem
/// no mesmo padrão dos demais registros (spells, diários...).
class LearningProgressRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final DataSyncService _syncService = DataSyncService();

  Future<Set<String>> completedLessonIds(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'learning_progress',
      columns: ['lesson_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return {for (final m in maps) m['lesson_id'] as String};
  }

  Future<void> markCompleted(String userId, String lessonId) async {
    final db = await _dbHelper.database;
    final existing = await db.query(
      'learning_progress',
      where: 'user_id = ? AND lesson_id = ?',
      whereArgs: [userId, lessonId],
      limit: 1,
    );
    if (existing.isNotEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final row = {
      'id': const Uuid().v4(),
      'user_id': userId,
      'lesson_id': lessonId,
      'completed_at': now,
      'updated_at': now,
      'synced': 0,
    };
    await db.insert(
      'learning_progress',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _syncService.syncItem(SyncEntity.learningProgress, row);
  }

  /// Migra o progresso antigo salvo em SharedPreferences para o banco.
  Future<void> importLegacy(String userId, Set<String> lessonIds) async {
    for (final lessonId in lessonIds) {
      await markCompleted(userId, lessonId);
    }
  }
}
