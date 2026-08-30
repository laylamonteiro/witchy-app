import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/tratamento_do_contexto.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_progress.dart';
import '../../../../core/widgets/starfield_background.dart';
import '../../../journeys/presentation/pages/magical_progress_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../learning/presentation/providers/learning_provider.dart';
import '../providers/daily_checkin_provider.dart';

/// Topo do "Seu Dia": saudação pelo nome + sequência de dias + anel de nível.
///
/// É o espelho de progresso da Bruxa — fica acima da dobra de propósito: ver
/// a sequência crescer (e não querer perdê-la) é o que traz de volta amanhã.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  String _greeting(AppLocalizations l10n, String name) {
    final hour = DateTime.now().hour;
    if (hour < 5) return l10n.yourDayGreetingNight(name);
    if (hour < 12) return l10n.yourDayGreetingMorning(name);
    if (hour < 18) return l10n.yourDayGreetingAfternoon(name);
    return l10n.yourDayGreetingEvening(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.watch<AuthProvider>().currentUser;
    final checkin = context.watch<DailyCheckinProvider>();
    final learning = context.watch<LearningProvider>();

    // Só o PRIMEIRO nome: "Boa noite, Layla" é caloroso; o nome completo
    // soa formulário. O perfil continua guardando o nome inteiro.
    final displayName = user.displayName?.trim();
    final name = (displayName != null && displayName.isNotEmpty)
        ? displayName.split(RegExp(r'\s+')).first
        : context.vocativo;

    final locale = Localizations.localeOf(context).toString();
    final dateText = DateFormat.yMMMMEEEEd(locale).format(DateTime.now());
    final level = learning.level;

    return StarfieldBackground(
      starCount: 18,
      intensity: 0.5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 16, 6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(l10n, name),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                  if (checkin.isLoaded && checkin.streak > 0) ...[
                    const SizedBox(height: 8),
                    _StreakPill(streak: checkin.streak),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Anel do nível — toque leva à Evolução Mágica, direto na aba
            // de Jornadas, onde o nível e a escada de títulos vivem.
            Semantics(
              label: '${level.title} · ${learning.xp} XP',
              button: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const MagicalProgressPage()),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: MagicalProgressRing(
                    value: learning.levelProgress,
                    size: 48,
                    strokeWidth: 4,
                    center: Text(
                      level.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Selo da sequência de dias — a chama pulsa de leve para chamar o olhar.
/// Toque abre as Estatísticas Mágicas, onde a sequência vive em detalhe.
class _StreakPill extends StatelessWidget {
  final int streak;

  const _StreakPill({required this.streak});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = context.gc.starYellow;

    return Semantics(
      label: l10n.yourDayStreakDays(streak),
      button: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.9, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => const MagicalProgressPage(initialTab: 1)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.55)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  l10n.yourDayStreakDays(streak),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
