import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/rune_spread_model.dart';

class RuneReadingRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Salvar leitura
  Future<void> saveReading(RuneReading reading) async {
    final db = await _dbHelper.database;

    await db.insert(
      'rune_readings',
      {
        'id': reading.id,
        'question': reading.question,
        'spread_type': reading.spreadType.name,
        'reading_data': reading.toJsonString(),
        'date': reading.date.millisecondsSinceEpoch,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
