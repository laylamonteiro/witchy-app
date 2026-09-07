import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';
import '../../../../core/services/debug_log_service.dart';
import '../models/user_entry_model.dart';
import '../services/user_photo_store.dart';

/// Entradas pessoais da enciclopédia: banco local + sincronização em nuvem.
///
/// A FOTO também viaja: com conta e sincronização ligada ela vai para o
/// Storage e `image_path` guarda a referência `supabase://…` (ver
/// [UserPhotoStore]). Sem isso fica um caminho local do aparelho, que
/// [uploadPendingPhotos] sobe assim que der — o mesmo caminho que migra as
/// fotos antigas do celular, de antes de a foto sincronizar.
class UserEncyclopediaRepository {
  UserEncyclopediaRepository({
    UserPhotoStore? photos,
    DataSyncService? syncService,
  })  : _photos = photos ?? UserPhotoStore(),
        _syncService = syncService ?? DataSyncService();

  static const String _tabela = 'user_encyclopedia_entries';

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final DataSyncService _syncService;
  final UserPhotoStore _photos;

  Future<List<UserEncyclopediaEntry>> entriesFor(
    String userId,
    UserEntryCategory category,
  ) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      _tabela,
      where: 'user_id = ? AND category = ?',
      whereArgs: [userId, category.key],
      orderBy: 'created_at DESC',
    );
    return rows
        .map(UserEncyclopediaEntry.fromMap)
        .whereType<UserEncyclopediaEntry>()
        .toList();
  }

  /// Cria a entrada, guardando a [photo] comprimida (se houver) onde couber
  /// — ver [UserPhotoStore.guardar]. O [id] nasce ANTES da foto: é ele que
  /// dá nome ao arquivo no bucket.
  Future<UserEncyclopediaEntry> create({
    required String userId,
    required UserEntryCategory category,
    required String name,
    Uint8List? photo,
    required Map<String, dynamic> data,
    String? id,
  }) async {
    final entryId = id ?? const Uuid().v4();
    final imagePath = photo == null
        ? null
        : await _photos.guardar(
            userId: userId,
            category: category,
            entryId: entryId,
            jpeg: photo,
          );

    final db = await _dbHelper.database;
    final now = DateTime.now();
    final entry = UserEncyclopediaEntry(
      id: entryId,
      userId: userId,
      category: category,
      name: name,
      imagePath: imagePath,
      data: data,
      createdAt: now,
      updatedAt: now,
    );
    await db.insert(
      _tabela,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _syncService.syncItem(SyncEntity.userEncyclopediaEntries, entry.toMap());
    return entry;
  }

  /// Sobe as fotos que ficaram como arquivo local (sem rede na hora, ou
  /// antigas, de quando a foto não sincronizava) e devolve quantas subiram.
  ///
  /// A linha é atualizada com `updated_at` novo e `synced = 0`, de
  /// propósito: a varredura do sync só sobe linhas com `synced = 0` e, no
  /// empate de datas, fica com o servidor — sem o carimbo novo a referência
  /// seria revertida no sync seguinte, para sempre. Melhor esforço: uma foto
  /// que falhe não impede as outras, e fica para a próxima rodada.
  Future<int> uploadPendingPhotos(String userId) async {
    if (!await _photos.podeSubir(userId)) return 0;

    final db = await _dbHelper.database;
    final rows = await db.query(
      _tabela,
      where: 'user_id = ? AND '
          "(image_path LIKE '/%' OR image_path LIKE 'file:%')",
      whereArgs: [userId],
    );

    var enviadas = 0;
    for (final row in rows) {
      final entry = UserEncyclopediaEntry.fromMap(row);
      final localPath = entry?.imagePath;
      if (entry == null || localPath == null) continue;
      try {
        final referencia = await _photos.subirArquivoLocal(
          userId: userId,
          category: entry.category,
          entryId: entry.id,
          localPath: localPath,
        );
        if (referencia == null) continue;

        final agora = DateTime.now().millisecondsSinceEpoch;
        await db.update(
          _tabela,
          {'image_path': referencia, 'updated_at': agora, 'synced': 0},
          where: 'id = ?',
          whereArgs: [entry.id],
        );
        await _syncService.syncItem(
          SyncEntity.userEncyclopediaEntries,
          {...entry.toMap(), 'image_path': referencia, 'updated_at': agora},
        );
        enviadas++;
      } catch (e) {
        await debugLog('STORAGE', 'Foto pendente de ${entry.id} não subiu: $e');
      }
    }
    return enviadas;
  }

  /// Remove a entrada e a foto associada (bucket + espelho, ou arquivo local).
  Future<void> delete(UserEncyclopediaEntry entry) async {
    final db = await _dbHelper.database;
    await db.delete(
      _tabela,
      where: 'id = ?',
      whereArgs: [entry.id],
    );
    _syncService.deleteItem(SyncEntity.userEncyclopediaEntries, entry.id);
    await _photos.apagar(entry.imagePath);
  }

  /// Contagem de entradas criadas hoje (limite diário de uso da IA).
  Future<int> countCreatedToday(String userId) async {
    final now = DateTime.now();
    final startOfDay =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM $_tabela '
      'WHERE user_id = ? AND created_at >= ?',
      [userId, startOfDay],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
