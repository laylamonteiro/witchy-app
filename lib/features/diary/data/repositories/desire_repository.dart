import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/desire_model.dart';

class DesireRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<DesireModel>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'desires',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => DesireModel.fromMap(maps[i]));
  }

  Future<DesireModel?> getById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'desires',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return DesireModel.fromMap(maps.first);
  }

  Future<List<DesireModel>> getByStatus(DesireStatus status) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'desires',
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => DesireModel.fromMap(maps[i]));
  }

  Future<int> insert(DesireModel desire) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'desires',
      desire.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(DesireModel desire) async {
    final db = await _dbHelper.database;
    return await db.update(
      'desires',
      desire.toMap(),
      where: 'id = ?',
      whereArgs: [desire.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'desires',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
