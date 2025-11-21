import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/models/goddess_model.dart';

class GoddessDetailPage extends StatelessWidget {
  final GoddessModel goddess;

  const GoddessDetailPage({super.key, required this.goddess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(goddess.name),
        backgroundColor: AppColors.darkBackground,
      ),
      backgroundColor: AppColors.darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card with emoji and basic info
            MagicalCard(
              child: Column(
                children: [
                  Text(
                    goddess.emoji,
                    style: const TextStyle(fontSize: 72),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    goddess.name,
                    style: GoogleFonts.cinzelDecorative(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lilac,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (goddess.alternateNames != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      goddess.alternateNames!,
                      style: TextStyle(
                        color: AppColors.softWhite.withOpacity(0.7),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(goddess.origin.emoji),
                        const SizedBox(width: 4),
                        Text(
                          goddess.origin.displayName,
                          style: const TextStyle(
                            color: AppColors.softWhite,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    goddess.description,
                    style: const TextStyle(
                      color: AppColors.softWhite,
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
                  _buildSectionTitle('Aspectos & Domínios'),
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
                          color: AppColors.lilac.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.lilac.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(aspect.emoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              aspect.displayName,
                              style: const TextStyle(
                                color: AppColors.lilac,
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
                  _buildSectionTitle('Correspondências'),
                  const SizedBox(height: 12),
                  Text(
                    goddess.correspondences,
                    style: const TextStyle(
                      color: AppColors.softWhite,
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
                  _buildSectionTitle('Símbolos & Associações'),
                  const SizedBox(height: 12),
                  _buildChipSection('Símbolos', goddess.symbols, '✨'),
                  const SizedBox(height: 12),
                  _buildChipSection('Animais Sagrados', goddess.animals, '🐾'),
                  const SizedBox(height: 12),
                  _buildChipSection('Plantas', goddess.plants, '🌿'),
                  const SizedBox(height: 12),
                  _buildChipSection('Cores', goddess.colors, '🎨'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Mythology
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Mitologia'),
                  const SizedBox(height: 12),
                  Text(
                    goddess.mythology,
                    style: const TextStyle(
                      color: AppColors.softWhite,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Usos Rituais'),
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
                                style: const TextStyle(
                                  color: AppColors.softWhite,
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

            const SizedBox(height: 16),

            // Invocation Tips
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Como Invocar'),
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
                                style: const TextStyle(
                                  color: AppColors.softWhite,
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

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.cinzelDecorative(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.lilac,
      ),
    );
  }

  Widget _buildChipSection(String title, List<String> items, String emoji) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$emoji $title',
          style: TextStyle(
            color: AppColors.softWhite.withOpacity(0.8),
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
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item,
                style: const TextStyle(
                  color: AppColors.softWhite,
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
