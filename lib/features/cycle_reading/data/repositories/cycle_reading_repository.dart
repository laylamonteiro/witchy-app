import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';
import '../models/cycle_reading_model.dart';

/// Persistência local (+ espelho no Supabase) das Leituras do Ciclo.
class CycleReadingRepository {
  CycleReadingRepository({Database? db}) : _dbOverride = db;

  /// Banco injetável para testes; produção usa o [DatabaseHelper].
  final Database? _dbOverride;
  final DataSyncService _syncService = DataSyncService();

  Future<Database> get _db async =>
      _dbOverride ?? await DatabaseHelper.instance.database;

  Future<void> insert(CycleReadingModel reading) async {
    final db = await _db;
    await db.insert(
      'cycle_readings',
      reading.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _syncService.syncItem(SyncEntity.cycleReadings, reading.toMap());
  }

  Future<void> update(CycleReadingModel reading) async {
    final db = await _db;
    await db.update(
      'cycle_readings',
      reading.toMap(),
      where: 'id = ?',
      whereArgs: [reading.id],
    );
    await _syncService.syncItem(SyncEntity.cycleReadings, reading.toMap());
  }

  /// A leitura desta janela, se existir (crédito pendente OU já gerada).
  ///
  /// A janela é identificada pelo início do período E pelo tipo: semana e
  /// lunação são produtos distintos, e comprar uma nunca satisfaz a outra.
  Future<CycleReadingModel?> findForPeriod(
    String userId,
    DateTime periodStart, {
    String periodType = CycleReadingPeriodType.lunation,
  }) async {
    final db = await _db;
    final rows = await db.query(
      'cycle_readings',
      where: 'user_id = ? AND period_start = ? AND period_type = ?',
      whereArgs: [
        userId,
        periodStart.millisecondsSinceEpoch,
        periodType,
      ],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return CycleReadingModel.fromMap(rows.first);
  }

  /// A leitura que gerou uma entrada do acervo — o caminho de volta quando
  /// a pessoa reabre o relatório por "Meus Registros".
  Future<CycleReadingModel?> findByWritingId(String writingId) async {
    final db = await _db;
    final rows = await db.query(
      'cycle_readings',
      where: 'writing_id = ?',
      whereArgs: [writingId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return CycleReadingModel.fromMap(rows.first);
  }

  /// Uma leitura JÁ GERADA cujo período cruza a janela `[start, end)`.
  ///
  /// É a trava do período escolhido a dedo: retroagir para ler um pedaço de
  /// vida ainda não lido é legítimo (e o motivo de existir a escolha de
  /// datas); repetir um pedaço já lido não é uma leitura nova.
  ///
  /// Sobreposição clássica de intervalos meio-abertos: existe cruzamento
  /// quando `period_start < end` E `period_end > start`. Encostar não é
  /// cruzar — uma janela que começa exatamente onde a outra terminou passa.
  Future<CycleReadingModel?> overlappingGenerated(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await _db;
    final rows = await db.query(
      'cycle_readings',
      where: 'user_id = ? AND status = ? '
          'AND period_start < ? AND period_end > ?',
      whereArgs: [
        userId,
        CycleReadingStatus.generated,
        end.millisecondsSinceEpoch,
        start.millisecondsSinceEpoch,
      ],
      orderBy: 'period_start DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return CycleReadingModel.fromMap(rows.first);
  }

  Future<List<CycleReadingModel>> getAll(String userId) async {
    final db = await _db;
    final rows = await db.query(
      'cycle_readings',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'period_start DESC',
    );
    return rows.map(CycleReadingModel.fromMap).toList();
  }

}
