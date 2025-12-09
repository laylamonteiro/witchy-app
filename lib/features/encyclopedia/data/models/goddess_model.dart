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
        return 'Grega';
      case GoddessOrigin.roman:
        return 'Romana';
      case GoddessOrigin.celtic:
        return 'Celta';
      case GoddessOrigin.norse:
        return 'Nórdica';
      case GoddessOrigin.egyptian:
        return 'Egípcia';
      case GoddessOrigin.hindu:
        return 'Hindu';
      case GoddessOrigin.brazilian:
        return 'Brasileira';
      case GoddessOrigin.african:
        return 'Africana';
      case GoddessOrigin.mesopotamian:
        return 'Mesopotâmica';
      case GoddessOrigin.japanese:
        return 'Japonesa';
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
        return 'Amor';
      case GoddessAspect.war:
        return 'Guerra';
      case GoddessAspect.wisdom:
        return 'Sabedoria';
      case GoddessAspect.fertility:
        return 'Fertilidade';
      case GoddessAspect.moon:
        return 'Lua';
      case GoddessAspect.sun:
        return 'Sol';
      case GoddessAspect.nature:
        return 'Natureza';
      case GoddessAspect.magic:
        return 'Magia';
      case GoddessAspect.protection:
        return 'Proteção';
      case GoddessAspect.healing:
        return 'Cura';
      case GoddessAspect.death:
        return 'Morte';
      case GoddessAspect.transformation:
        return 'Transformação';
      case GoddessAspect.sea:
        return 'Mar';
      case GoddessAspect.harvest:
        return 'Colheita';
      case GoddessAspect.home:
        return 'Lar';
      case GoddessAspect.beauty:
        return 'Beleza';
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
