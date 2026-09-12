import 'dart:convert';

import '../data/models/oracle_card_model.dart';

/// One Oracle consultation: 1, 3 or 5 cards chosen face down from the 44.
/// Card IDs are the invariant catalog integers, stored as strings so the
/// selection surface shared with the tarot can handle them unchanged.
class OracleSelectionSession {
  static const deckVersion = 'oracle-44-v1';
  static const tool = 'oracle';
  static const cardCount = 44;

  OracleSelectionSession({
    required this.id,
    required this.userId,
    required this.spread,
    required this.dayKey,
    required this.dayStart,
    required this.startedAt,
    required List<String> deck,
    required List<String> selectedIds,
    this.resultId,
    this.resultSignature,
  }) : deck = List.unmodifiable(deck),
       selectedIds = List.unmodifiable(selectedIds) {
    if (deck.length != cardCount ||
        deck.toSet().length != cardCount ||
        selectedIds.length > spread.cardCount ||
        selectedIds.toSet().length != selectedIds.length ||
        selectedIds.any((id) => !deck.contains(id))) {
      throw const FormatException('Invalid oracle selection');
    }
    if ((resultId != null) != (resultSignature != null) ||
        (resultId != null && !isComplete)) {
      throw const FormatException('Incomplete oracle result');
    }
  }

  final String id;
  final String userId;
  final OracleSpreadType spread;
  final String dayKey;
  final DateTime dayStart;
  final DateTime startedAt;
  final List<String> deck;
  final List<String> selectedIds;
  final String? resultId;
  final String? resultSignature;

  int get cardsNeeded => spread.cardCount;
  bool get isComplete => selectedIds.length == cardsNeeded;
  bool get isCommitted => resultId != null;
  int positionOf(String id) => deck.indexOf(id);

  static String idOf(OracleCard card) => '${card.id}';

  factory OracleSelectionSession.fromRow(Map<String, Object?> row) {
    if (row['tool'] != tool || row['deck_version'] != deckVersion) {
      throw const FormatException('Unsupported oracle deck');
    }
    return OracleSelectionSession(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      spread: OracleSpreadType.values.byName(row['spread'] as String),
      dayKey: row['day_key'] as String,
      dayStart: DateTime.fromMillisecondsSinceEpoch(row['day_start'] as int),
      startedAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      deck: (jsonDecode(row['deck_json'] as String) as List).cast<String>(),
      selectedIds:
          (jsonDecode(row['selected_json'] as String) as List).cast<String>(),
      resultId: row['result_id'] as String?,
      resultSignature: row['result_signature'] as String?,
    );
  }
}

/// Outcome of a choice. [newDiscoveries] lists the catalog IDs first seen
/// in this very reading, for the album (P11); never XP.
class OracleSelectionUpdate {
  const OracleSelectionUpdate(this.session,
      {this.created = false, this.newDiscoveries = const []});
  final OracleSelectionSession session;
  final bool created;
  final List<int> newDiscoveries;
}

class OracleQuotaExceeded implements Exception {
  const OracleQuotaExceeded();
}

class OracleAccountChanged implements Exception {
  const OracleAccountChanged();
}
