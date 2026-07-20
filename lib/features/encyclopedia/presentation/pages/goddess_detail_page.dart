import 'package:flutter/material.dart';
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
                    style: Theme.of(context).textTheme.headlineMedium,
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


            // Aspects
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Aspectos & Domínios'),
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


            // Correspondences
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Correspondências'),
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


            // Symbols, Animals, Plants, Colors
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Símbolos & Associações'),
                  const SizedBox(height: 12),
                  _buildChipSection(context, 'Símbolos', goddess.symbols, '✨'),
                  const SizedBox(height: 12),
                  _buildChipSection(context, 'Animais Sagrados', goddess.animals, '🐾'),
                  const SizedBox(height: 12),
                  _buildChipSection(context, 'Plantas', goddess.plants, '🌿'),
                  const SizedBox(height: 12),
                  _buildChipSection(context, 'Cores', goddess.colors, '🎨'),
                ],
              ),
            ),


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


            // Ritual Uses
            MagicalCard(
              child: PremiumContentSection(
                feature: AppFeature.encyclopediaGoddessesDetails,
                title: _buildSectionTitle(context, 'Usos Mágicos'),
                subtitle:
                    'Práticas devocionais e rituais associados a esta divindade.',
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


            // Invocation Tips
            MagicalCard(
              child: PremiumContentSection(
                feature: AppFeature.encyclopediaGoddessesDetails,
                title: _buildSectionTitle(context, 'Como Invocar'),
                subtitle:
                    'Orientações para conexão, invocação e trabalho devocional.',
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
