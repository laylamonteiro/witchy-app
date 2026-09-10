import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
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
  const user = 'manual-rune-user';
  final day = DateTime(2026, 9, 10, 23, 59);
  late RuneSelectionRepository repo;

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('rune_selection_repository');
    await databaseFactory.setDatabasesPath(dir.path);
  });
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    await db.execute('DROP TRIGGER IF EXISTS fail_runes');
    for (final table in [...ReadingSessionSchema.tables, 'rune_readings']) {
      await db.delete(table);
    }
    repo = RuneSelectionRepository(random: Random(42));
  });

  Future<RuneSelectionSession> prepare({
    RuneSpreadType spread = RuneSpreadType.threeCast,
    bool premium = false, bool startNew = false, String question = 'My question?',
    int legacyUsed = 0, DateTime? at, String owner = user,
  }) => repo.prepare(userId: owner, spread: spread, question: question,
      catalog: runesData, premium: premium, legacyRuneUsed: legacyUsed,
      freeLimit: 1, startNew: startNew, now: at ?? day);

  Future<RuneSelectionUpdate> choose(RuneSelectionSession session, String id,
      {bool premium = false, bool active = true, String owner = user}) =>
      repo.select(userId: owner, sessionId: session.id, runeId: id,
          expectedCount: session.selectedIds.length, catalog: runesData,
          positionLabels: List.generate(session.stonesNeeded, (i) => 'Position $i'),
          emptyQuestionLabel: 'No question',
          isCurrentUser: () => active, isPremium: () => premium, freeLimit: 1);

  Future<int> used([DateTime? at]) => UsageCoordinator().used(
      userId: user, legacyUsed: 0, category: UsageCoordinator.runes, day: at ?? day);

  Future<RuneSelectionUpdate> finish(RuneSelectionSession session,
      {bool premium = false}) async {
    var current = session;
    RuneSelectionUpdate? result;
    while (!current.isComplete) {
      final id = current.deck.firstWhere((r) => !current.selectedIds.contains(r.id)).id;
      result = await choose(current, id, premium: premium);
      current = result.session;
    }
    return result ?? await choose(current, current.selectedIds.last, premium: premium);
  }

  test('the cloth holds the 24 stones with fixed orientation and no use', () async {
    final first = await prepare();
    expect(first.deck.length, 24);
    expect(first.deck.map((r) => r.id).toSet(), runesData.map((r) => r.name).toSet());
    expect(first.selectedIds, isEmpty);
    expect(await used(), 0);
    repo = RuneSelectionRepository(random: Random(987));
    final resumed = await prepare(question: '  MY QUESTION?  ');
    expect(resumed.id, first.id);
    expect(resumed.deck.map((r) => r.toJson()).toList(),
        first.deck.map((r) => r.toJson()).toList());
    expect(resumed.spread, RuneSpreadType.threeCast);
  });

  for (final spread in RuneSpreadType.values) {
    test('${spread.name} persists each position and commits the ordered set once', () async {
      var session = await prepare(spread: spread);
      final original = session.deck.map((r) => r.toJson()).toList();
      final chosen = [session.deck.last.id, session.deck.first.id,
        ...session.deck.skip(5).take(spread.runeCount - 2).map((r) => r.id)]
          .take(spread.runeCount).toList();
      for (var i = 0; i < chosen.length; i++) {
        final update = await choose(session, chosen[i]);
        session = update.session;
        expect(session.selectedIds, chosen.take(i + 1).toList());
        expect(update.created, i == chosen.length - 1);
        expect(await used(), i == chosen.length - 1 ? 1 : 0);
        repo = RuneSelectionRepository(random: Random(i + 7));
        final resumed = await prepare(spread: spread);
        expect(resumed.id, session.id);
        expect(resumed.deck.map((r) => r.toJson()).toList(), original);
        expect(resumed.selectedIds, session.selectedIds);
      }
      final repeated = await choose(session, session.deck[3].id);
      expect(repeated.created, isFalse);
      expect(repeated.session.selectedIds, chosen);
      expect(await used(), 1);
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query('rune_readings');
      expect(rows, hasLength(1));
      expect(rows.single['spread_type'], spread.name);
      expect(rows.single['question'], 'My question?');
      expect(rows.single['date'], session.startedAt.millisecondsSinceEpoch);
      final data = jsonDecode(rows.single['reading_data'] as String) as Map;
      expect(data['session_id'], session.id);
      final positions = data['positions'] as List;
      expect(positions, hasLength(spread.runeCount));
      for (var i = 0; i < chosen.length; i++) {
        expect(positions[i]['rune']['name'], chosen[i]);
        expect(positions[i]['isReversed'], session.stone(chosen[i]).reversed);
        expect(positions[i]['positionMeaning'], 'Position $i');
        expect(positions[i]['position'], i);
      }
      final reading = await repo.reading(session);
      expect(reading?.id, session.resultId);
      expect(reading?.positions.map((p) => p.rune.name).toList(), chosen);
    });
  }

  test('concurrent commands fill only one position and IDs cannot repeat', () async {
    final session = await prepare(spread: RuneSpreadType.nineWorlds);
    final results = await Future.wait([
      choose(session, session.deck.first.id),
      choose(session, session.deck.last.id),
    ]);
    expect(results.every((r) => r.session.selectedIds.length == 1), isTrue);
    final current = await prepare(spread: RuneSpreadType.nineWorlds);
    final duplicate = await choose(current, current.selectedIds.single);
    expect(duplicate.session.selectedIds, current.selectedIds);
    expect(await used(), 0);
    await expectLater(choose(current, 'not-a-rune'), throwsStateError);
    await expectLater(choose(current, current.deck[5].id, active: false),
        throwsA(isA<RuneAccountChanged>()));
    await expectLater(choose(current, current.deck[5].id, owner: 'another-account'),
        throwsA(isA<RuneAccountChanged>()));
    expect((await prepare(spread: RuneSpreadType.nineWorlds)).selectedIds,
        current.selectedIds);
  });

  test('a result failure keeps every stone and the retry consumes once', () async {
    var session = await prepare();
    session = (await choose(session, session.deck.first.id)).session;
    session = (await choose(session, session.deck.last.id)).session;
    final last = session.deck[10].id;
    final expected = [...session.selectedIds, last];
    final db = await DatabaseHelper.instance.database;
    await db.execute("CREATE TRIGGER fail_runes BEFORE INSERT ON rune_readings "
        "BEGIN SELECT RAISE(ABORT, 'interrupted write'); END");
    await expectLater(choose(session, last), throwsA(isA<DatabaseException>()));
    expect(await used(), 0);
    expect(await db.query('rune_readings'), isEmpty);
    final resumed = await prepare();
    expect(resumed.selectedIds, expected);
    expect(resumed.isComplete, isTrue);
    expect(resumed.isCommitted, isFalse);
    await db.execute('DROP TRIGGER fail_runes');
    final result = await choose(resumed, session.deck[20].id);
    expect(result.session.selectedIds, expected);
    expect(result.created, isTrue);
    expect(await used(), 1);
  });

  test('Free keeps one table per day and reopens it without another debit', () async {
    final done = await finish(await prepare());
    expect(await used(), 1);
    final revisited = await prepare();
    expect(revisited.id, done.session.id);
    expect(revisited.isCommitted, isTrue);
    expect((await prepare(startNew: true)).id, done.session.id);
    await expectLater(prepare(spread: RuneSpreadType.single),
        throwsA(isA<RuneQuotaExceeded>()));
    await expectLater(prepare(question: 'Another question?'),
        throwsA(isA<RuneQuotaExceeded>()));
    await expectLater(prepare(question: ''), throwsA(isA<RuneQuotaExceeded>()));
    final db = await DatabaseHelper.instance.database;
    expect(await db.query('rune_readings'), hasLength(1));
  });

  test('the legacy counter is imported once and blocks a second Free table', () async {
    await expectLater(prepare(legacyUsed: 1), throwsA(isA<RuneQuotaExceeded>()));
    expect(await used(), 1);
    final premium = await prepare(legacyUsed: 1, premium: true);
    await finish(premium, premium: true);
    expect(await used(), 1);
  });

  test('Premium resumes until a new reading is explicitly requested', () async {
    final first = await finish(await prepare(premium: true), premium: true);
    expect((await prepare(premium: true)).id, first.session.id);
    final second = await prepare(premium: true, startNew: true);
    expect(second.id, isNot(first.session.id));
    expect(second.selectedIds, isEmpty);
    expect((await prepare(premium: true)).id, second.id);
    await finish(second, premium: true);
    expect(await used(), 0);
    final db = await DatabaseHelper.instance.database;
    expect(await db.query('rune_readings'), hasLength(2));
  });

  test('quota changes during selection are rechecked without changing the stones', () async {
    final session = await prepare();
    await UsageCoordinator().record(userId: user, legacyUsed: 0,
        category: UsageCoordinator.runes, day: day, operationId: 'elsewhere');
    await expectLater(finish(session), throwsA(isA<RuneQuotaExceeded>()));
    final resumed = await prepare(premium: true);
    expect(resumed.id, session.id);
    final upgraded = await finish(resumed, premium: true);
    expect(upgraded.session.selectedIds, resumed.selectedIds);
    expect(await used(), 1);
  });

  test('an unfinished table resumes its original day after midnight', () async {
    var session = await prepare();
    session = (await choose(session, session.deck.last.id)).session;
    final tomorrow = DateTime(2026, 9, 11);
    final resumed = await prepare(at: tomorrow);
    expect(resumed.id, session.id);
    expect(resumed.dayKey, session.dayKey);
    await finish(resumed);
    expect(await used(), 1);
    expect(await used(tomorrow), 0);
    expect((await prepare(at: tomorrow)).id, isNot(session.id));
  });

  test('an empty question is stored with its label and keeps the interpretation', () async {
    final done = await finish(await prepare(question: '   '));
    expect(done.session.question, '');
    final reading = await repo.reading(done.session);
    expect(reading?.question, 'No question');
    expect(reading?.interpretation, isNull);
    await RuneReadingRepository().attachInterpretation(
        readingId: done.session.resultId!, userId: user, interpretation: 'Woven');
    expect((await repo.reading(done.session))?.interpretation, 'Woven');
    expect((await repo.reading(done.session))?.positions.length, 3);
    expect((await prepare(question: '')).id, done.session.id);
  });

  test('accounts never share drafts, results or quota', () async {
    final mine = await prepare();
    final theirs = await prepare(owner: 'someone-else');
    expect(theirs.id, isNot(mine.id));
    await finish(mine);
    expect(await used(), 1);
    expect(await UsageCoordinator().used(userId: 'someone-else', legacyUsed: 0,
        category: UsageCoordinator.runes, day: day), 0);
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('rune_readings');
    expect(rows.single['user_id'], user);
    expect((await prepare(owner: 'someone-else')).id, theirs.id);
  });
}
