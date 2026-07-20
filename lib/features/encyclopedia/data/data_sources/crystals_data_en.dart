import '../models/crystal_model.dart';

/// Encyclopedia crystals — English content.
///
/// Names follow each language's convention; enums, elements and images are
/// invariant. Keep the same order as `crystals_data_pt.dart` — parity is
/// verified by `test/content_parity_test.dart`.
final List<CrystalModel> crystalsEn = [
  const CrystalModel(
    name: 'Agate',
    description:
        'A stone of balance, harmony and gentle protection. It stabilizes energies and soothes.',
    element: Element.earth,
    imageUrl: 'assets/images/crystals/agata.jpg',
    intentions: [
      'Emotional balance',
      'Harmony',
      'Gentle protection',
      'Stability',
      'Concentration',
      'Acceptance',
    ],
    usageTips: [
      'Use it for emotional balance',
      'Carry it for stability',
      'Meditate with it for inner peace',
      'Place it around your space for harmony',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Running water',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Smoke',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Earth',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Sun or moon',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Earth',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Amethyst',
    description:
        'A stone of spirituality and protection. It calms the mind and fosters mental clarity.',
    element: Element.air,
    imageUrl: 'assets/images/crystals/ametista.jpg',
    intentions: [
      'Spiritual protection',
      'Intuition',
      'Meditation',
      'Mental clarity',
      'Restful sleep',
      'Transformation',
    ],
    usageTips: [
      'Place it in the bedroom for protective dreams',
      'Meditate holding it to open the third eye',
      'Use it during spiritual practices',
      'Carry it for psychic protection',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Running water',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Herbal smoke',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Moonlight',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Full moon',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Other crystals',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Morning sun (briefly)',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'May fade with prolonged sun exposure',
    ],
  ),
  const CrystalModel(
    name: 'Citrine',
    description:
        'The stone of prosperity and abundance. It draws success, joy and positive energy.',
    element: Element.fire,
    imageUrl: 'assets/images/crystals/citrino.jpg',
    intentions: [
      'Prosperity',
      'Abundance',
      'Success',
      'Joy',
      'Confidence',
      'Creativity',
    ],
    usageTips: [
      'Place it in your wallet or cash register',
      'Keep it at the office for professional success',
      'Meditate with it to attract abundance',
      'Place it near plants for positive energy',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Running water',
        isSafe: false,
        warning: 'May fade - prefer other methods',
      ),
      CrystalMethod(
        method: 'Herbal smoke',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Moonlight',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Sun (morning)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Earth',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Clear quartz',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Very sensitive to sunlight - can lose its color quickly',
      'Avoid excessive heat',
    ],
  ),
  const CrystalModel(
    name: 'Carnelian',
    description:
        'A stone of creativity, courage and vitality. It sparks motivation and confidence.',
    element: Element.fire,
    imageUrl: 'assets/images/crystals/cornalina.jpg',
    intentions: [
      'Creativity',
      'Courage and confidence',
      'Vitality and energy',
      'Motivation',
      'Fertility',
      'Manifestation',
    ],
    usageTips: [
      'Use it for creative projects',
      'Carry it for energy and motivation',
      'Meditate on the sacral chakra',
      'Place it in your workspace',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Running water',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Smoke',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Earth',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Sun',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Earth',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Fluorite',
    description:
        'A stone of focus, learning and mental organization. Excellent for study sessions.',
    element: Element.air,
    imageUrl: 'assets/images/crystals/fluorita.jpg',
    intentions: [
      'Focus and concentration',
      'Learning',
      'Mental organization',
      'Aura cleansing',
      'Clear decisions',
      'Memory',
    ],
    usageTips: [
      'Use it while studying',
      'Place it on your desk',
      'Meditate with it for mental clarity',
      'Carry it for focus',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Water',
        isSafe: false,
        warning: 'Avoid water - it may cause damage',
      ),
      CrystalMethod(
        method: 'Smoke',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sound',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Moon',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Quartz',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Fragile - handle with care',
      'Avoid intense sunlight',
    ],
  ),
  const CrystalModel(
    name: 'Howlite',
    description:
        'A calming stone of patience and awareness. Excellent for insomnia and anxiety.',
    element: Element.air,
    imageUrl: 'assets/images/crystals/howlita.jpg',
    intentions: [
      'Calm and patience',
      'Restful sleep',
      'Anxiety relief',
      'Awareness',
      'Memory',
      'Calm communication',
    ],
    usageTips: [
      'Place it under your pillow for insomnia',
      'Meditate with it to ease anxiety',
      'Carry it through stressful situations',
      'Use it to soothe anger',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Running water (briefly)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Smoke',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Moon',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Moon',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Quartz',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Red Jasper',
    description:
        'A stone of grounding, strength and stability. It connects you to the energy of the Earth.',
    element: Element.earth,
    imageUrl: 'assets/images/crystals/jaspe_vermelho.jpg',
    intentions: [
      'Grounding',
      'Physical strength',
      'Stability',
      'Endurance',
      'Courage',
      'Vitality',
    ],
    usageTips: [
      'Use it for grounding',
      'Carry it for physical strength',
      'Meditate on the root chakra',
      'Place it around your space for stability',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Running water',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Earth',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Smoke',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Earth (bury it)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sun',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Labradorite',
    description:
        'A mystical stone of transformation and magic. It shields against negative energies and sharpens intuition.',
    element: Element.air,
    imageUrl: 'assets/images/crystals/labradorita.jpg',
    intentions: [
      'Psychic protection',
      'Intuition and clairvoyance',
      'Transformation',
      'Magic',
      'Inner strength',
      'Synchronicity',
    ],
    usageTips: [
      'Use it during magical workings',
      'Meditate with it to develop intuition',
      'Carry it for auric protection',
      'Place it on your altar',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Running water (quickly)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Smoke',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Full moon',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Full moon',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Earth',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Lapis Lazuli',
    description:
        'The stone of wisdom, truth and spiritual vision. It opens the third eye.',
    element: Element.air,
    imageUrl: 'assets/images/crystals/lapis_lazuli.jpg',
    intentions: [
      'Wisdom',
      'Truth',
      'Spiritual vision',
      'Higher communication',
      'Intuition',
      'Inner peace',
    ],
    usageTips: [
      'Meditate with it to open the third eye',
      'Use it for truthful communication',
      'Carry it for wisdom',
      'Place it on your altar',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Water',
        isSafe: false,
        warning: 'Avoid water - it may cause damage',
      ),
      CrystalMethod(
        method: 'Smoke',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sound',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Moon',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Quartz or amethyst',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Do not get it wet - it may stain or be damaged',
      'Keep it away from chemicals',
    ],
  ),
  const CrystalModel(
    name: 'Black Obsidian',
    description:
        'A powerful stone of protection and grounding. It absorbs and transmutes negative energies.',
    element: Element.earth,
    imageUrl: 'assets/images/crystals/obsidiana_negra.jpg',
    intentions: [
      'Strong protection',
      'Grounding',
      'Transformation',
      'Truth',
      'Deep cleansing',
      'Trauma release',
    ],
    usageTips: [
      'Use it for intense protection',
      'Meditate with it for shadow work',
      'Place it at the entrance of your home',
      'Carry it for personal protection',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Running water with salt',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Smoke',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Earth (bury it)',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Earth',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'New moon',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Very powerful - use with awareness',
      'May bring emotions to the surface',
    ],
  ),
  const CrystalModel(
    name: "Tiger's Eye",
    description:
        'A stone of courage, protection and prosperity. It strengthens confidence and brings good luck.',
    element: Element.fire,
    imageUrl: 'assets/images/crystals/olho_de_tigre.jpg',
    intentions: [
      'Courage and strength',
      'Protection',
      'Prosperity',
      'Confidence',
      'Grounding',
      'Good luck',
    ],
    usageTips: [
      'Carry it for courage and confidence',
      'Keep it at work for success',
      'Use it during negotiations',
      'Meditate with it for balance',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Running water',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Smoke',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Earth',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Sun',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Earth',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Moonstone',
    description:
        'The sacred stone of the moon and the feminine. It connects you to lunar cycles and intuition.',
    element: Element.water,
    imageUrl: 'assets/images/crystals/pedra_da_lua.jpg',
    intentions: [
      'Intuition',
      'Feminine cycles',
      'New beginnings',
      'Emotional balance',
      'Dreams',
      'Fertility',
    ],
    usageTips: [
      'Use it during the full moon',
      'Place it under your pillow for dreams',
      'Carry it for hormonal balance',
      'Meditate with it for lunar connection',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Running water (briefly)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Smoke',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Moonlight',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Full moon (especially)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Moon water',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Avoid intense sunlight - it may fade',
    ],
  ),
  const CrystalModel(
    name: 'Pyrite',
    description:
        'A stone of prosperity and manifestation. It attracts abundance and wards off negativity.',
    element: Element.earth,
    imageUrl: 'assets/images/crystals/pirita.jpg',
    intentions: [
      'Prosperity',
      'Manifestation',
      'Protection',
      'Confidence',
      'Memory',
      'Vitality',
    ],
    usageTips: [
      'Place it in your office or business',
      'Carry it in your wallet',
      'Use it in prosperity rituals',
      'Keep it in safes or money drawers',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Water',
        isSafe: false,
        warning: 'It may rust - avoid water!',
      ),
      CrystalMethod(
        method: 'Smoke',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sound',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Sun',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Earth',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Do not get it wet - it may rust and release sulfur',
      'Keep it dry',
    ],
  ),
  const CrystalModel(
    name: 'Rose Quartz',
    description:
        'The stone of self-love and unconditional love. It fosters inner peace and emotional healing.',
    element: Element.water,
    imageUrl: 'assets/images/crystals/quartzo_rosa.jpg',
    intentions: [
      'Self-love',
      'Self-acceptance',
      'Emotional healing',
      'Relationships',
      'Compassion',
    ],
    usageTips: [
      'Place it under your pillow for loving dreams',
      'Use it on a self-love altar',
      'Carry it in your pocket to attract love',
      'Meditate holding it over your heart',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Running water',
        isSafe: false,
        warning: 'May fade with prolonged exposure to water',
      ),
      CrystalMethod(
        method: 'Herbal smoke (incense, palo santo)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Moonlight',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sound (bell, singing bowl)',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Full moon (preferably)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Earth (bury for 24h)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Other crystals (amethyst, quartz)',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'May fade with prolonged sun exposure',
      'Avoid water for long periods',
    ],
  ),
  const CrystalModel(
    name: 'Clear Quartz',
    description:
        'The master healer and amplifier. It can be programmed for any intention.',
    element: Element.spirit,
    imageUrl: 'assets/images/crystals/quartzo_transparente.jpg',
    intentions: [
      'Energy amplification',
      'Clarity',
      'General healing',
      'Intention programming',
      'Cleansing',
      'Balance',
    ],
    usageTips: [
      'Program it with your intention',
      'Use it to amplify other crystals',
      'Meditate with it for mental clarity',
      'Place it in water to energize it',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Running water',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sunlight or moonlight',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Smoke',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sound',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Sun or moon',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Earth',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Intention and visualization',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Selenite',
    description:
        'A stone of peace and purification. Self-cleansing, it rarely needs to be cleansed.',
    element: Element.air,
    imageUrl: 'assets/images/crystals/selenita.jpg',
    intentions: [
      'Purification',
      'Peace',
      'Mental clarity',
      'Spiritual connection',
      'Space cleansing',
      'Gentle protection',
    ],
    usageTips: [
      'Place it around your space to purify it',
      'Use it to cleanse other crystals',
      'Meditate with it for inner peace',
      'Place it under your pillow (careful - it is fragile)',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Water',
        isSafe: false,
        warning: 'NEVER use water - it dissolves selenite!',
      ),
      CrystalMethod(
        method: 'Self-cleansing',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Moonlight (if you wish)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sound',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Moonlight',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Self-charging',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'NEVER get it wet - it dissolves in water',
      'Very fragile - handle with care',
      'Do not leave it in the sun - it may turn dull',
    ],
  ),
  const CrystalModel(
    name: 'Sodalite',
    description:
        'A stone of logic, truth and communication. It stimulates rational thinking and intuition.',
    element: Element.air,
    imageUrl: 'assets/images/crystals/sodalita.jpg',
    intentions: [
      'Clear communication',
      'Truth and honesty',
      'Logic and rationality',
      'Intuition',
      'Self-acceptance',
      'Inner peace',
    ],
    usageTips: [
      'Use it while studying',
      'Carry it for clear communication',
      'Meditate with it to balance logic and intuition',
      'Place it in your office',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Running water (briefly)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Smoke',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Moon',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Moon',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Quartz',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Black Tourmaline',
    description:
        'A powerful stone of protection and grounding. It blocks negative energies.',
    element: Element.earth,
    imageUrl: 'assets/images/crystals/turmalina_negra.jpg',
    intentions: [
      'Protection',
      'Grounding',
      'Energy cleansing',
      'Blocking negativity',
      'Balance',
      'Purification',
    ],
    usageTips: [
      'Place it in the corners of your home for protection',
      'Carry it to shield yourself from heavy energies',
      'Use it during grounding meditation',
      'Place it near electronics',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Running water with salt',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Rosemary or sage smoke',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Earth (bury it)',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Earth',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'New moon',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sun',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
];
