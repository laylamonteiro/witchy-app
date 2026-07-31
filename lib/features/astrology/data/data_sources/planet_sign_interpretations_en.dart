import '../models/enums.dart';

/// Magical planet-sign interpretations — English content.
///
/// Map KEYS (`'<planet>_<sign>'`, derived from `Planet.name` and
/// `ZodiacSign.name`) are invariant across languages; only the text VALUES
/// are translated. Keep the same keys in the three files
/// (`planet_sign_interpretations_pt/en/es.dart`) — parity is verified by
/// `test/astrology_interpretations_parity_test.dart`.
const Map<String, String> planetSignInterpretationsEn = {
  // SUN in each sign
  'sun_aries':
      'With the Sun in Aries, your magical essence is INITIATING FIRE. You are a '
          'warrior witch, unafraid of starting new magical projects. Your magic is '
          'strongest when you act with courage and determination. Rituals of protection, '
          'willpower and new beginnings are your strong points. Work with red and orange '
          'candles, and cast your spells right at the start of each lunation.',
  'sun_taurus':
      'With the Sun in Taurus, your magical essence is EARTHY and SENSUAL. You are a '
          'green witch, deeply connected with nature and the cycles of the earth. Your '
          'magic manifests best through the senses - scents, textures, flavors. Rituals '
          'of prosperity, love and material abundance come naturally to you. Crystals, '
          'herbs and magical gardening are your allies.',
  'sun_gemini':
      'With the Sun in Gemini, your magical essence is MENTAL and COMMUNICATIVE. You '
          'are a witch of words, a master of verbal enchantments and sigils. Your '
          'curiosity leads you to explore many magical traditions. Tarot, runes and any '
          'form of divination come naturally to you. Use incense and work with the '
          'element of Air to empower your magic.',
  'sun_cancer':
      'With the Sun in Cancer, your magical essence is LUNAR and INTUITIVE. You are a '
          'hearth witch, a natural protector of family and sacred space. Your magic '
          'flows with the cycles of the Moon. Rituals of home protection, emotional '
          'healing and ancestor work are your gifts. Ritual baths and potions are '
          'especially powerful in your hands.',
  'sun_leo':
      'With the Sun in Leo, your magical essence is SOLAR and RADIANT. You are a '
          'performing witch who shines in group rituals. Your presence energizes any '
          'magic circle. Glamour magic, success and self-confidence come naturally to '
          'you. Work with gold, golden candles and rituals at noon. Lead rituals with a '
          'generous heart.',
  'sun_virgo':
      'With the Sun in Virgo, your magical essence is PRACTICAL and HEALING. You are '
          'an herbalist witch, a master at preparing remedies and potions with '
          'precision. Your attention to detail makes your rituals impeccable. Healing, '
          'purification and organization magic are your strong points. Keep a detailed '
          'grimoire and a perfectly organized altar.',
  'sun_libra':
      'With the Sun in Libra, your magical essence is HARMONIC and RELATIONAL. You '
          'are a diplomat witch, able to balance energies and harmonize spaces. Love, '
          'partnership and justice magic come naturally to you. Your altars are '
          'aesthetically beautiful. Work in pairs or groups to empower your magic. '
          'Energy-balancing rituals are your specialty.',
  'sun_scorpio':
      'With the Sun in Scorpio, your magical essence is TRANSFORMATIVE and DEEP. You '
          'are a witch of the occult, unafraid of exploring the deepest mysteries. Your '
          'magic is intense and powerful. Transformation, banishings and shadow work '
          'come naturally to you. Rituals of symbolic death and rebirth strengthen you. '
          'Pluto is your ally in transmutations.',
  'sun_sagittarius':
      'With the Sun in Sagittarius, your magical essence is EXPANSIVE and '
          'PHILOSOPHICAL. You are an adventurer witch, a seeker of truths across many '
          'traditions. Your magic grows stronger when you study and travel (physically '
          'or spiritually). Rituals of luck, expansion and astral travel come '
          'naturally. Jupiter blesses your spiritual journey.',
  'sun_capricorn':
      'With the Sun in Capricorn, your magical essence is DISCIPLINED and '
          'TRADITIONAL. You are an ancestral witch, connected with ancient practices '
          'and family traditions. Your magic grows stronger with consistency and '
          'structure. Rituals for career, long-term manifestation and protection are '
          'your strong points. Saturn teaches patience in your practice.',
  'sun_aquarius':
      'With the Sun in Aquarius, your magical essence is INNOVATIVE and COLLECTIVE. '
          'You are a futurist witch who brings new ideas to old practices. Your magic '
          'is strongest in groups and for humanitarian causes. Rituals of freedom, '
          'friendship and social change come naturally. Uranus inspires you to break '
          'paradigms in witchcraft.',
  'sun_pisces':
      'With the Sun in Pisces, your magical essence is MYSTICAL and COMPASSIONATE. '
          'You are a seer witch, naturally connected with the spirit world. Your magic '
          'flows through dreams, visions and pure intuition. Mediumship, channeling '
          'and empathic healing are your natural gifts. Neptune guides you on '
          'spiritual journeys.',

  // MOON in each sign
  'moon_aries':
      'With the Moon in Aries, your emotions are INTENSE and IMPULSIVE. You process '
          'feelings through action. Your magical intuition is quick and instinctive. '
          'Spontaneous rituals work well for you. When emotionally charged, channel it '
          'into protection magic or ritual physical exercise. The Moon in Aries '
          'empowers spells of courage.',
  'moon_taurus':
      'With the Moon in Taurus, your emotions are STABLE and SENSUAL. You find '
          'emotional comfort through the senses - food, nature, touch. Your intuition '
          'speaks through the body. Rituals with physical elements (crystals, herbs, '
          'oils) are especially effective. You need emotional security for your magic '
          'to flow.',
  'moon_gemini':
      'With the Moon in Gemini, your emotions are VERSATILE and COMMUNICATIVE. You '
          'process feelings by talking or writing about them. Your intuition comes '
          'through words, messages and synchronicities. Magical journaling and '
          'automatic writing are powerful tools. The Moon in Gemini empowers '
          'divination.',
  'moon_cancer':
      'With the Moon in Cancer, you are AT HOME. This is the Moon\'s most powerful '
          'placement. Your emotions are deep, your intuition is strong, and your '
          'connection with the lunar cycles is natural. You feel the Moon\'s phases in '
          'your body. All lunar magic is amplified for you. Ancestor work and family '
          'protection are natural gifts.',
  'moon_leo':
      'With the Moon in Leo, your emotions are DRAMATIC and GENEROUS. You need to '
          'feel special and recognized to be well. Your intuition shines when you are '
          'on stage or leading. Theatrical, expressive rituals work well. The Moon in '
          'Leo empowers magic of self-esteem and creative expression.',
  'moon_virgo':
      'With the Moon in Virgo, your emotions are ANALYTICAL and seek ORDER. You '
          'process feelings by trying to understand them logically. Your intuition '
          'speaks through details and patterns. Meticulous, organized rituals calm '
          'you. The Moon in Virgo empowers healing and purification magic.',
  'moon_libra':
      'With the Moon in Libra, your emotions seek HARMONY and BEAUTY. You need peace '
          'and balanced relationships to be well. Your intuition speaks through '
          'aesthetics and a sense of justice. Elegant, balanced rituals work best. '
          'The Moon in Libra empowers relationship magic.',
  'moon_scorpio':
      'With the Moon in Scorpio, your emotions are INTENSE and TRANSFORMATIVE. You '
          'feel everything deeply and are not afraid of the emotional dark. Your '
          'psychic intuition is powerful. Transformation rituals and shadow work come '
          'naturally. The Moon in Scorpio amplifies occult and banishing magic.',
  'moon_sagittarius':
      'With the Moon in Sagittarius, your emotions seek FREEDOM and MEANING. You '
          'need emotional space and purpose. Your intuition speaks through visions '
          'and philosophical insights. Outdoor rituals and spiritual journeys nourish '
          'you. The Moon in Sagittarius empowers expansion magic.',
  'moon_capricorn':
      'With the Moon in Capricorn, your emotions are CONTAINED and PRACTICAL. You '
          'process feelings through work and structure. Your intuition speaks through '
          'tradition and experience. Structured, traditional rituals work best. The '
          'Moon in Capricorn empowers magic of material manifestation.',
  'moon_aquarius':
      'With the Moon in Aquarius, your emotions are DETACHED and HUMANITARIAN. You '
          'process feelings intellectually. Your intuition arrives as sudden downloads '
          'and insights. Group rituals and work for collective causes nourish you. '
          'The Moon in Aquarius empowers innovation magic.',
  'moon_pisces':
      'With the Moon in Pisces, your emotions are OCEANIC and boundless. You absorb '
          'the feelings around you like a sponge. Your psychic intuition is extremely '
          'strong. Water rituals, lucid dreams and deep meditation come naturally. The '
          'Moon in Pisces amplifies all intuitive and spiritual magic.',

  // MERCURY in each sign
  'mercury_aries':
      'With Mercury in Aries, your mind is FAST and DIRECT. You think and speak with '
          'speed and assertiveness. Short, direct enchantments work better than long '
          'rituals for you. Your magical communication is courageous. Quick-action '
          'sigils are your specialty.',
  'mercury_taurus':
      'With Mercury in Taurus, your mind is PRACTICAL and DELIBERATE. You think '
          'slowly but with depth. You prefer memorizing enchantments to improvising. '
          'Your magical communication has weight and substance. Repetitive chants and '
          'mantras are especially powerful.',
  'mercury_gemini':
      'With Mercury in Gemini, your mind is BRILLIANT and VERSATILE. This is '
          'Mercury\'s strongest placement. You are a master of magic words. Sigils, '
          'enchantments and all verbal magic are amplified. Tarot and oracles speak '
          'clearly to you.',
  'mercury_cancer':
      'With Mercury in Cancer, your mind is INTUITIVE and EMOTIONAL. You think with '
          'the heart. Your magical communication carries deep emotion. Enchantments '
          'spoken with feeling are especially powerful. You receive messages through '
          'memories and dreams.',
  'mercury_leo':
      'With Mercury in Leo, your mind is CREATIVE and DRAMATIC. You express yourself '
          'with flair and confidence. Enchantments proclaimed out loud are especially '
          'powerful. Your magical communication inspires others. You excel at leading '
          'group invocations.',
  'mercury_virgo':
      'With Mercury in Virgo, your mind is ANALYTICAL and PRECISE. This is another '
          'strong placement of Mercury. You are meticulous with words and '
          'correspondences. Your magical records are impeccable. Detailed, precise '
          'enchantments are your specialty.',
  'mercury_libra':
      'With Mercury in Libra, your mind seeks BALANCE and DIPLOMACY. You consider '
          'every side before deciding. Your magical communication is elegant and '
          'harmonious. Enchantments of partnership and justice come naturally. You '
          'excel at spiritual mediation.',
  'mercury_scorpio':
      'With Mercury in Scorpio, your mind is PENETRATING and INVESTIGATIVE. You go '
          'deep into any subject. Your magical communication is intense and '
          'transformative. Words of power and secret invocations are your specialty. '
          'You uncover hidden knowledge easily.',
  'mercury_sagittarius':
      'With Mercury in Sagittarius, your mind is EXPANSIVE and PHILOSOPHICAL. You '
          'think in broad, universal terms. Your magical communication is inspiring '
          'and optimistic. Studying many traditions enriches your practice. '
          'Enchantments of expansion are powerful.',
  'mercury_capricorn':
      'With Mercury in Capricorn, your mind is STRUCTURED and SERIOUS. You think '
          'long-term and practically. Your magical communication is traditional and '
          'respectful. Formal, traditional enchantments work best. You learn well '
          'from mentors.',
  'mercury_aquarius':
      'With Mercury in Aquarius, your mind is ORIGINAL and VISIONARY. You think '
          'outside the box and question everything. Your magical communication is '
          'innovative. You create new enchantments and systems. Sudden intuitive '
          'downloads are common for you.',
  'mercury_pisces':
      'With Mercury in Pisces, your mind is INTUITIVE and IMAGINATIVE. You think in '
          'symbols and images. Your magical communication is poetic and fluid. '
          'Automatic writing and channeling come naturally. You receive messages '
          'through dreams and visions.',

  // VENUS in each sign
  'venus_aries':
      'With Venus in Aries, you LOVE with PASSION and INTENSITY. Love magic for you '
          'should be direct and courageous. You attract through energy and '
          'initiative. Rituals of self-love and confidence are especially powerful. '
          'Spells of passion and attraction work quickly.',
  'venus_taurus':
      'With Venus in Taurus, you LOVE with the SENSES. This is Venus\'s strongest '
          'placement. You attract through beauty and sensory pleasure. Love magic '
          'with oils, perfumes and food is especially effective. Rituals of loving '
          'prosperity come naturally.',
  'venus_gemini':
      'With Venus in Gemini, you LOVE through COMMUNICATION. Mental connection is '
          'essential for you. Love magic includes words, letters and conversations. '
          'You attract through intellect and humor. Spells with love sigils are '
          'especially effective.',
  'venus_cancer':
      'With Venus in Cancer, you LOVE with CARE and PROTECTION. Emotional security '
          'is essential. Love magic focused on family and home is powerful. You '
          'attract through tenderness and nurturing. Love rituals during the Full '
          'Moon are amplified.',
  'venus_leo':
      'With Venus in Leo, you LOVE with DRAMA and GENEROSITY. Grand romance attracts '
          'you. Love magic should be special and theatrical. You attract through '
          'radiance and confidence. Love glamour rituals are your specialty.',
  'venus_virgo':
      'With Venus in Virgo, you LOVE through SERVICE. Acts of care are your love '
          'language. Practical, useful love magic works best. You attract through '
          'competence and attention to detail. Prepare love potions with care.',
  'venus_libra':
      'With Venus in Libra, you LOVE with HARMONY and ELEGANCE. This is another '
          'strong placement of Venus. Balanced partnerships are essential. Aesthetic, '
          'romantic love magic is powerful. You attract through grace and diplomacy. '
          'Marriage rituals are your specialty.',
  'venus_scorpio':
      'With Venus in Scorpio, you LOVE with TOTAL INTENSITY. Deep, transformative '
          'connections attract you. Love magic is intense and powerful for you. You '
          'attract through magnetism and mystery. Love rituals involving deep '
          'commitment are effective.',
  'venus_sagittarius':
      'With Venus in Sagittarius, you LOVE with FREEDOM. Connections that expand '
          'your world attract you. Love magic should include adventure and growth. '
          'You attract through optimism and humor. Outdoor love rituals are powerful.',
  'venus_capricorn':
      'With Venus in Capricorn, you LOVE with COMMITMENT. Serious, lasting '
          'relationships attract you. Love magic should be practical and build for '
          'the future. You attract through stability. Love rituals with structure '
          'and tradition work.',
  'venus_aquarius':
      'With Venus in Aquarius, you LOVE with FREEDOM and FRIENDSHIP. Unique, '
          'unconventional connections attract you. Love magic should respect '
          'individuality. You attract through originality. Love rituals in groups or '
          'for friendship are powerful.',
  'venus_pisces':
      'With Venus in Pisces, you LOVE with TOTAL DEVOTION. This is Venus\'s most '
          'romantic placement. Spiritual connections attract you. Love magic is '
          'transcendent for you. You attract through compassion. Love rituals with '
          'water and music are especially effective.',

  // MARS in each sign
  'mars_aries':
      'With Mars in Aries, your ENERGY is EXPLOSIVE and DIRECT. This is Mars\'s '
          'strongest placement. You act with courage and initiative. Protection and '
          'banishing magic is especially powerful. Quick-action rituals are '
          'effective. Use this energy to start magical projects.',
  'mars_taurus':
      'With Mars in Taurus, your ENERGY is PERSISTENT and DETERMINED. You act slowly '
          'but with unstoppable force. Magic of material manifestation is powerful. '
          'Rituals that require patience work well. Use this energy for long-lasting '
          'protection.',
  'mars_gemini':
      'With Mars in Gemini, your ENERGY is VERSATILE and MENTAL. You act through '
          'words and ideas. Verbal and communication magic is powerful. Debates and '
          'discussions energize you. Use this energy for active sigils.',
  'mars_cancer':
      'With Mars in Cancer, your ENERGY is PROTECTIVE and EMOTIONAL. You act to '
          'defend those you love. Family protection magic is especially powerful. '
          'Emotionally charged rituals are effective. Use this energy to protect '
          'the home.',
  'mars_leo':
      'With Mars in Leo, your ENERGY is DRAMATIC and CREATIVE. You act with flair '
          'and confidence. Magic of self-expression and courage is powerful. '
          'Theatrical rituals are effective. Use this energy for leadership rituals.',
  'mars_virgo':
      'With Mars in Virgo, your ENERGY is PRECISE and EFFICIENT. You act '
          'methodically and with attention to detail. Healing and purification magic '
          'is powerful. Well-planned rituals are more effective. Use this energy for '
          'precise workings.',
  'mars_libra':
      'With Mars in Libra, your ENERGY seeks JUSTICE and BALANCE. You act in the '
          'name of harmony. Justice and balance magic is powerful. Partnership '
          'rituals are effective. Use this energy to resolve conflicts magically.',
  'mars_scorpio':
      'With Mars in Scorpio, your ENERGY is INTENSE and TRANSFORMATIVE. This is a '
          'very strong placement of Mars. You act with relentless determination. '
          'Transformation and banishing magic is extremely powerful. Use this energy '
          'for deep changes.',
  'mars_sagittarius':
      'With Mars in Sagittarius, your ENERGY is ADVENTUROUS and EXPANSIVE. You act '
          'with optimism and enthusiasm. Expansion and travel magic is powerful. '
          'Outdoor rituals are effective. Use this energy for active spiritual '
          'growth.',
  'mars_capricorn':
      'With Mars in Capricorn, your ENERGY is DISCIPLINED and AMBITIOUS. This is a '
          'very strong placement of Mars. You act with strategy and patience. Career '
          'and material manifestation magic is powerful. Structured rituals are '
          'effective.',
  'mars_aquarius':
      'With Mars in Aquarius, your ENERGY is REVOLUTIONARY and INDEPENDENT. You act '
          'in unconventional ways. Group magic and magic for social causes is '
          'powerful. Innovative rituals are effective. Use this energy for '
          'collective change.',
  'mars_pisces':
      'With Mars in Pisces, your ENERGY is FLUID and INTUITIVE. You act guided by '
          'intuition and compassion. Spiritual and healing magic is powerful. '
          'Meditative rituals are effective. Use this energy for active spiritual '
          'work.',
};

// The enum getters (`displayName`, `magicalDescription`) are already
// localized via `ContentLocale`, so the template functions below use them
// directly instead of re-translating planet/sign/element names.

/// Default (composed) interpretation when there is no specific entry in the
/// map — covers outer planets, the nodes and the mystic points (MC/IC/DSC,
/// Vertex, Lilith, Part of Fortune). Joins the planet's theme with the sign's
/// style plus a short magical tip.
String planetSignDefaultInterpretationEn(Planet planet, ZodiacSign sign) {
  final style = _signStyleEn(sign);
  final magic = _planetMagicEn(planet);

  if (planet == Planet.northNode) {
    return 'Your North Node in ${sign.displayName} points to this life\'s '
        'path of growth and purpose, to be walked $style. $magic';
  }
  if (planet == Planet.southNode) {
    return 'Your South Node in ${sign.displayName} reveals gifts already '
        'earned and the comfort zone you carry $style. $magic';
  }
  // English has no gendered article — "Your" covers every point.
  return 'Your ${planet.displayName} in ${sign.displayName} expresses '
      '${_planetMeaningEn(planet)}, $style. $magic';
}

/// Core theme of each planet (noun phrase).
String _planetMeaningEn(Planet planet) {
  switch (planet) {
    case Planet.sun:
      return 'your essence and vitality';
    case Planet.moon:
      return 'your emotions and inner world';
    case Planet.mercury:
      return 'your mind and communication';
    case Planet.venus:
      return 'love, pleasure, and beauty';
    case Planet.mars:
      return 'action, desire, and courage';
    case Planet.jupiter:
      return 'expansion, faith, and abundance';
    case Planet.saturn:
      return 'discipline, boundaries, and maturity';
    case Planet.uranus:
      return 'innovation, disruption, and freedom';
    case Planet.neptune:
      return 'spirituality, dreams, and imagination';
    case Planet.pluto:
      return 'deep transformation and the power of rebirth';
    case Planet.northNode:
      return 'the soul\'s path of growth';
    case Planet.southNode:
      return 'gifts inherited from other lives';
    case Planet.midheaven:
      return 'your calling, public image, and the legacy you build';
    case Planet.imumCoeli:
      return 'your roots, home, and innermost emotional foundation';
    case Planet.descendant:
      return 'relationships and what you seek in another';
    case Planet.vertex:
      return 'fateful encounters and turns of destiny';
    case Planet.lilith:
      return 'instinctive power, shadow, and untamed desire';
    case Planet.partOfFortune:
      return 'your luck, prosperity, and well-being';
  }
}

/// Each sign's style of expression (element + quality in a nutshell).
String _signStyleEn(ZodiacSign sign) {
  switch (sign) {
    case ZodiacSign.aries:
      return 'in a bold, direct, pioneering way';
    case ZodiacSign.taurus:
      return 'in a steady, sensory, persistent way';
    case ZodiacSign.gemini:
      return 'in a curious, communicative, versatile way';
    case ZodiacSign.cancer:
      return 'in a sensitive, protective, nurturing way';
    case ZodiacSign.leo:
      return 'in an expressive, generous, creative way';
    case ZodiacSign.virgo:
      return 'in a practical, analytical, careful way';
    case ZodiacSign.libra:
      return 'in a harmonious, diplomatic, aesthetic way';
    case ZodiacSign.scorpio:
      return 'in an intense, deep, transformative way';
    case ZodiacSign.sagittarius:
      return 'in an adventurous, philosophical, optimistic way';
    case ZodiacSign.capricorn:
      return 'in a disciplined, ambitious, responsible way';
    case ZodiacSign.aquarius:
      return 'in an original, independent, humanitarian way';
    case ZodiacSign.pisces:
      return 'in a sensitive, imaginative, compassionate way';
  }
}

/// Short magical tip per planet.
String _planetMagicEn(Planet planet) {
  switch (planet) {
    case Planet.sun:
      return 'In magic, it is your center of power and identity.';
    case Planet.moon:
      return 'In magic, it guides your cycles, intuition, and lunar workings.';
    case Planet.mercury:
      return 'In magic, it favors spells of communication, study, and clarity.';
    case Planet.venus:
      return 'In magic, it rules rituals of love, self-worth, and pleasure.';
    case Planet.mars:
      return 'In magic, it fuels protection, courage, and banishing.';
    case Planet.jupiter:
      return 'In magic, use it in rituals of growth, luck, and abundance.';
    case Planet.saturn:
      return 'In magic, use it in workings of structure, protection, and lasting commitments.';
    case Planet.uranus:
      return 'In magic, use it to break patterns and open new paths.';
    case Planet.neptune:
      return 'In magic, use it in dreamwork, divination, and spiritual connection.';
    case Planet.pluto:
      return 'In magic, use it in rites of transformation, deep healing, and rebirth.';
    case Planet.northNode:
      return 'Cultivate this sign\'s qualities — it is where your soul grows toward.';
    case Planet.southNode:
      return 'Honor these already-natural gifts, and avoid settling for them alone.';
    case Planet.midheaven:
      return 'In magic, direct rituals of purpose, career, and recognition here.';
    case Planet.imumCoeli:
      return 'In magic, use it in workings of home protection, ancestry, and roots.';
    case Planet.descendant:
      return 'In magic, it favors rituals of partnership, unions, and harmony with others.';
    case Planet.vertex:
      return 'In magic, it marks fated encounters — work with synchronicities and portals.';
    case Planet.lilith:
      return 'In magic, it is the wild witch\'s portal: sovereignty, shadow, and desire.';
    case Planet.partOfFortune:
      return 'In magic, aim spells of prosperity, luck, and abundance here.';
  }
}

/// Short summary for list display.
String planetSignShortInterpretationEn(Planet planet, ZodiacSign sign) {
  switch (planet) {
    case Planet.sun:
      return 'Your magical essence is ${sign.magicalDescription}';
    case Planet.moon:
      return 'Your emotions and intuition are ${sign.magicalDescription}';
    case Planet.mercury:
      return 'Your mind and communication are ${sign.magicalDescription}';
    case Planet.venus:
      return 'Your love and beauty are ${sign.magicalDescription}';
    case Planet.mars:
      return 'Your energy and action are ${sign.magicalDescription}';
    case Planet.jupiter:
      return 'Your luck and expansion are ${sign.magicalDescription}';
    case Planet.saturn:
      return 'Your discipline and structure are ${sign.magicalDescription}';
    case Planet.uranus:
      return 'Your innovation is ${sign.magicalDescription}';
    case Planet.neptune:
      return 'Your spirituality is ${sign.magicalDescription}';
    case Planet.pluto:
      return 'Your transformation is ${sign.magicalDescription}';
    default:
      return '${planet.displayName} in ${sign.displayName}';
  }
}
