import '../models/arcane_entry_model.dart';

/// Sacred Symbols of Witchcraft — English content.
///
/// Emojis and non-textual correspondences are invariant across languages.
/// Keep the same order as `sacred_symbols_data_pt.dart` — parity is verified
/// by `test/content_parity_test.dart`.
const List<ArcaneEntry> sacredSymbolsEn = [
  ArcaneEntry(
    name: 'Pentagram',
    emoji: '⛤',
    summary: 'The five-pointed star: the elements in balance',
    origin: 'Mesopotamia and Pythagorean Greece; reclaimed by modern witchcraft',
    history:
        'Used by Sumerians and Pythagoreans (who called it "health"), the pentagram passed through medieval Christianity as a symbol of the five wounds before becoming, in nineteenth-century occultism and in Wicca, the emblem of the four elements crowned by Spirit. Inverted, it gained diverse readings — from the symbol of Baphomet to traditional uses with no negative connotation.',
    characteristics: [
      'Point upward: spirit governing matter',
      'Continuous stroke: protection without gaps',
      'Within the circle (pentacle): consecration',
    ],
    symbolism: [
      'The five points: Earth, Air, Fire, Water and Spirit',
      'The golden ratio hidden in the tracing',
    ],
    correspondences: ['All the elements', 'Silver', 'Salt and candles in rituals'],
    studyPractices: [
      'Learn to trace invoking and banishing pentagrams',
      'Study the symbol\'s history before the modern stigmas',
    ],
    magicalUses: [
      'Protection of spaces and people',
      'Consecration of tools on the altar pentacle',
    ],
    cautions:
        'The inverted pentagram carries multiple meanings depending on the tradition — avoid hasty judgments.',
    related: ['Sigils', 'Altar (Encyclopedia)', 'Elements'],
  ),
  ArcaneEntry(
    name: 'Triple Moon',
    emoji: '🌒🌕🌘',
    summary: 'Waxing, full and waning: the three faces of the Goddess',
    origin: 'Iconography of modern witchcraft (20th c.), with classical roots',
    history:
        'The Maiden-Mother-Crone association was articulated by Robert Graves and embraced by Wicca. The symbol — waxing crescent, full disc and waning crescent joined — became the emblem of the Triple Goddess and the crown of high priestesses.',
    characteristics: [
      'A synthesis of the complete lunar cycle',
      'The three phases of life and of creation',
    ],
    symbolism: [
      'Waxing: beginnings and youth',
      'Full: fullness and power',
      'Waning: wisdom and closure',
    ],
    correspondences: ['Moon', 'Silver', 'Moonstone', 'Monday'],
    studyPractices: [
      'Follow a complete lunar cycle in the app\'s Lunar Calendar',
      'Identify which "phase" each area of your life is in',
    ],
    magicalUses: [
      'Crown altars dedicated to the Goddess',
      'Synchronize rituals with the corresponding phase',
    ],
    cautions:
        'A modern symbol with ancient roots: acknowledging its historicity does not diminish its devotional power.',
    related: ['Moon Phases', 'The Maiden, The Mother and The Wise Woman (Archetypes)'],
  ),
  ArcaneEntry(
    name: 'Ankh',
    emoji: '☥',
    summary: 'The key of life from ancient Egypt',
    origin: 'Ancient Egypt (hieroglyph for "life")',
    history:
        'A hieroglyph meaning "life", the ankh appears in the hands of Egyptian gods offering the breath of life to the pharaohs. Adopted by the Copts as a cross and by modern occultism as a symbol of vitality and immortality.',
    characteristics: [
      'Union of the circle (the eternal) with the cross (matter)',
      'A symbol of the offering of life in sacred scenes',
    ],
    symbolism: [
      'The loop: the rising sun, the eternal',
      'The shaft: the earthly path',
      'In the hands of the gods: life as a gift',
    ],
    correspondences: ['Sun', 'Gold', 'Frankincense', 'Vitality'],
    studyPractices: [
      'Study Egyptian iconography and its gods',
      'Meditate holding the symbol: "what gives me life?"',
    ],
    magicalUses: [
      'Talisman of vitality and energetic health',
      'A presence on ancestry altars',
    ],
    cautions:
        'Respect the cultural origin: the ankh is a heritage of ancient Egypt, not an empty ornament.',
    related: ['Energy & Healing (Grimoire)', 'Sacred Symbols'],
  ),
  ArcaneEntry(
    name: 'Triquetra',
    emoji: '🔱',
    summary: 'The three-cornered knot: trinities and continuity',
    origin: 'Celtic and Germanic art; Christian and neopagan reinterpretations',
    history:
        'Found on rune stones and in the Book of Kells, the triquetra is an interlacing of three arcs with no beginning and no end. It served the Christian Trinity in Ireland and today represents, in witchcraft, triads such as land-sea-sky or body-mind-spirit.',
    characteristics: [
      'A single continuous line: unity within the three',
      'Often interlaced with a circle',
    ],
    symbolism: [
      'Land, sea and sky in Celtic cosmology',
      'Past, present and future',
      'The Triple Goddess in Wiccan readings',
    ],
    correspondences: ['Ritual triads', 'Green and gold', 'Oak'],
    studyPractices: [
      'Draw the triquetra in a continuous stroke as meditation',
      'Study the symbolism of three in Celtic traditions',
    ],
    magicalUses: [
      'Seal workings in three stages',
      'Amulet of protection and continuity',
    ],
    cautions:
        'A symbol shared by several living traditions: context matters.',
    related: ['Triple Moon', 'The Weaver (Archetypes)'],
  ),
  ArcaneEntry(
    name: 'Eye of Horus',
    emoji: '𓂀',
    summary: 'The eye that restores all: protection and wholeness',
    origin: 'Ancient Egypt (myth of Horus and Set)',
    history:
        'In the myth, Set tears out the eye of Horus, later restored by Thoth — which is why the udjat ("that which is complete") became an amulet of healing and protection omnipresent in Egypt, from the living to the sarcophagi.',
    characteristics: [
      'A funerary and everyday amulet of immense popularity',
      'Its parts were used as fractions in Egypt',
    ],
    symbolism: [
      'Restoration: what was wounded can be made whole',
      'Benevolent watchfulness: to see and to protect',
    ],
    correspondences: ['Lapis lazuli', 'Blue and gold', 'Protection'],
    studyPractices: [
      'Study the myth of Horus, Set and Osiris',
      'Reflect: "what in me asks for restoration?"',
    ],
    magicalUses: [
      'Amulet against envy and harmful gazes',
      'Rituals of healing and reintegration',
    ],
    cautions:
        'Not to be confused with the Masonic "all-seeing eye" — distinct histories.',
    related: ['Ankh', 'Protection & Cleansing (Grimoire)'],
  ),
  ArcaneEntry(
    name: 'Wheel of the Year',
    emoji: '☸️',
    summary: 'The eight spokes of the sacred cycle of the seasons',
    origin: '20th-century neopaganism, built on Celtic and Germanic festivals',
    history:
        'The modern Wheel of the Year joins four Celtic fire festivals (Samhain, Imbolc, Beltane, Lughnasadh) with the solstices and equinoxes, forming eight sabbats. The symbol — an eight-spoked wheel — expresses nature\'s circular time.',
    characteristics: [
      'Eight equidistant festivals (~6.5 weeks apart)',
      'Cyclical time, not linear',
    ],
    symbolism: [
      'Each spoke: a quality of the light and of the harvest',
      'The center: the unmoving axis of the one who observes',
    ],
    correspondences: ['Sabbats', 'Wheat, candles and seasonal flowers'],
    studyPractices: [
      'Follow the sabbats in the app\'s Wheel of the Year section',
      'Create small personal seasonal celebrations',
    ],
    magicalUses: [
      'Plan intentions according to the season',
      'A seasonal altar renewed at each sabbat',
    ],
    cautions:
        'Adapt the dates to the southern hemisphere when it makes sense for your practice.',
    related: ['Wheel of the Year (app)', 'Sabbats (Encyclopedia)'],
  ),
  ArcaneEntry(
    name: 'Spiral',
    emoji: '🌀',
    summary: 'The path that returns changed: the oldest symbol',
    origin: 'Universal Neolithic art (Newgrange, ~3200 BCE)',
    history:
        'Carved into megalithic tombs such as Newgrange millennia before the pyramids, the spiral is perhaps humanity\'s oldest sacred symbol — present in shells, galaxies and in the very growth of plants.',
    characteristics: [
      'Single (one line), double or triple (triskelion)',
      'Clockwise/counterclockwise with distinct readings',
    ],
    symbolism: [
      'Evolution: returning to the same point, deeper',
      'Birth-death-rebirth',
      'The journey inward and outward',
    ],
    correspondences: ['Shells', 'Circle dances', 'Labyrinths'],
    studyPractices: [
      'Walk labyrinths or draw meditative spirals',
      'Map the "turns of the spiral" in your own story',
    ],
    magicalUses: [
      'Trace spirals to open (deosil) or close (widdershins) rituals',
      'A symbol of growth in sigils',
    ],
    cautions:
        'Directions vary between traditions and hemispheres — follow your own coherence.',
    related: ['Sigils', 'Recurring Dreams (Dream Themes)'],
  ),
  ArcaneEntry(
    name: 'Witch\'s Knot',
    emoji: '➰',
    summary: 'Four interlaced loops: woven protection',
    origin: 'European folk tradition (knot magic)',
    history:
        'The witch\'s knot — four loops interlaced in a continuous stroke — was scratched onto doors and hearths to protect against hostile magic. Heir to ancient knot magic, in which tying and untying held and released intentions.',
    characteristics: [
      'Continuous stroke, with no beginning and no end',
      'Four loops: the four winds/directions',
    ],
    symbolism: [
      'The knot: intention made fast',
      'The interlacing: forces that sustain one another',
    ],
    correspondences: ['Cords', 'Doors and thresholds', 'Four directions'],
    studyPractices: [
      'Learn the single-line tracing',
      'Study knot magic across different cultures',
    ],
    magicalUses: [
      'Protection of the home\'s entrances',
      'Cord magic: tying intentions into knots',
    ],
    cautions:
        'When untying ritual knots, do so with the same awareness with which you tied them.',
    related: ['The Weaver (Archetypes)', 'Protection & Cleansing (Grimoire)'],
  ),
  ArcaneEntry(
    name: 'Hecate\'s Strophalos',
    emoji: '🛞',
    summary: 'Hecate\'s wheel: the labyrinth of the lady of the crossroads',
    origin: 'Ancient Greece; Chaldean Oracles',
    history:
        'The strophalos — a wheel with a serpentine labyrinth around a center — is linked to Hecate, lady of the crossroads and of magic. The Chaldean Oracles mention the spinning "iynx" as a theurgic instrument of invocation.',
    characteristics: [
      'Three turns of the labyrinth: the three realms (sky, earth, sea)',
      'A symbol of Hecate\'s sovereignty over passages',
    ],
    symbolism: [
      'The center: the flame of the soul',
      'The labyrinth: the initiatory path',
      'The crossroads: the moment of choice',
    ],
    correspondences: ['Hecate', 'Keys and torches', 'Dark moon', 'Garlic and pomegranate'],
    studyPractices: [
      'Study Hecate in the ancient sources vs. modern rereadings',
      'Meditate on the current "crossroads" of your life',
    ],
    magicalUses: [
      'Devotional to Hecate on dark moons',
      'Decision rituals at symbolic crossroads',
    ],
    cautions:
        'A specific devotional symbol: approach it with study and respect.',
    related: ['Hecate (Goddesses)', 'The Shadow Queen (Archetypes)'],
  ),
  ArcaneEntry(
    name: 'Vegvísir',
    emoji: '🧭',
    summary: 'The Icelandic "wayfinder"',
    origin: 'Icelandic magical manuscripts (19th c., Huld Manuscript)',
    history:
        'Recorded in the Huld Manuscript (1860), the vegvísir promised that "whoever carries it will not lose their way in storms". It is not a Viking-age symbol, but a late heir of the galdrastafir — Icelandic magical staves.',
    characteristics: [
      'Eight staves with distinct endings',
      'Of the galdrastafir family (Icelandic sigils)',
    ],
    symbolism: [
      'The eight directions: total orientation',
      'The storm: the confusing phases of life',
    ],
    correspondences: ['Journeys', 'Storm blue', 'Runes (kinship)'],
    studyPractices: [
      'Distinguish Viking-age symbols from the late manuscripts',
      'Study the galdrastafir and their sigil logic',
    ],
    magicalUses: [
      'Talisman of orientation in phases of uncertainty',
      'Travel blessings',
    ],
    cautions:
        'Avoid calling it a "Viking symbol": historical honesty strengthens the practice.',
    related: ['Runes (Encyclopedia)', 'Sigils'],
  ),
  ArcaneEntry(
    name: 'Ouroboros',
    emoji: '🐍',
    summary: 'The serpent biting its own tail: the eternal return',
    origin: 'Ancient Egypt; Greco-Egyptian alchemy',
    history:
        'From Tutankhamun\'s tomb to the alchemical treatise of Cleopatra (with the legend "hen to pan" — the One is the All), the ouroboros represents the self-feeding cycle. Jung took it as a central symbol of individuation.',
    characteristics: [
      'A perfect circle formed by a living being',
      'Sometimes half light, half dark (union of opposites)',
    ],
    symbolism: [
      'Eternal return and self-sufficiency',
      'Death that feeds life',
      'The cyclical time of the cosmos',
    ],
    correspondences: ['Alchemy', 'Silver and black', 'Long cycles'],
    studyPractices: [
      'Identify cycles that repeat until they are understood',
      'Study the alchemical and Jungian ouroboros',
    ],
    magicalUses: [
      'Seal rituals of ending-and-beginning-again',
      'A symbol of renewal in sigils',
    ],
    cautions:
        'A cycle repeated without awareness is a hamster wheel: the ouroboros asks for presence.',
    related: ['The Alchemist (Archetypes)', 'Spiral'],
  ),
];
