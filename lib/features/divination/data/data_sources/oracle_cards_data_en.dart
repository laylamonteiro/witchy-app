import '../models/oracle_card_model.dart';

/// The 44 Oracle cards — English content.
///
/// The `id` and `emoji` fields are invariant across languages; name, message,
/// guidance and keywords are translated. Keep the same order as
/// `oracle_cards_data_pt.dart` — parity is verified by
/// `test/content_parity_test.dart`.
const List<OracleCard> oracleCardsEn = [
  OracleCard(
    id: 1,
    name: 'The Full Moon',
    message: 'It is time to harvest what you have sown',
    emoji: '🌕',
    guidance: 'The Full Moon lights up your journey and brings to the surface all '
        'that was hidden. This is a moment of culmination and fulfillment. '
        'Your efforts are bearing fruit',
    keywords: ['fulfillment', 'illumination', 'culmination'],
  ),
  OracleCard(
    id: 2,
    name: 'The New Moon',
    message: 'New beginnings await',
    emoji: '🌑',
    guidance: 'The New Moon is a portal to new beginnings. '
        'Plant your intentions now and watch them grow. This is the perfect moment to start',
    keywords: ['new beginnings', 'intention', 'sowing'],
  ),
  OracleCard(
    id: 3,
    name: 'The Cauldron',
    message: 'Transformation is underway',
    emoji: '🪄',
    guidance: 'Inside the cauldron, elements blend and transform. '
        'You are in the midst of a deep transformation. Trust the process',
    keywords: ['transformation', 'alchemy', 'change'],
  ),
  OracleCard(
    id: 4,
    name: 'The Broom',
    message: 'Clear out what no longer serves you',
    emoji: '🧹',
    guidance: 'The broom sweeps away stagnant energies. It is time for a deep '
        'cleansing in your life. Release the old to make room for the new',
    keywords: ['cleansing', 'release', 'renewal'],
  ),
  OracleCard(
    id: 5,
    name: 'The Grimoire',
    message: 'Ancestral knowledge is within reach',
    emoji: '📖',
    guidance: 'The grimoire holds ancient wisdom. Study, learn and connect '
        'with the teachings of the ancients. Knowledge is power',
    keywords: ['wisdom', 'study', 'ancestry'],
  ),
  OracleCard(
    id: 6,
    name: 'The Candle',
    message: 'Your inner light shines bright',
    emoji: '🕯️',
    guidance: 'The candle\'s flame never wavers. Your inner light is powerful and '
        'constant. Trust your own wisdom and intuition',
    keywords: ['inner light', 'faith', 'clarity'],
  ),
  OracleCard(
    id: 7,
    name: 'The Crystal',
    message: 'Clarity and healing are on their way',
    emoji: '💎',
    guidance: 'Crystals amplify energy and bring healing. You are entering a '
        'period of greater clarity and well-being. Allow yourself to heal',
    keywords: ['healing', 'clarity', 'amplification'],
  ),
  OracleCard(
    id: 8,
    name: 'The Pentagram',
    message: 'Divine protection is with you',
    emoji: '⭐',
    guidance: 'The pentagram is a symbol of protection. You are safe and shielded '
        'by divine forces. No harm can reach you',
    keywords: ['protection', 'safety', 'divine'],
  ),
  OracleCard(
    id: 9,
    name: 'The Athame',
    message: 'Cut away what no longer serves',
    emoji: '🗡️',
    guidance: 'The athame cuts with precision. It is time to make firm decisions and '
        'let go of whatever no longer resonates with you',
    keywords: ['decision', 'cutting', 'firmness'],
  ),
  OracleCard(
    id: 10,
    name: 'The Chalice',
    message: 'Receive the blessings being offered',
    emoji: '🏆',
    guidance: 'The chalice is full of blessings waiting to be received. '
        'Open yourself to receive love, abundance and joy',
    keywords: ['receiving', 'blessings', 'abundance'],
  ),
  OracleCard(
    id: 11,
    name: 'The Fire',
    message: 'Passion and action are called for',
    emoji: '🔥',
    guidance: 'Fire burns, transforms and illuminates. It is time to act with passion '
        'and determination. Let your inner fire guide you',
    keywords: ['passion', 'action', 'transformation'],
  ),
  OracleCard(
    id: 12,
    name: 'The Earth',
    message: 'Stability and manifestation',
    emoji: '🌍',
    guidance: 'The Earth offers a solid foundation. Your intentions are manifesting '
        'on the physical plane. Stay steady on your path',
    keywords: ['stability', 'manifestation', 'grounding'],
  ),
  OracleCard(
    id: 13,
    name: 'The Air',
    message: 'New thoughts and ideas are flowing',
    emoji: '💨',
    guidance: 'The Air brings mental clarity and fresh perspectives. Open your mind to '
        'new ideas and new ways of thinking',
    keywords: ['mental clarity', 'ideas', 'communication'],
  ),
  OracleCard(
    id: 14,
    name: 'The Water',
    message: 'Flow with your emotions',
    emoji: '💧',
    guidance: 'Water teaches us to flow. Allow yourself to feel deeply and '
        'follow the current of your emotions with confidence',
    keywords: ['emotions', 'intuition', 'fluidity'],
  ),
  OracleCard(
    id: 15,
    name: 'The Owl',
    message: 'Hidden wisdom reveals itself',
    emoji: '🦉',
    guidance: 'The Owl sees through the darkness. Secrets and hidden wisdom '
        'are being revealed to you. Pay attention',
    keywords: ['wisdom', 'revelation', 'vision'],
  ),
  OracleCard(
    id: 16,
    name: 'The Black Cat',
    message: 'Magic is all around you',
    emoji: '🐈‍⬛',
    guidance: 'The Black Cat walks between worlds. You are surrounded by magic '
        'and synchronicities. Recognize the signs',
    keywords: ['magic', 'mystery', 'synchronicity'],
  ),
  OracleCard(
    id: 17,
    name: 'The Serpent',
    message: 'Rebirth and deep healing',
    emoji: '🐍',
    guidance: 'The Serpent sheds its skin and is reborn. You are going through a '
        'profound transformation. Let the old die so you can be reborn',
    keywords: ['rebirth', 'healing', 'transformation'],
  ),
  OracleCard(
    id: 18,
    name: 'The Spider',
    message: 'You are the weaver of your own web',
    emoji: '🕷️',
    guidance: 'The Spider patiently weaves its web. You are creating your own '
        'reality. Weave it with intention and care',
    keywords: ['creation', 'patience', 'destiny'],
  ),
  OracleCard(
    id: 19,
    name: 'The Raven',
    message: 'Messages from the unseen realms',
    emoji: '🐦‍⬛',
    guidance: 'The Raven is a messenger between worlds. Pay attention to the messages '
        'that arrive in unexpected ways',
    keywords: ['message', 'magic', 'mystery'],
  ),
  OracleCard(
    id: 20,
    name: 'The Rose',
    message: 'Love and beauty are blossoming',
    emoji: '🌹',
    guidance: 'The Rose symbolizes love in its purest form. Open your heart '
        'to give and receive true love',
    keywords: ['love', 'beauty', 'openness'],
  ),
  OracleCard(
    id: 21,
    name: 'The Tree',
    message: 'Deep roots and steady growth',
    emoji: '🌳',
    guidance: 'The Tree stands firm in its roots while growing toward the sky. '
        'Balance grounding with expansion',
    keywords: ['grounding', 'growth', 'balance'],
  ),
  OracleCard(
    id: 22,
    name: 'The Stars',
    message: 'Hope and divine guidance',
    emoji: '⭐',
    guidance: 'The Stars guide the lost. Even in darkness, there is light and hope. '
        'Trust the guidance you receive',
    keywords: ['hope', 'guide', 'guidance'],
  ),
  OracleCard(
    id: 23,
    name: 'The Sun',
    message: 'Joy and vitality arrive',
    emoji: '☀️',
    guidance: 'The Sun shines at full strength. This is a period of joy, '
        'vitality and success. Let your light shine!',
    keywords: ['joy', 'vitality', 'success'],
  ),
  OracleCard(
    id: 24,
    name: 'The Storm',
    message: 'After the storm comes the calm',
    emoji: '⛈️',
    guidance: 'Storms pass and bring renewal. If you are facing challenges, '
        'know that they are temporary',
    keywords: ['challenge', 'renewal', 'temporary'],
  ),
  OracleCard(
    id: 25,
    name: 'The Rainbow',
    message: 'A promise of better times',
    emoji: '🌈',
    guidance: 'The Rainbow is a sign of hope and promise. Better times '
        'are on their way. Keep the faith',
    keywords: ['hope', 'promise', 'beauty'],
  ),
  OracleCard(
    id: 26,
    name: 'The Key',
    message: 'You hold the key to the answer',
    emoji: '🔑',
    guidance: 'The Key you are looking for is inside you. You already know the answer, '
        'so trust your inner wisdom',
    keywords: ['answer', 'wisdom', 'trust'],
  ),
  OracleCard(
    id: 27,
    name: 'The Door',
    message: 'New opportunities are opening',
    emoji: '🚪',
    guidance: 'One door opens when another closes. New opportunities '
        'are presenting themselves. Be brave enough to walk through them',
    keywords: ['opportunity', 'courage', 'new path'],
  ),
  OracleCard(
    id: 28,
    name: 'The Mirror',
    message: 'Look within',
    emoji: '🪞',
    guidance: 'The Mirror reflects the truth. It is time to look honestly at yourself '
        'and acknowledge your own truths',
    keywords: ['self-knowledge', 'truth', 'reflection'],
  ),
  OracleCard(
    id: 29,
    name: 'The Hourglass',
    message: 'Divine timing is at work',
    emoji: '⏳',
    guidance: 'The Hourglass marks the perfect time. Trust divine timing. '
        'Everything happens at the right moment',
    keywords: ['timing', 'patience', 'trust'],
  ),
  OracleCard(
    id: 30,
    name: 'The Anchor',
    message: 'Stay firm and steady',
    emoji: '⚓',
    guidance: 'The Anchor holds the ship steady through the storm. Find your inner '
        'stability and stay centered',
    keywords: ['stability', 'firmness', 'center'],
  ),
  OracleCard(
    id: 31,
    name: 'The Butterfly',
    message: 'A complete transformation is happening',
    emoji: '🦋',
    guidance: 'The Butterfly emerges from the chrysalis transformed. You are going '
        'through a deep metamorphosis. Trust the process',
    keywords: ['metamorphosis', 'transformation', 'beauty'],
  ),
  OracleCard(
    id: 32,
    name: 'The Scales',
    message: 'Seek balance and justice',
    emoji: '⚖️',
    guidance: 'The Scales weigh with precision. It is time to seek balance in your life '
        'and act with justice and integrity',
    keywords: ['balance', 'justice', 'integrity'],
  ),
  OracleCard(
    id: 33,
    name: 'The Crown',
    message: 'Acknowledge your personal power',
    emoji: '👑',
    guidance: 'You are the sovereign of your own life. It is time to recognize and '
        'claim your personal power. You are worthy',
    keywords: ['power', 'sovereignty', 'worthiness'],
  ),
  OracleCard(
    id: 34,
    name: 'The Heart',
    message: 'Follow the voice of your heart',
    emoji: '❤️',
    guidance: 'The Heart knows the way. Your emotions and intuitions are valid guides. '
        'Trust what your heart is telling you',
    keywords: ['heart', 'love', 'intuition'],
  ),
  OracleCard(
    id: 35,
    name: 'The Wheel',
    message: 'Cycles turn, everything is transient',
    emoji: '☸️',
    guidance: 'The Wheel turns eternally. Everything moves in cycles. If things are '
        'hard right now, the wheel will turn. If they are good, enjoy them',
    keywords: ['cycles', 'change', 'impermanence'],
  ),
  OracleCard(
    id: 36,
    name: 'The Path',
    message: 'Trust the journey',
    emoji: '🛤️',
    guidance: 'The Path reveals itself step by step. You do not need to see the whole '
        'route, only the next step. Keep walking',
    keywords: ['journey', 'trust', 'step by step'],
  ),
  OracleCard(
    id: 37,
    name: 'The Fountain',
    message: 'Abundance flows endlessly',
    emoji: '⛲',
    guidance: 'The Fountain never runs dry. The universe is abundant and there is '
        'enough for everyone. Allow yourself to receive',
    keywords: ['abundance', 'flow', 'receiving'],
  ),
  OracleCard(
    id: 38,
    name: 'The Labyrinth',
    message: 'The path may wind, but it leads to the center',
    emoji: '🌀',
    guidance: 'The Labyrinth is not a prison, but a journey to the center of yourself. '
        'Every turn has a purpose',
    keywords: ['inner journey', 'purpose', 'patience'],
  ),
  OracleCard(
    id: 39,
    name: 'The Bridge',
    message: 'Important connections are emerging',
    emoji: '🌉',
    guidance: 'The Bridge connects two sides. You are building important connections '
        'or crossing between phases of life',
    keywords: ['connection', 'transition', 'union'],
  ),
  OracleCard(
    id: 40,
    name: 'The Mountain',
    message: 'Great achievements require effort',
    emoji: '⛰️',
    guidance: 'The Mountain is high, but the view from the top is worth it. Keep '
        'climbing, step by step. You are capable',
    keywords: ['challenge', 'achievement', 'perseverance'],
  ),
  OracleCard(
    id: 41,
    name: 'The Ocean',
    message: 'Emotional depths call for exploration',
    emoji: '🌊',
    guidance: 'The Ocean is vast and deep. So are your emotions. It is time to '
        'dive deep and explore what lies beneath the surface',
    keywords: ['depth', 'emotion', 'exploration'],
  ),
  OracleCard(
    id: 42,
    name: 'The Seed',
    message: 'Infinite potential is waiting to sprout',
    emoji: '🌱',
    guidance: 'Within the Seed lies all the potential of a tree. Within you lies '
        'all the potential to create your life. Nurture your seeds',
    keywords: ['potential', 'growth', 'beginning'],
  ),
  OracleCard(
    id: 43,
    name: 'The Harvest',
    message: 'Receive the fruits of your labor',
    emoji: '🌾',
    guidance: 'The Harvest is generous to those who planted and tended. It is time to '
        'receive the fruits of your work and dedication',
    keywords: ['harvest', 'reward', 'abundance'],
  ),
  OracleCard(
    id: 44,
    name: 'The Infinite',
    message: 'You are eternal and limitless',
    emoji: '∞',
    guidance: 'The symbol of the Infinite reminds you that you are more than this body '
        'and this moment. You are eternal, infinite and limitless',
    keywords: ['eternity', 'infinity', 'limitless'],
  ),
];
