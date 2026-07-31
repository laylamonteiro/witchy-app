import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Trail 'magia_negra' — English content.
/// Parity with _pt/_es checked in test/trails_parity_test.dart.
const LearningTrail magiaNegraTrailEn = LearningTrail(
    id: 'magia_negra',
    emoji: '🌑',
    title: 'Black Magic',
    subtitle: 'Shadow, severance, and conscious power',
    description:
        'Undo the myths and cross the dark with responsibility: shadow work, banishings, cord cuttings, and protections — the power born when you look at what most people avoid.',
    lessons: [
      TrailLesson(
        id: 'mn_01',
        recordKind: LessonRecordKind.note,
        title: 'What black magic is (and what it never was)',
        teaching:
            'Black magic, in this trail, is the name we give to conscious work with the shadow: banishing what makes you sick, defending your own field, cutting what drains you, and claiming power with ethics. It is not a recipe for harming anyone — it is the side of witchcraft that looks the dark straight in the eye. Understanding what this term is, and what it never was, is the first step toward practicing without fear and without irresponsibility.\n\nThe label of black magic carries a heavy history: it was used to demonize Afro-diasporic religions, folk healers, and popular wisdom, associating darkness with evil out of pure prejudice and racism. Folklore and cinema exaggerated the rest, creating the caricature of the curse and the sinister pact. Modern practice undoes this confusion: darkness is not a synonym for wickedness, just as the night is not the enemy of the day.\n\nAt the beginning, it is common to arrive at this subject with fear or with too much fascination — both throw you off balance. The classic mistake is seeking spells against someone who hurt you: besides being ethically wrong, it binds your energy to the very person you want distance from. The tip is to set your limits before any practice: write down what you will never do, and why. Ethics defined with clarity is the greatest protection there is.\n\nTake this with you: the dark is a natural part of the path, and those who walk it with responsibility find strength there, not danger. You do not need to fear this trail or prove courage to anyone. Your pact is with yourself — and it is what turns power into maturity. The witch who knows her limits can go far deeper than the one who pretends not to have them.',
        practice:
            'You will write your Pact of Responsibility. First, reflect honestly on what brought you to this trail. Then, write on your page the limits you take on: what you will never do with your own magic and the values that will guide each practice. Finally, read the pact aloud, as if signing a commitment with yourself. The goal is to set the ethical foundation that will protect you along the entire path of the shadow.',
        pageTitle: 'My Pact of Responsibility',
        pagePurpose: 'Define my limits before touching the shadow',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'What drew me to this path:',
          'My limits: what I will never do:',
          'What I want to transform in myself:',
          'My commitment, in my own words:',
        ],
      ),
      TrailLesson(
        id: 'mn_02',
        recordKind: LessonRecordKind.note,
        title: 'The shadow: what you hide from yourself',
        teaching:
            'The shadow is everything you hid from yourself in order to be accepted: swallowed anger, denied desires, talents that seemed too dangerous. In the mystical key, it is the basement of the soul — and every basement holds as much clutter as treasure. Shadow work matters because what you do not look at does not disappear: it simply starts acting in the dark, without your permission.\n\nJung\'s psychology gave a name to what witches always knew: what we repress does not die, it projects itself. That is why certain flaws in others irritate us so much — they tend to be mirrors of something of our own. In the old tales, the monster of the forest almost always guards a treasure or becomes an ally when faced head-on: folklore already taught that the dark hides power, and not only danger.\n\nIn practice, shadow work starts small: noticing disproportionate irritations, the jealousies that embarrass you, the compliments you reject. The common mistake is turning this into self-punishment — you do not beat the shadow, you listen to it. Another is wanting to illuminate everything at once. Go slowly, with curiosity and without judgment, like someone exploring an old house with a candle in hand.\n\nTake this with you: your shadow is not your enemy — it is the part of you that waited years for attention. Each piece you listen to returns energy that was trapped in hiding. The witch who knows her own shadow does not become darker: she becomes more whole, more honest, and much harder to manipulate. The map begins today, and the one holding the lantern is you.',
        practice:
            'You will draw the first Map of your Shadow. First, list three behaviors in others that irritate you disproportionately. Then, ask yourself, honestly and without judgment, what each one might mirror in you — memories and moments of shame that surface are valuable clues. Finally, record on the page the aspects of shadow you recognized. The goal is to begin the conscious encounter with what you hide from yourself.',
        pageTitle: 'Map of My Shadow',
        pagePurpose: 'Recognize projections and denied parts of me',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'What irritates me most in others (and may be mine):',
          'The part of me I hide from the world:',
          'When it shows up without my wanting it to:',
          'What it is trying to protect me from feeling:',
        ],
      ),
      TrailLesson(
        id: 'mn_03',
        recordKind: LessonRecordKind.spell,
        title: 'Banishing: cutting away what sickens',
        teaching:
            'To banish is the magical gesture of saying enough: removing from your field a habit, an energy, or a situation that makes you sick. It is the deep cleaning of witchcraft — before attracting anything good, you must make room. In this trail, banishing never targets people to cause harm: the target is always the pattern, the addiction, the weight. You banish what binds you, not those around you.\n\nBanishing is among the oldest practices in the world: salt in the corners of the house, a broom sweeping outward, smoke of bitter herbs, water carrying away what no longer serves. The traditional logic follows the waning moon: just as it shrinks in the sky, so shrinks what has been banished. Writing down what you want to remove and safely destroying the paper is the classic form — fire and water have always been the great dissolvers of folk magic.\n\nFor the beginner, the key is choosing a concrete and fair target: a habit that drains, a heavy energy in a room, a cycle that repeats. The common mistake is banishing vaguely — everything bad in my life — and feeling no effect, or disguising an attack on someone as a banishing. Another is banishing and then feeding the pattern again the next day: the spell opens the door, but the one who walks through it is you.\n\nTake this with you: banishing is an act of self-love that looks like courage. Each thing you consciously remove gives back space for what deserves to grow. This is your first spell of the trail — simple, honest, and powerful in the measure of your commitment. The power is not in the burned paper: it is in the decision you sustain after it.',
        practice:
            'You will perform your first banishing. First, choose a fair target: a habit, an energy, or a situation — never a person. Then, write it on a piece of paper, light a candle in a safe place, and burn the paper while declaring that it no longer has a place in your life; discard the ashes outside your home. Finally, record everything on the grimoire page. The goal is to make room by consciously removing what makes you sick.',
        pageTitle: 'My First Banishing',
        pagePurpose: 'Banish a habit, energy, or situation that sickens me',
        pageCategory: SpellCategory.banishing,
        pageType: SpellType.banishment,
        pageIngredients: ['Dark candle or paper and pen', 'A symbol of what will be banished'],
        pagePrompts: [
          'What I am banishing (habit, energy, or situation):',
          'Why it no longer has a place in my life:',
          'How I performed the rite and what I felt:',
          'What fills the space that was freed:',
        ],
      ),
      TrailLesson(
        id: 'mn_04',
        recordKind: LessonRecordKind.spell,
        title: 'Shields and mirrors: magical defense',
        teaching:
            'Magical defense is hygiene, not paranoia: just as you lock the door without living in fear, the energetic shield protects your field without turning the world into a threat. Shields filter what comes from outside; mirrors return to the source what was sent, without you having to strike back. Knowing how to protect yourself is what allows you to work the shadow calmly and remain open to life.\n\nFolklore is full of defenses: iron on the door, the evil-eye charm against envy, rue at the entrance, little mirrors that confuse and return the evil eye. The idea of the mirror is elegant: you attack no one, you simply stop absorbing — what comes, returns to whoever sent it, and the responsibility belongs to the sender. Modern visualization inherits this: imagining yourself inside a mirrored sphere is a technique both simple and ancient at once.\n\nIn everyday life, the shield is built in one minute each morning: breathe, visualize the sphere of mirrored light around your body, and set the intention. The common mistake is armoring yourself so much that nothing gets in — not even the good; a shield is a filter, not a wall of isolation. Another is remembering protection only in a crisis. Consistency is worth more than intensity: a simple amulet renewed with care protects more than grand rituals forgotten.\n\nTake this with you: you have the right not to absorb what is not yours. Protecting yourself is neither aggression nor distrust of the world — it is respect for your own field. With the mirrored shield, you walk lighter, knowing that what does not belong to you finds its own way back. Energetic safety is the silent foundation of all the magic that comes after.',
        practice:
            'You will raise your Mirrored Shield. First, sit in silence, take three deep breaths, and feel your feet firm on the ground. Then, visualize a sphere of light around you whose outer face is a mirror: what is good passes through, what weighs is returned to its source; hold the image for a few minutes and, if you wish, consecrate a small object as an amulet. Finally, record the experience on the page. The goal is to create a daily protection that filters without isolating.',
        pageTitle: 'My Mirrored Shield',
        pagePurpose: 'Raise my protection before any shadow work',
        pageCategory: SpellCategory.protection,
        pageType: SpellType.banishment,
        pageIngredients: ['Small mirror or reflective object', 'Coarse salt'],
        pagePrompts: [
          'What I am protecting myself from:',
          'How I visualized my shield (shape, material, shine):',
          'The phrase that sets my protection:',
          'When I will renew this shield:',
        ],
      ),
      TrailLesson(
        id: 'mn_05',
        recordKind: LessonRecordKind.spell,
        title: 'Cord cutting',
        teaching:
            'Between you and every person in your life there are invisible ties — cords of affection, of history, of energy. Some nourish; others drain, bind you to relationships already ended, or turn coexistence into a tug of war. Cord cutting is the ritual that returns to each person their own energy. Cutting is not attacking or erasing someone: it is closing an energetic contract that has already expired.\n\nTraditions around the world know these cords: ribbons tied and untied in folk rites, knots undone to open paths, scissors cutting through heavy air. The modern rite uses simple symbols: a cord representing the tie, two candles representing the two sides, a consecrated pair of scissors. When you cut the cord, you declare the end of the bond that drains — and wish, from the heart, that each part go on in peace with what is theirs.\n\nIn practice, start with a clearly expired tie: an ended relationship that still occupies your thoughts, a connection that only drains. The common mistake is cutting in anger, turning the rite into silent revenge — cutting is done with serene firmness, not with hatred. Another is expecting someone to vanish from your life the next day: what is cut is the energetic cord; the practical choices about distance remain yours.\n\nTake this with you: letting go is also magic — perhaps the hardest and the most liberating. Each tie cut with awareness returns energy that was trapped in the past. You do not need to carry cords that no longer lead anywhere. Cut with respect, give thanks for what was learned, and walk lighter: the space that opens is yours, and the other person\'s too.',
        practice:
            'You will perform the Cord Cutting Ritual. First, choose a bond that drains you and take a cord or string to represent it, holding one end in each hand while silently naming what that tie has become. Then, cut the cord with scissors, wishing peace for both sides, and discard the separated parts. Finally, record the rite and what you felt on the page. The goal is to release energy trapped in relationships that have already fulfilled their role.',
        pageTitle: 'Cord Cutting Ritual',
        pagePurpose: 'Cut energetic cords that drain me',
        pageCategory: SpellCategory.banishing,
        pageType: SpellType.banishment,
        pageIngredients: ['Cord or string', 'Scissors', 'Candle'],
        pagePrompts: [
          'The tie I needed to cut (without blaming, just naming):',
          'What this bond drained from me:',
          'What the moment of cutting was like:',
          'What good I wish for both sides, apart:',
        ],
      ),
      TrailLesson(
        id: 'mn_06',
        recordKind: LessonRecordKind.note,
        title: 'The dark moon and the fertile dark',
        teaching:
            'The dark moon is the phase when the sky seems empty: the moon is there, but reflects no light at all. In the traditions of witchcraft, this is the time of silence, of diving inward, and of rest — the fertile dark where everything prepares itself before being born. Honoring this phase matters because power is not only action: the conscious pause is as magical as any well-cast spell.\n\nAncient peoples planted by the moon and knew that the seed germinates in the dark of the earth, not in the light. Folklore linked the dark moon to the deep mysteries, to the crone goddess, to the time when nothing is begun — only listened to. Modern practice translates this into personal retreat: less stimulation, more silence, divination, writing, and restorative sleep. It is the moment when the shadow speaks most clearly, because the noise dies down.\n\nIn practice, mark the dark moon on your calendar and reserve a quieter night for it: fewer screens, a long bath, free writing, early sleep. The common mistake is treating rest as laziness and forcing yourself to produce — in this phase, that only breeds exhaustion. Another is expecting great revelations: sometimes the dark moon delivers only a deep sleep, and that is already the gift of the phase.\n\nTake this with you: you also have phases, and none of them is wrong. The fertile dark teaches that withdrawing is preparing the next bloom. The witch who respects her own winter does not fade — she gathers depth. Let the dark moon be your monthly reminder that emptiness is not lack: it is the silent womb where your next version is being formed.',
        practice:
            'You will begin your Dark Moon Journal. First, find out when the next dark moon is and reserve that night — or do a rehearsal today on a quiet evening. Then, lower the stimulation: dim light, silence, fewer screens, and write freely about what in your life is asking for rest and what is germinating in the dark. Finally, record your perceptions on the page. The goal is to turn the dark phase into a monthly rite of listening and rest.',
        pageTitle: 'Dark Moon Journal',
        pagePurpose: 'Work with silence and rest as power',
        pageCategory: SpellCategory.other,
        pagePrompts: [
          'What the dark teaches me when I stop running from it:',
          'What I am letting rest during this moon:',
          'What I noticed in the silence:',
          'The seed I will plant when the light returns:',
        ],
      ),
      TrailLesson(
        id: 'mn_07',
        recordKind: LessonRecordKind.dream,
        title: 'Dark dreams: messages from the shadow',
        teaching:
            'Nightmares frighten, but they rarely come to torment: in the mystical reading, they are urgent letters from the shadow. When something important cannot reach you through the ordinary route, the dream turns up the volume — and becomes a monster, a fall, a chase. Learning to listen to dark dreams matters because they point exactly to what your shadow work needs to look at now.\n\nAncient cultures treated dreams as oracles: incubation temples in Greece, folk blessings against nightmares, guardians of sleep in the lore of many peoples. The modern symbolic key reads the nightmare inside out: whoever chases you in the dream is usually something of yours asking for a meeting; the house in ruins speaks of inner structures; the fall, of control that needs to be released. The monster, almost always, wants to deliver a message — not devour you.\n\nIn practice, the secret is recording as soon as you wake, before the dream evaporates: note scenes, emotions, and symbols in the app\'s Dream Journal and consult the Dream Meanings to open layers. The common mistake is interpreting literally and concluding that a bad dream is an omen — most of the time, it is an inner portrait, not a prophecy. Another is fleeing the theme: an ignored nightmare tends to come back louder.\n\nTake this with you: the night is your ally, even when it speaks in frightening images. Each nightmare listened to with courage is one less conversation the shadow needs to shout. You are not at the mercy of your dreams — you are in dialogue with them. Sleep like someone who trusts her own depths: the dark of dreams also works in your favor.',
        practice:
            'You will listen to a dark dream. First, record in the app\'s Dream Journal a recent nightmare — or the next one that comes — with scenes, symbols, and emotions. Then, explore the Dream Meanings to open the symbolic layers and ask yourself what part of you might be speaking through those images. Finally, write on the page the message you managed to hear. The goal is to transform the nightmare from threat into messenger of the shadow.',
        pageTitle: 'A Dark Dream Heard',
        pagePurpose: 'Listen to a nightmare as a messenger',
        pageCategory: SpellCategory.dreams,
        pagePrompts: [
          'The dark dream that visited me:',
          'What I felt inside it and upon waking:',
          'What part of my shadow may be speaking:',
          'What this message asks of me in waking life:',
        ],
      ),
      TrailLesson(
        id: 'mn_08',
        recordKind: LessonRecordKind.oracle,
        title: 'Black mirror and dark scrying',
        teaching:
            'Dark scrying is the art of looking into the dark until it begins to speak. The black mirror, the bowl of dark water, and the candle flame are ancient doors to this: surfaces that occupy the eyes so that intuition takes command. Learning this practice matters because it trains the witch\'s central skill: holding your gaze before the unknown without running from it.\n\nThe practice spans centuries: seers have gazed into obsidian mirrors, deep wells, and basins of ink across many cultures, and folklore kept stories of mirrors that show hidden truths. How it works is less mysterious than it seems: before a dark, featureless surface, the rational mind quiets and inner images gain room — symbols, memories, intuitions. The mirror does not show ghosts: it shows you, in depth.\n\nTo begin, darken the room, light a candle out of the reflection, and gaze softly at the black surface for a few minutes, blinking normally. The common mistake is forcing visions or giving up on the third attempt — scrying is a muscle, it grows slowly. If you prefer more concrete support, the app\'s Oracle Cards serve a similar role: images that lend shape to your intuition. Record everything, even what seems like little.\n\nTake this with you: the dark is not empty — it is full of you. Each scrying session teaches your eyes to trust what the other senses already know. There is no right answer to find, only a listening to refine. With patience, the black mirror stops being frightening and becomes what it always was: a calm window into your own depths.',
        practice:
            'You will hold your first scrying session. First, prepare the space: dim light, a lit candle, and a dark mirror or a bowl of water over a dark background — or, if you prefer, the app\'s Oracle Cards. Then, gaze softly at the surface or draw a card, letting impressions, images, and sensations arise without forcing, for five to ten minutes. Finally, record everything on the page, without censoring. The goal is to train the intuitive gaze before the dark.',
        pageTitle: 'My Scrying Session',
        pagePurpose: 'Look into the dark without fear and record what I saw',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'How I prepared the space and the mirror (or the cards):',
          'What I saw, felt, or intuited:',
          'What may be symbol and what may be my own fear:',
          'The message I take from this session:',
        ],
      ),
      TrailLesson(
        id: 'mn_09',
        recordKind: LessonRecordKind.spell,
        title: 'Binding: the spell tied to ethics',
        teaching:
            'Binding is the spell that ties down a harm so it stops spreading — like bandaging a broken arm or closing a leaking valve. In this trail, it exists to contain destructive patterns, situations, and behaviors, never to control someone\'s will or hurt anyone at all. It is the magic of the limit: the word enough spoken in knot and cord.\n\nThe image of the knot runs through the history of magic: knots that hold winds in sailors\' legends, ribbons that seal promises, braids that keep intentions. The classic binding ties a symbol of the problem with cord and firm word. The ethics are explicit: to bind is to stop a harm from continuing — like containing your own addiction, a dynamic of gossip, or a cycle of self-sabotage. Controlling or hurting people is something else, and this trail does not teach it.\n\nIn practice, write the situation or pattern to be contained on a piece of paper, fold it inward, and tie it with dark cord, declaring that this harm is contained and grows no more. Keep the bundle in a closed place. The common mistake is using binding as a shortcut to avoid acting — the spell holds the bleeding, but healing calls for concrete steps. Another is targeting someone out of anger disguised as justice: always ask yourself what exactly you want to contain.\n\nTake this with you: every spell returns to the hands that cast it — which is why the mature witch measures her intention before the knot. A well-made binding is not an attack: it is the sacred limit that protects you and others from an ongoing harm. Use it rarely, with clarity and responsibility, and it will be one of the most sober tools in your grimoire.',
        practice:
            'You will cast an ethical Binding Spell. First, identify an ongoing harm that needs to stop growing — a pattern, a cycle, a situation; never a person as the target. Then, write it on a piece of paper, fold it inward, and tie it with a dark cord in firm knots, declaring that this harm is contained; keep the bundle in a closed place. Finally, record the spell and the concrete steps that will accompany it. The goal is to contain the harm while you act to resolve it.',
        pageTitle: 'My Binding Spell',
        pagePurpose: 'Contain an ongoing harm without hurting anyone',
        pageCategory: SpellCategory.protection,
        pageType: SpellType.banishment,
        pageIngredients: ['Cord for the symbolic knot', 'Paper and pen'],
        pagePrompts: [
          'The harm that needs to stop (a fact, not a person):',
          'My ethical limit in this work:',
          'How I tied the binding (knot, word, symbol):',
          'The concrete action that accompanies the spell:',
        ],
      ),
      TrailLesson(
        id: 'mn_10',
        recordKind: LessonRecordKind.note,
        title: 'Integration: the whole witch',
        teaching:
            'The trail ends where whole witchcraft begins: at integration. After looking at the shadow, banishing, cutting, protecting, and binding, you discover there are not two witches inside you — one of light and one of dark. There is only one, more honest, who knows her own depths. Integration is this: no longer choosing halves and inhabiting your own wholeness with serenity.\n\nThe old symbols always pointed to this union: the day needs the night, the full moon carries the memory of the dark moon, the seed and the flower are the same plant at different times. In the stories, whoever descends to the underworld and returns comes back transformed — not darker, wiser. The integrated shadow does not disappear: it becomes discernment, humor, compassion, and that quiet strength of someone who already knows herself from within.\n\nIn everyday life, integration shows in discreet signs: you get less irritated by other people\'s mirrors, you say no without guilt, you rest without shame, you protect yourself without hardening. The common mistake is thinking shadow work ends — it changes rhythm, but accompanies life. Another is expecting perfection: the whole witch is not the one who never errs; she is the one who takes responsibility for what she does with her own power.\n\nTake this with you: you crossed the dark and it did not swallow you — it enlarged you. The manifesto you write now is the portrait of the one who made it here: someone who practices with ethics, feels without drowning, and shines without denying her own night. Go on with both hands open, one for the light and one for the shadow. That is how the whole witch walks.',
        practice:
            'You will write the Manifesto of the Whole Witch. First, reread the pages of this trail and observe what has changed from the initial pact until now. Then, write a short, personal text declaring who you are as a practitioner: your values, your limits, what you integrate from light and shadow. Finally, read the manifesto aloud and keep it as the closing of the trail. The goal is to seal the integration and claim, with ethics, your own whole power.',
        pageTitle: 'Manifesto of the Whole Witch',
        pagePurpose: 'Integrate light and shadow on my path',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'What power the shadow gave back to me:',
          'What changed in my relationship with fear:',
          'My ethics, now in one sentence:',
          'How I go on from here: light and shadow together:',
        ],
      ),
    ],
  );
