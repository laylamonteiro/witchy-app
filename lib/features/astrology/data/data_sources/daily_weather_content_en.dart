import '../models/enums.dart';
import '../models/transit_model.dart';

/// Daily Magical Weather content — English.
///
/// Public symbols mirror `daily_weather_content_pt.dart`; only the text is
/// translated. Parity is verified in
/// `test/daily_weather_content_parity_test.dart`.

/// Section headings used in the Free preview when the generated markdown has
/// no headings of its own. They mirror the forecast's editorial structure.
const List<String> dailyWeatherFallbackHeadingsEn = [
  'Energy of the Day',
  'The Moon Today',
  'Magical Opportunities',
  'Cautions for the Day',
  'Suggested Ritual',
  'Crystals and Allies',
  'Message from the Stars',
];

/// Placeholder sentence shown blurred in place of the Premium forecast body.
const String dailyWeatherPremiumPlaceholderEn =
    'The influences of the day reveal personalized magical guidance and practices for this moment.';

// Localized names — the enum getters (`displayName`) return Portuguese text,
// so the English template resolves names from these maps keyed by the
// invariant enum values.
const Map<ZodiacSign, String> _signNamesEn = {
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

const Map<Element, String> _elementNamesEn = {
  Element.fire: 'Fire',
  Element.earth: 'Earth',
  Element.air: 'Air',
  Element.water: 'Water',
};

/// Fallback (markdown) text used when AI generation fails. It keeps the SAME
/// 7 sections as the AI text (Energy, Moon, Opportunities, Cautions, Ritual,
/// Crystals, Message) so the daily weather stays complete even without AI.
String dailyWeatherFallbackTextEn(DailyMagicalWeather weather) {
  final element = _elementNamesEn[weather.moonSign.element]!;
  final sign = _signNamesEn[weather.moonSign]!;

  final challenges = weather.aspects
      .where((a) => a.energyLevel == EnergyLevel.challenging)
      .take(2)
      .map((a) =>
          '- ${a.description}: act calmly and avoid reacting on impulse.')
      .toList();
  final cautions = challenges.isNotEmpty
      ? challenges.join('\n')
      : '- No major tensions today. Even so, avoid rushed decisions and set aside a quiet moment to center yourself.';

  return '''## Energy of the Day

${weather.generalInterpretation}

## The Moon Today

The Moon is in $sign, bringing energies of the $element element.
Current phase: ${weather.moonPhase}.

## Magical Opportunities

${weather.recommendedPractices.map((p) => '- $p').join('\n')}

## Cautions for the Day

$cautions

## Suggested Ritual

Light a candle and take three deep breaths, attuning yourself to the $element element of the Moon in $sign. Set a simple, clear intention for the day and visualize it coming true.

## Crystals and Allies

- Clear quartz (overall balance)
- Amethyst (spiritual protection)
- Moonstone (lunar connection)

## Message from the Stars

Allow the celestial energies to guide your path today. Trust your intuition and follow the flow of the universe.
''';
}
