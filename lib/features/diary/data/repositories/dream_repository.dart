import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';
import '../models/dream_model.dart';

class DreamRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final DataSyncService _syncService = DataSyncService();

  Future<List<DreamModel>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dreams',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => DreamModel.fromMap(maps[i]));
  }

  Future<DreamModel?> getById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dreams',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return DreamModel.fromMap(maps.first);
  }

  Future<List<DreamModel>> getByTag(String tag) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dreams',
      where: 'tags LIKE ?',
      whereArgs: ['%$tag%'],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => DreamModel.fromMap(maps[i]));
  }

  Future<List<DreamModel>> searchByContent(String query) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dreams',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => DreamModel.fromMap(maps[i]));
  }

  Future<int> insert(DreamModel dream) async {
    final db = await _dbHelper.database;
    final result = await db.insert(
      'dreams',
      dream.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // Sync to cloud in background
    _syncService.syncItem(SyncEntity.dreams, dream.toMap());
    return result;
  }

  Future<int> update(DreamModel dream) async {
    final db = await _dbHelper.database;
    final result = await db.update(
      'dreams',
      dream.toMap(),
      where: 'id = ?',
      whereArgs: [dream.id],
    );
    // Sync to cloud in background
    _syncService.syncItem(SyncEntity.dreams, dream.toMap());
    return result;
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    final result = await db.delete(
      'dreams',
      where: 'id = ?',
      whereArgs: [id],
    );
    // Delete from cloud in background
    _syncService.deleteItem(SyncEntity.dreams, id);
    return result;
  }
}
