import 'package:flutter/material.dart';
import '../widgets/encyclopedia_image.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../data/models/crystal_model.dart';
import '../../data/models/user_entry_model.dart';
import '../widgets/user_entry_helpers.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../auth/auth.dart';

class CrystalDetailPage extends StatelessWidget {
  final CrystalModel crystal;

  /// Presente quando a página exibe uma entrada criada pela Bruxa: habilita
  /// a lixeira no AppBar (mesmo padrão dos feitiços do Grimório).
  final UserEncyclopediaEntry? userEntry;

  const CrystalDetailPage({super.key, required this.crystal, this.userEntry});

  @override
  Widget build(BuildContext context) {
    final entry = userEntry;
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(crystal.name),
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
                  if (crystal.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: EncyclopediaImage(
                        path: crystal.imageUrl!,
                        width: 200,
                        height: 200,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage(context);
                        },
                      ),
                    )
                  else
                    _buildPlaceholderImage(context),
                  const SizedBox(height: 16),
                  Text(
                    crystal.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(crystal.element.emoji,
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        crystal.element.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    crystal.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Safety Warnings Section (only if there are warnings)
            if (crystal.safetyWarnings.isNotEmpty)
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
                      ...crystal.safetyWarnings.map(
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
            // Intenções - visível para todos
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
                    children: crystal.intentions
                        .map((intention) => Chip(
                              label: Text(intention),
                              backgroundColor: context.gc.mint.withValues(alpha: 0.2),
                              side: BorderSide(color: context.gc.mint),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            // Limpeza - visível para todos
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Limpeza',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ...crystal.cleaningMethods.map(
                    (methodObj) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                methodObj.isSafe
                                    ? Icons.water_drop
                                    : Icons.dangerous,
                                size: 16,
                                color: methodObj.isSafe
                                    ? context.gc.info
                                    : context.gc.alert,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  methodObj.method,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        decoration: methodObj.isSafe
                                            ? null
                                            : TextDecoration.lineThrough,
                                        color: methodObj.isSafe
                                            ? null
                                            : context.gc.textSecondary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          if (!methodObj.isSafe && methodObj.warning != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 24, top: 4),
                              child: Text(
                                '⚠️ ${methodObj.warning}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: context.gc.alert,
                                      fontStyle: FontStyle.italic,
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
            // Recarga - visível para todos
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recarga',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ...crystal.chargingMethods.map(
                    (methodObj) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                methodObj.isSafe ? Icons.bolt : Icons.dangerous,
                                size: 16,
                                color: methodObj.isSafe
                                    ? context.gc.starYellow
                                    : context.gc.alert,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  methodObj.method,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        decoration: methodObj.isSafe
                                            ? null
                                            : TextDecoration.lineThrough,
                                        color: methodObj.isSafe
                                            ? null
                                            : context.gc.textSecondary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          if (!methodObj.isSafe && methodObj.warning != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 24, top: 4),
                              child: Text(
                                '⚠️ ${methodObj.warning}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: context.gc.alert,
                                      fontStyle: FontStyle.italic,
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
            // Premium content - blur apenas nas sugestões de uso (título sem blur)
            MagicalCard(
              child: PremiumContentSection(
                feature: AppFeature.encyclopediaCrystalsDetails,
                title: Text(
                  AppLocalizations.of(context).encySectionMagicUses,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                subtitle:
                    AppLocalizations.of(context).encyCrystalUsesSub,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    ...crystal.usageTips.map(
                      (tip) => Padding(
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
                                tip,
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

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: context.gc.lilac.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        Icons.diamond,
        color: context.gc.lilac,
        size: 80,
      ),
    );
  }
}
