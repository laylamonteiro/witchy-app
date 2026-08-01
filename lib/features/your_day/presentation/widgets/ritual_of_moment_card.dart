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
import '../../../wheel_of_year/data/models/sabbat_model.dart';
import '../../../wheel_of_year/presentation/providers/wheel_of_year_provider.dart';

/// O que a Bruxa faz HOJE — a ação primária da tela, em card de destaque.
///
/// Prioridade: sabbat de hoje → lua cheia/nova de hoje → contagem para o
/// próximo evento (com o ritual já aberto para preparar). Só existe UM card
/// hero por tela: é ele que diz "faça isto agora".
class RitualOfMomentCard extends StatelessWidget {
  const RitualOfMomentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wheel = context.watch<WheelOfYearProvider>();
    final lunar = context.watch<LunarProvider>();

    // 1. É sabbat hoje?
    if (wheel.isTodaySabbat()) {
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

    // 3. Contagem para o evento mais próximo — o CTA já abre o ritual para
    // a Bruxa se preparar (materiais, quando fazer).
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

    return _HeroRitual(
      accent: next.isMoon ? context.gc.lilac : context.gc.starYellow,
      emoji: next.emoji,
      title: l10n.yourDayRitualCountdown(days, next.name),
      subtitle: AllGuidedRituals.byId(next.ritualId)?.timing ?? '',
      cta: l10n.yourDayHeroPrepareCta,
      ritualId: next.ritualId,
      daysBadge: days,
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

  /// Quando presente, a lua respira no lugar do emoji estático (só no dia).
  final MoonPhase? breathingPhase;

  /// Dias restantes, exibidos como selo no canto (só na contagem).
  final int? daysBadge;

  const _HeroRitual({
    required this.accent,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.ritualId,
    this.breathingPhase,
    this.daysBadge,
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
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.yourDayHeroEyebrow.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (daysBadge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accent.withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    'D-$daysBadge',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
            ],
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
