import '../models/arcane_entry_model.dart';

/// Archetypes of the magical path — English content.
///
/// Emojis and non-textual correspondences are invariant across languages.
/// Keep the same order as `archetypes_data_pt.dart` — parity is verified by
/// `test/content_parity_test.dart`.
const List<ArcaneEntry> archetypesEn = [
  ArcaneEntry(
    name: 'The Witch',
    emoji: '🧙‍♀️',
    summary: 'Sovereignty over one\'s own power and forbidden knowledge',
    origin: 'Universal — from European folklore to the folk healers of the Americas',
    history:
        'From village healer to the persecuted of the pyres, the Witch has crossed centuries as a symbol of feminine power beyond institutional control. In the twentieth century she was reclaimed by modern witchcraft movements as an emblem of spiritual autonomy',
    characteristics: [
      'Self-sufficiency and intimacy with nature',
      'Knowledge of herbs, cycles and mysteries',
      'The courage to live outside others\' expectations',
      'A direct relationship with the sacred, without intermediaries',
    ],
    symbolism: [
      'The cauldron: inner transformation',
      'The broom: crossing between worlds',
      'The moon: cycles and the hidden',
    ],
    correspondences: ['Moon', 'Mugwort', 'Obsidian', 'Black and violet'],
    studyPractices: [
      'Journaling: "where do I give up my power in order to be accepted?"',
      'Study the history of the persecutions and of local folk healers',
    ],
    magicalUses: [
      'Invoke self-confidence in rituals of personal sovereignty',
      'Mirror meditation to integrate rejected parts',
    ],
    cautions:
        'Archetypes are symbolic mirrors, not fixed identities — use them as a tool for reflection',
    related: ['The Wise Woman', 'The Healer', 'Hecate (Goddesses)'],
  ),
  ArcaneEntry(
    name: 'The Healer',
    emoji: '🌿',
    summary: 'The gift of caring, restoring and returning balance',
    origin: 'Universal — shamans, folk healers, midwives and herbalists',
    history:
        'Present in every culture, the Healer keeps the practical knowledge of healing: plants, touch, words and prayers. Folk healers and midwives kept this lineage alive even under persecution, passing the craft from mother to daughter',
    characteristics: [
      'Deep empathy and a presence that soothes',
      'Knowledge of natural remedies and cleansing rituals',
      'Listening to the body and to subtle signs',
    ],
    symbolism: [
      'The hands: a channel of energy and care',
      'The serpent: renewal and medicine',
      'Water: cleansing and emotional flow',
    ],
    correspondences: ['Rosemary', 'Green quartz', 'Green and white', 'Mercury'],
    studyPractices: [
      'Study one herb per week (see the Herb Encyclopedia)',
      'Practice ritualized self-care before caring for others',
    ],
    magicalUses: [
      'Ritual cleansing baths and teas',
      'Distance healing rituals and blessings',
    ],
    cautions:
        'Caring for others does not replace caring for yourself; the shadow Healer burns out in the name of others. Energy practices do not replace medicine',
    related: ['Herbs (Encyclopedia)', 'The Mother', 'Brigid (Goddesses)'],
  ),
  ArcaneEntry(
    name: 'The Seer',
    emoji: '👁️',
    summary: 'Seeing beyond the veil: intuition, oracles and prophecy',
    origin: 'The Oracle of Delphi, Roman sibyls, seers of folklore',
    history:
        'From the Greek pythias to the fortune-tellers of the fair, the Seer embodies the human capacity to read signs and to sense what is coming. Always revered and feared, her gift defies the linear logic of time',
    characteristics: [
      'Sharpened intuition and meaningful dreams',
      'Comfort with symbols, omens and ambiguity',
      'Sensitivity to the energies of people and places',
    ],
    symbolism: [
      'The third eye: subtle perception',
      'The mist: the veil between worlds',
      'The mirror and the crystal ball: surfaces of vision',
    ],
    correspondences: ['Amethyst', 'Mugwort', 'Indigo', 'Moon and Neptune'],
    studyPractices: [
      'Record dreams and synchronicities in the Journal',
      'Practice with one oracle at a time until a bond forms',
    ],
    magicalUses: [
      'Tarot, rune and pendulum readings',
      'Meditations to open the intuition',
    ],
    cautions:
        'Intuition is trained with discernment: not every hunch is prophecy. Avoid making important decisions based on signs alone',
    related: ['Oracle Cards', 'Runes', 'Pendulum', 'Dreams & Visions'],
  ),
  ArcaneEntry(
    name: 'The Guardian',
    emoji: '🛡️',
    summary: 'Protection of thresholds, people and sacred spaces',
    origin: 'Guardians of temples, homes and crossroads in every culture',
    history:
        'From the stone lions at the gates to witchcraft\'s circles of salt, the Guardian watches over boundaries: what comes in, what goes out, what shall not pass. She is the force that says "this far and no further" with love and firmness',
    characteristics: [
      'A keen sense of boundaries and justice',
      'Loyalty and protection of her own',
      'Serene courage in the face of threats',
    ],
    symbolism: [
      'The shield and the circle: sacred boundary',
      'The key: authority over passages',
      'Salt: purity that bars the unwanted',
    ],
    correspondences: ['Coarse salt', 'Rue', 'Black tourmaline', 'Mars'],
    studyPractices: [
      'Reflect: "which of my boundaries need reinforcing?"',
      'Study protective amulets from different cultures',
    ],
    magicalUses: [
      'Home protection rituals and energetic shields',
      'Consecration of amulets and talismans',
    ],
    cautions:
        'Too much protection becomes a wall: check whether your boundaries guard or isolate',
    related: ['Protection & Cleansing (Grimoire)', 'Sacred Symbols'],
  ),
  ArcaneEntry(
    name: 'The Wise Woman',
    emoji: '🦉',
    summary: 'The elder within: experience transformed into wisdom',
    origin: 'The crone of the tales, grandmothers and teachers of every tradition',
    history:
        'Third face of the Triple Goddess, the Crone keeps the wisdom of completed cycles. In ancestral cultures, the eldest women were counselors of the community; in the tales, she is the old woman of the forest who tests and bestows gifts',
    characteristics: [
      'Detachment from appearances and from others\' judgment',
      'Long-term vision and a sharp sense of humor',
      'The ability to release what has already fulfilled its role',
    ],
    symbolism: [
      'The owl: seeing in the dark',
      'The waning moon: fertile withdrawal',
      'The thread and the scissors: knowing when to cut',
    ],
    correspondences: ['Waning moon', 'Sage', 'Onyx', 'Gray and black'],
    studyPractices: [
      'Write letters from your "elder self" to your "present self"',
      'Honor the older women of your lineage',
    ],
    magicalUses: [
      'Cycle-closing rituals during the waning moon',
      'Inner counsel in deep meditations',
    ],
    cautions:
        'The shadow of the Wise Woman is cynicism: wisdom without tenderness hardens',
    related: ['The Witch', 'Hecate (Goddesses)', 'Moon Phases'],
  ),
  ArcaneEntry(
    name: 'The Maiden',
    emoji: '🌸',
    summary: 'Beginnings, freshness and the courage of the first step',
    origin: 'First face of the Triple Goddess; Persephone before the abduction',
    history:
        'The Maiden is the springtime of the cycle: curiosity, potential and youthful independence. In the myths, she is often the one who departs, explores and inaugurates — the energy of all that is yet to bloom',
    characteristics: [
      'Enthusiasm, openness and faith in the possible',
      'Independence and the desire to explore',
      'Purity of intention — beginning without scars',
    ],
    symbolism: [
      'The waxing moon: a promise taking shape',
      'Flowers and seeds: potential',
      'The dawn: a daily new beginning',
    ],
    correspondences: ['Waxing moon', 'Jasmine', 'Rose quartz', 'White and pink'],
    studyPractices: [
      'List "shelved" dreams that deserve a first attempt',
      'Practice beginner\'s mind: learn something from scratch without self-judgment',
    ],
    magicalUses: [
      'Rituals of new beginnings during the waxing moon',
      'Spells for inspiration and creative freshness',
    ],
    cautions:
        'The shadow of the Maiden is the eternal promise that never matures: beginning also asks for continuing',
    related: ['The Mother', 'The Wise Woman', 'Waxing Moon'],
  ),
  ArcaneEntry(
    name: 'The Mother',
    emoji: '🤱',
    summary: 'Nurturing, creation and the force that makes things grow',
    origin: 'Neolithic mother goddesses, Demeter, Yemanjá, the Triple Goddess',
    history:
        'Central face of the Triple Goddess, the Mother is the fullness of the full moon: gestating, birthing and sustaining — children, projects, communities. The mother goddesses are among the oldest figures of the human sacred',
    characteristics: [
      'Generosity, abundance and presence',
      'Fertility in the broadest sense: making things grow',
      'Protective fury when her own are threatened',
    ],
    symbolism: [
      'The full moon: fullness',
      'The womb and the chalice: gestation',
      'The harvest: fruit of constant care',
    ],
    correspondences: ['Full moon', 'Chamomile', 'Moonstone', 'Gold and green'],
    studyPractices: [
      'Ask yourself: "what am I nurturing — and what nurtures me?"',
      'Gratitude practices for your maternal lineage (see Journal)',
    ],
    magicalUses: [
      'Abundance and fruition rituals at the full moon',
      'Blessings for growing projects',
    ],
    cautions:
        'The shadow of the Mother is control disguised as care and the forgetting of oneself',
    related: ['The Maiden', 'The Healer', 'Full Moon'],
  ),
  ArcaneEntry(
    name: 'The Huntress',
    emoji: '🏹',
    summary: 'Focus, independence and the arrow that does not stray',
    origin: 'Artemis/Diana and the ladies of the hunt of European folklore',
    history:
        'Lady of the woods and protector of wild animals, the Huntress runs free beyond the city walls. Diana became, in the tradition of Italian witchcraft and in Wicca, one of the central faces of the Goddess',
    characteristics: [
      'Absolute focus on the chosen target',
      'Self-sufficiency and love of freedom',
      'Honed instinct and readiness',
    ],
    symbolism: [
      'The bow and arrow: directed intention',
      'The forest: the wild territory within',
      'The pack: loyalty without domestication',
    ],
    correspondences: ['Waxing moon', 'Cypress', 'Silver', 'Sagittarius'],
    studyPractices: [
      'Set a single target per lunar cycle and pursue it',
      'Contemplative walks in nature',
    ],
    magicalUses: [
      'Spells for focus and achieving goals',
      'Rituals of reconnection with wild nature',
    ],
    cautions:
        'The shadow of the Huntress is proud solitude: asking for help is also good aim',
    related: ['The Guardian', 'Diana (Goddesses)', 'Prosperity & Paths'],
  ),
  ArcaneEntry(
    name: 'The Weaver',
    emoji: '🕸️',
    summary: 'Destiny, patience and the art of interlacing the threads of life',
    origin: 'The Greek Moirai, the Norse Norns, Grandmother Spider of Indigenous peoples',
    history:
        'In many myths, destiny is woven: the Moirai spin, measure and cut; the Norns water the world tree. The Weaver reminds us that every choice is a thread — and that patterns can be rewoven',
    characteristics: [
      'A vision of patterns and invisible connections',
      'The patience of one who builds stitch by stitch',
      'Responsibility for one\'s own choices',
    ],
    symbolism: [
      'The web: the interdependence of all things',
      'The spindle: turning time',
      'The knot: intention made fast',
    ],
    correspondences: ['Threads and knots', 'Lavender', 'Labradorite', 'Saturn'],
    studyPractices: [
      'Map patterns that repeat throughout your story',
      'Meditative crafts: knitting, macramé, embroidery',
    ],
    magicalUses: [
      'Knot magic (binding intentions into cords)',
      'Pattern-rewriting rituals during the waning moon',
    ],
    cautions:
        'Not every thread is yours to weave: respect the free will of others',
    related: ['Sigils', 'Dreams & Visions', 'The Wise Woman'],
  ),
  ArcaneEntry(
    name: 'The Alchemist',
    emoji: '⚗️',
    summary: 'Transmutation: turning inner lead into gold',
    origin: 'Greco-Egyptian, Arabic and medieval European alchemy',
    history:
        'More than precursors of chemistry, the alchemists sought the transformation of the soul itself — the solve et coagula: dissolving what has hardened and recomposing it in nobler form. Jung reread alchemy as a map of individuation',
    characteristics: [
      'Fascination with processes of transformation',
      'Experimental discipline: test, observe, refine',
      'Faith that nothing is lost, everything is transmuted',
    ],
    symbolism: [
      'The ouroboros: cycles that renew themselves',
      'The furnace (athanor): pressure that refines',
      'Gold: the essence fulfilled',
    ],
    correspondences: ['Symbolic sulfur and salt', 'Cinnamon', 'Pyrite', 'Sun'],
    studyPractices: [
      'Study the alchemical stages (nigredo, albedo, rubedo) as personal phases',
      'Transform one habit at a time, documenting the process',
    ],
    magicalUses: [
      'Rituals to transmute pain into learning',
      'Working with the cauldron as a symbolic athanor',
    ],
    cautions:
        'Real transformation is slow: beware of instant gold',
    related: ['The Witch', 'Metals (Encyclopedia)', 'Energy & Healing'],
  ),
  ArcaneEntry(
    name: 'The Shadow Queen',
    emoji: '🌑',
    summary: 'Sovereignty over one\'s own shadow and the deep territories',
    origin: 'Persephone in the underworld, the Norse Hel, the stepmother of the tales',
    history:
        'Every psyche has its cellars. The Shadow Queen rules over what was exiled: anger, envy, desire, grief. In the myths, descending to the underworld — like Inanna or Persephone — is the path to reigning whole',
    characteristics: [
      'Radical honesty with oneself',
      'The capacity to hold difficult emotions without fleeing',
      'Personal power that does not apologize',
    ],
    symbolism: [
      'The throne in the dark: dignity in the depths',
      'The pomegranate: the pact with one\'s own underworld',
      'The new moon: the fertile invisible',
    ],
    correspondences: ['New moon', 'Myrrh', 'Obsidian', 'Dark wine and black'],
    studyPractices: [
      'Shadow work: dialogue in writing with what you reject in yourself',
      'Read the descent myths (Inanna, Persephone) as inner scripts',
    ],
    magicalUses: [
      'Shadow-integration rituals at the new moon',
      'Conscious banishings of what has already been understood',
    ],
    cautions:
        'Shadow work stirs sensitive material: go at your own pace and seek professional support when the pain runs deep',
    related: ['The Wise Woman', 'Hecate (Goddesses)', 'New Moon'],
  ),
];
