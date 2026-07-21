import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// 'tarot' trail — English content.
/// Parity with _pt/_es is verified in test/trails_parity_test.dart.
const LearningTrail tarotTrailEn = LearningTrail(
    id: 'tarot',
    emoji: '🎴',
    title: 'Tarot',
    subtitle: 'The 78 doors of self-knowledge',
    description:
        'From zero to fluent reading: the arcana, the suits, and the art of weaving stories with the cards — training in the Tarot Tutor and recording your discoveries.',
    lessons: [
      TrailLesson(
        id: 'ta_01',
        recordKind: LessonRecordKind.tarot,
        tool: LessonTool.tarotLibrary,
        title: 'The deck: a map in 78 cards',
        teaching:
            'The tarot is a map of human experience drawn across 78 cards. There are 22 major arcana, which portray the great forces and passages of life, and 56 minor arcana, which describe the everyday. Knowing this map matters because it offers a mirror: each card names something you have already lived or will live one day, and naming is the first step toward understanding.\n\nThe minors are divided into four suits, each tied to an element. Wands is fire and speaks of action, projects, and passion. Cups is water and rules emotions, bonds, and intuition. Swords is air, the territory of the mind, of ideas and conflicts. Pentacles is earth: body, work, and matter. So an Ace of Wands brings a creative spark, while a Ten of Cups shows the emotional fullness of a home at peace.\n\nBefore memorizing any meaning, handle the cards. Tarot is learned through the hands and the eyes: notice the colors, gestures, and landscapes of each card. The most common beginner mistake is trying to memorize 78 entries at once and getting frustrated. Prefer short, frequent visits to the deck, letting the images speak first and letting study come later, as support.\n\nCarry this idea with you: the deck is not a code to crack, it is a territory to inhabit. You do not need to master all 78 cards today — you only need to start walking through them with curiosity. Each visit makes the map more familiar, and it is intimacy, not haste, that shapes a good reader.',
        practice:
            'Open the app\'s Card Library and browse the 78 cards without hurry, looking at each image before reading its meaning. At the end, choose one card that attracted you and another that unsettled you, and reread each one\'s text carefully. Then record what you saw and felt on this lesson\'s page. The goal is to create your first bond with the deck: to notice that it already speaks with you before any formal study.',
        pageTitle: 'My Meeting with the Deck',
        pagePurpose: 'Record my first contact with the 78 cards',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'The card that ATTRACTED me and what I saw in it:',
          'The card that UNSETTLED me and what it poked at:',
          'My guess: why these two?',
          'What I hope to learn from the tarot:',
        ],
      ),
      TrailLesson(
        id: 'ta_02',
        recordKind: LessonRecordKind.tarot,
        tool: LessonTool.tarotTutor,
        title: 'The Fool\'s Journey (0-VII)',
        teaching:
            'The major arcana tell a continuous story, known as The Fool\'s Journey. The Fool, card zero, sets out with no baggage and crosses the 21 cards that follow as stages of maturing. Studying the majors in order matters because it turns a loose list of cards into a living plot, one your memory embraces far more easily.\n\nIn this first third, the Fool meets the early masters: the Magician teaches the will that makes things real, the High Priestess keeps intuition and mystery, the Empress rules fertile creation, the Emperor gives structure and limits, the Hierophant passes down tradition, the Lovers present the choice that defines paths, and the Chariot celebrates the victory of well-directed will.\n\nTo study, tell the story out loud: the Fool leaps, learns with the Magician, falls silent with the High Priestess, and so on. Attach each arcanum to a word of your own, not to borrowed definitions. The common stumble is confusing the pairs: remember that the Magician acts and the Emperor organizes, that the High Priestess knows in silence and the Empress creates in abundance.\n\nKeep this key: from 0 to VII you learn the basic forces of the world — will, intuition, creation, order, tradition, choice, and direction. When one of these cards appears in a reading, ask which of these forces is asking to move through your life right now. The Journey has begun, and you are already walking within it.',
        practice:
            'Open the Tarot Tutor and take a quiz session dedicated to the major arcana from 0 to VII. Answer calmly, trying to recall the scene of each card before choosing an option. Redo the questions you miss until you answer them with confidence. When you finish, note on this lesson\'s page which arcana still blur together in your head. The goal is to fix the first third of The Fool\'s Journey through gentle repetition, without rote memorization.',
        pageTitle: 'The Fool\'s Journey: First Steps',
        pagePurpose: 'Fix arcana 0 to VII in memory',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'Where on the Journey (0-VII) am I TODAY? Why:',
          'The arcanum that made immediate sense to me:',
          'What the quiz revealed I still confuse:',
          'My one-line summary for each card (0-VII):',
        ],
      ),
      TrailLesson(
        id: 'ta_03',
        recordKind: LessonRecordKind.tarot,
        tool: LessonTool.tarotTutor,
        title: 'The trials of the soul (VIII-XIV)',
        teaching:
            'After learning the forces of the world, the Fool faces the second third of the Journey: the inner trials. From arcana VIII to XIV, the story leaves the outer masters behind and dives into the soul. These cards matter because they deal with what no one escapes — courage, retreat, cycles, consequences, and the great art of transformation.\n\nStrength, arcanum VIII in the Rider-Waite, teaches the gentle courage that tames without violence. The Hermit withdraws to find his own light. The Wheel of Fortune turns the cycles of life, and Justice, arcanum XI, collects the consequence of every choice. The Hanged Man inverts his gaze and gains a new perspective, Death ends what has fulfilled its time, and Temperance blends opposites into serene synthesis.\n\nThese are the cards that frighten beginners and sustain experienced readers. The classic mistake is reading Death as tragedy: it speaks of necessary endings, almost never of physical death. Study the group by linking each card to a trial you have already lived — emotional memory holds far more than dry repetition. And do not rush the Hermit: withdrawing is also moving forward.\n\nCarry this with you: maturity in tarot means losing your fear of these seven cards. When one of them appears, instead of fearing it, ask which trial is ripe in your life and what it has come to teach. Here lies the difference between someone who merely consults the cards and someone who truly converses with them.',
        practice:
            'In the Tarot Tutor, take a quiz session focused on arcana VIII to XIV, paying special attention to the ones that resemble each other, like the Wheel and Justice. After the quiz, open the Death card and contemplate the image for two minutes, breathing deeply, without fear. Finally, record your impressions on this lesson\'s page. The goal is to fix the trials of the soul in memory and turn the deck\'s most feared card into an ally of yours.',
        pageTitle: 'The Trials of My Soul',
        pagePurpose: 'Fix arcana VIII to XIV in memory',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'The "trial" (VIII-XIV) I am living right now:',
          'What Death means after the contemplation:',
          'The card in this group that became an ally:',
          'My one-line summary for each one:',
        ],
      ),
      TrailLesson(
        id: 'ta_04',
        recordKind: LessonRecordKind.tarot,
        tool: LessonTool.tarotTutor,
        title: 'The dark night and the dawn (XV-XXI)',
        teaching:
            'The final third of the Journey crosses the darkest night before the dawn. From arcana XV to XXI, the Fool faces his attachments and illusions in order to be reborn whole. Knowing this stretch matters because it describes the crises that transform — and shows that no night, however deep it seems, is the end of the story you are living.\n\nThe Devil reveals the attachments that bind, the Tower topples false structures in a single blow, the Star returns hope naked and serene, and the Moon dives into the illusions and fears of the unconscious. Then day breaks: the Sun brings clear joy, Judgement sounds like a call to rebirth, and the World closes the cycle in completeness — the dance of one who has integrated the whole Journey.\n\nTo fix it in memory, tell the full arc as a story, from the Fool\'s leap to the World\'s dance: narrating out loud engraves more than rereading. Beware the mistake of treating the Tower and the Devil as curses — in real readings, they usually point to urgent liberations. And remember: the Journey is not a straight line, it is a spiral; you walk it many times over the course of a life.\n\nKeep this image: every Tower that falls opens a view onto a Star. With all 22 majors complete, you now carry the skeleton of the tarot. Before any spread, first look for where on the spiral the querent stands — the rest of the reading organizes itself from there.',
        practice:
            'Open the Tarot Tutor and take a quiz session with arcana XV to XXI; then, a general round with all 22 major arcana. Next, set the app aside for a moment and tell the whole Journey out loud, card by card, as if narrating a tale. Come back and record your summary and your quiz accuracy on the page. The goal is to stitch the complete arc of the majors into memory, once and for all.',
        pageTitle: 'My Complete Journey',
        pagePurpose: 'Fix arcana XV to XXI and the full arc',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'My most recent "dark night" and the Star that appeared:',
          'The Fool\'s Journey told in my own words (summary):',
          'My ruling arcanum for this phase of life:',
          'Current accuracy on the majors quiz:',
        ],
      ),
      TrailLesson(
        id: 'ta_05',
        recordKind: LessonRecordKind.tarot,
        tool: LessonTool.tarotTutor,
        title: 'Wands and Cups: fire and water',
        teaching:
            'If the majors narrate the great passages, the suits speak of the everyday — and that is where most of a reading happens. Wands and Cups form the deck\'s warm pair: fire and water, impulse and feeling. Mastering this duo matters because it describes nearly everything that moves your days: desire, projects, bonds, and emotions.\n\nWands is fire: projects, passion, movement. The Ace lights the creative spark, the Three already gazes at the horizon of plans, and the Ten shows the overload of someone who took on too much. Cups is water: bonds, emotions, intuition. The Ace overflows with a new feeling, the Three celebrates among friends, and the Ten crowns emotional fullness. Each number tells a stage of the suit\'s energy.\n\nThe golden tip: number plus suit forms a sentence. Think of the number as the verb and the suit as the subject — Three is expansion, Cups is affection, so the Three of Cups is shared celebration. The common mistake is memorizing each card in isolation; build the sentence and you can read any minor. Train with your own day: which Wands card was that hectic meeting?\n\nCarry this with you: fire without water burns out, water without fire stagnates. Wands asks where your drive is; Cups asks how your heart is doing. When these two suits dominate a spread, life is speaking of passion and of bonds — and you already know how to conjugate both.',
        practice:
            'Open the Tarot Tutor and take a quiz session dedicated to the suits of Wands and Cups. Before answering each question, build the number-plus-suit sentence in your mind and only then check the options. After the quiz, create three sentences of that kind on your own and record them on the page, along with any confusions that appear. The goal is to internalize the logic that lets you read any minor card without rote memorization.',
        pageTitle: 'Fire and Water in My Hands',
        pagePurpose: 'Master the logic of Wands and Cups',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'Where my FIRE is burning (which Wands card describes it):',
          'How my WATER is flowing (which Cups card describes it):',
          'My 3 number+suit sentences:',
          'Confusions the quiz revealed:',
        ],
      ),
      TrailLesson(
        id: 'ta_06',
        recordKind: LessonRecordKind.tarot,
        tool: LessonTool.tarotTutor,
        title: 'Swords and Pentacles: air and earth',
        teaching:
            'Swords and Pentacles complete the quartet of suits: air and earth, mind and matter. This is the pair that balances the deck — after desire and emotion come thought and solid ground. Knowing both matters because every mature reading must distinguish what is an idea, what is concrete fact, and what is fear dressed up as truth.\n\nSwords is air: the mind, with its clarity that cuts and its anxiety that wounds. It is the suit with the hardest reputation and also the most honest one — the Ace brings the naked truth, the Three names the pain of disappointment, the Nine portrays the insomnia of worry. Pentacles is earth: body, work, money, and the magic of well-tended matter — from the Ace, a concrete seed, to the Ten, wealth and legacy.\n\nKeep using the number-plus-element formula: now you can read any numbered minor in the deck. The common mistake here is dramatizing Swords — the suit describes thoughts, not sentences. Facing a harsh card, ask what thought this is, not what disaster is coming. And honor Pentacles: caring for the concrete is also spiritual practice.\n\nKeep this synthesis: Swords shows what your mind tells you; Pentacles shows what your hands build. Between thinking and making real walks the whole of life. With all four suits in your bag, the entire everyday world has become reading vocabulary for you.',
        practice:
            'In the Tarot Tutor, take a quiz session with the suits of Swords and Pentacles, applying the number-plus-element formula before each answer. When you finish, walk through the suit of Swords in your mind and identify which card most resembles your mind today; do the same with Pentacles and your material life. Record everything on the page. The goal is to complete your mastery of the four suits and bring the cards into your present.',
        pageTitle: 'Air and Earth in My Hands',
        pagePurpose: 'Master the logic of Swords and Pentacles',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'The Swords card of my mind today (and why):',
          'The Pentacles card of my material life today:',
          'What the "tens" of each suit teach me about excess:',
          'Current accuracy on the minors quiz:',
        ],
      ),
      TrailLesson(
        id: 'ta_07',
        recordKind: LessonRecordKind.tarot,
        tool: LessonTool.tarotTutor,
        title: 'The court: the sixteen people',
        teaching:
            'Sixteen cards of the deck describe not situations but people: they are the court cards — Page, Knight, Queen, and King of each suit. They matter because every reading involves people and postures, and the court is the mirror where the querent, the reader, and the characters of life appear with a face, an inner age, and a temperament.\n\nEach rank marks a maturity of the suit\'s energy: the Page learns and experiments, the Knight acts and rides out on a mission, the Queen masters the energy from within, the King governs it outwardly, in the world. Cross the rank with the element and the portrait emerges: the Queen of Cups welcomes with emotional depth, the Knight of Swords charges ahead with sharp ideas and plenty of haste.\n\nIn a spread, a court card can be someone present in the situation or a role you yourself are wearing — always ask: who is this, or what am I being? The common mistake is pinning each court card to a physical person who looks the part; prefer to read temperaments. Train by matching loved ones to the sixteen cards: emotional memory anchors the learning.\n\nCarry this with you: you are not a single court card — you are the whole deck, wearing ranks as the week demands. Before a court card, always ask the double question: who is acting this way, and when is it me who acts this way. With it, these sixteen cards stop confusing and start revealing.',
        practice:
            'Open the Tarot Tutor and take a quiz session dedicated to the sixteen court cards, attentive to each one\'s pair of rank and suit. Then reflect: which court card are you wearing this week — a curious Page, a providing Queen of Pentacles? Also choose court cards for three people in your life and record everything on the page. The goal is to recognize postures and temperaments, inside and outside of you.',
        pageTitle: 'The Court I Inhabit',
        pagePurpose: 'Recognize postures in the court cards',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'The court card I am wearing this week:',
          'People in my life as court cards (3 examples):',
          'The court card I need to invoke more:',
          'The one I need to let rest:',
        ],
      ),
      TrailLesson(
        id: 'ta_08',
        recordKind: LessonRecordKind.tarot,
        title: 'Drawing cards: the question is half',
        teaching:
            'A good reading begins before the shuffle: with the question. The question is half the answer, because it defines the lens through which the cards will be read. Asking well matters as much as knowing meanings — a whole spread of accurate cards cannot save a question that is crooked, vague, or that hands the deck your power to decide.\n\nOpen questions bear fruit: what do I need to see about this situation, what energy helps me now. Yes-or-no questions impoverish the conversation, and questions about other people\'s lives trespass on foreign territory. Rephrase until the question points at you — instead of asking whether someone will come back, ask what you need to understand about that bond.\n\nWhen drawing: breathe deeply, shuffle with the question alive in your body, and turn the cards over calmly. Read the image first — what the scene shows, what you feel as you look — and only then consult the meaning, which comes to your aid, never ahead of you. The common mistake is jumping straight to the text and ignoring what your eyes already knew.\n\nKeep this measure: open question, eyes first, meaning after. Whoever asks well has already received half an answer before turning the first card. The tarot does not decide for you — it lights up the terrain so you can decide better, and that is where your power lives.',
        practice:
            'Go to the app\'s Tarot page and choose the Three-Card spread. Before drawing, write your question and rephrase it until it is open and pointed at you. Shuffle while breathing deeply, turn the cards over, and read the images first, noting your impressions; only then open the meanings and compare. Record the process on the lesson\'s page. The goal is to establish the complete ritual: a well-made question, your own gaze, and study as support.',
        pageTitle: 'The Art of the Question',
        pagePurpose: 'Structure my consultations',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'My question (rephrased until it became mine):',
          'What the IMAGES told me before the text:',
          'What the meaning confirmed or corrected:',
          'My answer in one sentence:',
        ],
      ),
      TrailLesson(
        id: 'ta_09',
        recordKind: LessonRecordKind.tarot,
        title: 'Weaving the story: combined reading',
        teaching:
            'Cards do not speak alone — they converse. A mature reading does not add up isolated entries: it weaves a story in which each card illuminates its neighbors. Learning to combine matters because this is what separates those who look up meanings from those who truly read. The spread is a text, and the cards are sentences that only gain full meaning when read together.\n\nThree patterns guide the weaving: repetition of a suit reveals the dominant theme — many Cups, and the subject is affection; a majority of major arcana signals great forces at play, above the everyday; and neighbors light each other up — the Tower beside the Star is rupture with hope, the Ten of Wands near the Hermit asks for pause and retreat before going on.\n\nIn practice, before consulting any meaning, look at the whole spread and tell the story: where it begins, where it tightens, where it points to a way out. Writing the reading as a short tale trains the eye. The common mistake is reading card by card like loose index cards, each with its own paragraph, never connecting — and the story gets lost inside the dictionary.\n\nCarry this with you: your role as a reader is to narrate what the cards form together, with a beginning, a tension, and a counsel. Trust the thread you see running between the cards — it is your reading. Anyone can open the dictionary; the story, only you can tell.',
        practice:
            'On the Tarot page, do a Three-Card spread about a theme of your current moment. Before consulting any meaning, look at the whole spread and write the reading as a five-line mini tale, with a beginning, a tension, and a counsel. Then check the meanings, note suit repetitions, the presence of majors, and neighboring cards, and record everything. The goal is to train combined reading: weaving stories instead of adding up loose cards.',
        pageTitle: 'My First Woven Story',
        pagePurpose: 'Read combinations, not loose cards',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'The 3 cards and the spread:',
          'My 5-line mini tale:',
          'Patterns I noticed (suits, majors, neighbors):',
          'The spread\'s final counsel:',
        ],
      ),
      TrailLesson(
        id: 'ta_10',
        recordKind: LessonRecordKind.tarot,
        title: 'Your tarot: ethics and your own voice',
        teaching:
            'Reaching the end of the trail, what is missing is not technique: it is identity. The mature reader is known by two marks — firm ethics and a voice of her own. This matters because the tarot touches people in sensitive moments, and the difference between helping and haunting lies entirely in the posture of the one holding the cards before another soul.\n\nEthics comes down to returning the power: do not predict death or illness, do not decide anyone\'s life, do not feed dependence on consultations. Your own voice is built over time: your anchor cards, the ones you read with your eyes closed; your table rituals, the way you open and close each reading; your unique way of telling what the spread shows.\n\nDay to day, nothing steadies voice and bond like constancy: one card a day is worth more than one enormous spread a month. Draw the Card of the Day, write one line, go on with life — and at night notice how the card showed up. The common mistake is abandoning the practice when routine tightens; shrink the ritual if you must, but do not abandon it.\n\nKeep this as a manifesto: the tarot does not predict a sealed fate — it lights up paths for those who choose. You now know the map, the suits, the court, and the whole Journey. From here on, the deck speaks with your voice. Read with courage, with ethics, and with the tenderness of one who knows that every card is a mirror.',
        practice:
            'On the Tarot page, draw the Card of the Day for seven days in a row. Each morning, look at the image, breathe, and write a single line about what the card awakens; at night, if you wish, add how it showed up in your day. At the end of the week, reread the seven lines and write your reader\'s manifesto on the lesson\'s page. The goal is to establish the habit that sustains every reader: brief, constant, daily presence with the cards.',
        pageTitle: 'Reader\'s Manifesto',
        pagePurpose: 'Establish my ethics and voice in tarot',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'My reading ethics (what I do and what I never do):',
          'My anchor cards (the ones I already read with eyes closed):',
          'My table ritual (how I open and close readings):',
          'Diary of the 7 Cards of the Day:',
        ],
      ),
    ],
  );
