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
        return 'Terra';
      case HerbElement.water:
        return 'Água';
      case HerbElement.air:
        return 'Ar';
      case HerbElement.fire:
        return 'Fogo';
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
        return 'Sol';
      case Planet.moon:
        return 'Lua';
      case Planet.mercury:
        return 'Mercúrio';
      case Planet.venus:
        return 'Vênus';
      case Planet.mars:
        return 'Marte';
      case Planet.jupiter:
        return 'Júpiter';
      case Planet.saturn:
        return 'Saturno';
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
