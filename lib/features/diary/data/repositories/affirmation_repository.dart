import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';
import '../models/affirmation_model.dart';

class AffirmationRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final DataSyncService _syncService = DataSyncService();

  Future<List<AffirmationModel>> getAll(String userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'affirmations',
      where: 'user_id = ? OR is_preloaded = 1',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => AffirmationModel.fromMap(maps[i]));
  }

  Future<List<AffirmationModel>> getByCategory(
      AffirmationCategory category) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'affirmations',
      where: 'category = ?',
      whereArgs: [category.name],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => AffirmationModel.fromMap(maps[i]));
  }

  Future<List<AffirmationModel>> getFavorites() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'affirmations',
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => AffirmationModel.fromMap(maps[i]));
  }

  Future<int> insert(AffirmationModel affirmation) async {
    final db = await _dbHelper.database;
    final result = await db.insert(
      'affirmations',
      affirmation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (!affirmation.isPreloaded) {
      _syncService.syncItem(SyncEntity.affirmations, affirmation.toMap());
    }
    return result;
  }

  Future<void> insertAll(List<AffirmationModel> affirmations) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (var affirmation in affirmations) {
      batch.insert(
        'affirmations',
        affirmation.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<int> update(AffirmationModel affirmation) async {
    final db = await _dbHelper.database;
    final result = await db.update(
      'affirmations',
      affirmation.toMap(),
      where: 'id = ?',
      whereArgs: [affirmation.id],
    );
    if (!affirmation.isPreloaded) {
      _syncService.syncItem(SyncEntity.affirmations, affirmation.toMap());
    }
    return result;
  }

  /// Apaga as afirmações pré-carregadas para dar lugar a uma semeadura
  /// nova, PRESERVANDO as que a pessoa favoritou — se ela guardou aquela
  /// frase, a frase é dela agora.
  Future<int> deletePreloadedExceptFavorites() async {
    final db = await _dbHelper.database;
    return db.delete(
      'affirmations',
      where: 'is_preloaded = ? AND is_favorite = ?',
      whereArgs: [1, 0],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    final result = await db.delete(
      'affirmations',
      where: 'id = ? AND is_preloaded = ?',
      whereArgs: [id, 0], // Só permite deletar afirmações não-pré-carregadas
    );
    _syncService.deleteItem(SyncEntity.affirmations, id);
    return result;
  }

  Future<bool> hasPreloadedData() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'affirmations',
      where: 'is_preloaded = ?',
      whereArgs: [1],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
