import '../../../../core/database/base_repository.dart';
import '../../../../core/services/data_sync_service.dart';
import '../models/gratitude_model.dart';

class GratitudeRepository extends BaseSyncRepository<GratitudeModel> {
  @override
  String get tableName => 'gratitudes';

  @override
  SyncEntity get syncEntity => SyncEntity.gratitudes;

  @override
  String get defaultOrderBy => 'date DESC';

  @override
  GratitudeModel fromMap(Map<String, dynamic> map) => GratitudeModel.fromMap(map);

  @override
  Map<String, dynamic> toMap(GratitudeModel item) => item.toMap();

  @override
  String idOf(GratitudeModel item) => item.id;
}
