import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/gratitude_model.dart';

class GratitudeRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<GratitudeModel>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gratitudes',
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
    return await db.insert(
      'gratitudes',
      gratitude.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(GratitudeModel gratitude) async {
    final db = await _dbHelper.database;
    return await db.update(
      'gratitudes',
      gratitude.toMap(),
      where: 'id = ?',
      whereArgs: [gratitude.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'gratitudes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
