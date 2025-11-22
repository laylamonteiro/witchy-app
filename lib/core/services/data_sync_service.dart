import 'dart:async';
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
}

/// Resultado de sincronização
class SyncResult {
  final bool success;
  final int uploaded;
  final int downloaded;
  final String? error;

  SyncResult({
    required this.success,
    this.uploaded = 0,
    this.downloaded = 0,
    this.error,
  });

  factory SyncResult.success({int uploaded = 0, int downloaded = 0}) {
    return SyncResult(success: true, uploaded: uploaded, downloaded: downloaded);
  }

  factory SyncResult.error(String message) {
    return SyncResult(success: false, error: message);
  }
}

/// Serviço de sincronização de dados entre SQLite local e Supabase
class DataSyncService {
  static final DataSyncService _instance = DataSyncService._internal();
  factory DataSyncService() => _instance;
  DataSyncService._internal();

  SupabaseClient? _supabase;
  final _db = DatabaseHelper.instance;

  SyncStatus _status = SyncStatus.idle;
  final _statusController = StreamController<SyncStatus>.broadcast();

  Stream<SyncStatus> get statusStream => _statusController.stream;
  SyncStatus get status => _status;

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

  /// Sincroniza todos os dados
  Future<SyncResult> syncAll() async {
    if (!isReady) {
      return SyncResult.error('Usuário não autenticado');
    }

    _setStatus(SyncStatus.syncing);

    try {
      int totalUploaded = 0;
      int totalDownloaded = 0;

      // Sincronizar cada entidade
      for (final entity in SyncEntity.values) {
        final result = await _syncEntity(entity);
        if (result.success) {
          totalUploaded += result.uploaded;
          totalDownloaded += result.downloaded;
        }
      }

      _setStatus(SyncStatus.success);
      return SyncResult.success(
        uploaded: totalUploaded,
        downloaded: totalDownloaded,
      );
    } catch (e) {
      _setStatus(SyncStatus.error);
      return SyncResult.error('Erro na sincronização: $e');
    }
  }

  /// Sincroniza uma entidade específica
  Future<SyncResult> _syncEntity(SyncEntity entity) async {
    try {
      final tableName = _getTableName(entity);
      final localTable = _getLocalTableName(entity);

      // 1. Buscar dados locais não sincronizados
      final localData = await _getUnsyncedLocalData(localTable);

      // 2. Enviar dados locais para o Supabase
      int uploaded = 0;
      for (final item in localData) {
        await _uploadItem(tableName, item);
        await _markAsSynced(localTable, item['id']);
        uploaded++;
      }

      // 3. Buscar dados do Supabase
      final remoteData = await _getRemoteData(tableName);

      // 4. Baixar dados que não existem localmente
      int downloaded = 0;
      for (final item in remoteData) {
        final exists = await _existsLocally(localTable, item['id']);
        if (!exists) {
          await _insertLocally(localTable, item);
          downloaded++;
        }
      }

      return SyncResult.success(uploaded: uploaded, downloaded: downloaded);
    } catch (e) {
      print('Erro ao sincronizar ${entity.name}: $e');
      return SyncResult.error(e.toString());
    }
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

  /// Busca dados locais não sincronizados
  Future<List<Map<String, dynamic>>> _getUnsyncedLocalData(String table) async {
    final db = await _db.database;

    // Verificar se a coluna synced existe
    try {
      return await db.query(
        table,
        where: 'synced = ? AND user_id = ?',
        whereArgs: [0, currentUserId],
      );
    } catch (e) {
      // Se não existir coluna synced, retornar todos os dados do usuário
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

    // Remover campos locais
    data.remove('synced');

    // Garantir user_id
    data['user_id'] = currentUserId;

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
    data['synced'] = 1; // Marcar como sincronizado

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
      print('Erro ao sincronizar item: $e');
    }
  }

  /// Deleta um item do Supabase
  Future<void> deleteItem(SyncEntity entity, dynamic id) async {
    if (!isReady) return;

    try {
      final tableName = _getTableName(entity);
      await _supabase!.from(tableName).delete().eq('id', id);
    } catch (e) {
      print('Erro ao deletar item do Supabase: $e');
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

        // Limpar dados locais do usuário
        final db = await _db.database;
        await db.delete(
          localTable,
          where: 'user_id = ?',
          whereArgs: [currentUserId],
        );

        // Baixar todos os dados do servidor
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

        // Buscar todos os dados locais do usuário
        final db = await _db.database;
        final localData = await db.query(
          localTable,
          where: 'user_id = ?',
          whereArgs: [currentUserId],
        );

        // Enviar para o servidor
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
  }
}
