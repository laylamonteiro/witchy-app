import '../models/dream_theme_model.dart';

/// Dream themes and symbolism — English content.
///
/// Ids and emojis are invariant across languages; only titles, summaries,
/// readings and reflections are translated. Keep the same order as
/// `dream_themes_data_pt.dart` — parity is verified by
/// `test/dream_themes_parity_test.dart`.
const List<DreamTheme> dreamThemesEn = [
  DreamTheme(
    id: 'agua',
    emoji: '🌊',
    title: 'Water',
    summary: 'Emotions, the unconscious and the flow of life',
    readings: [
      DreamThemeReading(
        title: 'The state of your emotions',
        content:
            'Water tends to mirror your emotional moment: calm, crystal-clear waters may point to serenity and clarity; murky, rough or dark waters may signal feelings that are confused, dammed up or asking for attention',
      ),
      DreamThemeReading(
        title: 'The deep unconscious',
        content:
            'In the Jungian reading, seas and oceans represent the unconscious. Diving in can be an invitation to know yourself better; drowning may suggest a sense of being overwhelmed by unprocessed emotions',
      ),
      DreamThemeReading(
        title: 'Purification and renewal',
        content:
            'In many magical traditions, water is the element of cleansing and healing. Rain, baths and rivers in a dream can point to a purification cycle underway — something being washed away to make room for the new',
      ),
    ],
    reflection:
        'How was the water in your dream — and how are your emotions upon waking? Recording both sides helps you notice patterns',
  ),
  DreamTheme(
    id: 'queda',
    emoji: '🪂',
    title: 'Falling',
    summary: 'Loss of control and fear of failing',
    readings: [
      DreamThemeReading(
        title: 'A sense of losing control',
        content:
            'Dreaming that you fall is one of the most universal dreams, and it tends to accompany phases when something feels out of control: work, relationships, finances. The body translates the moment\'s insecurity into a fall',
      ),
      DreamThemeReading(
        title: 'Fear of disappointing',
        content:
            'Falling can also speak of the fear of failing in other people\'s eyes — the height of the "cliff" is usually proportional to the expectations we carry',
      ),
      DreamThemeReading(
        title: 'An invitation to surrender',
        content:
            'In mystical readings, falling without getting hurt (or flying after the fall) may indicate it is safe to release control and trust the flow — the fall becomes a crossing',
      ),
    ],
    reflection:
        'What in your life feels "groundless" right now? Naming that fear already weakens its power',
  ),
  DreamTheme(
    id: 'perseguicao',
    emoji: '🏃',
    title: 'Being Chased',
    summary: 'What we avoid facing',
    readings: [
      DreamThemeReading(
        title: 'Fleeing a conflict',
        content:
            'Being chased usually represents something we are avoiding: a difficult conversation, a postponed decision, a denied feeling. The pursuer is often the pending matter itself',
      ),
      DreamThemeReading(
        title: 'The inner shadow',
        content:
            'In dream psychology, what chases us can be a part of ourselves we reject — the "shadow". Turning around and facing the pursuer, in the dream or in your imagination upon waking, often transforms the plot',
      ),
      DreamThemeReading(
        title: 'External pressures',
        content:
            'It can also reflect real demands: deadlines, debts, other people\'s expectations. The dream exaggerates the image so the message gets heard',
      ),
    ],
    reflection:
        'If you stopped running and looked back, who — or what — would be there?',
  ),
  DreamTheme(
    id: 'morte',
    emoji: '🦋',
    title: 'Death',
    summary: 'End of a cycle and transformation',
    readings: [
      DreamThemeReading(
        title: 'Transformation, not an omen',
        content:
            'In the vast majority of traditions — from tarot to Jungian symbolism — death in a dream speaks of the end of a cycle and rebirth, not literal death. Something in you or in your life is closing to open up space',
      ),
      DreamThemeReading(
        title: 'Grief and longing',
        content:
            'Dreaming of people who have passed away can be a natural part of grief: the unconscious processes the absence and, for many spiritual traditions, it is also a space for meeting and saying goodbye',
      ),
      DreamThemeReading(
        title: 'What needs to go',
        content:
            'When the one who "dies" in the dream is the dreamer, it is worth asking: which version of me is ready to stay in the past? Habits, roles and identities die too',
      ),
    ],
    reflection:
        'What cycle is closing in your life? Honoring the ending is the first step of the new beginning',
  ),
  DreamTheme(
    id: 'animais',
    emoji: '🦉',
    title: 'Animals',
    summary: 'Instincts and guides from nature',
    readings: [
      DreamThemeReading(
        title: 'The voice of instinct',
        content:
            'Animals in dreams often embody instincts: a wolf may speak of loyalty and territory; a cat, of independence and mystery; a serpent, of transformation and vital energy',
      ),
      DreamThemeReading(
        title: 'Power animals',
        content:
            'In shamanic and witchcraft traditions, a recurring animal can be read as an ally or spirit guide. Notice its behavior in the dream: does it threaten, protect, lead the way?',
      ),
      DreamThemeReading(
        title: 'Relationship with your own body',
        content:
            'Wounded or caged animals can mirror neglected basic needs — rest, nourishment, pleasure, movement',
      ),
    ],
    reflection:
        'Which animal appeared and what was it doing? Look up its symbolism in the traditions that resonate with you',
  ),
  DreamTheme(
    id: 'dentes',
    emoji: '🦷',
    title: 'Teeth',
    summary: 'Self-image, personal power and loss',
    readings: [
      DreamThemeReading(
        title: 'Insecurity about your image',
        content:
            'Teeth falling out is a classic tied to self-image and fear of judgment: how will I be seen if I "lose face"? It often shows up in phases of exposure — a new job, relationship, big change',
      ),
      DreamThemeReading(
        title: 'A feeling of powerlessness',
        content:
            'Teeth are our "bite" on the world. Losing them can point to a sense of lost strength, voice or ability to defend yourself in some area',
      ),
      DreamThemeReading(
        title: 'Transition and growth',
        content:
            'Just as baby teeth fall out to make way for permanent ones, the dream can mark a phase transition — uncomfortable, but necessary',
      ),
    ],
    reflection:
        'In what recent situation did you feel you "lost your voice" or the power to react?',
  ),
  DreamTheme(
    id: 'casa',
    emoji: '🏠',
    title: 'House',
    summary: 'The self and its inner rooms',
    readings: [
      DreamThemeReading(
        title: 'A map of the self',
        content:
            'The house usually represents the dreamer: the facade is the social image; the living room, relationships; the bedroom, intimacy; the bathroom, emotional cleansing; the kitchen, creativity and care',
      ),
      DreamThemeReading(
        title: 'Unknown rooms',
        content:
            'Discovering new rooms or secret floors is a powerful dream: it points to talents, memories or possibilities within you that you have not yet explored',
      ),
      DreamThemeReading(
        title: 'The state of the structure',
        content:
            'A house in ruins, flooded or broken into can speak of weakened personal boundaries or structural exhaustion — body and routine asking for renovation',
      ),
    ],
    reflection:
        'Which room appeared and in what state was it? What does that say about this area of your life?',
  ),
  DreamTheme(
    id: 'voo',
    emoji: '🕊️',
    title: 'Flying',
    summary: 'Freedom, perspective and expansion',
    readings: [
      DreamThemeReading(
        title: 'Freedom won',
        content:
            'Flying with pleasure usually accompanies phases of expansion: a weight has lifted, a limit was overcome, a liberating decision was made',
      ),
      DreamThemeReading(
        title: 'Gaining perspective',
        content:
            'Seeing the world from above can point to the need — or the newly acquired ability — to look at a problem from a distance, with a view of the whole',
      ),
      DreamThemeReading(
        title: 'Escaping the ground',
        content:
            'If the flight is an escape from something, it is worth asking whether an "earthly" matter is being avoided. Unstable flights can speak of idealization without practical grounding',
      ),
    ],
    reflection:
        'Was the flight light or anxious? Freedom and escape sometimes use the same wings',
  ),
  DreamTheme(
    id: 'gravidez',
    emoji: '🌱',
    title: 'Pregnancy',
    summary: 'Projects and new beginnings gestating',
    readings: [
      DreamThemeReading(
        title: 'Something new being created',
        content:
            'Dreaming of pregnancy is rarely literal: it usually points to a project, idea, relationship or version of yourself in gestation — something growing quietly that has not yet come into the world',
      ),
      DreamThemeReading(
        title: 'A time for ripening',
        content:
            'The dream may remind you that there is a right time: gestations cannot be rushed. Anxiety about the "birth" can mirror impatience for results',
      ),
      DreamThemeReading(
        title: 'Creative potential',
        content:
            'In witchcraft, dream pregnancy is often read as fertility in the broad sense — creativity, abundance and manifestation on the way',
      ),
    ],
    reflection:
        'What are you gestating right now — and what does that project need in order to be born well?',
  ),
  DreamTheme(
    id: 'pessoas-do-passado',
    emoji: '🕰️',
    title: 'People from the Past',
    summary: 'Memories, loose ends and reintegration',
    readings: [
      DreamThemeReading(
        title: 'Unfinished business',
        content:
            'Ex-partners, distant friends or old colleagues tend to appear when something from that time asks for closure: a forgiveness, a lesson, a word left unsaid',
      ),
      DreamThemeReading(
        title: 'Qualities to reclaim',
        content:
            'The person may represent a trait of yours from that phase — courage, lightness, discipline — that the present is asking you to bring back',
      ),
      DreamThemeReading(
        title: 'Cycles compared',
        content:
            'The unconscious also uses the past as a measuring stick: the people who appear are those who lived through a cycle like your current one, inviting you to compare choices',
      ),
    ],
    reflection:
        'What did that person represent to you? Perhaps the message is about that quality, not about them',
  ),
  DreamTheme(
    id: 'lugares-desconhecidos',
    emoji: '🗺️',
    title: 'Unknown Places',
    summary: 'Unexplored inner territories',
    readings: [
      DreamThemeReading(
        title: 'The new calling',
        content:
            'Never-before-seen cities, roads and landscapes tend to announce brand-new phases — inwardly or outwardly. The tone of the place (welcoming, hostile, vast) shows how you feel about this novelty',
      ),
      DreamThemeReading(
        title: 'Unvisited potentials',
        content:
            'Like the secret rooms of the house, unknown lands can represent capacities of yours not yet explored',
      ),
      DreamThemeReading(
        title: 'A sense of displacement',
        content:
            'Getting lost in a strange place can mirror the feeling of not belonging — to a group, a job or a phase. The dream asks you to locate yourself: what is yours there?',
      ),
    ],
    reflection:
        'Did you feel lost or exploring? The same landscape changes meaning depending on the feeling',
  ),
  DreamTheme(
    id: 'sonhos-recorrentes',
    emoji: '🔁',
    title: 'Recurring Dreams',
    summary: 'Messages that insist until they are heard',
    readings: [
      DreamThemeReading(
        title: 'A message not yet answered',
        content:
            'Repetition usually points to an unresolved theme: the unconscious replays the scene until something changes in waking life. Small variations between versions are valuable clues',
      ),
      DreamThemeReading(
        title: 'Emotional patterns',
        content:
            'Recurring dreams often accompany patterns that repeat in relationships or choices. When the pattern changes in real life, the dream tends to change with it — or stop',
      ),
      DreamThemeReading(
        title: 'How to work with it',
        content:
            'Recording each occurrence in the Dream Diary, comparing details and talking with the dream (imagining different endings before sleep) are classic practices to unlock the repetition',
      ),
    ],
    reflection:
        'What has changed in the latest versions of the dream? The variation is the thermometer of your process',
  ),
  DreamTheme(
    id: 'fogo',
    emoji: '🔥',
    title: 'Fire',
    summary: 'Passion, anger and intense transformation',
    readings: [
      DreamThemeReading(
        title: 'Vital energy in motion',
        content:
            'Fire is the element of will and passion. Controlled flames — a candle, a welcoming bonfire — usually speak of enthusiasm, desire and creative force in good measure',
      ),
      DreamThemeReading(
        title: 'Anger and overload',
        content:
            'Out-of-control blazes can mirror hot, dammed-up emotions: swallowed anger, accumulated stress, a limit about to burst. The dream shows the size of the inner boil',
      ),
      DreamThemeReading(
        title: 'Purification by burning',
        content:
            'In many magical traditions, to burn is to transmute: what the fire consumes in the dream may point to what needs to be destroyed to become compost — a habit, a bond, a version of yourself',
      ),
    ],
    reflection:
        'Did the fire in your dream warm or destroy? Notice where that same energy appears in your waking life',
  ),
  DreamTheme(
    id: 'serpente',
    emoji: '🐍',
    title: 'Serpent',
    summary: 'Transformation, healing and vital energy',
    readings: [
      DreamThemeReading(
        title: 'Shedding skin',
        content:
            'The serpent is the great symbol of renewal: it sheds its skin in order to grow. Dreaming of snakes tends to accompany phases of deep transformation — uncomfortable, but necessary',
      ),
      DreamThemeReading(
        title: 'Healing and wisdom',
        content:
            'From the staff of Asclepius to kundalini, the serpent also represents healing and rising vital energy. A calm snake can point to personal power and awakening intuition',
      ),
      DreamThemeReading(
        title: 'Warning and betrayal',
        content:
            'In popular imagination, the hidden snake speaks of silent dangers: situations or people that ask for attention. The fear felt in the dream is the clue — dread and fascination tell different stories',
      ),
    ],
    reflection:
        'Was the serpent attacking, watching, or simply going its own way? Your reaction in the dream says as much as the symbol',
  ),
  DreamTheme(
    id: 'bebe',
    emoji: '👶',
    title: 'Baby',
    summary: 'Beginnings, vulnerability and care',
    readings: [
      DreamThemeReading(
        title: 'Something newly born',
        content:
            'A baby in a dream usually represents what has just been born in your life: a project, a relationship, a phase. The baby\'s state — healthy, crying, forgotten — mirrors how that beginning is being cared for',
      ),
      DreamThemeReading(
        title: 'The inner child',
        content:
            'The baby can also be your own most vulnerable part asking to be held: basic needs for affection, rest and comfort that adult life has run over',
      ),
      DreamThemeReading(
        title: 'A new responsibility',
        content:
            'Dreaming that you must care for a baby that is not yours can speak of newly taken-on responsibilities — and the fear of not being up to them',
      ),
    ],
    reflection:
        'What in your life is in its newborn phase right now — and what care is it receiving (or not receiving)?',
  ),
  DreamTheme(
    id: 'dinheiro',
    emoji: '💰',
    title: 'Money',
    summary: 'Self-worth, exchange and the energy of abundance',
    readings: [
      DreamThemeReading(
        title: 'Your own worth',
        content:
            'Money in a dream is rarely just money: finding coins or bills usually speaks of inner resources discovered — talents, time, energy — and of how valuable you feel',
      ),
      DreamThemeReading(
        title: 'Loss and fear of lack',
        content:
            'Losing money, being robbed or being unable to pay for something can mirror real material insecurity or the feeling of spending energy on what gives nothing back',
      ),
      DreamThemeReading(
        title: 'The flow of exchange',
        content:
            'In the magical reading, money is a symbol of flow: what you give and what you receive. Dreams of abundance may confirm that the flow is open — or compensate for a tight phase',
      ),
    ],
    reflection:
        'In the dream, was the money arriving or slipping away? Compare it with what you have been giving and receiving — in every currency, not just the financial one',
  ),
  DreamTheme(
    id: 'nudez',
    emoji: '🙈',
    title: 'Naked in Public',
    summary: 'Exposure, shame and authenticity',
    readings: [
      DreamThemeReading(
        title: 'Fear of being truly seen',
        content:
            'Being naked in public is the classic exposure dream: it tends to appear when something intimate — a mistake, a feeling, a personal project — is about to become visible, and there is fear of judgment',
      ),
      DreamThemeReading(
        title: 'A shame that is only yours',
        content:
            'A revealing detail: in many of these dreams, nobody notices the nudity. The unconscious suggests the shame is bigger on the inside than in other people\'s eyes',
      ),
      DreamThemeReading(
        title: 'An invitation to authenticity',
        content:
            'In more luminous readings, nudity speaks of showing yourself without masks. Feeling free in the dream, even naked, can point to a phase of acceptance and truth with yourself',
      ),
    ],
    reflection:
        'What do you fear others might discover about you — and what would truly happen if they did?',
  ),
  DreamTheme(
    id: 'provas-atrasos',
    emoji: '⏰',
    title: 'Exams and Running Late',
    summary: 'Pressure, preparation and fear of falling short',
    readings: [
      DreamThemeReading(
        title: 'A feeling of being unprepared',
        content:
            'Arriving late, missing the flight, taking an exam without having studied: they are variations on the same theme — the feeling that life demands more than you managed to prepare',
      ),
      DreamThemeReading(
        title: 'Excessive self-demand',
        content:
            'Curiously, this dream is common among very responsible people. The "exam" is the inner tribunal: a bar set too high for yourself, not a real evaluation',
      ),
      DreamThemeReading(
        title: 'Reviewing priorities',
        content:
            'Running late can also mean you are chasing a schedule that is not your own — deadlines and milestones set by other people. Perhaps the dream\'s clock should not rule your life',
      ),
    ],
    reflection:
        'What exam do you feel you are taking in real life right now — and who scheduled that exam?',
  ),
  DreamTheme(
    id: 'traicao',
    emoji: '💔',
    title: 'Betrayal',
    summary: 'Trust, insecurity and loyalty to yourself',
    readings: [
      DreamThemeReading(
        title: 'Insecurity, not prophecy',
        content:
            'Dreaming of a partner\'s betrayal rarely exposes a fact: it usually mirrors insecurity in the bond, a longing for attention or old wounds of trust asking for care',
      ),
      DreamThemeReading(
        title: 'Betraying yourself',
        content:
            'It is worth turning the mirror around: in what area have you been betraying yourself — swallowing what you feel, postponing what matters, saying yes when it was no? The dream borrows another person\'s face for an inner pain',
      ),
      DreamThemeReading(
        title: 'Broken expectations',
        content:
            'Being betrayed by friends or colleagues in the dream can speak of unspoken expectations: agreements that only existed in your head, which the other person never knew they had signed',
      ),
    ],
    reflection:
        'Does the dream\'s pain point to the other person, or to an agreement you made on your own? Talking undoes half of these plots',
  ),
  DreamTheme(
    id: 'espelho',
    emoji: '🪞',
    title: 'Mirror',
    summary: 'Identity, self-image and inner truth',
    readings: [
      DreamThemeReading(
        title: 'Meeting your own image',
        content:
            'The mirror confronts: seeing yourself different, older, younger or unrecognizable tends to accompany phases of identity change — when the inner image has not yet caught up with the new life',
      ),
      DreamThemeReading(
        title: 'What the reflection hides',
        content:
            'Empty, fogged or broken mirrors can speak of disconnection from yourself: tiredness of performing, difficulty knowing what you want and what you feel',
      ),
      DreamThemeReading(
        title: 'Portal and divination',
        content:
            'In witchcraft, the mirror is a tool of scrying and a symbolic portal. Passing through it or seeing another scene reflected can point to sharpened intuition and an invitation to look beyond the surface',
      ),
    ],
    reflection:
        'If you looked in the mirror right now, on the inside: would the image you see match the life you are living?',
  ),
];
