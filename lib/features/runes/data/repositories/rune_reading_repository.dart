import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';
import '../models/rune_spread_model.dart';

class RuneReadingRepository {
  RuneReadingRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _dbHelper;

  // Salvar leitura
  final DataSyncService _syncService = DataSyncService();

  Future<void> saveReading(RuneReading reading, String userId) async {
    final data = await insertReading(reading, userId);
    await _syncService.syncItem(SyncEntity.runeReadings, data);
  }

  /// Grava a linha local (dentro de [executor], quando a leitura faz parte
  /// de uma transação maior) e devolve o payload para subir depois.
  Future<Map<String, dynamic>> insertReading(
    RuneReading reading,
    String userId, {
    DatabaseExecutor? executor,
  }) async {
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
    return data;
  }

  /// Sobe uma leitura já gravada localmente (best-effort, como saveReading).
  Future<void> syncReading(Map<String, dynamic> data) =>
      _syncService.syncItem(SyncEntity.runeReadings, data);

  /// Guarda a interpretação do Conselheiro junto da leitura, para que
  /// reabrir a mesma mesa não peça outra geração.
  Future<void> attachInterpretation({
    required String readingId,
    required String userId,
    required String interpretation,
  }) async {
    final db = await _dbHelper.database;
    final rows = await db.query('rune_readings',
        where: 'id = ? AND user_id = ?', whereArgs: [readingId, userId], limit: 1);
    if (rows.isEmpty) return;
    final row = Map<String, dynamic>.from(rows.single);
    final json = jsonDecode(row['reading_data'] as String) as Map<String, dynamic>;
    json['interpretation'] = interpretation;
    row['reading_data'] = jsonEncode(json);
    row['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    row['synced'] = 0;
    await db.update('rune_readings', row,
        where: 'id = ? AND user_id = ?', whereArgs: [readingId, userId]);
    await _syncService.syncItem(SyncEntity.runeReadings, row);
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
  Future<RuneReading?> getReading(String id) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'rune_readings',
      where: 'id = ?',
      whereArgs: [id],
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
