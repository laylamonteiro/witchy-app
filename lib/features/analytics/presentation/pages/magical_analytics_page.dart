import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/database_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Página de Analytics Mágicos - Estatísticas de uso do app
class MagicalAnalyticsPage extends StatefulWidget {
  const MagicalAnalyticsPage({super.key});

  @override
  State<MagicalAnalyticsPage> createState() => _MagicalAnalyticsPageState();
}

class _MagicalAnalyticsPageState extends State<MagicalAnalyticsPage> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      final db = await DatabaseHelper.instance.database;
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser.id;

      // Contadores gerais
      final spellsCount = await _countRecords(db, 'spells', userId);
      final dreamsCount = await _countRecords(db, 'dreams', userId);
      final desiresCount = await _countRecords(db, 'desires', userId);
      final gratitudesCount = await _countRecords(db, 'gratitudes', userId);
      final affirmationsCount = await _countRecords(db, 'affirmations', userId);
      final sigilsCount = await _countRecords(db, 'sigils', userId);
      final runeReadingsCount = await _countRecords(db, 'rune_readings', userId);
      final oracleReadingsCount = await _countRecords(db, 'oracle_readings', userId);
      final pendulumCount = await _countRecords(db, 'pendulum_consultations', userId);

      // Estatísticas por período
      final spellsThisMonth = await _countRecordsThisMonth(db, 'spells', userId);
      final dreamsThisWeek = await _countRecordsThisWeek(db, 'dreams', userId);
      final gratitudesToday = await _countRecordsToday(db, 'gratitudes', userId);

      // Desejos por status
      final desiresPending = await _countDesiresByStatus(db, userId, 'pending');
      final desiresManifested = await _countDesiresByStatus(db, userId, 'manifested');

      // Feitiços por tipo
      final spellsByType = await _getSpellsByType(db, userId);

      // Streak de gratidão
      final gratitudeStreak = await _calculateGratitudeStreak(db, userId);

      setState(() {
        _stats = {
          // Totais
          'spells': spellsCount,
          'dreams': dreamsCount,
          'desires': desiresCount,
          'gratitudes': gratitudesCount,
          'affirmations': affirmationsCount,
          'sigils': sigilsCount,
          'runeReadings': runeReadingsCount,
          'oracleReadings': oracleReadingsCount,
          'pendulum': pendulumCount,
          // Por período
          'spellsThisMonth': spellsThisMonth,
          'dreamsThisWeek': dreamsThisWeek,
          'gratitudesToday': gratitudesToday,
          // Desejos
          'desiresPending': desiresPending,
          'desiresManifested': desiresManifested,
          // Tipos de feitiço
          'spellsByType': spellsByType,
          // Streaks
          'gratitudeStreak': gratitudeStreak,
          // Total de práticas
          'totalPractices': spellsCount + dreamsCount + gratitudesCount +
                           affirmationsCount + runeReadingsCount +
                           oracleReadingsCount + pendulumCount,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Erro ao carregar estatísticas: $e');
    }
  }

  Future<int> _countRecords(dynamic db, String table, String userId) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $table WHERE user_id = ?',
        [userId],
      );
      return result.first['count'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _countRecordsThisMonth(dynamic db, String table, String userId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $table WHERE user_id = ? AND created_at >= ?',
        [userId, startOfMonth.toIso8601String()],
      );
      return result.first['count'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _countRecordsThisWeek(dynamic db, String table, String userId) async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $table WHERE user_id = ? AND created_at >= ?',
        [userId, DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day).toIso8601String()],
      );
      return result.first['count'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _countRecordsToday(dynamic db, String table, String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $table WHERE user_id = ? AND created_at >= ?',
        [userId, startOfDay.toIso8601String()],
      );
      return result.first['count'] as int? ?? 0;
    } catch (e) {
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
    } catch (e) {
      return 0;
    }
  }

  Future<Map<String, int>> _getSpellsByType(dynamic db, String userId) async {
    try {
      final result = await db.rawQuery(
        'SELECT type, COUNT(*) as count FROM spells WHERE user_id = ? GROUP BY type',
        [userId],
      );
      final map = <String, int>{};
      for (final row in result) {
        final type = row['type'] as String? ?? 'Outro';
        map[type] = row['count'] as int? ?? 0;
      }
      return map;
    } catch (e) {
      return {};
    }
  }

  Future<int> _calculateGratitudeStreak(dynamic db, String userId) async {
    try {
      final result = await db.rawQuery(
        '''SELECT DISTINCT date(created_at) as day
           FROM gratitudes
           WHERE user_id = ?
           ORDER BY day DESC''',
        [userId],
      );

      if (result.isEmpty) return 0;

      int streak = 0;
      DateTime? previousDay;

      for (final row in result) {
        final dayStr = row['day'] as String?;
        if (dayStr == null) continue;

        final day = DateTime.parse(dayStr);

        if (previousDay == null) {
          // Verificar se é hoje ou ontem
          final today = DateTime.now();
          final todayDate = DateTime(today.year, today.month, today.day);
          final yesterdayDate = todayDate.subtract(const Duration(days: 1));

          if (day == todayDate || day == yesterdayDate) {
            streak = 1;
            previousDay = day;
          } else {
            break; // Streak quebrado
          }
        } else {
          final expectedDay = previousDay.subtract(const Duration(days: 1));
          if (day == expectedDay) {
            streak++;
            previousDay = day;
          } else {
            break; // Streak quebrado
          }
        }
      }

      return streak;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Estatisticas Magicas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.lilac))
          : RefreshIndicator(
              onRefresh: _loadStats,
              color: AppColors.lilac,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumo geral
                    _buildSummaryCard(),
                    const SizedBox(height: 20),

                    // Streaks e conquistas
                    _buildStreaksCard(),
                    const SizedBox(height: 20),

                    // Práticas por categoria
                    _buildCategoriesGrid(),
                    const SizedBox(height: 20),

                    // Desejos e manifestações
                    _buildDesiresCard(),
                    const SizedBox(height: 20),

                    // Feitiços por tipo
                    if ((_stats['spellsByType'] as Map?)?.isNotEmpty ?? false)
                      _buildSpellTypesCard(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    final totalPractices = _stats['totalPractices'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.lilac.withValues(alpha: 0.3),
            AppColors.pink.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lilac.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 48,
            color: AppColors.starYellow,
          ),
          const SizedBox(height: 12),
          Text(
            '$totalPractices',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Praticas Magicas',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniStat('Este mes', '${_stats['spellsThisMonth'] ?? 0}', Icons.calendar_month),
              _buildMiniStat('Esta semana', '${_stats['dreamsThisWeek'] ?? 0}', Icons.date_range),
              _buildMiniStat('Hoje', '${_stats['gratitudesToday'] ?? 0}', Icons.today),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildStreaksCard() {
    final gratitudeStreak = _stats['gratitudeStreak'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
              SizedBox(width: 8),
              Text(
                'Sequencias',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStreakItem(
                  'Gratidao',
                  gratitudeStreak,
                  Colors.orange,
                  Icons.favorite,
                ),
              ),
            ],
          ),
          if (gratitudeStreak > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      gratitudeStreak >= 30
                          ? 'Incrivel! 30 dias de gratidao!'
                          : gratitudeStreak >= 7
                              ? 'Otimo! 1 semana de gratidao!'
                              : 'Continue assim! $gratitudeStreak dias de gratidao!',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStreakItem(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count dias',
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suas Praticas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
          children: [
            _buildCategoryCard('Feiticos', _stats['spells'] ?? 0, Icons.auto_fix_high, Colors.purple),
            _buildCategoryCard('Sonhos', _stats['dreams'] ?? 0, Icons.nights_stay, Colors.indigo),
            _buildCategoryCard('Gratidao', _stats['gratitudes'] ?? 0, Icons.favorite, Colors.pink),
            _buildCategoryCard('Afirmacoes', _stats['affirmations'] ?? 0, Icons.format_quote, Colors.teal),
            _buildCategoryCard('Sigilos', _stats['sigils'] ?? 0, Icons.gesture, Colors.amber),
            _buildCategoryCard('Runas', _stats['runeReadings'] ?? 0, Icons.casino, Colors.red),
            _buildCategoryCard('Oraculo', _stats['oracleReadings'] ?? 0, Icons.style, Colors.cyan),
            _buildCategoryCard('Pendulo', _stats['pendulum'] ?? 0, Icons.radio_button_checked, Colors.green),
            _buildCategoryCard('Desejos', _stats['desires'] ?? 0, Icons.star, Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String label, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDesiresCard() {
    final pending = _stats['desiresPending'] ?? 0;
    final manifested = _stats['desiresManifested'] ?? 0;
    final total = pending + manifested;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 24),
              SizedBox(width: 8),
              Text(
                'Manifestacoes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDesiresStat('Pendentes', pending, Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDesiresStat('Manifestados', manifested, Colors.green),
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total > 0 ? manifested / total : 0,
                backgroundColor: Colors.orange.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation(Colors.green),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              total > 0
                  ? '${((manifested / total) * 100).toStringAsFixed(0)}% de taxa de manifestacao'
                  : 'Comece a registrar seus desejos!',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDesiresStat(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpellTypesCard() {
    final spellsByType = _stats['spellsByType'] as Map<String, int>? ?? {};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_fix_high, color: Colors.purple, size: 24),
              SizedBox(width: 8),
              Text(
                'Feiticos por Tipo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...spellsByType.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.key,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: spellsByType.values.isNotEmpty
                          ? entry.value / spellsByType.values.reduce((a, b) => a > b ? a : b)
                          : 0,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation(
                        _getTypeColor(entry.key),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${entry.value}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'proteção':
      case 'protecao':
        return Colors.blue;
      case 'amor':
        return Colors.pink;
      case 'prosperidade':
        return Colors.green;
      case 'cura':
        return Colors.teal;
      case 'limpeza':
        return Colors.cyan;
      case 'banimento':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }
}
