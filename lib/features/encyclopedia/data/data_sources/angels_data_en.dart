import '../models/arcane_entry_model.dart';

/// Encyclopedia Angels — English content.
///
/// Informative, historical approach across religious, folk, occult and
/// literary traditions. Emojis are invariant; keep the same order as
/// `angels_data_pt.dart` — parity is verified by
/// `test/content_parity_test.dart`.
const List<ArcaneEntry> angelsEn = [
  ArcaneEntry(
    name: 'Michael',
    emoji: '⚔️',
    summary: 'The prince of the heavenly hosts, strength and protection',
    origin: 'Jewish, Christian and Islamic traditions (Mikael)',
    history:
        'Mentioned in the Book of Daniel and in Revelation, Michael ("Who is like God?") is the commander of the heavenly hosts who defeats the dragon. Devotion to him swept through medieval Christendom, with hilltop shrines all across Europe',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religious',
        view:
            'Warrior archangel and psychopomp: he protects the faithful, weighs souls and leads the battle against evil',
      ),
      ArcanePerspective(
        tradition: 'Occult',
        view:
            'In ceremonial magic he rules the South and the element of Fire (in some schools, the East and Air), invoked in banishing rituals such as the LBRP',
      ),
      ArcanePerspective(
        tradition: 'Folk/Popular',
        view:
            'Patron of police officers and soldiers; invoked in prayers of protection against physical and spiritual dangers',
      ),
    ],
    characteristics: ['Courage', 'Justice', 'Leadership', 'Cutting harmful ties'],
    symbolism: [
      'The flaming sword: truth that cuts through illusion',
      'The scales: fair judgment',
      'The defeated dragon: the shadow mastered',
    ],
    correspondences: ['Sunday', 'Sun/Fire', 'Gold and red', 'Frankincense'],
    studyPractices: [
      'Compare the biblical mentions with medieval angelology',
      'Contemplate: "which inner battle calls for courage right now?"',
    ],
    magicalUses: [
      'Invoked in rituals of protection and courage',
      'Meditations for cutting energetic cords',
    ],
    cautions:
        'Historical, informative content: traditions diverge and no single reading is definitive',
    related: ['The Guardian (Archetypes)', 'Sacred Symbols'],
  ),
  ArcaneEntry(
    name: 'Gabriel',
    emoji: '📯',
    summary: 'The messenger: announcements, revelations and the power of the word',
    origin: 'Jewish, Christian and Islamic traditions (Jibril)',
    history:
        'Gabriel ("Strength of God") appears in Daniel interpreting visions and, in the New Testament, announces the births of John the Baptist and Jesus. In Islam, it is Jibril who reveals the Quran to Muhammad — the great intermediary between heaven and humankind',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religious',
        view:
            'The divine herald par excellence: bearer of revelations, birth announcements and prophetic callings',
      ),
      ArcanePerspective(
        tradition: 'Occult',
        view:
            'Associated with the West, Water and the Moon in ceremonial magic; he rules dreams, intuition and the mysteries of the lunar cycle',
      ),
      ArcanePerspective(
        tradition: 'Literary',
        view:
            'Present from Milton to contemporary works as the trumpeter of judgment and the reluctant messenger',
      ),
    ],
    characteristics: ['Communication', 'Revelation', 'Intuition', 'Fertility of ideas'],
    symbolism: [
      'The trumpet: the call that awakens',
      'The lily: purity of the message',
      'The moon: cycles and dreams',
    ],
    correspondences: ['Monday', 'Moon/Water', 'White and silver', 'Jasmine'],
    studyPractices: [
      'Record announcing dreams in the Dream Journal',
      'Study the annunciations across the three Abrahamic traditions',
    ],
    magicalUses: [
      'Meditations for clarity in communication',
      'Intuition work and lucid dreaming',
    ],
    cautions:
        'Historical, informative content: traditions diverge and no single reading is definitive',
    related: ['The Seer (Archetypes)', 'Dreams & Visions'],
  ),
  ArcaneEntry(
    name: 'Raphael',
    emoji: '💚',
    summary: 'The medicine of God: healing, journeys and fortunate meetings',
    origin: 'Book of Tobit (Judeo-Christian tradition); Israfil in Islam plays another role',
    history:
        'In the Book of Tobit, Raphael ("God heals") travels in disguise beside young Tobias, teaches him remedies and cures his father\'s blindness — which is why he is the patron of travelers, physicians and matchmakers',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religious',
        view:
            'Archangel of healing and companion of the road: he protects journeys and restores health of body and soul',
      ),
      ArcanePerspective(
        tradition: 'Occult',
        view:
            'In ceremonial magic he rules the East and Air (in some schools, Mercury), tied to the knowledge that heals',
      ),
      ArcanePerspective(
        tradition: 'Folk/Popular',
        view:
            'Invoked in novenas for health, successful surgeries and fortunate encounters',
      ),
    ],
    characteristics: ['Healing', 'Protective companionship', 'Serene joy', 'Practical knowledge'],
    symbolism: [
      'The traveler\'s staff: the guided journey',
      'The fish: the unexpected remedy',
      'The flask of balm: sacred medicine',
    ],
    correspondences: ['Wednesday', 'Mercury/Air', 'Green and yellow', 'Lavender'],
    studyPractices: [
      'Read the Book of Tobit as a tale of healing and crossing',
      'Contemplate: "which wound of mine asks for a companion on the road?"',
    ],
    magicalUses: [
      'Meditations for healing and convalescence',
      'Travel blessings and protection of one\'s paths',
    ],
    cautions:
        'Spiritual practices do not replace medical treatment. Historical, informative content',
    related: ['The Healer (Archetypes)', 'Energy & Healing'],
  ),
  ArcaneEntry(
    name: 'Uriel',
    emoji: '🔥',
    summary: 'The fire of God: intellectual illumination and truth',
    origin: 'Jewish apocryphal literature (2 Esdras, Book of Enoch)',
    history:
        'Uriel ("Fire/Light of God") appears in the apocrypha as the angel who guides Ezra and watches over the gates. Outside the official canon of the major churches, he became a central figure of esoteric and Anglican angelology',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religious',
        view:
            'Revered in some Eastern and Anglican churches as the archangel of wisdom; absent from the current Catholic canon',
      ),
      ArcanePerspective(
        tradition: 'Occult',
        view:
            'He rules the North and the element of Earth in ceremonial magic; guardian of the mysteries and of the inner light',
      ),
      ArcanePerspective(
        tradition: 'Literary',
        view:
            'In Milton, he is the "sharpest-sighted spirit of all in Heaven" — the watcher who sees far',
      ),
    ],
    characteristics: ['Wisdom', 'Discernment', 'Study', 'Plain-spoken truth'],
    symbolism: [
      'The flame in the palm: inner illumination',
      'The scroll: revealed knowledge',
      'The lightning bolt: sudden insight',
    ],
    correspondences: ['Earth', 'Amber', 'Red and ochre', 'Sandalwood'],
    studyPractices: [
      'Study with intention: light a candle before learning something new',
      'Compare canonical and apocryphal angelology',
    ],
    magicalUses: [
      'Clarity meditations for difficult decisions',
      'Rituals to illuminate paths and studies',
    ],
    cautions:
        'Historical, informative content: traditions diverge and no single reading is definitive',
    related: ['The Wise Woman (Archetypes)', 'The Alchemist (Archetypes)'],
  ),
  ArcaneEntry(
    name: 'Lucifer',
    emoji: '🌟',
    summary: 'The light-bearing angel: the morning star before and after the fall',
    origin: 'Latin lucifer ("light-bearer", the morning star); Isaiah 14',
    history:
        'Originally the Latin name of Venus as the morning star, "Lucifer" became attached to the fallen king of Isaiah 14 and, from there, to the rebel angel. Milton made him the tragic anti-hero of Paradise Lost; Romantic and occult currents reread him as a symbol of knowledge and luminous rebellion',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religious',
        view: 'The angel who fell through pride; identified with Satan in the Christian tradition',
      ),
      ArcanePerspective(
        tradition: 'Literary',
        view:
            'In Milton and in Romanticism, the magnificent rebel — "better to reign in Hell than serve in Heaven"',
      ),
      ArcanePerspective(
        tradition: 'Modern occult',
        view:
            'A symbol of free thought and the pursuit of knowledge (philosophical Luciferianism), distinct from popular Satanism',
      ),
    ],
    characteristics: ['Pride', 'Intellectual brilliance', 'Rebellion', 'Fall and quest'],
    symbolism: [
      'The morning star: the light that precedes the sun',
      'The fall: the price of hubris',
      'The torch: knowledge that frees or burns',
    ],
    correspondences: ['Morning Venus', 'Symbolic sulfur', 'Electric blue'],
    studyPractices: [
      'Read Isaiah 14 and Paradise Lost side by side',
      'Reflect on healthy pride vs. hubris',
    ],
    magicalUses: [
      'Symbolic study of your own brilliance and your own falls',
      'Contemplation of Venus in the morning sky',
    ],
    cautions:
        'Historical, informative content. No practice here involves or encourages harm',
    related: ['The Alchemist (Archetypes)', 'Sacred Symbols'],
  ),
  ArcaneEntry(
    name: 'Metatron',
    emoji: '📖',
    summary: 'The celestial scribe and the geometry of the cosmos',
    origin: 'Jewish mysticism (Talmud, Hekhalot literature, Kabbalah)',
    history:
        'In the Jewish mystical tradition, Metatron is the scribe who records all things and, in some currents, the prophet Enoch transfigured. In Kabbalah he is linked to the sefirah Kether — the point closest to the ineffable',
    perspectives: [
      ArcanePerspective(
        tradition: 'Jewish mysticism',
        view:
            'The "prince of the presence": divine scribe and transmitting voice; a figure for advanced study, not for worship',
      ),
      ArcanePerspective(
        tradition: 'Occult/New Age',
        view:
            'Linked to "Metatron\'s Cube", a sacred-geometry figure said to contain the Platonic solids — a modern reading without an ancient source',
      ),
    ],
    characteristics: ['Record-keeping', 'Cosmic order', 'Ascension', 'Deep study'],
    symbolism: [
      'The cube: the structure of creation',
      'The quill and the book: the memory of the universe',
      'The ladder: Enoch\'s journey',
    ],
    correspondences: ['Sacred geometry', 'Selenite', 'White and violet'],
    studyPractices: [
      'Study sacred geometry and draw Metatron\'s Cube',
      'Journaling as the "scribe" of your own life',
    ],
    magicalUses: [
      'Sacred-geometry meditations for mental order',
      'Rituals of recording and reviewing cycles',
    ],
    cautions:
        'Distinguish ancient sources from modern rereadings as you study. Historical, informative content',
    related: ['Sacred Symbols', 'The Weaver (Archetypes)'],
  ),
  ArcaneEntry(
    name: 'Sandalphon',
    emoji: '🎶',
    summary: 'Metatron\'s spiritual twin brother, lord of music and prayers',
    origin: 'Jewish mysticism; associated with the prophet Elijah',
    history:
        'In the mystical tradition, Sandalphon gathers human prayers and weaves them into crowns. Like Metatron/Enoch, he is said to be the prophet Elijah raised on high — the link between the cry of the earth and heaven',
    perspectives: [
      ArcanePerspective(
        tradition: 'Jewish mysticism',
        view:
            'The angel who carries prayers to the throne; associated with the sefirah Malkuth, the earthly kingdom',
      ),
      ArcanePerspective(
        tradition: 'New Age',
        view:
            'Invoked as the patron of music and musicians, of the arts that uplift',
      ),
    ],
    characteristics: ['Devotion', 'Music', 'Groundedness', 'Bridge between earth and heaven'],
    symbolism: [
      'The sandals: sacred walking upon the earth',
      'The crown of prayers: the strength of the collective',
      'The lyre: prayer set to song',
    ],
    correspondences: ['Devotional music', 'Turquoise', 'Earth and Malkuth'],
    studyPractices: [
      'Sing or play music as a contemplative practice',
      'Study the role of music in religious traditions',
    ],
    magicalUses: [
      'Mantras and chants in rituals',
      'Grounding practices before energy work',
    ],
    cautions:
        'Historical, informative content: traditions diverge and no single reading is definitive',
    related: ['Metatron', 'Affirmations (Journal)'],
  ),
  ArcaneEntry(
    name: 'Raziel',
    emoji: '🗝️',
    summary: 'The keeper of secrets and of the book of mysteries',
    origin: 'Kabbalah and Jewish mystical literature (Sefer Raziel HaMalakh)',
    history:
        'Raziel ("Secret of God") is said to have handed Adam a book holding all the mysteries of the universe — the legendary Sefer Raziel, whose medieval version circulated as a grimoire of protection',
    perspectives: [
      ArcanePerspective(
        tradition: 'Kabbalistic',
        view:
            'Associated with the sefirah Chokmah (wisdom); the hidden knowledge that precedes form',
      ),
      ArcanePerspective(
        tradition: 'Occult',
        view:
            'The medieval Sefer Raziel was copied as an amulet: keeping the book at home was said to protect against fire',
      ),
    ],
    characteristics: ['Mystery', 'Esoteric knowledge', 'Protection through knowing'],
    symbolism: [
      'The sealed book: knowledge that must be earned',
      'The key: initiation',
      'The veil: the hidden revealed little by little',
    ],
    correspondences: ['Indigo', 'Sodalite', 'Chokmah', 'Myrrh'],
    studyPractices: [
      'Keep a personal grimoire as "your own Sefer Raziel"',
      'Study the history of medieval grimoires',
    ],
    magicalUses: [
      'Consecrating your personal grimoire',
      'Meditations for reaching inner knowledge',
    ],
    cautions:
        'Historical grimoires reflect their times: study them critically. Historical, informative content',
    related: ['My Grimoire', 'The Alchemist (Archetypes)'],
  ),
  ArcaneEntry(
    name: 'Guardian Angel',
    emoji: '👼',
    summary: 'The personal companion: the universal belief in an individual protector',
    origin: 'Greco-Roman antiquity (daimon/genius) and the Abrahamic traditions',
    history:
        'The idea of a personal protective spirit predates Christianity: the Greeks had the daimon, the Romans the genius. Christianity consolidated the individual guardian angel, and ceremonial magic made contact with the "Holy Guardian Angel" its great work',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religious',
        view:
            'Each person has an appointed angel who protects and intercedes — with a liturgical memorial on October 2nd',
      ),
      ArcanePerspective(
        tradition: 'Occult',
        view:
            'In the Abramelin tradition and the Golden Dawn, the "Knowledge and Conversation of the Holy Guardian Angel" is the central goal of magical work — read by many as the Higher Self',
      ),
      ArcanePerspective(
        tradition: 'Folk',
        view:
            'Popular prayers ("Angel of God, my guardian dear...") and the everyday belief in narrow escapes',
      ),
    ],
    characteristics: ['Constant presence', 'Intuitive warning', 'Comfort'],
    symbolism: [
      'The enfolding wings: shelter',
      'The light at one\'s side: invisible company',
    ],
    correspondences: ['White candle', 'Personal angel', 'White quartz'],
    studyPractices: [
      'Record "close calls" and protective intuitions in the Journal',
      'Compare the Socratic daimon with the Christian guardian angel',
    ],
    magicalUses: [
      'Meditative dialogue with the inner protector',
      'A weekly white candle in gratitude',
    ],
    cautions:
        'Historical, informative content: traditions diverge and no single reading is definitive',
    related: ['The Guardian (Archetypes)', 'Mystic Counselor'],
  ),
  ArcaneEntry(
    name: 'Seraphim',
    emoji: '🔥',
    summary: 'The burning ones: the order closest to the throne',
    origin: 'Isaiah\'s vision (Old Testament)',
    history:
        'Isaiah describes them with six wings, crying "Holy, Holy, Holy". Their name derives from "to burn" — they are divine love in an incandescent state, the summit of Pseudo-Dionysius\'s angelic hierarchy',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religious',
        view:
            'The highest order, consumed in perpetual adoration before the throne',
      ),
      ArcanePerspective(
        tradition: 'Mystical',
        view:
            'The seraphic fire as a metaphor for spiritual ecstasy — the love that purifies as it burns',
      ),
    ],
    characteristics: ['Ardor', 'Purity', 'Adoration', 'Intensity'],
    symbolism: [
      'The six wings: reverence, readiness and flight',
      'The ember: purification (the live coal on Isaiah\'s lips)',
    ],
    correspondences: ['Fire', 'Deep red', 'Frankincense and myrrh'],
    studyPractices: [
      'Read Isaiah 6 and the hierarchy of Pseudo-Dionysius',
      'Contemplate: "what in me deserves to burn with enthusiasm?"',
    ],
    magicalUses: [
      'Meditations of purification through symbolic fire',
      'Red candles in devotional practices',
    ],
    cautions:
        'Historical, informative content: traditions diverge and no single reading is definitive',
    related: ['Uriel', 'Elements: Fire'],
  ),
  ArcaneEntry(
    name: 'Cherubim',
    emoji: '🌩️',
    summary: 'The guardians of the throne and of Eden — nothing like winged babies',
    origin: 'Genesis, Ezekiel and Mesopotamian art',
    history:
        'The biblical cherubim guard Eden with a flaming sword and bear the divine throne in Ezekiel\'s visions — imposing tetramorphic beings, kin to the Assyrian lamassu. The image of winged babies (putti) is an invention of Renaissance art',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religious',
        view:
            'Guardians of the sacred and bearers of the throne; sculpted upon the Ark of the Covenant',
      ),
      ArcanePerspective(
        tradition: 'Art-historical',
        view:
            'From fearsome tetramorph to decorative putto: a textbook case of iconographic transformation',
      ),
    ],
    characteristics: ['Unyielding guardianship', 'Majesty', 'Knowledge'],
    symbolism: [
      'The four faces: the whole of creation',
      'The flaming sword: the inviolable boundary',
      'The storm: the power of the sacred',
    ],
    correspondences: ['Storm', 'Lapis lazuli', 'Deep blue'],
    studyPractices: [
      'Compare Ezekiel\'s cherubim with the Assyrian lamassu',
      'Reflect on what you guard as non-negotiable',
    ],
    magicalUses: [
      'Visualizations for guarding sacred spaces',
      'Iconographic study as meditation',
    ],
    cautions:
        'Historical, informative content: traditions diverge and no single reading is definitive',
    related: ['The Guardian (Archetypes)', 'Michael'],
  ),
  ArcaneEntry(
    name: 'Ariel',
    emoji: '🦁',
    summary: 'The lion of God, angel of nature and the elements',
    origin: 'Hebrew Ari\'el ("lion of God"); Kabbalistic and occult traditions',
    history:
        'Cited in apocryphal texts and grimoires as the angel who rules wild nature, animals and the elemental spirits. In Renaissance magic he appears as ruler of Air (and, in some sources, of Earth), and Shakespeare immortalized him as the spirit of The Tempest',
    perspectives: [
      ArcanePerspective(
        tradition: 'Kabbalistic',
        view: 'An angelic name tied to the wild face of the sacred: the lion\'s strength in service of creation',
      ),
      ArcanePerspective(
        tradition: 'Occult',
        view: 'Ruler of elemental spirits; invoked in workings of harmony with nature',
      ),
      ArcanePerspective(
        tradition: 'Literary',
        view: 'Shakespeare\'s nimble spirit: the wind that serves, enchants and is at last set free',
      ),
    ],
    characteristics: ['Connection with nature', 'Environmental healing', 'Gentle courage', 'Elementals'],
    symbolism: [
      'The lion: strength that protects rather than devours',
      'The wind: messages from nature',
      'The compass rose: the four elements in balance',
    ],
    correspondences: ['Air and Earth', 'Green and gold', 'Wild plants', 'Green quartz'],
    studyPractices: [
      'Compare Ariel in the grimoires and in The Tempest',
      'A contemplative walk: what messages does nature bring today?',
    ],
    magicalUses: [
      'Meditations to reconnect with nature and the elements',
      'Blessings for gardens, plants and animals',
    ],
    cautions:
        'Historical, informative content: traditions diverge and no single reading is definitive',
    related: ['The Huntress (Archetypes)', 'Elements'],
  ),
  ArcaneEntry(
    name: 'Haniel',
    emoji: '🌹',
    summary: 'The grace of God: angel of Venus, of love and of the moon',
    origin: 'Hebrew Hana\'el ("grace of God"); Kabbalistic angelology',
    history:
        'In Kabbalah, Haniel rules the sphere of Netzach, associated with Venus, beauty and victory. Tradition ties him to the cycles of the moon and to the feminine mysteries, making him one of the angels most invoked in Venusian planetary magic',
    perspectives: [
      ArcanePerspective(
        tradition: 'Kabbalistic',
        view: 'Ruler of Netzach: beauty, elevated desire and the persistence of life',
      ),
      ArcanePerspective(
        tradition: 'Occult',
        view: 'Planetary angel of Venus, invoked on Fridays in workings of self-love and harmony',
      ),
      ArcanePerspective(
        tradition: 'Popular',
        view: 'Angel of grace and charm: he helps you see beauty in your own cycles',
      ),
    ],
    characteristics: ['Self-love', 'Harmony', 'Lunar intuition', 'Charm'],
    symbolism: [
      'The rose: beauty that blooms among thorns',
      'The crescent moon: cycles and renewal',
      'The star of Venus: love as a compass',
    ],
    correspondences: ['Friday', 'Venus/Moon', 'Emerald green and pink', 'Rose and jasmine'],
    studyPractices: [
      'Study Netzach on the Tree of Life',
      'A cycle journal: how does your energy shift with the moon?',
    ],
    magicalUses: [
      'Rituals of self-love and inner reconciliation',
      'Lunar workings of intuition and beauty',
    ],
    cautions:
        'Historical, informative content: traditions diverge and no single reading is definitive',
    related: ['The Maiden (Archetypes)', 'Goddesses'],
  ),
  ArcaneEntry(
    name: 'Azrael',
    emoji: '🕊️',
    summary: 'The angel of death and of passages, comfort for those who cross',
    origin: 'Islamic and Jewish traditions (Azra\'il, "the one whom God helps")',
    history:
        'In Islam, Azrael is the angel who gathers souls with compassion; in Jewish folklore, the messenger of passages. Far from the grim popular figure, the sources describe him as a devoted servant who accompanies every crossing with mercy',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religious',
        view: 'The angel charged with the passage of souls, who acts only at divine command',
      ),
      ArcanePerspective(
        tradition: 'Folk',
        view: 'The scribe who records births and erases names at the hour of departure',
      ),
      ArcanePerspective(
        tradition: 'Modern occult',
        view: 'A psychopomp invoked in rites of mourning and in the respectful honoring of ancestors',
      ),
    ],
    characteristics: ['Compassion', 'Crossings', 'Grief and comfort', 'Memory of the departed'],
    symbolism: [
      'The quill and the book: every life recorded',
      'The veil: the border between the worlds',
      'The dove: the soul departing in peace',
    ],
    correspondences: ['Saturday', 'Saturn', 'Gray and white', 'Cypress and myrrh'],
    studyPractices: [
      'Compare the Islamic Azrael with psychopomps from other cultures',
      'Write letters of farewell or gratitude to those who have passed',
    ],
    magicalUses: [
      'Rites of mourning, closing cycles and honoring ancestors',
      'Meditations for accepting great changes',
    ],
    cautions:
        'Historical, informative content. Deep grief also deserves human and professional support',
    related: ['The Dark Queen (Archetypes)', 'Wheel of the Year'],
  ),
  ArcaneEntry(
    name: 'Samael',
    emoji: '⚖️',
    summary: 'The venom of God: the stern angel between light and shadow',
    origin: 'Talmud and rabbinic literature; Sama\'el ("venom of God")',
    history:
        'An ambiguous figure in Jewish angelology: archangel of severity and heavenly accuser, sometimes identified with the angel of death, sometimes with Mars. In Kabbalistic folklore he is named the consort of Lilith — one of the most discussed pairings in occultism',
    perspectives: [
      ArcanePerspective(
        tradition: 'Rabbinic',
        view: 'The accuser who tests the righteous: severity that serves rather than destroys',
      ),
      ArcanePerspective(
        tradition: 'Kabbalistic',
        view: 'Associated with Gevurah and Mars: the force that cuts what needs to be cut',
      ),
      ArcanePerspective(
        tradition: 'Occult',
        view: 'A symbol of shadow work: facing the inner accuser and integrating it',
      ),
    ],
    characteristics: ['Severity', 'Hard justice', 'Boundaries', 'Integrated shadow'],
    symbolism: [
      'The sword of Mars: the necessary cut',
      'The venom: medicine in the right dose',
      'The tilted scales: judgment under tension',
    ],
    correspondences: ['Tuesday', 'Mars', 'Dark red', 'Pepper and iron'],
    studyPractices: [
      'Study Gevurah and the role of rigor on the Tree of Life',
      'Reflect: where does severity protect — and where does it wound?',
    ],
    magicalUses: [
      'Meditations on boundaries and shadow work',
      'Symbolic study of the Samael-Lilith pair in folklore',
    ],
    cautions:
        'Historical, informative content. No practice here involves or encourages harm',
    related: ['Lilith (Demons)', 'The Dark Queen (Archetypes)'],
  ),
  ArcaneEntry(
    name: 'Zadkiel',
    emoji: '💜',
    summary: 'The righteousness of God: angel of mercy and transmutation',
    origin: 'Hebrew Tzadki\'el ("righteousness of God"); Kabbalistic angelology',
    history:
        'Associated in Kabbalah with the sphere of Chesed (mercy) and with Jupiter, Zadkiel is remembered as the angel who stayed Abraham\'s hand. Modern esotericism linked him to the "violet flame" of transmutation popularized by the Theosophical schools',
    perspectives: [
      ArcanePerspective(
        tradition: 'Kabbalistic',
        view: 'Ruler of Chesed: the generosity that expands and forgives',
      ),
      ArcanePerspective(
        tradition: 'Theosophical/New Age',
        view: 'Keeper of the violet flame: transmuting heavy memories into learning',
      ),
      ArcanePerspective(
        tradition: 'Religious',
        view: 'The angel of mercy who halts unnecessary sacrifices',
      ),
    ],
    characteristics: ['Forgiveness', 'Generosity', 'Transmutation', 'Just abundance'],
    symbolism: [
      'The violet flame: the past transformed',
      'Jupiter\'s scepter: benevolence that governs',
      'The stayed hand: mercy above the rite',
    ],
    correspondences: ['Thursday', 'Jupiter', 'Violet and royal blue', 'Amethyst'],
    studyPractices: [
      'Study Chesed and the balance between giving and withholding',
      'A forgiveness practice: from whom do you still collect an inner debt?',
    ],
    magicalUses: [
      'Rituals of forgiveness and releasing old hurts',
      'Transmutation meditations with the violet flame',
    ],
    cautions:
        'Historical, informative content: traditions diverge and no single reading is definitive',
    related: ['The Healer (Archetypes)', 'Crystals'],
  ),
];
