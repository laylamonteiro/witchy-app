import '../../../../core/database/base_repository.dart';
import '../../../../core/services/data_sync_service.dart';
import '../models/desire_model.dart';

class DesireRepository extends BaseSyncRepository<DesireModel> {
  @override
  String get tableName => 'desires';

  @override
  SyncEntity get syncEntity => SyncEntity.desires;

  @override
  DesireModel fromMap(Map<String, dynamic> map) => DesireModel.fromMap(map);

  @override
  Map<String, dynamic> toMap(DesireModel item) => item.toMap();

  @override
  String idOf(DesireModel item) => item.id;

  Future<List<DesireModel>> getByStatus(DesireStatus status) {
    return queryWhere('status = ?', [status.name]);
  }
}
