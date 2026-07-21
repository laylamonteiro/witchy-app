import '../../../../core/content/content_locale.dart';
import 'enums.dart';

class House {
  final int number; // 1-12
  final ZodiacSign sign; // Signo na cúspide
  final int degree; // Grau da cúspide
  final int minute; // Minuto da cúspide
  final double cuspLongitude; // Longitude da cúspide

  const House({
    required this.number,
    required this.sign,
    required this.degree,
    required this.minute,
    required this.cuspLongitude,
  });

  String get meaning =>
      ContentLocale.instance.select(
        pt: _houseMeaningPt,
        en: _houseMeaningEn,
        es: _houseMeaningEs,
      )[number] ??
      '';

  String get magicalMeaning =>
      ContentLocale.instance.select(
        pt: _houseMagicalMeaningPt,
        en: _houseMagicalMeaningEn,
        es: _houseMagicalMeaningEs,
      )[number] ??
      '';

  String get cuspString => '${sign.symbol} ${degree}°${minute}\'';

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'sign': sign.name,
      'degree': degree,
      'minute': minute,
      'cuspLongitude': cuspLongitude,
    };
  }

  factory House.fromJson(Map<String, dynamic> json) {
    return House(
      number: json['number'],
      sign: ZodiacSign.values.firstWhere((e) => e.name == json['sign']),
      degree: json['degree'],
      minute: json['minute'],
      cuspLongitude: json['cuspLongitude'],
    );
  }
}

// ---------------------------------------------------------------------------
// Mapas de tradução por número de casa (1..12).
//
// Espelham o mecanismo síncrono de `ContentLocale` (sem `BuildContext`),
// mesmo padrão de enums.dart. Cada mapa DEVE cobrir as casas 1..12 — a
// paridade é verificada por test/astrology_content_parity_test.dart.
// ---------------------------------------------------------------------------

const Map<int, String> _houseMeaningPt = {
  1: 'Personalidade, aparência, como você se apresenta ao mundo',
  2: 'Recursos, valores, posses materiais',
  3: 'Comunicação, aprendizado, irmãos',
  4: 'Lar, família, raízes, emoções profundas',
  5: 'Criatividade, romance, prazer, filhos',
  6: 'Saúde, rotina, trabalho diário',
  7: 'Parcerias, relacionamentos, casamento',
  8: 'Transformação, sexualidade, magia, ocultismo',
  9: 'Filosofia, viagens, espiritualidade, sabedoria',
  10: 'Carreira, status social, propósito público',
  11: 'Amizades, comunidade, sonhos, ideais',
  12: 'Inconsciente, espiritualidade, isolamento, mediunidade',
};

const Map<int, String> _houseMeaningEn = {
  1: 'Personality, appearance, how you present yourself to the world',
  2: 'Resources, values, material possessions',
  3: 'Communication, learning, siblings',
  4: 'Home, family, roots, deep emotions',
  5: 'Creativity, romance, pleasure, children',
  6: 'Health, routine, daily work',
  7: 'Partnerships, relationships, marriage',
  8: 'Transformation, sexuality, magic, the occult',
  9: 'Philosophy, travel, spirituality, wisdom',
  10: 'Career, social status, public purpose',
  11: 'Friendships, community, dreams, ideals',
  12: 'The unconscious, spirituality, isolation, mediumship',
};

const Map<int, String> _houseMeaningEs = {
  1: 'Personalidad, apariencia, cómo te presentas ante el mundo',
  2: 'Recursos, valores, posesiones materiales',
  3: 'Comunicación, aprendizaje, hermanos',
  4: 'Hogar, familia, raíces, emociones profundas',
  5: 'Creatividad, romance, placer, hijos',
  6: 'Salud, rutina, trabajo diario',
  7: 'Asociaciones, relaciones, matrimonio',
  8: 'Transformación, sexualidad, magia, ocultismo',
  9: 'Filosofía, viajes, espiritualidad, sabiduría',
  10: 'Carrera, estatus social, propósito público',
  11: 'Amistades, comunidad, sueños, ideales',
  12: 'Inconsciente, espiritualidad, aislamiento, mediumnidad',
};

const Map<int, String> _houseMagicalMeaningPt = {
  1: 'Sua máscara mágica - como você se apresenta como bruxa',
  2: 'Suas ferramentas mágicas - cristais, ervas, recursos',
  3: 'Comunicação com espíritos, feitiços falados',
  4: 'Altar do lar, magia doméstica, ancestrais',
  5: 'Criatividade mágica, prazer nos rituais',
  6: 'Rituais diários, limpezas, saúde energética',
  7: 'Parcerias mágicas, trabalho em covens',
  8: 'Magia sexual, transformação profunda, ocultismo',
  9: 'Estudos esotéricos, viagens astrais',
  10: 'Seu propósito como bruxa no mundo',
  11: 'Comunidade mágica, círculos, intenções',
  12: 'Mediunidade, sonhos proféticos, magia oculta',
};

const Map<int, String> _houseMagicalMeaningEn = {
  1: 'Your magical mask - how you present yourself as a witch',
  2: 'Your magical tools - crystals, herbs, resources',
  3: 'Communication with spirits, spoken spells',
  4: 'Home altar, domestic magic, ancestors',
  5: 'Magical creativity, pleasure in rituals',
  6: 'Daily rituals, cleansings, energetic health',
  7: 'Magical partnerships, coven work',
  8: 'Sex magic, deep transformation, the occult',
  9: 'Esoteric study, astral travel',
  10: 'Your purpose as a witch in the world',
  11: 'Magical community, circles, intentions',
  12: 'Mediumship, prophetic dreams, hidden magic',
};

const Map<int, String> _houseMagicalMeaningEs = {
  1: 'Tu máscara mágica - cómo te presentas como bruja',
  2: 'Tus herramientas mágicas - cristales, hierbas, recursos',
  3: 'Comunicación con espíritus, hechizos hablados',
  4: 'Altar del hogar, magia doméstica, ancestros',
  5: 'Creatividad mágica, placer en los rituales',
  6: 'Rituales diarios, limpiezas, salud energética',
  7: 'Asociaciones mágicas, trabajo en aquelarres',
  8: 'Magia sexual, transformación profunda, ocultismo',
  9: 'Estudios esotéricos, viajes astrales',
  10: 'Tu propósito como bruja en el mundo',
  11: 'Comunidad mágica, círculos, intenciones',
  12: 'Mediumnidad, sueños proféticos, magia oculta',
};
