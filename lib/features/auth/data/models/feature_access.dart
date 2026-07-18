import '../../../../core/services/premium_access.dart';
import 'user_model.dart';

/// Features do aplicativo que podem ter restrições de acesso
enum AppFeature {
  // Grimório
  grimoireCreate,
  grimoireView,
  grimoireEdit,
  grimoireDelete,

  // Diários
  diaryDreamsCreate,
  diaryDreamsView,
  diaryDesiresCreate,
  diaryDesiresView,
  diaryGratitudeCreate,
  diaryGratitudeView,
  diaryAffirmationsCreate,
  diaryAffirmationsView,

  // Calendário Lunar
  lunarCalendarBasic,
  lunarCalendarDetails,

  // Enciclopédia - Acesso básico (lista)
  encyclopediaList,
  // Enciclopédia - Detalhes completos
  encyclopediaCrystalsDetails,
  encyclopediaHerbsDetails,
  encyclopediaColorsDetails,
  encyclopediaMetalsDetails,
  encyclopediaGoddessesDetails,
  encyclopediaElementsDetails,
  encyclopediaAltarDetails,

  // Astrologia
  astrologyBasic,
  astrologyBirthChart,
  astrologyMagicalProfile,
  astrologyDailyWeather,
  astrologyPersonalizedSuggestions,

  // Runas
  runesBasic,
  runesReadings,

  // Sigilos
  sigilsCreate,
  sigilsView,

  // Adivinhação
  divinationPendulum,
  divinationOracle,
  tarotReadings,
  numerologyReadings,

  // Roda do Ano
  wheelOfYearBasic,
  wheelOfYearDetails,

  // Funcionalidades de IA
  aiMysticCounselor,
  aiDreamAnalysis,
  aiPalmistry,
  aiPersonalizedDreamInterpretation,
  aiSpellSuggestions,
  aiMagicalWeather,
  interactiveMagicalLearning,

  // Diagnóstico (admin only)
  diagnosticPanel,

  // Mascote
  mascotInteraction,

  // Configurações
  settingsBasic,
  settingsAdvanced,
}

/// Janela de apuração de limites de uso.
enum LimitWindow { daily, monthly, total }

/// Definição centralizada de limite para uma feature.
class FeatureUsageLimit {
  final int limit;
  final LimitWindow window;
  final int Function(UserModel user) used;
  final String? availableMessage;
  final String blockedMessage;

  const FeatureUsageLimit({
    required this.limit,
    required this.window,
    required this.used,
    required this.blockedMessage,
    this.availableMessage,
  });

  int remainingFor(UserModel user) => limit - used(user);
}

/// Evento sem dados pessoais para analytics de acesso bloqueado.
class BlockedAccessEvent {
  final AppFeature feature;
  final AccessType accessType;
  final String reason;
  final int? limit;
  final LimitWindow? window;

  const BlockedAccessEvent({
    required this.feature,
    required this.accessType,
    required this.reason,
    this.limit,
    this.window,
  });

  Map<String, Object?> toAnalyticsParameters() => {
        'feature': feature.name,
        'access_type': accessType.name,
        'reason': reason,
        'limit': limit,
        'window': window?.name,
      };
}

typedef BlockedAccessAnalyticsHook = void Function(BlockedAccessEvent event);

/// Tipo de acesso para uma feature
enum AccessType {
  full,
  preview,
  blocked,
}

/// Resultado da verificação de acesso
class AccessResult {
  final AccessType type;
  final String? message;
  final int? remainingUses;
  final int? limit;
  final LimitWindow? limitWindow;

  const AccessResult({
    required this.type,
    this.message,
    this.remainingUses,
    this.limit,
    this.limitWindow,
  });

  bool get hasFullAccess => type == AccessType.full;
  bool get isPreview => type == AccessType.preview;
  bool get isBlocked => type == AccessType.blocked;

  factory AccessResult.full({
    int? remaining,
    int? limit,
    LimitWindow? window,
    String? message,
  }) =>
      AccessResult(
        type: AccessType.full,
        remainingUses: remaining,
        limit: limit,
        limitWindow: window,
        message: message,
      );

  factory AccessResult.preview({
    String? message,
    int? limit,
    LimitWindow? window,
  }) =>
      AccessResult(
        type: AccessType.preview,
        message: message ?? FeatureAccessMessages.preview,
        limit: limit,
        limitWindow: window,
      );

  factory AccessResult.blocked({String? message}) => AccessResult(
        type: AccessType.blocked,
        message: message ?? FeatureAccessMessages.blocked,
      );

  factory AccessResult.limited({
    required int remaining,
    required int limit,
    required LimitWindow window,
    String? message,
  }) =>
      AccessResult(
        type: remaining > 0 ? AccessType.full : AccessType.preview,
        remainingUses: remaining.clamp(0, limit).toInt(),
        limit: limit,
        limitWindow: window,
        message: message,
      );
}

/// Mensagens padronizadas para gates, previews e bloqueios.
class FeatureAccessMessages {
  static const preview = 'Conteúdo exclusivo Premium. Desbloqueie para atravessar o véu.';
  static const blocked = 'Funcionalidade indisponível para seu acesso atual.';
  static const limitReached = 'Limite gratuito atingido. Assine Premium para uso ilimitado.';
  static const adminOnly = 'Painel de diagnóstico exclusivo para administradores.';
}

/// Serviço central para consulta de acesso e limites.
class FeatureAccessService {
  FeatureAccessService({BlockedAccessAnalyticsHook? analyticsHook})
      : _analyticsHook = analyticsHook;

  static final FeatureAccessService instance = FeatureAccessService();

  BlockedAccessAnalyticsHook? _analyticsHook;

  void setBlockedAccessAnalyticsHook(BlockedAccessAnalyticsHook? hook) {
    _analyticsHook = hook;
  }

  static final FeatureUsageLimit _diaryLimit = FeatureUsageLimit(
    limit: UserModel.freeDiaryEntriesLimit,
    window: LimitWindow.monthly,
    used: (user) => user.diaryEntriesThisMonth,
    blockedMessage:
        'Você atingiu o limite de ${UserModel.freeDiaryEntriesLimit} entradas este mês. Assine Premium para registros ilimitados.',
  );

  static final FeatureUsageLimit _aiLimit = FeatureUsageLimit(
    limit: UserModel.freeAiConsultationsLimit,
    window: LimitWindow.daily,
    used: (user) => user.aiConsultationsToday,
    availableMessage: 'consulta(s) de IA hoje',
    blockedMessage:
        'Você usou suas ${UserModel.freeAiConsultationsLimit} consultas de IA hoje. Assine Premium para acesso ilimitado.',
  );

  static final Map<AppFeature, FeatureUsageLimit> limits = {
    AppFeature.grimoireCreate: FeatureUsageLimit(
      limit: UserModel.freeSpellsLimit,
      window: LimitWindow.total,
      used: (user) => user.spellsCount,
      blockedMessage: 'Você atingiu o limite de ${UserModel.freeSpellsLimit} feitiços. Assine Premium para criar ilimitados.',
    ),
    AppFeature.diaryDreamsCreate: _diaryLimit,
    AppFeature.diaryDesiresCreate: _diaryLimit,
    AppFeature.diaryGratitudeCreate: _diaryLimit,
    AppFeature.diaryAffirmationsCreate: _diaryLimit,
    AppFeature.runesReadings: FeatureUsageLimit(
      limit: UserModel.freeRuneReadingsLimit,
      window: LimitWindow.daily,
      used: (user) => user.runeReadingsToday,
      availableMessage: 'leitura(s) gratuita(s) hoje',
      blockedMessage: FeatureAccessMessages.limitReached,
    ),
    AppFeature.divinationPendulum: FeatureUsageLimit(
      limit: UserModel.dailyPendulumLimit,
      window: LimitWindow.daily,
      used: (user) => user.pendulumUsesToday,
      availableMessage: 'consulta(s) gratuita(s) hoje',
      blockedMessage: FeatureAccessMessages.limitReached,
    ),
    AppFeature.divinationOracle: FeatureUsageLimit(
      limit: UserModel.freeOracleReadingsLimit,
      window: LimitWindow.daily,
      used: (user) => user.oracleReadingsToday,
      availableMessage: 'leitura(s) gratuita(s) hoje',
      blockedMessage: FeatureAccessMessages.limitReached,
    ),
    AppFeature.tarotReadings: FeatureUsageLimit(
      limit: UserModel.freeOracleReadingsLimit,
      window: LimitWindow.daily,
      used: (user) => user.oracleReadingsToday,
      availableMessage: 'leitura(s) gratuita(s) de tarot hoje',
      blockedMessage: FeatureAccessMessages.limitReached,
    ),
    AppFeature.numerologyReadings: FeatureUsageLimit(
      limit: UserModel.freeAiConsultationsLimit,
      window: LimitWindow.daily,
      used: (user) => user.aiConsultationsToday,
      availableMessage: 'consulta(s) gratuita(s) de numerologia hoje',
      blockedMessage: FeatureAccessMessages.limitReached,
    ),
    AppFeature.aiMysticCounselor: FeatureUsageLimit(
      limit: UserModel.freeAdvisorConsultationsLimit,
      window: LimitWindow.daily,
      used: (user) => user.advisorConsultationsToday,
      availableMessage: 'consulta(s) ao Conselheiro hoje',
      blockedMessage: 'Você usou sua consulta ao Conselheiro Místico hoje. Assine Premium para consultas ilimitadas.',
    ),
    AppFeature.aiDreamAnalysis: _aiLimit,
    AppFeature.aiPalmistry: _aiLimit,
    AppFeature.aiPersonalizedDreamInterpretation: _aiLimit,
    AppFeature.aiSpellSuggestions: _aiLimit,
    AppFeature.aiMagicalWeather: _aiLimit,
    AppFeature.interactiveMagicalLearning: _aiLimit,
  };

  AccessResult checkAccess(
    AppFeature feature,
    UserModel user, {
    bool? isPremiumEffective,
    bool isOffline = false,
  }) {
    final premium = isPremiumEffective ??
        (PremiumAccess.instance.isPremium ||
            user.isPremium ||
            user.plan == SubscriptionPlan.lifetime);

    if (user.isAdmin) return AccessResult.full();
    if (premium) {
      if (feature == AppFeature.diagnosticPanel) {
        return _blocked(feature, FeatureAccessMessages.adminOnly);
      }
      return AccessResult.full();
    }

    final access = _checkFreeAccess(feature, user);
    if (!access.hasFullAccess) {
      _analyticsHook?.call(BlockedAccessEvent(
        feature: feature,
        accessType: access.type,
        reason: access.limit != null ? 'limit_reached' : 'premium_required',
        limit: access.limit,
        window: access.limitWindow,
      ));
    }
    return access;
  }

  AccessResult _blocked(AppFeature feature, String message) {
    final result = AccessResult.blocked(message: message);
    _analyticsHook?.call(BlockedAccessEvent(
      feature: feature,
      accessType: result.type,
      reason: 'blocked',
    ));
    return result;
  }

  AccessResult _checkFreeAccess(AppFeature feature, UserModel user) {
    const freeFeatures = {
      AppFeature.lunarCalendarBasic,
      AppFeature.encyclopediaList,
      AppFeature.wheelOfYearBasic,
      AppFeature.runesBasic,
      AppFeature.astrologyBasic,
      AppFeature.settingsBasic,
      AppFeature.mascotInteraction,
      AppFeature.grimoireView,
      AppFeature.grimoireEdit,
      AppFeature.grimoireDelete,
      AppFeature.diaryDreamsView,
      AppFeature.diaryDesiresView,
      AppFeature.diaryGratitudeView,
      AppFeature.diaryAffirmationsView,
    };
    if (freeFeatures.contains(feature)) return AccessResult.full();

    final limit = limits[feature];
    if (limit != null) {
      final remaining = limit.remainingFor(user);
      return AccessResult.limited(
        remaining: remaining,
        limit: limit.limit,
        window: limit.window,
        message: remaining > 0 && limit.availableMessage != null
            ? '$remaining ${limit.availableMessage}'
            : limit.blockedMessage,
      );
    }

    if (feature == AppFeature.diagnosticPanel) {
      return AccessResult.blocked(message: FeatureAccessMessages.adminOnly);
    }

    return AccessResult.preview(message: _previewMessage(feature));
  }

  String _previewMessage(AppFeature feature) {
    switch (feature) {
      case AppFeature.encyclopediaCrystalsDetails:
      case AppFeature.encyclopediaHerbsDetails:
      case AppFeature.encyclopediaColorsDetails:
      case AppFeature.encyclopediaMetalsDetails:
      case AppFeature.encyclopediaGoddessesDetails:
      case AppFeature.encyclopediaElementsDetails:
      case AppFeature.encyclopediaAltarDetails:
        return 'Desbloqueie detalhes completos da enciclopédia com o plano Premium.';
      case AppFeature.lunarCalendarDetails:
        return 'Informações detalhadas das fases lunares são exclusivas Premium.';
      case AppFeature.wheelOfYearDetails:
        return 'Rituais e celebrações detalhadas são conteúdo Premium.';
      case AppFeature.astrologyBirthChart:
      case AppFeature.astrologyMagicalProfile:
      case AppFeature.astrologyDailyWeather:
      case AppFeature.astrologyPersonalizedSuggestions:
        return 'Mapa astral completo e perfil mágico são exclusivos Premium.';
      case AppFeature.sigilsCreate:
      case AppFeature.sigilsView:
        return 'Criação de sigilos é uma funcionalidade Premium.';
      default:
        return FeatureAccessMessages.preview;
    }
  }
}

/// Sistema de controle de acesso a features.
class FeatureAccess {
  static AccessResult checkAccess(
    AppFeature feature,
    UserModel user, {
    bool? isPremiumEffective,
    bool isOffline = false,
  }) {
    return FeatureAccessService.instance.checkAccess(
      feature,
      user,
      isPremiumEffective: isPremiumEffective,
      isOffline: isOffline,
    );
  }

  static bool canViewEncyclopediaDetails(UserModel user) =>
      user.isPremium || user.isAdmin;
  static bool canUseAi(UserModel user) => user.canUseAi;
  static bool canViewDiagnostic(UserModel user) => user.isAdmin;
}
