import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';
import '../models/gratitude_model.dart';

class GratitudeRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final DataSyncService _syncService = DataSyncService();

  Future<List<GratitudeModel>> getAll(String userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gratitudes',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => GratitudeModel.fromMap(maps[i]));
  }

  Future<GratitudeModel?> getById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gratitudes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return GratitudeModel.fromMap(maps.first);
  }

  Future<int> insert(GratitudeModel gratitude) async {
    final db = await _dbHelper.database;
    final result = await db.insert(
      'gratitudes',
      gratitude.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _syncService.syncItem(SyncEntity.gratitudes, gratitude.toMap());
    return result;
  }

  Future<int> update(GratitudeModel gratitude) async {
    final db = await _dbHelper.database;
    final result = await db.update(
      'gratitudes',
      gratitude.toMap(),
      where: 'id = ?',
      whereArgs: [gratitude.id],
    );
    _syncService.syncItem(SyncEntity.gratitudes, gratitude.toMap());
    return result;
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    final result = await db.delete(
      'gratitudes',
      where: 'id = ?',
      whereArgs: [id],
    );
    _syncService.deleteItem(SyncEntity.gratitudes, id);
    return result;
  }
}
