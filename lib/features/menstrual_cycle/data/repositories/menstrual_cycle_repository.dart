import 'package:flutter/foundation.dart' show debugPrint;
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/database/menstrual_cycle_schema.dart';
import '../../domain/menstrual_day.dart';
import '../services/menstrual_archive_recorder.dart';

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
///
/// Toda linha que entra ou sai daqui tem um espelho no Grimório: a página do
/// dia em "Meus Registros", escrita pelo [MenstrualArchiveRecorder]. O espelho
/// mora NESTE repositório, e não nas telas, porque são três os caminhos que
/// mexem na linha (a folha do dia, o apagar da folha e o "apagar meus
/// registros do ciclo" da tela de Privacidade) e nenhum deles pode ter o
/// direito de esquecer. Quem grava o dia grava a página; quem apaga
/// o dia apaga a página — não há ordem em que uma exista sem a outra.
///
/// [history] devolve o histórico VIVO — é o que "A Lua e você" lê. Levar os
/// dados embora continua trabalho do DataExportService, que lê a tabela
/// direto: de propósito, ele leva também as lápides, que o `deleted = 0`
/// daqui esconderia do backup dela.
class MenstrualCycleRepository {
  MenstrualCycleRepository({
    DatabaseHelper? dbHelper,
    MenstrualArchiveRecorder? archive,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _archive = archive ?? MenstrualArchiveRecorder();

  final DatabaseHelper _dbHelper;
  final MenstrualArchiveRecorder _archive;

  static const _table = MenstrualCycleSchema.table;

  /// Grava o dia. Corrigir um dia já registrado mantém a data de criação e
  /// sobe a revisão; registrar num dia apagado o traz de volta, porque foi a
  /// pessoa que pediu.
  Future<MenstrualDay> save(MenstrualDay day) async {
    final db = await _dbHelper.database;
    final saved = await db.transaction((txn) async {
      final current = await _rowOf(txn, day.userId, day.dayKey);
      final gravado = day.copyWith(
        revision: (current?.revision ?? 0) + 1,
        deleted: false,
        updatedAt: day.updatedAt,
      );
      final row = gravado.toRow();
      if (current != null) {
        row['created_at'] = current.createdAt.millisecondsSinceEpoch;
      }
      await txn.insert(_table, row,
          conflictAlgorithm: ConflictAlgorithm.replace);
      return MenstrualDay.fromRow(row);
    });
    // Fora da transação de propósito: a página é uma segunda tabela, e
    // prender o commit do registro dela seria deixar o dia sem gravar por
    // causa da vitrine. A ordem é esta — a linha primeiro, o espelho depois.
    //
    // E a falha da vitrine não pode virar "não salvei": o dia JÁ está
    // gravado aqui. Deixar a exceção subir faria a folha mostrar erro em
    // cima de uma gravação que deu certo, e não recarregar a tela. O
    // espelho é idempotente, então a próxima gravação do mesmo dia o
    // reconstrói sozinha.
    try {
      await _archive.record(saved);
    } catch (e) {
      debugPrint('espelho do ciclo não gravou: $e');
    }
    return saved;
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
    // Incondicional: a página tem de sair mesmo quando não havia linha viva
    // para apagar. Um espelho órfão é justamente o modo de falha que este
    // repositório não pode ter — ela apagaria o dia na roda, voltaria ao
    // Grimório e o encontraria ali, inteiro.
    await _archive.erase(userId: userId, day: day);
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

  /// Todos os dias registrados, do primeiro ao mais recente, sem lápides.
  /// Um começo de três meses atrás é tão começo quanto o de ontem, e por isso
  /// "A Lua e você" lê daqui, e não do mês na tela.
  Future<List<MenstrualDay>> history(String userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      _table,
      where: 'user_id = ? AND deleted = 0',
      whereArgs: [userId],
      orderBy: 'day_key ASC',
    );
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

  /// Apaga tudo desta conta, de verdade, inclusive as lápides — e as páginas
  /// que os dias tinham no Grimório, que somem no mesmo gesto. A confirmação
  /// dessa tela conta dias, e há exatamente uma página por dia: o número que
  /// ela lê antes de confirmar é o número de páginas que somem.
  Future<int> purge(String userId) async {
    final db = await _dbHelper.database;
    await _archive.eraseAll(userId);
    return db.delete(_table, where: 'user_id = ?', whereArgs: [userId]);
  }

  /// Recebe a versão de outro aparelho. Ganha a revisão maior; empatadas,
  /// ganha a gravação mais recente. É assim que um apagar feito offline não
  /// volta quando um aparelho antigo se conecta com a cópia velha.
  Future<bool> mergeRemote(MenstrualDay incoming) async {
    final db = await _dbHelper.database;
    final row = incoming.toRow();
    final venceu = await db.transaction((txn) async {
      final current = await _rowOf(txn, incoming.userId, incoming.dayKey);
      if (current != null) {
        final older = incoming.revision < current.revision;
        final tie = incoming.revision == current.revision &&
            !incoming.updatedAt.isAfter(current.updatedAt);
        if (older || tie) return false;
      }
      row['synced'] = 1;
      if (current != null) {
        row['created_at'] = current.createdAt.millisecondsSinceEpoch;
      }
      await txn.insert(_table, row,
          conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    });
    // A página é função da linha, venha ela da tela ou de outro aparelho — e
    // a lápide que chega de fora tira a página junto, senão o dia que ela
    // apagou no celular continuaria no Grimório do navegador.
    if (venceu) {
      final vencedor = MenstrualDay.fromRow(row);
      if (vencedor.deleted) {
        await _archive.erase(userId: vencedor.userId, day: vencedor.day);
      } else {
        await _archive.record(vencedor);
      }
    }
    return venceu;
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
