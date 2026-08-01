import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Trail 'magia_do_caos' — English content.
/// Parity with _pt/_es checked in test/trails_parity_test.dart.
const LearningTrail magiaDoCaosTrailEn = LearningTrail(
    id: 'magia_do_caos',
    emoji: '🌀',
    title: 'Chaos Magic',
    subtitle: 'Nothing is true, everything is permitted to create',
    description:
        'Magic as experimental technology: belief as a tool, sigils, measurable results, and zero dogma. You are the laboratory',
    lessons: [
      TrailLesson(
        id: 'mc_01',
        recordKind: LessonRecordKind.note,
        title: 'Belief as a tool',
        teaching:
            'The central axiom of chaos magic states that belief is not the truth: it is the instrument. If believing something produces the desired result, the practitioner puts that belief on like a coat, works with it, and then hangs it up. This shift matters because it hands the power back to you: instead of waiting to find the perfect faith, you learn to choose and operate beliefs on purpose\n\nThis is not cynicism: it is taking belief so seriously that you use it deliberately. Chaos magic was born in the postmodern spirit, heir to Austin Osman Spare, and treats every system as a useful map, never as the territory. One day you operate as an animist, the next as a methodical skeptic: what counts is the effect each lens produces on your perception and your results\n\nIn a beginner\'s daily life, this becomes an experiment: adopting a chosen belief for a period and observing what changes in decisions, posture, and opportunities. Prefer useful, testable beliefs, one at a time, and note the effects. The common mistake is the lukewarm middle ground: half-believing generates no data. Wear the belief fully during the test and take it off fully afterward\n\nCarry the image of the coat with you: beliefs are work garments, not tattoos. You can swap them according to the task, without guilt and without losing yourself, because the one choosing is you. Welcome to the laboratory: here, believing is a technique — and every technique is learned with practice and patience',
        practice:
            'You will test belief as a tool. First, choose a useful, affirmative, testable belief, such as: people like to help me. Then, live 24 hours as if it were absolutely true, acting in full coherence with it. Finally, note what changed in you and around you. The goal is to feel firsthand that a belief worn on purpose alters perception, attitude, and results',
        pageTitle: 'Experiment: 7-Day Belief',
        pagePurpose: 'Test belief as a tool',
        pageCategory: SpellCategory.other,
        pagePrompts: [
          'The adopted belief (affirmative, testable):',
          'Success criterion (how I know it worked):',
          '7-day journal (one line per day):',
          'Verdict of the experiment:',
        ],
      ),
      TrailLesson(
        id: 'mc_02',
        recordKind: LessonRecordKind.sigil,
        title: 'Sigils: the encrypted desire',
        teaching:
            'The sigil is the encrypted desire: a symbol that carries your intention without the conscious mind being able to read it. Created by Austin Osman Spare, the method turns a sentence of desire into an abstract glyph. It matters because it solves magic\'s greatest saboteur: the anxiety of watching for the result and, without meaning to, pushing it away\n\nSpare\'s process has three acts: write the desire, remove the repeated letters, and merge the remaining ones into a single drawing. Then comes the decisive step: launching the glyph into the unconscious through an altered state, gnosis — exhaustion, dance, a fixed gaze — and then forgetting. Forgetting is no small detail: the anxious mind sabotages, while the unconscious, free of surveillance, works in silence\n\nFor the beginner, the practical challenge is phrasing the desire: affirmative sentences, in the present tense, without negations. The app\'s Sigils tool builds the glyph for you, which frees your energy for what matters: the launching and the forgetting. The most common mistake is revisiting the sigil constantly to check whether it worked. Launched, forgotten: truly distract yourself and let the seed germinate in the dark\n\nKeep this key: the sigil works to the extent that you let go. Desire, encrypt, launch, forget — four simple gestures that train magic\'s hardest art, which is trusting what cannot be seen. Your unconscious is a competent ally: hand over the request and get out of its way',
        practice:
            'You will create and launch your first sigil. Open the app\'s tool under Tools, choose Sigils, and write your desire as an affirmative sentence: the glyph will be generated for you. Before activating, define your gnosis method, such as dancing to exhaustion or gazing fixedly at a candle. Activate the sigil in that state, then destroy or store the drawing and distract yourself. The goal is to complete the whole cycle: desire, encrypt, launch, and forget',
        pageTitle: 'My First Launched Sigil',
        pagePurpose: 'Record the complete sigilization method',
        pageCategory: SpellCategory.other,
        pagePrompts: [
          'Desire sentence (write it and cross it out afterward!):',
          'Gnosis method used:',
          'How I destroyed/forgot the sigil:',
          '(In 1 month) Observed results:',
        ],
      ),
      TrailLesson(
        id: 'mc_03',
        recordKind: LessonRecordKind.note,
        title: 'Gnosis: the portals of trance',
        teaching:
            'Gnosis is the state in which the critical mind falls silent and the magical command passes straight to the depths of the psyche. It is the moment of openness every operation needs: without it, the intention stays stuck in the chattering layer of thought. Knowing your own paths to this state is basic magical infrastructure, as essential as the very desire you want to launch\n\nThe chaote tradition divides the portals into two routes. The excitatory one rises: dance, drumming, light hyperventilation, climax — the body accelerates until the mind lets go of the helm. The inhibitory one descends: stillness, short fasting, a fixed gaze, absolute silence — the world slows down until only the focus remains. Neither route is superior; each person has their natural portals, and discovering them is a work of personal mapping\n\nStart with what your body already knows: those who dance easily lean toward the excitatory route; those who meditate, toward the inhibitory. Test in short sessions, safely and without substances — the body already has everything it needs. The common mistake is forcing intensity: gnosis is not fainting, it is the instant when the world sharpens. Record every test and always respect your physical limits\n\nTake the idea of the portal with you: gnosis is not a distant place, it is a door your own body knows how to open. With practice, you learn to reach it in a few minutes, and every magical operation gains depth. Mapping your altered states is knowing the key to your own house',
        practice:
            'You will test an inhibitory portal today. Light a candle in a calm room, sit comfortably, and hold a fixed gaze on the flame for 5 minutes, without straining your eyelids, letting your breathing slow down. Notice the moment when the world seems to sharpen and thoughts space out. When you finish, note the sensations. The goal is to recognize in the body the taste of gnosis so you can use it later in your operations',
        pageTitle: 'My Gnosis Map',
        pagePurpose: 'Map my safe altered states',
        pageCategory: SpellCategory.energy,
        pagePrompts: [
          'Excitatory methods that work on me:',
          'Inhibitory methods that work on me:',
          'My safety limits:',
          'The portal I will master first:',
        ],
      ),
      TrailLesson(
        id: 'mc_04',
        recordKind: LessonRecordKind.note,
        title: 'The results diary',
        teaching:
            'The results diary is what separates the chaote from the armchair mystic: a faithful record of every operation with date, technique, state, and outcome. Without it, memory cheats — every success is remembered, every failure conveniently forgotten — and you learn nothing. With it, your magic becomes a real laboratory, with a history and visible evolution\n\nChaos magic defines itself as experimental technology, and an experiment without data does not exist. Recording turns vague impressions into visible patterns: which technique yields more, in which state you operate best, how long the effects take. It is the same spirit that guided Spare and the modern chaotes: measurable results above beautiful theories, zero dogma, and constant revision\n\nIn practice, create a short template and always use it: date, operation, technique, inner state, result, and a confidence note. Review in fixed cycles, weekly or lunar. The classic mistake is recording only when it works, or dressing up failure with excuses. Be merciless with self-delusion and gentle with the process: failure is precious data, not shame\n\nKeep this maxim: what is not recorded is not learned. Your diary is the most powerful instrument in the laboratory, because it turns every attempt — good or bad — into a step. Today\'s honesty on paper becomes tomorrow\'s mastery in practice, and no one can do that work for you',
        practice:
            'You will audit your experiments so far. Reread the records from the previous lessons — the 24-hour belief, the sigil, the gnosis tests — and evaluate each one with brutal honesty: what actually worked, what was coincidence, what was confirmation bias. Then, build your fixed recording template for the next operations. The goal is to found your results diary on clean data, not on wishes',
        pageTitle: 'My Recording Protocol',
        pagePurpose: 'Systematize the results diary',
        pageCategory: SpellCategory.study,
        pagePrompts: [
          'What I record in every operation (my template):',
          'When I review (weekly? lunar?):',
          'My results scale:',
          'First review: lessons learned:',
        ],
      ),
      TrailLesson(
        id: 'mc_05',
        title: 'Servitors: creatures of purpose',
        teaching:
            'The servitor is a psychic program: an entity created by you to fulfill a single function, such as reminding, protecting, or finding. Unlike spirits inherited from traditions, it is born from your conscious design. The technique matters because it teaches, on a small and safe scale, how attention gives life and form to the constructions of the mind\n\nThe construction follows a clear recipe: the servitor receives a name, a visual form, a single well-delimited function, a symbolic food — daily attention, a gesture, a symbol — and, crucially, a shutdown date. In the chaote view, it matters little whether it is a real being or a psychological mechanism: if it fulfills the function and responds to the protocol, it is technology working\n\nFor the beginner, the secret is modesty: a servitor for one concrete task of the week, not a cosmic guardian. Write the function in one sentence; if you need two, that is two servitors. Feed it at the agreed time and observe. The common mistake is creating and abandoning: a forgotten entity becomes noise. Treat it as responsible creation, with maintenance and a dignified retirement\n\nTake this image with you: the servitor is an app you install in your own psyche — clear purpose, defined consumption, expiration date. Creating, maintaining, and shutting down with respect is a complete cycle of magical responsibility. Start small and learn the craft of giving form to the invisible',
        practice:
            'You will design your first servitor. Choose a concrete task for this week, such as remembering to drink water. Sketch the creature in drawing or text: define its name, form, the single function in one sentence, the symbolic food, and the exact shutdown date. Introduce it mentally to the task and feed it once a day. The goal is to experience the complete cycle of creating, maintaining, and shutting down an entity of purpose',
        pageTitle: 'My First Servitor',
        pagePurpose: 'Create a single-purpose entity',
        pageCategory: SpellCategory.other,
        pagePrompts: [
          'Name, form, and SINGLE function:',
          'How I feed it (attention, gesture, symbol):',
          'Shutdown date and rite:',
          'Results of the first week:',
        ],
      ),
      TrailLesson(
        id: 'mc_06',
        recordKind: LessonRecordKind.rune,
        title: 'Paradigm shifting',
        teaching:
            'Paradigm shifting is the king exercise of chaos magic: living an entire period inside another belief system — one week as an animist, another as a radical skeptic, another as a devotee. It is not about mocking or pretending on the outside: it is about experiencing the system from within, with the rules, the eyes, and the gestures of someone who truly believes\n\nThe practice comes from chaos\'s postmodern stance: every paradigm is a map, and maps are swapped according to the journey. By inhabiting a foreign system, you discover what it reveals and what it hides. A concrete example: spending three days reading the world through the Norse runes, consulting them in the day\'s decisions, even if your usual path is another. Immersion generates data that reading from the outside would never give\n\nFor the beginner, the safe format is short and delimited: choose the paradigm, write your immersion rules, define a beginning and an end, and record daily what changes in your perception. The common mistake is half-immersion, visiting the system like a hurried tourist. Another is forgetting the exit: when the period ends, close it clearly and return to your center\n\nThe prize of this exercise is flexibility: whoever has lived in several houses of belief never again mistakes the furniture for the world. Each paradigm visited leaves a tool in your luggage and loosens the illusion that there is a single right way of seeing. Travel with curiosity, learn, and come back freer',
        practice:
            'You will live 3 days in a paradigm different from your own — for example, that of the Norse runes. Define your immersion rules, open the app\'s Runes tool under Tools, and draw one rune per day, letting the reading guide small decisions. Record each night what changed in your perception. At the end, close the immersion clearly. The goal is to experience another system from within and gain flexibility of belief',
        pageTitle: 'Paradigm Shift Report',
        pagePurpose: 'Experience another system from within',
        pageCategory: SpellCategory.study,
        pagePrompts: [
          'The paradigm visited and my immersion rules:',
          'Journal of the days (what changed in perception):',
          'What I bring back with me:',
          'What I learned about MY paradigm:',
        ],
      ),
      TrailLesson(
        id: 'mc_07',
        recordKind: LessonRecordKind.desire,
        title: 'Results magic: operational goals',
        teaching:
            'Results magic is the pragmatic heart of chaos: magic in the service of real goals, with a specific target, a defined deadline, and a chosen technique. No vague requests to the universe: a well-designed operation looks more like a project than a prayer. This matters because it takes magic out of the terrain of fantasy and places it in that of verifiable effects\n\nThe chaote trademark is the paired mundane action: every magical working comes accompanied by concrete moves in the world. The job spell walks alongside sent resumes; the health sigil, alongside the booked appointment. The logic is two-way: magic opens paths and sharpens perception, while action ensures there is a door where the path leads. Magic without action is a lottery; action without magic is half the arsenal\n\nDay to day, design small, measurable operations: a 30-day goal, one technique, three mundane actions, and a clear success criterion. Note everything in the results diary. The common mistakes are nebulous goals like wanting to prosper in general, endless deadlines, and the temptation to wait for the spell to act alone while nothing moves in practical life\n\nEngrave this formula: clear target, real deadline, chosen technique, and paired action in the world. When magic and movement walk together, every result — wherever it comes from — is your achievement. You stop asking the universe for permission and start negotiating with it as an equal, using both hands',
        practice:
            'You will design a complete 30-day operation. Choose a real, specific goal, with a deadline. Then define the magical technique — a sigil, a servitor, whatever your diary approves — and list 3 paired mundane actions you will take in the same period. Record everything and mark the evaluation date. The goal is to live the chaote formula in full: magic and action working together for a measurable result',
        pageTitle: '30-Day Operation',
        pagePurpose: 'Pair magic and action for a goal',
        pageCategory: SpellCategory.prosperity,
        pagePrompts: [
          'Specific goal and deadline:',
          'Chosen magical technique:',
          'My 3 paired mundane actions:',
          '(At the deadline) Result and analysis:',
        ],
      ),
      TrailLesson(
        id: 'mc_08',
        title: 'Undoing: the chaote banishing',
        teaching:
            'Banishing is the cleaning of the laboratory: the technique that clears residue between operations, undoes workings that did not serve, and returns the inner space to a neutral state. Without it, remnants of intention, anxiety, and charged images accumulate from one rite to the next. Closing well is as important as starting well — perhaps even more\n\nThe chaote tradition cultivates everything from banishing laughter — laughing at your own operation until it dissolves completely — to adapted versions of the ritual pentagram. Laughter works because it breaks the gravity: nothing resists a good burst of laughter, not even your own solemnity. But the chaote criterion is a single one: the rite must work for you. Test formats and measure the effect, as with any technique\n\nIn daily life, banishing is also psychological: closing the day\'s mental tabs, cutting off rumination, marking the end of a cycle with a physical gesture — claps, a word, a breath on the candle. Beginners tend to skip this step out of haste or because it seems unimportant, and then carry the operation in their heads for days. A short, repeated rite is worth more than an elaborate, forgotten one\n\nTake with you the rule of the clean laboratory: every operation deserves a sharp ending. A gesture, a laugh, a cut — and the bench is free for the next experiment. Whoever knows how to close sleeps better, operates better, and does not mistake yesterday\'s echo for today\'s signal',
        practice:
            'You will create your first energetic cleanup. At the end of the day, stand up, breathe deeply, and clap your hands 3 times firmly. Then, laugh out loud at everything left pending — let the laughter dissolve the weight. Feel the cut between what has passed and the now. Repeat for a few days and note the effect on your body and sleep. The goal is to install a simple banishing rite that closes cycles and clears the space between operations',
        pageTitle: 'My Banishing',
        pagePurpose: 'Create my energetic cleanup',
        pageCategory: SpellCategory.banishing,
        pageType: SpellType.banishment,
        pagePrompts: [
          'My banishing rite (steps):',
          'When I use it (between rituals? daily?):',
          'Did the banishing laughter work? How it went:',
          'What I notice after banishing:',
        ],
      ),
      TrailLesson(
        id: 'mc_09',
        recordKind: LessonRecordKind.oracle,
        title: 'Synchronicity: surfing chance',
        teaching:
            'For the chaote, synchronicity is the system\'s feedback: when coincidences begin to align with your operation — the right song, the improbable encounter, the repeated word — something is underway. Reading these echoes matters because they indicate whether the route is alive, working as the instrument panel of your magical flight\n\nThe term comes from Jung: meaningful coincidences with no apparent common cause. The chaote stance is pragmatic: synchronicity is not forced — it is surfed. You record the echo, give thanks, and adjust the route, without turning every falling leaf into prophecy. Chance can also be consulted actively: oracles are generators of meaningful randomness, invitations for the pattern to emerge\n\nThe beginner\'s trap is apophenia: seeing patterns in everything, a sign in every street sign. The antidote is the results diary: note the echo the moment it happens, reread it coldly later, and ask whether it pointed to something verifiable. Work with one question at a time, collect the echoes of a whole day, and only then do the reading, honest and unforced\n\nKeep the image of the surfer: you do not create the wave of chance, but you learn to ride it. Signal recorded, brief gratitude, route adjusted — and the diary as the keel so the reading does not turn into delirium. The world converses with those who operate; your job is to listen carefully, without inventing what was not said',
        practice:
            'You will cast a question to chance. In the morning, formulate a clear question and make a consultation in the app\'s Oracle tool, under Tools, keeping the answer as a seed. Throughout the day, collect the echoes — coincidences, phrases, encounters — without forcing anything. At night, reread everything and do the honest reading: signal or apophenia? The goal is to train your listening to chance with the diary as protection against self-deception',
        pageTitle: 'Synchronicity Journal',
        pagePurpose: 'Record and read the echoes of chance',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'My cast question:',
          'The echoes collected during the day:',
          'Honest reading (signal or apophenia?):',
          'Route adjustment decided:',
        ],
      ),
      TrailLesson(
        id: 'mc_10',
        recordKind: LessonRecordKind.note,
        title: 'Build your own system',
        teaching:
            'The destiny of chaos magic is autonomy: after testing beliefs, techniques, and paradigms, you assemble your own system — personal, functional, and revisable. No one else\'s grimoire knows your gnosis portals, your living symbols, your rhythm. Arriving here matters because it closes the phase of following maps and opens the phase of drawing them\n\nThe assembly criterion is experimental: if it passes your results diary, it is yours. Mix without fear the esbat with sigils, your grandmother\'s folk blessing with modern servitors — the chaote tradition has always treated systems as toolboxes, not as churches. The limits are only ethical: no harm to people or animals, nothing criminal. The rest — the strange, the symbolic, the invented — is legitimate raw material\n\nIn practice, start lean: three proven core techniques, your non-negotiable principles, and a testing area for what is still under evaluation. Give the system a name and a review date, like software that gets versions. The common mistake is the endless quilt: accumulating techniques without ever pruning. A good system is the one you actually use, not the one that decorates the notebook\n\nTake with you the idea of version 1.0: your system does not need to be born finished, it needs to be born yours. Revisable, honest, and alive, it will grow with each recorded experiment. Nothing is true, everything is permitted to create — and your magic, from now on, carries your own signature',
        practice:
            'You will consolidate your path. Reread all your pages and records from the trails, calmly, and circle what already works as your way: techniques that yield, symbols that speak, rhythms that sustain. Then, organize the essentials into three core techniques, your principles, and a list of what remains under testing. Mark the date of the first review. The goal is to turn the accumulated experience into your magical system version 1.0.',
        pageTitle: 'My Magical System v1.0',
        pagePurpose: 'Consolidate my personal path',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'My 3 core techniques:',
          'My non-negotiable principles:',
          'What I am testing now:',
          'Date of the next system review:',
        ],
      ),
    ],
  );
