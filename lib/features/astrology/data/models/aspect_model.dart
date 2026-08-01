import '../../../../core/content/content_locale.dart';
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
    final key = type.isHarmonious
        ? 'connectionHarmonious'
        : type.isChallenging
            ? 'connectionChallenging'
            : 'connectionNeutral';
    return _aspectText(key)
        .replaceAll('{p1}', planet1.displayName)
        .replaceAll('{p2}', planet2.displayName);
  }

  String get magicalInterpretation {
    // Interpretações mágicas específicas para combinações importantes
    if (planet1 == Planet.sun && planet2 == Planet.moon) {
      return type.isHarmonious
          ? _aspectText('sunMoonHarmonious')
          : _aspectText('sunMoonChallenging');
    }

    if ((planet1 == Planet.moon || planet2 == Planet.moon) &&
        (planet1 == Planet.neptune || planet2 == Planet.neptune)) {
      return type.isHarmonious
          ? _aspectText('moonNeptuneHarmonious')
          : _aspectText('moonNeptuneChallenging');
    }

    if ((planet1 == Planet.mercury || planet2 == Planet.mercury) &&
        (planet1 == Planet.neptune || planet2 == Planet.neptune)) {
      return type.isHarmonious
          ? _aspectText('mercuryNeptuneHarmonious')
          : _aspectText('mercuryNeptuneChallenging');
    }

    if (planet1 == Planet.venus || planet2 == Planet.venus) {
      return type.isHarmonious
          ? _aspectText('venusHarmonious')
          : _aspectText('venusChallenging');
    }

    if (planet1 == Planet.mars || planet2 == Planet.mars) {
      return type.isHarmonious
          ? _aspectText('marsHarmonious')
          : _aspectText('marsChallenging');
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

// ---------------------------------------------------------------------------
// Mapas de tradução por id estável de texto de aspecto.
//
// Espelham o mecanismo síncrono de `ContentLocale` (sem `BuildContext`),
// mesmo padrão de house_model.dart. Os três mapas DEVEM ter as mesmas chaves —
// a paridade é verificada por test/astrology_content_parity_test.dart.
// Templates usam os placeholders `{p1}` e `{p2}` (nomes dos planetas).
// ---------------------------------------------------------------------------

String _aspectText(String key) => ContentLocale.instance.select(
      pt: _aspectTextsPt,
      en: _aspectTextsEn,
      es: _aspectTextsEs,
    )[key]!;

const Map<String, String> _aspectTextsPt = {
  'connectionHarmonious': 'Conexão harmoniosa entre {p1} e {p2}',
  'connectionChallenging': 'Conexão desafiadora entre {p1} e {p2}',
  'connectionNeutral': 'Conexão neutra entre {p1} e {p2}',
  'sunMoonHarmonious':
      'Integração do masculino e feminino. Equilíbrio entre ação e intuição',
  'sunMoonChallenging':
      'Conflito entre ego e emoção. Trabalhe a integração através de rituais de equilíbrio',
  'moonNeptuneHarmonious':
      'Forte intuição psíquica. Ótimo para divinação e trabalho com sonhos',
  'moonNeptuneChallenging':
      'Confusão emocional. Use cristais de ancoragem em seus rituais',
  'mercuryNeptuneHarmonious':
      'Canalização e comunicação espiritual facilitadas',
  'mercuryNeptuneChallenging':
      'Dificuldade em distinguir intuição de imaginação. Ancore-se antes de rituais',
  'venusHarmonious': 'Energia favorável para feitiços de amor e beleza',
  'venusChallenging': 'Revise suas intenções em feitiços de atração',
  'marsHarmonious': 'Energia poderosa para feitiços de proteção e banimento',
  'marsChallenging':
      'Cuidado com impulsividade em rituais. Trabalhe o autocontrole',
};

const Map<String, String> _aspectTextsEn = {
  'connectionHarmonious': 'Harmonious connection between {p1} and {p2}',
  'connectionChallenging': 'Challenging connection between {p1} and {p2}',
  'connectionNeutral': 'Neutral connection between {p1} and {p2}',
  'sunMoonHarmonious':
      'Integration of the masculine and feminine. Balance between action and intuition',
  'sunMoonChallenging':
      'Conflict between ego and emotion. Work on integration through balancing rituals',
  'moonNeptuneHarmonious':
      'Strong psychic intuition. Great for divination and dream work',
  'moonNeptuneChallenging':
      'Emotional confusion. Use grounding crystals in your rituals',
  'mercuryNeptuneHarmonious':
      'Channeling and spiritual communication come easily',
  'mercuryNeptuneChallenging':
      'Difficulty telling intuition from imagination. Ground yourself before rituals',
  'venusHarmonious': 'Favorable energy for love and beauty spells',
  'venusChallenging': 'Review your intentions in attraction spells',
  'marsHarmonious': 'Powerful energy for protection and banishing spells',
  'marsChallenging':
      'Beware of impulsiveness in rituals. Work on self-control',
};

const Map<String, String> _aspectTextsEs = {
  'connectionHarmonious': 'Conexión armoniosa entre {p1} y {p2}',
  'connectionChallenging': 'Conexión desafiante entre {p1} y {p2}',
  'connectionNeutral': 'Conexión neutra entre {p1} y {p2}',
  'sunMoonHarmonious':
      'Integración de lo masculino y lo femenino. Equilibrio entre acción e intuición',
  'sunMoonChallenging':
      'Conflicto entre ego y emoción. Trabaja la integración a través de rituales de equilibrio',
  'moonNeptuneHarmonious':
      'Fuerte intuición psíquica. Excelente para la adivinación y el trabajo con sueños',
  'moonNeptuneChallenging':
      'Confusión emocional. Usa cristales de anclaje en tus rituales',
  'mercuryNeptuneHarmonious':
      'Canalización y comunicación espiritual facilitadas',
  'mercuryNeptuneChallenging':
      'Dificultad para distinguir la intuición de la imaginación. Ánclate antes de los rituales',
  'venusHarmonious': 'Energía favorable para hechizos de amor y belleza',
  'venusChallenging': 'Revisa tus intenciones en hechizos de atracción',
  'marsHarmonious':
      'Energía poderosa para hechizos de protección y destierro',
  'marsChallenging':
      'Cuidado con la impulsividad en los rituales. Trabaja el autocontrol',
};
