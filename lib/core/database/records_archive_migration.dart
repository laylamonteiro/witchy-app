import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;
import 'package:uuid/uuid.dart';

import '../services/data_sync_service.dart';
import 'database_helper.dart';

/// Move as páginas de registro do Grimório Vivo — linhas de `spells` com id
/// `registro_<uuid>` — para o acervo `free_writings` (source='grimorio_vivo').
///
/// Esse id nunca foi um UUID válido para a coluna remota: os registros JAMAIS
/// subiram para a nuvem, então desinstalar o app os perdia. Migrados, eles
/// ficam `synced=0` e sobem no próximo sync com o uuid do sufixo preservado.
///
/// Idempotente e por item: a flag em SharedPreferences só é gravada quando
/// não resta nenhuma linha por migrar — uma falha no meio recomeça de onde
/// parou na próxima abertura (o INSERT usa ConflictAlgorithm.ignore para não
/// sobrescrever itens já migrados e possivelmente editados).
class RecordsArchiveMigration {
  RecordsArchiveMigration({
    DatabaseHelper? dbHelper,
    Future<void> Function(String spellId)? deleteRemote,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _deleteRemote = deleteRemote ?? _defaultDeleteRemote;

  static const prefsKey = 'records_archive_migration_v1_done';
  static const _uuidPattern =
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
      r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$';

  final DatabaseHelper _dbHelper;
  final Future<void> Function(String spellId) _deleteRemote;

  /// Best-effort: o id nunca foi aceito pela nuvem, então isto é defensivo.
  static Future<void> _defaultDeleteRemote(String spellId) async {
    try {
      await DataSyncService().deleteItem(SyncEntity.spells, spellId);
    } catch (e) {
      debugPrint('RecordsArchiveMigration: delete remoto falhou: $e');
    }
  }

  /// Id no acervo: preserva o uuid do sufixo (identidade estável entre
  /// execuções interrompidas); sufixo sem cara de uuid ganha id novo.
  @visibleForTesting
  static String archiveIdFor(String spellId) {
    final suffix = spellId.startsWith('registro_')
        ? spellId.substring('registro_'.length)
        : spellId;
    if (RegExp(_uuidPattern).hasMatch(suffix)) return suffix;
    return const Uuid().v4();
  }

  /// Executa a migração se ainda não concluída. Rápida (dezenas de linhas no
  /// pior caso) e silenciosa — nenhuma UI envolvida.
  Future<void> run(SharedPreferences prefs) async {
    if (prefs.getBool(prefsKey) ?? false) return;

    try {
      final db = await _dbHelper.database;
      // ESCAPE obrigatório: `_` é curinga do LIKE.
      const where = "id LIKE 'registro\\_%' ESCAPE '\\'";
      final rows = await db.query('spells', where: where);

      for (final row in rows) {
        final oldId = row['id'] as String;
        final observations = (row['observations'] as String?)?.trim() ?? '';
        final steps = (row['steps'] as String?) ?? '';
        // A nota "trilha — lição" abre a página, como no cabeçalho antigo.
        final content =
            observations.isEmpty ? steps : '$observations\n\n$steps';

        await db.insert(
          'free_writings',
          {
            'id': archiveIdFor(oldId),
            'user_id': row['user_id'] ?? 'local_user',
            'title': row['name'],
            'content': content,
            'source': 'grimorio_vivo',
            'created_at': row['created_at'],
            'updated_at': row['updated_at'] ?? row['created_at'],
            'synced': 0,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        await db.delete('spells', where: 'id = ?', whereArgs: [oldId]);
        unawaited(_deleteRemote(oldId));
      }

      final remaining = await db.query('spells', where: where, limit: 1);
      if (remaining.isEmpty) {
        await prefs.setBool(prefsKey, true);
      }
    } catch (e) {
      // Nunca impede o app de abrir: tenta de novo na próxima sessão.
      debugPrint('RecordsArchiveMigration falhou: $e');
    }
  }
}
