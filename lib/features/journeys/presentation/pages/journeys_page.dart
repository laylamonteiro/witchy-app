import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/database_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/journey_model.dart';

/// Página de Jornadas Mágicas Gamificadas
class JourneysPage extends StatefulWidget {
  const JourneysPage({super.key});

  @override
  State<JourneysPage> createState() => _JourneysPageState();
}

class _JourneysPageState extends State<JourneysPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, int> _userStats = {};
  int _totalXp = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUserStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserStats() async {
    setState(() => _isLoading = true);

    try {
      final db = await DatabaseHelper.instance.database;
      final authProvider = context.read<AuthProvider>();
      final odUserId = authProvider.currentUser.id;

      // Carregar contagens de cada entidade
      _userStats = {
        'spells': await _countRecords(db, 'spells', odUserId),
        'dreams': await _countRecords(db, 'dreams', odUserId),
        'desires': await _countRecords(db, 'desires', odUserId),
        'gratitudes': await _countRecords(db, 'gratitudes', odUserId),
        'affirmations': await _countRecords(db, 'affirmations', odUserId),
        'sigils': await _countRecords(db, 'sigils', odUserId),
        'rune_readings': await _countRecords(db, 'rune_readings', odUserId),
        'oracle_readings': await _countRecords(db, 'oracle_readings', odUserId),
        'pendulum_consultations': await _countRecords(db, 'pendulum_consultations', odUserId),
        'birth_charts': await _countRecords(db, 'birth_charts', odUserId),
        'desires_manifested': await _countDesiresByStatus(db, odUserId, 'manifested'),
        'gratitude_streak': await _calculateStreak(db, 'gratitudes', odUserId),
      };

      // Calcular all_readings
      _userStats['all_readings'] = (_userStats['rune_readings'] ?? 0) +
          (_userStats['oracle_readings'] ?? 0) +
          (_userStats['pendulum_consultations'] ?? 0);

      // Calcular XP total baseado no progresso
      _totalXp = _calculateTotalXp();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Erro ao carregar stats: $e');
    }
  }

  Future<int> _countRecords(dynamic db, String table, String odUserId) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $table WHERE user_id = ?',
        [odUserId],
      );
      return result.first['count'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _countDesiresByStatus(dynamic db, String odUserId, String status) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM desires WHERE user_id = ? AND status = ?',
        [odUserId, status],
      );
      return result.first['count'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _calculateStreak(dynamic db, String table, String odUserId) async {
    try {
      final result = await db.rawQuery(
        '''SELECT DISTINCT date(created_at) as day
           FROM $table
           WHERE user_id = ?
           ORDER BY day DESC''',
        [odUserId],
      );

      if (result.isEmpty) return 0;

      int streak = 0;
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
    } catch (e) {
      return 0;
    }
  }

  int _calculateTotalXp() {
    int xp = 0;

    for (final journey in AvailableJourneys.all) {
      for (final step in journey.steps) {
        final progress = _getStepProgress(step);
        if (progress >= step.requiredCount) {
          xp += step.xpReward;
        }
      }
    }

    return xp;
  }

  int _getStepProgress(JourneyStep step) {
    if (step.type == StepType.streak) {
      return _userStats['${step.targetEntity}_streak'] ??
          _userStats['gratitude_streak'] ??
          0;
    }
    return _userStats[step.targetEntity] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Jornadas Magicas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.lilac,
          labelColor: AppColors.lilac,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Iniciante'),
            Tab(text: 'Diario'),
            Tab(text: 'Divinacao'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.lilac))
          : Column(
              children: [
                // XP Header
                _buildXpHeader(),

                // Jornadas
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildJourneysList(AvailableJourneys.all),
                      _buildJourneysList(AvailableJourneys.byCategory(JourneyCategory.iniciante)),
                      _buildJourneysList([
                        ...AvailableJourneys.byCategory(JourneyCategory.diario),
                        ...AvailableJourneys.byCategory(JourneyCategory.grimorio),
                      ]),
                      _buildJourneysList([
                        ...AvailableJourneys.byCategory(JourneyCategory.divinacao),
                        ...AvailableJourneys.byCategory(JourneyCategory.astrologia),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildXpHeader() {
    final level = (_totalXp / 500).floor() + 1;
    final xpInLevel = _totalXp % 500;
    final xpForNextLevel = 500;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.lilac.withValues(alpha: 0.3),
            AppColors.pink.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lilac.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.lilac, AppColors.pink],
              ),
            ),
            child: Center(
              child: Text(
                '$level',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nivel $level - ${_getLevelTitle(level)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_totalXp XP total',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: xpInLevel / xpForNextLevel,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(AppColors.starYellow),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$xpInLevel / $xpForNextLevel XP para o proximo nivel',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLevelTitle(int level) {
    if (level >= 20) return 'Arquimago';
    if (level >= 15) return 'Mestre';
    if (level >= 10) return 'Adepto';
    if (level >= 5) return 'Praticante';
    if (level >= 3) return 'Aprendiz';
    return 'Iniciante';
  }

  Widget _buildJourneysList(List<JourneyModel> journeys) {
    if (journeys.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma jornada disponivel',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserStats,
      color: AppColors.lilac,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: journeys.length,
        itemBuilder: (context, index) {
          return _buildJourneyCard(journeys[index]);
        },
      ),
    );
  }

  Widget _buildJourneyCard(JourneyModel journey) {
    int completedSteps = 0;
    int earnedXp = 0;

    for (final step in journey.steps) {
      final progress = _getStepProgress(step);
      if (progress >= step.requiredCount) {
        completedSteps++;
        earnedXp += step.xpReward;
      }
    }

    final isCompleted = completedSteps == journey.totalSteps;
    final progress = journey.totalSteps > 0 ? completedSteps / journey.totalSteps : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? journey.color.withValues(alpha: 0.7)
              : Colors.white10,
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showJourneyDetails(journey),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: journey.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(journey.icon, color: journey.color, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                journey.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isCompleted) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 18,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            journey.description,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white10,
                              valueColor: AlwaysStoppedAnimation(journey.color),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$completedSteps de ${journey.totalSteps} etapas',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.starYellow.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: AppColors.starYellow, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '$earnedXp/${journey.xpReward} XP',
                            style: const TextStyle(
                              color: AppColors.starYellow,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showJourneyDetails(JourneyModel journey) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: journey.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(journey.icon, color: journey.color, size: 40),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                journey.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                journey.description,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Etapas
                    const Text(
                      'Etapas da Jornada',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...journey.steps.asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;
                      final progress = _getStepProgress(step);
                      final isCompleted = progress >= step.requiredCount;
                      final progressPercent = step.requiredCount > 0
                          ? (progress / step.requiredCount).clamp(0.0, 1.0)
                          : 0.0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCompleted ? Colors.green : Colors.white10,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? Colors.green
                                    : journey.color.withValues(alpha: 0.3),
                              ),
                              child: Center(
                                child: isCompleted
                                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                                    : Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: journey.color,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    step.title,
                                    style: TextStyle(
                                      color: isCompleted ? Colors.green : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    step.description,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(2),
                                          child: LinearProgressIndicator(
                                            value: progressPercent,
                                            backgroundColor: Colors.white10,
                                            valueColor: AlwaysStoppedAnimation(
                                              isCompleted ? Colors.green : journey.color,
                                            ),
                                            minHeight: 4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$progress/${step.requiredCount}',
                                        style: TextStyle(
                                          color: isCompleted ? Colors.green : Colors.white54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.starYellow.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '+${step.xpReward} XP',
                                style: const TextStyle(
                                  color: AppColors.starYellow,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
