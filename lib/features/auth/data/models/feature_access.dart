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

  // Roda do Ano
  wheelOfYearBasic,
  wheelOfYearDetails,

  // Funcionalidades de IA
  aiMysticCounselor,
  aiDreamAnalysis,
  aiSpellSuggestions,
  aiMagicalWeather,

  // Diagnóstico (admin only)
  diagnosticPanel,

  // Mascote
  mascotInteraction,

  // Configurações
  settingsBasic,
  settingsAdvanced,
}

/// Tipo de acesso para uma feature
enum AccessType {
  /// Acesso total
  full,

  /// Acesso com limite (preview com blur)
  preview,

  /// Sem acesso (bloqueado)
  blocked,
}

/// Resultado da verificação de acesso
class AccessResult {
  final AccessType type;
  final String? message;
  final int? remainingUses;
  final int? limit;

  const AccessResult({
    required this.type,
    this.message,
    this.remainingUses,
    this.limit,
  });

  bool get hasFullAccess => type == AccessType.full;
  bool get isPreview => type == AccessType.preview;
  bool get isBlocked => type == AccessType.blocked;

  factory AccessResult.full() => const AccessResult(type: AccessType.full);

  factory AccessResult.preview({String? message}) => AccessResult(
        type: AccessType.preview,
        message: message ?? 'Conteúdo exclusivo para assinantes',
      );

  factory AccessResult.blocked({String? message}) => AccessResult(
        type: AccessType.blocked,
        message: message ?? 'Funcionalidade bloqueada',
      );

  factory AccessResult.limited({
    required int remaining,
    required int limit,
    String? message,
  }) =>
      AccessResult(
        type: remaining > 0 ? AccessType.full : AccessType.preview,
        remainingUses: remaining,
        limit: limit,
        message: message,
      );
}

/// Sistema de controle de acesso a features
class FeatureAccess {
  /// Verifica o acesso a uma feature baseado no usuário
  static AccessResult checkAccess(AppFeature feature, UserModel user) {
    // Admin tem acesso total a tudo
    if (user.isAdmin) {
      return AccessResult.full();
    }

    // Premium tem acesso a quase tudo, exceto diagnóstico
    if (user.isPremium) {
      if (feature == AppFeature.diagnosticPanel) {
        return AccessResult.blocked(
          message: 'Painel de diagnóstico exclusivo para administradores',
        );
      }
      return AccessResult.full();
    }

    // Usuário free - verificar cada feature
    return _checkFreeAccess(feature, user);
  }

  /// Verifica acesso para usuários free
  static AccessResult _checkFreeAccess(AppFeature feature, UserModel user) {
    switch (feature) {
      // === ACESSO TOTAL PARA FREE ===

      // Calendário Lunar básico
      case AppFeature.lunarCalendarBasic:
        return AccessResult.full();

      // Enciclopédia - lista é gratuita
      case AppFeature.encyclopediaList:
        return AccessResult.full();

      // Roda do Ano básico
      case AppFeature.wheelOfYearBasic:
        return AccessResult.full();

      // Runas básico
      case AppFeature.runesBasic:
        return AccessResult.full();

      // Astrologia básico (signos)
      case AppFeature.astrologyBasic:
        return AccessResult.full();

      // Configurações básicas
      case AppFeature.settingsBasic:
        return AccessResult.full();

      // Mascote
      case AppFeature.mascotInteraction:
        return AccessResult.full();

      // === ACESSO COM LIMITE ===

      // Grimório - limite de 10 feitiços
      case AppFeature.grimoireCreate:
        if (user.spellsCount >= UserModel.freeSpellsLimit) {
          return AccessResult.limited(
            remaining: 0,
            limit: UserModel.freeSpellsLimit,
            message:
                'Você atingiu o limite de ${UserModel.freeSpellsLimit} feitiços. Assine para criar ilimitados!',
          );
        }
        return AccessResult.limited(
          remaining: UserModel.freeSpellsLimit - user.spellsCount,
          limit: UserModel.freeSpellsLimit,
        );

      case AppFeature.grimoireView:
      case AppFeature.grimoireEdit:
      case AppFeature.grimoireDelete:
        return AccessResult.full();

      // Diários - limite de 30 entradas por mês
      case AppFeature.diaryDreamsCreate:
      case AppFeature.diaryDesiresCreate:
      case AppFeature.diaryGratitudeCreate:
      case AppFeature.diaryAffirmationsCreate:
        if (user.diaryEntriesThisMonth >= UserModel.freeDiaryEntriesLimit) {
          return AccessResult.limited(
            remaining: 0,
            limit: UserModel.freeDiaryEntriesLimit,
            message:
                'Você atingiu o limite de ${UserModel.freeDiaryEntriesLimit} entradas este mês. Assine para registros ilimitados!',
          );
        }
        return AccessResult.limited(
          remaining: UserModel.freeDiaryEntriesLimit - user.diaryEntriesThisMonth,
          limit: UserModel.freeDiaryEntriesLimit,
        );

      case AppFeature.diaryDreamsView:
      case AppFeature.diaryDesiresView:
      case AppFeature.diaryGratitudeView:
      case AppFeature.diaryAffirmationsView:
        return AccessResult.full();

      // === PREVIEW (BLUR) PARA FREE ===

      // Enciclopédia detalhada - preview com blur
      case AppFeature.encyclopediaCrystalsDetails:
      case AppFeature.encyclopediaHerbsDetails:
      case AppFeature.encyclopediaColorsDetails:
      case AppFeature.encyclopediaMetalsDetails:
      case AppFeature.encyclopediaGoddessesDetails:
      case AppFeature.encyclopediaElementsDetails:
      case AppFeature.encyclopediaAltarDetails:
        return AccessResult.preview(
          message: 'Desbloqueie detalhes completos da enciclopédia com o plano Premium',
        );

      // Calendário Lunar detalhado - preview
      case AppFeature.lunarCalendarDetails:
        return AccessResult.preview(
          message: 'Informações detalhadas das fases lunares são exclusivas Premium',
        );

      // Roda do Ano detalhes - preview
      case AppFeature.wheelOfYearDetails:
        return AccessResult.preview(
          message: 'Rituais e celebrações detalhadas são conteúdo Premium',
        );

      // Astrologia avançada - preview
      case AppFeature.astrologyBirthChart:
      case AppFeature.astrologyMagicalProfile:
      case AppFeature.astrologyDailyWeather:
      case AppFeature.astrologyPersonalizedSuggestions:
        return AccessResult.preview(
          message: 'Mapa astral completo e perfil mágico são exclusivos Premium',
        );

      // Runas leituras - preview
      case AppFeature.runesReadings:
        return AccessResult.preview(
          message: 'Leituras de runas são exclusivas para assinantes',
        );

      // Sigilos - preview
      case AppFeature.sigilsCreate:
      case AppFeature.sigilsView:
        return AccessResult.preview(
          message: 'Criação de sigilos é uma funcionalidade Premium',
        );

      // Adivinhação - preview
      case AppFeature.divinationPendulum:
      case AppFeature.divinationOracle:
        return AccessResult.preview(
          message: 'Ferramentas de adivinhação são exclusivas Premium',
        );

      // === BLOQUEADO PARA FREE (IA) ===

      // Funcionalidades de IA - limite de 3 por dia
      case AppFeature.aiMysticCounselor:
      case AppFeature.aiDreamAnalysis:
      case AppFeature.aiSpellSuggestions:
      case AppFeature.aiMagicalWeather:
        if (user.aiConsultationsToday >= UserModel.freeAiConsultationsLimit) {
          return AccessResult.preview(
            message:
                'Você usou suas ${UserModel.freeAiConsultationsLimit} consultas de IA hoje. Assine para acesso ilimitado!',
          );
        }
        return AccessResult.limited(
          remaining: user.remainingAiConsultations,
          limit: UserModel.freeAiConsultationsLimit,
          message:
              'Restam ${user.remainingAiConsultations} consultas de IA hoje',
        );

      // === BLOQUEADO (ADMIN ONLY) ===

      case AppFeature.diagnosticPanel:
        return AccessResult.blocked(
          message: 'Painel de diagnóstico exclusivo para administradores',
        );

      // Configurações avançadas
      case AppFeature.settingsAdvanced:
        return AccessResult.preview(
          message: 'Configurações avançadas são exclusivas Premium',
        );
    }
  }

  /// Verifica se o usuário pode acessar conteúdo da enciclopédia detalhado
  static bool canViewEncyclopediaDetails(UserModel user) {
    return user.isPremium || user.isAdmin;
  }

  /// Verifica se o usuário pode usar IA
  static bool canUseAi(UserModel user) {
    return user.canUseAi;
  }

  /// Verifica se o usuário pode ver o diagnóstico
  static bool canViewDiagnostic(UserModel user) {
    return user.isAdmin;
  }
}
