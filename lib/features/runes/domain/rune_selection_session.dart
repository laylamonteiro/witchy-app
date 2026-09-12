import 'dart:convert';

import '../data/models/rune_spread_model.dart';

class HiddenRune {
  const HiddenRune({required this.id, required this.reversed});
  final String id;
  final bool reversed;
  Map<String, Object> toJson() => {'id': id, 'reversed': reversed};
}

/// The stone's place and orientation belong to the consultation, not its art.
class RuneSelectionSession {
  static const deckVersion = 'elder-futhark-24-v1';

  RuneSelectionSession({
    required this.id,
    required this.userId,
    required this.spread,
    required this.question,
    required this.dayKey,
    required this.startedAt,
    required List<HiddenRune> deck,
    required List<String> selectedIds,
    this.resultId,
  }) : deck = List.unmodifiable(deck),
       selectedIds = List.unmodifiable(selectedIds) {
    if (deck.length != 24 || deck.map((r) => r.id).toSet().length != 24 ||
        selectedIds.length > spread.runeCount ||
        selectedIds.toSet().length != selectedIds.length ||
        selectedIds.any((id) => !deck.any((r) => r.id == id)) ||
        (isCommitted && !isComplete)) {
      throw const FormatException('Invalid rune selection');
    }
  }

  final String id;
  final String userId;
  final RuneSpreadType spread;
  final String question;
  final String dayKey;
  final DateTime startedAt;
  final List<HiddenRune> deck;
  final List<String> selectedIds;
  final String? resultId;

  bool get isComplete => selectedIds.length == spread.runeCount;
  bool get isCommitted => resultId != null;
  int positionOf(String id) => deck.indexWhere((r) => r.id == id);
  HiddenRune stone(String id) => deck.firstWhere((r) => r.id == id);

  factory RuneSelectionSession.fromRow(Map<String, Object?> row) {
    if (row['tool'] != 'runes' || row['deck_version'] != deckVersion) {
      throw const FormatException('Unsupported rune selection');
    }
    final deck = (jsonDecode(row['deck_json'] as String) as List).cast<Map>();
    return RuneSelectionSession(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      spread: RuneSpreadType.values.byName(row['spread'] as String),
      question: row['question'] as String,
      dayKey: row['day_key'] as String,
      startedAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      deck: [for (final r in deck)
        HiddenRune(id: r['id'] as String, reversed: r['reversed'] as bool)],
      selectedIds: (jsonDecode(row['selected_json'] as String) as List).cast<String>(),
      resultId: row['result_id'] as String?,
    );
  }
}

class RuneSelectionUpdate {
  const RuneSelectionUpdate(this.session, {this.created = false});
  final RuneSelectionSession session;
  final bool created;
}

class RuneQuotaExceeded implements Exception {
  const RuneQuotaExceeded();
}

class RuneAccountChanged implements Exception {
  const RuneAccountChanged();
}
