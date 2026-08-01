import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// 'wicca' trail — English content.
/// Parity with _pt/_es checked in test/trails_parity_test.dart.
const LearningTrail wiccaTrailEn = LearningTrail(
    id: 'wicca',
    emoji: '🌕',
    title: 'Wicca',
    subtitle: 'The Goddess, the God and the Wheel of the Year',
    description:
        'The foundations of the religion of modern witchcraft: divine duality, sabbats, esbats and ethics — while building your Book of Shadows',
    lessons: [
      TrailLesson(
        id: 'wi_01',
        recordKind: LessonRecordKind.note,
        title: 'The Rede: "harm none"',
        teaching:
            'Wiccan ethics fits into one sentence known as the Rede: do what you will, as long as it harms none. It matters because it is the compass that guides the whole practice — before any spell, candle or altar comes the question of who your action reaches. And there is a detail many people forget: "none" includes you. Caring for yourself is already practicing the Rede\n\nFrom the Rede flows the reflection on return, which many traditions call the Threefold Law: the energy you set in motion comes back to you, in quality more than in exact arithmetic. The phrase became popular with modern Wicca, spread from Gerald Gardner and Doreen Valiente, and each tradition interprets it in its own way — some as spiritual law, others as an invitation to responsibility. There is no single dogma here: there is a living principle\n\nIn everyday life, the Rede shows up in small choices: what you say about someone, the spell you consider casting, the line you let yourself cross against your own well-being. Before acting, a beginner witch can ask: does this harm anyone, including me? A common mistake is to use the Rede as a courtroom for blaming yourself for everything. It is training in awareness, not a rod for punishment\n\nKeep this idea: freedom and responsibility walk together. You are free to desire, create and act — and it is precisely that freedom that asks for care with every thread of the web connecting you to others and to yourself. Your ethics is the first page of your path, and it is written every single day',
        practice:
            'What to do: honestly revisit a recent difficult situation. How: first, recall the scene without judgment; then ask yourself how the Rede would have guided your action, including care for you; finally, note on your page what you would do the same and what you would do differently. The goal is to train ethical awareness before the next real choice — this is training, not a trial',
        pageTitle: 'My Code of the Rede',
        pagePurpose: 'Translate Wiccan ethics into my life',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'The Rede in my own words:',
          'Three real situations where it guides me:',
          'Where I tend to harm myself (new agreement with me):',
          'What "return" means to me:',
        ],
      ),
      TrailLesson(
        id: 'wi_02',
        recordKind: LessonRecordKind.note,
        title: 'Goddess and God: the duality',
        teaching:
            'Classical Wicca honors the divine in duality: the Goddess and the God, two complementary faces of the same sacred. The Triple Goddess reveals herself as Maiden, Mother and Crone, mirroring the cycles of the moon; the Horned God is the sun and the wild nature that is born, ripens and dies with the seasons. This duality matters because it gives image and rhythm to what would otherwise remain far too abstract\n\nIn the Wicca spread by Gerald Gardner, Goddess and God dance through the Wheel of the Year: he is born at the winter solstice, grows, joins the Goddess and declines, while she remains, changing her face. Current branches soften this view — some worship only the Goddess, some honor many deities, and some see a sacred beyond gender. What is essential, common to nearly all traditions, is immanence: the divine is IN nature, not outside it\n\nIn daily life, this relationship starts small: noticing the moon phase on your way home, greeting the morning sun, lighting a silver candle for the Goddess or a golden one for the God. A beginner does not need to feel anything grand — the common mistake is forcing mystical experiences or copying someone else\'s devotion. Notice what truly touches you and begin from that point\n\nTake this key with you: the sacred does not live far away. It meets you in the changing moon, in the returning sun, in the weed that insists on sprouting through the pavement. Whatever face the divine has for you, Wicca invites you to recognize it close by — and to let that closeness transform the way you see',
        practice:
            'What to do: a five-minute devotional contemplation exercise. How: go outdoors or stand by the window, choose something alive from nature — a tree, the sky, the moon — and watch it in silence, as one contemplates a face of the divine, asking for nothing and in no hurry. Afterwards, record on your page what you felt. The goal is to exercise the perception of the immanent sacred, the one that requires no temple: only presence',
        pageTitle: 'How the Sacred Finds Me',
        pagePurpose: 'Record my relationship with the divine',
        pageCategory: SpellCategory.wisdom,
        pageIngredients: ['Silver and golden candles (optional)'],
        pagePrompts: [
          'Which face of the sacred touches me most:',
          'Where I have already felt this in nature:',
          'My simple gesture of daily devotion:',
          'How the 5-minute observation went:',
        ],
      ),
      TrailLesson(
        id: 'wi_03',
        recordKind: LessonRecordKind.note,
        title: 'The Wiccan altar',
        teaching:
            'The Wiccan altar is the cosmos arranged on a table: a meeting point between you and the forces you work with. On it live the four elements — the pentacle or salt for Earth, incense for Air, the candle for Fire, the cup for Water — along with symbols of the Goddess and the God. It matters because it gives the invisible a concrete address inside your home\n\nIn the tradition that spread from Gardner, each tool has a role: the athame or the wand direct the will, the chalice receives, the pentacle consecrates. Common symbols of the divine duality are a silver candle and a golden one, a shell and a horn, or two images. But traditions vary widely — there are fixed altars, seasonal altars that change with each sabbat, and minimal altars kept in a box. All of them are legitimate\n\nFor the beginner, the message is: start simple. A candle, a glass of water, a stone and a feather already make a complete altar. The most common mistake is postponing practice while waiting to buy perfect tools — the altar grows WITH the practice, not before it. Care for it as you care for a plant: clean it, renew the water, replace what has lost meaning. The Altar tab in the Encyclopedia offers more ideas\n\nKeep this idea: the altar is not a display case, it is a relationship. A humble table visited every day is worth more than a luxurious set covered in dust. Where you place attention and affection, the sacred finds a home. Build yours with what you have today and let it grow along with you',
        practice:
            'What to do: set up your first minimal altar, even a provisional one. How: choose a quiet corner, clean the surface and lay out four objects, one for each element — for example, a stone or salt for Earth, a feather or incense for Air, a candle for Fire and a glass of water for Water. Stand before it for a moment in silence. The goal is to create a physical meeting point with the sacred, one that will grow along with your practice',
        pageTitle: 'My Altar',
        pagePurpose: 'Record the building of my altar',
        pageCategory: SpellCategory.other,
        pagePrompts: [
          'Where I set it up and what represents each element:',
          'Symbols of the Goddess/the God (if I chose to have them):',
          'What I feel standing before it:',
          'What I want to add over time:',
        ],
      ),
      TrailLesson(
        id: 'wi_04',
        title: 'Calling the Quarters',
        teaching:
            'Calling the Quarters means inviting the guardians of the four directions to sustain the ritual circle: the East linked to Air, the North or the South linked to Fire depending on the hemisphere, the West linked to Water and the remaining direction linked to Earth. The practice matters because it establishes the circle as a living space, surrounded by allied presences, and anchors the rite in the four elements\n\nIn the ritual structure inherited from Gardnerian Wicca, the calls happen after the circle is cast, usually starting in the East and following the turning of the sun. Each call is a respectful invitation, never a command: the guardians — seen by some traditions as elemental spirits, by others as aspects of the psyche itself — are welcomed as guests of honor. At the end of the rite, they are released in reverse order, always with thanks\n\nAt first, it is common to freeze when speaking aloud or to forget the order. Take it slowly: simple, sincere words are worth more than memorized verses. A frequent mistake is copying northern-hemisphere correspondences without reflection — in the southern hemisphere, many witches adjust the directions to the real seasons and winds. Choose your own logic, record it and stay consistent with it\n\nTake this with you: an invitation is not a command. The strength of this practice lies in courtesy — you call, welcome, work and give thanks. Start small and repeat: familiarity turns gesture into rite. Whoever learns to open and close the doors with respect discovers that the circle becomes, more and more, a home',
        practice:
            'What to do: your first calling of the quarters. How: stand up, turn to each direction — in the order that makes sense in your hemisphere — and speak a simple invitation, such as: guardians of this direction, corresponding element, be welcome in my circle. When the moment ends, thank each direction in reverse order. The goal is to experience in your body the gesture of opening and closing a ritual space with respect and presence',
        pageTitle: 'My Calling of the Quarters',
        pagePurpose: 'Create my liturgy of the directions',
        pageCategory: SpellCategory.protection,
        pagePrompts: [
          'My direction→element correspondence (and hemisphere):',
          'My words for each call:',
          'My words of release:',
          'What I felt in each direction:',
        ],
      ),
      TrailLesson(
        id: 'wi_05',
        title: 'The Wheel of the Year',
        teaching:
            'The Wheel of the Year is the sacred calendar of Wicca: time lived as a circle, not as a straight line. There are eight sabbats — the two solstices, the two equinoxes and the four fire festivals: Samhain, Imbolc, Beltane and Lughnasadh. Celebrating them matters because it reconnects your life to the real rhythm of the earth: sowing, blossoming, harvesting and resting stop being metaphors and become experience\n\nIn the classic Wiccan narrative, the Wheel tells the story of the Goddess and the God through the seasons: the God is born at the winter solstice, grows, joins the Goddess at Beltane, gives himself at the harvest and returns to the womb of the Crone at Samhain, when the ancestors are honored. Each sabbat mirrors an inner moment: honoring those who came before, being reborn, blossoming, giving thanks for the harvest. Different traditions tell this story with variations — and all of them are valid\n\nIn the southern hemisphere, many witches flip the dates to follow the real seasons — celebrating Samhain in May, for example — while others keep the northern calendar. There is no single answer: choose your own consistency and record it. The beginner\'s common mistake is wanting grand rituals at every sabbat; start with ten-minute celebrations, sincere and simple\n\nTake this with you: the Wheel turns without hurry, and you turn with it. Each season of the earth meets a season within you. Celebrating the sabbats is just that: keeping regular appointments with your own cycle. When life feels stuck, remember: no winter is final — the Wheel always turns back toward the light',
        practice:
            'What to do: plan your first seasonal celebration. How: check the app\'s Wheel of the Year and find out which sabbat comes next in your hemisphere; read about what it celebrates; then design a ten-minute celebration — it can be lighting a candle, preparing a seasonal food or writing an intention. Note the plan on your page and carry it out on the date. The goal is to leave theory behind and live the Wheel at your own rhythm',
        pageTitle: 'My Next Sabbat',
        pagePurpose: 'Plan my first celebration of the Wheel',
        pageCategory: SpellCategory.other,
        pagePrompts: [
          'Sabbat and date (in my hemisphere):',
          'What it celebrates and what it mirrors in me:',
          'My 10-minute celebration:',
          'Afterwards: how did it go?',
        ],
      ),
      TrailLesson(
        id: 'wi_06',
        title: 'The Esbat: full moon magic',
        teaching:
            'If the sabbats celebrate the journey of the sun, the esbats honor the moon — especially the full moon, the classic hour for magical work in Wicca. The esbat is the witch\'s regular meeting with the Goddess in her lunar face: a moment of recharging, magic and listening. It matters because it creates rhythm: while the sabbats arrive every six or seven weeks, the full moon visits you every month\n\nIn traditional covens, the esbat is the working meeting: it is when magic, divination and healing are done, under the full moon that amplifies the subtle tides. A classic outline for the solitary witch: a preparation bath, casting the circle, greeting the Goddess, the gesture of Drawing Down the Moon — receiving the light in silence, letting it fill the body —, the magical or oracular work, the sharing of cakes and wine and the closing with gratitude\n\nIn real life, not every full moon finds you in the mood — and that is fine. An esbat can last ten minutes: a lit candle, three breaths under the moon, one intention. The common mistake is thinking it only counts with the full script; constancy is worth more than pomp. And if the sky is cloudy, the moon is still there: work just the same, trusting the invisible tide\n\nTake this with you: the moon is the monthly reminder that you also have phases. Drawing Down the Moon is, at heart, allowing yourself to receive — a rare thing in a life of so much doing. Set a date with her: the liturgy you write on your page will be your first original work on this path',
        practice:
            'What to do: your first gesture of Drawing Down the Moon. How: on the next night with a visible moon, go outside or stand by the window, breathe deeply and spend three minutes under her light — not asking, not speaking, only receiving, as if taking a bath of silver. Afterwards, record on your page what you felt in your body and your mood. The goal is to train the art of receiving, which is the heart of the esbat, before building your full moon liturgy',
        pageTitle: 'My Esbat Ritual',
        pagePurpose: 'Create my full moon liturgy',
        pageCategory: SpellCategory.energy,
        pageIngredients: ['White candle', 'Water', 'Something for "cakes and wine"'],
        pagePrompts: [
          'My opening (circle + greeting):',
          'My moment of Drawing Down the Moon:',
          'The work I will do at the esbats:',
          'My closing and sharing:',
        ],
      ),
      TrailLesson(
        id: 'wi_07',
        recordKind: LessonRecordKind.note,
        title: 'The Book of Shadows',
        teaching:
            'The Book of Shadows is the material heart of the Wiccan witch: the place where rituals, recipes, dreams, failures and discoveries live — everything recorded, without censorship. It matters because memory fails and practice evolves: what you write down today becomes the map that will guide the witch you will be a few years from now\n\nIn the Gardnerian tradition, the Book of Shadows was copied by hand, from teacher to initiate, preserving the coven\'s rites — and each copy took on the marks of the one who wrote it. Today, with the strength of solitary witchcraft, each practitioner starts their own from scratch, and traditions differ on the format: handcrafted notebooks, digital files, card boxes. What remains is the principle: recording is part of the rite, not paperwork after it\n\nYou are already writing yours: this app is it. Every page you fill in the trails and in My Grimoire is a leaf of your Book. In daily life, the habit that sustains everything is simple: after each ritual or practice, note the date, what you did, what you felt and the result. The common mistake is recording only the successes — failures teach more and deserve a page of their own\n\nTake this with you: a Book of Shadows does not need to be beautiful, it needs to be true. Organize it your own way and let the structure grow with use. It is the mirror of your journey and, one day, it may be an inheritance. Write as if talking with the witch of the future — she will be grateful for every line',
        practice:
            'What to do: an editorial review of your own Book. How: calmly go through the pages you have already written in the trails and in My Grimoire; notice themes that repeat, records that worked and gaps; then sketch, on this lesson\'s page, the sections that would make sense to organize it all. The goal is to discover the structure that already emerges naturally from your records — and to adopt it as the order of your Book of Shadows',
        pageTitle: 'The Order of My Book',
        pagePurpose: 'Organize my Book of Shadows',
        pageCategory: SpellCategory.study,
        pagePrompts: [
          'My sections (how I organize my records):',
          'What I ALWAYS record after a ritual:',
          'My ritual for opening the book (a phrase? a symbol?):',
          'Who (if anyone) I would leave this book to one day:',
        ],
      ),
      TrailLesson(
        id: 'wi_08',
        title: 'Magic with the Goddess: invocation',
        teaching:
            'To invoke, in Wicca, is to invite the divine close — not to bring down entities or give orders to the sacred. It is the gesture of opening your front door to a beloved visitor: you call, welcome and share time together. Invocation matters because it transforms the practice, which stops being a set of techniques and becomes a living relationship with what you hold sacred\n\nInvocation has three movements. First, preparing yourself: a bath, casting the circle, a few minutes of silence to arrive whole. Then, calling: with words from the heart, not formulas memorized from other people — Wiccan traditions keep famous invocations to the Goddess at the full moon, but all of them were born in the same place: someone who spoke truthfully. Finally, LISTENING — the most forgotten movement of the three\n\nIn a beginner\'s practice, the sign that the invocation worked is rarely spectacular: it is a different kind of silence, a warmth in the chest, a gentle certainty. The most common mistake is expecting phenomena and giving up when they do not come — or talking so much that no room is left for any answer. Always keep at least two minutes of absolute listening after you call\n\nTake this with you: invoking is conversing, and every good conversation holds more listening than speech. Call the sacred with your own words, in your own way, and trust the discreet signs. The divine presence tends to arrive in a low voice — learn, little by little, to listen quietly too',
        practice:
            'What to do: your first complete invocation. How: prepare with a bath or a few minutes of silence; in your space, call with your own words the divine energy that touches you most — Goddess, God or the sacred as you understand it; then remain two minutes in absolute listening, expecting nothing specific; close by giving thanks. The goal is to experience the three movements of the rite — preparing, calling and listening — and to record the subtle signs that appear',
        pageTitle: 'My Invocation',
        pagePurpose: 'Create my words of calling',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'My words of invocation:',
          'How I prepare beforehand:',
          'What I noticed while listening:',
          'How I close and give thanks:',
        ],
      ),
      TrailLesson(
        id: 'wi_09',
        title: 'Cakes and Wine: the sacred that nourishes',
        teaching:
            'The rite of cakes and wine closes Wiccan rituals with a grounding gesture: after moving energy, the body asks for solid ground — and eating and drinking with a blessing returns you to the world. It is the eucharist of nature: the sacred becoming body. The rite matters because it teaches something central in Wicca: matter and spirit are not enemies, and the table is also an altar\n\nIn traditional covens, the moment of cakes and wine seals the gathering: the food is blessed — in some traditions, with the symbolic gesture of the athame dipped into the chalice, the union of the God and the Goddess —, the first portion is offered to the earth and the rest is shared among all. The solitary witch adapts: the offering can go to the garden, to the window planter or to the foot of a tree. No wine? Juice, tea or water will do: the blessing is in the gesture, not on the menu\n\nIn everyday life, this rite can overflow from the circle into living: blessing breakfast, giving thanks before lunch, having one meal a day without screens and with presence. The common mistake is treating this step as an informal snack and skipping the offering — it is precisely offering first that turns consumption into communion. Presence is the ingredient that cannot be missing\n\nTake this with you: all food is the earth reaching you. When you bless, offer and eat with attention, the most ordinary act of the day becomes rite — and the sacred stops being a rare event and becomes a habit that nourishes, in the most literal sense of the word. Eat slowly: grounding is also celebrating',
        practice:
            'What to do: your first rite of cakes and wine outside the circle. How: prepare a simple snack and a drink — tea, juice or water count as much as wine; bless the food with your own words; set aside a first symbolic portion and offer it to the earth, to a planter or beside a plant; then eat slowly, with full presence and no screens. The goal is to experience grounding through food and feel the difference between eating on autopilot and communing',
        pageTitle: 'My Rite of Cakes and Wine',
        pagePurpose: 'Create my grounding rite',
        pageCategory: SpellCategory.home,
        pagePrompts: [
          'My "cakes" and my "wine" (what I use):',
          'My blessing over the food:',
          'How I make the offering:',
          'The difference between eating this way and eating on autopilot:',
        ],
      ),
      TrailLesson(
        id: 'wi_10',
        recordKind: LessonRecordKind.desire,
        title: 'Self-initiation: the commitment',
        teaching:
            'Self-initiation is the rite in which the solitary witch, without a coven, formally commits to the path — before the sacred as she understands it. It is not a diploma or a graduation: it is an intimate vow, made from you to you, witnessed by whatever you consider divine. It matters because it marks a crossing: from curious to practitioner, from one who studies to one who claims the path\n\nIn initiatory traditions, such as the Gardnerian, initiation is conferred by the coven after the classic period of a year and a day of study — and part of the Wiccan community holds that only this passes on the lineage. Other currents, especially since the spread of solitary practice, hold that sincere dedication before the gods has full value. Both views coexist in today\'s Wicca; your path is yours to choose, with respect for both\n\nIn practice, the rite usually gathers everything you have learned: bath, circle, calling the quarters, invocation, the vow spoken aloud, cakes and wine, a record in the Book of Shadows. The common mistake is haste — dedicating yourself in the first week of study — or the opposite: postponing forever because you never feel ready. The right time is your own, but there are signs: constancy in practice and clarity in desire\n\nTake this with you: no one initiates you onto your own path — not even a coven would do it without your inner yes. This last page is the draft of your dedication rite. Write it without hurry, perform it when you feel it is time and come back to record it. The Wheel keeps turning, and now you turn with it, hand in hand with what is sacred to you',
        practice:
            'What to do: write, for yourself alone, the draft of your commitment. How: in a quiet moment, answer in writing what it means to commit to this path — what you promise yourself, what you leave behind, what you wish to cultivate; then sketch the rite you will perform one day: place, elements, words. No deadline and no hurry. The goal is to prepare the heart and the text of your future self-initiation, to perform it when you feel the time has come',
        pageTitle: 'My Dedication Rite',
        pagePurpose: 'Design my commitment to the path',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'What I promise myself on this path:',
          'The rite I plan (place, elements, words):',
          'How I will know it is time:',
          '(After performing it) How my dedication day went:',
        ],
      ),
    ],
  );
