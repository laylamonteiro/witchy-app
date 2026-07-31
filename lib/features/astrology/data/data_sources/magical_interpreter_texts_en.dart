import '../models/enums.dart';
import 'magical_interpreter_texts.dart';

/// Magical interpreter texts — English content.
///
/// Keep the same keys/structures across the three files
/// (`magical_interpreter_texts_pt/en/es.dart`) — parity is checked in
/// `test/astrology_interpreters_parity_test.dart`.
final MagicalInterpreterTexts magicalInterpreterTextsEn =
    MagicalInterpreterTexts(
  sunEssence: const {
    ZodiacSign.aries:
        'Your magical essence is one of pioneering and courage. You are a warrior witch '
            'who acts with speed and decision. Your most powerful spells involve starting new '
            'cycles and breaking through barriers. Use fire as your main element.',
    ZodiacSign.taurus:
        'Your magical essence is rooted in the earth and in manifestation. You are a witch '
            'who brings the spirit world into the physical. Your most powerful spells involve '
            'prosperity, sensuality, and beauty. Work with crystals and herbs.',
    ZodiacSign.gemini:
        'Your magical essence flows through communication and knowledge. You are a '
            'scholarly witch who masters magic through words and symbols. Your most '
            'powerful spells involve communication, learning, and versatility.',
    ZodiacSign.cancer:
        'Your magical essence flows with the lunar tides. You are an intuitive witch, '
            'deeply connected to emotions. Your most powerful spells involve protecting '
            'the home, emotional healing, and lunar magic.',
    ZodiacSign.leo:
        'Your magical essence shines like the Sun. You are a radiant witch, confident and '
            'creative. Your most powerful spells involve self-expression, creativity, and '
            'leadership. Use solar rituals.',
    ZodiacSign.virgo:
        'Your magical essence lies in precision and service. You are a meticulous witch '
            'who masters the details of every ritual. Your most powerful spells involve healing, '
            'purification, and herbal magic.',
    ZodiacSign.libra:
        'Your magical essence seeks balance and harmony. You are a diplomat witch '
            'who works with energies of beauty and justice. Your most powerful spells involve '
            'relationships, harmony, and aesthetics.',
    ZodiacSign.scorpio:
        'Your magical essence dives into the depths. You are a transformative witch '
            'who does not fear the shadows. Your most powerful spells involve deep transformation, '
            'sex magic, and rebirth.',
    ZodiacSign.sagittarius:
        'Your magical essence seeks wisdom and expansion. You are a philosopher witch '
            'who explores different traditions. Your most powerful spells involve spiritual '
            'growth, protection while traveling, and abundance.',
    ZodiacSign.capricorn:
        'Your magical essence is structured and ambitious. You are a disciplined witch '
            'who builds power over time. Your most powerful spells involve material '
            'manifestation, career, and Saturnian magic.',
    ZodiacSign.aquarius:
        'Your magical essence is innovative and unique. You are a revolutionary witch who '
            'breaks traditions and creates new paths. Your most powerful spells involve social '
            'change, intuition, and technological magic.',
    ZodiacSign.pisces:
        'Your magical essence dissolves boundaries. You are a mystical witch, deeply '
            'connected to the collective unconscious. Your most powerful spells involve dreams, '
            'mediumship, and universal compassion.',
  },
  moonIntro: (signName, houseNumber) =>
      'Your Moon in $signName in House $houseNumber ',
  moonBySign: const {
    ZodiacSign.aries:
        'brings quick, instinctive intuitions. Trust your first impulses.',
    ZodiacSign.taurus:
        'offers intuition through the senses. Work with scents, textures, and flavors.',
    ZodiacSign.cancer:
        'amplifies your psychic sensitivity. You are naturally empathic and receptive.',
    ZodiacSign.scorpio:
        'dives into the emotional depths. You have powerful psychic gifts.',
    ZodiacSign.pisces:
        'dissolves the boundaries between worlds. You may have prophetic dreams.',
  },
  moonByElement: (elementName) =>
      'offers intuition in tune with $elementName. '
      'Work with this element to strengthen your connection.',
  mercuryByElement: const {
    Element.fire:
        'Your magical communication is direct and inspiring. Use powerful affirmations '
            'and incantations spoken out loud.',
    Element.earth:
        'Your magical communication is practical and grounded. Write your spells down and '
            'work with physical grimoires.',
    Element.air:
        'Your magical communication is versatile and clear. You excel at reading runes, '
            'tarot, and other symbol-based divination systems.',
    Element.water:
        'Your magical communication is intuitive and emotional. Work with poetry, music, and '
            'creative expression in your rituals.',
  },
  venus: (signName, elementName) =>
      'Your Venus in $signName indicates that you attract beauty and pleasure through '
      '$elementName. Weave this element into spells of love and self-care.',
  mars: (signName, elementName) =>
      'Your Mars in $signName shows that your protective energy manifests through '
      '$elementName. Use this element in spells of protection and banishing.',
  house8Intro: (signName) =>
      'Your 8th House (magic and the occult) is in $signName. ',
  house8NoPlanets:
      'Although there are no planets here, you can still develop your magical '
      'abilities through conscious practice.',
  house8WithPlanets: (count, planetNames) =>
      'With $count planet(s) here, you have a strong natural affinity '
      'for magic: $planetNames. ',
  house8Moon: 'The Moon here intensifies your magical intuition. ',
  house8Pluto: 'Pluto here indicates deep transformative powers. ',
  house12Intro: (signName) =>
      'Your 12th House (spirituality) is in $signName. ',
  house12NoPlanets:
      'Develop your spiritual connection through meditation and dreams.',
  house12WithPlanets: (count, planetNames) =>
      'With $count planet(s) here, you have a strong connection to the divine: '
      '$planetNames. ',
  house12Neptune:
      'Neptune here amplifies your mediumship and mystical connection. ',
  house12Moon: 'The Moon here brings prophetic dreams and strong intuition. ',
  strengthPsychicIntuition: 'Natural psychic intuition',
  strengthSunMoonBalance: 'Balance between action and intuition',
  strengthMagicAffinity: 'Natural affinity for magic',
  strengthSpiritualConnection: 'Deep spiritual connection',
  strengthDominantElement: (elementName) =>
      'Mastery of the $elementName element',
  practicesByElement: const {
    Element.fire: [
      'Candle magic',
      'Rituals under the sun',
      'Sacred fire work',
      'Quick-action spells',
    ],
    Element.earth: [
      'Green witchcraft (herbs and plants)',
      'Crystal magic',
      'Manifestation rituals',
      'Working with a permanent altar',
    ],
    Element.air: [
      'Word and incantation magic',
      'Rune and tarot reading',
      'Working with incense',
      'Spirit communication',
    ],
    Element.water: [
      'Lunar magic',
      'Ritual baths',
      'Dream work',
      'Water divination',
    ],
  },
  practicesHouse8: const [
    'Sex magic and deep transformation',
    'Shadow work',
  ],
  practicesHouse12: const [
    'Meditation and astral journeys',
    'Working with the unconscious',
  ],
  toolsByElement: const {
    Element.fire: ['Citrine', 'Carnelian', 'Ruby', 'Red/orange candles'],
    Element.earth: ['Green Quartz', 'Black Tourmaline', 'Coarse salt', 'Herbs'],
    Element.air: ['Clear Quartz', 'Amethyst', 'Incense', 'Feathers'],
    Element.water: ['Moonstone', 'Moon water', 'Seashells', 'Mirror'],
  },
  sunCrystal: (signName) => '$signName crystal',
  moonHerb: (signName) => '$signName herb',
  shadowSunMoon: 'Integrate the conscious ego with emotional needs',
  shadowSaturn: 'Work with limitations and rigid structures',
  shadowHouse12:
      'Explore hidden aspects of the personality through meditation',
);
