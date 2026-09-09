import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../database/database_helper.dart';

/// Preferences seed a day once; afterwards SQLite is the authority.
/// Tarot and Oracle use the same existing quota category.
class UsageCoordinator {
  UsageCoordinator({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _dbHelper;
  static const oracle = 'oracle';

  /// Keep the existing question-preference day format for migration.
  static String dayKey(DateTime date) =>
      '${date.year}-${date.month}-${date.day}';

  Future<int> oracleUsed({
    required String userId,
    required int legacyUsed,
    DateTime? day,
  }) async {
    final db = await _dbHelper.database;
    final key = dayKey(day ?? DateTime.now());
    return db.transaction((txn) async {
      await importBalance(txn,
          userId: userId, dayKey: key, legacyUsed: legacyUsed);
      return usedIn(txn, userId: userId, dayKey: key);
    });
  }

  Future<int> recordOracleUse({
    required String userId,
    required int legacyUsed,
    DateTime? day,
    String? operationId,
  }) async {
    final db = await _dbHelper.database;
    final key = dayKey(day ?? DateTime.now());
    final operation = operationId ?? const Uuid().v4();
    return db.transaction((txn) async {
      await importBalance(txn,
          userId: userId, dayKey: key, legacyUsed: legacyUsed);
      await recordIn(txn,
          userId: userId, dayKey: key, operationId: operation);
      return usedIn(txn, userId: userId, dayKey: key);
    });
  }

  static Future<void> importBalance(
    DatabaseExecutor db, {
    required String userId,
    required String dayKey,
    required int legacyUsed,
  }) async {
    await db.insert(
      'usage_balances',
      {
        'user_id': userId,
        'category': oracle,
        'day_key': dayKey,
        'initial_used': legacyUsed < 0 ? 0 : legacyUsed,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<int> usedIn(
    DatabaseExecutor db, {
    required String userId,
    required String dayKey,
  }) async {
    final rows = await db.rawQuery('''
      SELECT initial_used + COALESCE((
        SELECT SUM(amount) FROM usage_operations
        WHERE user_id = ? AND category = ? AND day_key = ?
      ), 0) AS used
      FROM usage_balances
      WHERE user_id = ? AND category = ? AND day_key = ?
    ''', [userId, oracle, dayKey, userId, oracle, dayKey]);
    if (rows.isEmpty) throw StateError('Usage balance was not initialized');
    return (rows.single['used'] as num).toInt();
  }

  static Future<void> recordIn(
    DatabaseExecutor db, {
    required String userId,
    required String dayKey,
    required String operationId,
  }) async {
    await db.insert(
      'usage_operations',
      {
        'user_id': userId,
        'operation_id': operationId,
        'category': oracle,
        'day_key': dayKey,
        'amount': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }
}
