import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/database/menstrual_cycle_schema.dart';
import '../../domain/menstrual_day.dart';

/// O registro menstrual da pessoa: grava, lê, corrige e apaga o que ela
/// escreveu, e nada mais.
///
/// Não há cálculo aqui — nem dia do ciclo, nem média, nem próxima data. Ler o
/// histórico devolve os dias registrados; o que se faz com eles é decisão de
/// quem chama, e o que é derivado fica atrás do gate Premium.
///
/// Apagar deixa lápide: o dia sai do histórico, mas a linha continua com uma
/// revisão maior, para que a cópia antiga de outro aparelho não o traga de
/// volta. Só [purge] remove de verdade, quando a pessoa pede para apagar tudo.
class MenstrualCycleRepository {
  MenstrualCycleRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _dbHelper;

  static const _table = MenstrualCycleSchema.table;

  /// Grava o dia. Corrigir um dia já registrado mantém a data de criação e
  /// sobe a revisão; registrar num dia apagado o traz de volta, porque foi a
  /// pessoa que pediu.
  Future<MenstrualDay> save(MenstrualDay day) async {
    final db = await _dbHelper.database;
    return db.transaction((txn) async {
      final current = await _rowOf(txn, day.userId, day.dayKey);
      final saved = day.copyWith(
        revision: (current?.revision ?? 0) + 1,
        deleted: false,
        updatedAt: day.updatedAt,
      );
      final row = saved.toRow();
      if (current != null) {
        row['created_at'] = current.createdAt.millisecondsSinceEpoch;
      }
      await txn.insert(_table, row,
          conflictAlgorithm: ConflictAlgorithm.replace);
      return MenstrualDay.fromRow(row);
    });
  }

  /// Apaga um dia deixando a lápide.
  Future<void> remove({required String userId, required DateTime day}) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      final current = await _rowOf(txn, userId, MenstrualDay.keyOf(day));
      if (current == null) return;
      await txn.update(
        _table,
        {
          'mark': MenstrualMark.note.name,
          'flow': null,
          'symptoms': '[]',
          'mood': null,
          'note': '',
          'deleted': 1,
          'revision': current.revision + 1,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
          'synced': 0,
        },
        where: 'user_id = ? AND day_key = ?',
        whereArgs: [userId, current.dayKey],
      );
    });
  }

  /// O dia pedido, se houver registro vivo.
  Future<MenstrualDay?> dayOf({
    required String userId,
    required DateTime day,
  }) async {
    final db = await _dbHelper.database;
    final found = await _rowOf(db, userId, MenstrualDay.keyOf(day));
    return found == null || found.deleted ? null : found;
  }

  /// Os dias registrados entre duas datas, nas pontas inclusive, em ordem.
  /// Um dia sem linha simplesmente não vem: é ausência de registro.
  Future<List<MenstrualDay>> between({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      _table,
      where: 'user_id = ? AND deleted = 0 AND day_key >= ? AND day_key <= ?',
      whereArgs: [userId, MenstrualDay.keyOf(from), MenstrualDay.keyOf(to)],
      orderBy: 'day_key ASC',
    );
    return [for (final row in rows) MenstrualDay.fromRow(row)];
  }

  /// Tudo o que a pessoa registrou, para ela ver ou levar embora.
  Future<List<MenstrualDay>> all(String userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(_table,
        where: 'user_id = ? AND deleted = 0',
        whereArgs: [userId],
        orderBy: 'day_key ASC');
    return [for (final row in rows) MenstrualDay.fromRow(row)];
  }

  /// Quantos dias existem. Serve para dizer o alcance de exportar ou apagar —
  /// é contagem de operação, não um número sobre o corpo de ninguém.
  Future<int> count(String userId) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM $_table WHERE user_id = ? AND deleted = 0',
      [userId],
    );
    return (rows.first['total'] as num?)?.toInt() ?? 0;
  }

  /// Apaga tudo desta conta, de verdade, inclusive as lápides.
  Future<int> purge(String userId) async {
    final db = await _dbHelper.database;
    return db.delete(_table, where: 'user_id = ?', whereArgs: [userId]);
  }

  /// Recebe a versão de outro aparelho. Ganha a revisão maior; empatadas,
  /// ganha a gravação mais recente. É assim que um apagar feito offline não
  /// volta quando um aparelho antigo se conecta com a cópia velha.
  Future<bool> mergeRemote(MenstrualDay incoming) async {
    final db = await _dbHelper.database;
    return db.transaction((txn) async {
      final current = await _rowOf(txn, incoming.userId, incoming.dayKey);
      if (current != null) {
        final older = incoming.revision < current.revision;
        final tie = incoming.revision == current.revision &&
            !incoming.updatedAt.isAfter(current.updatedAt);
        if (older || tie) return false;
      }
      final row = incoming.toRow();
      row['synced'] = 1;
      if (current != null) {
        row['created_at'] = current.createdAt.millisecondsSinceEpoch;
      }
      await txn.insert(_table, row,
          conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    });
  }

  Future<MenstrualDay?> _rowOf(
      DatabaseExecutor db, String userId, String dayKey) async {
    final rows = await db.query(
      _table,
      where: 'user_id = ? AND day_key = ?',
      whereArgs: [userId, dayKey],
      limit: 1,
    );
    return rows.isEmpty ? null : MenstrualDay.fromRow(rows.first);
  }
}
