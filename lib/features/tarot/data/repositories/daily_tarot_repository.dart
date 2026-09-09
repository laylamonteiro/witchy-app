import 'dart:convert';
import 'dart:math';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/services/usage_coordinator.dart';
import '../../domain/daily_tarot_session.dart';
import '../../domain/regra_da_carta_do_dia.dart';
import '../models/tarot_card_model.dart';
import 'tarot_day_repository.dart';
import 'tarot_reading_repository.dart';

/// A resumable daily choice. Animation never selects, records or consumes.
class DailyTarotRepository {
  DailyTarotRepository({DatabaseHelper? dbHelper, Random? random})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _random = random ?? Random();

  final DatabaseHelper _dbHelper;
  final Random _random;
  static const deckVersion = DailyTarotSession.deckVersion;

  Future<DailyTarotSession> prepare({
    required String userId,
    required String question,
    required List<TarotCard> catalog,
    required bool premium,
    required int legacyOracleUsed,
    required int freeLimit,
    DateTime? now,
  }) async {
    final asked = question.trim();
    if (asked.isEmpty) throw ArgumentError.value(question, 'question');
    if (catalog.length != 78 || catalog.map((c) => c.id).toSet().length != 78) {
      throw const FormatException('Expected the complete tarot catalog');
    }
    final instant = now ?? DateTime.now();
    final key = UsageCoordinator.dayKey(instant);
    final start = DateTime(instant.year, instant.month, instant.day);
    final end = DateTime(instant.year, instant.month, instant.day + 1);
    final seed = await TarotDayRepository.legacySeed(userId, instant);
    final db = await _dbHelper.database;
    return db.transaction((txn) async {
      final day = await TarotDayRepository.ensureIn(txn,
          userId: userId, dayKey: key, seed: seed);
      await UsageCoordinator.importBalance(txn,
          userId: userId, dayKey: key, legacyUsed: legacyOracleUsed);

      final existing = await txn.query('selection_sessions',
          where: 'user_id = ? AND tool = ? AND spread = ? '
              'AND day_key = ? AND normalized_question = ?',
          whereArgs: [userId, 'tarot', 'daily', key, asked.toLowerCase()],
          limit: 1);
      if (existing.isNotEmpty) return DailyTarotSession.fromRow(existing.single);

      // Adopt an already drawn daily card before offering a new choice.
      // The upper bound prevents a future/other-day record from matching.
      final oldDraws = await txn.query('tarot_readings',
          where: 'user_id = ? AND spread_type = ? AND date >= ? AND date < ?',
          whereArgs: [userId, 'daily', start.millisecondsSinceEpoch,
            end.millisecondsSinceEpoch],
          orderBy: 'date ASC, id ASC');
      Map<String, Object?>? legacy;
      for (final row in oldDraws) {
        if ((row['question'] as String?)?.trim().toLowerCase() ==
            asked.toLowerCase()) {
          legacy = row;
          break;
        }
      }
      if (legacy == null) {
        final used = await UsageCoordinator.usedIn(txn,
            userId: userId, dayKey: key);
        _checkQuota(premium, day.dailyQuestion, asked, used, freeLimit);
      }

      final cards = [...catalog]..shuffle(_random);
      final deck = [for (final card in cards)
        HiddenTarotCard(id: card.id, reversed: _random.nextInt(4) == 0)];
      String? selectedId;
      String? legacySignature;
      if (legacy != null) {
        final payload = jsonDecode(legacy['reading_data'] as String)
            as Map<String, dynamic>;
        final recorded = payload['cards'] as List;
        if (recorded.length != 1) {
          throw const FormatException('Invalid existing daily reading');
        }
        final saved = recorded.single as Map<String, dynamic>;
        final card = catalog.firstWhere((c) =>
            (c.suit.name == saved['suit'] && c.number == saved['number']) ||
            (saved['suit'] == null && c.name == saved['name']));
        selectedId = card.id;
        final index = deck.indexWhere((c) => c.id == selectedId);
        deck[index] = HiddenTarotCard(
            id: card.id, reversed: saved['reversed'] == true);
        legacySignature = legacy['signature'] as String?;
        if (legacySignature == null) {
          legacySignature = 'daily-legacy:${legacy['id']}';
          await txn.update('tarot_readings', {'signature': legacySignature},
              where: 'id = ? AND user_id = ?',
              whereArgs: [legacy['id'], userId]);
        }
      }

      final row = <String, Object?>{
        'id': const Uuid().v4(),
        'user_id': userId,
        'tool': 'tarot',
        'spread': 'daily',
        'day_key': key,
        'day_start': start.millisecondsSinceEpoch,
        'day_end': end.millisecondsSinceEpoch,
        'question': asked,
        'normalized_question': asked.toLowerCase(),
        'deck_version': deckVersion,
        'deck_json': jsonEncode(deck.map((c) => c.toJson()).toList()),
        'selected_json': jsonEncode([if (selectedId != null) selectedId]),
        'result_id': legacy?['id'],
        'result_signature': legacySignature,
        'created_at': instant.millisecondsSinceEpoch,
        'updated_at': instant.millisecondsSinceEpoch,
      };
      await txn.insert('selection_sessions', row);
      // Remember a draft's question without charging or moving the quota's
      // remembered question. Reopening the app can resume this same fan.
      await txn.update('tarot_day_state', {'last_question': asked},
          where: 'user_id = ? AND day_key = ?', whereArgs: [userId, key]);
      return DailyTarotSession.fromRow(row);
    });
  }

  Future<DailyTarotCommit> selectAndCommit({
    required String userId,
    required String sessionId,
    required String cardId,
    required List<TarotCard> catalog,
    required String positionLabel,
    required bool Function() isCurrentUser,
    required bool Function() isPremium,
    required int freeLimit,
  }) async {
    final db = await _dbHelper.database;
    // Persist the choice first: a result-write failure must not allow a
    // different card on retry, even after the process is restarted.
    await db.transaction((txn) async {
      _checkAccount(isCurrentUser);
      final session = await _read(txn, userId, sessionId);
      if (session.isCommitted || session.selectedId != null) return;
      session.card(cardId); // Validate membership; never redraw here.
      _checkAccount(isCurrentUser);
      await txn.update('selection_sessions',
          {'selected_json': jsonEncode([cardId]),
            'updated_at': DateTime.now().millisecondsSinceEpoch},
          where: 'id = ? AND user_id = ?', whereArgs: [sessionId, userId]);
    });

    return db.transaction((txn) async {
      _checkAccount(isCurrentUser);
      final session = await _read(txn, userId, sessionId);
      if (session.isCommitted) return DailyTarotCommit(session, created: false);
      final selected = session.card(session.selectedId!);
      final card = catalog.firstWhere((c) => c.id == selected.id);
      final day = await TarotDayRepository.ensureIn(txn,
          userId: userId, dayKey: session.dayKey, seed: const TarotDayState());
      final used = await UsageCoordinator.usedIn(txn,
          userId: userId, dayKey: session.dayKey);
      _checkAccount(isCurrentUser);
      final decision = _checkQuota(
          isPremium(), day.dailyQuestion, session.question, used, freeLimit);
      if (decision == DecisaoDaTiragem.cobrar) {
        await UsageCoordinator.recordIn(txn, userId: userId,
            dayKey: session.dayKey, operationId: session.id);
      }
      final signature = 'daily-session:${session.id}';
      final resultId = await TarotReadingRepository(dbHelper: _dbHelper)
          .recordDraw(
        userId: userId,
        spreadName: 'daily',
        signature: signature,
        drawn: [TarotDrawnCard(card: card, isReversed: selected.reversed,
            positionLabel: positionLabel)],
        question: session.question,
        executor: txn,
        sessionId: session.id,
        date: session.dayStart,
      );
      await txn.update('tarot_day_state', {
        if (decision == DecisaoDaTiragem.cobrar || day.dailyQuestion == null)
          'daily_question': session.question.toLowerCase(),
        'last_question': session.question,
      }, where: 'user_id = ? AND day_key = ?',
          whereArgs: [userId, session.dayKey]);
      _checkAccount(isCurrentUser);
      await txn.update('selection_sessions', {
        'result_id': resultId,
        'result_signature': signature,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ? AND user_id = ?', whereArgs: [session.id, userId]);
      return DailyTarotCommit(await _read(txn, userId, sessionId), created: true);
    });
  }

  Future<String?> interpretation(DailyTarotSession session) async {
    if (!session.isCommitted) return null;
    final db = await _dbHelper.database;
    final rows = await db.query('tarot_readings', columns: ['reading_data'],
        where: 'id = ? AND user_id = ?',
        whereArgs: [session.resultId, session.userId], limit: 1);
    if (rows.isEmpty) return null;
    final data = jsonDecode(rows.single['reading_data'] as String) as Map;
    return data['interpretation'] as String?;
  }

  static Future<DailyTarotSession> _read(
      DatabaseExecutor db, String userId, String id) async {
    final rows = await db.query('selection_sessions',
        where: 'id = ? AND user_id = ?', whereArgs: [id, userId], limit: 1);
    if (rows.isEmpty) throw const TarotAccountChanged();
    return DailyTarotSession.fromRow(rows.single);
  }

  static void _checkAccount(bool Function() isCurrentUser) {
    if (!isCurrentUser()) throw const TarotAccountChanged();
  }

  static DecisaoDaTiragem _checkQuota(bool premium, String? remembered,
      String question, int used, int freeLimit) {
    final decision = decidirTiragem(premium: premium,
        perguntaDoDia: remembered, pergunta: question,
        tiragemJaFeitaHoje: false, temCota: used < freeLimit);
    if (decision == DecisaoDaTiragem.bloquear) throw const TarotQuotaExceeded();
    return decision;
  }
}
