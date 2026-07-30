import '../../../../core/content/content_locale.dart';
import '../models/enums.dart';
import 'planet_sign_interpretations_en.dart';
import 'planet_sign_interpretations_es.dart';
import 'planet_sign_interpretations_pt.dart';

/// Interpretações mágicas de cada planeta em cada signo, no idioma atual do
/// aplicativo. Para ajudar iniciantes a entenderem seu mapa astral de forma
/// prática.
///
/// O conteúdo por idioma vive em `planet_sign_interpretations_pt/en/es.dart`;
/// esta classe apenas seleciona a variante via [ContentLocale].
class PlanetSignInterpretations {
  /// Base de dados de interpretações no idioma atual.
  static Map<String, String> get _interpretations =>
      ContentLocale.instance.select(
        pt: planetSignInterpretationsPt,
        en: planetSignInterpretationsEn,
        es: planetSignInterpretationsEs,
      );

  /// Retorna a interpretação mágica de um planeta em um signo
  static String getInterpretation(Planet planet, ZodiacSign sign) {
    final key = '${planet.name}_${sign.name}';
    return _interpretations[key] ?? _getDefaultInterpretation(planet, sign);
  }

  /// Interpretação concisa (composta) para planetas externos, nodos e pontos
  /// místicos, que não têm texto próprio na base. Junta o tema do planeta com
  /// o estilo do signo e uma dica mágica — cobertura completa, sem escrever
  /// 12 textos por corpo. O texto por idioma vive nos arquivos irmãos
  /// `planet_sign_interpretations_pt/en/es.dart`.
  static String _getDefaultInterpretation(Planet planet, ZodiacSign sign) {
    return ContentLocale.instance.select(
      pt: planetSignDefaultInterpretationPt,
      en: planetSignDefaultInterpretationEn,
      es: planetSignDefaultInterpretationEs,
    )(planet, sign);
  }

  /// Retorna um resumo curto para exibição em lista
  static String getShortInterpretation(Planet planet, ZodiacSign sign) {
    return ContentLocale.instance.select(
      pt: planetSignShortInterpretationPt,
      en: planetSignShortInterpretationEn,
      es: planetSignShortInterpretationEs,
    )(planet, sign);
  }
}
