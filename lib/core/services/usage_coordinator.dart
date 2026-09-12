import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../database/database_helper.dart';

/// Preferences seed a day once; afterwards SQLite is the authority.
/// Tarot and Oracle share a category; Runas keeps its own existing quota.
class UsageCoordinator {
  UsageCoordinator({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _dbHelper;
  static const oracle = 'oracle';
  static const runes = 'runes';

  /// Keep the existing question-preference day format for migration.
  static String dayKey(DateTime date) =>
      '${date.year}-${date.month}-${date.day}';

  Future<int> oracleUsed({
    required String userId,
    required int legacyUsed,
    DateTime? day,
  }) => used(userId: userId, legacyUsed: legacyUsed, day: day);

  Future<int> used({
    required String userId,
    required int legacyUsed,
    String category = oracle,
    DateTime? day,
  }) async {
    final db = await _dbHelper.database;
    final key = dayKey(day ?? DateTime.now());
    return db.transaction((txn) async {
      await importBalance(txn,
          userId: userId, dayKey: key, legacyUsed: legacyUsed, category: category);
      return usedIn(txn, userId: userId, dayKey: key, category: category);
    });
  }

  Future<int> recordOracleUse({
    required String userId,
    required int legacyUsed,
    DateTime? day,
    String? operationId,
  }) => recordUse(userId: userId, legacyUsed: legacyUsed,
      day: day, operationId: operationId);

  Future<int> recordUse({
    required String userId,
    required int legacyUsed,
    String category = oracle,
    DateTime? day,
    String? operationId,
  }) async {
    final db = await _dbHelper.database;
    final key = dayKey(day ?? DateTime.now());
    final operation = operationId ?? const Uuid().v4();
    return db.transaction((txn) async {
      await importBalance(txn,
          userId: userId, dayKey: key, legacyUsed: legacyUsed, category: category);
      await recordIn(txn,
          userId: userId, dayKey: key, operationId: operation, category: category);
      return usedIn(txn, userId: userId, dayKey: key, category: category);
    });
  }

  static Future<void> importBalance(
    DatabaseExecutor db, {
    required String userId,
    required String dayKey,
    required int legacyUsed,
    String category = oracle,
  }) async {
    await db.insert(
      'usage_balances',
      {
        'user_id': userId,
        'category': category,
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
    String category = oracle,
  }) async {
    final rows = await db.rawQuery('''
      SELECT initial_used + COALESCE((
        SELECT SUM(amount) FROM usage_operations
        WHERE user_id = ? AND category = ? AND day_key = ?
      ), 0) AS used
      FROM usage_balances
      WHERE user_id = ? AND category = ? AND day_key = ?
    ''', [userId, category, dayKey, userId, category, dayKey]);
    if (rows.isEmpty) throw StateError('Usage balance was not initialized');
    return (rows.single['used'] as num).toInt();
  }

  static Future<void> recordIn(
    DatabaseExecutor db, {
    required String userId,
    required String dayKey,
    required String operationId,
    String category = oracle,
  }) async {
    await db.insert(
      'usage_operations',
      {
        'user_id': userId,
        'operation_id': operationId,
        'category': category,
        'day_key': dayKey,
        'amount': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }
}
