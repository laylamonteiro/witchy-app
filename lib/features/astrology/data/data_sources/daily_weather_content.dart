import '../../../../core/content/content_locale.dart';
import '../models/transit_model.dart';
import 'daily_weather_content_en.dart';
import 'daily_weather_content_es.dart';
import 'daily_weather_content_pt.dart';

/// Conteúdo gerado/interpretativo do Clima Mágico Diário no idioma atual do
/// aplicativo (texto de fallback da previsão, títulos da prévia Free e
/// placeholder premium).
///
/// O conteúdo por idioma vive em `daily_weather_content_pt/en/es.dart`; esta
/// classe apenas seleciona a variante via [ContentLocale].
///
/// Importante: o texto da previsão é PERSISTIDO por dia na tabela
/// `daily_magical_weather` (ver `DailyWeatherRepository`). Textos já salvos
/// não são reescritos ao trocar de idioma — apenas gerações novas usam o
/// locale atual.
class DailyWeatherContent {
  DailyWeatherContent._();

  /// Texto de fallback (markdown) da previsão quando a geração por IA falha.
  static String fallbackText(DailyMagicalWeather weather) {
    return ContentLocale.instance.select(
      pt: dailyWeatherFallbackTextPt,
      en: dailyWeatherFallbackTextEn,
      es: dailyWeatherFallbackTextEs,
    )(weather);
  }

  /// Um texto de previsão persistido é considerado completo quando traz as
  /// seções que só existem na versão nova (IA ou fallback de 7 seções).
  ///
  /// A checagem aceita os cabeçalhos de QUALQUER um dos três idiomas: textos
  /// salvos em EN/ES não podem ser tratados como incompletos (e regerados a
  /// cada abertura) por uma verificação apenas em português.
  static bool looksComplete(String text) {
    const requiredPairsByLocale = [
      ['## Ritual Sugerido', '## Cuidados do Dia'], // pt
      ['## Suggested Ritual', '## Cautions for the Day'], // en
      ['## Ritual Sugerido', '## Cuidados del Día'], // es
    ];
    return requiredPairsByLocale.any((pair) => pair.every(text.contains));
  }

  /// Títulos de seção da prévia Free quando o markdown da previsão não tem
  /// cabeçalhos próprios.
  static List<String> get fallbackHeadings => ContentLocale.instance.select(
        pt: dailyWeatherFallbackHeadingsPt,
        en: dailyWeatherFallbackHeadingsEn,
        es: dailyWeatherFallbackHeadingsEs,
      );

  /// Frase-placeholder exibida desfocada no lugar do corpo Premium.
  static String get premiumPlaceholder => ContentLocale.instance.select(
        pt: dailyWeatherPremiumPlaceholderPt,
        en: dailyWeatherPremiumPlaceholderEn,
        es: dailyWeatherPremiumPlaceholderEs,
      );
}
