import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/navigation/app_deep_link.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../diary/data/models/gratitude_model.dart';
import '../../../diary/presentation/providers/dream_provider.dart';
import '../../../diary/presentation/providers/gratitude_provider.dart';
import '../../../tarot/presentation/pages/tarot_page.dart';
import '../providers/daily_checkin_provider.dart';

/// Os ritos de hoje: três práticas curtas que fecham o dia da Bruxa.
///
/// A regra é atrito baixo — a gratidão se escreve aqui mesmo, o sonho vai
/// para o diário onírico e a adivinhação abre o tarot. Concluir os três
/// mantém a sequência viva, que é o que traz de volta amanhã.
///
/// Um rito só fica marcado quando a ação ACONTECEU: gratidão e sonho são
/// lidos dos registros do dia (se existe a entrada, está feito) e o tarot é
/// marcado pela própria tiragem. Tocar no rito apenas leva até a ação.
class DailyRitesCard extends StatelessWidget {
  const DailyRitesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final checkin = context.watch<DailyCheckinProvider>();
    if (!checkin.isLoaded) return const SizedBox.shrink();

    // Provas de que a ação aconteceu de verdade.
    final gratitudeDone = context
        .watch<GratitudeProvider>()
        .gratitudes
        .any((g) => _isToday(g.createdAt));
    final dreamDone =
        context.watch<DreamProvider>().dreams.any((d) => _isToday(d.createdAt));
    final tarotDone = checkin.isRiteDone(DailyRites.divination);

    final total = DailyRites.all.length;
    final done = [gratitudeDone, dreamDone, tarotDone].where((e) => e).length;
    final complete = done == total;
    final accent = complete ? context.gc.mint : context.gc.lilac;

    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                complete ? Icons.check_circle : Icons.brightness_2_outlined,
                color: accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.yourDayRitesTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Text(
                l10n.yourDayRitesProgress(done, total),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _RiteTile(
            done: gratitudeDone,
            emoji: '🙏',
            label: l10n.yourDayRiteGratitude,
            onStart: () => _writeGratitude(context),
          ),
          _RiteTile(
            done: dreamDone,
            emoji: '🌙',
            label: l10n.yourDayRiteDream,
            // Só leva até lá: quem marca é o sonho registrado.
            onStart: () =>
                DeepLinkService.instance.dispatch(AppDeepLink.dreamsDiary),
          ),
          _RiteTile(
            done: tarotDone,
            emoji: '🎴',
            label: l10n.yourDayRiteTarot,
            // Quem marca é a tiragem, feita lá dentro.
            onStart: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TarotPage()),
            ),
          ),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: complete
                ? Row(
                    key: const ValueKey('complete'),
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.yourDayRitesComplete,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.gc.mint,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    l10n.yourDayRitesHint,
                    key: const ValueKey('hint'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
          ),
        ],
      ),
    );
  }

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Gratidão em um gesto: uma linha, salvar, pronto — e o registro vai para
  /// o Diário de Gratidão como qualquer outro.
  static Future<void> _writeGratitude(BuildContext context) async {
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.gc.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _GratitudeSheet(),
    );

    if (text == null || text.isEmpty || !context.mounted) return;

    await context.read<GratitudeProvider>().addGratitude(
          GratitudeModel(
            title: text.length > 40 ? '${text.substring(0, 40)}…' : text,
            content: text,
            tags: const [],
          ),
        );
    // A gratidão salva já é a prova do rito; o check-in do dia continua
    // sendo registrado normalmente.
    if (context.mounted) HapticFeedback.selectionClick();
  }
}

/// Folha de gratidão rápida.
///
/// É um StatefulWidget de propósito: o TextEditingController morre junto com
/// ela, e todo `Theme.of`/`Provider.of` usa o contexto DA FOLHA. Fazer isso
/// pelo contexto de fora quebrava a árvore quando a folha fechava
/// (`_dependents.isEmpty`).
class _GratitudeSheet extends StatefulWidget {
  const _GratitudeSheet();

  @override
  State<_GratitudeSheet> createState() => _GratitudeSheetState();
}

class _GratitudeSheetState extends State<_GratitudeSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.yourDayRiteGratitude,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 3,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: l10n.yourDayGratitudeHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.gc.lilac,
                foregroundColor: context.gc.onPrimary,
              ),
              onPressed: _save,
              child: Text(l10n.commonSave),
            ),
          ),
        ],
      ),
    );
  }
}

/// Uma linha de rito: emoji, rótulo e o círculo que marca a conclusão.
class _RiteTile extends StatelessWidget {
  final bool done;
  final String emoji;
  final String label;
  final VoidCallback onStart;

  const _RiteTile({
    required this.done,
    required this.emoji,
    required this.label,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: done ? null : onStart,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? context.gc.mint.withValues(alpha: 0.25)
                    : Colors.transparent,
                border: Border.all(
                  color: done ? context.gc.mint : context.gc.surfaceBorder,
                  width: 1.5,
                ),
              ),
              child: done
                  ? Icon(Icons.check, size: 16, color: context.gc.mint)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: done
                          ? context.gc.textSecondary
                          : context.gc.textPrimary,
                      decoration: done ? TextDecoration.lineThrough : null,
                      decorationColor: context.gc.textSecondary,
                    ),
              ),
            ),
            if (!done)
              Icon(Icons.chevron_right, size: 18, color: context.gc.lilac),
          ],
        ),
      ),
    );
  }
}
