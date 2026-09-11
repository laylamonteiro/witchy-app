import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../domain/lunar_comparison.dart';
import '../../domain/menstrual_insights.dart';

/// "Você e a Lua": qual era a Lua estimada nas datas que ela marcou.
///
/// O valor aparece desde o primeiro começo — a lista das datas com a fase
/// estimada — e o resumo só entra com três intervalos completos, o que exige
/// quatro começos. O quarto fecha o terceiro intervalo, continua visível e
/// não vira uma quarta observação num denominador de três.
///
/// Nada aqui vira porcentagem de sincronia, pontuação, ranking ou previsão de
/// que voltará a acontecer, e nenhuma frase diz que a Lua comanda o ciclo de
/// alguém. Datas próximas autorizam uma comparação e uma leitura poética.
class MenstrualLunarCard extends StatelessWidget {
  const MenstrualLunarCard({super.key, required this.insights});

  final MenstrualInsights insights;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.gc;
    final summary = LunarComparison.summarize(insights);
    final starts = insights.starts;
    final shown = starts.length <= LunarComparison.minimumStarts
        ? starts
        : starts.sublist(starts.length - LunarComparison.minimumStarts);

    final rows = <Widget>[
      for (final start in shown)
        _Observation(
          observation: LunarComparison.observe(start),
          closing: summary != null && start == summary.closing.day,
        ),
    ];

    final reduced = GrimoireMotion.reduced(context);
    return MagicalCard(
      key: const ValueKey('menstrual-lunar'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.menstrualLunarTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.lilac,
                    fontWeight: FontWeight.bold,
                  )),
          const SizedBox(height: 10),
          if (rows.isEmpty)
            Text(
              l10n.menstrualLunarEmpty,
              key: const ValueKey('menstrual-lunar-empty'),
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            )
          else if (reduced)
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows)
          else
            StaggeredEntrance(children: rows),
          const SizedBox(height: 10),
          if (summary == null)
            Text(
              l10n.menstrualLunarPending(starts.length),
              key: const ValueKey('menstrual-lunar-pending'),
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            )
          else ...[
            if (summary.nearFullMoon > 0)
              Text(
                l10n.menstrualLunarNearFull(summary.nearFullMoon,
                    summary.total, LunarComparison.windowDays),
                key: const ValueKey('menstrual-lunar-full'),
                style: TextStyle(color: colors.textPrimary, height: 1.4),
              ),
            if (summary.nearNewMoon > 0)
              Text(
                l10n.menstrualLunarNearNew(summary.nearNewMoon, summary.total,
                    LunarComparison.windowDays),
                key: const ValueKey('menstrual-lunar-new'),
                style: TextStyle(color: colors.textPrimary, height: 1.4),
              ),
            if (summary.nearFullMoon == 0 && summary.nearNewMoon == 0)
              Text(
                l10n.menstrualLunarNeither(
                    summary.total, LunarComparison.windowDays),
                key: const ValueKey('menstrual-lunar-neither'),
                style: TextStyle(color: colors.textPrimary, height: 1.4),
              ),
          ],
          const SizedBox(height: 10),
          Text(
            l10n.menstrualLunarNote(LunarComparison.windowDays),
            style: TextStyle(
                color: colors.textSecondary, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }
}

/// Uma data marcada por ela, a Lua estimada naquele dia e — quando é o caso —
/// a etiqueta de proximidade. A distinção vem por texto, não só por cor.
class _Observation extends StatelessWidget {
  const _Observation({required this.observation, required this.closing});

  final LunarObservation observation;
  final bool closing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.gc;
    final tag = switch (observation.nearness) {
      LunarNearness.newMoon => l10n.menstrualLunarTagNew,
      LunarNearness.fullMoon => l10n.menstrualLunarTagFull,
      LunarNearness.neither => null,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Text(observation.phase.emoji,
                style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_readable(observation.day)} · ${observation.phase.displayName}',
                  style: TextStyle(color: colors.textPrimary, fontSize: 13),
                ),
                if (tag != null)
                  Text(tag,
                      style: TextStyle(color: colors.lilac, fontSize: 11)),
                if (closing)
                  Text(l10n.menstrualLunarClosing,
                      key: const ValueKey('menstrual-lunar-closing'),
                      style:
                          TextStyle(color: colors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _readable(DateTime day) =>
      '${day.day.toString().padLeft(2, '0')}/'
      '${day.month.toString().padLeft(2, '0')}/${day.year}';
}
