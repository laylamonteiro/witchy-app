import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';
import '../data_sources/spells_data.dart';
import '../models/spell_model.dart';

abstract class SpellLocalStore {
  Future<void> ensurePreloadedSpells();
  Future<List<SpellModel>> getAll();
  Future<List<SpellModel>> getForUser(String userId);
  Future<SpellModel?> getById(String id);
  Future<List<SpellModel>> getByPurpose(String purpose);
  Future<List<SpellModel>> getByType(SpellType type);
  Future<int> insert(SpellModel spell);
  Future<int> update(SpellModel spell);
  Future<int> delete(String id);
  Future<int> count();
}

class SqfliteSpellLocalStore implements SpellLocalStore {
  SqfliteSpellLocalStore({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _dbHelper;

  @override
  Future<List<SpellModel>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'spells',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => SpellModel.fromMap(maps[i]));
  }


  /// Garante que os feitiços ancestrais do app existam no banco.
  ///
  /// A verificação consulta apenas registros pré-carregados para manter o seed
  /// idempotente e evitar depender de dados criados pelo usuário.
  @override
  Future<void> ensurePreloadedSpells() async {
    final db = await _dbHelper.database;
    final existingPreloadedRows = await db.query(
      'spells',
      columns: ['id'],
      where: 'is_preloaded = ?',
      whereArgs: [1],
    );
    final existingPreloadedIds = existingPreloadedRows
        .map((row) => row['id'] as String)
        .toSet();

    final batch = db.batch();
    var hasMissingSeed = false;

    for (final spell in preloadedSpells) {
      if (!existingPreloadedIds.contains(spell.id)) {
        hasMissingSeed = true;
        batch.insert(
          'spells',
          spell.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    if (hasMissingSeed) {
      await batch.commit(noResult: true);
    }
  }

  /// Retorna feitiços do usuário + pré-carregados (excluindo feitiços de outros usuários)
  @override
  Future<List<SpellModel>> getForUser(String userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'spells',
      where: 'user_id = ? OR is_preloaded = 1',
      whereArgs: [userId],
      orderBy: 'is_preloaded ASC, created_at DESC, name COLLATE NOCASE ASC, id ASC',
    );
    return List.generate(maps.length, (i) => SpellModel.fromMap(maps[i]));
  }

  @override
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

  @override
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

  @override
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

  @override
  Future<int> insert(SpellModel spell) async {
    final db = await _dbHelper.database;
    return db.insert(
      'spells',
      spell.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<int> update(SpellModel spell) async {
    final db = await _dbHelper.database;
    return db.update(
      'spells',
      spell.toMap(),
      where: 'id = ?',
      whereArgs: [spell.id],
    );
  }

  @override
  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return db.delete(
      'spells',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> count() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM spells');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

abstract class SpellSyncGateway {
  Future<void> sync(SpellModel spell);
  Future<void> delete(String id);
}

class DataSyncSpellGateway implements SpellSyncGateway {
  DataSyncSpellGateway({DataSyncService? syncService})
      : _syncService = syncService ?? DataSyncService();

  final DataSyncService _syncService;

  @override
  Future<void> sync(SpellModel spell) =>
      _syncService.syncItem(SyncEntity.spells, spell.toMap());

  @override
  Future<void> delete(String id) =>
      _syncService.deleteItem(SyncEntity.spells, id);
}

class SpellRepository {
  SpellRepository({SpellLocalStore? localStore, SpellSyncGateway? syncGateway})
      : _localStore = localStore ?? SqfliteSpellLocalStore(),
        _syncGateway = syncGateway ?? DataSyncSpellGateway();

  final SpellLocalStore _localStore;
  final SpellSyncGateway _syncGateway;

  /// Garante que os feitiços ancestrais do app existam no banco (seed idempotente).
  Future<void> ensurePreloadedSpells() => _localStore.ensurePreloadedSpells();

  /// Retorna todos os feitiços (sem filtro de usuário) - usado apenas para admin/debug
  Future<List<SpellModel>> getAll() => _localStore.getAll();

  /// Retorna feitiços do usuário + pré-carregados (excluindo feitiços de outros usuários)
  Future<List<SpellModel>> getForUser(String userId) =>
      _localStore.getForUser(userId);

  Future<SpellModel?> getById(String id) => _localStore.getById(id);

  Future<List<SpellModel>> getByPurpose(String purpose) =>
      _localStore.getByPurpose(purpose);

  Future<List<SpellModel>> getByType(SpellType type) =>
      _localStore.getByType(type);

  Future<int> insert(SpellModel spell) async {
    final result = await _localStore.insert(spell);
    if (!spell.isPreloaded) {
      await _syncGateway.sync(spell);
    }
    return result;
  }

  Future<int> update(SpellModel spell) async {
    final result = await _localStore.update(spell);
    if (!spell.isPreloaded) {
      await _syncGateway.sync(spell);
    }
    return result;
  }

  Future<int> delete(String id) async {
    final spell = await _localStore.getById(id);
    final result = await _localStore.delete(id);
    if (spell != null && !spell.isPreloaded) {
      await _syncGateway.delete(id);
    }
    return result;
  }

  Future<int> count() => _localStore.count();
}
