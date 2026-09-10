import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/reading_session_schema.dart';
import 'package:grimorio_de_bolso/features/journeys/data/repositories/journey_stats_repository.dart';
import 'package:grimorio_de_bolso/features/journeys/data/repositories/progress_milestone_repository.dart';
import 'package:grimorio_de_bolso/features/journeys/domain/action_outcome.dart';
import 'package:grimorio_de_bolso/features/journeys/domain/progress_coordinator.dart';
import 'package:grimorio_de_bolso/features/learning/presentation/providers/learning_provider.dart';
import 'package:grimorio_de_bolso/features/your_day/presentation/providers/daily_checkin_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  const user = 'progress-user';

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('progress_coordinator');
    await databaseFactory.setDatabasesPath(dir.path);
  });
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    for (final table in [...ReadingSessionSchema.tables, 'dreams', 'gratitudes',
        'tarot_readings', 'rune_readings', 'daily_checkins']) {
      await db.delete(table);
    }
  });

  Future<String> insertDream(String owner, {DateTime? at}) async {
    final db = await DatabaseHelper.instance.database;
    final id = const Uuid().v4();
    final when = (at ?? DateTime.now()).millisecondsSinceEpoch;
    await db.insert('dreams', {
      'id': id, 'user_id': owner, 'title': 'Dream', 'content': 'A dream',
      'date': when, 'created_at': when, 'updated_at': when, 'synced': 0,
    });
    return id;
  }

  Future<void> insertGratitude(String owner) async {
    final db = await DatabaseHelper.instance.database;
    final when = DateTime.now().millisecondsSinceEpoch;
    await db.insert('gratitudes', {
      'id': const Uuid().v4(), 'user_id': owner, 'title': 'Thanks', 'content': 'Grateful',
      'date': when, 'created_at': when, 'updated_at': when, 'synced': 0,
    });
  }

  test('the tenth dream reaches a milestone once; repeats, reloads and edits never repeat it',
      () async {
    final learning = LearningProvider();
    await learning.setUserId(user);
    final coordinator = ProgressCoordinator();
    var celebrations = 0;
    coordinator.onCelebration = () => celebrations++;
    await coordinator.setUserId(user);

    final first = await coordinator.record(userId: user, origin: ActionOrigin.dream,
        entityId: await insertDream(user), learning: learning);
    expect(first.xpGained, LearningProvider.xpPerCreation);
    expect(first.newMilestones.map((s) => s.id).toSet(), {'son_01_01', 'ini_01_02'});
    expect(first.newLevel, isNull);
    expect(coordinator.current?.actionId, first.actionId);
    expect(celebrations, 1);

    for (var i = 0; i < 8; i++) {
      final outcome = await coordinator.record(userId: user, origin: ActionOrigin.dream,
          entityId: await insertDream(user), learning: learning);
      expect(outcome.newMilestones, isEmpty);
      expect(outcome.xpGained, LearningProvider.xpPerCreation);
    }
    final tenth = await coordinator.record(userId: user, origin: ActionOrigin.dream,
        entityId: await insertDream(user), learning: learning);
    expect(tenth.newMilestones.map((s) => s.id).toList(), ['son_01_02']);
    expect(tenth.newMilestones.single.localizedTitle, isNotEmpty);
    expect(celebrations, 2);

    // Recording again for the same state, or after a reload, adds nothing.
    final again = await coordinator.record(userId: user, origin: ActionOrigin.dream,
        entityId: 'edited', learning: learning);
    expect(again.newMilestones, isEmpty);
    expect(again.xpGained, 0);
    await learning.load();
    expect(await ProgressMilestoneRepository().acquired(user),
        containsAll(['son_01_01', 'ini_01_02', 'son_01_02']));
    expect(celebrations, 2);
  });

  test('milestones already reached before the update are adopted silently', () async {
    for (var i = 0; i < 10; i++) {
      await insertDream(user, at: DateTime(2026, 1, 1 + i));
    }
    final learning = LearningProvider();
    await learning.setUserId(user);
    final coordinator = ProgressCoordinator();
    var celebrations = 0;
    coordinator.onCelebration = () => celebrations++;
    await coordinator.setUserId(user);
    final acquired = await ProgressMilestoneRepository().acquired(user);
    expect(acquired, containsAll(['son_01_01', 'son_01_02']));
    expect(coordinator.current, isNull);
    expect(celebrations, 0);
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('progress_milestones', where: 'user_id = ?', whereArgs: [user]);
    expect(rows.every((r) => r['source_action_id'] == null), isTrue);

    final eleventh = await coordinator.record(userId: user, origin: ActionOrigin.dream,
        entityId: await insertDream(user), learning: learning);
    expect(eleventh.newMilestones, isEmpty);
    expect(eleventh.xpGained, LearningProvider.xpPerCreation);
  });

  test('a lost and recovered count never re-grants, and levels are keyed by threshold',
      () async {
    final learning = LearningProvider();
    await learning.setUserId(user);
    final coordinator = ProgressCoordinator();
    await coordinator.setUserId(user);
    final ids = <String>[];
    for (var i = 0; i < 19; i++) {
      ids.add(await insertDream(user));
    }
    final nineteenth = await coordinator.record(userId: user, origin: ActionOrigin.dream,
        entityId: ids.last, learning: learning, present: false);
    expect(nineteenth.newLevel, isNull);
    expect(coordinator.current, isNull, reason: 'present: false never queues');
    final db = await DatabaseHelper.instance.database;
    await db.delete('dreams', where: 'id = ?', whereArgs: [ids.first]);
    await coordinator.record(userId: user, origin: ActionOrigin.other,
        entityId: 'deleted', learning: learning, present: false);
    final restored = await coordinator.record(userId: user, origin: ActionOrigin.dream,
        entityId: await insertDream(user), learning: learning, present: false);
    expect(restored.newMilestones, isEmpty, reason: 'ten dreams was already acquired');
    final twentieth = await coordinator.record(userId: user, origin: ActionOrigin.dream,
        entityId: await insertDream(user), learning: learning, present: false);
    expect(twentieth.xpAfter, 20 * LearningProvider.xpPerCreation);
    expect(twentieth.newLevel?.minXp, 100);
    final more = await coordinator.record(userId: user, origin: ActionOrigin.dream,
        entityId: await insertDream(user), learning: learning, present: false);
    expect(more.newLevel, isNull);
  });

  test('concurrent actions are serialized per account and credited separately', () async {
    final learning = LearningProvider();
    await learning.setUserId(user);
    final coordinator = ProgressCoordinator();
    await coordinator.setUserId(user);
    await insertDream(user);
    await insertGratitude(user);
    final results = await Future.wait([
      coordinator.record(userId: user, origin: ActionOrigin.dream,
          entityId: 'd', learning: learning, present: false),
      coordinator.record(userId: user, origin: ActionOrigin.gratitude,
          entityId: 'g', learning: learning, present: false),
    ]);
    expect(results.first.xpGained, 2 * LearningProvider.xpPerCreation);
    expect(results.last.xpGained, 0);
    expect(results.first.newMilestones.map((s) => s.id),
        containsAll(['son_01_01', 'ini_01_02', 'ini_01_03']));
    expect(results.last.newMilestones, isEmpty);
    expect(results.map((r) => r.actionId).toSet(), hasLength(2));
  });

  test('tarot readings count towards the readings total', () async {
    final db = await DatabaseHelper.instance.database;
    final when = DateTime.now().millisecondsSinceEpoch;
    await db.insert('tarot_readings', {
      'id': 't1', 'user_id': user, 'spread_type': 'daily', 'signature': 's',
      'reading_data': '{}', 'date': when, 'created_at': when, 'updated_at': when, 'synced': 0,
    });
    await db.insert('rune_readings', {
      'id': 'r1', 'user_id': user, 'question': '', 'spread_type': 'single',
      'reading_data': '{}', 'date': when, 'created_at': when, 'updated_at': when, 'synced': 0,
    });
    final stats = await JourneyStatsRepository().load(user);
    expect(stats['tarot_readings'], 1);
    expect(stats['all_readings'], 2);
    expect(JourneyStatsRepository.reachedSteps(stats), isEmpty);
    expect(JourneyStatsRepository.stepById('div_01_04')?.targetEntity, 'all_readings');
  });

  test('the day closes through the service when the three rites are done', () async {
    final learning = LearningProvider();
    await learning.setUserId(user);
    final checkin = DailyCheckinProvider();
    await checkin.setUserId(user);
    final coordinator = ProgressCoordinator();
    await coordinator.setUserId(user);
    await insertGratitude(user);
    await checkin.completeRite(DailyRites.featuredToday());
    final withoutDream = await coordinator.record(userId: user, origin: ActionOrigin.gratitude,
        entityId: 'g', learning: learning, checkin: checkin, present: false);
    expect(withoutDream.dayCompleted, isFalse);
    final xpBeforeDream = learning.xp;
    final withDream = await coordinator.record(userId: user, origin: ActionOrigin.dream,
        entityId: await insertDream(user), learning: learning, checkin: checkin, present: false);
    expect(withDream.dayCompleted, isTrue);
    expect(checkin.isRiteDone(DailyRites.dayComplete), isTrue);
    expect(withDream.xpGained,
        learning.xp - xpBeforeDream, reason: 'creation plus the full-day bonus');
    expect(withDream.xpGained, LearningProvider.xpPerCreation + LearningProvider.xpPerFullDay);
    final again = await coordinator.record(userId: user, origin: ActionOrigin.dream,
        entityId: await insertDream(user), learning: learning, checkin: checkin, present: false);
    expect(again.dayCompleted, isFalse, reason: 'A day is sealed once');
    checkin.dispose();
  });
}
