import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../diary/data/models/gratitude_model.dart';
import '../../../diary/presentation/providers/gratitude_provider.dart';
import '../../../diary/presentation/pages/dreams_list_page.dart';
import '../../../tarot/presentation/pages/tarot_page.dart';
import '../providers/daily_checkin_provider.dart';

/// Os ritos de hoje: três práticas curtas que fecham o dia da Bruxa.
///
/// A regra é atrito baixo — a gratidão se escreve aqui mesmo, o sonho vai
/// para o diário onírico e a adivinhação abre o tarot. Concluir os três
/// mantém a sequência viva, que é o que traz de volta amanhã.
class DailyRitesCard extends StatelessWidget {
  const DailyRitesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final checkin = context.watch<DailyCheckinProvider>();
    if (!checkin.isLoaded) return const SizedBox.shrink();

    final done = checkin.ritesDoneCount;
    final total = DailyRites.all.length;
    final complete = checkin.isDayComplete;
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
            id: DailyRites.gratitude,
            emoji: '🙏',
            label: l10n.yourDayRiteGratitude,
            onStart: () => _writeGratitude(context),
          ),
          _RiteTile(
            id: DailyRites.dream,
            emoji: '🌙',
            label: l10n.yourDayRiteDream,
            onStart: () {
              _complete(context, DailyRites.dream);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DreamsListPage()),
              );
            },
          ),
          _RiteTile(
            id: DailyRites.divination,
            emoji: '🎴',
            label: l10n.yourDayRiteTarot,
            onStart: () {
              _complete(context, DailyRites.divination);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TarotPage()),
              );
            },
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

  /// Marca o rito e comemora quando ele foi o último do dia.
  static Future<void> _complete(BuildContext context, String riteId) async {
    final provider = context.read<DailyCheckinProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context).yourDayRitesComplete;

    HapticFeedback.selectionClick();
    final closedTheDay = await provider.completeRite(riteId);
    if (closedTheDay) {
      messenger.showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
    }
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
    if (context.mounted) await _complete(context, DailyRites.gratitude);
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
  final String id;
  final String emoji;
  final String label;
  final VoidCallback onStart;

  const _RiteTile({
    required this.id,
    required this.emoji,
    required this.label,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final checkin = context.watch<DailyCheckinProvider>();
    final done = checkin.isRiteDone(id);

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
