import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/lunar_provider.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/moon_phase_widget.dart';
import '../../../../core/widgets/breathing_moon.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class LunarCalendarPage extends StatefulWidget {
  final bool embedded;

  const LunarCalendarPage({super.key, this.embedded = false});

  @override
  State<LunarCalendarPage> createState() => _LunarCalendarPageState();
}

class _LunarCalendarPageState extends State<LunarCalendarPage> {
  final PageController _pageController = PageController(initialPage: 1);
  int _currentPage = 1; // 0 = Ontem, 1 = Hoje, 2 = Amanhã

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Consumer<LunarProvider>(
        builder: (context, lunarProvider, _) {
          try {
            final currentPhase = lunarProvider.getCurrentMoonPhase();
            final dateFormat = DateFormat('dd/MM/yyyy');

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Carrossel: Ontem - Hoje - Amanhã
                  SizedBox(
                    height: 300,
                    child: Column(
                      children: [
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            children: [
                              // Ontem
                              _buildDayCard(
                                context,
                                lunarProvider,
                                'Ontem',
                                -1,
                                dateFormat,
                              ),
                              // Hoje
                              _buildDayCard(
                                context,
                                lunarProvider,
                                'Hoje',
                                0,
                                dateFormat,
                              ),
                              // Amanhã
                              _buildDayCard(
                                context,
                                lunarProvider,
                                'Amanhã',
                                1,
                                dateFormat,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Indicador de página
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index
                                    ? AppColors.lilac
                                    : AppColors.surfaceBorder,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                  // Próximas fases importantes
                  MagicalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Próximas Fases Lunares',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Acompanhe as próximas mudanças da lua',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._buildAllNextPhases(context, lunarProvider),
                      ],
                    ),
                  ),

                  // Recomendações para feitiços
                  MagicalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              color: AppColors.starYellow,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Recomendações',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSpellRecommendation(
                          context,
                          lunarProvider,
                          SpellType.attraction,
                        ),
                        const SizedBox(height: 12),
                        _buildSpellRecommendation(
                          context,
                          lunarProvider,
                          SpellType.banishment,
                        ),
                      ],
                    ),
                  ),

                  // Significado das fases
                  MagicalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fases da Lua',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        ...MoonPhase.values.map((phase) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    phase.emoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          phase.displayName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                        Text(
                                          phase.description,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } catch (e) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.alert,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar calendário lunar',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário Lunar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: content,
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    LunarProvider provider,
    String dayLabel,
    int dayOffset,
    DateFormat dateFormat,
  ) {
    // Calcular a data baseada no offset (-1 = ontem, 0 = hoje, 1 = amanhã)
    final date = DateTime.now().add(Duration(days: dayOffset));

    // Criar um provider temporário para a data específica
    final tempProvider = LunarProvider()..setSelectedDate(date);
    final phase = tempProvider.getCurrentMoonPhase();

    return MagicalCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayLabel,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 2),
            Text(
              dateFormat.format(date),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            // Usar BreathingMoon para Lua Cheia, MoonPhaseWidget para outras fases
            Flexible(
              child: phase == MoonPhase.fullMoon
                  ? BreathingMoon(
                      moonEmoji: phase.emoji,
                      size: 90,
                      showStars: true,
                    )
                  : MoonPhaseWidget(
                      phase: phase,
                      showName: true,
                      showDescription: true,
                      size: 70,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAllNextPhases(
    BuildContext context,
    LunarProvider provider,
  ) {
    final allPhases = provider.getAllNextPhases();
    final widgets = <Widget>[];

    for (int i = 0; i < allPhases.length; i++) {
      final phaseData = allPhases[i];
      final phase = phaseData['phase'] as MoonPhase;
      final date = phaseData['date'] as DateTime;
      final daysUntil = phaseData['daysUntil'] as int;
      final hoursUntil = phaseData['hoursUntil'] as int;

      widgets.add(_buildEnhancedPhaseItem(
        context,
        phase.displayName,
        phase.emoji,
        date,
        daysUntil,
        hoursUntil,
      ));

      if (i < allPhases.length - 1) {
        widgets.add(const SizedBox(height: 16));
      }
    }

    return widgets;
  }

  Widget _buildEnhancedPhaseItem(
    BuildContext context,
    String phaseName,
    String emoji,
    DateTime date,
    int daysUntil,
    int hoursUntil,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    String timeText = '';
    if (daysUntil == 0) {
      if (hoursUntil == 0) {
        timeText = 'Agora!';
      } else if (hoursUntil == 1) {
        timeText = 'Em 1 hora';
      } else {
        timeText = 'Em $hoursUntil horas';
      }
    } else if (daysUntil == 1) {
      timeText = 'Amanhã às ${timeFormat.format(date)}';
    } else {
      timeText = 'Em $daysUntil dias às ${timeFormat.format(date)}';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lilac.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phaseName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(date),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.lilac,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpellRecommendation(
    BuildContext context,
    LunarProvider lunarProvider,
    SpellType spellType,
  ) {
    final isGoodTime = lunarProvider.isGoodTimeForSpell(spellType);
    final recommendation = lunarProvider.getSpellRecommendation(spellType);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isGoodTime
            ? AppColors.success.withOpacity(0.1)
            : AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isGoodTime ? AppColors.success : AppColors.info,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isGoodTime ? Icons.check_circle : Icons.info,
            color: isGoodTime ? AppColors.success : AppColors.info,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spellType.displayName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isGoodTime ? AppColors.success : AppColors.info,
                      ),
                ),
                Text(
                  recommendation,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
