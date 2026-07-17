import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';
import '../models/free_writing_model.dart';

class FreeWritingRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final DataSyncService _syncService = DataSyncService();

  Future<List<FreeWritingModel>> getAll(String userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'free_writings',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );
    return List.generate(maps.length, (i) => FreeWritingModel.fromMap(maps[i]));
  }

  Future<FreeWritingModel?> getById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'free_writings',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return FreeWritingModel.fromMap(maps.first);
  }

  /// Insere ou substitui (upsert) — reutilizado pelo autosave para manter o
  /// mesmo id ao longo da edição de uma reflexão.
  Future<int> insert(FreeWritingModel writing) async {
    final db = await _dbHelper.database;
    final result = await db.insert(
      'free_writings',
      writing.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _syncService.syncItem(SyncEntity.freeWritings, writing.toMap());
    return result;
  }

  Future<int> update(FreeWritingModel writing) async {
    final db = await _dbHelper.database;
    final result = await db.update(
      'free_writings',
      writing.toMap(),
      where: 'id = ?',
      whereArgs: [writing.id],
    );
    _syncService.syncItem(SyncEntity.freeWritings, writing.toMap());
    return result;
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    final result = await db.delete(
      'free_writings',
      where: 'id = ?',
      whereArgs: [id],
    );
    _syncService.deleteItem(SyncEntity.freeWritings, id);
    return result;
  }
}
