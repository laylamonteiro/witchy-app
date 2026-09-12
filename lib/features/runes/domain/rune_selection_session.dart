import 'dart:convert';

import '../data/models/rune_spread_model.dart';

/// A face-down stone. The ID is the invariant rune name; orientation is
/// fixed when the cloth is laid out, never by the gesture that picks it.
class HiddenRune {
  const HiddenRune({required this.id, required this.reversed});
  final String id;
  final bool reversed;
  Map<String, Object> toJson() => {'id': id, 'reversed': reversed};
}

/// One rune consultation: 1, 3, 5 or 9 stones chosen from the same 24.
class RuneSelectionSession {
  static const deckVersion = 'elder-futhark-24-v1';
  static const tool = 'runes';
  static const stoneCount = 24;

  RuneSelectionSession({
    required this.id,
    required this.userId,
    required this.spread,
    required this.question,
    required this.dayKey,
    required this.dayStart,
    required this.startedAt,
    required List<HiddenRune> deck,
    required List<String> selectedIds,
    this.resultId,
    this.resultSignature,
  }) : deck = List.unmodifiable(deck),
       selectedIds = List.unmodifiable(selectedIds) {
    if (deck.length != stoneCount ||
        deck.map((r) => r.id).toSet().length != stoneCount ||
        selectedIds.length > spread.runeCount ||
        selectedIds.toSet().length != selectedIds.length ||
        selectedIds.any((id) => !deck.any((r) => r.id == id))) {
      throw const FormatException('Invalid rune selection');
    }
    if ((resultId != null) != (resultSignature != null) ||
        (resultId != null && !isComplete)) {
      throw const FormatException('Incomplete rune result');
    }
  }

  final String id;
  final String userId;
  final RuneSpreadType spread;
  /// Original text, possibly empty: runes accept a consultation without one.
  final String question;
  final String dayKey;
  final DateTime dayStart;
  final DateTime startedAt;
  final List<HiddenRune> deck;
  final List<String> selectedIds;
  final String? resultId;
  final String? resultSignature;

  int get stonesNeeded => spread.runeCount;
  bool get isComplete => selectedIds.length == stonesNeeded;
  bool get isCommitted => resultId != null;
  int positionOf(String id) => deck.indexWhere((r) => r.id == id);
  HiddenRune stone(String id) => deck.firstWhere((r) => r.id == id);

  static String normalize(String question) => question.trim().toLowerCase();

  factory RuneSelectionSession.fromRow(Map<String, Object?> row) {
    if (row['tool'] != tool || row['deck_version'] != deckVersion) {
      throw const FormatException('Unsupported rune deck');
    }
    final stones = (jsonDecode(row['deck_json'] as String) as List).cast<Map>();
    return RuneSelectionSession(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      spread: RuneSpreadType.values.byName(row['spread'] as String),
      question: row['question'] as String,
      dayKey: row['day_key'] as String,
      dayStart: DateTime.fromMillisecondsSinceEpoch(row['day_start'] as int),
      startedAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      deck: [for (final s in stones)
        HiddenRune(id: s['id'] as String, reversed: s['reversed'] as bool)],
      selectedIds:
          (jsonDecode(row['selected_json'] as String) as List).cast<String>(),
      resultId: row['result_id'] as String?,
      resultSignature: row['result_signature'] as String?,
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
