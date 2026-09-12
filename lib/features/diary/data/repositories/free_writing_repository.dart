import 'dart:async';

import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';
import '../models/free_writing_model.dart';

class FreeWritingRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final DataSyncService _syncService = DataSyncService();

  Future<List<FreeWritingModel>> getAll(String userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'free_writings',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );
    return List.generate(maps.length, (i) => FreeWritingModel.fromMap(maps[i]));
  }

  Future<FreeWritingModel?> getById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'free_writings',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return FreeWritingModel.fromMap(maps.first);
  }

  /// Insere ou substitui (upsert) — reutilizado pelo autosave para manter o
  /// mesmo id ao longo da edição de uma reflexão.
  Future<int> insert(FreeWritingModel writing) async {
    final db = await _dbHelper.database;
    final result = await db.insert(
      'free_writings',
      writing.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _syncService.syncItem(SyncEntity.freeWritings, writing.toMap());
    return result;
  }

  Future<int> update(FreeWritingModel writing) async {
    final db = await _dbHelper.database;
    final result = await db.update(
      'free_writings',
      writing.toMap(),
      where: 'id = ?',
      whereArgs: [writing.id],
    );
    _syncService.syncItem(SyncEntity.freeWritings, writing.toMap());
    return result;
  }

  /// Apaga a reflexão. Este é o caminho por onde o "apagar o registro
  /// menstrual" da tela de Privacidade derruba os relatórios derivados, em
  /// laço — por isso o aviso à nuvem é condicionado a ter havido exclusão de
  /// verdade: sem linha apagada não há cópia remota para purgar, e mandar o
  /// id assim mesmo era falar do que já não existe aqui.
  ///
  /// Continua sem `await` de propósito: `deleteItem` engole os próprios
  /// erros e faz uma ida à rede, e a tela não deve esperar por ela para
  /// mostrar que a reflexão saiu. O `unawaited` diz isso em voz alta.
  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    final result = await db.delete(
      'free_writings',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result > 0) {
      unawaited(_syncService.deleteItem(SyncEntity.freeWritings, id));
    }
    return result;
  }
}
