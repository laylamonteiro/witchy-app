import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/reading_session_schema.dart';
import 'package:grimorio_de_bolso/core/services/usage_coordinator.dart';
import 'package:grimorio_de_bolso/features/runes/data/data_sources/runes_data.dart';
import 'package:grimorio_de_bolso/features/runes/data/models/rune_spread_model.dart';
import 'package:grimorio_de_bolso/features/runes/data/repositories/rune_reading_repository.dart';
import 'package:grimorio_de_bolso/features/runes/data/repositories/rune_selection_repository.dart';
import 'package:grimorio_de_bolso/features/runes/domain/rune_selection_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  const user = 'rune-fixture';
  final day = DateTime(2026, 9, 10, 23, 59);
  late RuneSelectionRepository repo;

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('rune_sessions');
    await databaseFactory.setDatabasesPath(dir.path);
  });
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    ContentLocale.instance.setLocale(const Locale('en'));
    final db = await DatabaseHelper.instance.database;
    await db.execute('DROP TRIGGER IF EXISTS fail_rune_result');
    for (final table in [...ReadingSessionSchema.tables, 'rune_readings']) {
      await db.delete(table);
    }
    repo = RuneSelectionRepository(random: Random(42));
  });

  Future<RuneSelectionSession> prepare({RuneSpreadType spread = RuneSpreadType.threeCast,
      String question = 'A question', bool premium = false, bool startNew = false,
      String owner = user, DateTime? at, int legacy = 0}) => repo.prepare(
    userId: owner, spread: spread, question: question, catalog: runesData,
    premium: premium, legacyRuneUsed: legacy, freeLimit: 1, startNew: startNew, now: at ?? day,
  );
  Future<RuneSelectionUpdate> choose(RuneSelectionSession session, String id,
      {bool premium = false, bool active = true, String owner = user}) => repo.select(
    userId: owner, sessionId: session.id, stoneId: id,
    expectedCount: session.selectedIds.length, catalog: runesData,
    positionLabels: [for (var i = 0; i < session.spread.runeCount; i++) 'Position $i'],
    isCurrentUser: () => active, isPremium: () => premium, freeLimit: 1,
  );
  Future<int> used({String category = UsageCoordinator.runes, DateTime? at}) =>
      UsageCoordinator().used(userId: user, legacyUsed: 0, category: category, day: at ?? day);

  Future<RuneSelectionUpdate> finish(RuneSelectionSession session, {bool premium = false}) async {
    var current = session;
    RuneSelectionUpdate? result;
    while (!current.isComplete) {
      result = await choose(current,
          current.deck.firstWhere((r) => !current.selectedIds.contains(r.id)).id, premium: premium);
      current = result.session;
    }
    return result ?? await choose(current, current.selectedIds.last, premium: premium);
  }

  for (final spread in RuneSpreadType.values) {
    test('${spread.name}: each choice survives restart and commits once in the chosen order', () async {
      var session = await prepare(spread: spread);
      final deck = session.deck.map((r) => r.toJson()).toList();
      final ids = session.deck.reversed.take(spread.runeCount).map((r) => r.id).toList();
      for (var i = 0; i < ids.length; i++) {
        final update = await choose(session, ids[i]);
        session = update.session;
        expect(session.selectedIds, ids.take(i + 1).toList());
        expect(update.created, i == ids.length - 1);
        expect(await used(), i == ids.length - 1 ? 1 : 0);
        repo = RuneSelectionRepository(random: Random(i + 7));
        final resumed = await prepare(spread: spread, question: '  A QUESTION  ');
        expect(resumed.id, session.id);
        expect(resumed.deck.map((r) => r.toJson()).toList(), deck);
        expect(resumed.selectedIds, session.selectedIds);
      }
      final repeated = await choose(session, session.deck.first.id);
      expect(repeated.created, isFalse);
      expect(await used(), 1);
      final reading = (await RuneReadingRepository().getReading(session.resultId!, userId: user))!;
      expect(reading.positions.map((p) => p.rune.id), ids);
      expect(reading.date, day);
      for (var i = 0; i < ids.length; i++) {
        expect(reading.positions[i].isReversed, session.stone(ids[i]).reversed);
        expect(reading.positions[i].positionMeaning, 'Position $i');
      }
      final db = await DatabaseHelper.instance.database;
      expect(await db.query('rune_readings'), hasLength(1));
    });
  }

  test('concurrent and stale commands cannot fill two positions', () async {
    final session = await prepare();
    await Future.wait([choose(session, session.deck.first.id), choose(session, session.deck.last.id)]);
    final current = (await repo.latest(user, now: day))!;
    expect(current.selectedIds, hasLength(1));
    expect((await choose(current, current.selectedIds.single)).session.selectedIds, hasLength(1));
    await expectLater(choose(current, 'unknown-rune'), throwsStateError);
    expect(await used(), 0);
  });

  test('a result write failure preserves all choices and rolls back usage', () async {
    final session = await prepare(spread: RuneSpreadType.single);
    final db = await DatabaseHelper.instance.database;
    await db.execute("CREATE TRIGGER fail_rune_result BEFORE INSERT ON rune_readings "
        "BEGIN SELECT RAISE(ABORT, 'fixture failure'); END");
    await expectLater(choose(session, session.deck.last.id), throwsA(isA<Exception>()));
    final pending = (await repo.latest(user, now: day))!;
    expect(pending.selectedIds, [session.deck.last.id]);
    expect(pending.isCommitted, isFalse);
    expect(await used(), 0);
    expect(await db.query('rune_readings'), isEmpty);
    await db.execute('DROP TRIGGER fail_rune_result');
    final result = await choose(pending, session.deck.first.id);
    expect(result.created, isTrue);
    expect(result.session.selectedIds, [session.deck.last.id]);
    expect(await used(), 1);
  });

  test('Rune quota imports once and stays separate from Tarot and Oracle', () async {
    await UsageCoordinator().recordOracleUse(userId: user, legacyUsed: 0, day: day);
    final session = await prepare(spread: RuneSpreadType.single);
    await finish(session);
    expect(await used(), 1);
    expect(await used(category: UsageCoordinator.oracle), 1);
    expect((await prepare(spread: RuneSpreadType.single, legacy: 20)).id, session.id);
    await expectLater(prepare(spread: RuneSpreadType.single, startNew: true),
        throwsA(isA<RuneQuotaExceeded>()));
    await expectLater(prepare(question: 'another question'), throwsA(isA<RuneQuotaExceeded>()));
  });

  test('previous Free usage is imported before opening a new consultation', () async {
    await expectLater(prepare(legacy: 1), throwsA(isA<RuneQuotaExceeded>()));
    // A blocked transaction rolls back its import; the provider restores the
    // authoritative preference before retry, so no used credit becomes a draw.
    await expectLater(prepare(legacy: 1), throwsA(isA<RuneQuotaExceeded>()));
  });

  test('Premium only starts a new session on an explicit action', () async {
    final first = await prepare(premium: true);
    await finish(first, premium: true);
    expect((await prepare(premium: true)).id, first.id);
    final next = await prepare(premium: true, startNew: true);
    expect(next.id, isNot(first.id));
    expect(next.selectedIds, isEmpty);
    await finish(next, premium: true);
    expect(await used(), 0);
    final db = await DatabaseHelper.instance.database;
    expect(await db.query('rune_readings'), hasLength(2));
  });

  test('access is revalidated after choosing and uses the original day at midnight', () async {
    var session = await prepare(premium: true);
    session = (await choose(session, session.deck.first.id, premium: true)).session;
    final tomorrow = DateTime(2026, 9, 11, 0, 1);
    final resumed = await prepare(at: tomorrow);
    expect(resumed.id, session.id);
    await finish(resumed);
    expect(await used(), 1);
    expect(await used(at: tomorrow), 0);
    final blocked = await prepare(premium: true, startNew: true, spread: RuneSpreadType.single);
    await expectLater(finish(blocked), throwsA(isA<RuneQuotaExceeded>()));
    expect((await repo.latest(user, now: day))!.selectedIds, hasLength(1));
    expect((await finish((await repo.latest(user, now: day))!, premium: true)).created, isTrue);
  });

  test('different accounts and other tools cannot read or commit a Rune session', () async {
    final session = await prepare(spread: RuneSpreadType.single);
    await expectLater(choose(session, session.deck.first.id, owner: 'other'),
        throwsA(isA<RuneAccountChanged>()));
    await expectLater(choose(session, session.deck.first.id, active: false),
        throwsA(isA<RuneAccountChanged>()));
    expect(await repo.latest('other', now: day), isNull);
    final result = await finish(session);
    expect(await RuneReadingRepository().getReading(result.session.resultId!, userId: 'other'), isNull);
    final db = await DatabaseHelper.instance.database;
    await db.update('selection_sessions', {'tool': 'tarot'}, where: 'id = ?', whereArgs: [session.id]);
    await expectLater(choose(session, session.deck.first.id), throwsA(isA<RuneAccountChanged>()));
  });

  test('IDs and orientations survive translation; saved advice keeps its date and owner', () async {
    var session = await prepare();
    session = (await choose(session, session.deck.first.id)).session;
    final deck = session.deck.map((r) => r.toJson()).toList();
    ContentLocale.instance.setLocale(const Locale('es'));
    session = await prepare();
    expect(session.deck.map((r) => r.toJson()).toList(), deck);
    final result = await finish(session);
    final readings = RuneReadingRepository();
    final updated = await readings.updateInterpretation(result.session.resultId!, user, 'Saved advice');
    expect(updated!.date, day);
    expect(updated.interpretation, 'Saved advice');
    expect(await readings.updateInterpretation(updated.id, 'other', 'Other advice'), isNull);
    expect((await readings.getReading(updated.id, userId: user))!.interpretation, 'Saved advice');
  });
}
