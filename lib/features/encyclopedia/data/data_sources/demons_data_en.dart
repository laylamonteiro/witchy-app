import '../models/arcane_entry_model.dart';

/// Encyclopedia demons — English content.
///
/// Informative, historical approach: goetia, folklore, literary demonology
/// and modern re-readings, with no encouragement of harmful practices.
/// Emojis are invariant; keep the same order across the three files
/// (`demons_data_pt/en/es.dart`) — parity is checked in
/// `test/content_parity_test.dart`.
const List<ArcaneEntry> demonsEn = [
  ArcaneEntry(
    name: 'Lilith',
    emoji: '🌒',
    summary: 'From demonization to reclamation: the first who said no',
    origin: 'Mesopotamian wind demons; medieval Jewish folklore',
    history:
        'Lilith grows out of the Mesopotamian lilitu and gains a biography in the Alphabet of Ben Sira: Adam\'s first wife, who refused submission and left. Feared for centuries and warded off with protective amulets, she was reclaimed in the twentieth century as an icon of feminine autonomy',
    perspectives: [
      ArcanePerspective(
        tradition: 'Folk',
        view:
            'A night spirit against whom amulets were used, especially for newborns',
      ),
      ArcanePerspective(
        tradition: 'Kabbalistic',
        view: 'Consort of the shadow side in the medieval mystical currents',
      ),
      ArcanePerspective(
        tradition: 'Modern/Feminist',
        view:
            'A symbol of refusing submission and of sovereignty — present in astrology (the Black Moon) and in contemporary witchcraft',
      ),
    ],
    characteristics: ['Radical independence', 'Night', 'Sovereign sexuality', 'Refusal'],
    symbolism: [
      'The owl: night vision',
      'The black moon: the untamed feminine',
      'The desert: the territory outside the rules',
    ],
    correspondences: ['Black Moon (astrology)', 'Obsidian', 'Black and wine red'],
    studyPractices: [
      'Compare the Alphabet of Ben Sira with the feminist re-readings',
      'Reflect: "where do I say yes when I mean no?"',
    ],
    magicalUses: [
      'Shadow work on autonomy and boundaries',
      'Study of the Black Moon in the birth chart',
    ],
    cautions:
        'Historical, informative content. No practice here involves or encourages harm to anyone',
    related: ['The Shadow Queen (Archetypes)', 'New Moon'],
  ),
  ArcaneEntry(
    name: 'Asmodeus',
    emoji: '💍',
    summary: 'The demon of the Book of Tobit and king of pleasures in the goetia',
    origin: 'Persian Aeshma-daeva; Book of Tobit; medieval goetia',
    history:
        'Heir of the Persian "demon of wrath", Asmodeus torments Sarah\'s marriage in the Book of Tobit until he is driven away with Raphael\'s help. In the Goetia (Lemegeton) he figures as a king who teaches mathematics and handicrafts — an example of the medieval blend of dread and scholarly fascination',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religious',
        view: 'The destroyer of marriages defeated with angelic help',
      ),
      ArcanePerspective(
        tradition: 'Goetic',
        view:
            'One of Solomon\'s 72 spirits: a king who teaches arithmetic, astronomy and crafts',
      ),
      ArcanePerspective(
        tradition: 'Folk',
        view: 'In the Solomon legends, the genie who (grudgingly) helped build the Temple',
      ),
    ],
    characteristics: ['Desire', 'Jealousy', 'Ingenuity', 'Excess'],
    symbolism: [
      'Solomon\'s ring: the knowledge that orders the passions',
      'The fish smoke: the unexpected remedy',
    ],
    correspondences: ['Goetia (study)', 'Garnet', 'Dark red'],
    studyPractices: [
      'Read the Book of Tobit and compare it with the Lemegeton',
      'Reflect on jealousy and desire as messengers, not masters',
    ],
    magicalUses: [
      'Historical study of the Solomonic grimoires',
      'Shadow work on possessiveness',
    ],
    cautions:
        'The goetia is presented here as an object of historical study. No harmful practice is taught or encouraged',
    related: ['Raphael (Angels)', 'Raziel (Angels)'],
  ),
  ArcaneEntry(
    name: 'Beelzebub',
    emoji: '🪰',
    summary: 'The "Lord of the Flies": from Philistine god to prince of demons',
    origin: 'Baal-Zebub of Ekron (2 Kings); the gospels; medieval demonology',
    history:
        'Baal-Zebub was a Philistine god consulted as an oracle. Jewish tradition turned the name into mockery ("lord of the flies") and the gospels cite him as prince of demons — a classic case of a foreign deity demonized',
    perspectives: [
      ArcanePerspective(
        tradition: 'Historical',
        view:
            'A textbook example of how the gods of rival peoples were turned into demons',
      ),
      ArcanePerspective(
        tradition: 'Religious',
        view: 'In the gospels, the prince of demons by whose power Jesus was accused of acting',
      ),
      ArcanePerspective(
        tradition: 'Literary',
        view:
            'From Milton to the novel "Lord of the Flies", a symbol of decay and social chaos',
      ),
    ],
    characteristics: ['Decay', 'Noise', 'Corrupted power'],
    symbolism: [
      'The fly: what gathers where something rots',
      'The fallen throne: authority in decline',
    ],
    correspondences: ['Historical study', 'Grey and black'],
    studyPractices: [
      'Research the historical process by which deities were demonized',
      'Reflect: "what judgments have I inherited without examining them?"',
    ],
    magicalUses: [
      'No ritual use proposed — a historical study entry',
    ],
    cautions:
        'Historical, informative content. No harmful practice is taught or encouraged',
    related: ['Lucifer', 'Sacred Symbols'],
  ),
  ArcaneEntry(
    name: 'Mephistopheles',
    emoji: '🎭',
    summary: 'The demon of the pact: the literary creation that defined a genre',
    origin: 'German legend of Faust (16th century); Marlowe and Goethe',
    history:
        'Mephistopheles comes from no religious tradition: he is born in the Faust legend and grows in the hands of Marlowe and Goethe. He is the spirit "that always denies" — ironic, cultured, contractual — and shaped the image of the demonic pact forever',
    perspectives: [
      ArcanePerspective(
        tradition: 'Literary',
        view:
            'In Goethe, "part of that force which always wills evil and always creates the good" — the adversary who sets us in motion',
      ),
      ArcanePerspective(
        tradition: 'Philosophical',
        view:
            'The spirit of negation and irony: the doubt that corrodes or that awakens',
      ),
    ],
    characteristics: ['Irony', 'Contract', 'Intellectual seduction', 'Negation'],
    symbolism: [
      'The signed pact: choices with a price',
      'The black dog: the shape of his first appearance',
      'The theatre: mask and play',
    ],
    correspondences: ['Faustian literature', 'Red and black'],
    studyPractices: [
      'Read Goethe\'s Faust (at least the pact scene)',
      'Reflect: "which shortcuts would cost me too much?"',
    ],
    magicalUses: [
      'No ritual use proposed — a literary figure for reflecting on choices',
    ],
    cautions:
        'Historical-literary content. No pact practice is real or encouraged',
    related: ['The Alchemist (Archetypes)', 'Lucifer'],
  ),
  ArcaneEntry(
    name: 'Pazuzu',
    emoji: '🌪️',
    summary: 'The Assyrian wind demon who protected against demons',
    origin: 'Mesopotamia (8th-7th centuries BCE)',
    history:
        'King of the wind demons in Assyria, Pazuzu brought storms and plagues — and, paradoxically, his amulets were used to drive away the dreaded Lamashtu, protecting pregnant women and babies. The evil that guards against evil',
    perspectives: [
      ArcanePerspective(
        tradition: 'Mesopotamian',
        view:
            'An ambivalent entity: dangerous by nature, protective by apotropaic function',
      ),
      ArcanePerspective(
        tradition: 'Pop culture',
        view:
            'Made famous (and distorted) by the film The Exorcist, becoming a byword for possession',
      ),
    ],
    characteristics: ['Ambivalence', 'Wind and fever', 'Paradoxical protection'],
    symbolism: [
      'The amulet head: terror tamed into a guardian',
      'The southwest wind: the force you do not control, you negotiate with',
    ],
    correspondences: ['Historical amulets', 'Bronze'],
    studyPractices: [
      'Study apotropaic amulets (evil against evil) across cultures',
      'Reflect on "feared" forces of yours that actually protect you',
    ],
    magicalUses: [
      'Study of the apotropaic principle in amulets',
    ],
    cautions:
        'Historical, informative content. No harmful practice is taught or encouraged',
    related: ['The Guardian (Archetypes)', 'Cherubim (Angels)'],
  ),
  ArcaneEntry(
    name: 'Baphomet',
    emoji: '🐐',
    summary: 'From the Templar trial to the occult symbol of balance',
    origin: 'Accusations against the Templars (1307); Eliphas Lévi\'s drawing (1856)',
    history:
        'The name appears in the forced confessions of the Templars — probably a corruption of "Mahomet". Centuries later, Eliphas Lévi drew the Goat of Mendes: an androgynous figure full of reconciled opposites ("solve" and "coagula" on its arms), which has nothing to do with any real medieval cult',
    perspectives: [
      ArcanePerspective(
        tradition: 'Historical',
        view:
            'A procedural phantom: the "idolatry" the inquisitors needed to find',
      ),
      ArcanePerspective(
        tradition: 'Occultist',
        view:
            'In Lévi, a symbol of the balance of opposites — matter and spirit, masculine and feminine, above and below',
      ),
      ArcanePerspective(
        tradition: 'Contemporary',
        view:
            'Adopted by secular satanist currents as an emblem of anti-dogmatism, widening the distance from the origin even further',
      ),
    ],
    characteristics: ['Synthesis of opposites', 'Historical misunderstanding', 'Provocation'],
    symbolism: [
      'The torch between the horns: intelligence above matter',
      'Solve et coagula: dissolve and recompose',
      'The androgyne: wholeness',
    ],
    correspondences: ['Symbolic alchemy', 'Black and silver'],
    studyPractices: [
      'Compare the records of the Templar trial with Lévi\'s drawing',
      'Meditate on pairs of opposites you need to reconcile',
    ],
    magicalUses: [
      'Alchemical contemplation of inner opposites',
    ],
    cautions:
        'Historical, informative content. A frequently misunderstood symbol; study the sources',
    related: ['The Alchemist (Archetypes)', 'Sacred Symbols'],
  ),
  ArcaneEntry(
    name: 'Belial',
    emoji: '⛓️',
    summary: '"Worthless": the personification of lawlessness in the ancient texts',
    origin: 'Biblical Hebrew; Dead Sea Scrolls; goetia',
    history:
        'In the Hebrew Bible, "sons of Belial" names lawless people. In the Dead Sea Scrolls, Belial leads the Sons of Darkness against the Sons of Light. In the Goetia he is a powerful king who demands offerings — a portrait of power without principle',
    perspectives: [
      ArcanePerspective(
        tradition: 'Biblical',
        view: 'Not a being but a qualifier: the absence of worth and law',
      ),
      ArcanePerspective(
        tradition: 'Qumran',
        view: 'The prince of darkness in the great eschatological battle',
      ),
      ArcanePerspective(
        tradition: 'Goetic',
        view: 'A king who hands out favors and titles — the archetype of corrupt power',
      ),
    ],
    characteristics: ['Lawlessness', 'Power without ethics', 'The lure of the shortcut'],
    symbolism: [
      'The broken chains: freedom without responsibility',
      'The empty throne: authority without legitimacy',
    ],
    correspondences: ['Study of the Dead Sea Scrolls'],
    studyPractices: [
      'Reflect on power and ethics: "what power do I want — and at what cost?"',
    ],
    magicalUses: [
      'No ritual use proposed — a historical study entry',
    ],
    cautions:
        'Historical, informative content. No harmful practice is taught or encouraged',
    related: ['Lucifer', 'Mephistopheles'],
  ),
  ArcaneEntry(
    name: 'Mammon',
    emoji: '💰',
    summary: 'Wealth personified: when money becomes a master',
    origin: 'Aramaic mamona ("wealth"); the gospels; Milton',
    history:
        '"You cannot serve both God and Mammon": the Aramaic word for wealth was personified by Christian tradition and, in Milton, became the demon who even in heaven only looked at the golden floor — avarice as a lowering of the gaze',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religious',
        view: 'The idolatry of wealth as a direct rival of the sacred',
      ),
      ArcanePerspective(
        tradition: 'Literary',
        view:
            'In Milton, the builder of Pandemonium: talent in the service of accumulation',
      ),
    ],
    characteristics: ['Avarice', 'Hoarding', 'A lowered gaze'],
    symbolism: [
      'The gold on the ground: the value that makes you bow',
      'The dishonest scale: soulless exchange',
    ],
    correspondences: ['Reflections on prosperity', 'Gold and grey'],
    studyPractices: [
      'Examine your relationship with money: tool or master?',
      'Contrast it with healthy prosperity practices (see the Grimoire)',
    ],
    magicalUses: [
      'No ritual use proposed — a mirror for your relationship with abundance',
    ],
    cautions:
        'Historical, informative content. Healthy prosperity differs from avarice',
    related: ['Prosperity & Paths (Grimoire)', 'Belial'],
  ),
  ArcaneEntry(
    name: 'Leviathan',
    emoji: '🐉',
    summary: 'The monster of primordial chaos that dwells in the depths',
    origin: 'Canaanite myths (Lotan); Job, Psalms and Isaiah',
    history:
        'Heir of the Canaanite Lotan, Leviathan is the sea serpent of chaos that only the divine can master. In Job it is described with awe; Hobbes took it as a metaphor for the State; modern psychology reads it as unconscious chaos',
    perspectives: [
      ArcanePerspective(
        tradition: 'Biblical',
        view: 'The watery chaos subdued at creation — a force only the sacred can contain',
      ),
      ArcanePerspective(
        tradition: 'Philosophical',
        view: 'In Hobbes, the sovereign power that prevents the war of all against all',
      ),
      ArcanePerspective(
        tradition: 'Symbolic-psychological',
        view: 'The depths of the unconscious: what surfaces when the inner sea is stirred',
      ),
    ],
    characteristics: ['Primordial chaos', 'Immensity', 'The untamable'],
    symbolism: [
      'The deep sea: the collective unconscious',
      'The coiled serpent: contained energy',
      'The storm: emotions that overflow',
    ],
    correspondences: ['Water', 'Abyssal blue', 'Dreams of the sea'],
    studyPractices: [
      'Read Job 41 as a poem of awe before the uncontrollable',
      'Record dreams of the sea/water in the Dream Journal',
    ],
    magicalUses: [
      'Meditations for navigating your own depths',
    ],
    cautions:
        'Historical, informative content. No harmful practice is taught or encouraged',
    related: ['Water (Dream Themes)', 'The Shadow Queen (Archetypes)'],
  ),
  ArcaneEntry(
    name: 'Astaroth',
    emoji: '👑',
    summary: 'The grand duke of the Goetia, a demonized echo of the goddess Astarte',
    origin: 'Goetia (Lemegeton); derived from Astarte/Ishtar',
    history:
        'In the grimoires, Astaroth is a grand duke who teaches the sciences and reveals secrets of the past and the future. The name descends from Astarte, great goddess of the Near East — a classic case of an ancient deity demonized by later tradition',
    perspectives: [
      ArcanePerspective(
        tradition: 'Goetic',
        view: 'A duke who teaches the liberal arts and answers about hidden things',
      ),
      ArcanePerspective(
        tradition: 'Historical',
        view: 'The memory of Astarte/Ishtar turned into a demon: the demotion of the goddesses',
      ),
      ArcanePerspective(
        tradition: 'Modern occultist',
        view: 'A symbol of forbidden knowledge and of reclaiming the erased divine feminine',
      ),
    ],
    characteristics: ['Hidden knowledge', 'Ancestral memory', 'Eloquence', 'The past revealed'],
    symbolism: [
      'The serpent in the hand: the knowledge that frightens',
      'The ducal crown: fallen nobility',
      'The eight-pointed star: Ishtar\'s inheritance',
    ],
    correspondences: ['Venus (Astarte\'s heritage)', 'Wednesday in the grimoires', 'Deep green'],
    studyPractices: [
      'Compare Astarte in the Ugaritic texts with the goetic Astaroth',
      'Reflect: what knowledge has already been called forbidden?',
    ],
    magicalUses: [
      'Symbolic study of the demonization of female deities',
      'Contemplation on reclaiming erased knowledge',
    ],
    cautions:
        'Historical, informative content about grimoires. No practice here involves or encourages harm',
    related: ['Goddesses', 'The Wise Woman (Archetypes)'],
  ),
  ArcaneEntry(
    name: 'Paimon',
    emoji: '🐪',
    summary: 'The obedient king of the Goetia, master of the arts and sciences',
    origin: 'Goetia (Lemegeton), one of the kings of the West',
    history:
        'Described as a king who arrives with great fanfare, riding a dromedary and preceded by musicians, Paimon teaches all arts, sciences and secrets. The grimoires list him among the spirits most obedient to the exorcist — and recent cinema has returned him to popular culture',
    perspectives: [
      ArcanePerspective(
        tradition: 'Goetic',
        view: 'A king who teaches philosophy, the arts and the secrets of the mind',
      ),
      ArcanePerspective(
        tradition: 'Historical',
        view: 'A possible echo of pre-Islamic desert spirits absorbed into the European grimoires',
      ),
      ArcanePerspective(
        tradition: 'Pop culture',
        view: 'Reintroduced by contemporary horror as a symbol of hidden influence',
      ),
    ],
    characteristics: ['Mastery', 'Knowledge of minds', 'Ceremony', 'Bond and loyalty'],
    symbolism: [
      'The dromedary: the patient crossing of the desert',
      'The music that precedes him: power that announces itself',
      'The crown of the West: dominion over dusk',
    ],
    correspondences: ['West', 'Ceremonial music', 'Night blue and gold'],
    studyPractices: [
      'Read Paimon\'s description in the Lemegeton in historical context',
      'Study how cinema reinterprets goetic figures',
    ],
    magicalUses: [
      'Symbolic study of mastery and deep learning',
      'Critical analysis of the grimoires as magical literature',
    ],
    cautions:
        'Historical, informative content about grimoires. No practice here involves or encourages harm',
    related: ['The Alchemist (Archetypes)', 'Sacred Symbols'],
  ),
  ArcaneEntry(
    name: 'Bael',
    emoji: '🐸',
    summary: 'The first king of the Goetia, lord of invisibility',
    origin: 'Goetia (Lemegeton); from the Semitic title Ba\'al ("lord")',
    history:
        'The first spirit listed in the Lemegeton, Bael appears with three heads — of a man, a cat and a toad — and grants the art of becoming invisible. His name comes from Ba\'al, title of the great Canaanite gods, another case of an ancient deity demoted to demon',
    perspectives: [
      ArcanePerspective(
        tradition: 'Goetic',
        view: 'King of the East who teaches invisibility and cunning',
      ),
      ArcanePerspective(
        tradition: 'Historical',
        view: 'Ba\'al Hadad, the Canaanite storm god, demonized by biblical polemic',
      ),
      ArcanePerspective(
        tradition: 'Symbolic',
        view: 'The three heads: the masks we wear to be seen — or not',
      ),
    ],
    characteristics: ['Invisibility', 'Cunning', 'Ancient kingship', 'Masks'],
    symbolism: [
      'The three heads: the faces of the self',
      'Invisibility: protection and concealment',
      'The throne of the East: the power of dawn',
    ],
    correspondences: ['East', 'Storm (Ba\'al\'s heritage)', 'Black and amber'],
    studyPractices: [
      'Compare Ba\'al in the Ugarit texts with the goetic Bael',
      'Reflect: when does being invisible protect — and when does it erase?',
    ],
    magicalUses: [
      'Symbolic study of discretion and personal boundaries',
      'Contemplation of your own social masks',
    ],
    cautions:
        'Historical, informative content about grimoires. No practice here involves or encourages harm',
    related: ['Goddesses', 'Sacred Symbols'],
  ),
  ArcaneEntry(
    name: 'Stolas',
    emoji: '🦉',
    summary: 'The owl prince who teaches herbs, stones and astronomy',
    origin: 'Goetia (Lemegeton), a prince of the grimoires',
    history:
        'Stolas (or Stolos) appears as a great crowned owl who teaches astronomy and the power of herbs and precious stones — the goetic spirit closest to the heart of natural witchcraft. He is therefore a beloved figure among practitioners who study plants and crystals',
    perspectives: [
      ArcanePerspective(
        tradition: 'Goetic',
        view: 'A prince who teaches astronomy, herbs and the worth of stones',
      ),
      ArcanePerspective(
        tradition: 'Symbolic',
        view: 'The crowned owl: night wisdom that sees in the dark',
      ),
      ArcanePerspective(
        tradition: 'Natural witchcraft',
        view: 'Informal patron of the study of magical herbals and lapidaries',
      ),
    ],
    characteristics: ['Natural wisdom', 'Herbalism', 'The stars', 'Night vision'],
    symbolism: [
      'The owl: seeing what the light hides',
      'The crown: knowledge as royalty',
      'The starry sky: the map above and within us',
    ],
    correspondences: ['Herbs and crystals', 'Night', 'Moss green and silver'],
    studyPractices: [
      'Build your own index of the herbs and stones you study',
      'Watch the sky through one lunation and take notes',
    ],
    magicalUses: [
      'Symbolic study of learning herbs and crystals',
      'Night contemplations of sky watching',
    ],
    cautions:
        'Historical, informative content about grimoires. No practice here involves or encourages harm',
    related: ['Herbs', 'Crystals'],
  ),
  ArcaneEntry(
    name: 'Buer',
    emoji: '🌿',
    summary: 'The healer president of the Goetia, master of medicinal herbs',
    origin: 'Goetia (Lemegeton), a president of the grimoires',
    history:
        'Buer teaches natural philosophy, logic and the virtues of herbs, and is described as the one who "heals all infirmities". Illustrated by Collin de Plancy as a five-legged wheel, he became a curious symbol of the perpetual motion of learning',
    perspectives: [
      ArcanePerspective(
        tradition: 'Goetic',
        view: 'A president who teaches the virtues of plants and restores health',
      ),
      ArcanePerspective(
        tradition: 'Historical',
        view: 'A reflection of the ancient physician-philosopher: healing, logic and ethics went together',
      ),
      ArcanePerspective(
        tradition: 'Symbolic',
        view: 'The five-legged wheel: knowledge that never stops turning',
      ),
    ],
    characteristics: ['Healing', 'Herbalism', 'Logic', 'Natural philosophy'],
    symbolism: [
      'The wheel: the continuous motion of study',
      'The centaur with a bow (other sources): instinct and aim',
      'The sprig of herbs: medicine in nature',
    ],
    correspondences: ['Medicinal herbs', 'Sagittarius in the grimoires', 'Green and white'],
    studyPractices: [
      'Study the history of herbal medicine',
      'Reflect on the ethics of healing: limits and responsibility',
    ],
    magicalUses: [
      'Symbolic study of the healer\'s path',
      'Contemplation of health as balance',
    ],
    cautions:
        'Historical, informative content. Real medicinal herbs require professional guidance',
    related: ['Herbs', 'The Healer (Archetypes)'],
  ),
  ArcaneEntry(
    name: 'Dantalion',
    emoji: '📖',
    summary: 'The duke of a thousand faces who knows every thought',
    origin: 'Goetia (Lemegeton), 71st spirit',
    history:
        'Dantalion appears with countless faces of men and women, holding a book. The grimoires say he knows the thoughts of all people and teaches every art and science — the perfect image of empathy taken to the edge of mystery',
    perspectives: [
      ArcanePerspective(
        tradition: 'Goetic',
        view: 'A duke who reveals thoughts and teaches any art or science',
      ),
      ArcanePerspective(
        tradition: 'Symbolic',
        view: 'The thousand faces: every human mind contains multitudes',
      ),
      ArcanePerspective(
        tradition: 'Modern occultist',
        view: 'A figure associated with the study of empathy, persuasion and one\'s own biases',
      ),
    ],
    characteristics: ['Radical empathy', 'Multiplicity', 'Study of minds', 'The inner book'],
    symbolism: [
      'The book in hand: every person is a library',
      'The thousand faces: the versions of ourselves',
      'The mirror: reading another is reading yourself',
    ],
    correspondences: ['Mercury', 'Wednesday', 'Lilac and graphite'],
    studyPractices: [
      'Reflect: how many "selves" speak within you?',
      'Practice deep, non-judgmental listening for one day',
    ],
    magicalUses: [
      'Symbolic study of empathy and communication',
      'Contemplation of your own many faces',
    ],
    cautions:
        'Historical, informative content about grimoires. No practice here involves or encourages harm',
    related: ['The Seer (Archetypes)', 'The Weaver (Archetypes)'],
  ),
];
