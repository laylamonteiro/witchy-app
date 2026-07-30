import '../models/enums.dart';
import 'transit_interpreter_texts.dart';

/// Transit interpreter texts — English content.
///
/// Keep the same keys/structures across the three files
/// (`transit_interpreter_texts_pt/en/es.dart`) — parity is checked in
/// `test/astrology_interpreters_parity_test.dart`.
final TransitInterpreterTexts transitInterpreterTextsEn =
    TransitInterpreterTexts(
  phaseNames: const {
    'newMoon': 'New Moon',
    'waxingCrescent': 'Waxing Crescent',
    'firstQuarter': 'First Quarter',
    'waxingGibbous': 'Waxing Gibbous',
    'fullMoon': 'Full Moon',
    'waningGibbous': 'Waning Gibbous',
    'lastQuarter': 'Last Quarter',
    'waningCrescent': 'Waning Crescent',
  },
  phaseInterpretations: const {
    'newMoon': 'Ideal moment for new beginnings and magical intentions',
    'waxingCrescent': 'Growing energy favors manifestation and growth',
    'firstQuarter': 'Action and movement are favored',
    'waxingGibbous': 'Refinement and adjustments before the culmination',
    'fullMoon': 'Peak power for rituals and release',
    'waningGibbous': 'Gratitude and harvesting the fruits',
    'lastQuarter': 'A moment of release and cleansing',
    'waningCrescent': 'Introspection and banishing are favored',
  },
  phaseFallback: 'The moon guides your magical practices',
  moonInSign: (moonSignName, signQualities) =>
      'With the Moon in $moonSignName, emotions are $signQualities',
  energyDescriptions: const {
    EnergyLevel.intense: 'The day brings intense, transformative energy',
    EnergyLevel.challenging:
        'Planetary challenges call for attention and conscious work',
    EnergyLevel.moderate: 'The energy flow is balanced and stable',
    EnergyLevel.harmonious: 'The energies flow with harmony and ease',
  },
  phasePractices: const {
    'newMoon':
        'Setting intentions, planting magical seeds, manifestation work',
    'waxingCrescent':
        'Attraction spells, growing projects, green magic',
    'firstQuarter': 'Courage rituals, magical action, fire work',
    'waxingGibbous': 'Adjusting spells, refining practices',
    'fullMoon': 'Powerful rituals, charging tools, moon water',
    'waningGibbous': 'Gratitude, acknowledgment, offerings',
    'lastQuarter': 'Banishing, energy cleansing, cord cutting',
    'waningCrescent': 'Deep meditation, shadow work, divination',
  },
  practiceIntenseDay: 'Grounding and protection are essential today',
  practiceHarmoniousDay:
      'Excellent moment for complex spells and group work',
  phaseKeywords: const {
    'newMoon': ['renewal', 'intention', 'beginning'],
    'waxingCrescent': ['growth', 'expansion', 'manifestation'],
    'firstQuarter': ['action', 'movement', 'decision'],
    'waxingGibbous': ['refinement', 'patience', 'preparation'],
    'fullMoon': ['power', 'culmination', 'fullness'],
    'waningGibbous': ['gratitude', 'sharing', 'harvest'],
    'lastQuarter': ['release', 'cleansing', 'transformation'],
    'waningCrescent': ['introspection', 'wisdom', 'rest'],
  },
  keywordIntensity: 'intensity',
  keywordHarmony: 'harmony',
  transitAspect: (planet1, aspectSymbol, planet2, aspectQuality) =>
      '$planet1 $aspectSymbol $planet2: $aspectQuality energy',
  conjunctionTitle: (transitPlanet, natalPlanet) =>
      '$transitPlanet-$natalPlanet Conjunction',
  conjunctionDescription: (transitPlanet, natalPlanet) =>
      'This powerful aspect joins the energies of $transitPlanet and your '
      'natal $natalPlanet. It is a moment of deep integration.',
  conjunctionPractices: const [
    'Meditation focused on these energies',
    'Integration and alignment ritual',
    'Working with corresponding crystals',
  ],
  harmoniousTitle: 'Harmonious Energy Available',
  harmoniousDescription: (transitPlanet, aspectSymbol, natalPlanet) =>
      '$transitPlanet $aspectSymbol your natal $natalPlanet creates a '
      'positive flow of energy.',
  harmoniousPractices: const [
    'Manifestation and attraction spells',
    'Creative, inspired work',
    'Connection with spirit guides',
  ],
  challengingTitle: 'A Challenge for Growth',
  challengingDescription: (aspectName, transitPlanet, natalPlanet) =>
      'The $aspectName aspect between $transitPlanet and your natal '
      '$natalPlanet brings important lessons.',
  challengingPractices: const [
    'Shadow work and self-knowledge',
    'Banishing old patterns',
    'Protection and grounding',
  ],
  moonSuggestionTitle: (signName) => 'Moon in $signName',
  moonSuggestionDescription: (signName, elementName) =>
      'The Moon transits through $signName, bringing $elementName energies '
      'to your emotions and intuition.',
  moonSuggestionPractices: const [
    'Working with water and emotions',
    'Divination and intuitive reading',
    'Connection with lunar energy',
  ],
);
