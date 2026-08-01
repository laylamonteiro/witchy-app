import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_helper.dart';

/// Um dia de prática: a data (YYYY-MM-DD local) e os ritos concluídos nela.
typedef DailyCheckin = ({String date, Set<String> rites});

/// Check-in diário — a base do "streak" (dias seguidos) e dos ritos do dia.
///
/// Um registro por usuário por dia (UNIQUE(user_id, date)), como o cache do
/// clima mágico. Local-only por enquanto: não entra no pipeline de sync.
class DailyCheckinRepository {
  static const String _table = 'daily_checkins';
  static const _uuid = Uuid();

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

    await db.insert(
      _table,
      {
        'id': _uuid.v4(),
        'user_id': userId,
        'date': today,
        'rites': '',
        'created_at': stamp,
        'updated_at': stamp,
        'synced': 0,
      },
      // Já existe check-in hoje? Mantém o registro (e os ritos) intactos.
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
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
