import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/astrology_provider.dart';

class MagicalProfilePage extends StatelessWidget {
  const MagicalProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil Mágico'),
        backgroundColor: AppColors.darkBackground,
      ),
      backgroundColor: AppColors.darkBackground,
      body: Consumer<AstrologyProvider>(
        builder: (context, provider, _) {
          final profile = provider.magicalProfile;

          if (profile == null) {
            return const Center(
              child: Text(
                'Perfil mágico não encontrado',
                style: TextStyle(color: AppColors.softWhite),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Introdução
                MagicalCard(
                  child: Column(
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      Text(
                        'Seu Perfil Mágico',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.lilac,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Interpretação astrológica adaptada para bruxaria',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.softWhite.withOpacity(0.8),
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Elemento Dominante
                MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            profile.dominantElement.symbol,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Elemento ${profile.dominantElement.displayName}',
                            style: GoogleFonts.cinzelDecorative(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lilac,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: AppColors.lilac),
                      const SizedBox(height: 12),
                      Text(
                        profile.dominantElement.magicalDescription,
                        style: const TextStyle(
                          color: AppColors.softWhite,
                          height: 1.5,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Distribuição:',
                        style: TextStyle(
                          color: AppColors.softWhite.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...profile.elementDistribution.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${entry.key.symbol} ${entry.key.displayName}',
                                style: const TextStyle(color: AppColors.softWhite),
                              ),
                              Text(
                                '${entry.value} planeta(s)',
                                style: TextStyle(
                                  color: AppColors.softWhite.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Modalidade Dominante
                MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modalidade ${profile.dominantModality.displayName}',
                        style: GoogleFonts.cinzelDecorative(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lilac,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: AppColors.lilac),
                      const SizedBox(height: 12),
                      Text(
                        profile.dominantModality.description,
                        style: const TextStyle(
                          color: AppColors.softWhite,
                          height: 1.5,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Essência Mágica (Sol)
                MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '☉ Essência Mágica',
                        style: GoogleFonts.cinzelDecorative(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lilac,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: AppColors.lilac),
                      const SizedBox(height: 12),
                      Text(
                        profile.magicalEssence,
                        style: const TextStyle(
                          color: AppColors.softWhite,
                          height: 1.5,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Dons Intuitivos (Lua)
                MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '☽ Dons Intuitivos',
                        style: GoogleFonts.cinzelDecorative(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lilac,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: AppColors.lilac),
                      const SizedBox(height: 12),
                      Text(
                        profile.intuitiveGifts,
                        style: const TextStyle(
                          color: AppColors.softWhite,
                          height: 1.5,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Comunicação Mágica (Mercúrio)
                MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '☿ Comunicação Mágica',
                        style: GoogleFonts.cinzelDecorative(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lilac,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: AppColors.lilac),
                      const SizedBox(height: 12),
                      Text(
                        profile.communicationStyle,
                        style: const TextStyle(
                          color: AppColors.softWhite,
                          height: 1.5,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Casa 8 (Magia)
                MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔮 Casa da Magia',
                        style: GoogleFonts.cinzelDecorative(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lilac,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: AppColors.lilac),
                      const SizedBox(height: 12),
                      Text(
                        profile.houseOfMagic,
                        style: const TextStyle(
                          color: AppColors.softWhite,
                          height: 1.5,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Casa 12 (Espiritualidade)
                MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🌙 Casa do Espírito',
                        style: GoogleFonts.cinzelDecorative(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lilac,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: AppColors.lilac),
                      const SizedBox(height: 12),
                      Text(
                        profile.houseOfSpirit,
                        style: const TextStyle(
                          color: AppColors.softWhite,
                          height: 1.5,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Forças Mágicas
                if (profile.magicalStrengths.isNotEmpty)
                  MagicalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⭐ Suas Forças Mágicas',
                          style: GoogleFonts.cinzelDecorative(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lilac,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(color: AppColors.lilac),
                        const SizedBox(height: 12),
                        ...profile.magicalStrengths.map((strength) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    color: AppColors.lilac,
                                    fontSize: 16,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    strength,
                                    style: const TextStyle(
                                      color: AppColors.softWhite,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Práticas Recomendadas
                if (profile.recommendedPractices.isNotEmpty)
                  MagicalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📿 Práticas Recomendadas',
                          style: GoogleFonts.cinzelDecorative(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lilac,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(color: AppColors.lilac),
                        const SizedBox(height: 12),
                        ...profile.recommendedPractices.map((practice) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    color: AppColors.lilac,
                                    fontSize: 16,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    practice,
                                    style: const TextStyle(
                                      color: AppColors.softWhite,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Ferramentas Favoráveis
                if (profile.favorableTools.isNotEmpty)
                  MagicalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔮 Ferramentas Favoráveis',
                          style: GoogleFonts.cinzelDecorative(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lilac,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(color: AppColors.lilac),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: profile.favorableTools.map((tool) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lilac.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.lilac.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                tool,
                                style: const TextStyle(
                                  color: AppColors.lilac,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Trabalho com Sombras
                if (profile.shadowWork.isNotEmpty)
                  MagicalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🌑 Trabalho com Sombras',
                          style: GoogleFonts.cinzelDecorative(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lilac,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(color: AppColors.lilac),
                        const SizedBox(height: 12),
                        ...profile.shadowWork.map((work) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    color: AppColors.lilac,
                                    fontSize: 16,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    work,
                                    style: const TextStyle(
                                      color: AppColors.softWhite,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
