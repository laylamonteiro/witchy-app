import 'numerology_meanings_models.dart';

/// Numerology meanings — English content.
/// Parity with _pt/_es verified in test/numerology_meanings_parity_test.dart.
const Map<int, NumberMeaning> numberMeaningsEn = {
  1: NumberMeaning(
    number: 1,
    title: 'The Pioneer',
    keywords: ['initiative', 'leadership', 'independence', 'courage'],
    description:
        'One opens the way. It is the initial spark, the will that takes the first step and begins new cycles. Those who vibrate with One learn to trust themselves, lead with authenticity, and plant the new',
    shadow:
        'In shadow, it can turn into authoritarianism, impatience, or loneliness from never asking for help',
  ),
  2: NumberMeaning(
    number: 2,
    title: 'The Diplomat',
    keywords: ['cooperation', 'sensitivity', 'partnership', 'patience'],
    description:
        'Two unites. It is the number of bonds, listening, and mediation. Those who vibrate with Two flourish in partnerships, notice subtleties others miss, and heal spaces with a gentle presence',
    shadow:
        'In shadow, dependency, fear of conflict, and self-effacement appear',
  ),
  3: NumberMeaning(
    number: 3,
    title: 'The Communicator',
    keywords: ['creativity', 'expression', 'joy', 'sociability'],
    description:
        'Three blossoms through expression: word, art, laughter. It is an energy of creation and charm that inspires and connects people through beauty and enthusiasm',
    shadow:
        'In shadow, it scatters into superficiality, gossip, or drama',
  ),
  4: NumberMeaning(
    number: 4,
    title: 'The Builder',
    keywords: ['structure', 'discipline', 'work', 'stability'],
    description:
        'Four builds foundations. It is the energy of method, patience, and honest work that turns ideas into something solid and lasting. Those who vibrate with Four are the bedrock others rely on',
    shadow:
        'In shadow, rigidity, excessive routine, and resistance to change',
  ),
  5: NumberMeaning(
    number: 5,
    title: 'The Free Spirit',
    keywords: ['freedom', 'change', 'adventure', 'versatility'],
    description:
        'Five moves. It is the number of experience, the senses, and transformation. Those who vibrate with Five learn through living, adapt quickly, and bring fresh air wherever they go',
    shadow:
        'In shadow, restlessness, excess, and difficulty with commitment',
  ),
  6: NumberMeaning(
    number: 6,
    title: 'The Guardian',
    keywords: ['care', 'responsibility', 'harmony', 'family'],
    description:
        'Six embraces. It is the energy of home, beauty, and service to those we love. Those who vibrate with Six naturally nurture, harmonize spaces, and take responsibility for the well-being around them',
    shadow:
        'In shadow, over-protection, martyrdom, and interference',
  ),
  7: NumberMeaning(
    number: 7,
    title: 'The Mystic',
    keywords: ['wisdom', 'introspection', 'spirituality', 'analysis'],
    description:
        'Seven goes deep. It is the number of study, silence, and inner searching. Those who vibrate with Seven need time alone to understand the world and find truths that lie beneath the surface',
    shadow:
        'In shadow, isolation, skepticism, and emotional coldness',
  ),
  8: NumberMeaning(
    number: 8,
    title: 'The Achiever',
    keywords: ['power', 'abundance', 'ambition', 'justice'],
    description:
        'Eight materializes. It is the energy of achievement in the concrete world: resources, recognition, influence. Those who vibrate with Eight learn to use power with integrity and generate prosperity that circulates',
    shadow:
        'In shadow, greed, control, and worth measured only by results',
  ),
  9: NumberMeaning(
    number: 9,
    title: 'The Humanitarian',
    keywords: ['compassion', 'completion', 'generosity', 'universality'],
    description:
        'Nine completes and gives back. It is the number of universal love, art, and closing cycles. Those who vibrate with Nine feel the pain and beauty of the world and turn experience into wisdom to share',
    shadow:
        'In shadow, drama, difficulty letting go, and disappointment with humanity',
  ),
  11: NumberMeaning(
    number: 11,
    title: 'The Intuitive Master',
    keywords: ['intuition', 'inspiration', 'sensitivity', 'vision'],
    description:
        'Eleven is a master number: the Two raised to a higher octave. It is a channel between worlds — refined intuition, inspiration that arrives like lightning, a sensitivity that captures what is invisible',
    shadow:
        'In shadow, anxiety, nervous tension, and the feeling of never belonging',
  ),
  22: NumberMeaning(
    number: 22,
    title: 'The Master Builder',
    keywords: ['practical vision', 'great works', 'legacy', 'mastery'],
    description:
        'Twenty-Two materializes the impossible: it unites the vision of Eleven with the discipline of Four. It is the energy of projects that span generations — temples, institutions, legacies',
    shadow:
        'In shadow, it is crushed by its own expectations or dominates for the sake of its ends',
  ),
  33: NumberMeaning(
    number: 33,
    title: 'The Master of Love',
    keywords: ['healing', 'loving service', 'teaching', 'elevated compassion'],
    description:
        'Thirty-Three is rare: the Six elevated to universal devotion. It vibrates as healing by example — teaching with love, serving without expecting return',
    shadow:
        'In shadow, extreme sacrifice and denial of one\'s own needs',
  ),
};

/// Labels and explanations for each key number of the personal profile.
const profileNumberInfosEn = <String, ProfileNumberInfo>{
  'lifePath': ProfileNumberInfo(
    label: 'Life Path',
    emoji: '🌟',
    explanation:
        'Calculated from your birth date, it reveals the great lesson and direction of your journey',
  ),
  'expression': ProfileNumberInfo(
    label: 'Expression',
    emoji: '🗣️',
    explanation:
        'The sum of every letter in your full name: your talents and the way you present yourself to the world',
  ),
  'soulUrge': ProfileNumberInfo(
    label: 'Soul Urge',
    emoji: '💜',
    explanation:
        'Only the vowels of your name: what your heart quietly longs for, your deepest motivations',
  ),
  'personality': ProfileNumberInfo(
    label: 'Personality',
    emoji: '🎭',
    explanation:
        'Only the consonants: the first impression you make, the face the world sees',
  ),
  'personalYear': ProfileNumberInfo(
    label: 'Personal Year',
    emoji: '🗓️',
    explanation:
        'The theme of your current yearly cycle — the energy available for this year of your life',
  ),
};

/// Messages for the classic repeated sequences (popular mystical view +
/// numerological reading). The reduced numeric reading complements each one.
const Map<String, String> repeatedSequenceMessagesEn = {
  '000': 'Portal of the infinite: a cycle closes and everything is possible. A moment to choose consciously what to plant',
  '111': 'Alignment and manifestation: your thoughts are creating quickly. Focus on what you desire, not on what you fear',
  '222': 'Trust and patience: partnerships and right timing are working in your favor. Keep faith in the process',
  '333': 'Presence of the masters and of creativity: express yourself, create, communicate. You are being supported',
  '444': 'Protection and structure: your guardians confirm the foundation is solid. Keep up the work',
  '555': 'Change ahead: prepare for liberating transformations. Release what has already served its purpose',
  '666': 'Rebalancing: too much material worry. Return to the heart, the home, and what truly nourishes',
  '777': 'Spiritual luck: you are on the right path of learning. Deepen your studies and your intuition',
  '888': 'Abundance in flow: harvest and prosperity approach. Receive with gratitude and let it circulate',
  '999': 'Sacred closing: a great cycle completes. Close it with love so the new can arrive',
  '1010': 'New level: one step at a time, you are rising in a spiral. Trust the direction',
  '1212': 'Harmonic growth: faith and action in balance build the next chapter',
  '1234': 'Progression: life confirms you are advancing in the right order. Keep taking the steps',
};
