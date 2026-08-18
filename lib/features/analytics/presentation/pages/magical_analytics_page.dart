import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/accents.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/database/database_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../../grimoire/presentation/pages/user_spells_list_page.dart';
import '../../../journeys/presentation/pages/journeys_page.dart';
import '../../../learning/presentation/providers/learning_provider.dart';
import '../../../your_day/data/daily_checkin_repository.dart';
import '../../../your_day/presentation/providers/daily_checkin_provider.dart';
import '../../../diary/presentation/pages/dreams_list_page.dart';
import '../../../diary/presentation/pages/gratitudes_list_page.dart';
import '../../../diary/presentation/pages/affirmations_list_page.dart';
import '../../../diary/presentation/pages/desires_list_page.dart';
import '../../../sigils/presentation/pages/sigil_step1_intention_page.dart';
import '../../../runes/presentation/pages/rune_reading_page.dart';
import '../../../divination/presentation/pages/oracle_cards_page.dart';
import '../../../divination/presentation/pages/pendulum_page.dart';

/// Página de Analytics Mágicos - Estatísticas de uso do app
class MagicalAnalyticsPage extends StatefulWidget {
  /// Sem Scaffold/AppBar próprios: para viver como aba da Evolução Mágica
  /// (página que une Jornadas e Estatísticas). No modo embutido o atalho
  /// para as Jornadas some — elas são a aba vizinha.
  final bool embedded;

  const MagicalAnalyticsPage({super.key, this.embedded = false});

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

  /// Tabelas que contam como "prática" — a MESMA lista alimenta o total do
  /// herói, os períodos (hoje/semana/mês) e o calendário de dias, para os
  /// números baterem entre si e com a soma dos cards do grid.
  static const List<String> _practiceTables = [
    'spells',
    'dreams',
    'gratitudes',
    'affirmations',
    'sigils',
    'rune_readings',
    'oracle_readings',
    'pendulum_consultations',
    'desires',
  ];

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    // O XP de práticas vem do banco: recalcula ao abrir/atualizar a tela.
    unawaited(context.read<LearningProvider>().refreshPracticeXp());
    // A sequência mostrada aqui precisa contar o dia de hoje: garante que a
    // visita está registrada antes de ler o streak.
    await context.read<DailyCheckinProvider>().ensureToday();

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser.id;
      final db = await DatabaseHelper.instance.database;

      // Contadores gerais
      final spellsCount = await _countRecords(db, 'spells', userId);
      final dreamsCount = await _countRecords(db, 'dreams', userId);
      final desiresCount = await _countRecords(db, 'desires', userId);
      final gratitudesCount = await _countRecords(db, 'gratitudes', userId);
      final affirmationsCount = await _countRecords(db, 'affirmations', userId);
      final sigilsCount = await _countRecords(db, 'sigils', userId);
      final runeReadingsCount =
          await _countRecords(db, 'rune_readings', userId);
      final oracleReadingsCount =
          await _countRecords(db, 'oracle_readings', userId);
      final pendulumCount =
          await _countRecords(db, 'pendulum_consultations', userId);

      // Períodos: TODAS as práticas em cada janela (hoje ⊆ semana ⊆ mês*),
      // não uma tabela diferente por período como era antes.
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final startOfWeekDay = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeek =
          DateTime(startOfWeekDay.year, startOfWeekDay.month, startOfWeekDay.day);
      final startOfMonth = DateTime(now.year, now.month, 1);
      final practicesToday = await _countAllSince(db, userId, startOfDay);
      final practicesThisWeek = await _countAllSince(db, userId, startOfWeek);
      final practicesThisMonth = await _countAllSince(db, userId, startOfMonth);

      // Dias do mês corrente com pelo menos uma prática (calendário).
      final practiceDays = await _practiceDaysThisMonth(db, userId);
      // Dias com check-in (app aberto): a MESMA fonte da sequência — sem
      // isso o calendário contradiz o streak quando a pessoa entra mas não
      // cria nenhum registro no dia.
      final visitDays = await _visitDaysThisMonth(db, userId);

      // Desejos por status
      final desiresPending = await _countDesiresByStatus(db, userId, 'open');
      final desiresManifested =
          await _countDesiresByStatus(db, userId, 'manifested');

      // Feitiços por tipo
      final spellsByType = await _getSpellsByType(db, userId);

      // Streaks: gratidão + prática diária (check-in do Seu Dia)
      final gratitudeStreak = await _calculateGratitudeStreak(db, userId);
      final checkinStreak =
          await DailyCheckinRepository().currentStreak(userId);

      if (!mounted) return;
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
          'practicesToday': practicesToday,
          'practicesThisWeek': practicesThisWeek,
          'practicesThisMonth': practicesThisMonth,
          'practiceDays': practiceDays,
          'visitDays': visitDays,
          // Desejos
          'desiresPending': desiresPending,
          'desiresManifested': desiresManifested,
          // Tipos de feitiço
          'spellsByType': spellsByType,
          // Streaks
          'gratitudeStreak': gratitudeStreak,
          'checkinStreak': checkinStreak,
          // Total de práticas = soma dos cards do grid (mesmo critério).
          'totalPractices': spellsCount +
              dreamsCount +
              gratitudesCount +
              affirmationsCount +
              sigilsCount +
              runeReadingsCount +
              oracleReadingsCount +
              pendulumCount +
              desiresCount,
        };
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint('Erro ao carregar estatísticas: $e');
    }
  }

  /// Soma as práticas de todas as tabelas criadas a partir de [since].
  Future<int> _countAllSince(
      dynamic db, String userId, DateTime since) async {
    var total = 0;
    for (final table in _practiceTables) {
      total += await _countSince(db, table, userId, since);
    }
    return total;
  }

  Future<int> _countSince(
      dynamic db, String table, String userId, DateTime since) async {
    try {
      // Para spells e affirmations, contar apenas os criados pelo usuário.
      final preloadedFilter = (table == 'spells' || table == 'affirmations')
          ? ' AND is_preloaded = 0'
          : '';
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $table '
        'WHERE user_id = ? AND created_at >= ?$preloadedFilter',
        [userId, since.millisecondsSinceEpoch],
      );
      return result.first['count'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Dias (1..31) do mês corrente com pelo menos uma prática registrada.
  Future<Set<int>> _practiceDaysThisMonth(dynamic db, String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final days = <int>{};
    for (final table in _practiceTables) {
      try {
        final preloadedFilter = (table == 'spells' || table == 'affirmations')
            ? ' AND is_preloaded = 0'
            : '';
        final result = await db.rawQuery(
          "SELECT DISTINCT date(created_at / 1000, 'unixepoch', 'localtime') "
          'as day FROM $table '
          'WHERE user_id = ? AND created_at >= ?$preloadedFilter',
          [userId, startOfMonth.millisecondsSinceEpoch],
        );
        for (final row in result) {
          final dayStr = row['day'] as String?;
          if (dayStr == null) continue;
          final parsed = DateTime.tryParse(dayStr);
          if (parsed != null && parsed.month == now.month) {
            days.add(parsed.day);
          }
        }
      } catch (e) {
        // Tabela indisponível: segue com as demais.
      }
    }
    return days;
  }

  /// Dias (1..31) do mês corrente com check-in registrado (a data é a
  /// chave local YYYY-MM-DD da tabela `daily_checkins`).
  Future<Set<int>> _visitDaysThisMonth(dynamic db, String userId) async {
    final now = DateTime.now();
    final prefix = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-';
    final days = <int>{};
    try {
      final result = await db.rawQuery(
        'SELECT date FROM daily_checkins WHERE user_id = ? AND date LIKE ?',
        [userId, '$prefix%'],
      );
      for (final row in result) {
        final date = row['date'] as String?;
        if (date == null || date.length <= prefix.length) continue;
        final day = int.tryParse(date.substring(prefix.length));
        if (day != null) days.add(day);
      }
    } catch (_) {
      // Tabela indisponível numa base antiga: calendário segue só com as
      // práticas.
    }
    return days;
  }

  Future<void> _openAndReload(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (mounted) await _loadStats();
  }

  Future<int> _countRecords(dynamic db, String table, String userId) async {
    try {
      // Para spells e affirmations, contar apenas os criados pelo usuário (is_preloaded = 0)
      String query;
      if (table == 'spells' || table == 'affirmations') {
        query =
            'SELECT COUNT(*) as count FROM $table WHERE user_id = ? AND is_preloaded = 0';
      } else {
        query = 'SELECT COUNT(*) as count FROM $table WHERE user_id = ?';
      }

      final result = await db.rawQuery(query, [userId]);
      return result.first['count'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _countDesiresByStatus(
      dynamic db, String userId, String status) async {
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
      // Contar apenas feitiços criados pelo usuário (is_preloaded = 0)
      final result = await db.rawQuery(
        'SELECT type, COUNT(*) as count FROM spells WHERE user_id = ? AND is_preloaded = 0 GROUP BY type',
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
        '''SELECT DISTINCT date(created_at / 1000, 'unixepoch', 'localtime') as day
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
    final body = _isLoading
        ? Center(child: CircularProgressIndicator(color: context.gc.lilac))
        : RefreshIndicator(
            onRefresh: _loadStats,
            color: context.gc.lilac,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumo geral
                  _buildSummaryCard(),
                  const SizedBox(height: 20),

                  // Régua única de progresso: nível/XP unificado do
                  // Grimório Vivo. O atalho para as Jornadas só aparece
                  // fora do modo embutido — lá, elas são a aba vizinha.
                  _buildLearningCard(),
                  if (!widget.embedded) ...[
                    const SizedBox(height: 12),
                    _buildJourneysCard(),
                  ],
                  const SizedBox(height: 20),

                  // Streaks e conquistas
                  _buildStreaksCard(),
                  const SizedBox(height: 20),

                  // Calendário de dias com prática no mês
                  _buildPracticeDaysCard(),
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
          );

    if (widget.embedded) return body;

    return Scaffold(
      backgroundColor: context.gc.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ResponsiveAppBarTitle(
          AppLocalizations.of(context).profileMagicalStats,
          style: TextStyle(
            color: context.gc.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.gc.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: context.gc.textSecondary),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildSummaryCard() {
    final totalPractices = _stats['totalPractices'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.gc.lilac.withValues(alpha: 0.3),
            context.gc.pink.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.gc.lilac.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome,
            size: 48,
            color: context.gc.starYellow,
          ),
          const SizedBox(height: 12),
          Text(
            '$totalPractices',
            style: TextStyle(
              color: context.gc.textPrimary,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            AppLocalizations.of(context).analyticsPractices,
            style: TextStyle(
              color: context.gc.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniStat(AppLocalizations.of(context).analyticsToday,
                  '${_stats['practicesToday'] ?? 0}', Icons.today),
              _buildMiniStat(AppLocalizations.of(context).analyticsThisWeek,
                  '${_stats['practicesThisWeek'] ?? 0}', Icons.date_range),
              _buildMiniStat(AppLocalizations.of(context).analyticsThisMonth,
                  '${_stats['practicesThisMonth'] ?? 0}', Icons.calendar_month),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: context.gc.textSecondary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: context.gc.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: context.gc.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  /// Nível mágico unificado: XP total (estudo + práticas), barra até o
  /// próximo nível e o resumo do Grimório Vivo.
  Widget _buildLearningCard() {
    final l10n = AppLocalizations.of(context);
    final learning = context.watch<LearningProvider>();
    final level = learning.level;
    final next = learning.nextLevel;

    return Container(
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
              Icon(Icons.menu_book, color: context.gc.lilac, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.toolLivingGrimoireTitle,
                  style: TextStyle(
                    color: context.gc.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${level.emoji} ${level.title}',
                style: TextStyle(
                  color: context.gc.lilac,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${learning.xp} XP',
                style: TextStyle(
                  color: context.gc.starYellow,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                next != null
                    ? l10n.analyticsNextLevel(next.title)
                    : l10n.analyticsMaxLevel,
                style: TextStyle(
                  color:
                      next != null ? context.gc.textSecondary : context.gc.mint,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: learning.levelProgress,
              minHeight: 6,
              backgroundColor: context.gc.surfaceBorder,
              valueColor: AlwaysStoppedAnimation(context.gc.lilac),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.analyticsXpBreakdown(learning.lessonXp, learning.practiceXp),
            style: TextStyle(
              color: context.gc.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${l10n.analyticsPagesWritten(learning.totalPagesWritten)} · '
            '${l10n.analyticsTrailsBound(learning.boundTrails)}',
            style: TextStyle(
              color: context.gc.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Atalho para as Jornadas Mágicas — as conquistas moram junto das
  /// outras réguas de progresso.
  Widget _buildJourneysCard() {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const JourneysPage()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.gc.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.gc.textPrimary10),
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_events, color: context.gc.starYellow, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.profileMagicalJourneys,
                    style: TextStyle(
                      color: context.gc.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.analyticsJourneysSub,
                    style: TextStyle(
                      color: context.gc.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.gc.lilac),
          ],
        ),
      ),
    );
  }

  Widget _buildStreaksCard() {
    final gratitudeStreak = _stats['gratitudeStreak'] ?? 0;
    final checkinStreak = _stats['checkinStreak'] ?? 0;

    return Container(
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
              const Icon(Icons.local_fire_department,
                  color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).analyticsSequences,
                style: TextStyle(
                  color: context.gc.textPrimary,
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
                  AppLocalizations.of(context).analyticsDailyPractice,
                  checkinStreak,
                  context.gc.lilac,
                  Icons.auto_awesome,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStreakItem(
                  AppLocalizations.of(context).diaryTabGratitude,
                  gratitudeStreak,
                  Colors.orange,
                  Icons.favorite,
                ),
              ),
            ],
          ),
          // Troféu só quando é conquista de verdade (7+ dias) — antes ele
          // repetia a informação do card com "1 dia".
          if (gratitudeStreak >= 7) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events,
                      color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      gratitudeStreak >= 30
                          ? AppLocalizations.of(context).analyticsStreak30
                          : AppLocalizations.of(context).analyticsStreak7,
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

  /// Mini-calendário do mês: o dia acende quando o app foi aberto (check-in
  /// — a MESMA fonte da sequência) ou quando há prática criada. Um critério
  /// só: entrou no app, o dia conta — o calendário nunca contradiz o streak.
  Widget _buildPracticeDaysCard() {
    final practiceDays = _stats['practiceDays'] as Set<int>? ?? const <int>{};
    final visitDays = _stats['visitDays'] as Set<int>? ?? const <int>{};
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final locale = Localizations.localeOf(context).toString();
    var monthName = DateFormat.MMMM(locale).format(now);
    monthName = monthName[0].toUpperCase() + monthName.substring(1);

    return Container(
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
              Icon(Icons.calendar_month, color: context.gc.mint, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).analyticsPracticeDays(monthName),
                  style: TextStyle(
                    color: context.gc.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: List.generate(daysInMonth, (i) {
              final day = i + 1;
              final lit =
                  visitDays.contains(day) || practiceDays.contains(day);
              final isToday = day == now.day;
              final isFuture = day > now.day;
              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: lit
                      ? context.gc.lilac.withValues(alpha: 0.35)
                      : context.gc.textPrimary10.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: isToday
                      ? Border.all(color: context.gc.starYellow, width: 1.5)
                      : lit
                          ? Border.all(
                              color: context.gc.lilac.withValues(alpha: 0.6))
                          : null,
                ),
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        lit || isToday ? FontWeight.bold : FontWeight.normal,
                    color: lit
                        ? context.gc.textPrimary
                        : context.gc.textSecondary.withValues(
                            alpha: isFuture ? 0.35 : 0.7),
                  ),
                ),
              );
            }),
          ),
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
                AppLocalizations.of(context).analyticsStreakDays(count),
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: context.gc.textSecondary,
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
        Text(
          AppLocalizations.of(context).analyticsYourPractices,
          style: TextStyle(
            color: context.gc.textPrimary,
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
            _buildCategoryCard(
              AppLocalizations.of(context).profileSpells,
              _stats['spells'] ?? 0,
              Icons.auto_fix_high,
              Colors.purple,
              onTap: () => _openAndReload(
                UserSpellsListPage(title: AppLocalizations.of(context).grimoireTabMyGrimoire),
              ),
            ),
            _buildCategoryCard(
              AppLocalizations.of(context).diaryTabDreams,
              _stats['dreams'] ?? 0,
              Icons.nights_stay,
              Colors.indigo,
              onTap: () => _openAndReload(const DreamsListPage()),
            ),
            _buildCategoryCard(
              AppLocalizations.of(context).diaryTabGratitude,
              _stats['gratitudes'] ?? 0,
              Icons.favorite,
              Colors.pink,
              onTap: () => _openAndReload(const GratitudesListPage()),
            ),
            _buildCategoryCard(
              AppLocalizations.of(context).diaryTabAffirmations,
              _stats['affirmations'] ?? 0,
              Icons.format_quote,
              Colors.teal,
              onTap: () => _openAndReload(const AffirmationsListPage()),
            ),
            _buildCategoryCard(
              AppLocalizations.of(context).toolSigilsTitle,
              _stats['sigils'] ?? 0,
              Icons.gesture,
              Colors.amber,
              onTap: () => _openAndReload(const SigilStep1IntentionPage()),
            ),
            _buildCategoryCard(
              AppLocalizations.of(context).encyTabRunes,
              _stats['runeReadings'] ?? 0,
              Icons.casino,
              Colors.red,
              onTap: () => _openAndReload(const RuneReadingPage()),
            ),
            _buildCategoryCard(
              AppLocalizations.of(context).analyticsOracle,
              _stats['oracleReadings'] ?? 0,
              Icons.style,
              Colors.cyan,
              onTap: () => _openAndReload(const OracleCardsPage()),
            ),
            _buildCategoryCard(
              AppLocalizations.of(context).pendulumTitle,
              _stats['pendulum'] ?? 0,
              Icons.radio_button_checked,
              Colors.green,
              onTap: () => _openAndReload(const PendulumPage()),
            ),
            _buildCategoryCard(
              AppLocalizations.of(context).diaryTabDesires,
              _stats['desires'] ?? 0,
              Icons.star,
              Colors.orange,
              onTap: () => _openAndReload(const DesiresListPage()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String label, int count, IconData icon, Color color,
      {VoidCallback? onTap}) {
    // Práticas ainda não iniciadas ficam discretas: os zeros não competem
    // em peso visual com o que a pessoa realmente pratica.
    final dimmed = count == 0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: dimmed ? 0.45 : 1,
        child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.gc.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: dimmed ? 0.15 : 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                color: context.gc.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: context.gc.textSecondary,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        ),
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
        color: context.gc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.gc.textPrimary10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).analyticsManifestations,
                style: TextStyle(
                  color: context.gc.textPrimary,
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
                child: _buildDesiresStat(
                    AppLocalizations.of(context).analyticsPending,
                    pending,
                    Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDesiresStat(
                    AppLocalizations.of(context).analyticsManifested,
                    manifested,
                    Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (manifested > 0) ...[
            // Barra + taxa só quando já existe manifestação: 0% com barra
            // vazia parecia derrota (e bug) para quem está começando.
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: manifested / total,
                backgroundColor: Colors.orange.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation(Colors.green),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).analyticsManifestRate(
                  ((manifested / total) * 100).round()),
              style: TextStyle(
                color: context.gc.textSecondary,
                fontSize: 12,
              ),
            ),
          ] else
            Text(
              pending > 0
                  ? AppLocalizations.of(context).analyticsAwaitingDesires(pending)
                  : AppLocalizations.of(context).analyticsStartDesires,
              style: TextStyle(
                color: context.gc.textSecondary,
                fontSize: 12,
              ),
            ),
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
            style: TextStyle(
              color: context.gc.textSecondary,
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
        color: context.gc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.gc.textPrimary10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_fix_high, color: Colors.purple, size: 24),
              SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).analyticsSpellsByType,
                style: TextStyle(
                  color: context.gc.textPrimary,
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
                        _typeLabel(entry.key),
                        style: TextStyle(color: context.gc.textSecondary),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: spellsByType.values.isNotEmpty
                              ? entry.value /
                                  spellsByType.values
                                      .reduce((a, b) => a > b ? a : b)
                              : 0,
                          backgroundColor: context.gc.textPrimary10,
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
                      style: TextStyle(
                        color: context.gc.textPrimary,
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

  /// Rótulo localizado do tipo: a coluna `type` persiste o enum.name
  /// ('attraction'/'banishment') — exibir o cru vazava inglês na interface.
  String _typeLabel(String type) {
    for (final t in SpellType.values) {
      if (t.name == type) return t.displayName;
    }
    return type;
  }

  Color _getTypeColor(String type) {
    // Tipos atuais: as mesmas cores dos chips na página do feitiço
    // (atração = menta, banimento = rosa).
    switch (type) {
      case 'attraction':
        return context.gc.mint;
      case 'banishment':
        return context.gc.pink;
    }
    // Valores legados persistidos em PT; compara sem acentos.
    switch (removeAccents(type.toLowerCase())) {
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
