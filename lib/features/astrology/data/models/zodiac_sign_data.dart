import 'enums.dart';

/// Dados detalhados de cada signo do zodíaco.
///
/// O conteúdo textual é localizado por idioma nos arquivos
/// `zodiac_signs_data_pt/en/es.dart` (data_sources), selecionados em tempo de
/// execução por `zodiac_signs_data.dart` via `ContentLocale`. O campo [sign] é
/// invariante entre idiomas — a paridade é verificada em
/// `test/astrology_content_parity_test.dart`.
class ZodiacSignData {
  final ZodiacSign sign;
  final String dateRange;
  final String rulingPlanet;
  final String keywords;
  final String personality;
  final String magicalGifts;
  final String bestPractices;
  final String crystals;
  final String herbs;
  final String colors;

  const ZodiacSignData({
    required this.sign,
    required this.dateRange,
    required this.rulingPlanet,
    required this.keywords,
    required this.personality,
    required this.magicalGifts,
    required this.bestPractices,
    required this.crystals,
    required this.herbs,
    required this.colors,
  });
}
