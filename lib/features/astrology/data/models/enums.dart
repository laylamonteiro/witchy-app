// Enums para Astrologia
import 'package:flutter/material.dart';

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
  southNode;

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
      case Planet.uranus:
        return 'Urano';
      case Planet.neptune:
        return 'Netuno';
      case Planet.pluto:
        return 'Plutão';
      case Planet.northNode:
        return 'Nodo Norte';
      case Planet.southNode:
        return 'Nodo Sul';
    }
  }

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

  String get displayName {
    switch (this) {
      case ZodiacSign.aries:
        return 'Áries';
      case ZodiacSign.taurus:
        return 'Touro';
      case ZodiacSign.gemini:
        return 'Gêmeos';
      case ZodiacSign.cancer:
        return 'Câncer';
      case ZodiacSign.leo:
        return 'Leão';
      case ZodiacSign.virgo:
        return 'Virgem';
      case ZodiacSign.libra:
        return 'Libra';
      case ZodiacSign.scorpio:
        return 'Escorpião';
      case ZodiacSign.sagittarius:
        return 'Sagitário';
      case ZodiacSign.capricorn:
        return 'Capricórnio';
      case ZodiacSign.aquarius:
        return 'Aquário';
      case ZodiacSign.pisces:
        return 'Peixes';
    }
  }

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

  String get magicalDescription {
    switch (this) {
      case ZodiacSign.aries:
        return 'corajosas e iniciativas';
      case ZodiacSign.taurus:
        return 'estáveis e sensuais';
      case ZodiacSign.gemini:
        return 'curiosas e comunicativas';
      case ZodiacSign.cancer:
        return 'intuitivas e nutritivas';
      case ZodiacSign.leo:
        return 'expressivas e dramáticas';
      case ZodiacSign.virgo:
        return 'analíticas e práticas';
      case ZodiacSign.libra:
        return 'harmoniosas e diplomáticas';
      case ZodiacSign.scorpio:
        return 'profundas e transformadoras';
      case ZodiacSign.sagittarius:
        return 'expansivas e filosóficas';
      case ZodiacSign.capricorn:
        return 'disciplinadas e estruturadas';
      case ZodiacSign.aquarius:
        return 'inovadoras e humanitárias';
      case ZodiacSign.pisces:
        return 'místicas e compassivas';
    }
  }
}

enum Element {
  fire,
  earth,
  air,
  water;

  String get displayName {
    switch (this) {
      case Element.fire:
        return 'Fogo';
      case Element.earth:
        return 'Terra';
      case Element.air:
        return 'Ar';
      case Element.water:
        return 'Água';
    }
  }

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

  String get magicalDescription {
    switch (this) {
      case Element.fire:
        return 'Ação, paixão, transformação. Magia de velas e rituais solares.';
      case Element.earth:
        return 'Manifestação, aterramento, prosperidade. Bruxaria verde e cristais.';
      case Element.air:
        return 'Comunicação, intelecto, adivinhação. Magia de palavras e incensos.';
      case Element.water:
        return 'Intuição, emoção, magia lunar. Banhos rituais e trabalho com sonhos.';
    }
  }

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

  String get displayName {
    switch (this) {
      case Modality.cardinal:
        return 'Cardinal';
      case Modality.fixed:
        return 'Fixo';
      case Modality.mutable:
        return 'Mutável';
    }
  }

  String get description {
    switch (this) {
      case Modality.cardinal:
        return 'Iniciação, liderança, ação. Você é uma bruxa que inicia mudanças.';
      case Modality.fixed:
        return 'Estabilidade, persistência, poder. Você é uma bruxa que mantém e fortalece.';
      case Modality.mutable:
        return 'Adaptação, flexibilidade, transformação. Você é uma bruxa que flui e se adapta.';
    }
  }
}

enum AspectType {
  conjunction,
  sextile,
  square,
  trine,
  opposition;

  String get displayName {
    switch (this) {
      case AspectType.conjunction:
        return 'Conjunção';
      case AspectType.sextile:
        return 'Sextil';
      case AspectType.square:
        return 'Quadratura';
      case AspectType.trine:
        return 'Trígono';
      case AspectType.opposition:
        return 'Oposição';
    }
  }

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

  String get description {
    switch (this) {
      case AspectType.conjunction:
        return 'intensificadora';
      case AspectType.sextile:
        return 'harmoniosa';
      case AspectType.square:
        return 'desafiadora';
      case AspectType.trine:
        return 'fluida';
      case AspectType.opposition:
        return 'polarizadora';
    }
  }

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

  String get displayName {
    switch (this) {
      case EnergyLevel.high:
        return 'Alta';
      case EnergyLevel.medium:
        return 'Média';
      case EnergyLevel.low:
        return 'Baixa';
      case EnergyLevel.intense:
        return 'Intensa';
      case EnergyLevel.challenging:
        return 'Desafiadora';
      case EnergyLevel.moderate:
        return 'Moderada';
      case EnergyLevel.harmonious:
        return 'Harmoniosa';
    }
  }

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
