import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Trail 'magia_branca' — English content.
/// Parity with _pt/_es verified in test/trails_parity_test.dart.
const LearningTrail magiaBrancaTrailEn = LearningTrail(
    id: 'magia_branca',
    emoji: '🕯️',
    title: 'White Magic',
    subtitle: 'Light, protection, and blessings',
    description:
        'The path of luminous intention: protection, healing, and blessings for yourself and those you love. Ten lessons, ten pages written by you',
    lessons: [
      TrailLesson(
        id: 'mb_01',
        recordKind: LessonRecordKind.note,
        title: 'Intention is the heart',
        teaching:
            'All magic begins before the candle, the crystal, or the spoken word: it begins with intention. Intention is the heart of any working because it directs the energy you set in motion. In white magic, an intention is phrased clearly, positively, and in the present tense — instead of saying you want to stop being afraid, you affirm that you walk protected and confident. That clarity is what turns a vague wish into a magical act\n\nA good intention bears three marks: it is specific, it is yours — it never tries to control anyone else\'s will — and it is spoken as if it were already real. This structure appears across many traditions, from ancient prayers to modern affirmations, because the mind responds best to concrete, present-tense images. Experienced practitioners spend more time polishing the phrase than arranging the altar, for they know the right words carry the entire working\n\nIn a beginner witch\'s daily life, intention comes before everything else: before lighting a candle, drawing a bath, or opening the notebook. A common mistake is cramming several requests into one sentence, or using negations, which keep the focus on the problem. Another is phrasing in a hurry. Set aside a few minutes, write it down, read it aloud, and notice whether your body responds: a living intention usually brings a subtle shiver of recognition\n\nCarry this idea with you: magic begins in the phrase you choose. Before any tool, polish your intention until it is clear, yours, and present. When the words are right, everything else in the ritual simply follows along — the candle illuminates, the gesture seals, but what truly leads is the heart that knew how to say what it desires',
        practice:
            'In this practice you will polish an intention that matters to you. First, write three different versions of the same intention on paper. Then revise each one, cutting out negations, promises for a distant future, and wishes about other people. Finally, read all three aloud and choose the one that feels most alive in your body. The goal is to train the clarity that sustains all white magic: a phrase that is specific, yours, and spoken in the present',
        pageTitle: 'My Intention of Light',
        pagePurpose: 'Craft and consecrate a clear intention',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['1 white candle', 'Paper and pen'],
        pagePrompts: [
          'The final version of my intention (clear, mine, in the present):',
          'Why does this intention matter to me right now?',
          'How will I know it has come true?',
          'What did I feel reading it aloud before the candle?',
        ],
      ),
      TrailLesson(
        id: 'mb_02',
        title: 'The circle of protection',
        teaching:
            'The circle is magic\'s oldest technology: a symbolic boundary separating sacred space from the everyday. It matters because the mind needs borders in order to shift states — by casting the circle, you signal to yourself that within it, in that moment, everything is different. It is the frame that protects and concentrates any working of white magic\n\nTraditions across the world cast circles: with salt, chalk, cord, a pointed finger, or pure visualization. The material matters far less than the conscious gesture. In many lineages, you walk sunwise to open and counter-sunwise to release. And what is opened must be closed: ending the circle with thanks is as important as casting it, for it returns the space to ordinary life without leaving doors ajar\n\nDay to day, a beginner can cast a circle before meditating, writing in the grimoire, or lighting a candle. You don\'t need much room: an imagined circle around your chair already works. Common mistakes: stepping out of the circle mid-working without need, and forgetting to release it at the end. Start simple, with salt or visualization, and repeat until the gesture becomes body memory\n\nKeep this key: the circle is a gesture of awareness, not of materials. Wherever you trace a boundary with presence, sacred space is born — and wherever you release it with gratitude, ordinary life returns in peace. Open and close, always in that order: this is the quiet rhythm of all protection done well',
        practice:
            'In this practice you will create your first sacred space. First, cast a circle around yourself — with salt, a gesture, or pure visualization. Then remain in silence within it for three minutes, simply noticing the difference in the air and in your body. Finally, release the circle consciously, giving thanks. The goal is to feel firsthand that opening and closing a boundary changes your inner state — the foundation of all magical protection',
        pageTitle: 'My Circle of Protection',
        pagePurpose: 'Create and release a sacred space',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['Coarse salt (optional)', 'White candle (optional)'],
        pagePrompts: [
          'How I cast my circle (material or visualization):',
          'My words upon opening:',
          'My words upon closing:',
          'The difference I felt between inside and outside:',
        ],
      ),
      TrailLesson(
        id: 'mb_03',
        title: 'Blessings: magic for others',
        teaching:
            'The blessing is white magic\'s most generous form: actively wishing someone well without controlling anyone\'s path. It matters because it changes the direction of your practice — instead of asking for yourself, you radiate outward. Blessing trains the heart in abundance and reminds you that magic is also service, not only personal gain\n\nThe classic structure of a blessing has three steps: name who receives it, declare the good you wish for them, and seal it with a gesture — hands over the heart, a breath, a touch on water. Entire cultures have organized themselves around blessings: over food, homes, journeys, and births. One golden rule runs through them all: bless without expecting return, and never to sway someone\'s decisions — that would already be something else\n\nIn everyday life, a blessing fits anywhere: a kind thought when passing a neighbor, a silent word over a meal, a wish for peace when entering your home. The beginner\'s most common mistake is disguising a bid for control as a blessing — wishing that someone would make a certain decision, for instance. Bless the person as they are today, not as you would like them to be\n\nCarry this idea in your pocket: to bless is to wish well and release the outcome. When you bless without controlling, the energy flows clean and returns as lightness. A heart that blesses every day never practices small magic — it turns every encounter into a quiet altar',
        practice:
            'In this practice you will offer your first conscious blessing. First, choose someone dear to you and bring their face to mind. Then, for one full minute, silently wish them well — exactly as they are today, correcting nothing, asking for no changes. Finally, seal it with a simple gesture, such as a hand over your heart. The goal is to experience magic that flows outward: wishing well without controlling anyone\'s path',
        pageTitle: 'Blessing of My Home',
        pagePurpose: 'Bless the home and those who live in it',
        pageCategory: SpellCategory.home,
        pageIngredients: ['1 glass of clean water', 'White candle'],
        pagePrompts: [
          'The blessing I created for my home:',
          'The gesture that seals my blessing:',
          'Room by room: where did I feel the energy shift?',
          'What did I feel when blessing instead of asking?',
        ],
      ),
      TrailLesson(
        id: 'mb_04',
        tool: LessonTool.addColor,
        title: 'The candle: flame and focus',
        teaching:
            'The candle is white magic\'s portable altar: fire that concentrates intention into a single point of light. It matters because it gathers great power into a simple object — wax that comes from the earth, a wick that breathes the air, and a flame that transforms. Few tools offer so much focus with so little, which is why the candle is usually a witch\'s first companion\n\nEvery detail speaks to your goal. The candle\'s color converses with the intention — consult the Color Encyclopedia to choose consciously. Anointing the candle with oil is dressing it for the work, and carving symbols into the wax engraves the request in matter before handing it to the flame. Candle traditions exist in nearly every devotional practice: the flame has always been seen as a messenger between worlds\n\nFor the beginner, the candle is the most accessible ritual: light it with a clear intention, watch the flame, extinguish it with gratitude. Common mistakes: rushing to ask without preparing the intention, and carelessness with fire. Safety is part of the ritual: a lit candle is never left alone, always kept away from curtains and on a steady surface. Start with the white candle, which serves every luminous purpose\n\nMemorize this key: the flame is your focus made visible. When you light a candle with presence, it holds the intention as it burns. Care for the fire as you care for the desire — with attention, respect, and constancy — and the candle will always be a complete altar that fits in the palm of your hand',
        practice:
            'In this practice you will train presence before the fire. First, prepare a safe spot and light a white candle. Then, for ten minutes, simply watch the flame — its movement, its color, its dance — asking for absolutely nothing. Finally, extinguish it with gratitude or let it burn down safely. The goal is to build intimacy with the tool before using it: whoever learns to contemplate the flame learns to focus their own intention. Take the chance to record the chosen color: photograph it through the shortcut below and create its entry in your Color encyclopedia',
        pageTitle: 'My Candle Ritual',
        pagePurpose: 'Structure my work with candles',
        pageCategory: SpellCategory.energy,
        pageIngredients: ['Candle in the chosen color', 'Oil (optional)', 'Stick for carving'],
        pagePrompts: [
          'Chosen color and why (did I consult the Encyclopedia?):',
          'How I prepare the candle (anointing, symbols):',
          'What the flame "told" me during the 10 minutes of watching:',
          'My personal safety rules:',
        ],
      ),
      TrailLesson(
        id: 'mb_05',
        title: 'Lustral water: cleansing that consecrates',
        teaching:
            'Water and salt form the oldest purifying pair humanity knows. Lustral water is the consecrated version of that duo: a simple preparation that cleanses objects, spaces, and your own energy before any working. It matters because all magic asks for clean ground — working in a heavy atmosphere is like planting in tired soil\n\nThe preparation is a ritual in itself: clean water, a pinch of salt, your hands resting over the vessel, and a word of consecration spoken with presence. Ancient temples kept basins of water at their entrances to purify those who arrived — the logic is the same. Salt dissolves and water carries: together they break down what weighs and wash away what no longer serves\n\nIn daily life, lustral water is sprinkled into the corners of the home, touched to the forehead and wrists before a ritual, or used to wash newly arrived tools. Keep it in a beautiful vessel and renew it often — water left standing for many weeks loses its vitality. Two essential cautions: never drink lustral water, and never skip the consecration, for without the word it is only salted water\n\nThe key of this lesson: to cleanse is to prepare. Before asking, purify; before planting, tend the soil. A witch who keeps her lustral water alive also keeps the practice\'s most important habit — beginning every working on ground that is clear, light, and ready to receive',
        practice:
            'In this practice you will prepare your first lustral water. First, choose a beautiful vessel, fill it with clean water, and add a pinch of salt. Then rest your hands over it and speak a word of consecration with presence. Finally, use this water to cleanse an object you use every day, wiping a few drops over it with intention. The goal is to feel how purification prepares the ground for all magic',
        pageTitle: 'My Lustral Water',
        pagePurpose: 'Prepare and use cleansing water',
        pageCategory: SpellCategory.cleansing,
        pageIngredients: ['Clean water', 'Salt', 'A beautiful vessel'],
        pagePrompts: [
          'My words of consecration for the water:',
          'The object I cleansed first and why:',
          'Where I keep my lustral water:',
          'When I intend to renew it:',
        ],
      ),
      TrailLesson(
        id: 'mb_06',
        title: 'Shields: everyday protection',
        teaching:
            'Not every day holds an altar — but every day holds the world. The energy shield is the witch\'s portable protection: an invisible barrier created by the trained imagination, filtering what reaches you from outside. It matters because the sensitivity your practice awakens also calls for defense — whoever feels more must learn to guard themselves more\n\nThe shield works through repeated visualization: a sphere of light around the body, a cloak that wraps you, mirrors returning what is not yours. Every tradition has its favorite image, but the principle is the same — a trained mind creates energetic boundaries that are real to the one who inhabits them. The trigger gesture, discreet and always the same, is the switch that activates it all in seconds\n\nIn everyday life, the shield comes up before leaving home, in tense meetings, on crowded transit. The secret is training: a shield is built at home, calmly and through repetition, so it holds on the packed bus. The beginner\'s classic mistake is trying to create the protection for the first time in the middle of a crisis — without prior training, the image will not hold. Practice a little every day\n\nEngrave this idea: protection is a habit, not an emergency. A few minutes of daily visualization create a shield that answers your gesture anywhere. The protected witch is not the one who never meets heaviness in the world — she is the one who knows how to return quickly to her own light',
        practice:
            'In this practice you will build your personal shield. First, sit in a quiet place and visualize for five minutes a sphere of light enveloping your whole body — notice its color, its glow, its texture. Then choose a discreet gesture, like touching a ring or crossing your fingers, and repeat it while the image is vivid. The goal is to link gesture and shield, creating a trigger that activates your protection in seconds, wherever you are',
        pageTitle: 'My Daily Shield',
        pagePurpose: 'Create my portable protection',
        pageCategory: SpellCategory.protection,
        pagePrompts: [
          'What my shield is like (shape, color, texture):',
          'My trigger gesture:',
          'Situations where I need it most:',
          'First time I used it "in the field" — did it work?',
        ],
      ),
      TrailLesson(
        id: 'mb_07',
        title: 'Self-healing: the ritual bath',
        teaching:
            'The ritual bath turns the most ordinary act into a rite of healing: warm water, herbs or salt, low light, and intention. It matters because it joins the body to magic — the skin feels, the steam surrounds, and the mind understands, effortlessly, that something is being washed on the inside too. It is white magic\'s most accessible healing: you already bathe every day\n\nTradition distinguishes directions: from the neck down, the bath cleanses and discharges, sparing the head, seat of consciousness; from the head down, only with gentle herbs, it renews completely. Herbal baths cross cultures — from healing houses to ancient villages — always with the same grammar: prepare with intention, pour with presence, and let the body dry naturally when possible\n\nIn a beginner\'s routine, the ritual bath can close the week or precede important workings. Prepare everything beforehand: herb or salt, a candle lit in a safe spot in the bathroom, phone far away. Common mistakes: rushing, bathing on autopilot, and using herbs too strong without knowledge. Start simple — coarse salt or chamomile — and grow slowly, noting what works\n\nCarry this key: what matters is leaving the bath different from how you entered — and naming that difference. Running water carries away what weighs; guiding intention calls in what renews. With presence, your shower can become the most faithful and constant temple of your entire practice',
        practice:
            'In this practice you will turn today\'s bath into a ritual. First, leave your phone outside the bathroom and, if you like, light a candle in a safe spot. Then bathe without any hurry, visualizing the water carrying away everything that weighs — worries, tiredness, remnants of the day. Finally, as you turn off the shower, breathe deeply and silently name how you feel. The goal is to experience the simplest healing there is: water, presence, and intention',
        pageTitle: 'My Healing Bath',
        pagePurpose: 'Create my ritual bath recipe',
        pageCategory: SpellCategory.healing,
        pageIngredients: ['Gentle herbs or coarse salt', 'Candle for the bathroom'],
        pagePrompts: [
          'My recipe (herbs/salt, preparation):',
          'What the water carries away:',
          'What I call in for myself at the end:',
          'How I felt afterward:',
        ],
      ),
      TrailLesson(
        id: 'mb_08',
        tool: LessonTool.addCrystal,
        title: 'Amulets of light',
        teaching:
            'The amulet is intention condensed into matter: a small object, consecrated to a single purpose and carried close to the body. It matters because it extends magic beyond the ritual — while you live your day, the amulet keeps working in silence, reminding your energy of what was agreed before the altar\n\nIn white magic, the classics are amulets of protection — the eye, salt, rue — and of blessing, such as medals and light-colored stones. Consecration follows four simple steps: cleanse the object, declare its purpose aloud, charge it under moonlight, near a flame, or with your own breath, and carry it with faith. Peoples of every era have carried amulets: taking protection with you is a desire as old as the road itself\n\nFor the beginner, the best amulet is usually an object that already has history with you — an inherited ring, a found stone, a beloved medal. Common mistakes: piling several purposes onto one object, which dilutes its strength, and forgetting to cleanse it from time to time. One purpose per amulet and an occasional cleansing, and it will serve you for years\n\nAn idea to keep: the amulet is a silent pact between you and an object. Consecrate it with clarity, carry it with faith, and renew it with care, and it will answer with constancy. That way, even on days without altar or candle, a piece of your magic walks beside your body, wherever you go',
        practice:
            'In this practice you will choose your first amulet of light. First, look around and find a small object you already love, one with history between you. Then hold it in your hands and silently ask yourself what single purpose it will serve — protection or blessing. Finally, keep it in a special place until you record its consecration on your page. The goal is to understand that an amulet\'s power is born of the bond: one object, one purpose, one faith. If your amulet is a stone, photograph it through the shortcut below and create its entry in your Crystal encyclopedia',
        pageTitle: 'My Amulet of Light',
        pagePurpose: 'Consecrate a personal amulet',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['The chosen object'],
        pagePrompts: [
          'My object and its history with me:',
          'Its single purpose:',
          'How I consecrated it (cleansing, words, charging):',
          'Where it lives (pocket, chain, bag):',
        ],
      ),
      TrailLesson(
        id: 'mb_09',
        title: 'Magic for hard times',
        teaching:
            'White magic shines on dark days: a funeral, a diagnosis, a breakup. In those moments it does not solve — it accompanies. And that matters because a practice that only serves the good days abandons the witch exactly when she needs it most. A rite of passage gives you ground when the ground seems to vanish beneath your feet\n\nThe minimal rite for crossing through has four gestures: light a flame, name the pain aloud, ask for strength — not solutions — and give thanks for being alive to feel. Rites of passage exist in every human culture precisely because pain needs form: once it gains a name, a candle, and a word, it stops being a shoreless sea and becomes a river that can be crossed\n\nIn everyday terms, this means having your rite ready before the storm: three simple steps your body knows by heart. The most common mistake is demanding from magic what it does not promise — erasing the pain, bringing someone back, changing the diagnosis. If the pain is too great, seek human and professional support as well: mature magic walks alongside care, never in its place\n\nKeep this wisdom: mature magic knows the difference between transforming and accepting. On dark days, light the flame, name the pain, and ask for strength to cross through. You do not need to conquer the whole night at once — you only need enough light to take the next step',
        practice:
            'In this practice you will try a rite of crossing. First, think of a present or old pain that still deserves tending. Then light a white candle in a safe spot and, watching the flame, say aloud: I see you, I cross through you, I ask for strength. Finally, stay a few moments in silence and give thanks for being alive to feel. The goal is to give the pain form with a name, a flame, and a word, asking for strength instead of solutions',
        pageTitle: 'Ritual for Dark Days',
        pagePurpose: 'Create my rite of crossing',
        pageCategory: SpellCategory.healing,
        pageIngredients: ['White candle'],
        pagePrompts: [
          'My minimal rite for hard days (3 steps):',
          'The words that give me ground:',
          'Whom/what I ask for strength:',
          'What this rite does NOT promise (and that is okay):',
        ],
      ),
      TrailLesson(
        id: 'mb_10',
        recordKind: LessonRecordKind.gratitude,
        title: 'Closing with gratitude',
        teaching:
            'Every working of white magic ends in the same place: gratitude. Giving thanks closes the circuit of energy, acknowledging what was received even before seeing results. It matters because a well-made ending protects the entire working — a ritual without closure is a door left ajar, and gratitude is the key that turns smoothly in the lock\n\nGratitude is also the practice\'s most underrated protection: a grateful heart does not operate from lack, and magic made from lack tends to attract more lack. Traditions the world over close their rites by giving thanks — to the forces invoked, to the space, to the body itself. Thanks returns each thing to its place and seals what was done, like signing a letter before sending it\n\nIn daily life, the closing becomes a personal signature: a gesture always the same, a short phrase of gratitude, a breath over the candle. Repeated at the end of every working, it teaches the body that the rite is over. The common mistake is rushing away from the altar as soon as the request is made — give the ending the same care you gave the beginning. On this final page, you create your closing ritual\n\nTake with you the last key of this trail: gratitude is the beginning and end of all white magic. Give thanks before seeing, give thanks after receiving, give thanks even on days that held only crossing. Whoever closes with gratitude never leaves a ritual empty-handed — that is your magical signature',
        practice:
            'In this practice you will close the trail as one closes a ceremony. First, breathe deeply and look back, recalling the lessons you have crossed. Then list five things your practice has already brought into your life — small or large, they all count. Finally, read the list aloud, slowly, like the final words of a rite. The goal is to close the circuit of energy with gratitude, sealing everything you have built so far',
        pageTitle: 'My Closing Ritual',
        pagePurpose: 'Seal workings with gratitude',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'My closing gesture:',
          'My words of gratitude:',
          'The 5 things my practice has already brought me:',
          'Rereading this trail: what has become "my way"?',
        ],
      ),
    ],
  );
