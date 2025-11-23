import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/data_sync_service.dart';
import '../services/debug_log_service.dart';
import '../services/payment_service.dart';

/// Provider que gerencia o estado de sincronização e expõe para a UI
/// NOTA: Sincronização é uma funcionalidade PREMIUM
class SyncProvider extends ChangeNotifier {
  final DataSyncService _syncService = DataSyncService();
  final PaymentService _paymentService = PaymentService();

  SyncStatus _status = SyncStatus.idle;
  List<SyncConflict> _conflicts = [];
  String? _lastError;
  DateTime? _lastSyncTime;
  int _pendingSyncCount = 0;

  StreamSubscription<SyncStatus>? _statusSubscription;
  StreamSubscription<List<SyncConflict>>? _conflictsSubscription;

  SyncProvider() {
    _init();
  }

  void _init() {
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
  }

  // Getters
  SyncStatus get status => _status;
  List<SyncConflict> get conflicts => _conflicts;
  String? get lastError => _lastError;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingSyncCount => _pendingSyncCount;
  bool get isSyncing => _status == SyncStatus.syncing;
  bool get hasConflicts => _conflicts.isNotEmpty;
  bool get isReady => _syncService.isReady && _paymentService.isPro;
  bool get isPremium => _paymentService.isPro;

  /// Status formatado para exibição
  String get statusText {
    switch (_status) {
      case SyncStatus.idle:
        return 'Sincronização desativada';
      case SyncStatus.syncing:
        return 'Sincronizando...';
      case SyncStatus.success:
        return 'Sincronizado';
      case SyncStatus.error:
        return 'Erro na sincronização';
      case SyncStatus.conflict:
        return '${_conflicts.length} conflito(s)';
    }
  }

  /// Última sincronização formatada
  String get lastSyncText {
    if (_lastSyncTime == null) return 'Nunca sincronizado';

    final diff = DateTime.now().difference(_lastSyncTime!);
    if (diff.inMinutes < 1) return 'Agora mesmo';
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Há ${diff.inHours} h';
    return 'Há ${diff.inDays} dias';
  }

  /// Inicia sincronização manual
  Future<SyncResult> sync() async {
    if (!_paymentService.isPro) {
      _lastError = 'Sincronização é uma funcionalidade Premium';
      notifyListeners();
      return SyncResult.error(_lastError!);
    }

    if (!_syncService.isReady) {
      _lastError = 'Usuário não autenticado';
      notifyListeners();
      return SyncResult.error(_lastError!);
    }

    await debugLog('SYNC', 'Iniciando sincronização manual');
    final result = await _syncService.syncAll();

    if (!result.success) {
      _lastError = result.error;
      await debugLog('SYNC', 'Erro: ${result.error}');
    } else {
      await debugLog('SYNC', 'Sucesso: ${result.uploaded} enviados, ${result.downloaded} recebidos');
    }

    notifyListeners();
    return result;
  }

  /// Upload completo (enviar tudo para nuvem)
  Future<SyncResult> fullUpload() async {
    if (!_paymentService.isPro) {
      return SyncResult.error('Sincronização é uma funcionalidade Premium');
    }

    if (!_syncService.isReady) {
      return SyncResult.error('Usuário não autenticado');
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
    if (!_paymentService.isPro) {
      return SyncResult.error('Sincronização é uma funcionalidade Premium');
    }

    if (!_syncService.isReady) {
      return SyncResult.error('Usuário não autenticado');
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
  Future<void> resolveConflict(SyncConflict conflict, ConflictResolution resolution) async {
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
    _statusSubscription?.cancel();
    _conflictsSubscription?.cancel();
    super.dispose();
  }
}
