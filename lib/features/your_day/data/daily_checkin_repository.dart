import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/services/data_sync_service.dart';

/// Um dia de prática: a data (YYYY-MM-DD local) e os ritos concluídos nela.
typedef DailyCheckin = ({String date, Set<String> rites});

/// Check-in diário — a base do "streak" (dias seguidos) e dos ritos do dia.
///
/// Um registro por usuário por dia (UNIQUE(user_id, date)), como o cache do
/// clima mágico. Sincroniza na nuvem: a sequência é memória de uso, e
/// perdê-la ao reinstalar o app ou trocar de aparelho apaga meses de
/// constância.
class DailyCheckinRepository {
  static const String _table = 'daily_checkins';
  static const _uuid = Uuid();

  final DataSyncService _syncService = DataSyncService();

  /// Tabelas cujo `created_at` prova que o app foi aberto naquele dia —
  /// criar qualquer uma destas coisas exige ter entrado no app.
  static const List<String> _evidenceTables = [
    'spells',
    'dreams',
    'gratitudes',
    'affirmations',
    'desires',
    'sigils',
    'rune_readings',
    'oracle_readings',
    'pendulum_consultations',
    'user_encyclopedia_entries',
    'guided_ritual_logs',
  ];

  /// Chave do dia em horário LOCAL — nunca UTC, senão o dia "vira" na hora
  /// errada para quem está longe de Greenwich.
  static String dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Registra a visita de hoje (idempotente: só cria se ainda não existir).
  Future<void> registerVisit(String userId, {DateTime? now}) async {
    final db = await DatabaseHelper.instance.database;
    final today = dayKey(now ?? DateTime.now());
    final stamp = DateTime.now().millisecondsSinceEpoch;

    final row = {
      'id': _uuid.v4(),
      'user_id': userId,
      'date': today,
      'rites': '',
      'created_at': stamp,
      'updated_at': stamp,
      'synced': 0,
    };
    final inserted = await db.insert(
      _table,
      row,
      // Já existe check-in hoje? Mantém o registro (e os ritos) intactos.
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    // insert devolve 0 quando o conflito foi ignorado: só sobe para a nuvem
    // o dia que acabou de nascer.
    if (inserted != 0) {
      await _syncService.syncItem(SyncEntity.dailyCheckins, row);
    }
  }

  /// Reconstrói o histórico de visitas a partir das provas que o app
  /// guardou: conteúdo criado, lições concluídas e o clima mágico
  /// consultado. Serve para reparar o que se perdeu antes de a sequência
  /// existir (ou antes de sincronizar) — quem ficou só folheando a
  /// Enciclopédia num dia não deixou rastro e esse dia é irrecuperável.
  ///
  /// As linhas reconstruídas ficam com `rites` vazio de propósito: elas
  /// provam presença, não prática premiada, então não geram XP.
  Future<int> backfillFromPractice(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final days = <String>{};

    Future<void> collect(String sql) async {
      try {
        final rows = await db.rawQuery(sql, [userId]);
        for (final row in rows) {
          final day = row['day'] as String?;
          if (day != null && day.isNotEmpty) days.add(day);
        }
      } catch (_) {
        // Tabela ausente numa base antiga: segue com as demais.
      }
    }

    for (final table in _evidenceTables) {
      await collect(
        "SELECT DISTINCT date(created_at / 1000, 'unixepoch', 'localtime') "
        'AS day FROM $table WHERE user_id = ?',
      );
    }
    // Lição concluída tem carimbo próprio.
    await collect(
      "SELECT DISTINCT date(completed_at / 1000, 'unixepoch', 'localtime') "
      'AS day FROM learning_progress WHERE user_id = ?',
    );
    // O clima do dia só existe porque alguém abriu a página naquele dia —
    // é a prova de quem só consultou e não criou nada.
    await collect(
      'SELECT DISTINCT date AS day FROM daily_magical_weather '
      'WHERE user_id = ?',
    );

    if (days.isEmpty) return 0;

    final stamp = DateTime.now().millisecondsSinceEpoch;
    final batch = db.batch();
    for (final day in days) {
      batch.insert(
        _table,
        {
          'id': _uuid.v4(),
          'user_id': userId,
          'date': day,
          'rites': '',
          'created_at': stamp,
          'updated_at': stamp,
          'synced': 0,
        },
        // O UNIQUE(user_id, date) descarta os dias que já existem.
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    final results = await batch.commit(noResult: false);
    return results.where((r) => r != 0).length;
  }

  /// Ritos concluídos hoje.
  Future<Set<String>> ritesToday(String userId, {DateTime? now}) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      _table,
      columns: ['rites'],
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, dayKey(now ?? DateTime.now())],
      limit: 1,
    );
    if (rows.isEmpty) return {};
    return _parseRites(rows.first['rites'] as String?);
  }

  /// Marca um rito como concluído hoje (cria o check-in do dia se preciso).
  Future<Set<String>> completeRite(
    String userId,
    String riteId, {
    DateTime? now,
  }) async {
    final today = dayKey(now ?? DateTime.now());
    await registerVisit(userId, now: now);

    final db = await DatabaseHelper.instance.database;
    final current = await ritesToday(userId, now: now);
    if (current.contains(riteId)) return current;

    final updated = {...current, riteId};
    await db.update(
      _table,
      {
        'rites': updated.join(','),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'synced': 0,
      },
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, today],
    );

    // Sobe a linha inteira do dia (o upsert remoto casa por user_id+date).
    final rows = await db.query(
      _table,
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, today],
      limit: 1,
    );
    if (rows.isNotEmpty) {
      await _syncService.syncItem(SyncEntity.dailyCheckins, rows.first);
    }
    return updated;
  }

  /// Dias seguidos até hoje. Conta a partir de hoje ou de ontem — quem ainda
  /// não abriu o app hoje não perde a sequência antes do dia acabar.
  Future<int> currentStreak(String userId, {DateTime? now}) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      _table,
      columns: ['date'],
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: 400,
    );
    if (rows.isEmpty) return 0;

    final days = rows.map((r) => r['date'] as String).toSet();
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);

    var cursor = today;
    if (!days.contains(dayKey(cursor))) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!days.contains(dayKey(cursor))) return 0;
    }

    var streak = 0;
    while (days.contains(dayKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Maior sequência já alcançada (para o "recorde").
  Future<int> bestStreak(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      _table,
      columns: ['date'],
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date ASC',
    );
    if (rows.isEmpty) return 0;

    var best = 1;
    var run = 1;
    DateTime? previous;
    for (final row in rows) {
      final parts = (row['date'] as String).split('-');
      final day = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      if (previous != null) {
        run = day.difference(previous).inDays == 1 ? run + 1 : 1;
      }
      if (run > best) best = run;
      previous = day;
    }
    return best;
  }

  static Set<String> _parseRites(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    return raw.split(',').where((e) => e.isNotEmpty).toSet();
  }
}
