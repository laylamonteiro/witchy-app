import 'dart:convert';

import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/content/content_locale.dart';
import '../data_sources/runes_data.dart';
import 'rune_model.dart';

/// Strings do idioma atual sem BuildContext (modelos são usados fora da
/// árvore de widgets); o locale vem do ContentLocale, setado pelo
/// LanguageProvider.
AppLocalizations get _l10n =>
    lookupAppLocalizations(ContentLocale.instance.locale);


enum RuneSpreadType {
  single,
  threeCast,
  nordicCross,
  nineWorlds;

  String get displayName {
    switch (this) {
      case RuneSpreadType.single:
        return _l10n.runeSpreadSingle;
      case RuneSpreadType.threeCast:
        return _l10n.runeSpreadThreeCast;
      case RuneSpreadType.nordicCross:
        return _l10n.runeSpreadNordicCross;
      case RuneSpreadType.nineWorlds:
        return _l10n.runeSpreadNineWorlds;
    }
  }

  String get description {
    switch (this) {
      case RuneSpreadType.single:
        return _l10n.runeSpreadSingleDesc;
      case RuneSpreadType.threeCast:
        return _l10n.runeSpreadThreeCastDesc;
      case RuneSpreadType.nordicCross:
        return _l10n.runeSpreadNordicCrossDesc;
      case RuneSpreadType.nineWorlds:
        return _l10n.runeSpreadNineWorldsDesc;
    }
  }

  int get runeCount {
    switch (this) {
      case RuneSpreadType.single:
        return 1;
      case RuneSpreadType.threeCast:
        return 3;
      case RuneSpreadType.nordicCross:
        return 5;
      case RuneSpreadType.nineWorlds:
        return 9;
    }
  }

  String getPositionMeaning(int position) {
    switch (this) {
      case RuneSpreadType.single:
        return _l10n.runePosMessage;
      case RuneSpreadType.threeCast:
        return [_l10n.tarotPosPast, _l10n.tarotPosPresent, _l10n.tarotPosFuture][position];
      case RuneSpreadType.nordicCross:
        return [
          _l10n.runePosSituation,
          _l10n.tarotPosChallenge,
          _l10n.tarotPosPast,
          _l10n.tarotPosFuture,
          _l10n.runePosResult
        ][position];
      case RuneSpreadType.nineWorlds:
        return [
          _l10n.runePosInnerSelf,
          _l10n.runePosMind,
          _l10n.runePosSpirit,
          _l10n.runePosResources,
          _l10n.runePosObstacles,
          _l10n.runePosOpportunities,
          _l10n.tarotPosPast,
          _l10n.tarotPosPresent,
          _l10n.tarotPosFuture
        ][position];
    }
  }
}

class RunePosition {
  final int position;
  final RuneModel rune;
  final bool isReversed;
  final String positionMeaning;

  const RunePosition({
    required this.position,
    required this.rune,
    required this.isReversed,
    required this.positionMeaning,
  });

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'rune': rune.toJson(),
      'isReversed': isReversed,
      'positionMeaning': positionMeaning,
    };
  }

  factory RunePosition.fromJson(Map<String, dynamic> json) {
    return RunePosition(
      position: json['position'],
      rune: Rune.fromJson(json['rune']),
      isReversed: json['isReversed'],
      positionMeaning: json['positionMeaning'],
    );
  }
}

class RuneReading {
  final String id;
  final String question;
  final RuneSpreadType spreadType;
  final List<RunePosition> positions;
  final String? interpretation;
  final DateTime date;

  const RuneReading({
    required this.id,
    required this.question,
    required this.spreadType,
    required this.positions,
    this.interpretation,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'spreadType': spreadType.name,
      'positions': positions.map((p) => p.toJson()).toList(),
      'interpretation': interpretation,
      'date': date.toIso8601String(),
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory RuneReading.fromJson(Map<String, dynamic> json) {
    return RuneReading(
      id: json['id'],
      question: json['question'],
      spreadType: RuneSpreadType.values.firstWhere(
        (e) => e.name == json['spreadType'],
      ),
      positions: (json['positions'] as List)
          .map((p) => RunePosition.fromJson(p))
          .toList(),
      interpretation: json['interpretation'],
      date: DateTime.parse(json['date']),
    );
  }

  factory RuneReading.fromJsonString(String jsonString) {
    return RuneReading.fromJson(jsonDecode(jsonString));
  }
}
