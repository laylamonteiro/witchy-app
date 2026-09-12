import '../../../l10n/generated/app_localizations.dart';

/// Os humores oferecidos na folha do dia, pelos ids que vão para
/// `MenstrualDay.mood` — o mesmo contrato dos sintomas: o que se grava é o
/// id, e o rótulo é resolvido no idioma de quem lê.
///
/// A lista é curta de propósito, e os rótulos são neutros de gênero: a
/// página é oferecida ao feminino e ao neutro.
const menstrualMoods = [
  'light',
  'sensitive',
  'irritable',
  'sad',
  'strong',
  'at_peace',
];

/// O rótulo de um humor. Um id desconhecido volta como veio: o humor era
/// texto livre antes de virar chip, e um registro antigo com a palavra dela
/// continua legível em todo lugar que a mostra.
String menstrualMoodLabel(AppLocalizations l10n, String mood) => switch (mood) {
      'light' => l10n.menstrualMoodLight,
      'sensitive' => l10n.menstrualMoodSensitive,
      'irritable' => l10n.menstrualMoodIrritable,
      'sad' => l10n.menstrualMoodSad,
      'strong' => l10n.menstrualMoodStrong,
      'at_peace' => l10n.menstrualMoodAtPeace,
      _ => mood,
    };
