import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/content/content_locale.dart';
import '../../../divination/data/models/oracle_card_model.dart';
import '../../../divination/data/models/pendulum_model.dart';
import '../../../runes/data/models/rune_spread_model.dart';

/// Strings do idioma atual sem BuildContext (mesmo padrão dos modelos de
/// adivinhação): o texto é "assado" no momento do salvamento.
AppLocalizations get _l10n =>
    lookupAppLocalizations(ContentLocale.instance.locale);

/// Título + conteúdo prontos para virar uma entrada do acervo.
typedef ArchiveEntry = ({String title, String content});

/// Compõe a página de texto de uma leitura para o acervo "Meus Registros".
///
/// Formato compatível com o renderizador dos registros: linhas `✦ rótulo`
/// viram destaque, o texto seguinte é o corpo.
abstract final class ReadingArchiveComposer {
  static ArchiveEntry runes(RuneReading reading) {
    final l10n = _l10n;
    final parts = <String>[];
    if (reading.question.trim().isNotEmpty &&
        reading.question != l10n.runesNoQuestion) {
      parts.add('✦ ${l10n.readingQuestionLabel}\n${reading.question}');
    }
    for (final position in reading.positions) {
      final rune = position.rune;
      final reversed =
          position.isReversed ? ' (${l10n.runeReversedMark})' : '';
      parts.add(
        '✦ ${position.positionMeaning} — ${rune.symbol} ${rune.name}$reversed'
        '\n${rune.description}',
      );
    }
    return (
      title: '${l10n.runesReadingTitle} — ${reading.spreadType.displayName}',
      content: parts.join('\n\n'),
    );
  }

  static ArchiveEntry pendulum(PendulumConsultation consultation) {
    final l10n = _l10n;
    final answer = consultation.answer;
    final content = '✦ ${l10n.pendulumYourQuestion}\n${consultation.question}'
        '\n\n✦ ${l10n.readingAnswerLabel}\n'
        '${answer.emoji} ${answer.displayName}\n${answer.message}';
    return (title: l10n.pendulumTitle, content: content);
  }

  static ArchiveEntry oracle(OracleReading reading) {
    final l10n = _l10n;
    final parts = <String>[
      for (final position in reading.positions)
        '✦ ${position.positionMeaning} — '
            '${position.card.emoji} ${position.card.name}'
            '\n${position.card.message}\n${position.card.guidance}',
    ];
    return (
      title: '${l10n.oracleTitle} — ${reading.spreadType.displayName}',
      content: parts.join('\n\n'),
    );
  }
}
