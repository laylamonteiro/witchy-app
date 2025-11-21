import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/astrology_provider.dart';

class MagicalProfilePage extends StatefulWidget {
  const MagicalProfilePage({super.key});

  @override
  State<MagicalProfilePage> createState() => _MagicalProfilePageState();
}

class _MagicalProfilePageState extends State<MagicalProfilePage> {
  @override
  void initState() {
    super.initState();
    // Gerar texto IA se ainda não existir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AstrologyProvider>();
      if (provider.magicalProfile != null &&
          provider.magicalProfile!.aiGeneratedText == null) {
        provider.generateAIMagicalProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil Mágico'),
        backgroundColor: AppColors.darkBackground,
        actions: [
          Consumer<AstrologyProvider>(
            builder: (context, provider, _) {
              if (provider.hasAIGeneratedProfile) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: provider.isGeneratingAI
                      ? null
                      : () => provider.regenerateAIMagicalProfile(),
                  tooltip: 'Regenerar análise',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
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
                      }),
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

                const SizedBox(height: 24),

                // Texto Personalizado IA
                _buildAISection(provider),

                const SizedBox(height: 24),

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
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAISection(AstrologyProvider provider) {
    final profile = provider.magicalProfile;

    // Se está gerando IA
    if (provider.isGeneratingAI) {
      return MagicalCard(
        child: Column(
          children: [
            const CircularProgressIndicator(color: AppColors.lilac),
            const SizedBox(height: 16),
            Text(
              'Gerando sua análise personalizada...',
              style: GoogleFonts.cinzelDecorative(
                fontSize: 18,
                color: AppColors.lilac,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'A IA está analisando seu mapa astral e criando\numa interpretação única para você.',
              style: TextStyle(
                color: AppColors.softWhite.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Se tem texto IA gerado
    if (profile?.aiGeneratedText != null) {
      return MagicalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🌟', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  'Sua Análise Personalizada',
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lilac,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Gerada especialmente para você com base no seu mapa astral',
              style: TextStyle(
                color: AppColors.softWhite.withOpacity(0.6),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: AppColors.lilac),
            const SizedBox(height: 12),
            MarkdownBody(
              data: profile!.aiGeneratedText!,
              styleSheet: MarkdownStyleSheet(
                h2: GoogleFonts.cinzelDecorative(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lilac,
                ),
                p: const TextStyle(
                  color: AppColors.softWhite,
                  height: 1.6,
                  fontSize: 15,
                ),
                listBullet: const TextStyle(
                  color: AppColors.lilac,
                  fontSize: 15,
                ),
                strong: const TextStyle(
                  color: AppColors.lilac,
                  fontWeight: FontWeight.bold,
                ),
                em: TextStyle(
                  color: AppColors.softWhite.withOpacity(0.9),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Se não tem texto IA e houve erro
    if (provider.error != null) {
      return MagicalCard(
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: AppColors.alert, size: 48),
            const SizedBox(height: 16),
            Text(
              'Não foi possível gerar sua análise',
              style: GoogleFonts.cinzelDecorative(
                fontSize: 18,
                color: AppColors.alert,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Verifique sua conexão e tente novamente.',
              style: TextStyle(
                color: AppColors.softWhite.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => provider.generateAIMagicalProfile(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lilac,
                foregroundColor: AppColors.darkBackground,
              ),
            ),
          ],
        ),
      );
    }

    // Botão para gerar
    return MagicalCard(
      child: Column(
        children: [
          const Text('🔮', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'Análise Personalizada',
            style: GoogleFonts.cinzelDecorative(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.lilac,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gere uma análise única do seu perfil mágico\ncom inteligência artificial.',
            style: TextStyle(
              color: AppColors.softWhite.withOpacity(0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => provider.generateAIMagicalProfile(),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Gerar Análise'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lilac,
              foregroundColor: AppColors.darkBackground,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
