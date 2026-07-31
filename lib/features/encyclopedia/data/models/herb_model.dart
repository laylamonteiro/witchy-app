import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/content/content_locale.dart';

/// Strings do idioma atual sem BuildContext (modelos são usados fora da
/// árvore de widgets); o locale vem do ContentLocale, setado pelo
/// LanguageProvider.
AppLocalizations get _l10n =>
    lookupAppLocalizations(ContentLocale.instance.locale);

enum HerbElement {
  earth,
  water,
  air,
  fire,
}

enum Planet {
  sun,
  moon,
  mercury,
  venus,
  mars,
  jupiter,
  saturn,
}

extension HerbElementExtension on HerbElement {
  String get displayName {
    switch (this) {
      case HerbElement.earth:
        return _l10n.elementEarth;
      case HerbElement.water:
        return _l10n.elementWater;
      case HerbElement.air:
        return _l10n.elementAir;
      case HerbElement.fire:
        return _l10n.elementFire;
    }
  }

  String get emoji {
    switch (this) {
      case HerbElement.earth:
        return '🌍';
      case HerbElement.water:
        return '💧';
      case HerbElement.air:
        return '🌬️';
      case HerbElement.fire:
        return '🔥';
    }
  }
}

extension PlanetExtension on Planet {
  String get displayName {
    switch (this) {
      case Planet.sun:
        return _l10n.planetSun;
      case Planet.moon:
        return _l10n.planetMoon;
      case Planet.mercury:
        return _l10n.planetMercury;
      case Planet.venus:
        return _l10n.planetVenus;
      case Planet.mars:
        return _l10n.planetMars;
      case Planet.jupiter:
        return _l10n.planetJupiter;
      case Planet.saturn:
        return _l10n.planetSaturn;
    }
  }

  String get emoji {
    switch (this) {
      case Planet.sun:
        return '☀️';
      case Planet.moon:
        return '🌙';
      case Planet.mercury:
        return '☿️';
      case Planet.venus:
        return '♀️';
      case Planet.mars:
        return '♂️';
      case Planet.jupiter:
        return '♃';
      case Planet.saturn:
        return '♄';
    }
  }
}

class HerbModel {
  final String name;
  final String scientificName;
  final String description;
  final HerbElement element;
  final Planet planet;
  final List<String> magicalProperties;
  final List<String> ritualUses;
  final List<String> safetyWarnings;
  final bool edible;
  final bool toxic;
  final String? folkNames; // Nomes populares
  final String? imageUrl; // URL da imagem da erva

  const HerbModel({
    required this.name,
    required this.scientificName,
    required this.description,
    required this.element,
    required this.planet,
    required this.magicalProperties,
    required this.ritualUses,
    this.safetyWarnings = const [],
    this.edible = false,
    this.toxic = false,
    this.folkNames,
    this.imageUrl,
  });
}
