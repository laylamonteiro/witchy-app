import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/breathing_moon.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../../guided_rituals/data/models/guided_rituals_data.dart';
import '../../../guided_rituals/presentation/pages/guided_ritual_page.dart';
import '../../../lunar/presentation/providers/lunar_provider.dart';
import '../../../wheel_of_year/presentation/providers/wheel_of_year_provider.dart';

/// Como o rito aparece na tela.
enum RitualCardMode {
  /// Só quando o evento é HOJE: card de destaque no topo da página.
  todayHero,

  /// Só quando o evento AINDA VEM: faixa discreta com a contagem, no lugar
  /// de sempre (depois do carrossel da lua).
  countdown,
}

/// O rito do momento.
///
/// No dia do sabbat (ou da lua cheia/nova) ele vira o card de destaque no
/// topo — é O dia, merece a tela. Enquanto o dia não chega, volta a ser a
/// faixa pequena de contagem regressiva: informação, não chamado.
class RitualOfMomentCard extends StatelessWidget {
  final RitualCardMode mode;

  const RitualOfMomentCard({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wheel = context.watch<WheelOfYearProvider>();
    final lunar = context.watch<LunarProvider>();

    // 1. É sabbat hoje?
    if (wheel.isTodaySabbat()) {
      if (mode != RitualCardMode.todayHero) return const SizedBox.shrink();
      final sabbat = wheel.getTodaySabbat()!;
      final ritual = AllGuidedRituals.forSabbat(sabbat.type);
      return _HeroRitual(
        accent: context.gc.starYellow,
        emoji: sabbat.emoji,
        title: l10n.yourDayRitualTodayTitle(sabbat.name),
        subtitle: ritual.timing,
        cta: l10n.yourDayRitualCta,
        ritualId: ritual.id,
      );
    }

    // 2. É lua cheia ou nova hoje?
    final phase = lunar.getCurrentMoonPhase();
    if (phase == MoonPhase.fullMoon || phase == MoonPhase.newMoon) {
      if (mode != RitualCardMode.todayHero) return const SizedBox.shrink();
      final ritualId = phase == MoonPhase.fullMoon ? 'full_moon' : 'new_moon';
      final ritual = AllGuidedRituals.byId(ritualId);
      return _HeroRitual(
        accent: context.gc.lilac,
        emoji: phase.emoji,
        breathingPhase: phase,
        title: l10n.yourDayRitualTodayTitle(phase.displayName),
        subtitle: ritual?.timing ?? '',
        cta: l10n.yourDayRitualCta,
        ritualId: ritualId,
      );
    }

    // 3. Não é hoje: só o modo de contagem desenha algo.
    if (mode != RitualCardMode.countdown) return const SizedBox.shrink();

    // Contagem para o evento mais próximo — o toque já abre o ritual para a
    // Bruxa se preparar (materiais, quando fazer).
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final candidates =
        <({String name, String emoji, DateTime date, String ritualId, bool isMoon})>[];

    final nextSabbat = wheel.getNextSabbat();
    if (nextSabbat != null) {
      candidates.add((
        name: nextSabbat.name,
        emoji: nextSabbat.emoji,
        date: nextSabbat.date,
        ritualId: AllGuidedRituals.forSabbat(nextSabbat.type).id,
        isMoon: false,
      ));
    }
    final nextFull = lunar.getNextFullMoon();
    if (nextFull != null) {
      candidates.add((
        name: MoonPhase.fullMoon.displayName,
        emoji: MoonPhase.fullMoon.emoji,
        date: nextFull,
        ritualId: 'full_moon',
        isMoon: true,
      ));
    }
    final nextNew = lunar.getNextNewMoon();
    if (nextNew != null) {
      candidates.add((
        name: MoonPhase.newMoon.displayName,
        emoji: MoonPhase.newMoon.emoji,
        date: nextNew,
        ritualId: 'new_moon',
        isMoon: true,
      ));
    }
    if (candidates.isEmpty) return const SizedBox.shrink();

    candidates.sort((a, b) => a.date.compareTo(b.date));
    final next = candidates.first;
    // Dias de CALENDÁRIO (véspera = 1): o evento de hoje já foi tratado acima.
    final targetDay = DateTime(next.date.year, next.date.month, next.date.day);
    final days = targetDay.difference(today).inDays.clamp(1, 9999);

    final accent = next.isMoon ? context.gc.lilac : context.gc.starYellow;
    return MagicalCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GuidedRitualPage(ritualId: next.ritualId),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.hourglass_bottom, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.yourDayRitualCountdown(days, '${next.emoji} ${next.name}'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Icon(Icons.chevron_right, color: context.gc.textSecondary),
        ],
      ),
    );
  }
}

class _HeroRitual extends StatelessWidget {
  final Color accent;
  final String emoji;
  final String title;
  final String subtitle;
  final String cta;
  final String ritualId;

  /// Quando presente, a lua respira no lugar do emoji estático.
  final MoonPhase? breathingPhase;

  const _HeroRitual({
    required this.accent,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.ritualId,
    this.breathingPhase,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    void open() => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GuidedRitualPage(ritualId: ritualId),
          ),
        );

    return MagicalCard.hero(
      accent: accent,
      onTap: open,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.yourDayHeroEyebrow.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.gc.textSecondary,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 64,
                child: breathingPhase != null
                    ? BreathingMoon(
                        moonEmoji: emoji,
                        size: 56,
                        showStars: false,
                        phase: breathingPhase,
                      )
                    : Text(emoji, style: const TextStyle(fontSize: 44)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.gc.textSecondary,
                              height: 1.35,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: open,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: context.gc.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: Text(
                cta,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
