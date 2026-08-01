import '../../../grimoire/data/models/spell_model.dart' show MoonPhase;
import 'moon_content_data.dart';

/// Lunar knowledge — English.

const String moonIntroEn =
    'The Moon is the great clock of witchcraft. Her cycle of about 29.5 days '
    'sets the rhythm of magical workings: what grows with her grows stronger; '
    'what wanes with her dissolves more easily. Practitioners of every '
    'tradition watch the phase, the hour and even the position of the Moon to '
    'choose the right moment for each spell\n\n'
    'More than a calendar, the Moon is a symbol: she rules the tides, the '
    'emotions, intuition and the mysteries of the unconscious. To work '
    'aligned with her is to work with the current — not against it';

const Map<MoonPhase, MoonPhaseKnowledge> moonPhaseKnowledgeEn = {
  MoonPhase.newMoon: (
    favors:
        'The dark sky is the blank page of the cycle: a moment to plant intentions, start projects and turn inward to hear your intuition',
    goodFor: ['Intentions', 'New beginnings', 'Introspection', 'Final banishings'],
  ),
  MoonPhase.waxingCrescent: (
    favors:
        'The first growing light gives traction to what was planted: time to take the first steps and feed what should grow',
    goodFor: ['Attraction', 'Growth', 'Early courage', 'Prosperity'],
  ),
  MoonPhase.firstQuarter: (
    favors:
        'Half light, half shadow: the phase of decision and action. Overcome obstacles and adjust the course of your workings',
    goodFor: ['Action', 'Decisions', 'Willpower', 'Breaking blocks'],
  ),
  MoonPhase.waxingGibbous: (
    favors:
        'Almost full, the Moon asks for refinement: persist, polish the details and prepare the harvest that comes with the full moon',
    goodFor: ['Persistence', 'Refinement', 'Patience', 'Final adjustments'],
  ),
  MoonPhase.fullMoon: (
    favors:
        'The peak of lunar power illuminates everything: manifest intentions, charge crystals and tools, make moon water and practice divination',
    goodFor: ['Manifestation', 'Charging crystals', 'Moon water', 'Divination'],
  ),
  MoonPhase.waningGibbous: (
    favors:
        'Right after the peak, the energy invites gratitude and sharing: give thanks for what bloomed and teach what you learned',
    goodFor: ['Gratitude', 'Sharing', 'Teaching', 'Harvest'],
  ),
  MoonPhase.lastQuarter: (
    favors:
        'The fading light helps you let go: release habits, forgive, close cycles and do deep cleansings',
    goodFor: ['Release', 'Forgiveness', 'Cleansing', 'Closures'],
  ),
  MoonPhase.waningCrescent: (
    favors:
        'The end of the cycle asks for rest and silence: banish what remains, rest your body and prepare the ground for the next new moon',
    goodFor: ['Banishment', 'Rest', 'Protection', 'Silence'],
  ),
};

const String moonEsbatsIntroEn =
    'Esbats are the celebrations of the full moon — the "working" gatherings '
    'of witchcraft, in contrast with the sabbats, which celebrate the Sun and '
    'the wheel of the year. At each esbat the Moon is honored at the height '
    'of her power and the most important spells of the month are performed';

const List<EsbatItem> moonEsbatItemsEn = [
  (
    emoji: '🌕',
    title: 'When',
    text:
        'On the night of the full moon — there are 12 or 13 a year, and many traditions name each one (Wolf Moon, Flower Moon, Harvest Moon...)',
  ),
  (
    emoji: '🕯️',
    title: 'The altar',
    text: 'Set white or silver candles and offer water or milk to the Moon',
  ),
  (
    emoji: '💎',
    title: 'Charging energy',
    text:
        'Leave crystals and tools under the moonlight to renew their power',
  ),
  (
    emoji: '🫙',
    title: 'Moon water',
    text: 'Make moon water at the height of lunar power',
  ),
  (
    emoji: '🔮',
    title: 'Divination',
    text: 'Save a moment for tarot, runes or your favorite oracle',
  ),
  (
    emoji: '✨',
    title: 'Simplicity',
    text: 'Even lighting a candle and giving thanks is already an esbat',
  ),
];

const List<LunarDeity> moonDeitiesEn = [
  (
    name: 'Selene',
    description:
        'The Moon herself in ancient Greece: the titaness who crosses the night sky in her silver chariot',
  ),
  (
    name: 'Artemis',
    description:
        'Greek goddess of the hunt and the waxing moon, protector of wild nature and independence',
  ),
  (
    name: 'Hecate',
    description:
        'Lady of the crossroads, of magic and the dark moon — the great witch among the goddesses',
  ),
  (
    name: 'Isis',
    description:
        'Great sorceress of Egypt, tied to the moon, the mysteries and healing',
  ),
  (
    name: 'Yemanja',
    description:
        'Queen of the sea in Afro-Brazilian traditions, tied to the moon, the tides and motherhood',
  ),
];

const List<String> moonCorrespondencesEn = [
  'Moonstone',
  'Selenite',
  'Clear quartz',
  'Amethyst',
  'Jasmine',
  'Mugwort',
  'Lavender',
  'Chamomile',
  'Silver',
  'Silver (color)',
  'White',
];
