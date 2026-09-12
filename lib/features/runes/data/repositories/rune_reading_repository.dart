import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';
import '../models/rune_spread_model.dart';

class RuneReadingRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Salvar leitura
  final DataSyncService _syncService = DataSyncService();

  Future<void> saveReading(RuneReading reading, String userId,
      {DatabaseExecutor? executor}) async {
    final db = executor ?? await _dbHelper.database;

    final data = {
      'id': reading.id,
      'user_id': userId,
      'question': reading.question,
      'spread_type': reading.spreadType.name,
      'reading_data': reading.toJsonString(),
      'date': reading.date.millisecondsSinceEpoch,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
      'synced': 0,
    };
    await db.insert(
      'rune_readings',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // A local result/usage transaction must never wait on network I/O.
    if (executor == null) {
      await _syncService.syncItem(SyncEntity.runeReadings, data);
    }
  }

  Future<void> syncReading(String id, String userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query('rune_readings',
        where: 'id = ? AND user_id = ?', whereArgs: [id, userId], limit: 1);
    if (rows.isNotEmpty) {
      await _syncService.syncItem(SyncEntity.runeReadings, rows.single);
    }
  }

  Future<RuneReading?> updateInterpretation(
      String id, String userId, String interpretation) async {
    final db = await _dbHelper.database;
    final updated = await db.transaction((txn) async {
      final rows = await txn.query('rune_readings',
          where: 'id = ? AND user_id = ?', whereArgs: [id, userId], limit: 1);
      if (rows.isEmpty) return null;
      final old = RuneReading.fromJsonString(rows.single['reading_data'] as String);
      final reading = RuneReading(id: old.id, question: old.question,
          spreadType: old.spreadType, positions: old.positions,
          interpretation: interpretation, date: old.date);
      await txn.update('rune_readings', {
        'reading_data': reading.toJsonString(),
        'updated_at': DateTime.now().millisecondsSinceEpoch, 'synced': 0,
      }, where: 'id = ? AND user_id = ?', whereArgs: [id, userId]);
      return reading;
    });
    if (updated != null) await syncReading(id, userId);
    return updated;
  }

  // Buscar todas as leituras
  Future<List<RuneReading>> getAllReadings() async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'rune_readings',
      orderBy: 'date DESC',
    );

    return maps.map((map) {
      final readingData = map['reading_data'] as String;
      return RuneReading.fromJsonString(readingData);
    }).toList();
  }

  // Buscar leitura por ID
  Future<RuneReading?> getReading(String id, {required String userId}) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'rune_readings',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );

    if (maps.isEmpty) {
      return null;
    }

    final readingData = maps.first['reading_data'] as String;
    return RuneReading.fromJsonString(readingData);
  }

  // Deletar leitura
  Future<void> deleteReading(String id) async {
    final db = await _dbHelper.database;

    await db.delete(
      'rune_readings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Buscar leituras por período
  Future<List<RuneReading>> getReadingsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'rune_readings',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
      orderBy: 'date DESC',
    );

    return maps.map((map) {
      final readingData = map['reading_data'] as String;
      return RuneReading.fromJsonString(readingData);
    }).toList();
  }
}
