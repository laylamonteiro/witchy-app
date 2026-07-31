import '../models/elements_content_model.dart';

/// "The Four Elements" page content — English.
///
/// Emojis and the order/count of the lists (Earth, Water, Fire, Air) are
/// invariant across languages. Keep the same structure in all three files
/// (`elements_content_pt/en/es.dart`) — parity is checked in
/// `test/encyclopedia_content_parity_test.dart`.
const ElementsContent elementsContentEn = ElementsContent(
  pageTitle: 'The Four Elements',
  introTitle: 'About the 4 Elements',
  introBody:
      'In Wicca and traditional witchcraft, the four elements - Earth, Water, Fire, and Air - '
      'are fundamental forces of nature and existence. They are not merely physical substances, '
      'but primordial energies that compose all of creation.',
  introHint:
      'Explore each element below to understand its qualities, correspondences, and how to work with it.',
  essenceLabel: 'Essence',
  qualitiesLabel: 'Qualities',
  directionLabel: 'Cardinal Direction',
  seasonLabel: 'Season',
  lifePhaseLabel: 'Phase of Life',
  timeOfDayLabel: 'Time of Day',
  colorsLabel: 'Colors',
  toolsLabel: 'Magical Tools',
  correspondencesLabel: 'Correspondences',
  elements: [
    ElementInfo(
      name: 'Earth',
      emoji: '🌍',
      essence:
          'Earth represents stability, solidity, growth, and physical manifestation. '
          'It is the element of matter, of the body, of material abundance, and of connection with the natural world. '
          'Earth is where ideas become reality.',
      qualities:
          'Stable, fertile, nurturing, reliable, practical, patient, rooted',
      direction: 'North',
      season: 'Winter (a time of retreat and gestation)',
      lifePhase: 'Old age and wisdom',
      timeOfDay: 'Midnight',
      colors: 'Green, brown, black, yellow (earthy tones)',
      tools: 'Pentacle, crystals, salt, stones, coins',
      correspondences:
          '• Crystals: Smoky quartz, black tourmaline, jasper, agate, hematite\n'
          '• Herbs: Rosemary, cedar, patchouli, vetiver, roots\n'
          '• Animals: Bear, deer, bull, rabbit, snake\n'
          '• Zodiac: Taurus, Virgo, Capricorn',
      whenToWorkTitle: 'When to Work with Earth',
      whenToWork: '• Manifestation of material goals\n'
          '• Prosperity and abundance\n'
          '• Grounding and centering\n'
          '• Physical healing\n'
          '• Connection with nature\n'
          '• Stability and security\n'
          '• Growth and fertility',
    ),
    ElementInfo(
      name: 'Water',
      emoji: '🌊',
      essence:
          'Water represents emotions, intuition, healing, and purification. '
          'It is the element of deep feelings, of the subconscious, of dreams and the psyche. '
          'Water flows, adapts, and reflects the inner truth.',
      qualities:
          'Fluid, adaptable, emotional, intuitive, healing, purifying, reflective',
      direction: 'West',
      season: 'Autumn (a time of harvest and reflection)',
      lifePhase: 'Maturity',
      timeOfDay: 'Twilight',
      colors: 'Blue, turquoise, silver, indigo, purple',
      tools: 'Chalice, cauldron, mirror, cup, seashells',
      correspondences:
          '• Crystals: Amethyst, moonstone, aquamarine, pearl, sodalite\n'
          '• Herbs: Chamomile, gardenia, jasmine, lotus, sage\n'
          '• Animals: Fish, dolphin, swan, frog, otter\n'
          '• Zodiac: Cancer, Scorpio, Pisces',
      whenToWorkTitle: 'When to Work with Water',
      whenToWork: '• Emotional and spiritual healing\n'
          '• Developing intuition\n'
          '• Dream work\n'
          '• Energetic purification\n'
          '• Love and relationships\n'
          '• Meditation and contemplation\n'
          '• Connection with the subconscious',
    ),
    ElementInfo(
      name: 'Fire',
      emoji: '🔥',
      essence:
          'Fire represents transformation, passion, will, and personal power. '
          'It is the element of vital energy, of courage, of creativity and action. '
          'Fire consumes, transforms, and illuminates.',
      qualities:
          'Dynamic, transformative, purifying, passionate, courageous, energetic, creative',
      direction: 'South',
      season: 'Summer (a time of peak energy)',
      lifePhase: 'Youth and vigor',
      timeOfDay: 'Noon',
      colors: 'Red, orange, gold, bright yellow',
      tools: 'Athame (ritual dagger), wand, candle, flaming cauldron',
      correspondences:
          '• Crystals: Carnelian, citrine, ruby, garnet, obsidian\n'
          '• Herbs: Cinnamon, ginger, pepper, basil, clove\n'
          '• Animals: Dragon, lion, phoenix, fire serpent, salamander\n'
          '• Zodiac: Aries, Leo, Sagittarius',
      whenToWorkTitle: 'When to Work with Fire',
      whenToWork: '• Personal transformation\n'
          '• Courage and willpower\n'
          '• Passion and creativity\n'
          '• Active protection\n'
          '• Energetic purification\n'
          '• Banishing negative energies\n'
          '• Swift manifestation of desires',
    ),
    ElementInfo(
      name: 'Air',
      emoji: '💨',
      essence:
          'Air represents intellect, communication, thought, and inspiration. '
          'It is the element of the mind, of ideas, of wisdom and knowledge. '
          'Air carries messages, disperses, and renews.',
      qualities:
          'Light, mobile, communicative, intellectual, inspiring, free, renewing',
      direction: 'East',
      season: 'Spring (a time of new beginnings)',
      lifePhase: 'Childhood and learning',
      timeOfDay: 'Dawn',
      colors: 'Pale yellow, white, light blue, lavender',
      tools:
          'Wand (in some traditions), athame (in others), incense, feathers, bells',
      correspondences:
          '• Crystals: Citrine, topaz, fluorite, blue lace agate\n'
          '• Herbs: Lavender, mint, eucalyptus, white sage, dandelion\n'
          '• Animals: Eagle, butterfly, birds, dragonfly, fairy\n'
          '• Zodiac: Gemini, Libra, Aquarius',
      whenToWorkTitle: 'When to Work with Air',
      whenToWork: '• Study and learning\n'
          '• Communication and eloquence\n'
          '• Travel and movement\n'
          '• Creative inspiration\n'
          '• Mental clarity\n'
          '• New beginnings\n'
          '• Work with celestial deities',
    ),
  ],
  balanceTitle: 'Elemental Balance',
  balanceIntro:
      'In the practice of witchcraft, seeking the balance of the four elements is essential. '
      'Each element represents different aspects of our life and personality:',
  balanceItems: [
    ElementBalanceItem(
        '🌍', 'Earth', 'Our physical body and material resources'),
    ElementBalanceItem('🌊', 'Water', 'Our emotions and relationships'),
    ElementBalanceItem('🔥', 'Fire', 'Our energy and personal power'),
    ElementBalanceItem('💨', 'Air', 'Our mind and communication'),
  ],
  imbalanceTitle: 'Signs of Imbalance:',
  imbalanceBody:
      '• Too much Earth: Stubbornness, materialism, resistance to change\n'
      '• Too much Water: Excessive emotionality, emotional instability\n'
      '• Too much Fire: Impulsiveness, anger, burnout\n'
      '• Too much Air: Distraction, lack of practicality, disconnection',
  practicesTitle: 'How to Work with the Elements',
  practices: [
    ElementPractice(
      'Elemental Meditation',
      'Sit with an object representing each element and meditate on its qualities. '
          'Feel the energy of the element flowing through you.',
    ),
    ElementPractice(
      'Magic Circle',
      'When casting a circle, invoke each element in its cardinal direction. '
          'This creates a balanced and protected sacred space.',
    ),
    ElementPractice(
      'Elemental Altar',
      'Keep representations of the four elements on your altar to maintain energetic balance.',
    ),
    ElementPractice(
      'Specific Spells',
      'Work with the element corresponding to your intention: '
          'Earth for prosperity, Water for love, Fire for courage, Air for wisdom.',
    ),
    ElementPractice(
      'Daily Connection',
      'Spend time in nature connecting with the elements: '
          'walk barefoot (Earth), take a ritual bath (Water), light candles (Fire), practice breathing (Air).',
    ),
  ],
  honoringTitle: 'Honoring the Elements',
  honoringBody:
      'The four elements are not just magical tools - they are living forces that sustain all of existence. '
      'When working with the elements, we are connecting with the very foundations of the universe. '
      '\n\nRespect each element, learn its lessons, and allow its energies to guide and strengthen your practice. '
      'In time, you will develop a deep relationship with each element, recognizing its presence '
      'both in the outer world and within yourself.',
);
