import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../database/database_helper.dart';

/// Tipos de entidades sincronizáveis
enum SyncEntity {
  spells,
  dreams,
  desires,
  gratitudes,
  affirmations,
  dailyRituals,
  ritualLogs,
  sigils,
  birthCharts,
  magicalProfiles,
  runeReadings,
  pendulumConsultations,
  oracleReadings,
}

/// Status de sincronização
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  conflict,
}

/// Estratégia de resolução de conflitos
enum ConflictResolution {
  /// Servidor sempre vence (padrão)
  serverWins,

  /// Cliente sempre vence
  clientWins,

  /// Manter o mais recente baseado em updated_at
  mostRecent,

  /// Merge manual - mantém ambos e marca para revisão
  manual,
}

/// Representa um conflito de sincronização
class SyncConflict {
  final String id;
  final SyncEntity entity;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;
  final DateTime localUpdatedAt;
  final DateTime remoteUpdatedAt;
  final ConflictResolution? resolution;

  SyncConflict({
    required this.id,
    required this.entity,
    required this.localData,
    required this.remoteData,
    required this.localUpdatedAt,
    required this.remoteUpdatedAt,
    this.resolution,
  });

  /// Retorna qual versão é mais recente
  bool get isLocalMoreRecent => localUpdatedAt.isAfter(remoteUpdatedAt);

  /// Retorna os campos que diferem entre local e remoto
  Map<String, List<dynamic>> get differences {
    final diffs = <String, List<dynamic>>{};

    final allKeys = {...localData.keys, ...remoteData.keys};
    for (final key in allKeys) {
      if (key == 'synced' || key == 'updated_at') continue;

      final localValue = localData[key];
      final remoteValue = remoteData[key];

      if (localValue != remoteValue) {
        diffs[key] = [localValue, remoteValue];
      }
    }

    return diffs;
  }
}

/// Resultado de sincronização
class SyncResult {
  final bool success;
  final int uploaded;
  final int downloaded;
  final int conflictsResolved;
  final List<SyncConflict> unresolvedConflicts;
  final String? error;

  SyncResult({
    required this.success,
    this.uploaded = 0,
    this.downloaded = 0,
    this.conflictsResolved = 0,
    this.unresolvedConflicts = const [],
    this.error,
  });

  factory SyncResult.success({
    int uploaded = 0,
    int downloaded = 0,
    int conflictsResolved = 0,
  }) {
    return SyncResult(
      success: true,
      uploaded: uploaded,
      downloaded: downloaded,
      conflictsResolved: conflictsResolved,
    );
  }

  factory SyncResult.error(String message) {
    return SyncResult(success: false, error: message);
  }

  factory SyncResult.withConflicts(List<SyncConflict> conflicts) {
    return SyncResult(
      success: false,
      unresolvedConflicts: conflicts,
      error: '${conflicts.length} conflito(s) requer(em) resolução manual',
    );
  }
}

/// Serviço de sincronização de dados entre SQLite local e Supabase
/// Com tratamento avançado de conflitos
class DataSyncService {
  static final DataSyncService _instance = DataSyncService._internal();
  factory DataSyncService() => _instance;
  DataSyncService._internal();

  SupabaseClient? _supabase;
  final _db = DatabaseHelper.instance;

  SyncStatus _status = SyncStatus.idle;
  final _statusController = StreamController<SyncStatus>.broadcast();
  final _conflictsController = StreamController<List<SyncConflict>>.broadcast();

  /// Estratégia padrão de resolução de conflitos
  ConflictResolution _defaultResolution = ConflictResolution.mostRecent;

  /// Lista de conflitos pendentes
  final List<SyncConflict> _pendingConflicts = [];

  Stream<SyncStatus> get statusStream => _statusController.stream;
  Stream<List<SyncConflict>> get conflictsStream => _conflictsController.stream;
  SyncStatus get status => _status;
  List<SyncConflict> get pendingConflicts => List.unmodifiable(_pendingConflicts);

  /// Define a estratégia padrão de resolução
  set defaultResolution(ConflictResolution resolution) {
    _defaultResolution = resolution;
  }

  /// Inicializa o serviço
  void initialize() {
    if (SupabaseConfig.isConfigured) {
      _supabase = Supabase.instance.client;
    }
  }

  /// Verifica se está pronto para sincronizar
  bool get isReady => _supabase != null && _supabase!.auth.currentUser != null;

  /// ID do usuário atual
  String? get currentUserId => _supabase?.auth.currentUser?.id;

  /// Sincroniza todos os dados com tratamento de conflitos
  Future<SyncResult> syncAll({
    ConflictResolution? resolution,
  }) async {
    if (!isReady) {
      return SyncResult.error('Usuário não autenticado');
    }

    final useResolution = resolution ?? _defaultResolution;
    _setStatus(SyncStatus.syncing);
    _pendingConflicts.clear();

    try {
      int totalUploaded = 0;
      int totalDownloaded = 0;
      int totalConflictsResolved = 0;

      for (final entity in SyncEntity.values) {
        final result = await _syncEntity(entity, useResolution);
        if (result.success) {
          totalUploaded += result.uploaded;
          totalDownloaded += result.downloaded;
          totalConflictsResolved += result.conflictsResolved;
        }
        _pendingConflicts.addAll(result.unresolvedConflicts);
      }

      if (_pendingConflicts.isNotEmpty) {
        _setStatus(SyncStatus.conflict);
        _conflictsController.add(_pendingConflicts);
        return SyncResult.withConflicts(_pendingConflicts);
      }

      _setStatus(SyncStatus.success);
      return SyncResult.success(
        uploaded: totalUploaded,
        downloaded: totalDownloaded,
        conflictsResolved: totalConflictsResolved,
      );
    } catch (e) {
      _setStatus(SyncStatus.error);
      return SyncResult.error('Erro na sincronização: $e');
    }
  }

  /// Sincroniza uma entidade específica com detecção de conflitos
  Future<SyncResult> _syncEntity(
    SyncEntity entity,
    ConflictResolution resolution,
  ) async {
    try {
      final tableName = _getTableName(entity);
      final localTable = _getLocalTableName(entity);

      int uploaded = 0;
      int downloaded = 0;
      int conflictsResolved = 0;
      final conflicts = <SyncConflict>[];

      // 1. Buscar dados locais modificados
      final localData = await _getModifiedLocalData(localTable);

      // 2. Buscar dados remotos
      final remoteData = await _getRemoteData(tableName);
      final remoteMap = {for (var item in remoteData) item['id']: item};

      // 3. Processar dados locais
      for (final local in localData) {
        final id = local['id'];
        final remote = remoteMap[id];

        if (remote == null) {
          // Não existe no servidor - upload direto
          await _uploadItem(tableName, local);
          await _markAsSynced(localTable, id);
          uploaded++;
        } else {
          // Existe em ambos - verificar conflito
          final localUpdatedAt = _parseDateTime(local['updated_at']);
          final remoteUpdatedAt = _parseDateTime(remote['updated_at']);

          if (_hasChanges(local, remote)) {
            // Há diferenças - resolver conflito
            final conflict = SyncConflict(
              id: id.toString(),
              entity: entity,
              localData: local,
              remoteData: remote,
              localUpdatedAt: localUpdatedAt,
              remoteUpdatedAt: remoteUpdatedAt,
            );

            final resolved = await _resolveConflict(
              conflict,
              resolution,
              tableName,
              localTable,
            );

            if (resolved) {
              conflictsResolved++;
            } else {
              conflicts.add(conflict);
            }
          } else {
            // Sem diferenças - apenas marcar como sincronizado
            await _markAsSynced(localTable, id);
          }
        }
      }

      // 4. Baixar dados que só existem no servidor
      final localIds = localData.map((e) => e['id']).toSet();
      for (final remote in remoteData) {
        if (!localIds.contains(remote['id'])) {
          final exists = await _existsLocally(localTable, remote['id']);
          if (!exists) {
            await _insertLocally(localTable, remote);
            downloaded++;
          }
        }
      }

      if (conflicts.isNotEmpty) {
        return SyncResult(
          success: false,
          uploaded: uploaded,
          downloaded: downloaded,
          conflictsResolved: conflictsResolved,
          unresolvedConflicts: conflicts,
        );
      }

      return SyncResult.success(
        uploaded: uploaded,
        downloaded: downloaded,
        conflictsResolved: conflictsResolved,
      );
    } catch (e) {
      debugPrint('Erro ao sincronizar ${entity.name}: $e');
      return SyncResult.error(e.toString());
    }
  }

  /// Verifica se há diferenças entre local e remoto
  bool _hasChanges(Map<String, dynamic> local, Map<String, dynamic> remote) {
    final ignoreKeys = {'synced', 'updated_at', 'created_at'};

    for (final key in local.keys) {
      if (ignoreKeys.contains(key)) continue;
      if (local[key] != remote[key]) return true;
    }

    return false;
  }

  /// Resolve um conflito baseado na estratégia
  Future<bool> _resolveConflict(
    SyncConflict conflict,
    ConflictResolution resolution,
    String tableName,
    String localTable,
  ) async {
    switch (resolution) {
      case ConflictResolution.serverWins:
        // Sobrescrever local com remoto
        await _updateLocally(localTable, conflict.remoteData);
        return true;

      case ConflictResolution.clientWins:
        // Enviar local para servidor
        await _uploadItem(tableName, conflict.localData);
        await _markAsSynced(localTable, conflict.id);
        return true;

      case ConflictResolution.mostRecent:
        if (conflict.isLocalMoreRecent) {
          // Local é mais recente - upload
          await _uploadItem(tableName, conflict.localData);
          await _markAsSynced(localTable, conflict.id);
        } else {
          // Remoto é mais recente - download
          await _updateLocally(localTable, conflict.remoteData);
        }
        return true;

      case ConflictResolution.manual:
        // Não resolve automaticamente
        return false;
    }
  }

  /// Resolve um conflito manualmente
  Future<void> resolveConflictManually(
    SyncConflict conflict,
    ConflictResolution resolution,
  ) async {
    if (resolution == ConflictResolution.manual) {
      throw ArgumentError('Escolha uma resolução válida');
    }

    final tableName = _getTableName(conflict.entity);
    final localTable = _getLocalTableName(conflict.entity);

    await _resolveConflict(conflict, resolution, tableName, localTable);

    _pendingConflicts.removeWhere((c) => c.id == conflict.id);
    _conflictsController.add(_pendingConflicts);

    if (_pendingConflicts.isEmpty) {
      _setStatus(SyncStatus.success);
    }
  }

  /// Resolve todos os conflitos pendentes com uma estratégia
  Future<void> resolveAllConflicts(ConflictResolution resolution) async {
    if (resolution == ConflictResolution.manual) {
      throw ArgumentError('Escolha uma resolução válida');
    }

    for (final conflict in List.from(_pendingConflicts)) {
      await resolveConflictManually(conflict, resolution);
    }
  }

  /// Parse de DateTime robusto
  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  /// Obtém o nome da tabela no Supabase
  String _getTableName(SyncEntity entity) {
    switch (entity) {
      case SyncEntity.spells:
        return SupabaseTables.spells;
      case SyncEntity.dreams:
        return SupabaseTables.dreams;
      case SyncEntity.desires:
        return SupabaseTables.desires;
      case SyncEntity.gratitudes:
        return SupabaseTables.gratitudes;
      case SyncEntity.affirmations:
        return SupabaseTables.affirmations;
      case SyncEntity.dailyRituals:
        return SupabaseTables.dailyRituals;
      case SyncEntity.ritualLogs:
        return SupabaseTables.ritualLogs;
      case SyncEntity.sigils:
        return SupabaseTables.sigils;
      case SyncEntity.birthCharts:
        return SupabaseTables.birthCharts;
      case SyncEntity.magicalProfiles:
        return SupabaseTables.magicalProfiles;
      case SyncEntity.runeReadings:
        return SupabaseTables.runeReadings;
      case SyncEntity.pendulumConsultations:
        return SupabaseTables.pendulumConsultations;
      case SyncEntity.oracleReadings:
        return SupabaseTables.oracleReadings;
    }
  }

  /// Obtém o nome da tabela local
  String _getLocalTableName(SyncEntity entity) {
    switch (entity) {
      case SyncEntity.spells:
        return 'spells';
      case SyncEntity.dreams:
        return 'dreams';
      case SyncEntity.desires:
        return 'desires';
      case SyncEntity.gratitudes:
        return 'gratitudes';
      case SyncEntity.affirmations:
        return 'affirmations';
      case SyncEntity.dailyRituals:
        return 'daily_rituals';
      case SyncEntity.ritualLogs:
        return 'ritual_logs';
      case SyncEntity.sigils:
        return 'sigils';
      case SyncEntity.birthCharts:
        return 'birth_charts';
      case SyncEntity.magicalProfiles:
        return 'magical_profiles';
      case SyncEntity.runeReadings:
        return 'rune_readings';
      case SyncEntity.pendulumConsultations:
        return 'pendulum_consultations';
      case SyncEntity.oracleReadings:
        return 'oracle_readings';
    }
  }

  /// Busca dados locais modificados (não sincronizados ou atualizados)
  Future<List<Map<String, dynamic>>> _getModifiedLocalData(String table) async {
    final db = await _db.database;

    try {
      return await db.query(
        table,
        where: '(synced = ? OR synced IS NULL) AND user_id = ?',
        whereArgs: [0, currentUserId],
      );
    } catch (e) {
      return await db.query(
        table,
        where: 'user_id = ?',
        whereArgs: [currentUserId],
      );
    }
  }

  /// Envia item para o Supabase
  Future<void> _uploadItem(String table, Map<String, dynamic> item) async {
    final data = Map<String, dynamic>.from(item);
    data.remove('synced');
    data['user_id'] = currentUserId;
    data['updated_at'] = DateTime.now().toIso8601String();

    await _supabase!.from(table).upsert(data);
  }

  /// Marca item como sincronizado localmente
  Future<void> _markAsSynced(String table, dynamic id) async {
    final db = await _db.database;

    try {
      await db.update(
        table,
        {'synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      // Ignorar se não existir coluna synced
    }
  }

  /// Atualiza item localmente
  Future<void> _updateLocally(String table, Map<String, dynamic> item) async {
    final db = await _db.database;
    final data = Map<String, dynamic>.from(item);
    data['synced'] = 1;

    await db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [item['id']],
    );
  }

  /// Busca dados do Supabase
  Future<List<Map<String, dynamic>>> _getRemoteData(String table) async {
    final response = await _supabase!
        .from(table)
        .select()
        .eq('user_id', currentUserId!);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Verifica se item existe localmente
  Future<bool> _existsLocally(String table, dynamic id) async {
    final db = await _db.database;
    final result = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  /// Insere item localmente
  Future<void> _insertLocally(String table, Map<String, dynamic> item) async {
    final db = await _db.database;
    final data = Map<String, dynamic>.from(item);
    data['synced'] = 1;

    await db.insert(table, data);
  }

  /// Atualiza o status
  void _setStatus(SyncStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  /// Sincroniza um item específico após criação/atualização
  Future<void> syncItem(SyncEntity entity, Map<String, dynamic> item) async {
    if (!isReady) return;

    try {
      final tableName = _getTableName(entity);
      await _uploadItem(tableName, item);
    } catch (e) {
      debugPrint('Erro ao sincronizar item: $e');
    }
  }

  /// Deleta um item do Supabase
  Future<void> deleteItem(SyncEntity entity, dynamic id) async {
    if (!isReady) return;

    try {
      final tableName = _getTableName(entity);
      await _supabase!.from(tableName).delete().eq('id', id);
    } catch (e) {
      debugPrint('Erro ao deletar item do Supabase: $e');
    }
  }

  /// Limpa dados locais e baixa tudo do servidor
  Future<SyncResult> fullDownload() async {
    if (!isReady) {
      return SyncResult.error('Usuário não autenticado');
    }

    _setStatus(SyncStatus.syncing);

    try {
      int totalDownloaded = 0;

      for (final entity in SyncEntity.values) {
        final tableName = _getTableName(entity);
        final localTable = _getLocalTableName(entity);

        final db = await _db.database;
        await db.delete(
          localTable,
          where: 'user_id = ?',
          whereArgs: [currentUserId],
        );

        final remoteData = await _getRemoteData(tableName);
        for (final item in remoteData) {
          await _insertLocally(localTable, item);
          totalDownloaded++;
        }
      }

      _setStatus(SyncStatus.success);
      return SyncResult.success(downloaded: totalDownloaded);
    } catch (e) {
      _setStatus(SyncStatus.error);
      return SyncResult.error('Erro no download: $e');
    }
  }

  /// Envia todos os dados locais para o servidor
  Future<SyncResult> fullUpload() async {
    if (!isReady) {
      return SyncResult.error('Usuário não autenticado');
    }

    _setStatus(SyncStatus.syncing);

    try {
      int totalUploaded = 0;

      for (final entity in SyncEntity.values) {
        final tableName = _getTableName(entity);
        final localTable = _getLocalTableName(entity);

        final db = await _db.database;
        final localData = await db.query(
          localTable,
          where: 'user_id = ?',
          whereArgs: [currentUserId],
        );

        for (final item in localData) {
          await _uploadItem(tableName, item);
          await _markAsSynced(localTable, item['id']);
          totalUploaded++;
        }
      }

      _setStatus(SyncStatus.success);
      return SyncResult.success(uploaded: totalUploaded);
    } catch (e) {
      _setStatus(SyncStatus.error);
      return SyncResult.error('Erro no upload: $e');
    }
  }

  void dispose() {
    _statusController.close();
    _conflictsController.close();
  }
}
