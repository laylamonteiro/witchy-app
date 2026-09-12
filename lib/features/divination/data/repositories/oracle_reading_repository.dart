import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';
import '../models/oracle_card_model.dart';

/// Rows of `oracle_readings`, which keep syncing through the existing
/// content sync. The session link and the counselor text travel inside
/// `reading_data`; there is no new remote column.
class OracleReadingRepository {
  OracleReadingRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _dbHelper;
  final DataSyncService _syncService = DataSyncService();

  Future<Map<String, dynamic>> insertReading(
    OracleReading reading,
    String userId, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final data = {
      'id': reading.id,
      'user_id': userId,
      'spread_type': reading.spreadType.name,
      'reading_data': reading.toJsonString(),
      'date': reading.date.millisecondsSinceEpoch,
      'created_at': now,
      'updated_at': now,
      'synced': 0,
    };
    await db.insert('oracle_readings', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return data;
  }

  /// Best-effort upload of a row already final on this device.
  Future<void> syncReading(Map<String, dynamic> data) =>
      _syncService.syncItem(SyncEntity.oracleReadings, data);

  Future<OracleReading?> reading(String id, String userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query('oracle_readings', columns: ['reading_data'],
        where: 'id = ? AND user_id = ?', whereArgs: [id, userId], limit: 1);
    if (rows.isEmpty) return null;
    return OracleReading.fromJsonString(rows.single['reading_data'] as String);
  }

  Future<void> attachInterpretation({
    required String readingId,
    required String userId,
    required String interpretation,
  }) async {
    final db = await _dbHelper.database;
    final rows = await db.query('oracle_readings',
        where: 'id = ? AND user_id = ?', whereArgs: [readingId, userId], limit: 1);
    if (rows.isEmpty) return;
    final row = Map<String, dynamic>.from(rows.single);
    final json = jsonDecode(row['reading_data'] as String) as Map<String, dynamic>;
    json['interpretation'] = interpretation;
    row['reading_data'] = jsonEncode(json);
    row['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    row['synced'] = 0;
    await db.update('oracle_readings', row,
        where: 'id = ? AND user_id = ?', whereArgs: [readingId, userId]);
    await _syncService.syncItem(SyncEntity.oracleReadings, row);
  }
}
