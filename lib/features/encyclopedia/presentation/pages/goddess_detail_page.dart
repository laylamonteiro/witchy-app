import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/models/goddess_model.dart';
import '../../../auth/auth.dart';

class GoddessDetailPage extends StatelessWidget {
  final GoddessModel goddess;

  const GoddessDetailPage({super.key, required this.goddess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(goddess.name),
        backgroundColor: context.gc.darkBackground,
      ),
      backgroundColor: context.gc.darkBackground,
      body: SingleChildScrollView(
        // Sem padding horizontal: o MagicalCard já traz margem lateral de 16,
        // igual às demais enciclopédias. Evita cards mais estreitos aqui.
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card with image and basic info
            MagicalCard(
              child: Column(
                children: [
                  if (goddess.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        goddess.imageUrl!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage(context);
                        },
                      ),
                    )
                  else
                    _buildPlaceholderImage(context),
                  const SizedBox(height: 16),
                  Text(
                    goddess.name,
                    style: GoogleFonts.cinzelDecorative(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: context.gc.lilac,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (goddess.alternateNames != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      goddess.alternateNames!,
                      style: TextStyle(
                        color: context.gc.softWhite.withOpacity(0.7),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.gc.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(goddess.origin.emoji),
                        const SizedBox(width: 4),
                        Text(
                          goddess.origin.displayName,
                          style: TextStyle(
                            color: context.gc.softWhite,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    goddess.description,
                    style: TextStyle(
                      color: context.gc.softWhite,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Aspects
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, AppLocalizations.of(context).encyGoddessAspects),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: goddess.aspects.map((aspect) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: context.gc.lilac.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: context.gc.lilac.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(aspect.emoji,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              aspect.displayName,
                              style: TextStyle(
                                color: context.gc.lilac,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Correspondences
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, AppLocalizations.of(context).encySectionCorrespondences),
                  const SizedBox(height: 12),
                  Text(
                    goddess.correspondences,
                    style: TextStyle(
                      color: context.gc.softWhite,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Symbols, Animals, Plants, Colors
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, AppLocalizations.of(context).encyGoddessSymbolsAssoc),
                  const SizedBox(height: 12),
                  _buildChipSection(context, AppLocalizations.of(context).encyGoddessSymbols, goddess.symbols, '✨'),
                  const SizedBox(height: 12),
                  _buildChipSection(context, 'Animais Sagrados', goddess.animals, '🐾'),
                  const SizedBox(height: 12),
                  _buildChipSection(context, 'Plantas', goddess.plants, '🌿'),
                  const SizedBox(height: 12),
                  _buildChipSection(context, 'Cores', goddess.colors, '🎨'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Mythology
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Mitologia'),
                  const SizedBox(height: 12),
                  Text(
                    goddess.mythology,
                    style: TextStyle(
                      color: context.gc.softWhite,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Ritual Uses
            MagicalCard(
              child: PremiumContentSection(
                feature: AppFeature.encyclopediaGoddessesDetails,
                title: _buildSectionTitle(context, AppLocalizations.of(context).encySectionMagicUses),
                subtitle:
                    AppLocalizations.of(context).encyGoddessUsesSub,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    ...goddess.ritualUses.map((use) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('🔮 ', style: TextStyle(fontSize: 14)),
                              Expanded(
                                child: Text(
                                  use,
                                  style: TextStyle(
                                    color: context.gc.softWhite,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Invocation Tips
            MagicalCard(
              child: PremiumContentSection(
                feature: AppFeature.encyclopediaGoddessesDetails,
                title: _buildSectionTitle(context, 'Como Invocar'),
                subtitle:
                    AppLocalizations.of(context).encyGoddessConnectionSub,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    ...goddess.invocationTips.map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('🌟 ', style: TextStyle(fontSize: 14)),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: TextStyle(
                                    color: context.gc.softWhite,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    // Padrão da Enciclopédia: título de seção em titleLarge (a fonte
    // Cinzel fica reservada ao nome no cabeçalho).
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget _buildChipSection(BuildContext context, String title, List<String> items, String emoji) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$emoji $title',
          style: TextStyle(
            color: context.gc.softWhite.withOpacity(0.8),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: context.gc.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item,
                style: TextStyle(
                  color: context.gc.softWhite,
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: context.gc.lilac.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        goddess.emoji,
        style: const TextStyle(fontSize: 100),
        textAlign: TextAlign.center,
      ),
    );
  }
}
