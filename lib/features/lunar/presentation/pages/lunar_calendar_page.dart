import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/lunar_provider.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/moon_phase_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../grimoire/data/models/spell_model.dart';

class LunarCalendarPage extends StatelessWidget {
  const LunarCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário Lunar'),
      ),
      body: Consumer<LunarProvider>(
        builder: (context, lunarProvider, _) {
          final currentPhase = lunarProvider.getCurrentMoonPhase();
          final dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fase atual da lua
                MagicalCard(
                  child: Column(
                    children: [
                      Text(
                        'Hoje',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dateFormat.format(lunarProvider.selectedDate),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 24),
                      MoonPhaseWidget(
                        phase: currentPhase,
                        showName: true,
                        showDescription: true,
                        size: 80,
                      ),
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
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildNextPhaseItem(
                        context,
                        'Lua Cheia',
                        lunarProvider.getNextFullMoon(),
                        MoonPhase.fullMoon.emoji,
                      ),
                      const Divider(height: 24),
                      _buildNextPhaseItem(
                        context,
                        'Lua Nova',
                        lunarProvider.getNextNewMoon(),
                        MoonPhase.newMoon.emoji,
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
                            style: Theme.of(context).textTheme.titleLarge,
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
                        style: Theme.of(context).textTheme.titleLarge,
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
        },
      ),
    );
  }

  Widget _buildNextPhaseItem(
    BuildContext context,
    String phaseName,
    DateTime? date,
    String emoji,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');

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
              Text(
                date != null ? dateFormat.format(date) : 'Calculando...',
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
