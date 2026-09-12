import 'dart:convert';

import 'daily_tarot_session.dart';

/// A three-card or cross reading, with every hidden face fixed at preparation.
class TarotSpreadSession {
  static const counts = {'threeCards': 3, 'cross': 5};

  TarotSpreadSession({
    required this.id,
    required this.userId,
    required this.spread,
    required this.question,
    required this.dayKey,
    required this.dayStart,
    required this.startedAt,
    required List<HiddenTarotCard> deck,
    required List<String> selectedIds,
    this.resultId,
    this.resultSignature,
  }) : deck = List.unmodifiable(deck),
       selectedIds = List.unmodifiable(selectedIds) {
    if (!counts.containsKey(spread) || deck.length != 78 ||
        deck.map((c) => c.id).toSet().length != 78 ||
        selectedIds.length > counts[spread]! ||
        selectedIds.toSet().length != selectedIds.length ||
        selectedIds.any((id) => !deck.any((c) => c.id == id))) {
      throw const FormatException('Invalid spread selection');
    }
    if ((resultId != null) != (resultSignature != null) ||
        (resultId != null && !isComplete)) {
      throw const FormatException('Incomplete spread result');
    }
  }

  final String id;
  final String userId;
  final String spread;
  final String question;
  final String dayKey;
  final DateTime dayStart;
  final DateTime startedAt;
  final List<HiddenTarotCard> deck;
  final List<String> selectedIds;
  final String? resultId;
  final String? resultSignature;

  int get cardCount => counts[spread]!;
  bool get isComplete => selectedIds.length == cardCount;
  bool get isCommitted => resultId != null;
  int positionOf(String id) => deck.indexWhere((c) => c.id == id);
  HiddenTarotCard card(String id) => deck.firstWhere((c) => c.id == id);

  factory TarotSpreadSession.fromRow(Map<String, Object?> row) {
    if (row['tool'] != 'tarot' ||
        row['deck_version'] != DailyTarotSession.deckVersion) {
      throw const FormatException('Unsupported selection deck');
    }
    final cards = (jsonDecode(row['deck_json'] as String) as List).cast<Map>();
    return TarotSpreadSession(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      spread: row['spread'] as String,
      question: row['question'] as String,
      dayKey: row['day_key'] as String,
      dayStart: DateTime.fromMillisecondsSinceEpoch(row['day_start'] as int),
      startedAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      deck: [for (final c in cards)
        HiddenTarotCard(id: c['id'] as String, reversed: c['reversed'] as bool)],
      selectedIds: (jsonDecode(row['selected_json'] as String) as List).cast<String>(),
      resultId: row['result_id'] as String?,
      resultSignature: row['result_signature'] as String?,
    );
  }
}

class TarotSpreadUpdate {
  const TarotSpreadUpdate(this.session, {this.created = false});
  final TarotSpreadSession session;
  final bool created;
}
