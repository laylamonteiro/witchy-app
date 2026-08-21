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

  /// A leitura de uma janela EXATA (mesmo início e mesmo fim), se existir.
  ///
  /// Serve para não acumular registros do mesmo período: pedir de novo a
  /// leitura das mesmas datas reescreve a que já existe, em vez de criar uma
  /// segunda no banco e uma segunda entrada no acervo.
  Future<CycleReadingModel?> findForExactPeriod(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await _db;
    final rows = await db.query(
      'cycle_readings',
      where: 'user_id = ? AND period_start = ? AND period_end = ?',
      whereArgs: [
        userId,
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
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

  /// As últimas leituras GERADAS, da que cobre o período mais recente para
  /// a mais antiga.
  ///
  /// A ordem é por `period_end`, não por `created_at`: o que importa aqui é
  /// até onde a vida da pessoa já foi lida, e uma leitura retroativa feita
  /// hoje cobre um pedaço antigo.
  Future<List<CycleReadingModel>> recentGenerated(
    String userId, {
    int limit = 5,
  }) async {
    final db = await _db;
    final rows = await db.query(
      'cycle_readings',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, CycleReadingStatus.generated],
      orderBy: 'period_end DESC',
      limit: limit,
    );
    return rows.map(CycleReadingModel.fromMap).toList();
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
