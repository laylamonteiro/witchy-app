import 'package:sqflite/sqflite.dart';
import '../../../../core/database/base_repository.dart';
import '../../../../core/services/data_sync_service.dart';
import '../models/spell_model.dart';

class SpellRepository extends BaseSyncRepository<SpellModel> {
  @override
  String get tableName => 'spells';

  @override
  SyncEntity get syncEntity => SyncEntity.spells;

  @override
  SpellModel fromMap(Map<String, dynamic> map) => SpellModel.fromMap(map);

  @override
  Map<String, dynamic> toMap(SpellModel item) => item.toMap();

  @override
  String idOf(SpellModel item) => item.id;

  /// Retorna feitiços do usuário + pré-carregados (excluindo feitiços de outros usuários)
  Future<List<SpellModel>> getForUser(String userId) {
    return queryWhere('user_id = ? OR is_preloaded = 1', [userId]);
  }

  Future<List<SpellModel>> getByPurpose(String purpose) {
    return queryWhere('purpose LIKE ?', ['%$purpose%']);
  }

  Future<List<SpellModel>> getByType(SpellType type) {
    return queryWhere('type = ?', [type.name]);
  }

  Future<int> count() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM spells');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
