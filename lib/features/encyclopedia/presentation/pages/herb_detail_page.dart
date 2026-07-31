import 'package:flutter/material.dart';
import '../widgets/encyclopedia_image.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../data/models/herb_model.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../auth/auth.dart';

class HerbDetailPage extends StatelessWidget {
  final HerbModel herb;

  const HerbDetailPage({super.key, required this.herb});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(herb.name),
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
                              color: context.gc.mint.withOpacity(0.2),
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
                        color: context.gc.mint.withOpacity(0.2),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(herb.element.emoji,
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        herb.element.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 24),
                      Text(herb.planet.emoji,
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        herb.planet.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
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
                    color: context.gc.alert.withOpacity(0.1),
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
                          Text(
                            AppLocalizations.of(context).encySectionSafety,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: context.gc.alert,
                                  fontWeight: FontWeight.bold,
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
                              color: context.gc.alert.withOpacity(0.2),
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
                              backgroundColor: context.gc.mint.withOpacity(0.2),
                              side: BorderSide(color: context.gc.mint),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            // Indicadores - visível para todos
            MagicalCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Icon(
                        herb.edible ? Icons.restaurant : Icons.no_meals,
                        color: herb.edible ? context.gc.mint : context.gc.alert,
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        herb.edible
                            ? AppLocalizations.of(context).encyHerbEdible
                            : AppLocalizations.of(context).encyHerbNotEdible,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(
                        herb.toxic ? Icons.dangerous : Icons.verified_user,
                        color: herb.toxic ? context.gc.alert : context.gc.mint,
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        herb.toxic
                            ? AppLocalizations.of(context).encyHerbToxicLabel
                            : AppLocalizations.of(context).encyHerbNotToxic,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
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
}
