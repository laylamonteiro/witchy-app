import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/models/magical_moment_data.dart';

/// Card "Momento Mágico": mostra o dia da semana (planeta regente + para que
/// ele é bom) e o período atual do dia, guiando a Bruxa sobre o que fazer
/// agora. Tap abre a tabela completa de dias × períodos. 100% gratuito.
class MagicalMomentCard extends StatelessWidget {
  const MagicalMomentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final moment = MagicalMoment.of(now);
    final locale = Localizations.localeOf(context).toString();
    final weekdayName = DateFormat.EEEE(locale).format(now);

    return MagicalCard(
      onTap: () => _showFullGuide(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(moment.day.planetEmoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.magicalMomentTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Icon(Icons.chevron_right, color: context.gc.textSecondary),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.magicalMomentTodayIs(weekdayName, moment.day.theme),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.gc.lilac,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: moment.day.goodFor
                .map((item) => Chip(
                      label: Text(item,
                          style: Theme.of(context).textTheme.bodySmall),
                      backgroundColor: context.gc.lilac.withValues(alpha: 0.15),
                      side: BorderSide(
                          color: context.gc.lilac.withValues(alpha: 0.4)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.gc.starYellow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: context.gc.starYellow.withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(moment.period.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${moment.period.title}: ${moment.period.goodFor}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            moment.day.suggestion,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.gc.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }

  void _showFullGuide(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();

    showModalBottomSheet(
      context: context,
      backgroundColor: context.gc.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.gc.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.magicalMomentGuideTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.magicalMomentWeekdaysTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: context.gc.lilac,
                    ),
              ),
              const SizedBox(height: 8),
              ...List.generate(7, (i) {
                final weekday = i + 1;
                final day = WeekdayCorrespondence(weekday);
                // Um DateTime qualquer com esse weekday para formatar o nome.
                final reference = DateTime(2026, 1, 5 + i); // 05/01/2026 = seg
                final name = DateFormat.EEEE(locale).format(reference);
                final isToday = DateTime.now().weekday == weekday;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isToday
                        ? context.gc.lilac.withValues(alpha: 0.15)
                        : context.gc.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isToday
                          ? context.gc.lilac
                          : context.gc.surfaceBorder,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(day.planetEmoji,
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$name — ${day.planetName}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: isToday ? context.gc.lilac : null,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              day.goodFor.join(' • '),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              Text(
                l10n.magicalMomentPeriodsTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: context.gc.starYellow,
                    ),
              ),
              const SizedBox(height: 8),
              ...MagicDayPeriod.values.map((period) {
                final isNow =
                    MagicDayPeriod.fromHour(DateTime.now().hour) == period;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isNow
                        ? context.gc.starYellow.withValues(alpha: 0.12)
                        : context.gc.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isNow
                          ? context.gc.starYellow
                          : context.gc.surfaceBorder,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(period.emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              period.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              period.goodFor,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
