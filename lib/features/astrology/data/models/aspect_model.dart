import 'enums.dart';

class Aspect {
  final Planet planet1;
  final Planet planet2;
  final AspectType type;
  final double exactAngle; // Ângulo exato entre os planetas
  final double orb; // Orbe (diferença do ângulo exato)
  final bool isApplying; // Aspecto se aproximando ou se afastando

  const Aspect({
    required this.planet1,
    required this.planet2,
    required this.type,
    required this.exactAngle,
    required this.orb,
    this.isApplying = true,
  });

  String get description =>
      '${planet1.displayName} ${type.symbol} ${planet2.displayName} (${orb.toStringAsFixed(2)}°)';

  String get interpretation {
    final harmony = type.isHarmonious ? 'harmoniosa' :
                    type.isChallenging ? 'desafiadora' : 'neutra';
    return 'Conexão $harmony entre ${planet1.displayName} e ${planet2.displayName}.';
  }

  String get magicalInterpretation {
    // Interpretações mágicas específicas para combinações importantes
    if (planet1 == Planet.sun && planet2 == Planet.moon) {
      return type.isHarmonious
          ? 'Integração do masculino e feminino. Equilíbrio entre ação e intuição.'
          : 'Conflito entre ego e emoção. Trabalhe a integração através de rituais de equilíbrio.';
    }

    if ((planet1 == Planet.moon || planet2 == Planet.moon) &&
        (planet1 == Planet.neptune || planet2 == Planet.neptune)) {
      return type.isHarmonious
          ? 'Forte intuição psíquica. Ótimo para divinação e trabalho com sonhos.'
          : 'Confusão emocional. Use cristais de ancoragem em seus rituais.';
    }

    if ((planet1 == Planet.mercury || planet2 == Planet.mercury) &&
        (planet1 == Planet.neptune || planet2 == Planet.neptune)) {
      return type.isHarmonious
          ? 'Canalização e comunicação espiritual facilitadas.'
          : 'Dificuldade em distinguir intuição de imaginação. Ancore-se antes de rituais.';
    }

    if (planet1 == Planet.venus || planet2 == Planet.venus) {
      return type.isHarmonious
          ? 'Energia favorável para feitiços de amor e beleza.'
          : 'Revise suas intenções em feitiços de atração.';
    }

    if (planet1 == Planet.mars || planet2 == Planet.mars) {
      return type.isHarmonious
          ? 'Energia poderosa para feitiços de proteção e banimento.'
          : 'Cuidado com impulsividade em rituais. Trabalhe o autocontrole.';
    }

    return interpretation;
  }

  Map<String, dynamic> toJson() {
    return {
      'planet1': planet1.name,
      'planet2': planet2.name,
      'type': type.name,
      'exactAngle': exactAngle,
      'orb': orb,
      'isApplying': isApplying,
    };
  }

  factory Aspect.fromJson(Map<String, dynamic> json) {
    return Aspect(
      planet1: Planet.values.firstWhere((e) => e.name == json['planet1']),
      planet2: Planet.values.firstWhere((e) => e.name == json['planet2']),
      type: AspectType.values.firstWhere((e) => e.name == json['type']),
      exactAngle: json['exactAngle'],
      orb: json['orb'],
      isApplying: json['isApplying'] ?? true,
    );
  }
}
