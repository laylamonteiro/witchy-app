import '../../../../core/content/content_locale.dart';
import '../../../../l10n/generated/app_localizations.dart';
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
  encyclopediaArcaneDetails,

  // Astrologia
  astrologyBasic,
  astrologyBirthChart,
  astrologyMagicalProfile,
  astrologyDailyWeather,
  astrologyPersonalizedSuggestions,

  // Ciclos — Suas Eras
  /// A Era e a Fase de agora: abertas para todo mundo.
  lifeErasNow,

  /// Passado, futuro e as leituras completas: Premium.
  lifeErasFull,

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

  // Rituais guiados — Premium por inteiro (página de conteúdo e player;
  // free vê o paywall ao abrir)
  guidedRitualPlayer,

  // Conhecimento de bruxaria solar (página Sol) — Premium com preview
  sunKnowledge,

  // Enciclopédia pessoal (entradas criadas pela usuária com foto + IA)
  encyclopediaPersonalEntries,

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

/// Localizações resolvidas no idioma atual sem BuildContext (mesmo padrão
/// do NotificationService) — mensagens são lidas a cada acesso, então a
/// troca de idioma em runtime reflete imediatamente.
AppLocalizations get _l10n =>
    lookupAppLocalizations(ContentLocale.instance.locale);

/// Mensagens padronizadas para gates, previews e bloqueios.
class FeatureAccessMessages {
  static String get preview => _l10n.featureAccessPreview;
  static String get blocked => _l10n.featureAccessBlocked;
  static String get limitReached => _l10n.featureAccessLimitReached;
  static String get adminOnly => _l10n.featureAccessAdminOnly;
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

  static FeatureUsageLimit get _diaryLimit => FeatureUsageLimit(
        limit: UserModel.freeDiaryEntriesLimit,
        window: LimitWindow.monthly,
        used: (user) => user.diaryEntriesThisMonth,
        blockedMessage:
            _l10n.featureLimitDiaryBlocked(UserModel.freeDiaryEntriesLimit),
      );

  static FeatureUsageLimit get _aiLimit => FeatureUsageLimit(
        limit: UserModel.freeAiConsultationsLimit,
        window: LimitWindow.daily,
        used: (user) => user.aiConsultationsToday,
        availableMessage: _l10n.featureLimitAiAvailable,
        blockedMessage:
            _l10n.featureLimitAiBlocked(UserModel.freeAiConsultationsLimit),
      );

  static Map<AppFeature, FeatureUsageLimit> get limits => {
    AppFeature.grimoireCreate: FeatureUsageLimit(
      limit: UserModel.freeSpellsLimit,
      window: LimitWindow.total,
      used: (user) => user.spellsCount,
      blockedMessage:
          _l10n.featureLimitSpellsBlocked(UserModel.freeSpellsLimit),
    ),
    AppFeature.diaryDreamsCreate: _diaryLimit,
    AppFeature.diaryDesiresCreate: _diaryLimit,
    AppFeature.diaryGratitudeCreate: _diaryLimit,
    AppFeature.diaryAffirmationsCreate: _diaryLimit,
    AppFeature.runesReadings: FeatureUsageLimit(
      limit: UserModel.freeRuneReadingsLimit,
      window: LimitWindow.daily,
      used: (user) => user.runeReadingsToday,
      availableMessage: _l10n.featureLimitReadingsAvailable,
      blockedMessage: FeatureAccessMessages.limitReached,
    ),
    AppFeature.divinationPendulum: FeatureUsageLimit(
      limit: UserModel.dailyPendulumLimit,
      window: LimitWindow.daily,
      used: (user) => user.pendulumUsesToday,
      availableMessage: _l10n.featureLimitConsultAvailable,
      blockedMessage: FeatureAccessMessages.limitReached,
    ),
    AppFeature.divinationOracle: FeatureUsageLimit(
      limit: UserModel.freeOracleReadingsLimit,
      window: LimitWindow.daily,
      used: (user) => user.oracleReadingsToday,
      availableMessage: _l10n.featureLimitReadingsAvailable,
      blockedMessage: FeatureAccessMessages.limitReached,
    ),
    AppFeature.tarotReadings: FeatureUsageLimit(
      limit: UserModel.freeOracleReadingsLimit,
      window: LimitWindow.daily,
      used: (user) => user.oracleReadingsToday,
      availableMessage: _l10n.featureLimitTarotAvailable,
      blockedMessage: FeatureAccessMessages.limitReached,
    ),
    // numerologyReadings (explicação do Conselheiro Místico) é exclusiva
    // Premium: fora do mapa de limites, o plano Free recebe preview -> paywall.
    AppFeature.aiMysticCounselor: FeatureUsageLimit(
      limit: UserModel.freeAdvisorConsultationsLimit,
      window: LimitWindow.daily,
      used: (user) => user.advisorConsultationsToday,
      availableMessage: _l10n.featureLimitCounselorAvailable,
      blockedMessage: _l10n.featureLimitCounselorBlocked,
    ),
    AppFeature.aiDreamAnalysis: _aiLimit,
    // aiPalmistry e aiPersonalizedDreamInterpretation são exclusivas Premium:
    // fora do mapa de limites, o plano Free recebe preview -> paywall.
    AppFeature.aiSpellSuggestions: _aiLimit,
    AppFeature.aiMagicalWeather: _aiLimit,
    // interactiveMagicalLearning (Grimorio Vivo alem da licao 1) e exclusiva
    // Premium: fora do mapa, o Free recebe preview -> paywall.
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
      // A Era e a Fase correntes são a isca da feature: sem elas abertas,
      // ninguém descobre que existem 120 anos de linha do tempo por trás.
      AppFeature.lifeErasNow,
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
      case AppFeature.encyclopediaArcaneDetails:
        return _l10n.featurePreviewEncyclopedia;
      case AppFeature.lunarCalendarDetails:
        return _l10n.featurePreviewLunar;
      case AppFeature.wheelOfYearDetails:
        return _l10n.featurePreviewWheel;
      case AppFeature.astrologyBirthChart:
      case AppFeature.astrologyMagicalProfile:
      case AppFeature.astrologyDailyWeather:
      case AppFeature.astrologyPersonalizedSuggestions:
        return _l10n.featurePreviewAstrology;
      case AppFeature.lifeErasFull:
        return _l10n.featurePreviewCycles;
      case AppFeature.sigilsCreate:
      case AppFeature.sigilsView:
        return _l10n.featurePreviewSigils;
      case AppFeature.aiPersonalizedDreamInterpretation:
        return _l10n.featurePreviewDreams;
      case AppFeature.numerologyReadings:
        return _l10n.featurePreviewNumerology;
      case AppFeature.interactiveMagicalLearning:
        return _l10n.featurePreviewLearning;
      case AppFeature.aiPalmistry:
        return _l10n.featurePreviewPalmistry;
      case AppFeature.guidedRitualPlayer:
        return _l10n.featurePreviewGuidedRituals;
      case AppFeature.sunKnowledge:
        return _l10n.featurePreviewEncyclopedia;
      case AppFeature.encyclopediaPersonalEntries:
        return _l10n.featurePreviewPersonalEncyclopedia;
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
