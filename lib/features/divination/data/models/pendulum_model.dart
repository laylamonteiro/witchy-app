import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/content/content_locale.dart';

/// Strings do idioma atual sem BuildContext (modelos são usados fora da
/// árvore de widgets); o locale vem do ContentLocale, setado pelo
/// LanguageProvider.
AppLocalizations get _l10n =>
    lookupAppLocalizations(ContentLocale.instance.locale);

enum PendulumAnswer {
  yes,
  no,
  maybe;

  String get displayName {
    switch (this) {
      case PendulumAnswer.yes:
        return _l10n.pendulumYes;
      case PendulumAnswer.no:
        return _l10n.pendulumNo;
      case PendulumAnswer.maybe:
        return _l10n.pendulumMaybe;
    }
  }

  String get message {
    switch (this) {
      case PendulumAnswer.yes:
        return _l10n.pendulumYesMsg;
      case PendulumAnswer.no:
        return _l10n.pendulumNoMsg;
      case PendulumAnswer.maybe:
        return _l10n.pendulumMaybeMsg;
    }
  }

  String get emoji {
    switch (this) {
      case PendulumAnswer.yes:
        return '✅';
      case PendulumAnswer.no:
        return '❌';
      case PendulumAnswer.maybe:
        return '❓';
    }
  }
}

class PendulumConsultation {
  final String id;
  final String question;
  final PendulumAnswer answer;
  final DateTime date;

  const PendulumConsultation({
    required this.id,
    required this.question,
    required this.answer,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer.name,
      'date': date.toIso8601String(),
    };
  }

  factory PendulumConsultation.fromJson(Map<String, dynamic> json) {
    return PendulumConsultation(
      id: json['id'],
      question: json['question'],
      answer: PendulumAnswer.values.firstWhere(
        (e) => e.name == json['answer'],
      ),
      date: DateTime.parse(json['date']),
    );
  }
}
