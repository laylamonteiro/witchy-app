import '../content/content_locale.dart';
import '../../l10n/generated/app_localizations.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../database/database_helper.dart';

AppLocalizations get _l10n =>
    lookupAppLocalizations(ContentLocale.instance.locale);

/// Tipos de entidades sincronizáveis
enum SyncEntity {
  spells,
  dreams,
  desires,
  gratitudes,
  affirmations,
  freeWritings,
  dailyRituals,
  ritualLogs,
  sigils,
  birthCharts,
  magicalProfiles,
  runeReadings,
  pendulumConsultations,
  oracleReadings,
  tarotReadings,
  dailyMagicalWeather,
  dailyCheckins,
  learningProgress,
  userEncyclopediaEntries,
  cycleReadings,
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
  final Map<String, String> entityErrors;

  SyncResult({
    required this.success,
    this.uploaded = 0,
    this.downloaded = 0,
    this.conflictsResolved = 0,
    this.unresolvedConflicts = const [],
    this.error,
    this.entityErrors = const {},
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

  factory SyncResult.error(
    String message, {
    int uploaded = 0,
    int downloaded = 0,
    Map<String, String> entityErrors = const {},
  }) {
    return SyncResult(
      success: false,
      error: message,
      uploaded: uploaded,
      downloaded: downloaded,
      entityErrors: entityErrors,
    );
  }

  /// Erro com o motivo REAL por entidade, para os logs de diagnóstico —
  /// "Falha ao sincronizar: dailyCheckins" sozinho não diz o porquê.
  String get detailedError {
    if (entityErrors.isEmpty) return error ?? 'Erro desconhecido';
    final details =
        entityErrors.entries.map((e) => '${e.key}: ${e.value}').join(' | ');
    return '${error ?? 'Falha'} — $details';
  }

  factory SyncResult.withConflicts(List<SyncConflict> conflicts) {
    return SyncResult(
      success: false,
      unresolvedConflicts: conflicts,
      error: _l10n.syncConflicts(conflicts.length),
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
  static const cloudSyncPreferenceKey = 'privacy_cloud_sync';
  static const cloudSyncUserConfiguredKey =
      'privacy_cloud_sync_user_configured';
  static const lastSuccessfulSyncPreferenceKey =
      'last_successful_cloud_sync_at';

  static String lastSuccessfulSyncKey(String? userId) =>
      '${lastSuccessfulSyncPreferenceKey}_${userId ?? 'local_user'}';

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
  List<SyncConflict> get pendingConflicts =>
      List.unmodifiable(_pendingConflicts);

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

  /// A preferência de sincronização, sem paywall.
  ///
  /// Sincronizar deixou de ser exclusivo do Premium. O motivo é o iOS: no
  /// navegador, o armazenamento gravável por script é apagado depois de 7
  /// dias sem a pessoa abrir o site — e o banco do app é sqlite no
  /// IndexedDB. Sem cópia na nuvem, uma semana ociosa apagava o grimório
  /// inteiro, inclusive a Leitura do Ciclo, que é vendida justamente a quem
  /// NÃO é Premium. Não é a pessoa limpando dados: é o sistema apagando.
  ///
  /// O `isPremium` saiu da assinatura de propósito, e não virou parâmetro
  /// ignorado: assim o compilador aponta todo lugar que ainda decidia sync
  /// por plano.
  @visibleForTesting
  static bool resolveCloudSyncPreference(SharedPreferences prefs) {
    final configured = prefs.getBool(cloudSyncPreferenceKey);
    final userConfigured = prefs.getBool(cloudSyncUserConfiguredKey) ?? false;
    final hasLegacyPreference = prefs.containsKey('privacy_sync') ||
        prefs.containsKey('privacy_backup');

    // Versões anteriores persistiam `false` automaticamente para quem era
    // Free. Esse valor nunca foi escolha de ninguém — era o paywall — então
    // não pode virar "desligado" agora que o recurso é de todo mundo.
    if (configured == false && !userConfigured && !hasLegacyPreference) {
      return true;
    }
    if (configured != null) return configured;

    return (prefs.getBool('privacy_sync') ?? true) &&
        (prefs.getBool('privacy_backup') ?? true);
  }

  static Future<bool> ensureCloudSyncPreference(SharedPreferences prefs) async {
    final enabled = resolveCloudSyncPreference(prefs);
    if (prefs.getBool(cloudSyncPreferenceKey) != enabled) {
      await prefs.setBool(cloudSyncPreferenceKey, enabled);
    }
    return enabled;
  }

  Future<bool> get cloudSyncEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return ensureCloudSyncPreference(prefs);
  }

  /// Última sincronização concluída para a conta atual.
  Future<DateTime?> get lastSuccessfulSyncTime async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(lastSuccessfulSyncKey(currentUserId));
    return timestamp == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<void> _persistSuccessfulSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      lastSuccessfulSyncKey(currentUserId),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Sincroniza todos os dados com tratamento de conflitos
  Future<SyncResult> syncAll({
    ConflictResolution? resolution,
  }) async {
    if (!isReady) {
      return SyncResult.error(_l10n.syncNotAuthenticated);
    }
    if (!await cloudSyncEnabled) {
      return SyncResult.error(_l10n.syncDisabled);
    }

    final useResolution = resolution ?? _defaultResolution;
    _setStatus(SyncStatus.syncing);
    _pendingConflicts.clear();

    try {
      int totalUploaded = 0;
      int totalDownloaded = 0;
      int totalConflictsResolved = 0;
      final entityErrors = <String, String>{};

      for (final entity in SyncEntity.values) {
        final result = await _syncEntity(entity, useResolution);
        totalUploaded += result.uploaded;
        totalDownloaded += result.downloaded;
        if (result.success) {
          totalConflictsResolved += result.conflictsResolved;
        }
        if (!result.success && result.unresolvedConflicts.isEmpty) {
          entityErrors[entity.name] = result.error ?? 'Erro desconhecido';
        }
        _pendingConflicts.addAll(result.unresolvedConflicts);
      }

      if (entityErrors.isNotEmpty) {
        _setStatus(SyncStatus.error);
        return SyncResult.error(
          _l10n.syncEntitiesFailed(entityErrors.keys.join(', ')),
          uploaded: totalUploaded,
          downloaded: totalDownloaded,
          entityErrors: entityErrors,
        );
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
      return SyncResult.error(_l10n.syncFailed('$e'));
    }
  }

  /// Sincroniza uma entidade específica com detecção de conflitos
  Future<SyncResult> _syncEntity(
    SyncEntity entity,
    ConflictResolution resolution,
  ) async {
    var uploaded = 0;
    var downloaded = 0;
    var conflictsResolved = 0;
    try {
      final tableName = supabaseTableFor(entity);
      final localTable = localTableFor(entity);

      final conflicts = <SyncConflict>[];

      // 1. Buscar dados locais modificados
      final localData = await _getModifiedLocalData(localTable);

      // 2. Buscar dados remotos
      final remoteData = (await _getRemoteData(tableName))
          .map((item) => _toLocal(tableName, item))
          .toList();
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

          if (temMudancas(tableName, local, remote)) {
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
          // Nas tabelas de um-dia-só, o mesmo DIA pode existir localmente
          // com outro uuid (instalação/aparelho diferente) — checar só o
          // id derrubava o sync no UNIQUE(user_id, date) local.
          final exists = _oneRowPerDayTables.contains(localTable)
              ? await _existsLocallyForDay(localTable, remote)
              : await _existsLocally(localTable, remote['id']);
          if (!exists) {
            await _insertLocally(localTable, remote);
            downloaded++;
          } else if (localTable == 'daily_checkins') {
            // O dia já existe localmente (ex.: registerVisit da
            // reinstalação criou a linha vazia antes do backup descer):
            // mescla os ritos remotos em vez de descartá-los.
            if (await _mergeRitesLocally(remote)) downloaded++;
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
      return SyncResult.error(
        e.toString(),
        uploaded: uploaded,
        downloaded: downloaded,
      );
    }
  }

  /// Verifica se há diferenças entre local e remoto.
  ///
  /// A comparação precisa da TABELA por causa dos campos de blob JSON. Neles,
  /// o lado local é o texto que o SQLite guardou e o lado remoto veio de um
  /// `jsonb` do Postgres, decodificado e reserializado por `_toLocal`. Duas
  /// serializações do MESMO conteúdo diferem em ordem de chave e espaçamento,
  /// então a comparação de texto dizia "mudou" para toda linha suja das sete
  /// tabelas com blob — mapa astral, perfil mágico, runas, oráculo, tarô,
  /// clima do dia e enciclopédia.
  ///
  /// O efeito não era cosmético: todo upload virava "conflito", e o
  /// `mostRecent` resolve empate de milissegundo a favor do servidor. Ou
  /// seja, edição local perdida em silêncio. Com a sincronização aberta para
  /// todo mundo, o alcance disso multiplica — por isso vem junto.
  @visibleForTesting
  static bool temMudancas(
    String table,
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) {
    const ignoreKeys = {'synced', 'updated_at', 'created_at'};
    final camposJson = _jsonFields[table] ?? const <String>{};

    for (final key in local.keys) {
      if (ignoreKeys.contains(key)) continue;

      if (camposJson.contains(key)) {
        if (_jsonCanonico(local[key]) != _jsonCanonico(remote[key])) {
          return true;
        }
        continue;
      }

      if (local[key] != remote[key]) return true;
    }

    return false;
  }

  /// Uma forma estável do valor, para comparar CONTEÚDO e não serialização.
  ///
  /// Aceita tanto o texto do SQLite quanto o Map/List já decodificado. O que
  /// não for JSON válido volta como veio: aí comparar como texto é o certo.
  static String _jsonCanonico(dynamic valor) {
    dynamic conteudo = valor;
    if (valor is String) {
      try {
        conteudo = jsonDecode(valor);
      } catch (_) {
        return valor;
      }
    }
    return jsonEncode(_comChavesOrdenadas(conteudo));
  }

  static dynamic _comChavesOrdenadas(dynamic valor) {
    if (valor is Map) {
      final chaves = valor.keys.map((k) => k.toString()).toList()..sort();
      return {for (final k in chaves) k: _comChavesOrdenadas(valor[k])};
    }
    if (valor is List) {
      // Ordem de lista é conteúdo: [a, b] não é [b, a]. Só normaliza dentro.
      return valor.map(_comChavesOrdenadas).toList();
    }
    return valor;
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

    final tableName = supabaseTableFor(conflict.entity);
    final localTable = localTableFor(conflict.entity);

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
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  /// O nome da tabela no Supabase para cada entidade sincronizável.
  ///
  /// Pública e estática porque a exclusão de conta deriva desta lista as
  /// tabelas que precisa varrer. A lista que ela mantinha à mão ficou cinco
  /// entidades atrás do que o app sincroniza, e dado íntimo sobreviveu à
  /// exclusão da conta — derivando daqui, entidade nova nasce coberta nos
  /// dois lugares.
  static String supabaseTableFor(SyncEntity entity) {
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
      case SyncEntity.freeWritings:
        return SupabaseTables.freeWritings;
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
      case SyncEntity.dailyMagicalWeather:
        return SupabaseTables.dailyMagicalWeather;
      case SyncEntity.dailyCheckins:
        return SupabaseTables.dailyCheckins;
      case SyncEntity.learningProgress:
        return SupabaseTables.learningProgress;
      case SyncEntity.userEncyclopediaEntries:
        return SupabaseTables.userEncyclopediaEntries;
      case SyncEntity.tarotReadings:
        return SupabaseTables.tarotReadings;
      case SyncEntity.cycleReadings:
        return SupabaseTables.cycleReadings;
    }
  }

  /// O nome da tabela local (SQLite) para cada entidade sincronizável.
  ///
  /// Pública e estática pelo mesmo motivo de [supabaseTableFor]: a adoção de
  /// dados anônimos no login mantinha a própria lista escrita à mão e já
  /// tinha perdido uma entidade.
  static String localTableFor(SyncEntity entity) {
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
      case SyncEntity.freeWritings:
        return 'free_writings';
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
      case SyncEntity.dailyMagicalWeather:
        return 'daily_magical_weather';
      case SyncEntity.dailyCheckins:
        return 'daily_checkins';
      case SyncEntity.learningProgress:
        return 'learning_progress';
      case SyncEntity.userEncyclopediaEntries:
        return 'user_encyclopedia_entries';
      case SyncEntity.tarotReadings:
        return 'tarot_readings';
      case SyncEntity.cycleReadings:
        return 'cycle_readings';
    }
  }

  /// Busca dados locais modificados (não sincronizados ou atualizados)
  Future<List<Map<String, dynamic>>> _getModifiedLocalData(String table) async {
    final db = await _db.database;

    try {
      final result = await db.query(
        table,
        where: '(synced = ? OR synced IS NULL) AND user_id = ?',
        whereArgs: [0, currentUserId],
      );
      return result.where((item) => _isSyncableItem(table, item)).toList();
    } catch (e) {
      final result = await db.query(
        table,
        where: 'user_id = ?',
        whereArgs: [currentUserId],
      );
      return result.where((item) => _isSyncableItem(table, item)).toList();
    }
  }

  /// Tabelas com UMA linha por dia (UNIQUE(user_id, date) local e remoto):
  /// cada aparelho/instalação gera um uuid próprio para o MESMO dia, então
  /// a identidade de verdade é (user_id, date) — nunca só o id.
  static const _oneRowPerDayTables = {
    'daily_magical_weather',
    'daily_checkins',
  };

  /// Envia item para o Supabase
  Future<void> _uploadItem(String table, Map<String, dynamic> item) async {
    final remoteItem = _toRemote(table, item);
    // Tabelas com uma linha por DIA: cada aparelho gera um uuid próprio,
    // então o conflito de verdade é (user_id, date) — sem isto, dois
    // aparelhos criariam linhas duplicadas do mesmo dia.
    if (_oneRowPerDayTables.contains(table)) {
      if (table == 'daily_checkins') {
        // O upload NUNCA apaga ritos remotos: na reinstalação, o
        // registerVisit sobe o dia com rites vazio ANTES de o backup
        // descer — sem a união, ele apagava na nuvem os ritos já feitos
        // (e o "Ritos de Hoje" esquecia a tiragem salva).
        try {
          final existing = await _supabase!
              .from(table)
              .select('rites')
              .eq('user_id', remoteItem['user_id'])
              .eq('date', remoteItem['date'])
              .maybeSingle();
          final merged = {
            ..._splitRites(existing?['rites'] as String?),
            ..._splitRites(remoteItem['rites'] as String?),
          };
          remoteItem['rites'] = merged.join(',');
        } catch (_) {
          // Sem linha remota ou leitura indisponível: segue com o local.
        }
      }
      await _supabase!
          .from(table)
          .upsert(remoteItem, onConflict: 'user_id,date');
      return;
    }
    await _supabase!.from(table).upsert(remoteItem);
  }

  static Set<String> _splitRites(String? raw) => raw == null || raw.isEmpty
      ? {}
      : raw.split(',').where((e) => e.isNotEmpty).toSet();

  bool _isSyncableItem(String table, Map<String, dynamic> item) {
    if ((table == 'spells' || table == 'affirmations') &&
        item['is_preloaded'] == 1) {
      return false;
    }
    return true;
  }

  static const _booleanFields = {
    'spells': {'is_preloaded'},
    'affirmations': {'is_preloaded', 'is_favorite'},
    'daily_rituals': {'is_active'},
    'birth_charts': {'unknown_birth_time'},
  };

  static const _jsonFields = {
    'birth_charts': {'chart_data'},
    'magical_profiles': {'profile_data'},
    'rune_readings': {'reading_data'},
    'oracle_readings': {'reading_data'},
    'tarot_readings': {'reading_data'},
    'daily_magical_weather': {'weather_data'},
    'user_encyclopedia_entries': {'data'},
  };

  static const _dateFields = {
    'spells': {'created_at', 'updated_at'},
    'dreams': {'date', 'created_at', 'updated_at'},
    'desires': {'created_at', 'updated_at'},
    'gratitudes': {'date', 'created_at', 'updated_at'},
    'affirmations': {'created_at', 'updated_at'},
    'free_writings': {'created_at', 'updated_at'},
    'daily_rituals': {'created_at', 'updated_at'},
    'ritual_logs': {'completed_at', 'updated_at'},
    'sigils': {'created_at', 'updated_at'},
    'birth_charts': {'birth_date', 'calculated_at', 'updated_at'},
    'magical_profiles': {'generated_at', 'updated_at'},
    'rune_readings': {'date', 'created_at', 'updated_at'},
    'pendulum_consultations': {'date', 'created_at', 'updated_at'},
    'oracle_readings': {'date', 'created_at', 'updated_at'},
    'tarot_readings': {'date', 'created_at', 'updated_at'},
    'daily_magical_weather': {'created_at', 'updated_at'},
    // `date` fica de fora de propósito nas duas: já é a string YYYY-MM-DD
    // do dia local, e converter para timestamp faria o dia "virar" para
    // quem está longe de Greenwich.
    'daily_checkins': {'created_at', 'updated_at'},
    'learning_progress': {'completed_at', 'updated_at'},
    'user_encyclopedia_entries': {'created_at', 'updated_at'},
    'cycle_readings': {
      'period_start',
      'period_end',
      'created_at',
      'updated_at',
    },
  };

  /// Os nomes de tabela por entidade, para o teste que garante que nenhuma
  /// entidade fique sem par (uma tabela fora do sync some na reinstalação).
  @visibleForTesting
  String localTableForTest(SyncEntity entity) => localTableFor(entity);

  @visibleForTesting
  String remoteTableForTest(SyncEntity entity) => supabaseTableFor(entity);

  @visibleForTesting
  Map<String, dynamic> toRemoteForTest(
    String table,
    Map<String, dynamic> item,
    String userId,
  ) =>
      _toRemote(table, item, userIdOverride: userId);

  @visibleForTesting
  Map<String, dynamic> toLocalForTest(
    String table,
    Map<String, dynamic> item,
  ) =>
      _toLocal(table, item);

  Map<String, dynamic> _toRemote(
    String table,
    Map<String, dynamic> item, {
    String? userIdOverride,
  }) {
    final data = Map<String, dynamic>.from(item)..remove('synced');
    data['user_id'] = userIdOverride ?? currentUserId;

    for (final field in _booleanFields[table] ?? const <String>{}) {
      final value = data[field];
      if (value is int) data[field] = value == 1;
    }
    for (final field in _jsonFields[table] ?? const <String>{}) {
      final value = data[field];
      if (value is String) {
        try {
          data[field] = jsonDecode(value);
        } catch (_) {}
      }
    }
    for (final field in _dateFields[table] ?? const <String>{}) {
      final value = data[field];
      if (value is int) {
        data[field] = DateTime.fromMillisecondsSinceEpoch(value)
            .toUtc()
            .toIso8601String();
      } else if (value is DateTime) {
        data[field] = value.toUtc().toIso8601String();
      }
    }
    data['updated_at'] ??= DateTime.now().toUtc().toIso8601String();
    return data;
  }

  Map<String, dynamic> _toLocal(
    String table,
    Map<String, dynamic> item,
  ) {
    final data = Map<String, dynamic>.from(item);
    for (final field in _booleanFields[table] ?? const <String>{}) {
      final value = data[field];
      if (value is bool) data[field] = value ? 1 : 0;
    }
    for (final field in _jsonFields[table] ?? const <String>{}) {
      final value = data[field];
      if (value is Map || value is List) data[field] = jsonEncode(value);
    }
    for (final field in _dateFields[table] ?? const <String>{}) {
      final value = data[field];
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) data[field] = parsed.millisecondsSinceEpoch;
      } else if (value is DateTime) {
        data[field] = value.millisecondsSinceEpoch;
      }
    }
    data['synced'] = 1;
    return data;
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

  /// Colunas reais de cada tabela local (cache do PRAGMA por tabela).
  final Map<String, Set<String>> _localColumnsCache = {};

  /// Mantém no mapa apenas chaves que EXISTEM na tabela local. Quando o
  /// servidor ganha coluna nova, um app com schema local antigo recebe a
  /// chave desconhecida no download e o INSERT/UPDATE explodiria — este
  /// filtro elimina essa classe de bug (a mesma do dailyCheckins).
  Future<Map<String, dynamic>> _onlyLocalColumns(
    String table,
    Map<String, dynamic> item,
  ) async {
    var columns = _localColumnsCache[table];
    if (columns == null) {
      final db = await _db.database;
      final info = await db.rawQuery('PRAGMA table_info($table)');
      columns = info.map((c) => c['name'] as String).toSet();
      _localColumnsCache[table] = columns;
    }
    final cols = columns;
    return {
      for (final e in item.entries)
        if (cols.contains(e.key)) e.key: e.value,
    };
  }

  /// Atualiza item localmente
  Future<void> _updateLocally(String table, Map<String, dynamic> item) async {
    final db = await _db.database;
    final data = await _onlyLocalColumns(table, item);
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
    final response =
        await _supabase!.from(table).select().eq('user_id', currentUserId!);

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

  /// União dos ritos remotos na linha local do MESMO dia. Devolve true se
  /// a linha local ganhou ritos novos (fica synced=0: a união volta para a
  /// nuvem no próximo upload, que também é uma união — converge).
  Future<bool> _mergeRitesLocally(Map<String, dynamic> remote) async {
    final db = await _db.database;
    final rows = await db.query(
      'daily_checkins',
      where: 'user_id = ? AND date = ?',
      whereArgs: [remote['user_id'], remote['date']],
      limit: 1,
    );
    if (rows.isEmpty) return false;

    final localRites = _splitRites(rows.first['rites'] as String?);
    final remoteRites = _splitRites(remote['rites'] as String?);
    if (remoteRites.difference(localRites).isEmpty) return false;

    await db.update(
      'daily_checkins',
      {
        'rites': {...localRites, ...remoteRites}.join(','),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'synced': 0,
      },
      where: 'user_id = ? AND date = ?',
      whereArgs: [remote['user_id'], remote['date']],
    );
    return true;
  }

  /// Existência nas tabelas de um-dia-só: pelo id OU pelo dia (user_id,
  /// date) — a linha do dia pode ter nascido com outro uuid.
  Future<bool> _existsLocallyForDay(
    String table,
    Map<String, dynamic> item,
  ) async {
    final db = await _db.database;
    final result = await db.query(
      table,
      where: 'id = ? OR (user_id = ? AND date = ?)',
      whereArgs: [item['id'], item['user_id'], item['date']],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Insere item localmente
  Future<void> _insertLocally(String table, Map<String, dynamic> item) async {
    final db = await _db.database;
    final data = await _onlyLocalColumns(table, item);
    data['synced'] = 1;

    await db.insert(
      table,
      data,
      // Um-dia-só: numa corrida rara o mesmo dia ainda pode chegar com
      // outro id — ignorar a linha vale mais que derrubar o sync inteiro.
      conflictAlgorithm: _oneRowPerDayTables.contains(table)
          ? ConflictAlgorithm.ignore
          : ConflictAlgorithm.abort,
    );
  }

  /// Atualiza o status
  void _setStatus(SyncStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
    if (newStatus == SyncStatus.success) {
      unawaited(_persistSuccessfulSyncTime());
    }
  }

  /// Sincroniza um item específico após criação/atualização.
  ///
  /// Vale para qualquer conta: sincronizar não é mais exclusivo do Premium.
  /// O que ainda é exigido é CONTA — sem `auth.uid()` não há dono da linha
  /// no servidor.
  Future<void> syncItem(SyncEntity entity, Map<String, dynamic> item) async {
    if (!isReady) return;
    if (!await cloudSyncEnabled) return;

    try {
      final tableName = supabaseTableFor(entity);
      final localTable = localTableFor(entity);
      if (!_isSyncableItem(localTable, item)) return;
      await _uploadItem(tableName, item);
      await _markAsSynced(localTable, item['id']);
    } catch (e) {
      debugPrint('Erro ao sincronizar item: $e');
    }
  }

  /// Apaga na nuvem as linhas da pessoa que NÃO são do dia informado.
  ///
  /// Para as tabelas de um-dia-só (clima mágico): sem isto o
  /// [fullDownload] baixaria de volta todo o histórico que a poda local
  /// acabou de apagar, porque ele traz todas as linhas do usuário.
  Future<void> pruneOtherDays(SyncEntity entity, String date) async {
    if (!isReady) return;
    if (!await cloudSyncEnabled) return;

    try {
      await _supabase!
          .from(supabaseTableFor(entity))
          .delete()
          .eq('user_id', currentUserId!)
          .neq('date', date);
    } catch (e) {
      debugPrint('Erro ao podar dias antigos no Supabase: $e');
    }
  }

  /// Deleta um item do Supabase.
  ///
  /// Sem paywall, e é essencial que seja assim: se o apagar local não
  /// chegasse à nuvem, o próximo download traria o registro de volta.
  Future<void> deleteItem(SyncEntity entity, dynamic id) async {
    if (!isReady) return;
    if (!await cloudSyncEnabled) return;

    try {
      final tableName = supabaseTableFor(entity);
      await _supabase!
          .from(tableName)
          .delete()
          .eq('id', id)
          .eq('user_id', currentUserId!);
    } catch (e) {
      debugPrint('Erro ao deletar item do Supabase: $e');
    }
  }

  /// Limpa dados locais e baixa tudo do servidor
  Future<SyncResult> fullDownload() async {
    if (!isReady) {
      return SyncResult.error(_l10n.syncNotAuthenticated);
    }
    if (!await cloudSyncEnabled) {
      return SyncResult.error(_l10n.syncDisabled);
    }

    _setStatus(SyncStatus.syncing);

    try {
      final downloadedByTable = <String, List<Map<String, dynamic>>>{};
      final entityErrors = <String, String>{};
      for (final entity in SyncEntity.values) {
        try {
          final tableName = supabaseTableFor(entity);
          final localTable = localTableFor(entity);
          final remoteData = await _getRemoteData(tableName);
          downloadedByTable[localTable] =
              remoteData.map((item) => _toLocal(tableName, item)).toList();
        } catch (e) {
          entityErrors[entity.name] = e.toString();
        }
      }
      if (entityErrors.isNotEmpty) {
        _setStatus(SyncStatus.error);
        return SyncResult.error(
          _l10n.syncDownloadFailed(entityErrors.keys.join(', ')),
          entityErrors: entityErrors,
        );
      }

      final db = await _db.database;
      await db.transaction((txn) async {
        for (final entry in downloadedByTable.entries) {
          await txn.delete(
            entry.key,
            where: 'user_id = ?',
            whereArgs: [currentUserId],
          );
          for (final item in entry.value) {
            await txn.insert(entry.key, item);
          }
        }
      });
      final totalDownloaded = downloadedByTable.values
          .fold<int>(0, (total, items) => total + items.length);

      _setStatus(SyncStatus.success);
      return SyncResult.success(downloaded: totalDownloaded);
    } catch (e) {
      _setStatus(SyncStatus.error);
      return SyncResult.error(_l10n.syncFailed('$e'));
    }
  }

  /// Envia todos os dados locais para o servidor
  Future<SyncResult> fullUpload() async {
    if (!isReady) {
      return SyncResult.error(_l10n.syncNotAuthenticated);
    }
    if (!await cloudSyncEnabled) {
      return SyncResult.error(_l10n.syncDisabled);
    }

    _setStatus(SyncStatus.syncing);

    try {
      int totalUploaded = 0;
      final entityErrors = <String, String>{};

      for (final entity in SyncEntity.values) {
        try {
          final tableName = supabaseTableFor(entity);
          final localTable = localTableFor(entity);

          final db = await _db.database;
          final localData = await db.query(
            localTable,
            where: 'user_id = ?',
            whereArgs: [currentUserId],
          );

          for (final item in localData.where(
            (item) => _isSyncableItem(localTable, item),
          )) {
            await _uploadItem(tableName, item);
            await _markAsSynced(localTable, item['id']);
            totalUploaded++;
          }
        } catch (e) {
          entityErrors[entity.name] = e.toString();
        }
      }

      if (entityErrors.isNotEmpty) {
        _setStatus(SyncStatus.error);
        return SyncResult.error(
          _l10n.syncUploadFailed(entityErrors.keys.join(', ')),
          uploaded: totalUploaded,
          entityErrors: entityErrors,
        );
      }

      _setStatus(SyncStatus.success);
      return SyncResult.success(uploaded: totalUploaded);
    } catch (e) {
      _setStatus(SyncStatus.error);
      return SyncResult.error(_l10n.syncFailed('$e'));
    }
  }

  void dispose() {
    _statusController.close();
    _conflictsController.close();
  }
}
