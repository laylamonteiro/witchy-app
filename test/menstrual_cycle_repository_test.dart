import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/menstrual_cycle_schema.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/data/services/cycle_reading_composer.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/repositories/menstrual_cycle_repository.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/internal_season.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_day.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'support/short_test_timeout.dart';

void main() {
  useShortTestTimeout();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  const user = 'cycle-user';
  const other = 'another-account';
  late MenstrualCycleRepository repo;

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('menstrual_cycle');
    await databaseFactory.setDatabasesPath(dir.path);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    await db.delete(MenstrualCycleSchema.table);
    repo = MenstrualCycleRepository();
  });

  MenstrualDay day(
    int dayOfMonth, {
    MenstrualMark mark = MenstrualMark.flow,
    MenstrualFlowLevel? flow,
    List<String> symptoms = const [],
    String note = '',
    String owner = user,
  }) =>
      MenstrualDay(
        userId: owner,
        day: DateTime(2026, 3, dayOfMonth),
        mark: mark,
        flow: flow,
        symptoms: symptoms,
        note: note,
      );

  test('the day keeps what was written, and nothing else', () async {
    await repo.save(day(8,
        mark: MenstrualMark.start,
        flow: MenstrualFlowLevel.medium,
        symptoms: ['cramps', 'tired'],
        note: 'Quieter morning'));
    final saved = await repo.dayOf(userId: user, day: DateTime(2026, 3, 8));
    expect(saved, isNotNull);
    expect(saved!.mark, MenstrualMark.start);
    expect(saved.flow, MenstrualFlowLevel.medium);
    expect(saved.symptoms, ['cramps', 'tired']);
    expect(saved.note, 'Quieter morning');
    expect(saved.day, DateTime(2026, 3, 8));

    // Nothing derived is stored: no cycle day, no length, no estimate.
    final db = await DatabaseHelper.instance.database;
    final columns = (await db.rawQuery(
            'PRAGMA table_info(${MenstrualCycleSchema.table})'))
        .map((row) => row['name'] as String)
        .toSet();
    expect(
        columns,
        {
          'user_id', 'day_key', 'mark', 'flow', 'symptoms', 'mood', 'note',
          'revision', 'deleted', 'created_at', 'updated_at', 'synced',
        },
        reason: 'A derived column here would be a Premium result stored on Free');
  });

  test('spotting stays spotting; a start is only ever a choice', () async {
    await repo.save(day(3, mark: MenstrualMark.spotting));
    final saved = await repo.dayOf(userId: user, day: DateTime(2026, 3, 3));
    expect(saved!.mark, MenstrualMark.spotting);
    final history = await repo.between(
        userId: user, from: DateTime(2026, 3, 1), to: DateTime(2026, 3, 31));
    expect(history.where((d) => d.mark == MenstrualMark.start), isEmpty,
        reason: 'Nothing promotes a spotting into a beginning');
  });

  test('correcting a day keeps its first date and raises the revision',
      () async {
    final first = await repo.save(day(10, note: 'quick note'));
    expect(first.revision, 1);
    final fixed = await repo.save(day(10,
        mark: MenstrualMark.end, note: 'it ended today'));
    expect(fixed.revision, 2);
    expect(fixed.createdAt, first.createdAt,
        reason: 'Correcting is not writing for the first time');
    final reread = await repo.dayOf(userId: user, day: DateTime(2026, 3, 10));
    expect(reread!.mark, MenstrualMark.end);
    expect(reread.note, 'it ended today');
    expect(await repo.count(user), 1, reason: 'A correction is not a new day');
  });

  test('an empty day is absence of a record, never absence of symptoms',
      () async {
    await repo.save(day(5));
    final march = await repo.between(
        userId: user, from: DateTime(2026, 3, 1), to: DateTime(2026, 3, 31));
    expect(march.map((d) => d.day), [DateTime(2026, 3, 5)]);
    expect(await repo.dayOf(userId: user, day: DateTime(2026, 3, 6)), isNull);
  });

  test('deleting leaves a headstone that an older device cannot lift',
      () async {
    final saved = await repo.save(day(12, note: 'written here'));
    await repo.remove(userId: user, day: DateTime(2026, 3, 12));
    expect(await repo.dayOf(userId: user, day: DateTime(2026, 3, 12)), isNull);
    expect(await repo.count(user), 0);

    // The old device arrives with the copy it had before the deletion.
    final stale = saved.copyWith(revision: saved.revision);
    expect(await repo.mergeRemote(stale), isFalse);
    expect(await repo.dayOf(userId: user, day: DateTime(2026, 3, 12)), isNull,
        reason: 'What was deleted offline does not come back');

    // The person writing there again brings the day back, because they asked.
    await repo.save(day(12, note: 'again'));
    final back = await repo.dayOf(userId: user, day: DateTime(2026, 3, 12));
    expect(back!.note, 'again');
    expect(back.revision, greaterThan(saved.revision));
  });

  test('the chosen season and what she wrote with it travel with the day',
      () async {
    await repo.save(day(9).copyWith(
      season: InternalSeason.spring,
      seasonNote: 'um primeiro gesto',
    ));
    final saved = await repo.dayOf(userId: user, day: DateTime(2026, 3, 9));
    expect(saved!.season, InternalSeason.spring);
    expect(saved.seasonNote, 'um primeiro gesto');

    // Desmarcar a estação não apaga o resto do registro.
    await repo.save(saved.copyWith(clearSeason: true));
    final cleared = await repo.dayOf(userId: user, day: DateTime(2026, 3, 9));
    expect(cleared!.season, isNull);
    expect(cleared.mark, saved.mark);
    expect(cleared.seasonNote, 'um primeiro gesto');
  });

  test('erasing a day also erases the season and the writing with it',
      () async {
    await repo.save(day(10).copyWith(
      season: InternalSeason.autumn,
      seasonNote: 'o que pode ficar mais leve',
    ));
    await repo.remove(userId: user, day: DateTime(2026, 3, 10));
    final db = await DatabaseHelper.instance.database;
    final row = (await db.query(MenstrualCycleSchema.table,
            where: 'user_id = ? AND day_key = ?',
            whereArgs: [user, '2026-03-10']))
        .single;
    expect(row['deleted'], 1);
    expect(row['season'], isNull);
    expect(row['season_note'], '',
        reason: 'A lápide não guarda o que ela escreveu');
  });

  test('a newer revision from another device wins', () async {
    await repo.save(day(15, note: 'from this phone'));
    final incoming = MenstrualDay(
      userId: user,
      day: DateTime(2026, 3, 15),
      mark: MenstrualMark.flow,
      note: 'from the tablet',
      revision: 9,
      updatedAt: DateTime(2026, 3, 16),
    );
    expect(await repo.mergeRemote(incoming), isTrue);
    final merged = await repo.dayOf(userId: user, day: DateTime(2026, 3, 15));
    expect(merged!.note, 'from the tablet');

    // And the same revision arriving again changes nothing.
    expect(await repo.mergeRemote(incoming), isFalse);
  });

  test('two accounts never see each other, and erasing is per account',
      () async {
    await repo.save(day(20, note: 'mine'));
    await repo.save(day(20, note: 'theirs', owner: other));
    expect(await repo.count(user), 1);
    expect(await repo.count(other), 1);

    final erased = await repo.purge(user);
    expect(erased, 1);
    expect(await repo.all(user), isEmpty);
    expect(await repo.count(other), 1, reason: 'Only the asking account is erased');

    // Erasing everything leaves no headstone either: there is nothing left.
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(MenstrualCycleSchema.table,
        where: 'user_id = ?', whereArgs: [user]);
    expect(rows, isEmpty);
  });

  test('the record never reaches the Cycle Reading', () async {
    await repo.save(day(9, mark: MenstrualMark.start, note: 'private'));
    final composer = CycleReadingComposer();
    final total = await composer.countPeriodRecords(
      userId: user,
      start: DateTime(2026, 3, 1),
      end: DateTime(2026, 3, 31),
    );
    expect(total, 0,
        reason: 'The menstrual record is not material for the reading here');
    final heat = await composer.dailyRecordCounts(
      userId: user,
      start: DateTime(2026, 3, 1),
      end: DateTime(2026, 3, 31),
    );
    expect(heat.values.fold<int>(0, (a, b) => a + b), 0);
  });
}
