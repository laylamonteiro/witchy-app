import 'dart:convert';

import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/content/content_locale.dart';

/// Strings do idioma atual sem BuildContext (modelos são usados fora da
/// árvore de widgets); o locale vem do ContentLocale, setado pelo
/// LanguageProvider.
AppLocalizations get _l10n =>
    lookupAppLocalizations(ContentLocale.instance.locale);


class OracleCard {
  final int id;
  final String name;
  final String message;
  final String emoji;
  final String guidance;
  final List<String> keywords;

  const OracleCard({
    required this.id,
    required this.name,
    required this.message,
    required this.emoji,
    required this.guidance,
    required this.keywords,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'message': message,
      'emoji': emoji,
      'guidance': guidance,
      'keywords': keywords,
    };
  }

  factory OracleCard.fromJson(Map<String, dynamic> json) {
    return OracleCard(
      id: json['id'],
      name: json['name'],
      message: json['message'],
      emoji: json['emoji'],
      guidance: json['guidance'],
      keywords: List<String>.from(json['keywords']),
    );
  }
}

enum OracleSpreadType {
  daily,
  threeCard,
  weeklyGuidance;

  String get displayName {
    switch (this) {
      case OracleSpreadType.daily:
        return _l10n.oracleSpreadDaily;
      case OracleSpreadType.threeCard:
        return _l10n.oracleSpreadThreeCard;
      case OracleSpreadType.weeklyGuidance:
        return _l10n.oracleSpreadWeekly;
    }
  }

  String get description {
    switch (this) {
      case OracleSpreadType.daily:
        return _l10n.oracleSpreadDailyDesc;
      case OracleSpreadType.threeCard:
        return _l10n.oracleSpreadThreeCardDesc;
      case OracleSpreadType.weeklyGuidance:
        return _l10n.oracleSpreadWeeklyDesc;
    }
  }

  int get cardCount {
    switch (this) {
      case OracleSpreadType.daily:
        return 1;
      case OracleSpreadType.threeCard:
        return 3;
      case OracleSpreadType.weeklyGuidance:
        return 5;
    }
  }

  String getPositionMeaning(int position) {
    switch (this) {
      case OracleSpreadType.daily:
        return _l10n.oraclePosDayMessage;
      case OracleSpreadType.threeCard:
        return [_l10n.tarotPosPast, _l10n.tarotPosPresent, _l10n.tarotPosFuture][position];
      case OracleSpreadType.weeklyGuidance:
        return [
          _l10n.oraclePosMonTue,
          _l10n.oraclePosWed,
          _l10n.oraclePosThuFri,
          _l10n.oraclePosWeekend,
          _l10n.oraclePosFocus
        ][position];
    }
  }
}

class OracleCardPosition {
  final int position;
  final OracleCard card;
  final String positionMeaning;

  const OracleCardPosition({
    required this.position,
    required this.card,
    required this.positionMeaning,
  });

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'card': card.toJson(),
      'positionMeaning': positionMeaning,
    };
  }

  factory OracleCardPosition.fromJson(Map<String, dynamic> json) {
    return OracleCardPosition(
      position: json['position'],
      card: OracleCard.fromJson(json['card']),
      positionMeaning: json['positionMeaning'],
    );
  }
}

class OracleReading {
  final String id;
  final OracleSpreadType spreadType;
  final List<OracleCardPosition> positions;
  final DateTime date;

  const OracleReading({
    required this.id,
    required this.spreadType,
    required this.positions,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spreadType': spreadType.name,
      'positions': positions.map((p) => p.toJson()).toList(),
      'date': date.toIso8601String(),
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory OracleReading.fromJson(Map<String, dynamic> json) {
    return OracleReading(
      id: json['id'],
      spreadType: OracleSpreadType.values.firstWhere(
        (e) => e.name == json['spreadType'],
      ),
      positions: (json['positions'] as List)
          .map((p) => OracleCardPosition.fromJson(p))
          .toList(),
      date: DateTime.parse(json['date']),
    );
  }

  factory OracleReading.fromJsonString(String jsonString) {
    return OracleReading.fromJson(jsonDecode(jsonString));
  }
}
