import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/navigation/app_deep_link.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../../guided_rituals/data/models/guided_rituals_data.dart';
import '../../../guided_rituals/presentation/pages/guided_ritual_page.dart';
import '../../../lunar/presentation/providers/lunar_provider.dart';
import '../../../wheel_of_year/presentation/providers/wheel_of_year_provider.dart';

/// Ritual do momento: se hoje é sabbat ou lua cheia/nova, convida direto ao
/// ritual guiado ("É hoje!"); senão mostra a contagem regressiva para o
/// próximo evento mágico. Águas mágicas ficam nas páginas Lua/Sol.
class RitualOfMomentCard extends StatelessWidget {
  const RitualOfMomentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wheel = context.watch<WheelOfYearProvider>();
    final lunar = context.watch<LunarProvider>();

    // Evento de HOJE?
    String? todayEvent;
    String? todayRitualId;
    if (wheel.isTodaySabbat()) {
      final sabbat = wheel.getTodaySabbat()!;
      todayEvent = '${sabbat.emoji} ${sabbat.name}';
      todayRitualId = AllGuidedRituals.forSabbat(sabbat.type).id;
    } else {
      final phase = lunar.getCurrentMoonPhase();
      if (phase == MoonPhase.fullMoon || phase == MoonPhase.newMoon) {
        todayEvent = '${phase.emoji} ${phase.displayName}';
        todayRitualId =
            phase == MoonPhase.fullMoon ? 'full_moon' : 'new_moon';
      }
    }

    if (todayEvent != null && todayRitualId != null) {
      final ritualId = todayRitualId;
      return MagicalCard(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GuidedRitualPage(ritualId: ritualId),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.yourDayRitualTodayTitle(todayEvent),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: context.gc.lilac,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.auto_awesome, color: context.gc.starYellow),
                const SizedBox(width: 8),
                Text(
                  l10n.yourDayRitualCta,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.gc.starYellow,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Próximo evento mágico (sabbat, lua cheia ou lua nova — o mais perto).
    final now = DateTime.now();
    final candidates = <({String label, DateTime date, AppDeepLink link})>[];
    final nextSabbat = wheel.getNextSabbat();
    if (nextSabbat != null) {
      candidates.add((
        label: '${nextSabbat.emoji} ${nextSabbat.name}',
        date: nextSabbat.date,
        link: AppDeepLink.sabbatsEncyclopedia,
      ));
    }
    final nextFull = lunar.getNextFullMoon();
    if (nextFull != null) {
      candidates.add((
        label: '${MoonPhase.fullMoon.emoji} ${MoonPhase.fullMoon.displayName}',
        date: nextFull,
        link: AppDeepLink.moonEncyclopedia,
      ));
    }
    final nextNew = lunar.getNextNewMoon();
    if (nextNew != null) {
      candidates.add((
        label: '${MoonPhase.newMoon.emoji} ${MoonPhase.newMoon.displayName}',
        date: nextNew,
        link: AppDeepLink.moonEncyclopedia,
      ));
    }
    if (candidates.isEmpty) return const SizedBox.shrink();

    candidates.sort((a, b) => a.date.compareTo(b.date));
    final next = candidates.first;
    // Dias de CALENDÁRIO (véspera = 1), nunca horas ÷ 24 — o evento de hoje
    // já foi tratado acima, então aqui é sempre pelo menos 1.
    final today = DateTime(now.year, now.month, now.day);
    final targetDay =
        DateTime(next.date.year, next.date.month, next.date.day);
    final days = targetDay.difference(today).inDays.clamp(1, 9999);

    return MagicalCard(
      onTap: () => DeepLinkService.instance.dispatch(next.link),
      child: Row(
        children: [
          Icon(Icons.hourglass_bottom, color: context.gc.lilac),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.yourDayRitualCountdown(days, next.label),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Icon(Icons.chevron_right, color: context.gc.textSecondary),
        ],
      ),
    );
  }
}
