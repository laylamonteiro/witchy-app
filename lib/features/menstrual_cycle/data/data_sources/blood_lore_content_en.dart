import '../../../grimoire/data/models/spell_model.dart';
import '../../domain/menstrual_shortcut.dart';
import '../models/blood_lore_model.dart';

/// The Blood Lore in English. Same editorial rules as the Portuguese source
/// (see `blood_lore_content_pt.dart`): history stays history, modern
/// practice says it is modern, the Moon is correspondence and never cause,
/// the love philtre is told and never taught, and every practice that
/// mentions blood offers the same practice without it.
const bloodLoreContentEn = BloodLoreContent(
  pageTitle: 'Blood Lore',
  intro:
      'Four ways into the same subject: what the records show, what lunar '
      'magic does with a cycle, what you can practise today, and where all '
      'of it was taken from',
  introNote:
      'Every text carries a label saying where it comes from. A practice '
      'invented recently is never dressed here as ancient tradition.',
  categoryTitles: {
    BloodLoreCategory.bloodInMagic: 'Blood in magic',
    BloodLoreCategory.cycleAndMoon: 'Cycle and Moon',
    BloodLoreCategory.practices: 'Practices and spells',
    BloodLoreCategory.traditions: 'Traditions and history',
  },
  categorySubtitles: {
    BloodLoreCategory.bloodInMagic:
        'Link, ambivalence, love, protection and personal power',
    BloodLoreCategory.cycleAndMoon:
        'Two wheels that meet — and what that does not mean',
    BloodLoreCategory.practices:
        'Things to do, each with its origin in plain sight',
    BloodLoreCategory.traditions:
        'What was recorded, by whom, and what cannot be known',
  },
  tagLabels: {
    BloodLoreTag.documented: 'Historically documented',
    BloodLoreTag.tradition: 'Specific tradition',
    BloodLoreTag.contemporary: 'Contemporary practice',
    BloodLoreTag.modernAdaptation: 'Modern adaptation',
  },
  safetyNote:
      'Use only your own menstrual blood. Do not share bodily fluids, do not '
      'put them in food or drink, and do not use anything that could injure '
      'you. Nothing here asks you to cut yourself: this is about the blood '
      'your body already makes.',
  classificationLabel: 'Classification',
  practiceIntentionLabel: 'Intention',
  practiceMaterialsLabel: 'Materials',
  practiceStepsLabel: 'The practice',
  practiceWithoutBloodLabel: 'Version without blood',
  entriesCountTemplate: '{count} texts',
  cycleCta: 'Explore the blood lore',
  momentTitle: 'Practices for this moment',
  momentIntro:
      'Shortcuts to what the Grimoire already has. Whatever you write, draw '
      'or dream goes on living in its usual place.',
  shortcuts: {
    MenstrualShortcut.release: BloodLoreShortcut(
      title: 'What do you want to let go?',
      body: 'Write about something that has come to an end',
      prompt:
          'What is asking to end in this cycle?\n\nWrite without trying to '
          'solve it. Just notice what you would rather not carry into the '
          'next turn.',
    ),
    MenstrualShortcut.cultivate: BloodLoreShortcut(
      title: 'What do you want to grow?',
      body: 'Write about something that is beginning',
      prompt:
          'What is beginning in you this turn?\n\nWrite without demanding a '
          'result. Just name what you want to tend until the next blood.',
    ),
    MenstrualShortcut.oracle: BloodLoreShortcut(
      title: 'Hear the oracle',
      body: 'Draw cards about this cycle',
    ),
    MenstrualShortcut.dream: BloodLoreShortcut(
      title: 'Record a dream',
      body: 'The dream goes to your Dream Diary, like any other',
    ),
    MenstrualShortcut.intention: BloodLoreShortcut(
      title: 'Set an intention',
      body: 'One word becomes a sigil in the maker the Grimoire already has',
    ),
    MenstrualShortcut.practices: BloodLoreShortcut(
      title: 'Practise',
      body:
          'Explore practices tied to blood, protection, binding and endings',
    ),
  },
  moonCorrespondences: {
    MoonPhase.newMoon: 'seed, silence and what has no shape yet',
    MoonPhase.waxingCrescent: 'expansion, strengthening and what is being tended',
    MoonPhase.firstQuarter: 'decision, push and what asks for a choice',
    MoonPhase.waxingGibbous: 'ripening and adjusting what is already under way',
    MoonPhase.fullMoon: 'fullness, revelation and what overflows',
    MoonPhase.waningGibbous: 'gratitude, sharing and what may rest now',
    MoonPhase.lastQuarter: 'cutting, forgiveness and what is released',
    MoonPhase.waningCrescent: 'withdrawal, rest and the close of the circle',
  },
  correspondenceTemplate:
      'In lunar magic, {phase} is usually associated with {meaning}',
  startUnderTemplate: 'Your latest cycle began under {phase}',
  phaseTallyTemplate:
      '{count} of your last {total} beginnings happened under {phase}',
  moonNotSynced:
      'The lunar cycle and the menstrual cycle do not need to be in step. '
      'Watch how the two meet over time.',
  closingCorrespondence:
      '{phase} and bleeding share a symbolic correspondence of ending. If '
      'that makes sense for your practice, this may be a good moment to look '
      'at what you want to let go.',
  entries: [
    // ── Blood in magic ────────────────────────────────────────────────────
    BloodLoreEntry(
      id: 'sangue-vinculo',
      category: BloodLoreCategory.bloodInMagic,
      tag: BloodLoreTag.documented,
      emoji: '🔗',
      title: 'Blood as a link',
      summary: 'Why matter from the body appears so often in folk magic',
      sections: [
        BloodLoreSection(
          title: 'Matter that belongs to someone',
          body:
              'Blood, hair, nails, saliva, a piece of worn clothing: folk '
              'magic recorded in Europe, in the Americas and elsewhere keeps '
              'returning to these materials. The reasoning is always the '
              'same — what belonged to a body stays tied to it, and working '
              'with the material would be working with the person.',
        ),
        BloodLoreSection(
          title: 'What menstrual blood gathers',
          body:
              'It brings together in a single material: blood, bodily '
              'identity, cycle, sexuality and symbolic fertility. It is that '
              'sum, and not blood alone, that explains why it shows up so '
              'insistently in the records.',
        ),
        BloodLoreSection(
          title: 'The modern term',
          body:
              'Contemporary witchcraft tends to call these materials a '
              'taglock. The word is recent and useful for naming the group, '
              'but the concept is far older than the word — and the '
              'historical sources do not use it.',
        ),
      ],
    ),
    BloodLoreEntry(
      id: 'ambivalencia',
      category: BloodLoreCategory.bloodInMagic,
      tag: BloodLoreTag.documented,
      emoji: '⚖️',
      title: 'The ambivalence of menstrual blood',
      summary:
          'Dangerous, taboo, protective, powerful: the records do not agree '
          'with each other',
      sections: [
        BloodLoreSection(
          title: 'There is no single view',
          body:
              'Depending on the place and the century, menstrual blood has '
              'been treated as dangerous, as taboo, as protective, as '
              'powerful, as tied to fertility and as able to drive certain '
              'influences away. All of those readings appear in the records, '
              'sometimes within the same culture.',
        ),
        BloodLoreSection(
          title: 'Why this matters',
          body:
              'The line "menstrual blood used to be considered sacred" gets '
              'repeated a great deal and does not hold as a universal claim. '
              'There was reverence in some places and severe prohibition in '
              'others. The ambivalence is the finding, not an inconvenient '
              'detail.',
        ),
        BloodLoreSection(
          title: 'What to do with it',
          body:
              'Knowing there is no consensus hands the choice back to you. '
              'No single tradition gets to decide what menstruating means in '
              'your practice.',
        ),
      ],
    ),
    BloodLoreEntry(
      id: 'amor-e-ligacao',
      category: BloodLoreCategory.bloodInMagic,
      tag: BloodLoreTag.documented,
      emoji: '❤️',
      title: 'Love and binding',
      summary:
          'The most recurrent use of menstrual blood in recorded love magic',
      sections: [
        BloodLoreSection(
          title: 'What the records show',
          body:
              'Among the uses of menstrual blood that appear most often in '
              'trial papers, recipe books and folklore collections, love '
              'magic comes first. There are records of practices in which the '
              'blood was secretly placed in the food or drink of a desired '
              'person to produce desire, binding, affection or submission.',
        ),
        BloodLoreSection(
          title: 'This is history, not instruction',
          body:
              'The Grimoire tells this practice because it is part of the '
              'history of magic. It does not turn it into a how-to: it '
              'involves a bodily fluid, a person who did not choose to take '
              'part, and a real health risk.',
        ),
        BloodLoreSection(
          title: 'What belongs here',
          body:
              'The same intention — attraction, magnetism, openness — can be '
              'worked on yourself, without touching what belongs to someone '
              'else.',
        ),
      ],
      cta: BloodLoreCta(
        label: 'Explore a charm of attraction',
        link: BloodLoreLink.entry,
        entryId: 'encanto-de-atracao',
      ),
    ),
    BloodLoreEntry(
      id: 'protecao',
      category: BloodLoreCategory.bloodInMagic,
      tag: BloodLoreTag.documented,
      emoji: '🛡️',
      title: 'Protection',
      summary:
          'Counter-magic, the house and thresholds: the other side of the '
          'same records',
      sections: [
        BloodLoreSection(
          title: 'A force that repels',
          body:
              'One idea runs through many sources: whatever is held to be '
              'magically strong — or dangerous — also serves to push another '
              'influence away. That is why the same material that appears in '
              'prohibitions appears in protections.',
        ),
        BloodLoreSection(
          title: 'House and thresholds',
          body:
              'Doors, doorsteps, windows and fences are where domestic '
              'protection tends to be placed, across traditions that have '
              'little else in common. Menstrual blood appears in that group '
              'in part of the records, beside salt, iron, herbs and scratched '
              'symbols.',
        ),
        BloodLoreSection(
          title: 'Counter-magic',
          body:
              'In several bodies of accounts it is named as a resource '
              'against someone else\'s spell, not as a spell of attack.',
        ),
      ],
    ),
    BloodLoreEntry(
      id: 'vinculo-e-poder',
      category: BloodLoreCategory.bloodInMagic,
      tag: BloodLoreTag.contemporary,
      emoji: '🔮',
      title: 'Binding and personal power',
      summary: 'Matter from your own body as a magical signature',
      sections: [
        BloodLoreSection(
          title: 'The signature',
          body:
              'If matter from a body creates a link, matter from your body '
              'creates a link with you. That is the most common contemporary '
              'reading: using something of yours to sign a gesture, mark a '
              'commitment, strengthen an intention.',
        ),
        BloodLoreSection(
          title: 'Where it usually goes',
          body:
              'Commitments to yourself, personal protection, strengthening '
              'an intention, work on identity and personal power. The focus '
              'is always you — never another person\'s will.',
        ),
        BloodLoreSection(
          title: 'Where it comes from',
          body:
              'The idea that matter from the body signs is old. Turning it '
              'towards yourself as a practice of autonomy is recent, and '
              'comes from contemporary witchcraft.',
        ),
      ],
    ),
    BloodLoreEntry(
      id: 'vida-e-terra',
      category: BloodLoreCategory.bloodInMagic,
      tag: BloodLoreTag.tradition,
      emoji: '🌱',
      title: 'Life, fertility and nature',
      summary: 'Specific traditions tie this blood to what grows',
      sections: [
        BloodLoreSection(
          title: 'A slice, not a rule',
          body:
              'There are traditions that associate menstrual blood with '
              'fertility, fields, cultivation, life and natural cycles. They '
              'are specific traditions, from specific places and times — not '
              'a universal meaning of the body.',
        ),
        BloodLoreSection(
          title: 'How it appears',
          body:
              'In part of those accounts the described gesture is returning '
              'the blood to the earth or to the plants of the house, as '
              'restitution: what came from the body goes back to what feeds '
              'the body.',
        ),
        BloodLoreSection(
          title: 'Reading with care',
          body:
              'Turning these cases into "all ancient cultures" is the most '
              'common error on this subject. Here they stay where they are: '
              'traditions, with a place and a time.',
        ),
      ],
    ),

    // ── Cycle and Moon ────────────────────────────────────────────────────
    BloodLoreEntry(
      id: 'duas-rodas',
      category: BloodLoreCategory.cycleAndMoon,
      tag: BloodLoreTag.contemporary,
      emoji: '🌙',
      title: 'Two wheels that meet',
      summary: 'The Moon as correspondence and as a way of observing',
      sections: [
        BloodLoreSection(
          title: 'Two round calendars',
          body:
              'The lunar cycle runs about twenty-nine and a half days. The '
              'menstrual cycle varies from person to person and from turn to '
              'turn. Both are round, and that is where the analogy comes '
              'from — not from one commanding the other.',
        ),
        BloodLoreSection(
          title: 'What lunar magic does with it',
          body:
              'In magic each phase carries a correspondence: what grows, what '
              'is full, what withdraws, what starts again. Putting your '
              'beginning beside the phase of that day is using that '
              'correspondence as a lens, the way the wheel of the year is '
              'used.',
        ),
        BloodLoreSection(
          title: 'What this is not',
          body:
              'The lunar cycle and the menstrual cycle do not need to be in '
              'step, and there is no reason to expect them to be. Watch how '
              'the two meet over time, if that makes sense for your practice.',
        ),
      ],
    ),
    BloodLoreEntry(
      id: 'interpretacoes-contemporaneas',
      category: BloodLoreCategory.cycleAndMoon,
      tag: BloodLoreTag.contemporary,
      emoji: '✨',
      title: 'Contemporary interpretations',
      summary: 'White Moon, Red Moon and other recent categories',
      sections: [
        BloodLoreSection(
          title: 'Where they come from',
          body:
              'The White Moon, Red Moon, Pink Moon and Purple Moon categories '
              'were created in the late twentieth century and circulate in '
              'present-day books and courses. They are not ancient tradition '
              'and do not appear in historical sources.',
        ),
        BloodLoreSection(
          title: 'Why they are not the basis here',
          body:
              'They sort a person by the phase she bleeds in, and tend to tie '
              'each category to a role — motherhood, healing, teaching. The '
              'Grimoire does not make that classification: what it shows is '
              'your Moon and your beginning, side by side.',
        ),
        BloodLoreSection(
          title: 'If you want to use them',
          body:
              'Nothing stops you. It is only worth knowing how old the idea '
              'is before adopting it, and remembering that it describes a '
              'reading, not your body.',
        ),
      ],
    ),

    // ── Practices and spells ──────────────────────────────────────────────
    BloodLoreEntry(
      id: 'selo-do-limiar',
      category: BloodLoreCategory.practices,
      tag: BloodLoreTag.modernAdaptation,
      emoji: '🛡️',
      title: 'Seal of the Threshold',
      summary: 'A symbol of protection kept near the door',
      intention: 'Protection of the house.',
      materials: [
        'A small piece of paper',
        'A pen',
        'An envelope or a container that closes',
        'A minimal amount of your own menstrual blood, if you want',
      ],
      steps: [
        'Choose or draw a personal symbol of protection — a letter, a stroke, '
            'a sigil of yours.',
        'Write or draw the symbol on the paper.',
        'If you want to work with your menstrual blood, make a minimal mark '
            'on the paper and let it dry completely.',
        'Fold the paper, close it in the envelope and keep it near the '
            'entrance of the house.',
      ],
      withoutBlood:
          'Without blood the practice is the same: the symbol drawn, the '
          'paper closed and kept at the threshold. If you want to mark it '
          'with something of yours, your handwriting or a drop of an oil you '
          'wear will do.',
      sections: [
        BloodLoreSection(
          title: 'Where it comes from',
          body:
              'Adapted from records tying menstrual blood to the protection '
              'of thresholds and to domestic counter-magic. Keeping the '
              'folded paper is a present-day gesture: the old sources do not '
              'describe this practice this way.',
        ),
        BloodLoreSection(
          title: 'One care',
          body:
              'Do not spread blood around the house, over furniture or on '
              'shared surfaces. The mark is minimal, dry and stays inside a '
              'closed piece of paper.',
        ),
      ],
      mentionsBlood: true,
    ),
    BloodLoreEntry(
      id: 'laco-de-compromisso',
      category: BloodLoreCategory.practices,
      tag: BloodLoreTag.modernAdaptation,
      emoji: '🔗',
      title: 'Knot of commitment',
      summary: 'A sentence you want to hold, folded and tied',
      intention: 'To make a commitment to yourself.',
      materials: [
        'Paper and a pen',
        'Thread or cord',
        'A minimal amount of your own menstrual blood, if you want',
      ],
      steps: [
        'Write a short sentence, in the present, about something you want to '
            'hold: "I protect my time", "I finish what I start", "I keep this '
            'boundary".',
        'If you want, make a minimal mark of your blood on the paper and wait '
            'for it to dry completely.',
        'Fold the paper towards you, never away.',
        'Tie it with the thread and keep it where you will find it again.',
      ],
      withoutBlood:
          'Without blood, sign the paper with your name or in your own hand. '
          'What signs is the act of writing, not the material.',
      sections: [
        BloodLoreSection(
          title: 'Where it comes from',
          body:
              'A modern adaptation of binding magic: the same reasoning of '
              'tying and folding towards yourself, turned to a personal '
              'commitment instead of another person.',
        ),
        BloodLoreSection(
          title: 'The focus',
          body:
              'The work is about you. Binding aimed at someone who did not '
              'choose to take part is a different thing, and not what this '
              'practice does.',
        ),
      ],
      mentionsBlood: true,
    ),
    BloodLoreEntry(
      id: 'encanto-de-atracao',
      category: BloodLoreCategory.practices,
      tag: BloodLoreTag.modernAdaptation,
      emoji: '❤️',
      title: 'Charm of attraction',
      summary: 'Attraction and openness, addressed to no one',
      intention:
          'Attraction, magnetism, self-esteem and openness to the relations '
          'you want.',
      materials: [
        'Paper and a pen',
        'A sigil of yours, if you want to make one',
        'A perfume or oil you wear',
        'A personal object that stays with you',
        'A minimal amount of your own menstrual blood, if you want',
      ],
      steps: [
        'Write the intention without addressing anyone: "May what desires me '
            'and is good for me find its way to me".',
        'If you want, turn the sentence into a sigil — the Grimoire already '
            'has a sigil maker.',
        'Put the perfume on the personal object.',
        'If you want to work with your menstrual blood, make a minimal mark '
            'on the sigil paper and let it dry completely.',
        'Carry the object with you for as long as the intention stands.',
      ],
      withoutBlood:
          'Without blood, the perfume and the personal object are already the '
          'material of yours that the charm asks for.',
      sections: [
        BloodLoreSection(
          title: 'Where it comes from',
          body:
              'A contemporary adaptation. It is not the love magic of the '
              'historical records, which acted on one specific person without '
              'her knowing.',
        ),
        BloodLoreSection(
          title: 'The focus',
          body:
              'The charm is addressed to no one. It works on what comes from '
              'you: attraction, self-esteem and openness. Never put blood — '
              'or any other fluid — on what belongs to another person.',
        ),
      ],
      mentionsBlood: true,
      cta: BloodLoreCta(
        label: 'Make a sigil',
        link: BloodLoreLink.sigils,
      ),
    ),
    BloodLoreEntry(
      id: 'consagracao-de-sigilo',
      category: BloodLoreCategory.practices,
      tag: BloodLoreTag.contemporary,
      emoji: '🕯️',
      title: 'Consecration of a sigil',
      summary: 'Giving a sigil of yours a personal charge',
      intention: 'To consecrate a sigil with something that is yours.',
      materials: [
        'A sigil you made',
        'Paper and a pen',
        'A candle, if you want',
        'A minimal amount of your own menstrual blood, if you want',
      ],
      steps: [
        'Make the sigil in the Grimoire, from a one-word intention.',
        'Copy the sigil\'s stroke onto paper, by hand.',
        'Hold the paper and say the intention aloud, once.',
        'If you want, mark the paper with a minimal amount of your blood and '
            'let it dry completely.',
        'Keep the paper where you can see it, or close it and keep it where '
            'no one will disturb it.',
      ],
      withoutBlood:
          'Without blood, use your breath on the paper, the flame of a candle '
          'or simply your own handwriting. Consecration is the act of '
          'dedicating, and it does not depend on the material.',
      sections: [
        BloodLoreSection(
          title: 'Where it comes from',
          body:
              'A contemporary practice. Consecrating an object with something '
              'of the practitioner is an old gesture; the sigil as witchcraft '
              'uses it today comes from the twentieth century.',
        ),
      ],
      mentionsBlood: true,
      cta: BloodLoreCta(
        label: 'Open the sigil maker',
        link: BloodLoreLink.sigils,
      ),
    ),
    BloodLoreEntry(
      id: 'ritual-de-encerramento',
      category: BloodLoreCategory.practices,
      tag: BloodLoreTag.contemporary,
      emoji: '🍂',
      title: 'Ritual of ending',
      summary: 'Naming and releasing what has come to an end',
      intention: 'To name and release something that has come to an end.',
      materials: [
        'Paper and a pen',
        'A candle, if you want',
        'A safe container, if you are going to burn it',
      ],
      steps: [
        'Write, without trying to solve it, what you would rather not carry '
            'into the next turn.',
        'Read what you wrote once, aloud or in silence.',
        'Tear the paper, burn it in a safe container, or keep it closed until '
            'the next turn.',
        'If you want to keep writing, the Grimoire\'s Diary is the place.',
      ],
      sections: [
        BloodLoreSection(
          title: 'Where it comes from',
          body:
              'A contemporary practice. The symbolic tie between bleeding and '
              'release is a present-day reading, not a settled ancient '
              'tradition.',
        ),
        BloodLoreSection(
          title: 'One care',
          body:
              'If you burn it, use a container meant for that, away from '
              'curtains and anything that catches fire.',
        ),
      ],
      cta: BloodLoreCta(
        label: 'Write in the Diary',
        link: BloodLoreLink.diary,
      ),
    ),

    // ── Traditions and history ────────────────────────────────────────────
    BloodLoreEntry(
      id: 'filtro-de-sangue',
      category: BloodLoreCategory.traditions,
      tag: BloodLoreTag.documented,
      emoji: '📜',
      title: 'The menstrual blood philtre',
      summary:
          'The most recorded love practice — and why it does not become a '
          'tutorial',
      sections: [
        BloodLoreSection(
          title: 'What the records describe',
          body:
              'In trial papers, folk magic recipe books and folklore '
              'collections the same practice appears again and again: '
              'secretly placing a small amount of menstrual blood in the food '
              'or drink of a desired person, to create binding, desire or '
              'submission.',
        ),
        BloodLoreSection(
          title: 'The magical logic',
          body:
              'A substance belonging to the one casting the spell would be '
              'taken in by the target. Passing into their body, it would '
              'symbolically establish the link — the same idea that matter '
              'from the body ties people together, pushed to its limit.',
        ),
        BloodLoreSection(
          title: 'Why the Grimoire does not teach it',
          body:
              'Because the practice involves a bodily fluid, another '
              'person\'s food or drink, the absence of consent and a real '
              'health risk. Describing what history recorded is one thing; '
              'giving the steps is another.',
        ),
      ],
      cta: BloodLoreCta(
        label: 'Explore a charm of attraction',
        link: BloodLoreLink.entry,
        entryId: 'encanto-de-atracao',
      ),
    ),
    BloodLoreEntry(
      id: 'onde-os-registros-estao',
      category: BloodLoreCategory.traditions,
      tag: BloodLoreTag.documented,
      emoji: '🗂️',
      title: 'Where the records are',
      summary: 'How we know what we know — and what cannot be known',
      sections: [
        BloodLoreSection(
          title: 'The sources',
          body:
              'What is known about magic with menstrual blood comes mostly '
              'from three places: trial papers, where the practice is '
              'described by the accuser; folk magic recipe books and manuals; '
              'and folklore collections made between the nineteenth and '
              'twentieth centuries.',
        ),
        BloodLoreSection(
          title: 'What that distorts',
          body:
              'None of those sources is neutral. A trial records what the '
              'court wanted to hear; a folklore collector writes down what he '
              'understood. What reaches us is real practice seen from '
              'outside.',
        ),
        BloodLoreSection(
          title: 'What still stands',
          body:
              'Recurrence. When the same gesture shows up in sources that do '
              'not talk to each other, it is reasonable to say it existed. '
              'When it shows up once, it is an account — and that is how it '
              'is labelled here.',
        ),
      ],
    ),
  ],
);
