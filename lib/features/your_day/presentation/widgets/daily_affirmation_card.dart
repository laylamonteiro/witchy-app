import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../diary/data/models/affirmation_model.dart';
import '../../../diary/presentation/providers/affirmation_provider.dart';

/// Afirmação do dia: determinística por data sobre as pré-carregadas,
/// com botão de favoritar (reflete no diário de afirmações).
class DailyAffirmationCard extends StatefulWidget {
  const DailyAffirmationCard({super.key});

  @override
  State<DailyAffirmationCard> createState() => _DailyAffirmationCardState();
}

class _DailyAffirmationCardState extends State<DailyAffirmationCard> {
  @override
  void initState() {
    super.initState();
    // Garante o seed/carga das afirmações mesmo antes de abrir os Diários.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AffirmationProvider>();
      if (provider.affirmations.isEmpty && !provider.isLoading) {
        provider.loadAffirmations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<AffirmationProvider>(
      builder: (context, provider, _) {
        final affirmation = provider.affirmationForDate(DateTime.now());
        if (affirmation == null) return const SizedBox.shrink();

        return MagicalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(affirmation.category.icon,
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.yourDayAffirmationTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '“${affirmation.text}”',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => provider.toggleFavorite(affirmation),
                  icon: Icon(
                    affirmation.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 18,
                    color: context.gc.pink,
                  ),
                  label: Text(
                    affirmation.isFavorite
                        ? l10n.yourDayAffirmationSaved
                        : l10n.yourDayAffirmationSave,
                    style: TextStyle(color: context.gc.pink, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
