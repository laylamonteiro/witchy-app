import 'package:sqflite/sqflite.dart';
import '../../../../core/database/base_repository.dart';
import '../../../../core/services/data_sync_service.dart';
import '../models/affirmation_model.dart';

class AffirmationRepository extends BaseSyncRepository<AffirmationModel> {
  @override
  String get tableName => 'affirmations';

  @override
  SyncEntity get syncEntity => SyncEntity.affirmations;

  @override
  AffirmationModel fromMap(Map<String, dynamic> map) => AffirmationModel.fromMap(map);

  @override
  Map<String, dynamic> toMap(AffirmationModel item) => item.toMap();

  @override
  String idOf(AffirmationModel item) => item.id;

  @override
  bool shouldSync(AffirmationModel item) => !item.isPreloaded;

  Future<List<AffirmationModel>> getByCategory(AffirmationCategory category) {
    return queryWhere('category = ?', [category.name]);
  }

  Future<List<AffirmationModel>> getFavorites() {
    return queryWhere('is_favorite = ?', [1]);
  }

  Future<void> insertAll(List<AffirmationModel> affirmations) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (var affirmation in affirmations) {
      batch.insert(
        tableName,
        affirmation.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<int> delete(String id) async {
    final db = await dbHelper.database;
    final result = await db.delete(
      tableName,
      where: 'id = ? AND is_preloaded = ?',
      whereArgs: [id, 0], // Só permite deletar afirmações não-pré-carregadas
    );
    syncService.deleteItem(syncEntity, id);
    return result;
  }

  Future<bool> hasPreloadedData() async {
    final db = await dbHelper.database;
    final result = await db.query(
      tableName,
      where: 'is_preloaded = ?',
      whereArgs: [1],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
