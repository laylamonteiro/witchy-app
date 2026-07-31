import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../data/models/color_model.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../auth/auth.dart';

class ColorDetailPage extends StatelessWidget {
  final ColorModel colorModel;

  const ColorDetailPage({super.key, required this.colorModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(colorModel.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MagicalCard(
              child: Column(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: colorModel.color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: context.gc.surfaceBorder,
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    colorModel.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    colorModel.meaning,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
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
                    children: colorModel.intentions
                        .map((intention) => Chip(
                              label: Text(intention),
                              backgroundColor:
                                  colorModel.color.withOpacity(0.3),
                              side: BorderSide(color: colorModel.color),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            // Premium content - blur apenas nas sugestões de uso (título sem blur)
            MagicalCard(
              child: PremiumContentSection(
                feature: AppFeature.encyclopediaColorsDetails,
                title: Text(
                  AppLocalizations.of(context).encySectionMagicUses,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                subtitle:
                    AppLocalizations.of(context).encyColorUsesSub,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    ...colorModel.usageTips.map(
                      (tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: colorModel.color,
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
}
