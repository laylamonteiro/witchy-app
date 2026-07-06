import '../../../../core/database/base_repository.dart';
import '../../../../core/services/data_sync_service.dart';
import '../models/dream_model.dart';

class DreamRepository extends BaseSyncRepository<DreamModel> {
  @override
  String get tableName => 'dreams';

  @override
  SyncEntity get syncEntity => SyncEntity.dreams;

  @override
  String get defaultOrderBy => 'date DESC';

  @override
  DreamModel fromMap(Map<String, dynamic> map) => DreamModel.fromMap(map);

  @override
  Map<String, dynamic> toMap(DreamModel item) => item.toMap();

  @override
  String idOf(DreamModel item) => item.id;

  Future<List<DreamModel>> getByTag(String tag) {
    return queryWhere('tags LIKE ?', ['%$tag%']);
  }

  Future<List<DreamModel>> searchByContent(String query) {
    return queryWhere('title LIKE ? OR content LIKE ?', ['%$query%', '%$query%']);
  }
}
