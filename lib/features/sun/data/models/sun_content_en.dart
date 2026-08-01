import '../../../wheel_of_year/data/models/sabbat_model.dart' show SabbatType;
import 'sun_content_data.dart';

/// Solar knowledge — English.

const String sunIntroEn =
    'If the Moon rules the mysteries of the night, the Sun is the living '
    'force of the day: vitality, courage, success, healing and protection. '
    'Solar magic works with what is visible and conscious — action, the '
    'body, personal shine — and complements lunar magic, which tends to the '
    'invisible and the intuitive\n\n'
    'The Sun also marks the wheel of the year: the solstices and equinoxes '
    'are the four solar festivals of witchcraft. Every hour of the day has '
    'its own energy, from sunrise to sunset — one more tool in your '
    'grimoire';

const List<SolarSabbat> sunSabbatsEn = [
  (
    sabbat: SabbatType.yule,
    meaning: 'Winter Solstice: the longest night and the rebirth of the light'
  ),
  (
    sabbat: SabbatType.ostara,
    meaning: 'Spring Equinox: light and shadow in balance, everything awakens'
  ),
  (
    sabbat: SabbatType.litha,
    meaning: 'Summer Solstice: the peak of solar power, the longest day'
  ),
  (
    sabbat: SabbatType.mabon,
    meaning: 'Autumn Equinox: the second balance, gratitude for the harvest'
  ),
];

const List<String> sunCorrespondencesEn = [
  'Citrine',
  "Tiger's eye",
  'Amber',
  'Carnelian',
  'Sunflower',
  'Calendula',
  'Rosemary',
  'Chamomile',
  'Gold',
  'Golden',
  'Yellow',
  'Orange',
];

const List<SolarDeity> sunDeitiesEn = [
  (
    name: 'Ra',
    description:
        'The Egyptian sun god who crosses the sky in his barque, dying and being reborn each day'
  ),
  (
    name: 'Apollo',
    description:
        'Greek god of light, the arts, healing and prophecy — the shine that reveals the truth'
  ),
  (
    name: 'Amaterasu',
    description:
        'The great solar goddess of Shinto, whose emergence from the cave returned light to the world'
  ),
  (
    name: 'Sunna',
    description:
        'The Norse personification of the Sun, driving her chariot in perpetual flight across the sky'
  ),
  (
    name: 'Brigid',
    description:
        'Celtic lady of fire, the forge and inspiration — honored when the light begins to grow'
  ),
];
