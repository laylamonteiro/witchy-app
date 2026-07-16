import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/debug_log_service.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/services/premium_access.dart';
import '../../../../core/services/data_sync_service.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/config/supabase_config.dart';
import '../../data/models/user_model.dart';
import '../../data/models/feature_access.dart';
import '../../data/repositories/beta_code_repository.dart';
import '../../data/repositories/supabase_auth_repository.dart';

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
  ///
  /// ⚠️ ATENÇÃO: Incrementar esta versão força TODOS os usuários a verem o onboarding novamente
  /// e REMOVE suas credenciais (email, role). Use apenas para mudanças CRÍTICAS no fluxo de auth.
  ///
  /// IMPORTANTE: Esta versão NÃO afeta o banco de dados - os dados do usuário são PRESERVADOS.
  /// Usuários autenticados precisarão fazer login novamente para ver seus dados após o reset.
  ///
  /// Para atualizações normais do app: NÃO incremente esta versão.
  /// Para mudanças no onboarding que não afetam auth: considere usar outra flag.
  /// Para mudanças críticas de segurança/auth: incremente com MUITO cuidado.
  static const int _currentAuthVersion = 3;

  UserModel _currentUser = UserModel.defaultUser();
  bool _isInitialized = false;
  bool _hasSeenOnboarding = false;
  bool _isOriginalAdmin =
      false; // Mantém acesso ao painel admin ao simular outros roles
  bool _isSigningOut = false;

  UserModel get currentUser => _currentUser;
  bool get isInitialized => _isInitialized;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  /// Retorna true se o usuário é admin original (mesmo simulando outro role)
  bool get isOriginalAdmin => _isOriginalAdmin;

  // Atalhos convenientes
  bool get isAdmin => _currentUser.isAdmin;
  bool get isPremium => _currentUser.isPremium;
  bool get isFree => _currentUser.isFree;

  /// Fonte ÚNICA de verdade para acesso Premium efetivo.
  ///
  /// Combina todos os caminhos que concedem Premium:
  /// - Assinatura ativa no RevenueCat (`PaymentService.isPro`)
  /// - Role premium/admin no usuário local (inclui simulação de plano pelo admin)
  /// - Plano lifetime (concedido por Código Premium)
  ///
  /// TODOS os gates de conteúdo/funcionalidade Premium devem usar este getter
  /// (ou `PremiumAccess.isPremium(context)`), nunca `PaymentService.isPro` ou
  /// `isPremium` isoladamente.
  bool get isPremiumEffective =>
      PaymentService().isPro ||
      _currentUser.isPremium ||
      _currentUser.plan == SubscriptionPlan.lifetime;

  @override
  void notifyListeners() {
    // Mantém o singleton PremiumAccess (usado por serviços sem BuildContext,
    // como o sync) sempre alinhado ao estado do usuário.
    PremiumAccess.instance.updateLocalPremium(
      _currentUser.isPremium || _currentUser.plan == SubscriptionPlan.lifetime,
    );
    super.notifyListeners();
  }

  /// Inicializa o provider carregando dados salvos
  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();

    // Verificar versão do fluxo de autenticação
    // Se a versão mudou, resetar o estado de onboarding e usuário
    final savedAuthVersion = prefs.getInt(_authVersionKey) ?? 0;
    await debugLog('AUTH',
        'savedVersion=$savedAuthVersion, currentVersion=$_currentAuthVersion');

    if (savedAuthVersion < _currentAuthVersion) {
      // ⚠️ Auth version mudou - resetar credenciais mas PRESERVAR banco de dados
      await debugLog('AUTH',
          'AUTH VERSION UPDATE - resetting credentials but preserving database');
      await debugLog('AUTH',
          'Old version: $savedAuthVersion, New version: $_currentAuthVersion');

      // Remove apenas credenciais de autenticação (SharedPreferences)
      // ✅ BANCO DE DADOS É PRESERVADO - dados não são perdidos!
      await prefs.remove(_hasSeenOnboardingKey);
      await prefs.remove(_userKey);
      await prefs.remove(_isOriginalAdminKey);
      await prefs.setInt(_authVersionKey, _currentAuthVersion);

      _hasSeenOnboarding = false;
      _isOriginalAdmin = false;
      _currentUser = UserModel.defaultUser();
      _isInitialized = true;

      await debugLog('AUTH',
          'RESET COMPLETE - User credentials cleared, database preserved');
      await debugLog('AUTH',
          'User is now anonymous - authenticated users must login again to access their data');
      notifyListeners();
      return;
    }

    // Verificar se já viu onboarding
    _hasSeenOnboarding = prefs.getBool(_hasSeenOnboardingKey) ?? false;
    await debugLog('AUTH', 'hasSeenOnboarding=$_hasSeenOnboarding');

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

    // Registrar callback com PaymentService para sincronizar status Premium
    _registerPaymentServiceCallback();

    // Verificar se assinatura expirou (exceto para Códigos Premium lifetime e admin)
    await _checkSubscriptionExpiration();

    _isInitialized = true;
    notifyListeners();
  }

  /// Registra callback com PaymentService para sincronizar UserRole com status de assinatura
  void _registerPaymentServiceCallback() {
    final paymentService = PaymentService();
    paymentService.setProStatusChangedCallback((isPro) {
      _onPaymentStatusChanged(isPro);
    });
    debugPrint(
        '✅ AuthProvider registrado para receber updates do PaymentService');
  }

  /// Chamado quando o status Pro muda no PaymentService (ex: cancelamento, reembolso)
  Future<void> _onPaymentStatusChanged(bool isPro) async {
    await debugLog('AUTH', 'PaymentService notificou mudança: isPro=$isPro');

    if (_isSigningOut) {
      await debugLog(
          'AUTH', 'Update do PaymentService ignorado durante logout');
      return;
    }

    // Não alterar role de admin original (mesmo que perca assinatura)
    if (_isOriginalAdmin || _currentUser.isAdmin) {
      await debugLog('AUTH', 'Usuário é admin original - mantendo role');
      return;
    }

    // Atualizar role baseado no status da assinatura
    if (isPro) {
      await debugLog('AUTH', 'Atualizando para Premium');
      final paymentService = PaymentService();
      final isLifetime = paymentService.isLifetime;
      _currentUser = _currentUser.copyWith(
        role: UserRole.premium,
        plan: isLifetime ? SubscriptionPlan.lifetime : SubscriptionPlan.monthly,
      );
    } else {
      // Não fazer downgrade de usuários com acesso lifetime (Código Premium):
      // o RevenueCat não conhece esse plano, então isPro=false é esperado.
      // Mesma regra de _checkSubscriptionExpiration e refreshPremiumStatus.
      if (_currentUser.plan == SubscriptionPlan.lifetime) {
        await debugLog('AUTH',
            'Usuário lifetime (Código Premium) - ignorando downgrade do RevenueCat');
        return;
      }
      await debugLog(
          'AUTH', 'Revertendo para Free (assinatura cancelada/reembolsada)');
      _currentUser = _currentUser.copyWith(
        role: UserRole.free,
        plan: SubscriptionPlan.free,
      );
    }

    await _saveUser();
    notifyListeners();
    await debugLog('AUTH', 'UserRole atualizado com sucesso');
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

  /// Chave de prefs ESCOPADA POR USUÁRIO.
  ///
  /// Controles de "1x por dia" (resets de contadores, balão do mascote)
  /// precisam ser por conta: com chave global, deslogar da conta X e logar
  /// na conta Y no mesmo dia fazia a conta Y herdar o estado do dia da
  /// conta X (bug reportado no balão do gatinho).
  String _scopedKey(String base) => '${base}_${_currentUser.id}';

  /// Verifica e reseta contadores diários/mensais se necessário
  Future<void> _checkAndResetCounters() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    bool needsSave = false;

    final aiKey = _scopedKey(_lastAiResetKey);
    final diaryKey = _scopedKey(_lastDiaryResetKey);
    final pendulumKey = _scopedKey(_lastPendulumResetKey);
    final dailyLimitsKey = _scopedKey(_lastDailyLimitsResetKey);

    // Reset diário de IA
    final lastAiReset = prefs.getString(aiKey);
    if (lastAiReset != null) {
      final lastDate = DateTime.parse(lastAiReset);
      if (now.day != lastDate.day ||
          now.month != lastDate.month ||
          now.year != lastDate.year) {
        _currentUser = _currentUser.copyWith(aiConsultationsToday: 0);
        await prefs.setString(aiKey, now.toIso8601String());
        needsSave = true;
      }
    } else {
      await prefs.setString(aiKey, now.toIso8601String());
    }

    // Reset mensal de diários
    final lastDiaryReset = prefs.getString(diaryKey);
    if (lastDiaryReset != null) {
      final lastDate = DateTime.parse(lastDiaryReset);
      if (now.month != lastDate.month || now.year != lastDate.year) {
        _currentUser = _currentUser.copyWith(diaryEntriesThisMonth: 0);
        await prefs.setString(diaryKey, now.toIso8601String());
        needsSave = true;
      }
    } else {
      await prefs.setString(diaryKey, now.toIso8601String());
    }

    // Reset diário do pêndulo (para TODOS os usuários)
    final lastPendulumReset = prefs.getString(pendulumKey);
    if (lastPendulumReset != null) {
      final lastDate = DateTime.parse(lastPendulumReset);
      if (now.day != lastDate.day ||
          now.month != lastDate.month ||
          now.year != lastDate.year) {
        _currentUser = _currentUser.copyWith(pendulumUsesToday: 0);
        await prefs.setString(pendulumKey, now.toIso8601String());
        needsSave = true;
      }
    } else {
      await prefs.setString(pendulumKey, now.toIso8601String());
    }

    // Reset diário dos novos limites (afirmações, runas, oracle)
    final lastDailyLimitsReset = prefs.getString(dailyLimitsKey);
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
        await prefs.setString(dailyLimitsKey, now.toIso8601String());
        needsSave = true;
      }
    } else {
      await prefs.setString(dailyLimitsKey, now.toIso8601String());
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
  ///
  /// Comportamento de planos:
  /// - Free: plano free
  /// - Premium (admin testando): monthly (simula assinatura RevenueCat)
  /// - Premium (Código Premium): lifetime (preservado)
  /// - Admin: lifetime (acesso total)
  Future<void> setUserRole(UserRole role) async {
    SubscriptionPlan plan;
    switch (role) {
      case UserRole.admin:
        // Admin sempre tem lifetime
        plan = SubscriptionPlan.lifetime;
        break;
      case UserRole.premium:
        // Se é admin original testando Premium → monthly (simula assinatura)
        // Se é usuário com Código Premium → preserva lifetime
        if (_isOriginalAdmin) {
          // Admin testando como Premium: simular assinatura via RevenueCat
          plan = SubscriptionPlan.monthly;
        } else {
          // Usuário normal: preservar lifetime se já existir (Código Premium)
          plan = _currentUser.plan == SubscriptionPlan.lifetime
              ? SubscriptionPlan.lifetime
              : SubscriptionPlan.monthly;
        }
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

  /// Substitui o estado local pelos dados autenticados vindos do servidor.
  Future<void> syncAuthenticatedUser(UserModel user) async {
    _isSigningOut = false;
    await DatabaseHelper.instance.claimLegacyData(user.id);
    _currentUser = user;
    _isOriginalAdmin = user.isAdmin;

    // Contadores diários são por conta (chaves escopadas por usuário):
    // garante que o dia "vire" corretamente para ESTA conta ao logar
    await _checkAndResetCounters();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isOriginalAdminKey, _isOriginalAdmin);
    await _saveUser();
    _registerPaymentServiceCallback();

    // O sync precisa reconhecer Premium antes de o novo usuário ser
    // publicado aos providers da interface.
    PremiumAccess.instance.updateLocalPremium(
      _currentUser.isPremium || _currentUser.plan == SubscriptionPlan.lifetime,
    );

    await PaymentService().logIn(user.id);
    await debugLog(
      'AUTH',
      'Usuário sincronizado do servidor: id=${user.id}, role=${user.role.name}, plan=${user.plan.name}',
    );

    // Só libera a Home depois de o SQLite receber os dados remotos. Assim, os
    // providers fazem a primeira leitura já sobre a base sincronizada.
    await _autoSyncAfterLogin();
    notifyListeners();
  }

  /// Dispara uma sincronização completa (upload+download) logo após o login,
  /// se o usuário for Premium e a sincronização estiver habilitada.
  Future<void> _autoSyncAfterLogin() async {
    try {
      if (!PremiumAccess.instance.isPremium) return;
      final sync = DataSyncService();
      final syncEnabled = await sync.cloudSyncEnabled;
      if (!syncEnabled || !sync.isReady) return;

      await debugLog('SYNC', 'Auto-sync pós-login iniciado');
      final result = await sync.syncAll();
      await debugLog('SYNC',
          'Auto-sync pós-login: ${result.success ? "ok" : "falha: ${result.error}"}');
    } catch (error) {
      // Falha de nuvem não deve impedir o login nem o acesso aos dados locais.
      await debugLog('SYNC', 'Auto-sync pós-login falhou: $error');
    }
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

  /// Verifica se a assinatura expirou e faz downgrade se necessário
  Future<void> _checkSubscriptionExpiration() async {
    // Não verificar para admin ou usuários free
    if (_isOriginalAdmin || _currentUser.role == UserRole.free) {
      return;
    }

    // Não verificar para Códigos Premium (lifetime)
    if (_currentUser.plan == SubscriptionPlan.lifetime) {
      await debugLog('AUTH',
          'Usuário tem acesso lifetime (Código Premium) - não verifica expiração');
      return;
    }

    // Para assinaturas monthly/yearly, verificar com PaymentService
    final paymentService = PaymentService();
    if (!paymentService.isInitialized) {
      await paymentService.initialize();
    }

    // Se PaymentService diz que não é Pro, fazer downgrade
    if (!paymentService.isPro && _currentUser.role == UserRole.premium) {
      await debugLog(
          'AUTH', 'Assinatura expirou - fazendo downgrade para Free');
      _currentUser = _currentUser.copyWith(
        role: UserRole.free,
        plan: SubscriptionPlan.free,
      );
      await _saveUser();
      notifyListeners();
    }
  }

  /// Atualiza o status premium baseado no PaymentService (RevenueCat)
  Future<void> refreshPremiumStatus() async {
    if (_isSigningOut) {
      await debugLog('AUTH', 'refreshPremiumStatus ignorado durante logout');
      return;
    }

    final paymentService = PaymentService();

    if (!paymentService.isInitialized) {
      await paymentService.initialize();
    }

    if (paymentService.isPro) {
      // Usuário tem assinatura ativa
      final isLifetime = paymentService.isLifetime;
      _currentUser = _currentUser.copyWith(
        role: UserRole.premium,
        plan: isLifetime ? SubscriptionPlan.lifetime : SubscriptionPlan.monthly,
      );
      await _saveUser();
      notifyListeners();
    } else if (!_isOriginalAdmin &&
        _currentUser.plan != SubscriptionPlan.lifetime) {
      // Se não é mais Pro, não é admin e não tem lifetime (Código Premium), fazer downgrade
      await debugLog('AUTH',
          'Assinatura não está mais ativa - fazendo downgrade para Free');
      _currentUser = _currentUser.copyWith(
        role: UserRole.free,
        plan: SubscriptionPlan.free,
      );
      await _saveUser();
      notifyListeners();
    }
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
    if (_isSigningOut) return;

    _isSigningOut = true;
    // Após o logout, o callback fica anulado e PaymentService.logOut() zera
    // isPro — a fonte única (isPremiumEffective) volta a false naturalmente,
    // sem precisar de flag paralela.
    PaymentService().setProStatusChangedCallback(null);
    PremiumAccess.instance.updateLocalPremium(false);
    final paymentLogout = PaymentService().logOut();

    final prefs = await SharedPreferences.getInstance();

    // Verificar se o usuário tem sincronização na nuvem
    // Usuários com cloud sync = autenticados (email != null) E premium
    final hasCloudSync = _currentUser.email != null && _currentUser.isPremium;
    final isAnonymous = _currentUser.id == 'local_user';

    await debugLog('AUTH',
        'signOut - userId=${_currentUser.id}, hasCloudSync=$hasCloudSync, isAnonymous=$isAnonymous');

    if (SupabaseConfig.isConfigured) {
      final authRepository = SupabaseAuthRepository();
      try {
        await authRepository.signOut();
      } catch (e) {
        await debugLog(
            'AUTH', 'Logout remoto falhou; continuando limpeza local: $e');
      } finally {
        authRepository.dispose();
      }
    }

    await paymentLogout;

    // Regras de limpeza de dados:
    // 1. Usuário anônimo (local_user): SEMPRE limpar (evita que próximo usuário anônimo veja os dados)
    // 2. Usuário autenticado SEM cloud sync: limpar dados
    // 3. Usuário autenticado COM cloud sync: manter dados (serão sincronizados ao fazer login novamente)
    final shouldClearData = isAnonymous || !hasCloudSync;

    if (shouldClearData) {
      await debugLog('AUTH',
          'Clearing database - reason: ${isAnonymous ? "anonymous user" : "no cloud sync"}');
      try {
        await DatabaseHelper.instance.clearAllTables();
        await debugLog('AUTH', 'Database cleared successfully');
      } catch (e) {
        await debugLog('AUTH', 'Error clearing database: $e');
      }
    } else {
      await debugLog('AUTH', 'Keeping database - user has cloud sync enabled');
    }

    // Mantém hasSeenOnboarding para não mostrar onboarding novamente
    // Limpa apenas dados do usuário
    await prefs.remove(_userKey);
    await prefs.remove(_isOriginalAdminKey);
    await prefs.remove('is_authenticated');
    await prefs.remove('profile_photo_path');

    _currentUser = UserModel.defaultUser();
    _isOriginalAdmin = false;
    notifyListeners();
    _isSigningOut = false;
    await debugLog('AUTH', 'Logout concluído; estado local resetado');
  }

  // ============================================================
  // BETA CODES - Sistema de códigos promocionais com sync na nuvem
  // ============================================================

  final BetaCodeRepository _betaCodeRepo = BetaCodeRepository();

  /// Valida e resgata um Código Premium
  /// Funciona entre dispositivos via Supabase
  Future<Map<String, dynamic>> redeemBetaCode(String code) async {
    try {
      await debugLog('BETA_CODE', 'Tentando resgatar código: $code');

      // Usar repositório que sincroniza com Supabase
      final result = await _betaCodeRepo.redeemCode(code, _currentUser.id);

      if (result['success'] == true) {
        // Atualizar usuário para Premium vitalício
        _currentUser = _currentUser.copyWith(
          role: UserRole.premium,
          plan: SubscriptionPlan.lifetime,
        );

        await _saveUser();
        notifyListeners();

        await debugLog('BETA_CODE',
            'Código resgatado com sucesso - usuário agora é Premium vitalício');
      } else {
        await debugLog('BETA_CODE', 'Falha ao resgatar: ${result['message']}');
      }

      return result;
    } catch (e) {
      await debugLog('BETA_CODE', 'Erro ao resgatar código: $e');
      return {
        'success': false,
        'message': 'Erro ao processar código: $e',
      };
    }
  }

  /// Cria um novo Código Premium (apenas para admin)
  /// Sincroniza com Supabase para funcionar entre dispositivos
  ///
  /// [code] - Código a ser criado
  /// [maxUses] - Número máximo de usos permitidos (padrão: 1)
  Future<String?> createBetaCode(String code, {int maxUses = 1}) async {
    if (!isAdmin && !_isOriginalAdmin) {
      await debugLog('BETA_CODE', 'Apenas admins podem criar Códigos Premium');
      return null;
    }

    try {
      final cleanCode = code.trim().toUpperCase();

      // Usar repositório que sincroniza com Supabase
      final success =
          await _betaCodeRepo.createCode(cleanCode, maxUses: maxUses);

      if (success) {
        await debugLog('BETA_CODE',
            'Código Premium criado: $cleanCode (max_uses: $maxUses)');
        return cleanCode;
      } else {
        await debugLog('BETA_CODE', 'Erro ao criar Código Premium');
        return null;
      }
    } catch (e) {
      await debugLog('BETA_CODE', 'Erro ao criar Código Premium: $e');
      return null;
    }
  }
}
