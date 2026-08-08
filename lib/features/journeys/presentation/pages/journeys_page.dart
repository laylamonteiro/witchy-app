import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/database/database_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../learning/presentation/providers/learning_provider.dart';
import '../../data/models/journey_model.dart';

/// Página de Jornadas Mágicas Gamificadas.
///
/// Sem abas: as antigas ("Todas", "Iniciante", "Diário", "Divinação")
/// misturavam três eixos — filtro, nível de experiência e tema. A tela
/// agora é uma lista única organizada por PROGRESSO (em andamento → para
/// começar → concluídas), com o tema como etiqueta no card e a escada de
/// níveis num sheet aberto pelo cabeçalho de XP.
class JourneysPage extends StatefulWidget {
  /// Sem Scaffold/AppBar próprios: para viver como aba da Evolução Mágica
  /// (página que une Jornadas e Estatísticas).
  final bool embedded;

  const JourneysPage({super.key, this.embedded = false});

  @override
  State<JourneysPage> createState() => _JourneysPageState();
}

class _JourneysPageState extends State<JourneysPage> {
  bool _isLoading = true;
  Map<String, int> _userStats = {};

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final odUserId = authProvider.currentUser.id;
      final db = await DatabaseHelper.instance.database;

      // Carregar contagens de cada entidade
      _userStats = {
        // Para feitiços, excluir os pré-carregados (is_preloaded = 1)
        'spells': await _countUserSpells(db, odUserId),
        'dreams': await _countRecords(db, 'dreams', odUserId),
        'desires': await _countRecords(db, 'desires', odUserId),
        'gratitudes': await _countRecords(db, 'gratitudes', odUserId),
        'affirmations': await _countRecords(db, 'affirmations', odUserId),
        'sigils': await _countRecords(db, 'sigils', odUserId),
        'rune_readings': await _countRecords(db, 'rune_readings', odUserId),
        'oracle_readings': await _countRecords(db, 'oracle_readings', odUserId),
        'pendulum_consultations':
            await _countRecords(db, 'pendulum_consultations', odUserId),
        'birth_charts': await _countRecords(db, 'birth_charts', odUserId),
        'desires_manifested':
            await _countDesiresByStatus(db, odUserId, 'manifested'),
        'gratitude_streak': await _calculateStreak(db, 'gratitudes', odUserId),
        'guided_rituals':
            await _countRecords(db, 'guided_ritual_logs', odUserId),
      };

      // Calcular all_readings
      _userStats['all_readings'] = (_userStats['rune_readings'] ?? 0) +
          (_userStats['oracle_readings'] ?? 0) +
          (_userStats['pendulum_consultations'] ?? 0);

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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

  /// Conta apenas feitiços criados pelo usuário (excluindo os pré-carregados)
  Future<int> _countUserSpells(dynamic db, String odUserId) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM spells WHERE user_id = ? AND is_preloaded = 0',
        [odUserId],
      );
      return result.first['count'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _countDesiresByStatus(
      dynamic db, String odUserId, String status) async {
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

  Future<int> _calculateStreak(
      dynamic db, String table, String odUserId) async {
    try {
      final result = await db.rawQuery(
        '''SELECT DISTINCT date(created_at / 1000, 'unixepoch', 'localtime') as day
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
    final body = _isLoading
        ? Center(child: CircularProgressIndicator(color: context.gc.lilac))
        : Column(
            children: [
              // XP Header
              _buildXpHeader(),

              // Jornadas por progresso
              Expanded(child: _buildProgressList()),
            ],
          );

    if (widget.embedded) return body;

    return Scaffold(
      backgroundColor: context.gc.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ResponsiveAppBarTitle(
          AppLocalizations.of(context).profileMagicalJourneys,
          style: TextStyle(
            color: context.gc.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.gc.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: body,
    );
  }

  /// Progresso calculado de uma jornada (mesma lógica do card).
  ({int completed, double fraction}) _journeyProgress(JourneyModel journey) {
    var completed = 0;
    for (final step in journey.steps) {
      if (_getStepProgress(step) >= step.requiredCount) completed++;
    }
    final fraction =
        journey.totalSteps > 0 ? completed / journey.totalSteps : 0.0;
    return (completed: completed, fraction: fraction);
  }

  /// Lista única por progresso: "o que falta pouco" vem primeiro.
  Widget _buildProgressList() {
    final l10n = AppLocalizations.of(context);

    final inProgress = <JourneyModel>[];
    final toStart = <JourneyModel>[];
    final done = <JourneyModel>[];
    for (final journey in AvailableJourneys.all) {
      final p = _journeyProgress(journey);
      if (p.completed == 0) {
        toStart.add(journey);
      } else if (p.completed >= journey.totalSteps) {
        done.add(journey);
      } else {
        inProgress.add(journey);
      }
    }
    // Em andamento: a mais próxima de concluir primeiro.
    inProgress.sort((a, b) => _journeyProgress(b)
        .fraction
        .compareTo(_journeyProgress(a).fraction));

    return RefreshIndicator(
      onRefresh: _loadUserStats,
      color: context.gc.lilac,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (inProgress.isNotEmpty) ...[
            _sectionLabel(l10n.journeysSectionInProgress,
                hint: l10n.journeysSectionInProgressHint),
            for (final (i, journey) in inProgress.indexed)
              _buildJourneyCard(journey, highlight: i == 0),
          ],
          if (toStart.isNotEmpty) ...[
            _sectionLabel(l10n.journeysSectionToStart),
            ...toStart.map(_buildJourneyCard),
          ],
          if (done.isNotEmpty) ...[
            _sectionLabel(l10n.journeysSectionDone,
                hint: '${done.length}'),
            for (final journey in done)
              Opacity(opacity: 0.75, child: _buildJourneyCard(journey)),
          ],
          if (inProgress.isEmpty && toStart.isEmpty && done.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Center(
                child: Text(
                  l10n.journeysEmpty,
                  style: TextStyle(color: context.gc.textSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 10, 2, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '✦ ${label.toUpperCase()}',
            style: TextStyle(
              color: context.gc.starYellow,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '· $hint',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.gc.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Etiqueta de tema no card — o que antes eram abas.
  (String, String) _themeLabel(JourneyCategory category) {
    final l10n = AppLocalizations.of(context);
    return switch (category) {
      JourneyCategory.iniciante => ('🌱', l10n.journeysTabBeginner),
      JourneyCategory.diario ||
      JourneyCategory.grimorio =>
        ('📖', l10n.diaryTitle),
      JourneyCategory.divinacao ||
      JourneyCategory.astrologia =>
        ('🔮', l10n.divinationTitle),
      JourneyCategory.comunidade => ('✨', ''),
    };
  }

  Widget _buildThemeChip(JourneyCategory category) {
    final (emoji, label) = _themeLabel(category);
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: context.gc.textPrimary10),
      ),
      child: Text(
        '$emoji $label',
        style: TextStyle(
          color: context.gc.textSecondary,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Cabeçalho do nível — a MESMA escada do Grimório Vivo e das
  /// Estatísticas (LearningProvider), não uma contagem paralela: antes
  /// esta tela tinha níveis próprios ("Nivel 1 - Iniciante", 500 XP por
  /// nível) que diziam um número diferente do resto do app.
  Widget _buildXpHeader() {
    final l10n = AppLocalizations.of(context);
    final learning = context.watch<LearningProvider>();
    final level = learning.level;
    final next = learning.nextLevel;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.gc.lilac.withValues(alpha: 0.3),
            context.gc.pink.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.gc.lilac.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [context.gc.lilac, context.gc.pink],
              ),
            ),
            child: Center(
              child: Text(
                level.emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level.title,
                  style: TextStyle(
                    color: context.gc.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.journeysXpTotal(learning.xp),
                  style: TextStyle(
                    color: context.gc.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: learning.levelProgress,
                    backgroundColor: context.gc.textPrimary10,
                    valueColor:
                        AlwaysStoppedAnimation(context.gc.starYellow),
                    minHeight: 6,
                  ),
                ),
                if (next != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.journeysXpToNext(next.minXp - learning.xp, next.title),
                    style: TextStyle(
                      color: context.gc.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // A escada saiu do meio da lista: abre daqui, onde mora o número
          // que ela explica.
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _showLevelsSheet,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Text(
                '${l10n.journeysSeeLevels} ✦',
                style: TextStyle(
                  color: context.gc.starYellow,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLevelsSheet() {
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
          decoration: BoxDecoration(
            color: context.gc.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.gc.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [_buildLevelsSection()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A escada completa de títulos: sem isto, ninguém descobria que
  /// existem Praticante, Adepta, Mestra e Guardiã depois de Iniciada.
  Widget _buildLevelsSection() {
    final l10n = AppLocalizations.of(context);
    final learning = context.watch<LearningProvider>();
    final current = learning.level;
    final levels = LearningProvider.levels;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.gc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.gc.textPrimary10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.military_tech, color: context.gc.starYellow, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.journeysLevelsTitle,
                  style: TextStyle(
                    color: context.gc.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.journeysLevelsIntro,
            style: TextStyle(
              color: context.gc.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          for (final level in levels) ...[
            _buildLevelRow(
              level: level,
              reached: learning.xp >= level.minXp,
              isCurrent: level.title == current.title,
            ),
            if (level != levels.last) const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
          Divider(color: context.gc.textPrimary10),
          const SizedBox(height: 10),
          Text(
            l10n.journeysHowXp,
            style: TextStyle(
              color: context.gc.lilac,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.journeysHowXpBody,
            style: TextStyle(
              color: context.gc.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelRow({
    required LearningLevel level,
    required bool reached,
    required bool isCurrent,
  }) {
    final l10n = AppLocalizations.of(context);
    return Opacity(
      // Níveis ainda não alcançados ficam discretos, mas visíveis: são o
      // caminho à frente, não um segredo.
      opacity: reached ? 1 : 0.5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isCurrent
              ? context.gc.lilac.withValues(alpha: 0.15)
              : Colors.transparent,
          border: isCurrent
              ? Border.all(color: context.gc.lilac.withValues(alpha: 0.6))
              : null,
        ),
        child: Row(
          children: [
            Text(level.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.title,
                    style: TextStyle(
                      color: context.gc.textPrimary,
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(height: 2),
                    Text(
                      l10n.journeysLevelCurrent,
                      style: TextStyle(
                        color: context.gc.lilac,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              l10n.journeysLevelLocked(level.minXp),
              style: TextStyle(
                color: reached ? context.gc.starYellow : context.gc.textSecondary,
                fontSize: 12,
                fontWeight: reached ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyCard(JourneyModel journey, {bool highlight = false}) {
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
    final progress =
        journey.totalSteps > 0 ? completedSteps / journey.totalSteps : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.gc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          // Destaque dourado para a jornada mais próxima de concluir:
          // é o "continue daqui" da tela.
          color: highlight
              ? context.gc.starYellow.withValues(alpha: 0.55)
              : isCompleted
                  ? journey.color.withValues(alpha: 0.7)
                  : context.gc.textPrimary10,
          width: isCompleted || highlight ? 2 : 1,
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
                              Flexible(
                                child: Text(
                                  journey.localizedTitle,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: context.gc.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                              const SizedBox(width: 8),
                              _buildThemeChip(journey.category),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            journey.localizedDescription,
                            style: TextStyle(
                              color: context.gc.textSecondary,
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
                              backgroundColor: context.gc.textPrimary10,
                              valueColor: AlwaysStoppedAnimation(journey.color),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$completedSteps de ${journey.totalSteps} etapas',
                            style: TextStyle(
                              color: context.gc.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.gc.starYellow.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star,
                              color: context.gc.starYellow, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '$earnedXp/${journey.xpReward} XP',
                            style: TextStyle(
                              color: context.gc.starYellow,
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
          decoration: BoxDecoration(
            color: context.gc.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.gc.textSecondary,
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
                          child: Icon(journey.icon,
                              color: journey.color, size: 40),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                journey.localizedTitle,
                                style: TextStyle(
                                  color: context.gc.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                journey.localizedDescription,
                                style: TextStyle(
                                  color: context.gc.textSecondary,
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
                    Text(
                      'Etapas da Jornada',
                      style: TextStyle(
                        color: context.gc.textPrimary,
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
                              : context.gc.textPrimary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCompleted ? Colors.green : context.gc.textPrimary10,
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
                                    ? Icon(Icons.check,
                                        color: context.gc.textPrimary, size: 18)
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
                                    step.localizedTitle,
                                    style: TextStyle(
                                      color: isCompleted
                                          ? Colors.green
                                          : context.gc.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    step.localizedDescription,
                                    style: TextStyle(
                                      color: context.gc.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          child: LinearProgressIndicator(
                                            value: progressPercent,
                                            backgroundColor: context.gc.textPrimary10,
                                            valueColor: AlwaysStoppedAnimation(
                                              isCompleted
                                                  ? Colors.green
                                                  : journey.color,
                                            ),
                                            minHeight: 4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$progress/${step.requiredCount}',
                                        style: TextStyle(
                                          color: isCompleted
                                              ? Colors.green
                                              : context.gc.textSecondary,
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    context.gc.starYellow.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '+${step.xpReward} XP',
                                style: TextStyle(
                                  color: context.gc.starYellow,
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
