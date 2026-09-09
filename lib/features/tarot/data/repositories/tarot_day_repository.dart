import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/services/usage_coordinator.dart';
import '../../domain/regra_da_carta_do_dia.dart';

class TarotDayState {
  const TarotDayState({this.dailyQuestion, this.lastQuestion});
  final String? dailyQuestion;
  final String? lastQuestion;
}

/// Question memory now participates in the same commit as the daily draw.
class TarotDayRepository {
  TarotDayRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;
  final DatabaseHelper _dbHelper;

  Future<TarotDayState> read(String userId, DateTime day) async {
    final seed = await legacySeed(userId, day);
    final db = await _dbHelper.database;
    return db.transaction((txn) => ensureIn(txn,
        userId: userId, dayKey: UsageCoordinator.dayKey(day), seed: seed));
  }

  Future<void> remember({
    required String userId,
    required DateTime day,
    required String question,
    bool daily = false,
  }) async {
    final seed = await legacySeed(userId, day);
    final db = await _dbHelper.database;
    final key = UsageCoordinator.dayKey(day);
    await db.transaction((txn) async {
      await ensureIn(txn, userId: userId, dayKey: key, seed: seed);
      await txn.update(
        'tarot_day_state',
        {
          if (daily) 'daily_question': question.trim().toLowerCase(),
          'last_question': question.trim(),
        },
        where: 'user_id = ? AND day_key = ?',
        whereArgs: [userId, key],
      );
    });
  }

  static Future<TarotDayState> legacySeed(String userId, DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    final key = UsageCoordinator.dayKey(day);
    return TarotDayState(
      dailyQuestion: perguntaSeForDeHoje(
        guardada: prefs.getString('tarot_daily_q_$userId'), hoje: key),
      lastQuestion: perguntaSeForDeHoje(
        guardada: prefs.getString('tarot_last_q_$userId'), hoje: key),
    );
  }

  static Future<TarotDayState> ensureIn(
    DatabaseExecutor db, {
    required String userId,
    required String dayKey,
    required TarotDayState seed,
  }) async {
    await db.insert(
      'tarot_day_state',
      {
        'user_id': userId,
        'day_key': dayKey,
        'daily_question': seed.dailyQuestion,
        'last_question': seed.lastQuestion,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    final rows = await db.query('tarot_day_state',
        where: 'user_id = ? AND day_key = ?', whereArgs: [userId, dayKey]);
    return TarotDayState(
      dailyQuestion: rows.single['daily_question'] as String?,
      lastQuestion: rows.single['last_question'] as String?,
    );
  }
}
