import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/data/repositories/free_writing_repository.dart';
import '../../../diary/data/services/reading_archive_composer.dart';
import '../models/rune_spread_model.dart';

class RuneReadingRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Salvar leitura
  final DataSyncService _syncService = DataSyncService();

  Future<void> saveReading(RuneReading reading, String userId) async {
    final db = await _dbHelper.database;

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
    await _syncService.syncItem(SyncEntity.runeReadings, data);

    // A leitura também vira uma página em "Meus Registros" (acervo
    // unificado) — antes ela era gravada e nunca mais vista.
    final page = ReadingArchiveComposer.runes(reading);
    await FreeWritingRepository().insert(FreeWritingModel(
      userId: userId,
      title: page.title,
      content: page.content,
      source: FreeWritingSource.runes,
    ));
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
