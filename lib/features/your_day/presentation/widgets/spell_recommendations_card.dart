import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/expansion_magical_card.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../../lunar/presentation/providers/lunar_provider.dart';

/// Recomendações de feitiço pela fase lunar de hoje (migrado da página da
/// Lua para o "Seu Dia").
class SpellRecommendationsCard extends StatelessWidget {
  const SpellRecommendationsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final lunarProvider = context.watch<LunarProvider>();

    return ExpansionMagicalCard(
      emoji: '💡',
      title: AppLocalizations.of(context).lunarRecommendations,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
    // Paleta mística: dourado quando a lua favorece, lilás quando é hora de
    // esperar. Verde/azul de "sistema" quebravam a imersão.
    final accent = isGoodTime ? context.gc.starYellow : context.gc.lilac;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            isGoodTime ? Icons.auto_awesome : Icons.hourglass_bottom,
            color: accent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spellType.displayName,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: accent),
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
