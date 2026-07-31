import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/gender.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Saudação do Seu Dia: Salem + "Boa noite, {nome}" (fallback por gênero)
/// + data longa localizada.
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

    final displayName = user.displayName?.trim();
    final name = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : GenderText.select(
            preference: user.gender,
            feminine: l10n.witchTreatmentFeminine,
            masculine: l10n.witchTreatmentMasculine,
            neutral: l10n.witchTreatmentNeutral,
          );

    final locale = Localizations.localeOf(context).toString();
    final dateText = DateFormat.yMMMMEEEEd(locale).format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/new_cat/cat_sit_tail_left.png',
            width: 56,
            height: 56,
            errorBuilder: (_, __, ___) =>
                const Text('🐈‍⬛', style: TextStyle(fontSize: 40)),
          ),
          const SizedBox(width: 12),
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
