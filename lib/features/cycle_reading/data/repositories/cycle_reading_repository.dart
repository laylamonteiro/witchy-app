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
  /// A janela é identificada pelo instante de início do período.
  Future<CycleReadingModel?> findForPeriod(
    String userId,
    DateTime periodStart,
  ) async {
    final db = await _db;
    final rows = await db.query(
      'cycle_readings',
      where: 'user_id = ? AND period_start = ?',
      whereArgs: [userId, periodStart.millisecondsSinceEpoch],
      orderBy: 'created_at DESC',
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

  /// A pessoa Pro já usou a leitura inclusa deste mês-calendário?
  Future<bool> proGrantUsedThisMonth(String userId, {DateTime? now}) async {
    final reference = now ?? DateTime.now();
    final startOfMonth = DateTime(reference.year, reference.month, 1);
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM cycle_readings '
      'WHERE user_id = ? AND origin = ? AND created_at >= ?',
      [
        userId,
        CycleReadingOrigin.pro,
        startOfMonth.millisecondsSinceEpoch,
      ],
    );
    return ((rows.first['total'] as int?) ?? 0) > 0;
  }
}
