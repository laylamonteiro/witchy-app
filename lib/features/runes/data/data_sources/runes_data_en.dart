import '../models/rune_model.dart';

/// The 24 runes of the Elder Futhark — English content.
///
/// Names and symbols are invariant across languages; only keywords and
/// descriptions are translated. Keep the same order as `runes_data_pt.dart`
/// — parity is verified by `test/content_parity_test.dart`.
const List<Rune> runesEn = [
  Rune(
    name: 'Fehu',
    symbol: 'ᚠ',
    keywords: ['Prosperity', 'Wealth', 'Abundance'],
    description: 'Fehu represents movable wealth, prosperity and abundance. '
        'It symbolizes cattle, which was a form of wealth in ancient times. '
        'In readings, it suggests material gains, prosperous new beginnings '
        'and the energy needed to manifest your goals',
  ),
  Rune(
    name: 'Uruz',
    symbol: 'ᚢ',
    keywords: ['Strength', 'Vitality', 'Health'],
    description:
        'Uruz is the raw strength of nature, the vitality of the wild aurochs. '
        'It represents physical and mental strength, endurance and good health. '
        'It indicates a period of great energy, healing, or the need '
        'to face challenges with courage',
  ),
  Rune(
    name: 'Thurisaz',
    symbol: 'ᚦ',
    keywords: ['Protection', 'Defense', 'Challenge'],
    description:
        'Thurisaz is the thorn, or the hammer of Thor. It represents protection, '
        'but also conflict and challenge. It suggests the need to defend yourself '
        'or to confront obstacles. It can point to a situation that calls for '
        'caution and preparation',
  ),
  Rune(
    name: 'Ansuz',
    symbol: 'ᚨ',
    keywords: ['Communication', 'Wisdom', 'Inspiration'],
    description:
        'Ansuz is linked to Odin and represents divine communication, wisdom '
        'and inspiration. It symbolizes signs, messages and knowledge. '
        'In readings, it suggests that you are receiving guidance, '
        'or that you should pay attention to the signs around you',
  ),
  Rune(
    name: 'Raidho',
    symbol: 'ᚱ',
    keywords: ['Journey', 'Movement', 'Progress'],
    description:
        'Raidho is the rune of travel and movement. It represents physical '
        'and spiritual journeys, progress and evolution. It suggests that you '
        'are on a path of growth, or that it is time to move forward '
        'in some direction',
  ),
  Rune(
    name: 'Kenaz',
    symbol: 'ᚲ',
    keywords: ['Knowledge', 'Creativity', 'Illumination'],
    description:
        'Kenaz is the torch that lights up the darkness. It represents knowledge, '
        'creativity, inspiration and transformation through learning. '
        'It indicates a period of discoveries, creative insights or '
        'the development of skills',
  ),
  Rune(
    name: 'Gebo',
    symbol: 'ᚷ',
    keywords: ['Gift', 'Partnership', 'Exchange'],
    description:
        'Gebo represents gifts, generosity and balanced exchanges. '
        'It symbolizes partnerships, relationships and reciprocity. '
        'It suggests that you are in a period of giving and receiving, '
        'or that an important partnership is in the spotlight',
  ),
  Rune(
    name: 'Wunjo',
    symbol: 'ᚹ',
    keywords: ['Joy', 'Harmony', 'Fulfillment'],
    description:
        'Wunjo is the rune of joy, harmony and fulfillment. It represents '
        'happiness, contentment and times of peace. It indicates that you '
        'are, or soon will be, in a state of harmony and satisfaction with life',
  ),
  Rune(
    name: 'Hagalaz',
    symbol: 'ᚺ',
    keywords: ['Disruption', 'Change', 'Purification'],
    description: 'Hagalaz is hail - a disruptive force of nature. '
        'It represents sudden changes, unexpected events and purification. '
        'It can indicate a period of challenges that lead to transformation '
        'and growth',
  ),
  Rune(
    name: 'Nauthiz',
    symbol: 'ᚾ',
    keywords: ['Need', 'Endurance', 'Overcoming'],
    description: 'Nauthiz represents need, constraint and endurance. '
        'It symbolizes hard times that demand patience and perseverance. '
        'It suggests that you are facing limitations, but that you can '
        'overcome them through determination',
  ),
  Rune(
    name: 'Isa',
    symbol: 'ᛁ',
    keywords: ['Pause', 'Stillness', 'Introspection'],
    description:
        'Isa is ice - motionless and preserving. It represents pause, stillness '
        'and the need for introspection. It suggests a period of waiting, '
        'reflection, or the freezing of a situation. It is not always negative; '
        'sometimes we need to stop and take stock',
  ),
  Rune(
    name: 'Jera',
    symbol: 'ᛃ',
    keywords: ['Harvest', 'Cycles', 'Reward'],
    description: 'Jera represents the harvest and the natural cycles of time. '
        'It symbolizes rewards for past efforts and the importance '
        'of timing. It suggests that you will reap what you have sown, or that '
        'it is important to respect the natural cycles of things',
  ),
  Rune(
    name: 'Eihwaz',
    symbol: 'ᛇ',
    keywords: ['Protection', 'Endurance', 'Transformation'],
    description:
        'Eihwaz is the yew - tree of life and death. It represents protection, '
        'endurance and deep transformation. It symbolizes the ability to '
        'survive and adapt, even under difficult conditions',
  ),
  Rune(
    name: 'Perthro',
    symbol: 'ᛈ',
    keywords: ['Mystery', 'Fate', 'Hidden'],
    description:
        'Perthro is the dice cup - it represents mystery, fate and the '
        'unknown. It symbolizes secrets, hidden things and the element '
        'of chance in life. It suggests there are forces at play beyond what you '
        'can see or control',
  ),
  Rune(
    name: 'Algiz',
    symbol: 'ᛉ',
    keywords: ['Protection', 'Defense', 'Divine Connection'],
    description: 'Algiz represents divine protection and spiritual connection. '
        'It symbolizes the hand raised in protection, or the antlers of the elk. '
        'It suggests that you are protected, or that you should seek spiritual '
        'guidance and trust your intuition',
  ),
  Rune(
    name: 'Sowilo',
    symbol: 'ᛊ',
    keywords: ['Success', 'Vitality', 'Illumination'],
    description: 'Sowilo is the sun - source of life and energy. It represents '
        'success, vitality, clarity and illumination. It is an extremely positive '
        'rune that indicates victory, achievement and radiant solar energy',
  ),
  Rune(
    name: 'Tiwaz',
    symbol: 'ᛏ',
    keywords: ['Justice', 'Honor', 'Leadership'],
    description:
        'Tiwaz is linked to the god Tyr and represents justice, honor and '
        'leadership. It symbolizes sacrifice for a greater good and victory '
        'through integrity. It suggests that you should act with honor '
        'and lead by example',
  ),
  Rune(
    name: 'Berkano',
    symbol: 'ᛒ',
    keywords: ['Growth', 'Fertility', 'Renewal'],
    description: 'Berkano is the birch - tree of rebirth and fertility. '
        'It represents new beginnings, growth, care and nurturing. '
        'It symbolizes processes of gradual growth, both physical and '
        'spiritual',
  ),
  Rune(
    name: 'Ehwaz',
    symbol: 'ᛖ',
    keywords: ['Partnership', 'Trust', 'Movement'],
    description:
        'Ehwaz represents the horse - a symbol of partnership and trust. '
        'It symbolizes the bond between horse and rider, suggesting cooperation, '
        'loyalty and moving forward together. It indicates harmonious '
        'partnerships and progress through collaboration',
  ),
  Rune(
    name: 'Mannaz',
    symbol: 'ᛗ',
    keywords: ['Humanity', 'Self-awareness', 'Community'],
    description:
        'Mannaz represents humanity and self-awareness. It symbolizes '
        'the human mind, society and our connection with one another. '
        'It suggests reflecting on your role in the community and developing '
        'your consciousness',
  ),
  Rune(
    name: 'Laguz',
    symbol: 'ᛚ',
    keywords: ['Water', 'Intuition', 'Flow'],
    description:
        'Laguz is water - source of life and of the unconscious. It represents '
        'intuition, emotions and the natural flow of life. It suggests that you '
        'should trust your instincts and go with the flow, adapting '
        'to circumstances',
  ),
  Rune(
    name: 'Ingwaz',
    symbol: 'ᛜ',
    keywords: ['Fertility', 'Potential', 'Gestation'],
    description:
        'Ingwaz is linked to the god Ing and represents fertility and potential. '
        'It symbolizes periods of gestation - when something is developing '
        'inwardly before it becomes manifest. It suggests a time of '
        'preparation and cultivation',
  ),
  Rune(
    name: 'Dagaz',
    symbol: 'ᛞ',
    keywords: ['Day', 'Awakening', 'Transformation'],
    description:
        'Dagaz is the day - the dawn after the night. It represents '
        'transformation, awakening and new beginnings. It symbolizes the moment '
        'of clarity when everything lights up. It indicates an important turning '
        'point or a transformative revelation',
  ),
  Rune(
    name: 'Othala',
    symbol: 'ᛟ',
    keywords: ['Inheritance', 'Home', 'Ancestry'],
    description: 'Othala represents ancestral inheritance, home and property. '
        'It symbolizes roots, family traditions and legacies. It suggests '
        'connection with your roots, matters of home and family, or the '
        'receiving of an inheritance (material or spiritual)',
  ),
];
