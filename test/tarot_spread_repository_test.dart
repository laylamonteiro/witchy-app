import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/reading_session_schema.dart';
import 'package:grimorio_de_bolso/core/services/usage_coordinator.dart';
import 'package:grimorio_de_bolso/features/tarot/data/data_sources/tarot_cards_data.dart';
import 'package:grimorio_de_bolso/features/tarot/data/models/tarot_card_model.dart';
import 'package:grimorio_de_bolso/features/tarot/data/repositories/daily_tarot_repository.dart';
import 'package:grimorio_de_bolso/features/tarot/data/repositories/tarot_reading_repository.dart';
import 'package:grimorio_de_bolso/features/tarot/data/repositories/tarot_spread_repository.dart';
import 'package:grimorio_de_bolso/features/tarot/domain/daily_tarot_session.dart';
import 'package:grimorio_de_bolso/features/tarot/domain/tarot_spread_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  const user = 'manual-spread-user';
  final day = DateTime(2026, 9, 9, 23, 59);
  late TarotSpreadRepository repo;

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('tarot_spread_repository');
    await databaseFactory.setDatabasesPath(dir.path);
  });
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    await db.execute('DROP TRIGGER IF EXISTS fail_spread');
    for (final table in [...ReadingSessionSchema.tables, 'tarot_readings']) {
      await db.delete(table);
    }
    repo = TarotSpreadRepository(random: Random(42));
  });

  Future<TarotSpreadSession> prepare({String spread = 'threeCards',
      bool premium = false, bool startNew = false, String question = 'My question?',
      DateTime? at, String owner = user}) => repo.prepare(userId: owner,
      spread: spread, question: question, catalog: tarotCards, premium: premium,
      legacyOracleUsed: 0, freeLimit: 1, startNew: startNew, now: at ?? day);

  Future<TarotSpreadUpdate> choose(TarotSpreadSession session, String id,
      {bool premium = false, bool active = true, String owner = user}) =>
      repo.select(userId: owner, sessionId: session.id, cardId: id,
          expectedCount: session.selectedIds.length, catalog: tarotCards,
          positionLabels: List.generate(session.cardCount, (i) => 'Position $i'),
          isCurrentUser: () => active, isPremium: () => premium, freeLimit: 1);

  Future<int> used([DateTime? at]) => UsageCoordinator().oracleUsed(
      userId: user, legacyUsed: 0, day: at ?? day);

  Future<TarotSpreadUpdate> finish(TarotSpreadSession session, {bool premium = false}) async {
    var current = session;
    TarotSpreadUpdate? result;
    while (!current.isComplete) {
      final id = current.deck.firstWhere((c) => !current.selectedIds.contains(c.id)).id;
      result = await choose(current, id, premium: premium);
      current = result.session;
    }
    return result ?? await choose(current, current.selectedIds.last, premium: premium);
  }

  for (final spread in ['threeCards', 'cross']) {
    test('$spread persists each position and commits the exact ordered selection once', () async {
      var session = await prepare(spread: spread);
      final original = session.deck.map((c) => c.toJson()).toList();
      final chosen = [session.deck.last.id, session.deck.first.id,
        ...session.deck.skip(10).take(session.cardCount - 2).map((c) => c.id)];
      for (var i = 0; i < chosen.length; i++) {
        final update = await choose(session, chosen[i]);
        session = update.session;
        expect(session.selectedIds, chosen.take(i + 1).toList());
        expect(update.created, i == chosen.length - 1);
        expect(await used(), i == chosen.length - 1 ? 1 : 0);
        repo = TarotSpreadRepository(random: Random(i + 7));
        final resumed = await prepare(spread: spread, question: '  MY QUESTION?  ');
        expect(resumed.id, session.id);
        expect(resumed.deck.map((c) => c.toJson()).toList(), original);
        expect(resumed.selectedIds, session.selectedIds);
      }
      final repeated = await choose(session, session.deck[20].id);
      expect(repeated.created, isFalse);
      expect(repeated.session.selectedIds, chosen);
      expect(await used(), 1);
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query('tarot_readings');
      expect(rows, hasLength(1));
      final cards = (jsonDecode(rows.single['reading_data'] as String) as Map)['cards'] as List;
      for (var i = 0; i < chosen.length; i++) {
        final card = tarotCards.firstWhere((c) => c.id == chosen[i]);
        expect(cards[i]['suit'], card.suit.name);
        expect(cards[i]['number'], card.number);
        expect(cards[i]['reversed'], session.card(chosen[i]).reversed);
        expect(cards[i]['position'], 'Position $i');
      }
    });
  }

  test('concurrent commands fill only one position and selected IDs cannot repeat', () async {
    final session = await prepare();
    final results = await Future.wait([
      choose(session, session.deck.first.id),
      choose(session, session.deck.last.id),
    ]);
    expect(results.every((r) => r.session.selectedIds.length == 1), isTrue);
    final current = await prepare();
    final duplicate = await choose(current, current.selectedIds.single);
    expect(duplicate.session.selectedIds, current.selectedIds);
    expect(await used(), 0);
    await expectLater(choose(current, 'unknown-card'), throwsStateError);
    await expectLater(choose(current, current.deck[5].id, active: false),
        throwsA(isA<TarotAccountChanged>()));
    await expectLater(choose(current, current.deck[5].id, owner: 'another-account'),
        throwsA(isA<TarotAccountChanged>()));
    expect((await prepare()).selectedIds, current.selectedIds);
  });

  test('result failure retains every choice and retry rolls usage forward once', () async {
    var session = await prepare();
    session = (await choose(session, session.deck.first.id)).session;
    session = (await choose(session, session.deck.last.id)).session;
    final last = session.deck[10].id;
    final expected = [...session.selectedIds, last];
    final db = await DatabaseHelper.instance.database;
    await db.execute("CREATE TRIGGER fail_spread BEFORE INSERT ON tarot_readings "
        "BEGIN SELECT RAISE(ABORT, 'interrupted write'); END");
    await expectLater(choose(session, last), throwsA(isA<DatabaseException>()));
    expect(await used(), 0);
    expect(await db.query('tarot_readings'), isEmpty);
    final resumed = await prepare();
    expect(resumed.selectedIds, expected);
    expect(resumed.isComplete, isTrue);
    expect(resumed.isCommitted, isFalse);
    await db.execute('DROP TRIGGER fail_spread');
    final result = await choose(resumed, session.deck[20].id);
    expect(result.session.selectedIds, expected);
    expect(result.created, isTrue);
    expect(await used(), 1);
  });

  test('the daily repository cannot commit a multiple-card session', () async {
    final session = await prepare();
    await expectLater(DailyTarotRepository().selectAndCommit(
      userId: user, sessionId: session.id, cardId: session.deck.first.id,
      catalog: tarotCards, positionLabel: 'Daily', isCurrentUser: () => true,
      isPremium: () => true, freeLimit: 1,
    ), throwsA(isA<TarotAccountChanged>()));
    expect((await prepare()).selectedIds, isEmpty);
    expect(await used(), 0);
  });

  test('three and five cards share the remembered question and one Free debit', () async {
    await finish(await prepare());
    final cross = await finish(await prepare(spread: 'cross'));
    expect(cross.session.selectedIds, hasLength(5));
    expect(await used(), 1);
    expect((await prepare(startNew: true)).isCommitted, isTrue);
    await expectLater(prepare(question: 'Another question?'), throwsA(isA<TarotQuotaExceeded>()));
  });

  test('Premium resumes until a new reading is explicitly requested', () async {
    final first = await finish(await prepare(premium: true), premium: true);
    expect((await prepare(premium: true)).id, first.session.id);
    repo = TarotSpreadRepository(random: Random(42));
    final second = await prepare(premium: true, startNew: true);
    expect(second.deck.map((c) => c.toJson()).toList(),
        first.session.deck.map((c) => c.toJson()).toList());
    expect(second.id, isNot(first.session.id));
    expect((await prepare(premium: true)).id, second.id);
    await finish(second, premium: true);
    expect(await used(), 0);
    final db = await DatabaseHelper.instance.database;
    expect(await db.query('tarot_readings'), hasLength(2));
  });

  test('downgrade cannot turn a second Premium draft into another Free result', () async {
    await finish(await prepare(premium: true), premium: true);
    final second = await prepare(premium: true, startNew: true);
    await expectLater(finish(second), throwsA(isA<TarotQuotaExceeded>()));
    expect((await prepare()).isComplete, isTrue);
    expect((await prepare()).isCommitted, isFalse);
    expect(await used(), 0);
  });

  test('quota changes during selection are rechecked without changing the cards', () async {
    final session = await prepare();
    await UsageCoordinator().recordOracleUse(userId: user, legacyUsed: 0,
        day: day, operationId: 'another-oracle-use');
    await expectLater(finish(session), throwsA(isA<TarotQuotaExceeded>()));
    final resumed = await prepare(premium: true);
    final upgraded = await finish(resumed, premium: true);
    expect(upgraded.session.selectedIds, resumed.selectedIds);
    expect(await used(), 1);
  });

  test('an unfinished reading resumes its original day after midnight', () async {
    var session = await prepare();
    session = (await choose(session, session.deck.last.id)).session;
    final tomorrow = DateTime(2026, 9, 10);
    final resumed = await prepare(at: tomorrow);
    expect(resumed.id, session.id);
    expect(resumed.dayKey, session.dayKey);
    await finish(resumed);
    expect(await used(), 1);
    expect(await used(tomorrow), 0);
    expect((await prepare(at: tomorrow)).id, isNot(session.id));
  });

  test('existing readings retain faces, orientations, date and interpretation', () async {
    final readings = TarotReadingRepository();
    final drawn = [for (var i = 0; i < 3; i++)
      TarotDrawnCard(card: tarotCards[i], isReversed: i == 1, positionLabel: 'Old $i')];
    final id = await readings.recordDraw(userId: user, spreadName: 'threeCards',
        signature: 'legacy', drawn: drawn, question: 'My question?', date: day);
    await readings.attachInterpretation(userId: user, signature: 'legacy', interpretation: 'Saved');
    final adopted = await prepare();
    expect(adopted.resultId, id);
    expect(adopted.selectedIds, drawn.map((d) => d.card.id).toList());
    expect(adopted.card(tarotCards[1].id).reversed, isTrue);
    expect(adopted.startedAt, day);
    expect(await repo.interpretation(adopted), 'Saved');
    expect(await used(), 0);
  });
}
