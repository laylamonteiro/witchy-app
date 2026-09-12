import '../../../core/database/database_helper.dart';
import '../presentation/providers/daily_checkin_provider.dart';

/// The three requirements of a complete day, evaluated where the action
/// happens instead of only when the home card is built: a gratitude and a
/// dream written today, plus the day's featured rite. Sealing the day is
/// idempotent and keeps the existing bonus policy; nothing here celebrates.
class DayCompletionService {
  DayCompletionService({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _dbHelper;

  /// Returns true only when this call sealed the day.
  Future<bool> evaluate({
    required String userId,
    required DailyCheckinProvider checkin,
    DateTime? now,
  }) async {
    if (!checkin.isLoaded || checkin.isRiteDone(DailyRites.dayComplete)) return false;
    if (!checkin.isRiteDone(DailyRites.featuredToday(now: now))) return false;
    final instant = now ?? DateTime.now();
    final start = DateTime(instant.year, instant.month, instant.day);
    final end = DateTime(instant.year, instant.month, instant.day + 1);
    if (!await _hasToday('gratitudes', userId, start, end)) return false;
    if (!await _hasToday('dreams', userId, start, end)) return false;
    await checkin.completeRite(DailyRites.dayComplete);
    return checkin.isRiteDone(DailyRites.dayComplete);
  }

  Future<bool> _hasToday(String table, String userId, DateTime start, DateTime end) async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.rawQuery(
        'SELECT 1 FROM $table WHERE user_id = ? AND created_at >= ? AND created_at < ? LIMIT 1',
        [userId, start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      );
      return rows.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
