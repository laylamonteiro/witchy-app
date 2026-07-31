import 'journey_model.dart' show JourneyText;

/// Journey texts — English. Ids are invariant.
/// Paridade verificada em test/content_models_parity_test.dart.
const Map<String, JourneyText> journeyTextsEn = {
  'iniciante_01': (title: 'First Steps', description: 'Begin your magical journey by learning the basics'),
  'grimorio_01': (title: 'Grimoire Master', description: 'Build a powerful grimoire with your spells'),
  'gratidao_01': (title: 'Grateful Heart', description: 'Cultivate gratitude in your daily life'),
  'sonhos_01': (title: 'Dream Traveler', description: 'Explore the world of dreams'),
  'divinacao_01': (title: 'Seer', description: 'Master the divinatory arts'),
  'desejos_01': (title: 'Manifestor', description: 'Learn to manifest your desires'),
};

const Map<String, JourneyText> journeyStepTextsEn = {
  'ini_01_01': (title: 'Create your first spell', description: 'Record your first spell in the grimoire'),
  'ini_01_02': (title: 'Write in the dream journal', description: 'Record a dream in your journal'),
  'ini_01_03': (title: 'Practice gratitude', description: 'Write your first gratitude entry'),
  'ini_01_04': (title: 'Consult the runes', description: 'Do your first rune reading'),
  'ini_01_05': (title: 'Discover your birth chart', description: 'Generate your complete birth chart'),
  'grim_01_01': (title: 'Apprentice', description: 'Create 5 spells'),
  'grim_01_02': (title: 'Practitioner', description: 'Create 10 spells'),
  'grim_01_03': (title: 'Master', description: 'Create 25 spells'),
  'grim_01_04': (title: 'Archmage', description: 'Create 50 spells'),
  'grat_01_01': (title: 'Awakening', description: 'Practice gratitude for 3 days in a row'),
  'grat_01_02': (title: 'Habit', description: 'Practice gratitude for 7 days in a row'),
  'grat_01_03': (title: 'Devotion', description: 'Practice gratitude for 21 days in a row'),
  'grat_01_04': (title: 'Illumination', description: 'Practice gratitude for 30 days in a row'),
  'son_01_01': (title: 'First Entry', description: 'Record your first dream'),
  'son_01_02': (title: 'Devoted Dreamer', description: 'Record 10 dreams'),
  'son_01_03': (title: 'Dream Master', description: 'Record 30 dreams'),
  'son_01_04': (title: 'Oneiric Oracle', description: 'Record 50 dreams'),
  'div_01_01': (title: 'Rune Initiation', description: 'Do 5 rune readings'),
  'div_01_02': (title: 'Oracle Reader', description: 'Do 5 oracle readings'),
  'div_01_03': (title: 'Pendulum Master', description: 'Do 10 pendulum consultations'),
  'div_01_04': (title: 'Complete Oracle', description: 'Do 25 readings in total'),
  'des_01_01': (title: 'First Desire', description: 'Record your first desire'),
  'des_01_02': (title: 'Wish List', description: 'Record 10 desires'),
  'des_01_03': (title: 'First Manifestation', description: 'Manifest your first desire'),
  'des_01_04': (title: 'Master Manifestor', description: 'Manifest 5 desires'),
};
