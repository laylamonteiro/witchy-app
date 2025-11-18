import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/spell_model.dart';

class SpellRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<SpellModel>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'spells',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => SpellModel.fromMap(maps[i]));
  }

  Future<SpellModel?> getById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'spells',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return SpellModel.fromMap(maps.first);
  }

  Future<List<SpellModel>> getByPurpose(String purpose) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'spells',
      where: 'purpose LIKE ?',
      whereArgs: ['%$purpose%'],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => SpellModel.fromMap(maps[i]));
  }

  Future<List<SpellModel>> getByType(SpellType type) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'spells',
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => SpellModel.fromMap(maps[i]));
  }

  Future<int> insert(SpellModel spell) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'spells',
      spell.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(SpellModel spell) async {
    final db = await _dbHelper.database;
    return await db.update(
      'spells',
      spell.toMap(),
      where: 'id = ?',
      whereArgs: [spell.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'spells',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> count() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM spells');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
