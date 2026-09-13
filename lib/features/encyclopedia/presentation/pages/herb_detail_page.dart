import 'package:flutter/material.dart';
import '../widgets/encyclopedia_image.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../data/models/herb_model.dart';
import '../../data/models/user_entry_model.dart';
import '../widgets/user_entry_helpers.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../auth/auth.dart';

class HerbDetailPage extends StatelessWidget {
  final HerbModel herb;

  /// Presente quando a página exibe uma entrada criada pela Bruxa: habilita
  /// a lixeira no AppBar (mesmo padrão dos feitiços do Grimório).
  final UserEncyclopediaEntry? userEntry;

  const HerbDetailPage({super.key, required this.herb, this.userEntry});

  @override
  Widget build(BuildContext context) {
    final entry = userEntry;
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(herb.name),
        actions: [
          if (entry != null)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: AppLocalizations.of(context).commonDelete,
              onPressed: () async {
                final deleted = await confirmDeleteUserEntry(context, entry);
                if (deleted && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MagicalCard(
              child: Column(
                children: [
                  if (herb.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: EncyclopediaImage(
                        path: herb.imageUrl!,
                        width: 200,
                        height: 200,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: context.gc.mint.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Text(
                                '🌿',
                                style: TextStyle(fontSize: 60),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: context.gc.mint.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          '🌿',
                          style: TextStyle(fontSize: 60),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    herb.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    herb.scientificName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: context.gc.textSecondary,
                        ),
                  ),
                  if (herb.folkNames != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      herb.folkNames!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.gc.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Elemento e planeta lado a lado numa linha só estouravam
                  // em tela estreita com fonte ampliada (eram quatro textos
                  // rígidos num Row). Com Wrap, o par que não couber desce
                  // para a linha de baixo em vez de ser cortado; quando cabe,
                  // o desenho é exatamente o de antes.
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 24,
                    runSpacing: 8,
                    children: [
                      _buildAttribute(
                        context,
                        herb.element.emoji,
                        herb.element.displayName,
                      ),
                      _buildAttribute(
                        context,
                        herb.planet.emoji,
                        herb.planet.displayName,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    herb.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Safety Warnings Section (only if there are warnings)
            if (herb.safetyWarnings.isNotEmpty)
              MagicalCard(
                child: Container(
                  decoration: BoxDecoration(
                    color: context.gc.alert.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.gc.alert, width: 2),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: context.gc.alert,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          // "Avisos de Segurança" em titleLarge ao lado de um
                          // ícone de 28 não cabe em 320 com a fonte grande —
                          // e é justamente o aviso que não pode sumir.
                          Flexible(
                            child: Text(
                              AppLocalizations.of(context).encySectionSafety,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: context.gc.alert,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (herb.toxic)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: context.gc.alert.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.dangerous,
                                    color: context.gc.alert, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context).encyHerbToxicWarning,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: context.gc.alert,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ...herb.safetyWarnings.map(
                        (warning) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '⚠️',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  warning,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Propriedades Mágicas - visível para todos
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).encySectionMagicProps,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: herb.magicalProperties
                        .map((property) => Chip(
                              label: Text(property),
                              backgroundColor: context.gc.mint.withValues(alpha: 0.2),
                              side: BorderSide(color: context.gc.mint),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            // Indicadores - visível para todos
            MagicalCard(
              // Os dois indicadores dividem a linha meio a meio. Sem Expanded
              // cada um pedia a largura inteira do próprio rótulo ("Não
              // comestível") e os dois juntos estouravam o cartão numa tela
              // de 320 com a fonte ampliada.
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          herb.edible ? Icons.restaurant : Icons.no_meals,
                          color:
                              herb.edible ? context.gc.mint : context.gc.alert,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          herb.edible
                              ? AppLocalizations.of(context).encyHerbEdible
                              : AppLocalizations.of(context).encyHerbNotEdible,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          herb.toxic ? Icons.dangerous : Icons.verified_user,
                          color:
                              herb.toxic ? context.gc.alert : context.gc.mint,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          herb.toxic
                              ? AppLocalizations.of(context).encyHerbToxicLabel
                              : AppLocalizations.of(context).encyHerbNotToxic,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Premium content - blur apenas nas sugestões de uso ritual (título sem blur)
            MagicalCard(
              child: PremiumContentSection(
                feature: AppFeature.encyclopediaHerbsDetails,
                title: Text(
                  AppLocalizations.of(context).encySectionMagicUses,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                subtitle:
                    AppLocalizations.of(context).encyHerbUsesSub,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    ...herb.ritualUses.map(
                      (use) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: context.gc.starYellow,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                use,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Um par emoji + nome (elemento, planeta) como bloco indivisível.
  ///
  /// `mainAxisSize.min` para o Wrap medir o par inteiro, e `Flexible` no
  /// nome porque um par sozinho ainda pode ser mais largo que o cartão
  /// quando a fonte do sistema está no máximo.
  Widget _buildAttribute(BuildContext context, String emoji, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
