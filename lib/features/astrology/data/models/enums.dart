// Enums para Astrologia
import 'package:flutter/material.dart';

import '../../../../core/content/content_locale.dart';

enum Planet {
  sun,
  moon,
  mercury,
  venus,
  mars,
  jupiter,
  saturn,
  uranus,
  neptune,
  pluto,
  northNode,
  southNode,
  midheaven,
  imumCoeli,
  descendant,
  vertex,
  lilith,
  partOfFortune;

  String get displayName => ContentLocale.instance
      .select(pt: _planetNamesPt, en: _planetNamesEn, es: _planetNamesEs)[this]!;

  String get symbol {
    switch (this) {
      case Planet.sun:
        return '☉';
      case Planet.moon:
        return '☽';
      case Planet.mercury:
        return '☿';
      case Planet.venus:
        return '♀';
      case Planet.mars:
        return '♂';
      case Planet.jupiter:
        return '♃';
      case Planet.saturn:
        return '♄';
      case Planet.uranus:
        return '♅';
      case Planet.neptune:
        return '♆';
      case Planet.pluto:
        return '♇';
      case Planet.northNode:
        return '☊';
      case Planet.southNode:
        return '☋';
      case Planet.midheaven:
        return 'MC';
      case Planet.imumCoeli:
        return 'IC';
      case Planet.descendant:
        return 'Dsc';
      case Planet.vertex:
        return 'Vx';
      case Planet.lilith:
        return '⚸';
      case Planet.partOfFortune:
        return '⊗';
    }
  }

  int get swephId {
    switch (this) {
      case Planet.sun:
        return 0; // SE_SUN
      case Planet.moon:
        return 1; // SE_MOON
      case Planet.mercury:
        return 2; // SE_MERCURY
      case Planet.venus:
        return 3; // SE_VENUS
      case Planet.mars:
        return 4; // SE_MARS
      case Planet.jupiter:
        return 5; // SE_JUPITER
      case Planet.saturn:
        return 6; // SE_SATURN
      case Planet.uranus:
        return 7; // SE_URANUS
      case Planet.neptune:
        return 8; // SE_NEPTUNE
      case Planet.pluto:
        return 9; // SE_PLUTO
      case Planet.northNode:
        return 10; // SE_MEAN_NODE
      case Planet.southNode:
        return 10; // Same as north node, calculate opposite
      case Planet.lilith:
        return 12; // SE_MEAN_APOG (Lua Negra / apogeu médio)
      case Planet.midheaven:
      case Planet.imumCoeli:
      case Planet.descendant:
      case Planet.vertex:
      case Planet.partOfFortune:
        // Pontos calculados a partir das casas/ângulos — não vêm do sweph.
        throw StateError('${displayName} é um ponto calculado, não tem swephId');
    }
  }
}

enum ZodiacSign {
  aries,
  taurus,
  gemini,
  cancer,
  leo,
  virgo,
  libra,
  scorpio,
  sagittarius,
  capricorn,
  aquarius,
  pisces;

  String get displayName => ContentLocale.instance.select(
      pt: _zodiacNamesPt, en: _zodiacNamesEn, es: _zodiacNamesEs)[this]!;

  String get symbol {
    switch (this) {
      case ZodiacSign.aries:
        return '♈';
      case ZodiacSign.taurus:
        return '♉';
      case ZodiacSign.gemini:
        return '♊';
      case ZodiacSign.cancer:
        return '♋';
      case ZodiacSign.leo:
        return '♌';
      case ZodiacSign.virgo:
        return '♍';
      case ZodiacSign.libra:
        return '♎';
      case ZodiacSign.scorpio:
        return '♏';
      case ZodiacSign.sagittarius:
        return '♐';
      case ZodiacSign.capricorn:
        return '♑';
      case ZodiacSign.aquarius:
        return '♒';
      case ZodiacSign.pisces:
        return '♓';
    }
  }

  Element get element {
    switch (this) {
      case ZodiacSign.aries:
      case ZodiacSign.leo:
      case ZodiacSign.sagittarius:
        return Element.fire;
      case ZodiacSign.taurus:
      case ZodiacSign.virgo:
      case ZodiacSign.capricorn:
        return Element.earth;
      case ZodiacSign.gemini:
      case ZodiacSign.libra:
      case ZodiacSign.aquarius:
        return Element.air;
      case ZodiacSign.cancer:
      case ZodiacSign.scorpio:
      case ZodiacSign.pisces:
        return Element.water;
    }
  }

  Modality get modality {
    switch (this) {
      case ZodiacSign.aries:
      case ZodiacSign.cancer:
      case ZodiacSign.libra:
      case ZodiacSign.capricorn:
        return Modality.cardinal;
      case ZodiacSign.taurus:
      case ZodiacSign.leo:
      case ZodiacSign.scorpio:
      case ZodiacSign.aquarius:
        return Modality.fixed;
      case ZodiacSign.gemini:
      case ZodiacSign.virgo:
      case ZodiacSign.sagittarius:
      case ZodiacSign.pisces:
        return Modality.mutable;
    }
  }

  static ZodiacSign fromLongitude(double longitude) {
    final signIndex = (longitude / 30).floor();
    return ZodiacSign.values[signIndex % 12];
  }

  String get magicalDescription => ContentLocale.instance.select(
      pt: _zodiacMagicalPt,
      en: _zodiacMagicalEn,
      es: _zodiacMagicalEs)[this]!;
}

enum Element {
  fire,
  earth,
  air,
  water;

  String get displayName => ContentLocale.instance.select(
      pt: _elementNamesPt, en: _elementNamesEn, es: _elementNamesEs)[this]!;

  String get symbol {
    switch (this) {
      case Element.fire:
        return '🔥';
      case Element.earth:
        return '🌍';
      case Element.air:
        return '💨';
      case Element.water:
        return '💧';
    }
  }

  String get magicalDescription => ContentLocale.instance.select(
      pt: _elementMagicalPt,
      en: _elementMagicalEn,
      es: _elementMagicalEs)[this]!;

  Color get color {
    switch (this) {
      case Element.fire:
        return Colors.red;
      case Element.earth:
        return Colors.green;
      case Element.air:
        return Colors.yellow;
      case Element.water:
        return Colors.blue;
    }
  }
}

enum Modality {
  cardinal,
  fixed,
  mutable;

  String get displayName => ContentLocale.instance.select(
      pt: _modalityNamesPt, en: _modalityNamesEn, es: _modalityNamesEs)[this]!;

  String get description => ContentLocale.instance.select(
      pt: _modalityDescPt,
      en: _modalityDescEn,
      es: _modalityDescEs)[this]!;
}

enum AspectType {
  conjunction,
  sextile,
  square,
  trine,
  opposition;

  String get displayName => ContentLocale.instance.select(
      pt: _aspectNamesPt, en: _aspectNamesEn, es: _aspectNamesEs)[this]!;

  String get symbol {
    switch (this) {
      case AspectType.conjunction:
        return '☌';
      case AspectType.sextile:
        return '⚹';
      case AspectType.square:
        return '□';
      case AspectType.trine:
        return '△';
      case AspectType.opposition:
        return '☍';
    }
  }

  double get angle {
    switch (this) {
      case AspectType.conjunction:
        return 0;
      case AspectType.sextile:
        return 60;
      case AspectType.square:
        return 90;
      case AspectType.trine:
        return 120;
      case AspectType.opposition:
        return 180;
    }
  }

  double get orb {
    switch (this) {
      case AspectType.conjunction:
      case AspectType.opposition:
        return 10; // Orbe maior para aspectos principais
      case AspectType.trine:
      case AspectType.square:
        return 8;
      case AspectType.sextile:
        return 6;
    }
  }

  double get maxOrb => orb; // Alias para compatibilidade

  String get description => ContentLocale.instance.select(
      pt: _aspectDescPt, en: _aspectDescEn, es: _aspectDescEs)[this]!;

  bool get isHarmonious {
    return this == AspectType.trine || this == AspectType.sextile;
  }

  bool get isChallenging {
    return this == AspectType.square || this == AspectType.opposition;
  }
}

enum EnergyLevel {
  high,
  medium,
  low,
  intense,
  challenging,
  moderate,
  harmonious;

  String get displayName => ContentLocale.instance.select(
      pt: _energyNamesPt, en: _energyNamesEn, es: _energyNamesEs)[this]!;

  String get symbol {
    switch (this) {
      case EnergyLevel.high:
      case EnergyLevel.intense:
        return '⚡⚡⚡';
      case EnergyLevel.medium:
      case EnergyLevel.moderate:
      case EnergyLevel.challenging:
        return '⚡⚡';
      case EnergyLevel.low:
      case EnergyLevel.harmonious:
        return '⚡';
    }
  }
}

// ---------------------------------------------------------------------------
// Mapas de tradução por locale.
//
// Espelham o mecanismo síncrono de `ContentLocale` (sem `BuildContext`), usado
// também pelos serviços que rodam fora da árvore de widgets
// (magical_interpreter, transit_interpreter). Cada mapa DEVE cobrir todos os
// valores do respectivo enum — a paridade é verificada por
// test/astrology_enums_parity_test.dart.
// ---------------------------------------------------------------------------

const Map<Planet, String> _planetNamesPt = {
  Planet.sun: 'Sol',
  Planet.moon: 'Lua',
  Planet.mercury: 'Mercúrio',
  Planet.venus: 'Vênus',
  Planet.mars: 'Marte',
  Planet.jupiter: 'Júpiter',
  Planet.saturn: 'Saturno',
  Planet.uranus: 'Urano',
  Planet.neptune: 'Netuno',
  Planet.pluto: 'Plutão',
  Planet.northNode: 'Nodo Norte',
  Planet.southNode: 'Nodo Sul',
  Planet.midheaven: 'Meio do Céu',
  Planet.imumCoeli: 'Fundo do Céu',
  Planet.descendant: 'Descendente',
  Planet.vertex: 'Vértex',
  Planet.lilith: 'Lilith',
  Planet.partOfFortune: 'Parte da Fortuna',
};

const Map<Planet, String> _planetNamesEn = {
  Planet.sun: 'Sun',
  Planet.moon: 'Moon',
  Planet.mercury: 'Mercury',
  Planet.venus: 'Venus',
  Planet.mars: 'Mars',
  Planet.jupiter: 'Jupiter',
  Planet.saturn: 'Saturn',
  Planet.uranus: 'Uranus',
  Planet.neptune: 'Neptune',
  Planet.pluto: 'Pluto',
  Planet.northNode: 'North Node',
  Planet.southNode: 'South Node',
  Planet.midheaven: 'Midheaven',
  Planet.imumCoeli: 'Imum Coeli',
  Planet.descendant: 'Descendant',
  Planet.vertex: 'Vertex',
  Planet.lilith: 'Lilith',
  Planet.partOfFortune: 'Part of Fortune',
};

const Map<Planet, String> _planetNamesEs = {
  Planet.sun: 'Sol',
  Planet.moon: 'Luna',
  Planet.mercury: 'Mercurio',
  Planet.venus: 'Venus',
  Planet.mars: 'Marte',
  Planet.jupiter: 'Júpiter',
  Planet.saturn: 'Saturno',
  Planet.uranus: 'Urano',
  Planet.neptune: 'Neptuno',
  Planet.pluto: 'Plutón',
  Planet.northNode: 'Nodo Norte',
  Planet.southNode: 'Nodo Sur',
  Planet.midheaven: 'Medio Cielo',
  Planet.imumCoeli: 'Fondo del Cielo',
  Planet.descendant: 'Descendente',
  Planet.vertex: 'Vértex',
  Planet.lilith: 'Lilith',
  Planet.partOfFortune: 'Parte de la Fortuna',
};

const Map<ZodiacSign, String> _zodiacNamesPt = {
  ZodiacSign.aries: 'Áries',
  ZodiacSign.taurus: 'Touro',
  ZodiacSign.gemini: 'Gêmeos',
  ZodiacSign.cancer: 'Câncer',
  ZodiacSign.leo: 'Leão',
  ZodiacSign.virgo: 'Virgem',
  ZodiacSign.libra: 'Libra',
  ZodiacSign.scorpio: 'Escorpião',
  ZodiacSign.sagittarius: 'Sagitário',
  ZodiacSign.capricorn: 'Capricórnio',
  ZodiacSign.aquarius: 'Aquário',
  ZodiacSign.pisces: 'Peixes',
};

const Map<ZodiacSign, String> _zodiacNamesEn = {
  ZodiacSign.aries: 'Aries',
  ZodiacSign.taurus: 'Taurus',
  ZodiacSign.gemini: 'Gemini',
  ZodiacSign.cancer: 'Cancer',
  ZodiacSign.leo: 'Leo',
  ZodiacSign.virgo: 'Virgo',
  ZodiacSign.libra: 'Libra',
  ZodiacSign.scorpio: 'Scorpio',
  ZodiacSign.sagittarius: 'Sagittarius',
  ZodiacSign.capricorn: 'Capricorn',
  ZodiacSign.aquarius: 'Aquarius',
  ZodiacSign.pisces: 'Pisces',
};

const Map<ZodiacSign, String> _zodiacNamesEs = {
  ZodiacSign.aries: 'Aries',
  ZodiacSign.taurus: 'Tauro',
  ZodiacSign.gemini: 'Géminis',
  ZodiacSign.cancer: 'Cáncer',
  ZodiacSign.leo: 'Leo',
  ZodiacSign.virgo: 'Virgo',
  ZodiacSign.libra: 'Libra',
  ZodiacSign.scorpio: 'Escorpio',
  ZodiacSign.sagittarius: 'Sagitario',
  ZodiacSign.capricorn: 'Capricornio',
  ZodiacSign.aquarius: 'Acuario',
  ZodiacSign.pisces: 'Piscis',
};

const Map<ZodiacSign, String> _zodiacMagicalPt = {
  ZodiacSign.aries: 'corajosas e iniciativas',
  ZodiacSign.taurus: 'estáveis e sensuais',
  ZodiacSign.gemini: 'curiosas e comunicativas',
  ZodiacSign.cancer: 'intuitivas e nutritivas',
  ZodiacSign.leo: 'expressivas e dramáticas',
  ZodiacSign.virgo: 'analíticas e práticas',
  ZodiacSign.libra: 'harmoniosas e diplomáticas',
  ZodiacSign.scorpio: 'profundas e transformadoras',
  ZodiacSign.sagittarius: 'expansivas e filosóficas',
  ZodiacSign.capricorn: 'disciplinadas e estruturadas',
  ZodiacSign.aquarius: 'inovadoras e humanitárias',
  ZodiacSign.pisces: 'místicas e compassivas',
};

const Map<ZodiacSign, String> _zodiacMagicalEn = {
  ZodiacSign.aries: 'courageous and pioneering',
  ZodiacSign.taurus: 'stable and sensual',
  ZodiacSign.gemini: 'curious and communicative',
  ZodiacSign.cancer: 'intuitive and nurturing',
  ZodiacSign.leo: 'expressive and dramatic',
  ZodiacSign.virgo: 'analytical and practical',
  ZodiacSign.libra: 'harmonious and diplomatic',
  ZodiacSign.scorpio: 'deep and transformative',
  ZodiacSign.sagittarius: 'expansive and philosophical',
  ZodiacSign.capricorn: 'disciplined and structured',
  ZodiacSign.aquarius: 'innovative and humanitarian',
  ZodiacSign.pisces: 'mystical and compassionate',
};

const Map<ZodiacSign, String> _zodiacMagicalEs = {
  ZodiacSign.aries: 'valientes e iniciadoras',
  ZodiacSign.taurus: 'estables y sensuales',
  ZodiacSign.gemini: 'curiosas y comunicativas',
  ZodiacSign.cancer: 'intuitivas y nutritivas',
  ZodiacSign.leo: 'expresivas y dramáticas',
  ZodiacSign.virgo: 'analíticas y prácticas',
  ZodiacSign.libra: 'armoniosas y diplomáticas',
  ZodiacSign.scorpio: 'profundas y transformadoras',
  ZodiacSign.sagittarius: 'expansivas y filosóficas',
  ZodiacSign.capricorn: 'disciplinadas y estructuradas',
  ZodiacSign.aquarius: 'innovadoras y humanitarias',
  ZodiacSign.pisces: 'místicas y compasivas',
};

const Map<Element, String> _elementNamesPt = {
  Element.fire: 'Fogo',
  Element.earth: 'Terra',
  Element.air: 'Ar',
  Element.water: 'Água',
};

const Map<Element, String> _elementNamesEn = {
  Element.fire: 'Fire',
  Element.earth: 'Earth',
  Element.air: 'Air',
  Element.water: 'Water',
};

const Map<Element, String> _elementNamesEs = {
  Element.fire: 'Fuego',
  Element.earth: 'Tierra',
  Element.air: 'Aire',
  Element.water: 'Agua',
};

const Map<Element, String> _elementMagicalPt = {
  Element.fire: 'Ação, paixão, transformação. Magia de velas e rituais solares.',
  Element.earth:
      'Manifestação, aterramento, prosperidade. Bruxaria verde e cristais.',
  Element.air:
      'Comunicação, intelecto, adivinhação. Magia de palavras e incensos.',
  Element.water:
      'Intuição, emoção, magia lunar. Banhos rituais e trabalho com sonhos.',
};

const Map<Element, String> _elementMagicalEn = {
  Element.fire: 'Action, passion, transformation. Candle magic and solar rituals.',
  Element.earth:
      'Manifestation, grounding, prosperity. Green witchcraft and crystals.',
  Element.air: 'Communication, intellect, divination. Word magic and incense.',
  Element.water: 'Intuition, emotion, lunar magic. Ritual baths and dream work.',
};

const Map<Element, String> _elementMagicalEs = {
  Element.fire: 'Acción, pasión, transformación. Magia de velas y rituales solares.',
  Element.earth:
      'Manifestación, enraizamiento, prosperidad. Brujería verde y cristales.',
  Element.air:
      'Comunicación, intelecto, adivinación. Magia de palabras e inciensos.',
  Element.water:
      'Intuición, emoción, magia lunar. Baños rituales y trabajo con sueños.',
};

const Map<Modality, String> _modalityNamesPt = {
  Modality.cardinal: 'Cardinal',
  Modality.fixed: 'Fixo',
  Modality.mutable: 'Mutável',
};

const Map<Modality, String> _modalityNamesEn = {
  Modality.cardinal: 'Cardinal',
  Modality.fixed: 'Fixed',
  Modality.mutable: 'Mutable',
};

const Map<Modality, String> _modalityNamesEs = {
  Modality.cardinal: 'Cardinal',
  Modality.fixed: 'Fijo',
  Modality.mutable: 'Mutable',
};

const Map<Modality, String> _modalityDescPt = {
  Modality.cardinal:
      'Iniciação, liderança, ação. Você é uma bruxa que inicia mudanças.',
  Modality.fixed:
      'Estabilidade, persistência, poder. Você é uma bruxa que mantém e fortalece.',
  Modality.mutable:
      'Adaptação, flexibilidade, transformação. Você é uma bruxa que flui e se adapta.',
};

const Map<Modality, String> _modalityDescEn = {
  Modality.cardinal:
      'Initiation, leadership, action. You are a witch who starts change.',
  Modality.fixed:
      'Stability, persistence, power. You are a witch who sustains and strengthens.',
  Modality.mutable:
      'Adaptation, flexibility, transformation. You are a witch who flows and adapts.',
};

const Map<Modality, String> _modalityDescEs = {
  Modality.cardinal:
      'Iniciación, liderazgo, acción. Eres una bruja que inicia cambios.',
  Modality.fixed:
      'Estabilidad, persistencia, poder. Eres una bruja que mantiene y fortalece.',
  Modality.mutable:
      'Adaptación, flexibilidad, transformación. Eres una bruja que fluye y se adapta.',
};

const Map<AspectType, String> _aspectNamesPt = {
  AspectType.conjunction: 'Conjunção',
  AspectType.sextile: 'Sextil',
  AspectType.square: 'Quadratura',
  AspectType.trine: 'Trígono',
  AspectType.opposition: 'Oposição',
};

const Map<AspectType, String> _aspectNamesEn = {
  AspectType.conjunction: 'Conjunction',
  AspectType.sextile: 'Sextile',
  AspectType.square: 'Square',
  AspectType.trine: 'Trine',
  AspectType.opposition: 'Opposition',
};

const Map<AspectType, String> _aspectNamesEs = {
  AspectType.conjunction: 'Conjunción',
  AspectType.sextile: 'Sextil',
  AspectType.square: 'Cuadratura',
  AspectType.trine: 'Trígono',
  AspectType.opposition: 'Oposición',
};

const Map<AspectType, String> _aspectDescPt = {
  AspectType.conjunction: 'intensificadora',
  AspectType.sextile: 'harmoniosa',
  AspectType.square: 'desafiadora',
  AspectType.trine: 'fluida',
  AspectType.opposition: 'polarizadora',
};

const Map<AspectType, String> _aspectDescEn = {
  AspectType.conjunction: 'intensifying',
  AspectType.sextile: 'harmonious',
  AspectType.square: 'challenging',
  AspectType.trine: 'flowing',
  AspectType.opposition: 'polarizing',
};

const Map<AspectType, String> _aspectDescEs = {
  AspectType.conjunction: 'intensificadora',
  AspectType.sextile: 'armoniosa',
  AspectType.square: 'desafiante',
  AspectType.trine: 'fluida',
  AspectType.opposition: 'polarizadora',
};

const Map<EnergyLevel, String> _energyNamesPt = {
  EnergyLevel.high: 'Alta',
  EnergyLevel.medium: 'Média',
  EnergyLevel.low: 'Baixa',
  EnergyLevel.intense: 'Intensa',
  EnergyLevel.challenging: 'Desafiadora',
  EnergyLevel.moderate: 'Moderada',
  EnergyLevel.harmonious: 'Harmoniosa',
};

const Map<EnergyLevel, String> _energyNamesEn = {
  EnergyLevel.high: 'High',
  EnergyLevel.medium: 'Medium',
  EnergyLevel.low: 'Low',
  EnergyLevel.intense: 'Intense',
  EnergyLevel.challenging: 'Challenging',
  EnergyLevel.moderate: 'Moderate',
  EnergyLevel.harmonious: 'Harmonious',
};

const Map<EnergyLevel, String> _energyNamesEs = {
  EnergyLevel.high: 'Alta',
  EnergyLevel.medium: 'Media',
  EnergyLevel.low: 'Baja',
  EnergyLevel.intense: 'Intensa',
  EnergyLevel.challenging: 'Desafiante',
  EnergyLevel.moderate: 'Moderada',
  EnergyLevel.harmonious: 'Armoniosa',
};
