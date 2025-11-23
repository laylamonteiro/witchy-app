import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../data/models/feature_access.dart';

/// Provider para gerenciar autenticação e estado do usuário
class AuthProvider extends ChangeNotifier {
  static const String _userKey = 'current_user';
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _lastDiaryResetKey = 'last_diary_reset';
  static const String _lastAiResetKey = 'last_ai_reset';
  static const String _lastPendulumResetKey = 'last_pendulum_reset';
  static const String _lastDailyLimitsResetKey = 'last_daily_limits_reset';
  static const String _isOriginalAdminKey = 'is_original_admin';
  static const String _authVersionKey = 'auth_version';

  /// Versão atual do fluxo de autenticação
  /// Incrementar quando quiser forçar todos os usuários a ver o onboarding novamente
  static const int _currentAuthVersion = 3;

  UserModel _currentUser = UserModel.defaultUser();
  bool _isInitialized = false;
  bool _hasSeenOnboarding = false;
  bool _isOriginalAdmin = false; // Mantém acesso ao painel admin ao simular outros roles

  UserModel get currentUser => _currentUser;
  bool get isInitialized => _isInitialized;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  /// Retorna true se o usuário é admin original (mesmo simulando outro role)
  bool get isOriginalAdmin => _isOriginalAdmin;

  // Atalhos convenientes
  bool get isAdmin => _currentUser.isAdmin;
  bool get isPremium => _currentUser.isPremium;
  bool get isFree => _currentUser.isFree;

  /// Inicializa o provider carregando dados salvos
  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();

    // Verificar versão do fluxo de autenticação
    // Se a versão mudou, resetar o estado de onboarding e usuário
    final savedAuthVersion = prefs.getInt(_authVersionKey) ?? 0;
    debugPrint('🔐 AuthProvider: savedVersion=$savedAuthVersion, currentVersion=$_currentAuthVersion');

    if (savedAuthVersion < _currentAuthVersion) {
      // Nova versão do auth - limpar dados antigos para mostrar onboarding
      debugPrint('🔐 AuthProvider: RESETTING - limpando dados antigos');
      await prefs.remove(_hasSeenOnboardingKey);
      await prefs.remove(_userKey);
      await prefs.remove(_isOriginalAdminKey);
      await prefs.setInt(_authVersionKey, _currentAuthVersion);

      _hasSeenOnboarding = false;
      _isOriginalAdmin = false;
      _currentUser = UserModel.defaultUser();
      _isInitialized = true;
      debugPrint('🔐 AuthProvider: RESET COMPLETE - hasSeenOnboarding=$_hasSeenOnboarding, email=${_currentUser.email}');
      notifyListeners();
      return;
    }

    // Verificar se já viu onboarding
    _hasSeenOnboarding = prefs.getBool(_hasSeenOnboardingKey) ?? false;
    debugPrint('🔐 AuthProvider: hasSeenOnboarding=$_hasSeenOnboarding');

    // Carregar flag de admin original
    _isOriginalAdmin = prefs.getBool(_isOriginalAdminKey) ?? false;

    // Carregar usuário salvo
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        _currentUser = UserModel.fromJson(jsonDecode(userJson));
        // Resetar contadores se necessário
        await _checkAndResetCounters();
      } catch (e) {
        _currentUser = UserModel.defaultUser();
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Salva o usuário atual
  Future<void> _saveUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(_currentUser.toJson()));
  }

  /// Marca que o onboarding foi visto
  Future<void> markOnboardingSeen() async {
    _hasSeenOnboarding = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, true);
    notifyListeners();
  }

  /// Verifica e reseta contadores diários/mensais se necessário
  Future<void> _checkAndResetCounters() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    bool needsSave = false;

    // Reset diário de IA
    final lastAiReset = prefs.getString(_lastAiResetKey);
    if (lastAiReset != null) {
      final lastDate = DateTime.parse(lastAiReset);
      if (now.day != lastDate.day ||
          now.month != lastDate.month ||
          now.year != lastDate.year) {
        _currentUser = _currentUser.copyWith(aiConsultationsToday: 0);
        await prefs.setString(_lastAiResetKey, now.toIso8601String());
        needsSave = true;
      }
    } else {
      await prefs.setString(_lastAiResetKey, now.toIso8601String());
    }

    // Reset mensal de diários
    final lastDiaryReset = prefs.getString(_lastDiaryResetKey);
    if (lastDiaryReset != null) {
      final lastDate = DateTime.parse(lastDiaryReset);
      if (now.month != lastDate.month || now.year != lastDate.year) {
        _currentUser = _currentUser.copyWith(diaryEntriesThisMonth: 0);
        await prefs.setString(_lastDiaryResetKey, now.toIso8601String());
        needsSave = true;
      }
    } else {
      await prefs.setString(_lastDiaryResetKey, now.toIso8601String());
    }

    // Reset diário do pêndulo (para TODOS os usuários)
    final lastPendulumReset = prefs.getString(_lastPendulumResetKey);
    if (lastPendulumReset != null) {
      final lastDate = DateTime.parse(lastPendulumReset);
      if (now.day != lastDate.day ||
          now.month != lastDate.month ||
          now.year != lastDate.year) {
        _currentUser = _currentUser.copyWith(pendulumUsesToday: 0);
        await prefs.setString(_lastPendulumResetKey, now.toIso8601String());
        needsSave = true;
      }
    } else {
      await prefs.setString(_lastPendulumResetKey, now.toIso8601String());
    }

    // Reset diário dos novos limites (afirmações, runas, oracle)
    final lastDailyLimitsReset = prefs.getString(_lastDailyLimitsResetKey);
    if (lastDailyLimitsReset != null) {
      final lastDate = DateTime.parse(lastDailyLimitsReset);
      if (now.day != lastDate.day ||
          now.month != lastDate.month ||
          now.year != lastDate.year) {
        _currentUser = _currentUser.copyWith(
          affirmationsToday: 0,
          runeReadingsToday: 0,
          oracleReadingsToday: 0,
        );
        await prefs.setString(_lastDailyLimitsResetKey, now.toIso8601String());
        needsSave = true;
      }
    } else {
      await prefs.setString(_lastDailyLimitsResetKey, now.toIso8601String());
    }

    if (needsSave) {
      await _saveUser();
    }
  }

  /// Verifica acesso a uma feature
  AccessResult checkFeatureAccess(AppFeature feature) {
    return FeatureAccess.checkAccess(feature, _currentUser);
  }

  /// Verifica se tem acesso total a uma feature
  bool hasFullAccess(AppFeature feature) {
    return checkFeatureAccess(feature).hasFullAccess;
  }

  /// Incrementa contador de feitiços
  Future<void> incrementSpellsCount() async {
    if (_currentUser.isFree) {
      _currentUser = _currentUser.copyWith(
        spellsCount: _currentUser.spellsCount + 1,
      );
      await _saveUser();
      notifyListeners();
    }
  }

  /// Decrementa contador de feitiços (quando deletado)
  Future<void> decrementSpellsCount() async {
    if (_currentUser.isFree && _currentUser.spellsCount > 0) {
      _currentUser = _currentUser.copyWith(
        spellsCount: _currentUser.spellsCount - 1,
      );
      await _saveUser();
      notifyListeners();
    }
  }

  /// Incrementa contador de entradas de diário
  Future<void> incrementDiaryEntries() async {
    if (_currentUser.isFree) {
      _currentUser = _currentUser.copyWith(
        diaryEntriesThisMonth: _currentUser.diaryEntriesThisMonth + 1,
      );
      await _saveUser();
      notifyListeners();
    }
  }

  /// Incrementa contador de consultas IA
  Future<void> incrementAiConsultations() async {
    if (_currentUser.isFree) {
      _currentUser = _currentUser.copyWith(
        aiConsultationsToday: _currentUser.aiConsultationsToday + 1,
      );
      await _saveUser();
      notifyListeners();
    }
  }

  /// Verifica se pode usar o pêndulo hoje (limite para TODOS)
  bool get canUsePendulum => _currentUser.canUsePendulum;

  /// Quantos usos do pêndulo restam hoje
  int get remainingPendulumUses => _currentUser.remainingPendulumUses;

  /// Incrementa contador de uso do pêndulo (para TODOS os usuários)
  Future<void> incrementPendulumUses() async {
    _currentUser = _currentUser.copyWith(
      pendulumUsesToday: _currentUser.pendulumUsesToday + 1,
    );
    await _saveUser();
    notifyListeners();
  }

  /// Verifica se pode usar afirmações hoje
  bool get canUseAffirmations => _currentUser.canUseAffirmations;

  /// Quantas afirmações restam hoje
  int get remainingAffirmations => _currentUser.remainingAffirmations;

  /// Incrementa contador de afirmações
  Future<void> incrementAffirmations() async {
    if (_currentUser.isFree) {
      _currentUser = _currentUser.copyWith(
        affirmationsToday: _currentUser.affirmationsToday + 1,
      );
      await _saveUser();
      notifyListeners();
    }
  }

  /// Verifica se pode fazer leitura de runas hoje
  bool get canUseRunes => _currentUser.canUseRunes;

  /// Quantas leituras de runas restam hoje
  int get remainingRuneReadings => _currentUser.remainingRuneReadings;

  /// Incrementa contador de leituras de runas
  Future<void> incrementRuneReadings() async {
    if (_currentUser.isFree) {
      _currentUser = _currentUser.copyWith(
        runeReadingsToday: _currentUser.runeReadingsToday + 1,
      );
      await _saveUser();
      notifyListeners();
    }
  }

  /// Verifica se pode fazer leitura de oracle hoje
  bool get canUseOracle => _currentUser.canUseOracle;

  /// Quantas leituras de oracle restam hoje
  int get remainingOracleReadings => _currentUser.remainingOracleReadings;

  /// Incrementa contador de leituras de oracle
  Future<void> incrementOracleReadings() async {
    if (_currentUser.isFree) {
      _currentUser = _currentUser.copyWith(
        oracleReadingsToday: _currentUser.oracleReadingsToday + 1,
      );
      await _saveUser();
      notifyListeners();
    }
  }

  /// Atualiza o role do usuário (para testes/admin)
  Future<void> setUserRole(UserRole role) async {
    SubscriptionPlan plan;
    switch (role) {
      case UserRole.admin:
        plan = SubscriptionPlan.lifetime;
        break;
      case UserRole.premium:
        plan = SubscriptionPlan.monthly;
        break;
      case UserRole.free:
        plan = SubscriptionPlan.free;
        break;
    }

    _currentUser = _currentUser.copyWith(
      role: role,
      plan: plan,
    );
    await _saveUser();
    notifyListeners();
  }

  /// Atualiza dados do perfil do usuário
  Future<void> updateProfile({
    String? displayName,
    String? email,
    DateTime? birthDate,
    String? birthTime,
    String? birthPlace,
  }) async {
    _currentUser = _currentUser.copyWith(
      displayName: displayName ?? _currentUser.displayName,
      email: email ?? _currentUser.email,
      birthDate: birthDate ?? _currentUser.birthDate,
      birthTime: birthTime ?? _currentUser.birthTime,
      birthPlace: birthPlace ?? _currentUser.birthPlace,
    );
    await _saveUser();
    notifyListeners();
  }

  /// Atualiza apenas o nome do usuário
  Future<void> updateDisplayName(String name) async {
    _currentUser = _currentUser.copyWith(displayName: name);
    await _saveUser();
    notifyListeners();
  }

  /// Simula upgrade para premium (para testes - será substituído por compra real)
  Future<void> upgradeToPremium() async {
    _currentUser = _currentUser.copyWith(
      role: UserRole.premium,
      plan: SubscriptionPlan.monthly,
    );
    await _saveUser();
    notifyListeners();
  }

  /// Simula downgrade para free
  Future<void> downgradeToFree() async {
    _currentUser = _currentUser.copyWith(
      role: UserRole.free,
      plan: SubscriptionPlan.free,
    );
    await _saveUser();
    notifyListeners();
  }

  /// Ativa modo admin (para desenvolvimento)
  Future<void> activateAdminMode() async {
    _isOriginalAdmin = true;
    _currentUser = _currentUser.copyWith(
      role: UserRole.admin,
      plan: SubscriptionPlan.lifetime,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isOriginalAdminKey, true);
    await _saveUser();
    notifyListeners();
  }

  /// Reset para usuário padrão
  Future<void> resetUser() async {
    _currentUser = UserModel.defaultUser();
    await _saveUser();
    notifyListeners();
  }

  /// Limpa todos os dados (logout)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_hasSeenOnboardingKey);
    _currentUser = UserModel.defaultUser();
    _hasSeenOnboarding = false;
    notifyListeners();
  }

  /// Faz logout do usuário (mantém preferências locais)
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();

    // Mantém hasSeenOnboarding para não mostrar onboarding novamente
    // Limpa apenas dados do usuário
    await prefs.remove(_userKey);
    await prefs.remove(_isOriginalAdminKey);

    _currentUser = UserModel.defaultUser();
    _isOriginalAdmin = false;
    notifyListeners();
  }
}
