import '../content/content_locale.dart';
import '../../l10n/generated/app_localizations.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/data_sync_service.dart';
import '../services/debug_log_service.dart';
import '../services/premium_access.dart';

AppLocalizations get _l10n =>
    lookupAppLocalizations(ContentLocale.instance.locale);

/// Provider que gerencia o estado de sincronização e expõe para a UI
/// NOTA: Sincronização é uma funcionalidade PREMIUM
class SyncProvider extends ChangeNotifier {
  final DataSyncService _syncService = DataSyncService();

  SyncStatus _status = SyncStatus.idle;
  List<SyncConflict> _conflicts = [];
  String? _lastError;
  DateTime? _lastSyncTime;
  int _pendingSyncCount = 0;
  bool _disposed = false;

  StreamSubscription<SyncStatus>? _statusSubscription;
  StreamSubscription<List<SyncConflict>>? _conflictsSubscription;

  SyncProvider() {
    _init();
  }

  void _init() {
    // O stream é broadcast e não repete o último evento. Leia o estado atual
    // antes de assinar para não perder um sync concluído em background.
    _status = _syncService.status;
    _statusSubscription = _syncService.statusStream.listen((status) {
      _status = status;
      if (status == SyncStatus.success) {
        _lastSyncTime = DateTime.now();
        _lastError = null;
      }
      notifyListeners();
    });

    _conflictsSubscription = _syncService.conflictsStream.listen((conflicts) {
      _conflicts = conflicts;
      notifyListeners();
    });

    unawaited(refreshState());
  }

  /// Recarrega o singleton e o horário persistido da conta atual.
  Future<void> refreshState() async {
    final persistedLastSync = await _syncService.lastSuccessfulSyncTime;
    if (_disposed) return;

    _status = _syncService.status;
    _lastSyncTime = persistedLastSync;

    // Cobre o caso em que o provider nasceu depois do evento de sucesso.
    if (_status == SyncStatus.success && _lastSyncTime == null) {
      _lastSyncTime = DateTime.now();
    }
    notifyListeners();
  }

  // Getters
  SyncStatus get status => _status;
  List<SyncConflict> get conflicts => _conflicts;
  String? get lastError => _lastError;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingSyncCount => _pendingSyncCount;
  bool get isSyncing => _status == SyncStatus.syncing;
  bool get hasConflicts => _conflicts.isNotEmpty;
  bool get isReady => _syncService.isReady && PremiumAccess.instance.isPremium;
  bool get isPremium => PremiumAccess.instance.isPremium;

  /// Status formatado para exibição
  String get statusText {
    switch (_status) {
      case SyncStatus.idle:
        return _l10n.syncActive;
      case SyncStatus.syncing:
        return 'Sincronizando...';
      case SyncStatus.success:
        return 'Sincronizado';
      case SyncStatus.error:
        return _l10n.syncError;
      case SyncStatus.conflict:
        return '${_conflicts.length} conflito(s)';
    }
  }

  /// Última sincronização formatada
  String get lastSyncText {
    if (_lastSyncTime == null) return 'Nunca sincronizado';

    final diff = DateTime.now().difference(_lastSyncTime!);
    if (diff.inMinutes < 1) return 'Agora mesmo';
    if (diff.inMinutes < 60) return _l10n.syncAgoMinutes(diff.inMinutes);
    if (diff.inHours < 24) return _l10n.syncAgoHours(diff.inHours);
    return _l10n.syncAgoDays(diff.inDays);
  }

  /// Inicia sincronização manual
  Future<SyncResult> sync() async {
    if (!PremiumAccess.instance.isPremium) {
      _lastError = _l10n.syncPremiumOnly;
      notifyListeners();
      return SyncResult.error(_lastError!);
    }

    if (!_syncService.isReady) {
      _lastError = _l10n.syncNotAuthenticated;
      notifyListeners();
      return SyncResult.error(_lastError!);
    }

    await debugLog('SYNC', 'Iniciando sincronização manual');
    final result = await _syncService.syncAll();

    if (!result.success) {
      _lastError = result.error;
      await debugLog('SYNC', 'Erro: ${result.error}');
    } else {
      await debugLog('SYNC',
          'Sucesso: ${result.uploaded} enviados, ${result.downloaded} recebidos');
    }

    notifyListeners();
    return result;
  }

  /// Upload completo (enviar tudo para nuvem)
  Future<SyncResult> fullUpload() async {
    if (!PremiumAccess.instance.isPremium) {
      return SyncResult.error(_l10n.syncPremiumOnly);
    }

    if (!_syncService.isReady) {
      return SyncResult.error(_l10n.syncNotAuthenticated);
    }

    await debugLog('SYNC', 'Iniciando upload completo');
    final result = await _syncService.fullUpload();

    if (result.success) {
      await debugLog('SYNC', 'Upload concluído: ${result.uploaded} itens');
    }

    notifyListeners();
    return result;
  }

  /// Download completo (baixar tudo da nuvem)
  Future<SyncResult> fullDownload() async {
    if (!PremiumAccess.instance.isPremium) {
      return SyncResult.error(_l10n.syncPremiumOnly);
    }

    if (!_syncService.isReady) {
      return SyncResult.error(_l10n.syncNotAuthenticated);
    }

    await debugLog('SYNC', 'Iniciando download completo');
    final result = await _syncService.fullDownload();

    if (result.success) {
      await debugLog('SYNC', 'Download concluído: ${result.downloaded} itens');
    }

    notifyListeners();
    return result;
  }

  /// Resolve um conflito específico
  Future<void> resolveConflict(
      SyncConflict conflict, ConflictResolution resolution) async {
    await _syncService.resolveConflictManually(conflict, resolution);
    _conflicts = _syncService.pendingConflicts;
    notifyListeners();
  }

  /// Resolve todos os conflitos com uma estratégia
  Future<void> resolveAllConflicts(ConflictResolution resolution) async {
    await _syncService.resolveAllConflicts(resolution);
    _conflicts = _syncService.pendingConflicts;
    notifyListeners();
  }

  /// Define a estratégia padrão de resolução
  void setDefaultResolution(ConflictResolution resolution) {
    _syncService.defaultResolution = resolution;
  }

  @override
  void dispose() {
    _disposed = true;
    _statusSubscription?.cancel();
    _conflictsSubscription?.cancel();
    super.dispose();
  }
}
