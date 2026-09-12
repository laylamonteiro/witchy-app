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
import 'package:grimorio_de_bolso/features/tarot/data/repositories/tarot_day_repository.dart';
import 'package:grimorio_de_bolso/features/tarot/data/repositories/tarot_reading_repository.dart';
import 'package:grimorio_de_bolso/features/tarot/domain/daily_tarot_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  const user = 'daily-tarot-user';
  final day = DateTime(2026, 9, 9, 23, 59);
  late DailyTarotRepository repo;

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('daily_tarot');
    await databaseFactory.setDatabasesPath(dir.path);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    await db.execute('DROP TRIGGER IF EXISTS fail_daily_draw');
    for (final table in [...ReadingSessionSchema.tables, 'tarot_readings']) {
      await db.delete(table);
    }
    repo = DailyTarotRepository(random: Random(42));
  });

  Future<DailyTarotSession> prepare({String question = 'My question?',
      bool premium = false, int legacyUsed = 0, String owner = user,
      DateTime? at}) => repo.prepare(userId: owner, question: question,
      catalog: tarotCards, premium: premium, legacyOracleUsed: legacyUsed,
      freeLimit: 1, now: at ?? day);

  Future<DailyTarotCommit> commit(DailyTarotSession session, {
    String? cardId, bool premium = false, bool active = true, String owner = user,
  }) => repo.selectAndCommit(userId: owner, sessionId: session.id,
      cardId: cardId ?? session.deck.last.id, catalog: tarotCards,
      positionLabel: 'Daily card', isCurrentUser: () => active,
      isPremium: () => premium, freeLimit: 1);

  Future<int> used({DateTime? at, String owner = user, int legacy = 0}) =>
      UsageCoordinator().oracleUsed(userId: owner, legacyUsed: legacy, day: at ?? day);

  test('opening and abandoning retains all 78 IDs and orientations without use', () async {
    final first = await prepare();
    expect(first.deck.length, 78);
    expect(first.deck.map((c) => c.id).toSet().length, 78);
    expect(first.selectedId, isNull);
    expect(await used(), 0);
    repo = DailyTarotRepository(random: Random(987));
    final resumed = await prepare(question: '  MY QUESTION?  ');
    expect(resumed.id, first.id);
    expect(resumed.deck.map((c) => c.toJson()), first.deck.map((c) => c.toJson()));
    expect((await TarotDayRepository().read(user, day)).lastQuestion, 'My question?');
  });

  test('the exact selected card is recorded; duplicate commits consume once', () async {
    final session = await prepare();
    final chosen = session.deck.last;
    final results = await Future.wait([
      commit(session, cardId: chosen.id),
      commit(session, cardId: chosen.id),
    ]);
    expect(results.where((r) => r.created).length, 1);
    expect(results.map((r) => r.session.resultId).toSet().length, 1);
    expect(await used(), 1);
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('tarot_readings');
    expect(rows, hasLength(1));
    final data = jsonDecode(rows.single['reading_data'] as String) as Map;
    final card = (data['cards'] as List).single as Map;
    final expected = tarotCards.firstWhere((c) => c.id == chosen.id);
    expect(card['suit'], expected.suit.name);
    expect(card['number'], expected.number);
    expect(card['reversed'], chosen.reversed);
    final retry = await commit(session, cardId: session.deck.first.id);
    expect(retry.created, isFalse);
    expect(retry.session.selectedId, chosen.id);
    expect((await prepare(premium: true)).selectedId, chosen.id);
  });

  test('failed result write rolls back usage and retains the choice for restart', () async {
    final session = await prepare();
    final db = await DatabaseHelper.instance.database;
    await db.execute('''
      CREATE TRIGGER fail_daily_draw BEFORE INSERT ON tarot_readings
      BEGIN SELECT RAISE(ABORT, 'simulated interrupted write'); END
    ''');
    await expectLater(commit(session), throwsA(isA<DatabaseException>()));
    expect(await used(), 0);
    expect(await db.query('tarot_readings'), isEmpty);
    repo = DailyTarotRepository(random: Random(99));
    final resumed = await prepare();
    expect(resumed.selectedId, session.deck.last.id);
    await db.execute('DROP TRIGGER fail_daily_draw');
    final retry = await commit(resumed, cardId: session.deck.first.id);
    expect(retry.session.selectedId, session.deck.last.id);
    expect(await used(), 1);
  });

  test('legacy usage imports once and is not reset by subsequent stale mirrors', () async {
    await prepare(premium: true, legacyUsed: 1);
    expect(await used(legacy: 0), 1);
    await expectLater(prepare(question: 'Another?', legacyUsed: 0),
        throwsA(isA<TarotQuotaExceeded>()));
    expect(await used(), 1);
  });

  test('another Oracle use during selection is revalidated at commit', () async {
    final session = await prepare();
    await UsageCoordinator().recordOracleUse(userId: user, legacyUsed: 0,
        day: day, operationId: 'oracle-other');
    await expectLater(commit(session), throwsA(isA<TarotQuotaExceeded>()));
    expect((await prepare(premium: true)).selectedId, session.deck.last.id);
    final upgraded = await commit(session, premium: true);
    expect(upgraded.session.isCommitted, isTrue);
    expect(await used(), 1, reason: 'Premium does not charge another operation');
  });

  test('crossing midnight keeps the session day and leaves the next day quota', () async {
    final session = await prepare();
    final result = await commit(session);
    expect(result.session.dayKey, '2026-9-9');
    expect(await used(), 1);
    final next = DateTime(2026, 9, 10);
    expect(await used(at: next), 0);
    final tomorrow = await prepare(at: next);
    expect(tomorrow.id, isNot(session.id));
    expect(tomorrow.selectedId, isNull);
  });

  test('account switch and foreign session IDs never commit to another account', () async {
    final session = await prepare();
    await expectLater(commit(session, active: false), throwsA(isA<TarotAccountChanged>()));
    await expectLater(commit(session, owner: 'other'), throwsA(isA<TarotAccountChanged>()));
    expect(await used(), 0);
    expect((await prepare()).selectedId, isNull);
    final other = await prepare(owner: 'other');
    expect(other.id, isNot(session.id));
  });

  test('an existing daily reading is adopted, including orientation and interpretation', () async {
    final existing = TarotReadingRepository();
    final card = tarotCards[7];
    final id = await existing.recordDraw(userId: user, spreadName: 'daily',
        signature: 'legacy-reading', question: 'My question?', date: day,
        drawn: [TarotDrawnCard(card: card, isReversed: true, positionLabel: 'Daily')]);
    await existing.attachInterpretation(userId: user, signature: 'legacy-reading',
        interpretation: 'Saved interpretation');
    final session = await prepare(legacyUsed: 1);
    expect(session.resultId, id);
    expect(session.resultSignature, 'legacy-reading');
    expect(session.selectedId, card.id);
    expect(session.card(card.id).reversed, isTrue);
    expect(await repo.interpretation(session), 'Saved interpretation');
    expect(await used(), 1);
  });

  test('future readings cannot replace the current day and invalid IDs cannot select', () async {
    await TarotReadingRepository().recordDraw(userId: user, spreadName: 'daily',
        signature: 'future', question: 'My question?', date: DateTime(2026, 9, 10),
        drawn: [TarotDrawnCard(card: tarotCards[0], isReversed: false, positionLabel: 'Daily')]);
    final session = await prepare();
    expect(session.isCommitted, isFalse);
    await expectLater(commit(session, cardId: 'not-a-card'), throwsStateError);
    expect((await prepare()).selectedId, isNull);
    expect(await used(), 0);
  });

  test('legacy question memory preserves existing free reuse policy', () async {
    SharedPreferences.setMockInitialValues({
      'tarot_daily_q_$user': '2026-9-9|my question?',
      'tarot_last_q_$user': '2026-9-9|My question?',
    });
    final session = await prepare(legacyUsed: 1);
    await commit(session);
    expect(await used(), 1);
    expect((await TarotDayRepository().read(user, day)).dailyQuestion, 'my question?');
  });
}
