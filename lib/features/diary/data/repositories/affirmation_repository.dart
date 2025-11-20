import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/affirmation_model.dart';

class AffirmationRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<AffirmationModel>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'affirmations',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => AffirmationModel.fromMap(maps[i]));
  }

  Future<List<AffirmationModel>> getByCategory(AffirmationCategory category) async {
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
    return await db.insert(
      'affirmations',
      affirmation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
    return await db.update(
      'affirmations',
      affirmation.toMap(),
      where: 'id = ?',
      whereArgs: [affirmation.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'affirmations',
      where: 'id = ? AND is_preloaded = ?',
      whereArgs: [id, 0], // Só permite deletar afirmações não-pré-carregadas
    );
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
