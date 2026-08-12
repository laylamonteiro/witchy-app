import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/expansion_magical_card.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../../lunar/presentation/providers/lunar_provider.dart';

/// Próximas fases lunares (migrado da página da Lua para o "Seu Dia"): cada
/// item traz data, contagem e o significado básico da fase.
///
/// Recolhido por padrão: é consulta, não ação — expandido custava ~250px de
/// rolagem todo dia para quem já sabe o que vem por aí.
class NextMoonPhasesCard extends StatelessWidget {
  const NextMoonPhasesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lunarProvider = context.watch<LunarProvider>();

    return ExpansionMagicalCard(
      emoji: '🌙',
      title: l10n.lunarNextPhases,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.lunarNextPhasesSub,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.gc.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          ..._buildAllNextPhases(context, lunarProvider),
        ],
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
      final hoursUntil = phaseData['hoursUntil'] as int;

      widgets.add(_buildPhaseItem(
        context,
        phase,
        date,
        hoursUntil,
      ));

      if (i < allPhases.length - 1) {
        widgets.add(const SizedBox(height: 16));
      }
    }

    return widgets;
  }

  Widget _buildPhaseItem(
    BuildContext context,
    MoonPhase phase,
    DateTime date,
    int hoursUntil,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    final l10n = AppLocalizations.of(context);
    final time = timeFormat.format(date);

    // Dias de CALENDÁRIO, não de duração: 22 horas podem cair amanhã, e
    // 46 horas podem cair depois de amanhã. A hora exata aparece sempre —
    // a fase tem hora marcada, não só dia.
    final now = DateTime.now();
    final days = (DateTime(date.year, date.month, date.day)
                .difference(DateTime(now.year, now.month, now.day))
                .inHours /
            24)
        .round();

    final String timeText;
    if (hoursUntil < 1) {
      timeText = l10n.lunarNow;
    } else if (hoursUntil < 24) {
      timeText = l10n.lunarInHoursAt(hoursUntil, time);
    } else if (days == 1) {
      timeText = l10n.lunarTomorrowAt(time);
    } else {
      timeText = l10n.lunarInDaysAt(days, time);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.gc.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.gc.lilac.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            phase.emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phase.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${dateFormat.format(date)} · $timeText',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.lilac,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                // Significado básico da fase (absorvido do antigo card
                // "Fases da Lua" da página da Lua).
                Text(
                  phase.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
