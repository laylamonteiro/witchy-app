import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/lunar_provider.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/moon_phase_widget.dart';
import '../../../../core/widgets/breathing_moon.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../grimoire/data/models/spell_model.dart';

class LunarCalendarPage extends StatefulWidget {
  const LunarCalendarPage({super.key});

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário Lunar'),
      ),
      body: Consumer<LunarProvider>(
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
                          'Próximas Fases',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        _buildNextPhaseItem(
                          context,
                          lunarProvider,
                          'Lua Cheia',
                          MoonPhase.fullMoon.emoji,
                          isFullMoon: true,
                        ),
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

  Widget _buildNextPhaseItem(
    BuildContext context,
    LunarProvider provider,
    String phaseName,
    String emoji, {
    required bool isFullMoon,
  }) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final date = isFullMoon
        ? provider.getNextFullMoon()
        : provider.getNextNewMoon();
    final daysUntil = isFullMoon
        ? provider.getDaysUntilFullMoon()
        : provider.getDaysUntilNewMoon();

    String daysText = '';
    if (daysUntil != null) {
      if (daysUntil == 0) {
        daysText = 'Hoje!';
      } else if (daysUntil == 1) {
        daysText = 'Amanhã';
      } else {
        daysText = 'Em $daysUntil dias';
      }
    }

    return Row(
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
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (date != null) ...[
                Text(
                  dateFormat.format(date),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                if (daysText.isNotEmpty)
                  Text(
                    daysText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.lilac,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
              ] else
                Text(
                  'Calculando...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
            ],
          ),
        ),
      ],
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
