import 'dart:convert';

class HiddenTarotCard {
  const HiddenTarotCard({required this.id, required this.reversed});
  final String id;
  final bool reversed;
  Map<String, Object> toJson() => {'id': id, 'reversed': reversed};
}

/// Card identity and orientation are fixed before the fan is shown.
class DailyTarotSession {
  static const deckVersion = 'rider-waite-78-v1';

  DailyTarotSession({
    required this.id,
    required this.userId,
    required this.question,
    required this.dayKey,
    required this.dayStart,
    required this.dayEnd,
    required List<HiddenTarotCard> deck,
    this.selectedId,
    this.resultId,
    this.resultSignature,
  }) : deck = List.unmodifiable(deck) {
    if (deck.isEmpty || deck.map((c) => c.id).toSet().length != deck.length) {
      throw const FormatException('Invalid session deck');
    }
    if (selectedId != null && !deck.any((c) => c.id == selectedId)) {
      throw const FormatException('Selected card is not in the deck');
    }
    if ((resultId != null) != (resultSignature != null) ||
        (resultId != null && selectedId == null)) {
      throw const FormatException('Incomplete committed session');
    }
  }

  final String id;
  final String userId;
  final String question;
  final String dayKey;
  final DateTime dayStart;
  final DateTime dayEnd;
  final List<HiddenTarotCard> deck;
  final String? selectedId;
  final String? resultId;
  final String? resultSignature;

  bool get isCommitted => resultId != null;
  HiddenTarotCard card(String id) => deck.firstWhere((c) => c.id == id);

  factory DailyTarotSession.fromRow(Map<String, Object?> row) {
    if (row['deck_version'] != deckVersion) {
      throw const FormatException('Unsupported session deck version');
    }
    final cards = (jsonDecode(row['deck_json'] as String) as List)
        .cast<Map<String, dynamic>>();
    final selected =
        (jsonDecode(row['selected_json'] as String) as List).cast<String>();
    if (selected.length > 1) throw const FormatException('Invalid daily selection');
    return DailyTarotSession(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      question: row['question'] as String,
      dayKey: row['day_key'] as String,
      dayStart: DateTime.fromMillisecondsSinceEpoch(row['day_start'] as int),
      dayEnd: DateTime.fromMillisecondsSinceEpoch(row['day_end'] as int),
      deck: [for (final c in cards)
        HiddenTarotCard(id: c['id'] as String, reversed: c['reversed'] as bool)],
      selectedId: selected.isEmpty ? null : selected.single,
      resultId: row['result_id'] as String?,
      resultSignature: row['result_signature'] as String?,
    );
  }
}

class DailyTarotCommit {
  const DailyTarotCommit(this.session, {required this.created});
  final DailyTarotSession session;
  final bool created;
}

class TarotQuotaExceeded implements Exception {
  const TarotQuotaExceeded();
}

class TarotAccountChanged implements Exception {
  const TarotAccountChanged();
}
