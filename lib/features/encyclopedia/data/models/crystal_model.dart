enum Element {
  earth,
  water,
  air,
  fire,
  spirit,
}

/// Método de limpeza ou carregamento com flag de segurança
class CrystalMethod {
  final String method;
  final bool isSafe;
  final String? warning;

  const CrystalMethod({
    required this.method,
    required this.isSafe,
    this.warning,
  });
}

class CrystalModel {
  final String name;
  final String description;
  final Element element;
  final List<String> intentions;
  final List<String> usageTips;
  final List<CrystalMethod> cleaningMethods;
  final List<CrystalMethod> chargingMethods;
  final List<String> safetyWarnings; // ⚠️ NOVO: Avisos de segurança

  const CrystalModel({
    required this.name,
    required this.description,
    required this.element,
    required this.intentions,
    required this.usageTips,
    required this.cleaningMethods,
    required this.chargingMethods,
    this.safetyWarnings = const [], // ⚠️ NOVO
  });

  /// Métodos de limpeza seguros (apenas os que isSafe == true)
  List<String> get safeCleaningMethods =>
      cleaningMethods.where((m) => m.isSafe).map((m) => m.method).toList();

  /// Métodos de carregamento seguros (apenas os que isSafe == true)
  List<String> get safeChargingMethods =>
      chargingMethods.where((m) => m.isSafe).map((m) => m.method).toList();
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
