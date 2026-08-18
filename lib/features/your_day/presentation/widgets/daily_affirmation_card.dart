import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/sharing/share_card.dart';
import '../../../../core/sharing/share_card_sheet.dart';
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

  void _shareAsImage(BuildContext context, AffirmationModel affirmation) {
    final l10n = AppLocalizations.of(context);
    showShareCardSheet(
      context,
      fileName: 'afirmacao_do_dia',
      shareText: l10n.shareAffirmationText,
      card: ShareCard(
        child: AffirmationShareContent(
          title: l10n.yourDayAffirmationTitle,
          text: affirmation.text,
        ),
      ),
    );
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
              const SizedBox(height: 4),
              // Pull-quote: a frase é a protagonista do card — centralizada,
              // corpo maior e aspas decorativas em lilás. O texto usa a cor
              // padrão do tema (não o acento) para seguir legível em todos
              // os temas.
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Text(
                        '❝',
                        style: TextStyle(
                          fontSize: 36,
                          height: 1.1,
                          color: context.gc.lilac.withValues(alpha: 0.55),
                        ),
                      ),
                      Text(
                        affirmation.text,
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                  height: 1.45,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Ações em ícones discretos (rótulos viram tooltip): botões
              // com texto disputavam atenção com a frase, que é a
              // protagonista do card.
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _shareAsImage(context, affirmation),
                      tooltip: l10n.shareImageShare,
                      icon: Icon(
                        Icons.share_outlined,
                        size: 20,
                        color: context.gc.lilac,
                      ),
                    ),
                    IconButton(
                      onPressed: () => provider.toggleFavorite(affirmation),
                      tooltip: affirmation.isFavorite
                          ? l10n.yourDayAffirmationSaved
                          : l10n.yourDayAffirmationSave,
                      icon: Icon(
                        affirmation.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 20,
                        color: context.gc.pink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
