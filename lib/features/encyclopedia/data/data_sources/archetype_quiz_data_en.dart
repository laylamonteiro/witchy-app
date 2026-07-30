import '../models/archetype_quiz_model.dart';

/// Archetype Quiz questions — English content.
///
/// Each option's `archetypeEmoji` key is invariant across languages and
/// matches `ArcaneEntry.emoji` in `archetypes_data_pt/en/es.dart`:
/// 🧙‍♀️ The Witch · 🌿 The Healer · 👁️ The Seer · 🛡️ The Guardian ·
/// 🦉 The Wise Woman · 🌸 The Maiden · 🤱 The Mother · 🏹 The Huntress ·
/// 🕸️ The Weaver · ⚗️ The Alchemist · 🌑 The Shadow Queen.
/// Keep the same order/count in all three files — parity is checked in
/// `test/encyclopedia_content_parity_test.dart`.
const List<ArchetypeQuizQuestion> archetypeQuizQuestionsEn = [
  ArchetypeQuizQuestion('On a hard day, what restores you most?', [
    ArchetypeQuizOption(
        'Being in silence with myself, away from everyone', '🦉'),
    ArchetypeQuizOption(
        'Brewing a tea, taking a bath, caring for my body', '🌿'),
    ArchetypeQuizOption(
        'Going out into nature, wandering with no destination', '🏹'),
    ArchetypeQuizOption('Organizing my home and my plans', '🛡️'),
    ArchetypeQuizOption(
        'Creating something new: cooking, drawing, inventing', '⚗️'),
    ArchetypeQuizOption(
        'Putting on a song and dancing like no one is watching', '🌸'),
  ]),
  ArchetypeQuizQuestion('Which of these gifts would enchant you most?', [
    ArchetypeQuizOption('An old tarot deck', '👁️'),
    ArchetypeQuizOption('A blank, hand-bound notebook', '🕸️'),
    ArchetypeQuizOption('A kit of herbs and essential oils', '🌿'),
    ArchetypeQuizOption('A rare book of mysteries', '⚗️'),
    ArchetypeQuizOption('A black cloak that trails along the floor', '🧙‍♀️'),
    ArchetypeQuizOption('An album of old family photographs', '🤱'),
  ]),
  ArchetypeQuizQuestion(
      'How do you react when someone you love is threatened?', [
    ArchetypeQuizOption('I become a wall: no one gets past me', '🛡️'),
    ArchetypeQuizOption('I embrace and tend the wounds first', '🤱'),
    ArchetypeQuizOption('I face it head-on, without hesitating', '🏹'),
    ArchetypeQuizOption('I sense the threat before anyone else', '👁️'),
    ArchetypeQuizOption(
        'I confront the aggressor with a truth no one has spoken', '🌑'),
    ArchetypeQuizOption(
        'I tie up the loose ends: I find out who, how, and why', '🕸️'),
  ]),
  ArchetypeQuizQuestion(
      'What draws you most to the path of witchcraft?', [
    ArchetypeQuizOption('The freedom to be who I am', '🧙‍♀️'),
    ArchetypeQuizOption('Turning pain into wisdom', '⚗️'),
    ArchetypeQuizOption('The dreams, signs, and omens', '👁️'),
    ArchetypeQuizOption(
        'The cycles, patterns, and connections of everything', '🕸️'),
    ArchetypeQuizOption('The power to heal myself and my own', '🌿'),
    ArchetypeQuizOption(
        'Protecting those I love with something greater than me', '🛡️'),
  ]),
  ArchetypeQuizQuestion('Which phrase sounds most like you?', [
    ArchetypeQuizOption(
        '"I begin again as many times as I need to"', '🌸'),
    ArchetypeQuizOption('"I make everything I touch grow"', '🤱'),
    ArchetypeQuizOption('"I owe explanations to no one"', '🧙‍♀️'),
    ArchetypeQuizOption('"I have seen this story before"', '🦉'),
    ArchetypeQuizOption(
        '"I go where no one else has dared to go"', '🏹'),
    ArchetypeQuizOption('"I see what has not yet come to pass"', '👁️'),
  ]),
  ArchetypeQuizQuestion('Facing your own shadow, you…', [
    ArchetypeQuizOption(
        'Descend into it: I want to know it whole', '🌑'),
    ArchetypeQuizOption(
        'Transform it: nothing in me is waste, everything is raw material',
        '⚗️'),
    ArchetypeQuizOption(
        'Listen to what it has to say, without rushing', '🦉'),
    ArchetypeQuizOption(
        'Illuminate it with healing practices and self-compassion', '🌿'),
    ArchetypeQuizOption(
        'Face it like prey: I stare it down until it retreats', '🏹'),
    ArchetypeQuizOption(
        'Laugh with it: shadow is also part of my freedom', '🧙‍♀️'),
  ]),
  ArchetypeQuizQuestion(
      'Your favorite spot at a mystical festival would be…', [
    ArchetypeQuizOption('The dancing circle, in the middle of the joy', '🌸'),
    ArchetypeQuizOption('The tent of readings and oracles', '👁️'),
    ArchetypeQuizOption('The bonfire, telling ancient stories', '🦉'),
    ArchetypeQuizOption(
        'The craft stall: knots, threads, and amulets', '🕸️'),
    ArchetypeQuizOption('The communal kitchen, feeding everyone', '🤱'),
    ArchetypeQuizOption('The midnight ritual, far from the lights', '🌑'),
  ]),
  ArchetypeQuizQuestion('What do people seek most in you?', [
    ArchetypeQuizOption('Protection: with me they feel safe', '🛡️'),
    ArchetypeQuizOption('Comfort: warmth and encouragement', '🤱'),
    ArchetypeQuizOption('Courage: I go first', '🏹'),
    ArchetypeQuizOption('Truth: I say what no one dares to', '🌑'),
    ArchetypeQuizOption(
        'Lightness: I remind them that beginning again is possible', '🌸'),
    ArchetypeQuizOption(
        'Transformation: I come out better from everything that crosses me',
        '⚗️'),
  ]),
];
