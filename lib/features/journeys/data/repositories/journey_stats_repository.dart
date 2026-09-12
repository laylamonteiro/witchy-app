import '../../../../core/database/database_helper.dart';
import '../models/journey_model.dart';

/// The counts every journey step is measured against. One place for the
/// queries the Journeys page and the progress coordinator both need, so the
/// screen and the milestone detection can never disagree. Tarot readings
/// count towards the total of readings, like runes, oracle and pendulum.
class JourneyStatsRepository {
  JourneyStatsRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _dbHelper;

  Future<Map<String, int>> load(String userId) async {
    final db = await _dbHelper.database;
    final stats = <String, int>{
      'spells': await _countUserSpells(db, userId),
      'dreams': await _countRecords(db, 'dreams', userId),
      'desires': await _countRecords(db, 'desires', userId),
      'gratitudes': await _countRecords(db, 'gratitudes', userId),
      'affirmations': await _countRecords(db, 'affirmations', userId),
      'sigils': await _countRecords(db, 'sigils', userId),
      'rune_readings': await _countRecords(db, 'rune_readings', userId),
      'oracle_readings': await _countRecords(db, 'oracle_readings', userId),
      'pendulum_consultations':
          await _countRecords(db, 'pendulum_consultations', userId),
      'tarot_readings': await _countRecords(db, 'tarot_readings', userId),
      'birth_charts': await _countRecords(db, 'birth_charts', userId),
      'desires_manifested': await _countDesiresByStatus(db, userId, 'manifested'),
      'gratitude_streak': await _calculateStreak(db, 'gratitudes', userId),
      'guided_rituals': await _countRecords(db, 'guided_ritual_logs', userId),
    };
    stats['all_readings'] = stats['rune_readings']! +
        stats['oracle_readings']! +
        stats['pendulum_consultations']! +
        stats['tarot_readings']!;
    return stats;
  }

  static int progressOf(Map<String, int> stats, JourneyStep step) {
    if (step.type == StepType.streak) {
      return stats['${step.targetEntity}_streak'] ?? stats['gratitude_streak'] ?? 0;
    }
    return stats[step.targetEntity] ?? 0;
  }

  /// IDs of every step whose requirement the stats already satisfy.
  static Set<String> reachedSteps(Map<String, int> stats) => {
    for (final journey in AvailableJourneys.all)
      for (final step in journey.steps)
        if (progressOf(stats, step) >= step.requiredCount) step.id,
  };

  static JourneyStep? stepById(String id) {
    for (final journey in AvailableJourneys.all) {
      for (final step in journey.steps) {
        if (step.id == id) return step;
      }
    }
    return null;
  }

  Future<int> _countRecords(dynamic db, String table, String userId) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $table WHERE user_id = ?',
        [userId],
      );
      return result.first['count'] as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Only spells the person created (never the preloaded ones).
  Future<int> _countUserSpells(dynamic db, String userId) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM spells WHERE user_id = ? AND is_preloaded = 0',
        [userId],
      );
      return result.first['count'] as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _countDesiresByStatus(dynamic db, String userId, String status) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM desires WHERE user_id = ? AND status = ?',
        [userId, status],
      );
      return result.first['count'] as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _calculateStreak(dynamic db, String table, String userId) async {
    try {
      final result = await db.rawQuery(
        '''SELECT DISTINCT date(created_at / 1000, 'unixepoch', 'localtime') as day
           FROM $table
           WHERE user_id = ?
           ORDER BY day DESC''',
        [userId],
      );
      if (result.isEmpty) return 0;
      var streak = 0;
      DateTime? previousDay;
      for (final row in result) {
        final dayStr = row['day'] as String?;
        if (dayStr == null) continue;
        final day = DateTime.parse(dayStr);
        if (previousDay == null) {
          final today = DateTime.now();
          final todayDate = DateTime(today.year, today.month, today.day);
          final yesterdayDate = todayDate.subtract(const Duration(days: 1));
          if (day == todayDate || day == yesterdayDate) {
            streak = 1;
            previousDay = day;
          } else {
            break;
          }
        } else {
          final expectedDay = previousDay.subtract(const Duration(days: 1));
          if (day == expectedDay) {
            streak++;
            previousDay = day;
          } else {
            break;
          }
        }
      }
      return streak;
    } catch (_) {
      return 0;
    }
  }
}
