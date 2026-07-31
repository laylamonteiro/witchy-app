import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/content/content_locale.dart';

/// Strings do idioma atual sem BuildContext (modelos são usados fora da
/// árvore de widgets); o locale vem do ContentLocale, setado pelo
/// LanguageProvider.
AppLocalizations get _l10n =>
    lookupAppLocalizations(ContentLocale.instance.locale);

/// Origem da deusa
enum GoddessOrigin {
  greek,
  roman,
  celtic,
  norse,
  egyptian,
  hindu,
  brazilian,
  african,
  mesopotamian,
  japanese,
}

extension GoddessOriginExtension on GoddessOrigin {
  String get displayName {
    switch (this) {
      case GoddessOrigin.greek:
        return _l10n.goddessOriginGreek;
      case GoddessOrigin.roman:
        return _l10n.goddessOriginRoman;
      case GoddessOrigin.celtic:
        return _l10n.goddessOriginCeltic;
      case GoddessOrigin.norse:
        return _l10n.goddessOriginNorse;
      case GoddessOrigin.egyptian:
        return _l10n.goddessOriginEgyptian;
      case GoddessOrigin.hindu:
        return _l10n.goddessOriginHindu;
      case GoddessOrigin.brazilian:
        return _l10n.goddessOriginBrazilian;
      case GoddessOrigin.african:
        return _l10n.goddessOriginAfrican;
      case GoddessOrigin.mesopotamian:
        return _l10n.goddessOriginMesopotamian;
      case GoddessOrigin.japanese:
        return _l10n.goddessOriginJapanese;
    }
  }

  String get emoji {
    switch (this) {
      case GoddessOrigin.greek:
        return '🏛️';
      case GoddessOrigin.roman:
        return '🏛️';
      case GoddessOrigin.celtic:
        return '🍀';
      case GoddessOrigin.norse:
        return '⚔️';
      case GoddessOrigin.egyptian:
        return '🏺';
      case GoddessOrigin.hindu:
        return '🕉️';
      case GoddessOrigin.brazilian:
        return '🌊';
      case GoddessOrigin.african:
        return '🌍';
      case GoddessOrigin.mesopotamian:
        return '🌙';
      case GoddessOrigin.japanese:
        return '🎌';
    }
  }
}

/// Aspectos/domínios da deusa
enum GoddessAspect {
  love,
  war,
  wisdom,
  fertility,
  moon,
  sun,
  nature,
  magic,
  protection,
  healing,
  death,
  transformation,
  sea,
  harvest,
  home,
  beauty,
}

extension GoddessAspectExtension on GoddessAspect {
  String get displayName {
    switch (this) {
      case GoddessAspect.love:
        return _l10n.goddessAspectLove;
      case GoddessAspect.war:
        return _l10n.goddessAspectWar;
      case GoddessAspect.wisdom:
        return _l10n.goddessAspectWisdom;
      case GoddessAspect.fertility:
        return _l10n.goddessAspectFertility;
      case GoddessAspect.moon:
        return _l10n.goddessAspectMoon;
      case GoddessAspect.sun:
        return _l10n.goddessAspectSun;
      case GoddessAspect.nature:
        return _l10n.goddessAspectNature;
      case GoddessAspect.magic:
        return _l10n.goddessAspectMagic;
      case GoddessAspect.protection:
        return _l10n.goddessAspectProtection;
      case GoddessAspect.healing:
        return _l10n.goddessAspectHealing;
      case GoddessAspect.death:
        return _l10n.goddessAspectDeath;
      case GoddessAspect.transformation:
        return _l10n.goddessAspectTransformation;
      case GoddessAspect.sea:
        return _l10n.goddessAspectSea;
      case GoddessAspect.harvest:
        return _l10n.goddessAspectHarvest;
      case GoddessAspect.home:
        return _l10n.goddessAspectHome;
      case GoddessAspect.beauty:
        return _l10n.goddessAspectBeauty;
    }
  }

  String get emoji {
    switch (this) {
      case GoddessAspect.love:
        return '💕';
      case GoddessAspect.war:
        return '⚔️';
      case GoddessAspect.wisdom:
        return '🦉';
      case GoddessAspect.fertility:
        return '🌱';
      case GoddessAspect.moon:
        return '🌙';
      case GoddessAspect.sun:
        return '☀️';
      case GoddessAspect.nature:
        return '🌿';
      case GoddessAspect.magic:
        return '✨';
      case GoddessAspect.protection:
        return '🛡️';
      case GoddessAspect.healing:
        return '💚';
      case GoddessAspect.death:
        return '💀';
      case GoddessAspect.transformation:
        return '🦋';
      case GoddessAspect.sea:
        return '🌊';
      case GoddessAspect.harvest:
        return '🌾';
      case GoddessAspect.home:
        return '🏠';
      case GoddessAspect.beauty:
        return '🌹';
    }
  }
}

/// Modelo de Deusa
class GoddessModel {
  final String name;
  final String description;
  final GoddessOrigin origin;
  final List<GoddessAspect> aspects;
  final List<String> symbols;
  final List<String> animals;
  final List<String> plants;
  final List<String> colors;
  final String? alternateNames;
  final String correspondences;
  final List<String> ritualUses;
  final List<String> invocationTips;
  final String mythology;
  final String emoji;
  final String? imageUrl;

  const GoddessModel({
    required this.name,
    required this.description,
    required this.origin,
    required this.aspects,
    required this.symbols,
    required this.animals,
    required this.plants,
    required this.colors,
    this.alternateNames,
    required this.correspondences,
    required this.ritualUses,
    required this.invocationTips,
    required this.mythology,
    required this.emoji,
    this.imageUrl,
  });
}
