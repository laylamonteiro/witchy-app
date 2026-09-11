import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/reading_session_schema.dart';
import 'package:grimorio_de_bolso/core/services/usage_coordinator.dart';
import 'package:grimorio_de_bolso/features/divination/data/data_sources/oracle_cards_data.dart';
import 'package:grimorio_de_bolso/features/divination/data/models/oracle_card_model.dart';
import 'package:grimorio_de_bolso/features/divination/data/repositories/oracle_discovery_repository.dart';
import 'package:grimorio_de_bolso/features/divination/data/repositories/oracle_reading_repository.dart';
import 'package:grimorio_de_bolso/features/divination/data/repositories/oracle_selection_repository.dart';
import 'package:grimorio_de_bolso/features/divination/domain/oracle_selection_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'support/short_test_timeout.dart';

void main() {
  useShortTestTimeout();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  const user = 'manual-oracle-user';
  final day = DateTime(2026, 9, 10, 23, 59);
  late OracleSelectionRepository repo;

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('oracle_selection_repository');
    await databaseFactory.setDatabasesPath(dir.path);
  });
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    await db.execute('DROP TRIGGER IF EXISTS fail_oracle');
    for (final table in [...ReadingSessionSchema.tables, 'oracle_readings', 'tarot_readings']) {
      await db.delete(table);
    }
    repo = OracleSelectionRepository(random: Random(42));
  });

  Future<OracleSelectionSession> prepare({
    OracleSpreadType spread = OracleSpreadType.threeCard,
    bool premium = false, bool startNew = false, int legacyUsed = 0,
    DateTime? at, String owner = user,
  }) => repo.prepare(userId: owner, spread: spread, catalog: oracleCardsData,
      premium: premium, legacyOracleUsed: legacyUsed, freeLimit: 1,
      startNew: startNew, now: at ?? day);

  Future<OracleSelectionUpdate> choose(OracleSelectionSession session, String id,
      {bool premium = false, bool active = true, String owner = user}) =>
      repo.select(userId: owner, sessionId: session.id, cardId: id,
          expectedCount: session.selectedIds.length, catalog: oracleCardsData,
          positionLabels: List.generate(session.cardsNeeded, (i) => 'Position $i'),
          isCurrentUser: () => active, isPremium: () => premium, freeLimit: 1);

  Future<int> used([DateTime? at]) =>
      UsageCoordinator().oracleUsed(userId: user, legacyUsed: 0, day: at ?? day);

  Future<OracleSelectionUpdate> finish(OracleSelectionSession session,
      {bool premium = false, List<String>? ids}) async {
    var current = session;
    OracleSelectionUpdate? result;
    var index = 0;
    while (!current.isComplete) {
      final id = ids != null
          ? ids[index++]
          : current.deck.firstWhere((c) => !current.selectedIds.contains(c));
      result = await choose(current, id, premium: premium);
      current = result.session;
    }
    return result ?? await choose(current, current.selectedIds.last, premium: premium);
  }

  test('the fan holds the 44 IDs and resumes without use', () async {
    final first = await prepare();
    expect(first.deck.length, 44);
    expect(first.deck.toSet(), oracleCardsData.map((c) => '${c.id}').toSet());
    expect(await used(), 0);
    repo = OracleSelectionRepository(random: Random(987));
    final resumed = await prepare();
    expect(resumed.id, first.id);
    expect(resumed.deck, first.deck);
  });

  for (final spread in OracleSpreadType.values) {
    test('${spread.name} persists each position, commits once and records discoveries', () async {
      var session = await prepare(spread: spread);
      final chosen = [session.deck.last, session.deck.first, ...session.deck.skip(5)]
          .take(spread.cardCount).toList();
      for (var i = 0; i < chosen.length; i++) {
        final update = await choose(session, chosen[i]);
        session = update.session;
        expect(session.selectedIds, chosen.take(i + 1).toList());
        expect(update.created, i == chosen.length - 1);
        expect(await used(), i == chosen.length - 1 ? 1 : 0);
        if (update.created) {
          expect(update.newDiscoveries, chosen.map(int.parse).toList());
        } else {
          expect(update.newDiscoveries, isEmpty);
        }
        final resumed = await prepare(spread: spread);
        expect(resumed.id, session.id);
        expect(resumed.selectedIds, session.selectedIds);
      }
      final repeated = await choose(session, session.deck[3]);
      expect(repeated.created, isFalse);
      expect(repeated.newDiscoveries, isEmpty);
      expect(await used(), 1);
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query('oracle_readings');
      expect(rows, hasLength(1));
      expect(rows.single['spread_type'], spread.name);
      expect(rows.single['date'], session.startedAt.millisecondsSinceEpoch);
      final data = jsonDecode(rows.single['reading_data'] as String) as Map;
      expect(data['session_id'], session.id);
      final positions = data['positions'] as List;
      for (var i = 0; i < chosen.length; i++) {
        expect('${positions[i]['card']['id']}', chosen[i]);
        expect(positions[i]['positionMeaning'], 'Position $i');
      }
      expect(await OracleDiscoveryRepository().discovered(user),
          chosen.map(int.parse).toSet());
      final reading = await repo.reading(session);
      expect(reading?.id, session.resultId);
    });
  }

  test('a repeated card is not a new discovery and dates keep the first encounter', () async {
    final first = await finish(await prepare(premium: true), premium: true);
    final seen = first.session.selectedIds;
    final second = await prepare(premium: true, startNew: true);
    final ids = [seen.first, ...second.deck.where((c) => !seen.contains(c)).take(2)];
    final result = await finish(second, premium: true, ids: ids);
    expect(result.newDiscoveries, ids.skip(1).map(int.parse).toList());
    final db = await DatabaseHelper.instance.database;
    final row = (await db.query('oracle_discoveries',
        where: 'card_id = ?', whereArgs: [int.parse(seen.first)])).single;
    expect(row['source_reading_id'], first.session.resultId);
    expect(await OracleDiscoveryRepository().discovered(user), hasLength(5));
  });

  test('readings made before the update are adopted silently, oldest first', () async {
    final readings = OracleReadingRepository();
    final earlier = DateTime(2026, 9, 1);
    for (final (date, ids) in [(DateTime(2026, 9, 5), [7, 8]), (earlier, [7, 9])]) {
      await readings.insertReading(OracleReading(
        id: 'legacy-${date.day}', spreadType: OracleSpreadType.threeCard,
        positions: [for (final id in ids)
          OracleCardPosition(position: 0,
              card: oracleCardsData.firstWhere((c) => c.id == id), positionMeaning: 'Old')],
        date: date,
      ), user);
    }
    final db = await DatabaseHelper.instance.database;
    await db.insert('oracle_readings', {
      'id': 'broken', 'user_id': user, 'spread_type': 'daily', 'reading_data': '{',
      'date': 1, 'created_at': 1, 'updated_at': 1, 'synced': 0,
    });
    await prepare(premium: true);
    expect(await OracleDiscoveryRepository().discovered(user), {7, 8, 9});
    final seven = (await db.query('oracle_discoveries',
        where: 'card_id = ?', whereArgs: [7])).single;
    expect(seven['first_seen_at'], earlier.millisecondsSinceEpoch);
    expect(seven['source_reading_id'], 'legacy-1');
    expect(await OracleDiscoveryRepository().discovered('someone-else'), isEmpty);
  });

  test('concurrent commands fill only one position and IDs cannot repeat', () async {
    final session = await prepare(spread: OracleSpreadType.weeklyGuidance);
    final results = await Future.wait([
      choose(session, session.deck.first),
      choose(session, session.deck.last),
    ]);
    expect(results.every((r) => r.session.selectedIds.length == 1), isTrue);
    final current = await prepare(spread: OracleSpreadType.weeklyGuidance);
    final duplicate = await choose(current, current.selectedIds.single);
    expect(duplicate.session.selectedIds, current.selectedIds);
    expect(await used(), 0);
    await expectLater(choose(current, 'not-a-card'), throwsStateError);
    await expectLater(choose(current, current.deck[5], active: false),
        throwsA(isA<OracleAccountChanged>()));
    await expectLater(choose(current, current.deck[5], owner: 'another-account'),
        throwsA(isA<OracleAccountChanged>()));
  });

  test('a result failure keeps every card, no discovery and one retry debit', () async {
    var session = await prepare();
    session = (await choose(session, session.deck.first)).session;
    session = (await choose(session, session.deck.last)).session;
    final last = session.deck[10];
    final expected = [...session.selectedIds, last];
    final db = await DatabaseHelper.instance.database;
    await db.execute('CREATE TRIGGER fail_oracle BEFORE INSERT ON oracle_readings '
        "BEGIN SELECT RAISE(ABORT, 'interrupted write'); END");
    await expectLater(choose(session, last), throwsA(isA<DatabaseException>()));
    expect(await used(), 0);
    expect(await db.query('oracle_discoveries'), isEmpty);
    final resumed = await prepare();
    expect(resumed.selectedIds, expected);
    expect(resumed.isComplete, isTrue);
    expect(resumed.isCommitted, isFalse);
    await db.execute('DROP TRIGGER fail_oracle');
    final result = await choose(resumed, session.deck[20]);
    expect(result.session.selectedIds, expected);
    expect(result.created, isTrue);
    expect(result.newDiscoveries, hasLength(3));
    expect(await used(), 1);
  });

  test('Free shares the tarot quota, reopens today and blocks another table', () async {
    final done = await finish(await prepare());
    expect(await used(), 1);
    expect((await prepare()).id, done.session.id);
    expect((await prepare(startNew: true)).id, done.session.id);
    await expectLater(prepare(spread: OracleSpreadType.daily),
        throwsA(isA<OracleQuotaExceeded>()));
    await UsageCoordinator().recordOracleUse(userId: user, legacyUsed: 0, day: day,
        operationId: 'tarot-elsewhere');
    expect(await used(), 2);
    expect((await prepare()).isCommitted, isTrue);
  });

  test('quota consumed elsewhere during selection is rechecked at commit', () async {
    final session = await prepare();
    await UsageCoordinator().recordOracleUse(userId: user, legacyUsed: 0, day: day,
        operationId: 'tarot-elsewhere');
    await expectLater(finish(session), throwsA(isA<OracleQuotaExceeded>()));
    final resumed = await prepare(premium: true);
    expect(resumed.id, session.id);
    final upgraded = await finish(resumed, premium: true);
    expect(upgraded.session.selectedIds, resumed.selectedIds);
    expect(await used(), 1);
  });

  test('Premium resumes until a new reading is explicitly requested', () async {
    final first = await finish(await prepare(premium: true), premium: true);
    expect((await prepare(premium: true)).id, first.session.id);
    final second = await prepare(premium: true, startNew: true);
    expect(second.id, isNot(first.session.id));
    await finish(second, premium: true);
    expect(await used(), 0);
    final db = await DatabaseHelper.instance.database;
    expect(await db.query('oracle_readings'), hasLength(2));
  });

  test('an unfinished table resumes its original day after midnight', () async {
    var session = await prepare();
    session = (await choose(session, session.deck.last)).session;
    final tomorrow = DateTime(2026, 9, 11);
    final resumed = await prepare(at: tomorrow);
    expect(resumed.id, session.id);
    expect(resumed.dayKey, session.dayKey);
    await finish(resumed);
    expect(await used(), 1);
    expect(await used(tomorrow), 0);
    expect((await prepare(at: tomorrow)).id, isNot(session.id));
  });

  test('the counselor interpretation stays with the reading', () async {
    final done = await finish(await prepare());
    await OracleReadingRepository().attachInterpretation(
        readingId: done.session.resultId!, userId: user, interpretation: 'Woven');
    final reading = await repo.reading(done.session);
    expect(reading?.interpretation, 'Woven');
    expect(reading?.sessionId, done.session.id);
    expect(reading?.positions.length, 3);
  });
}
