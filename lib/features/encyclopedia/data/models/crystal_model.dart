enum Element {
  earth,
  water,
  air,
  fire,
  spirit,
}

class CrystalModel {
  final String name;
  final String description;
  final Element element;
  final List<String> intentions;
  final List<String> usageTips;
  final List<String> cleaningMethods;
  final List<String> chargingMethods;

  const CrystalModel({
    required this.name,
    required this.description,
    required this.element,
    required this.intentions,
    required this.usageTips,
    required this.cleaningMethods,
    required this.chargingMethods,
  });
}

extension ElementExtension on Element {
  String get displayName {
    switch (this) {
      case Element.earth:
        return 'Terra';
      case Element.water:
        return 'Água';
      case Element.air:
        return 'Ar';
      case Element.fire:
        return 'Fogo';
      case Element.spirit:
        return 'Espírito';
    }
  }

  String get emoji {
    switch (this) {
      case Element.earth:
        return '🌍';
      case Element.water:
        return '💧';
      case Element.air:
        return '🌬️';
      case Element.fire:
        return '🔥';
      case Element.spirit:
        return '✨';
    }
  }
}
