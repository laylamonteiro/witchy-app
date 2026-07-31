import '../models/metal_model.dart';
import '../models/crystal_model.dart';
import '../models/herb_model.dart';

/// Encyclopedia metals — English content.
///
/// Enums, elements, planets and images are invariant across languages.
/// Keep the same order as `metals_data_pt.dart` — parity is verified by
/// `test/content_parity_test.dart`.
final List<MetalModel> metalsEn = [
  const MetalModel(
    name: 'Gold',
    description:
        'The precious metal of the Sun, symbol of divine power, royalty and perfection. '
        'It represents spiritual light, illumination and vital energy. '
        'Traditionally used to attract prosperity, success and protection.',
    element: Element.fire,
    planet: Planet.sun,
    conductsPower: true,
    imageUrl: 'assets/images/metais/ouro.jpg',
    magicalProperties: [
      'Prosperity and abundance',
      'Personal power',
      'Success and victory',
      'Spiritual protection',
      'Vital energy',
      'Illumination',
      'Self-confidence',
      'Manifestation',
    ],
    ritualUses: [
      'Amulets of protection and power',
      'Solar and prosperity rituals',
      'Consecration of ritual tools',
      'Wealth-drawing magic',
      'Workings with solar deities',
      'Rituals for confidence and leadership',
    ],
    correspondences: [
      'Day: Sunday',
      'Gods: Apollo, Ra, Lugh, Balder',
      'Goddesses: Brighid, Amaterasu',
      'Chakra: Solar Plexus, Crown',
      'Sabbat: Litha (Summer Solstice)',
      'Tarot: The Sun',
    ],
    traditionalUses:
        'Used in crowns, scepters and ritual objects of power. '
        'Gold jewelry is traditionally worn for protection '
        'and to draw in solar energy.',
    safetyWarnings: [],
  ),
  const MetalModel(
    name: 'Silver',
    description:
        'The sacred metal of the Moon, symbol of intuition, mystery and psychic protection. '
        'It represents the divine feminine, cycles and lunar magic. '
        'It is the metal most used in witchcraft for protection and divination.',
    element: Element.water,
    planet: Planet.moon,
    conductsPower: true,
    imageUrl: 'assets/images/metais/prata.jpg',
    magicalProperties: [
      'Psychic protection',
      'Intuition and clairvoyance',
      'Lunar connection',
      'Prophetic dreams',
      'Purification',
      'Feminine magic',
      'Reflection and introspection',
      'Divination',
    ],
    ritualUses: [
      'Magic mirrors and crystal balls',
      'Protective jewelry',
      'Ritual chalices and cups',
      'Moon pendants',
      'Lunar and dream magic',
      'Divination rituals',
      'Workings with lunar deities',
    ],
    correspondences: [
      'Day: Monday',
      'Gods: Thoth, Khonsu',
      'Goddesses: Selene, Diana, Artemis, Hecate',
      'Chakra: Third Eye, Crown',
      'Sabbat: Esbats (Full Moons)',
      'Tarot: The Moon, The High Priestess',
    ],
    traditionalUses:
        'Traditionally used in amulets, magic mirrors, '
        'ritual chalices and protective jewelry. Silver is said '
        'to tarnish in the presence of negative energy.',
    safetyWarnings: [],
  ),
  const MetalModel(
    name: 'Copper',
    description:
        'The metal of Venus, supreme conductor of magical energy. '
        'Associated with love, beauty, harmony and healing. '
        'It is the most energy-conductive metal after silver.',
    element: Element.water,
    planet: Planet.venus,
    conductsPower: true,
    imageUrl: 'assets/images/metais/cobre.jpg',
    magicalProperties: [
      'Love and romance',
      'Beauty and attraction',
      'Harmony and peace',
      'Energy healing',
      'Energy conduction',
      'Artistic creativity',
      'Fertility',
      'Emotional balance',
    ],
    ritualUses: [
      'Magic wands (copper core)',
      'Love talismans',
      'Healing amulets',
      'Tools for channeling energy',
      'Venus rituals',
      'Attraction magic',
      'Protection circles',
    ],
    correspondences: [
      'Day: Friday',
      'Gods: Eros, Cupid',
      'Goddesses: Aphrodite, Venus, Freya, Hathor',
      'Chakra: Heart',
      'Sabbat: Beltane',
      'Tarot: The Empress, The Lovers',
    ],
    traditionalUses:
        'Used in wands, love amulets, and healing tools. '
        'Copper pyramids are used to amplify energy. '
        'Copper bracelets are traditionally worn to ease aches and pains.',
    safetyWarnings: [
      'May stain the skin green (not dangerous, just oxidation)',
    ],
  ),
  const MetalModel(
    name: 'Iron',
    description:
        'The metal of Mars, symbol of protection, strength and courage. '
        'Traditionally used to ward off evil spirits and faeries. '
        'It represents warrior strength and physical protection.',
    element: Element.fire,
    planet: Planet.mars,
    conductsPower: false,
    imageUrl: 'assets/images/metais/ferro.jpg',
    magicalProperties: [
      'Powerful protection',
      'Courage and strength',
      'Banishing negativity',
      'Psychic defense',
      'Grounding',
      'Willpower',
      'Justice',
      'Curse breaking',
    ],
    ritualUses: [
      'Iron nails for home protection',
      'Lucky horseshoes',
      'Athames and ritual knives',
      'Cauldrons',
      'Protective amulets',
      'Banishing circles',
      'Mars rituals',
    ],
    correspondences: [
      'Day: Tuesday',
      'Gods: Mars, Ares, Thor, Ogun',
      'Goddesses: Morrigan, Durga',
      'Chakra: Root, Solar Plexus',
      'Sabbat: Not specifically associated',
      'Tarot: The Tower, The Chariot',
    ],
    traditionalUses:
        'Horseshoes over doors for protection. Iron nails '
        'buried at the corners of the property. Ritual knives (athames) '
        'with iron blades. Faeries and evil spirits are said '
        'to be unable to cross iron.',
    safetyWarnings: [
      'Rusts easily - keep it dry',
    ],
  ),
  const MetalModel(
    name: 'Tin',
    description:
        'The metal of Jupiter, associated with expansion, growth and justice. '
        'Traditionally used to attract prosperity, luck and legal protection.',
    element: Element.air,
    planet: Planet.jupiter,
    conductsPower: true,
    imageUrl: 'assets/images/metais/estanho.jpg',
    magicalProperties: [
      'Prosperity and expansion',
      'Luck and fortune',
      'Justice and fairness',
      'Spiritual growth',
      'Protection while traveling',
      'Abundance',
      'Wisdom',
      'Honor and reputation',
    ],
    ritualUses: [
      'Prosperity amulets',
      'Justice rituals',
      'Luck magic',
      'Travel protection',
      'Workings with Jupiter',
      'Thursday rituals',
      'Business-growth magic',
    ],
    correspondences: [
      'Day: Thursday',
      'Gods: Jupiter, Zeus, Thor, Dagda',
      'Goddesses: Themis, Fortuna',
      'Chakra: Crown, Third Eye',
      'Sabbat: Yule',
      'Tarot: The Wheel of Fortune, The Hierophant',
    ],
    traditionalUses:
        'Used in talismans for luck and prosperity. '
        'Tin coins are traditionally carried to attract money. '
        'Also used in ritual bells.',
    safetyWarnings: [],
  ),
  const MetalModel(
    name: 'Lead',
    description:
        'The metal of Saturn, associated with time, boundaries and deep transformation. '
        'Used in banishing magic, heavy protection and breaking addictions. '
        'It represents limitations, discipline and karma.',
    element: Element.earth,
    planet: Planet.saturn,
    conductsPower: false,
    imageUrl: 'assets/images/metais/chumbo.jpg',
    magicalProperties: [
      'Powerful banishing',
      'Heavy protection',
      'Breaking addictions',
      'Boundaries and discipline',
      'Deep grounding',
      'Shadow work',
      'Karma and divine justice',
      'Difficult transformation',
    ],
    ritualUses: [
      'Banishing rituals',
      'Curse breaking',
      'Boundary magic',
      'Saturn workings',
      'Saturday rituals',
      'Burying negative intentions',
      'Protection against dark magic',
    ],
    correspondences: [
      'Day: Saturday',
      'Gods: Saturn, Cronus, Hades',
      'Goddesses: Hecate, The Fates',
      'Chakra: Root',
      'Sabbat: Samhain',
      'Tarot: Death, The Hermit, The World',
    ],
    traditionalUses:
        'Traditionally used to seal negative intentions inside boxes '
        'that are then buried. Used in protective weights and in rituals '
        'of definitive banishing.',
    safetyWarnings: [
      '⚠️ TOXIC - Do not ingest, avoid prolonged skin contact',
      'Wash your hands after handling',
      'Do not use in cauldrons or kitchen utensils',
      'Keep away from children and animals',
    ],
  ),
  const MetalModel(
    name: 'Bronze',
    description:
        'An ancient alloy of copper and tin, it represents tradition, antiquity and ancestral connection. '
        'Used since time immemorial in weapons, shields and ritual objects.',
    element: Element.fire,
    planet: Planet.venus,
    conductsPower: true,
    imageUrl: 'assets/images/metais/bronze.jpg',
    magicalProperties: [
      'Ancestral connection',
      'Tradition and history',
      'Lasting protection',
      'Strength and endurance',
      'Ancient magic',
      'Honoring the ancestors',
      'Preservation',
      'Memory',
    ],
    ritualUses: [
      'Ritual bells',
      'Magical musical instruments',
      'Deity statues',
      'Cauldrons (traditional)',
      'Ancestral workings',
      'Rituals of tradition',
      'Lineage protection',
    ],
    correspondences: [
      'Day: Friday (from copper)',
      'Gods: Hephaestus, Goibniu, Wayland',
      'Goddesses: Athena (warrior)',
      'Chakra: Root, Solar Plexus',
      'Sabbat: Mabon',
      'Tarot: The Hermit, Judgement',
    ],
    traditionalUses:
        'Bronze bells are used to cleanse energy and mark '
        'the opening of rituals. Bronze cauldrons are traditional '
        'in Celtic witchcraft. Polished bronze mirrors were used '
        'in antiquity for divination.',
    safetyWarnings: [],
  ),
  const MetalModel(
    name: 'Brass',
    description:
        'An alloy of copper and zinc, associated with purification, energy cleansing '
        'and protection against negativity. It shines like gold but is far more accessible.',
    element: Element.fire,
    planet: Planet.sun,
    conductsPower: true,
    imageUrl: 'assets/images/metais/latao.jpg',
    magicalProperties: [
      'Purification',
      'Energy cleansing',
      'Protection against negativity',
      'Mental clarity',
      'Luck attraction',
      'Dispelling illusions',
      'Accessible solar energy',
      'Truth',
    ],
    ritualUses: [
      'Cleansing bells',
      'Censers',
      'Offering bowls',
      'Candlesticks',
      'Protective amulets',
      'Purification rituals',
      'Space cleansing',
    ],
    correspondences: [
      'Day: Sunday',
      'Gods: Apollo, Helios',
      'Goddesses: Brighid',
      'Chakra: Solar Plexus',
      'Sabbat: Litha',
      'Tarot: Temperance, The Magician',
    ],
    traditionalUses:
        'Traditionally used in censers and cleansing bells. '
        'Polished brass objects are placed on altars to reflect '
        'negative energy away. An accessible substitute for gold in magic.',
    safetyWarnings: [],
  ),
  const MetalModel(
    name: 'Aluminum',
    description:
        'A modern metal associated with mental protection, blocking outside '
        'influences and preserving energy. Light and versatile.',
    element: Element.air,
    planet: Planet.mercury,
    conductsPower: true,
    imageUrl: 'assets/images/metais/aluminio.jpg',
    magicalProperties: [
      'Mental protection',
      'Blocking influences',
      'Energy preservation',
      'Lightness and adaptability',
      'Reflecting negativity',
      'Clear communication',
      'Speed',
      'Modernity',
    ],
    ritualUses: [
      'Wrapping magical objects for preservation',
      'Protecting tarot decks and tools',
      'Mental-shielding rituals',
      'Communication magic',
      'Reflecting spells back',
      'Mercury workings',
    ],
    correspondences: [
      'Day: Wednesday',
      'Gods: Mercury, Hermes',
      'Goddesses: Athena (wisdom)',
      'Chakra: Throat, Third Eye',
      'Sabbat: Not associated',
      'Tarot: The Fool, The Magician',
    ],
    traditionalUses:
        'Aluminum foil is used to wrap and protect tarot cards, '
        'crystals and magical objects. Also used to reflect negative '
        'energy back to its source.',
    safetyWarnings: [],
  ),
];
