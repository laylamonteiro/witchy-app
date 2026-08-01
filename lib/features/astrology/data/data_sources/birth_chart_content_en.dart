import '../models/enums.dart';
import 'birth_chart_content.dart';

/// Birth chart page content — English.
const BirthChartContent birthChartContentEn = BirthChartContent(
  ui: {
    'viewMagicalProfileTooltip': 'View Magical Profile',
    'noChartFound': 'No birth chart found',
    'sectionMainTrio': 'Main Trio',
    'sectionPersonalPlanets': 'Personal Planets',
    'sectionSocialPlanets': 'Social Planets',
    'sectionTranspersonalPlanets': 'Transpersonal Planets',
    'sectionAstroPoints': 'Astrological Points',
    'sectionHouses': 'Astrological Houses',
    'sectionAspects': 'Major Aspects',
    'ascendant': 'Ascendant',
    'ascendantMeaning': 'How you present yourself',
    'houseWord': 'House',
    'planetsInHousePrefix': 'Planets:',
    'noAspects': 'No significant aspects found',
    'unlockFullInterpretations': 'Unlock full interpretations',
    'viewMagicalProfileButton': 'View Magical Profile ✨',
    'tapToLearnMore': 'Tap to learn more',
    'beginnersGuide': "Beginner's Guide",
  },
  planetRowMeanings: {
    Planet.sun: 'Your essence',
    Planet.moon: 'Your emotions',
    Planet.mercury: 'Communication',
    Planet.venus: 'Love and beauty',
    Planet.mars: 'Action and energy',
  },
  trioSections: [
    BirthChartSection(
      title: '☉ The Sun - Your Essence',
      body:
          'The Sun represents who you truly are at your deepest core. It is your fundamental '
          'identity, your life goals and how you shine in the world\n\n'
          'In witchcraft, the Sun represents your vital force, your creative energy and your magical purpose. '
          'Your Sun sign shows what kind of magic you naturally express',
    ),
    BirthChartSection(
      title: '☽ The Moon - Your Emotions',
      body:
          'The Moon rules your emotions, intuition and inner world. It reveals how you process '
          'feelings, what you need to feel safe and your instinctive reactions\n\n'
          'For magic practitioners, the Moon is extremely important. It points to your intuitive gifts, '
          'your connection with the unconscious and how you relate to the lunar cycles',
    ),
    BirthChartSection(
      title: '⬆ The Ascendant - Your Mask',
      body:
          'The Ascendant (or rising sign) is how you present yourself to the world and the first '
          'impressions you make. It is your "social mask" and outer appearance\n\n'
          'In magical practice, the Ascendant influences how your energy is perceived by others '
          'and can indicate what kind of magical work you naturally attract',
    ),
  ],
  trioTip: BirthChartSection(
    title: '💡 Why does it matter?',
    body:
        'These three points form the foundation of your astrological personality. '
        'If you are just starting out in astrology, understanding your Sun, Moon and Ascendant '
        'is the first step to knowing yourself through the stars',
  ),
  personalIntro:
      'The personal planets are the ones that move quickly through the zodiac and '
      'influence the day-to-day facets of your personality',
  personalSections: [
    BirthChartSection(
      title: '☿ Mercury - Communication',
      body:
          'Mercury rules how you think, communicate and process information. '
          'It shapes the way you learn, speak and write\n\n'
          'In magic: It shows how you cast enchantments, write spells and communicate with the divine',
    ),
    BirthChartSection(
      title: '♀ Venus - Love and Beauty',
      body:
          'Venus rules love, relationships, beauty and pleasure. It shows what you value, '
          'how you relate romantically and your aesthetic sense\n\n'
          'In magic: It influences love workings (always ethical!), prosperity and the beauty of your altar',
    ),
    BirthChartSection(
      title: '♂ Mars - Action and Energy',
      body:
          'Mars represents your energy for action, how you fight for what you want, your courage '
          'and also your anger. It is the planet of initiative and determination\n\n'
          'In magic: It points to your protective energy, banishing power and magical willpower',
    ),
  ],
  personalTip: BirthChartSection(
    title: '✨ Tip for beginners',
    body:
        'These planets change sign frequently, so people born on the same day '
        'can have different placements. Check your Magical Profile for a '
        'personalized analysis of each planet',
  ),
  socialIntro:
      'Jupiter and Saturn are the social planets: they bridge your individual '
      'personality and the collective world — your relationship with '
      'society, growth, rules, responsibilities and maturing',
  socialSections: [
    BirthChartSection(
      title: '♃ Jupiter - Expansion',
      body:
          'Expansion, faith, knowledge, opportunities and worldview. It shows where '
          'you grow, trust and find ease and luck in life',
    ),
    BirthChartSection(
      title: '♄ Saturn - Structure',
      body:
          'Limits, discipline, duty, fear, structure and maturing. It indicates where '
          'you learn through challenges, take on responsibilities and build solidity',
    ),
  ],
  transpersonalIntro:
      'Uranus, Neptune and Pluto are the transpersonal (or generational) planets. '
      'They move slowly and spend years in each sign, so entire generations '
      'share them — they speak of collective, spiritual and profound changes',
  transpersonalSections: [
    BirthChartSection(
      title: '♅ Uranus - Disruption',
      body:
          'Disruption, freedom, innovation and revolution. Where you break patterns, '
          'seek authenticity and open new paths',
    ),
    BirthChartSection(
      title: '♆ Neptune - Dissolution',
      body:
          'Dreams, spirituality, idealization, dissolution and illusion. Your connection '
          'with the transcendent, imagination and compassion',
    ),
    BirthChartSection(
      title: '♇ Pluto - Transformation',
      body:
          'Power, crisis, symbolic death, transformation and regeneration. Where you '
          'deeply reinvent yourself and are reborn',
    ),
  ],
  pointsIntro:
      'Beyond the planets, the chart has calculated points and axes — crossings, '
      'angles and apogees that are not celestial bodies, yet reveal deep '
      'layers of destiny, shadow and soul',
  pointsSections: [
    BirthChartSection(
      title: 'MC · Midheaven - Vocation',
      body:
          'The highest point of the chart (cusp of House 10). It shows your vocation, '
          'public image, career and the legacy you build in the world',
    ),
    BirthChartSection(
      title: 'IC · Imum Coeli - Roots',
      body:
          'The lowest point (cusp of House 4), opposite the MC. It speaks of your '
          'roots, home, family and your most intimate emotional foundation',
    ),
    BirthChartSection(
      title: 'Dsc · Descendant - The Other',
      body:
          'The cusp of House 7, opposite the Ascendant. It describes relationships, '
          'partnerships and the qualities you seek (or project) in others',
    ),
    BirthChartSection(
      title: 'Vx · Vertex - Destiny',
      body:
          'A sensitive point linked to fateful encounters and turns of destiny — '
          'situations and people that arrive as if they were "written"',
    ),
    BirthChartSection(
      title: '⚸ Lilith - Black Moon',
      body:
          'The apogee of the lunar orbit. It represents your instinctive power, the shadow, '
          'untamed desire and that which refuses to be domesticated. In witchcraft, '
          'it is the portal of the wild witch and of feminine sovereignty',
    ),
    BirthChartSection(
      title: '⊗ Part of Fortune - Luck',
      body:
          'An Arabic point calculated from the Sun, the Moon and the Ascendant. It shows '
          'where your natural luck, prosperity and well-being live — the place '
          'of flow and joy in the chart',
    ),
    BirthChartSection(
      title: '☊ North Node - Growth',
      body:
          'It points to the experiences that demand growth and development — the '
          'direction your soul is walking toward in this life',
    ),
    BirthChartSection(
      title: '☋ South Node - Baggage',
      body:
          'Habits, talents and familiar or automatic patterns — the repertoire you '
          'already carry and where you tend to settle',
    ),
  ],
  housesIntro:
      'The 12 astrological houses represent different areas of your life. Each house '
      'is ruled by the sign on its cusp (beginning)',
  houseMeanings: {
    1: 'Identity, physical appearance, how you start things',
    2: 'Resources, money, personal values, self-esteem',
    3: 'Communication, siblings, neighbors, thinking',
    4: 'Home, family, roots, private life',
    5: 'Creativity, romance, children, fun',
    6: 'Health, routine, daily work, service',
    7: 'Partnerships, marriage, contracts, the other',
    8: 'Transformation, sexuality, death/rebirth, magic',
    9: 'Philosophy, travel, higher learning, expansion',
    10: 'Career, reputation, status, life mission',
    11: 'Friendships, groups, dreams, social causes',
    12: 'The unconscious, spirituality, karma, retreats',
  },
  housesTip: BirthChartSection(
    title: '🔮 Important houses for witchcraft',
    body:
        'House 8 (magic, transformation, mysteries) and House 12 (spirituality, intuition, '
        'connection with the divine) are especially important for magic practitioners. '
        'See your Magical Profile for a detailed analysis of these houses',
  ),
  aspectsIntro:
      'Aspects are the angular relationships between the planets. They show how the planetary '
      'energies interact with each other in your chart',
  aspectTypeMeanings: {
    AspectType.conjunction:
        'The planets are together. Intense, fused energy',
    AspectType.sextile:
        'Harmonious aspect. Opportunities and natural talents',
    AspectType.square: 'Challenging aspect. Tension that fuels growth',
    AspectType.trine: 'Very harmonious aspect. Easy flow of energy',
    AspectType.opposition:
        'Challenging aspect. Polarity and the need for balance',
  },
  aspectsTip: BirthChartSection(
    title: '💫 Good to know',
    body:
        '"Challenging" aspects are not bad! They point to areas of growth and '
        'potential. They are often where we develop our greatest strengths\n\n'
        'In magic, understanding your aspects helps you know which energies work '
        'well together and which need more attention in your rituals',
  ),
);
