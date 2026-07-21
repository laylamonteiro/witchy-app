import '../models/enums.dart';
import '../models/transit_model.dart';

/// Contenido del Clima Mágico Diario — español.
///
/// Los símbolos públicos reflejan `daily_weather_content_pt.dart`; solo el
/// texto está traducido. La paridad se verifica en
/// `test/daily_weather_content_parity_test.dart`.

/// Títulos de sección usados en la vista previa Free cuando el markdown
/// generado no tiene encabezados propios. Reflejan la estructura editorial
/// de la previsión.
const List<String> dailyWeatherFallbackHeadingsEs = [
  'Energía del Día',
  'La Luna Hoy',
  'Oportunidades Mágicas',
  'Cuidados del Día',
  'Ritual Sugerido',
  'Cristales y Aliados',
  'Mensaje de las Estrellas',
];

/// Frase-placeholder mostrada desenfocada en lugar del cuerpo Premium.
const String dailyWeatherPremiumPlaceholderEs =
    'Las influencias del día revelan orientaciones y prácticas mágicas personalizadas para este momento.';

// Nombres localizados — los getters de los enums (`displayName`) devuelven
// texto en portugués, así que la plantilla en español resuelve los nombres
// desde estos mapas indexados por los valores invariantes de los enums.
const Map<ZodiacSign, String> _signNamesEs = {
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

const Map<Element, String> _elementNamesEs = {
  Element.fire: 'Fuego',
  Element.earth: 'Tierra',
  Element.air: 'Aire',
  Element.water: 'Agua',
};

/// Texto de respaldo (markdown) usado cuando falla la generación por IA.
String dailyWeatherFallbackTextEs(DailyMagicalWeather weather) {
  return '''## Energía del Día

${weather.generalInterpretation}

## La Luna Hoy

La Luna está en ${_signNamesEs[weather.moonSign]}, trayendo energías del elemento ${_elementNamesEs[weather.moonSign.element]}.
Fase actual: ${weather.moonPhase}.

## Oportunidades Mágicas

${weather.recommendedPractices.map((p) => '- $p').join('\n')}

## Cristales y Aliados

- Cuarzo transparente (equilibrio general)
- Amatista (protección espiritual)
- Piedra Luna (conexión lunar)

## Mensaje de las Estrellas

Permite que las energías celestes guíen tu camino hoy. Confía en tu intuición y sigue el flujo del universo.
''';
}
