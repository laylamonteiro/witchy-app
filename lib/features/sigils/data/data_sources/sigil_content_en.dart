/// Static content for the Sigils feature — English.
///
/// Only the didactic/interpretive CONTENT of the method lives here
/// (explanations, technique steps, intention suggestions). UI chrome
/// (AppBar titles, buttons, short labels, snackbars) stays in the l10n ARBs.
///
/// Keep the three files (`sigil_content_pt/en/es.dart`) structurally
/// identical, with the same number of items in each list — parity is
/// checked in `test/sigil_content_parity_test.dart`.
library;

/// What a sigil is (didactic explanation on the intro card).
const String sigilWhatIsDescEn =
    'Sigils are magical symbols created to manifest intentions. '
    'By turning words into abstract symbols, you create an energetic mark '
    'that carries the power of your will without revealing your intention '
    'to others.';

/// How the method works (step 1 introduction).
const String sigilHowIntroEn =
    'Set your intention, choose a word that represents it, and the app '
    'will automatically create your unique sigil.';

/// Suggested intention words.
const List<String> sigilIntentionExamplesEn = [
  'Prosperity',
  'Protection',
  'Healing',
  'Confidence',
  'Intuition',
];

/// Tip on choosing the intention word.
const String sigilWordTipEn =
    'Tip: Choose positive, specific words that resonate with you.';

/// Introduction to the letter-simplification explanation (step 2).
const String sigilSimplifiedIntroEn =
    'Your word was simplified following sigil tradition:';

/// Steps of the simplification technique (they describe the processing —
/// the processing itself is invariant and lives in `SigilWheel`).
const List<String> sigilSimplificationStepsEn = [
  '1. Accents were normalized',
  '2. Spaces and symbols were removed',
  '3. Duplicate letters were removed (only the first occurrence is kept)',
];

/// Note about the Witches' Wheel (step 2).
const String sigilWheelNoteEn =
    "This simplified sequence will be connected on the Witches' Wheel "
    "to form your sigil's magical symbol.";

/// How to use the finished sigil (step 3) — title + description per step.
const List<({String title, String description})> sigilUsageStepsEn = [
  (
    title: '1. Copy this drawing',
    description:
        'Reproduce the tracing in your notebook, altar, candle, or ritual paper.',
  ),
  (
    title: '2. Personalize',
    description:
        'Simplify, rotate, or add details. Making it yours is part of the magic.',
  ),
  (
    title: '3. Activate the sigil',
    description:
        'Use it in meditation, burn it in ritual, or carry it with you to focus your intention.',
  ),
];

/// Closing interpretive reminder (step 3).
const String sigilRememberNoteEn =
    'Remember: the magic is in your intention and in the act of creating, '
    'not only in the final drawing.';
