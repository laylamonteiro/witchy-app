import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../../lunar/presentation/providers/lunar_provider.dart';

/// Recomendações de feitiço pela fase lunar de hoje (migrado da página da
/// Lua para o "Seu Dia").
class SpellRecommendationsCard extends StatelessWidget {
  const SpellRecommendationsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final lunarProvider = context.watch<LunarProvider>();

    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: context.gc.starYellow,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).lunarRecommendations,
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
            ? context.gc.success.withValues(alpha: 0.1)
            : context.gc.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isGoodTime ? context.gc.success : context.gc.info,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isGoodTime ? Icons.check_circle : Icons.info,
            color: isGoodTime ? context.gc.success : context.gc.info,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spellType.displayName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color:
                            isGoodTime ? context.gc.success : context.gc.info,
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
