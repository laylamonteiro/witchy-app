import 'package:sqflite/sqflite.dart';
import '../services/data_sync_service.dart';
import 'database_helper.dart';

/// Base class for SQLite-backed repositories that persist a model type [T] and
/// mirror local changes to the cloud through [DataSyncService].
///
/// Subclasses only need to declare the [tableName], the [syncEntity] and the
/// serialization hooks ([fromMap], [toMap], [idOf]). The common CRUD
/// operations (`getAll`, `getById`, `insert`, `update`, `delete`) are
/// implemented once here so every feature repository shares the same behavior.
abstract class BaseSyncRepository<T> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final DataSyncService syncService = DataSyncService();

  /// Name of the SQLite table backing this repository.
  String get tableName;

  /// Cloud sync entity mirrored on write and delete.
  SyncEntity get syncEntity;

  /// Ordering applied by [getAll] and [queryWhere].
  String get defaultOrderBy => 'created_at DESC';

  /// Deserializes a database row into a model.
  T fromMap(Map<String, dynamic> map);

  /// Serializes a model into a database row.
  Map<String, dynamic> toMap(T item);

  /// Primary key of [item], used by [update] and cloud sync.
  String idOf(T item);

  /// Whether [item] should be mirrored to the cloud on insert/update.
  ///
  /// Repositories with preloaded/read-only rows can override this to skip
  /// syncing that content.
  bool shouldSync(T item) => true;

  Future<List<T>> getAll() async {
    final db = await dbHelper.database;
    final maps = await db.query(tableName, orderBy: defaultOrderBy);
    return maps.map(fromMap).toList();
  }

  Future<T?> getById(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return fromMap(maps.first);
  }

  Future<int> insert(T item) async {
    final db = await dbHelper.database;
    final result = await db.insert(
      tableName,
      toMap(item),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (shouldSync(item)) {
      syncService.syncItem(syncEntity, toMap(item));
    }
    return result;
  }

  Future<int> update(T item) async {
    final db = await dbHelper.database;
    final result = await db.update(
      tableName,
      toMap(item),
      where: 'id = ?',
      whereArgs: [idOf(item)],
    );
    if (shouldSync(item)) {
      syncService.syncItem(syncEntity, toMap(item));
    }
    return result;
  }

  Future<int> delete(String id) async {
    final db = await dbHelper.database;
    final result = await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    syncService.deleteItem(syncEntity, id);
    return result;
  }

  /// Runs a `WHERE`-filtered query ordered by [defaultOrderBy] and maps rows.
  Future<List<T>> queryWhere(String where, List<Object?> whereArgs) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: defaultOrderBy,
    );
    return maps.map(fromMap).toList();
  }
}
