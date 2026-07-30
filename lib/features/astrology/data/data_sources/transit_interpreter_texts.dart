import '../../../../core/content/content_locale.dart';
import '../models/enums.dart';
import 'transit_interpreter_texts_en.dart';
import 'transit_interpreter_texts_es.dart';
import 'transit_interpreter_texts_pt.dart';

/// Chaves canônicas das fases da lua, invariantes entre idiomas.
///
/// Os mapas por fase de [TransitInterpreterTexts] são indexados por estas
/// chaves; o nome exibido ao usuário vem de
/// [TransitInterpreterTexts.phaseNames].
const List<String> kMoonPhaseKeys = [
  'newMoon',
  'waxingCrescent',
  'firstQuarter',
  'waxingGibbous',
  'fullMoon',
  'waningGibbous',
  'lastQuarter',
  'waningCrescent',
];

/// Frases-template do `TransitInterpreter` (clima mágico diário e sugestões
/// personalizadas).
///
/// O conteúdo por idioma vive em `transit_interpreter_texts_pt/en/es.dart` —
/// as três instâncias DEVEM preencher as mesmas estruturas (mesmas chaves nos
/// mapas, mesmos tamanhos de lista); a paridade é verificada em
/// `test/astrology_interpreters_parity_test.dart`. Nomes de planeta, signo,
/// elemento e aspecto chegam já localizados via os getters dos enums.
class TransitInterpreterTexts {
  const TransitInterpreterTexts({
    required this.phaseNames,
    required this.phaseInterpretations,
    required this.phaseFallback,
    required this.moonInSign,
    required this.energyDescriptions,
    required this.phasePractices,
    required this.practiceIntenseDay,
    required this.practiceHarmoniousDay,
    required this.phaseKeywords,
    required this.keywordIntensity,
    required this.keywordHarmony,
    required this.transitAspect,
    required this.conjunctionTitle,
    required this.conjunctionDescription,
    required this.conjunctionPractices,
    required this.harmoniousTitle,
    required this.harmoniousDescription,
    required this.harmoniousPractices,
    required this.challengingTitle,
    required this.challengingDescription,
    required this.challengingPractices,
    required this.moonSuggestionTitle,
    required this.moonSuggestionDescription,
    required this.moonSuggestionPractices,
  });

  /// Nome exibido de cada fase, indexado por [kMoonPhaseKeys].
  final Map<String, String> phaseNames;

  /// Interpretação de cada fase, indexada por [kMoonPhaseKeys].
  final Map<String, String> phaseInterpretations;

  /// Fallback caso a fase não esteja no mapa.
  final String phaseFallback;

  /// 'Com a Lua em X, as emoções estão Y' (Y = magicalDescription do signo).
  final String Function(String moonSignName, String signQualities) moonInSign;

  /// Descrição da energia geral do dia.
  final Map<EnergyLevel, String> energyDescriptions;

  /// Práticas recomendadas por fase, indexadas por [kMoonPhaseKeys].
  final Map<String, String> phasePractices;

  final String practiceIntenseDay;
  final String practiceHarmoniousDay;

  /// Palavras-chave de energia por fase, indexadas por [kMoonPhaseKeys].
  final Map<String, List<String>> phaseKeywords;

  final String keywordIntensity;
  final String keywordHarmony;

  /// 'P1 ☌ P2: energia desafiadora'.
  final String Function(
    String planet1,
    String aspectSymbol,
    String planet2,
    String aspectQuality,
  ) transitAspect;

  // Sugestão de conjunção.
  final String Function(String transitPlanet, String natalPlanet)
      conjunctionTitle;
  final String Function(String transitPlanet, String natalPlanet)
      conjunctionDescription;
  final List<String> conjunctionPractices;

  // Sugestão de aspecto harmonioso.
  final String harmoniousTitle;
  final String Function(
    String transitPlanet,
    String aspectSymbol,
    String natalPlanet,
  ) harmoniousDescription;
  final List<String> harmoniousPractices;

  // Sugestão de aspecto desafiador.
  final String challengingTitle;
  final String Function(
    String aspectName,
    String transitPlanet,
    String natalPlanet,
  ) challengingDescription;
  final List<String> challengingPractices;

  // Sugestão lunar.
  final String Function(String signName) moonSuggestionTitle;
  final String Function(String signName, String elementName)
      moonSuggestionDescription;
  final List<String> moonSuggestionPractices;
}

/// Textos do interpretador de trânsitos no idioma atual (fallback: português).
TransitInterpreterTexts get transitInterpreterTexts =>
    ContentLocale.instance.select(
      pt: transitInterpreterTextsPt,
      en: transitInterpreterTextsEn,
      es: transitInterpreterTextsEs,
    );
