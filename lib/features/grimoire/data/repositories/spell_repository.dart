import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';
import '../models/spell_model.dart';

class SpellRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final DataSyncService _syncService = DataSyncService();

  /// Retorna todos os feitiços (sem filtro de usuário) - usado apenas para admin/debug
  Future<List<SpellModel>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'spells',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => SpellModel.fromMap(maps[i]));
  }

  /// Retorna feitiços do usuário + pré-carregados (excluindo feitiços de outros usuários)
  Future<List<SpellModel>> getForUser(String userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'spells',
      where: 'user_id = ? OR is_preloaded = 1',
      whereArgs: [userId],
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
    final result = await db.insert(
      'spells',
      spell.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _syncService.syncItem(SyncEntity.spells, spell.toMap());
    return result;
  }

  Future<int> update(SpellModel spell) async {
    final existingSpell = await getById(spell.id);
    if (existingSpell?.isPreloaded ?? false) {
      return 0;
    }

    final db = await _dbHelper.database;
    final result = await db.update(
      'spells',
      spell.toMap(),
      where: 'id = ?',
      whereArgs: [spell.id],
    );
    _syncService.syncItem(SyncEntity.spells, spell.toMap());
    return result;
  }

  Future<int> delete(String id) async {
    final existingSpell = await getById(id);
    if (existingSpell?.isPreloaded ?? false) {
      return 0;
    }

    final db = await _dbHelper.database;
    final result = await db.delete(
      'spells',
      where: 'id = ?',
      whereArgs: [id],
    );
    _syncService.deleteItem(SyncEntity.spells, id);
    return result;
  }

  Future<int> count() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM spells');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
