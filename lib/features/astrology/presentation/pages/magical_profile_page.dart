import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../providers/astrology_provider.dart';
import '../../data/models/enums.dart';
import '../../data/data_sources/planet_sign_interpretations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';

class MagicalProfilePage extends StatefulWidget {
  const MagicalProfilePage({super.key});

  @override
  State<MagicalProfilePage> createState() => _MagicalProfilePageState();
}

class _MagicalProfilePageState extends State<MagicalProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveAppBarTitle('Perfil Mágico'),
        backgroundColor: context.gc.darkBackground,
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
      backgroundColor: context.gc.darkBackground,
      body: Consumer<AstrologyProvider>(
        builder: (context, provider, _) {
          final profile = provider.magicalProfile;

          if (profile == null) {
            return Center(
              child: Text(
                'Perfil mágico não encontrado',
                style: TextStyle(color: context.gc.softWhite),
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
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: context.gc.lilac,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Interpretação astrológica adaptada para bruxaria',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.gc.softWhite.withOpacity(0.8),
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
                              color: context.gc.lilac,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Divider(color: context.gc.lilac),
                      const SizedBox(height: 12),
                      Text(
                        profile.dominantElement.magicalDescription,
                        style: TextStyle(
                          color: context.gc.softWhite,
                          height: 1.5,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Distribuição:',
                        style: TextStyle(
                          color: context.gc.softWhite.withOpacity(0.7),
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
                                style:
                                    TextStyle(color: context.gc.softWhite),
                              ),
                              Text(
                                '${entry.value} planeta(s)',
                                style: TextStyle(
                                  color: context.gc.softWhite.withOpacity(0.6),
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
                          color: context.gc.lilac,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Divider(color: context.gc.lilac),
                      const SizedBox(height: 12),
                      Text(
                        profile.dominantModality.description,
                        style: TextStyle(
                          color: context.gc.softWhite,
                          height: 1.5,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Seção de Planetas em Signos
                _buildPlanetSignsSection(provider),

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
                            color: context.gc.lilac,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Divider(color: context.gc.lilac),
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
                                color: context.gc.lilac.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: context.gc.lilac.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                tool,
                                style: TextStyle(
                                  color: context.gc.lilac,
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

  /// Seção que mostra cada planeta em seu signo com explicação detalhada
  Widget _buildPlanetSignsSection(AstrologyProvider provider) {
    final birthChart = provider.birthChart;

    if (birthChart == null || birthChart.planets.isEmpty) {
      return const SizedBox.shrink();
    }

    // Mostrar TODOS os planetas + nodos + pontos místicos (cada um com sua
    // explicação). Só os que estiverem presentes no mapa são exibidos.
    final personalPlanets = [
      Planet.sun,
      Planet.moon,
      Planet.mercury,
      Planet.venus,
      Planet.mars,
      Planet.jupiter,
      Planet.saturn,
      Planet.uranus,
      Planet.neptune,
      Planet.pluto,
      Planet.midheaven,
      Planet.imumCoeli,
      Planet.descendant,
      Planet.vertex,
      Planet.lilith,
      Planet.partOfFortune,
      Planet.northNode,
      Planet.southNode,
    ].where((p) => birthChart.planets.any((x) => x.planet == p)).toList();

    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Seus Planetas nos Signos',
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.gc.lilac,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Toque em cada planeta para entender seu significado no seu mapa',
            style: TextStyle(
              color: context.gc.softWhite.withOpacity(0.6),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: context.gc.lilac),
          const SizedBox(height: 12),

          // Lista de planetas pessoais
          ...personalPlanets.map((planet) {
            final planetPosition =
                birthChart.planets.firstWhere((p) => p.planet == planet);

            return _buildPlanetTile(
              planet: planetPosition.planet,
              sign: planetPosition.sign,
              houseNumber: planetPosition.houseNumber,
              isRetrograde: planetPosition.isRetrograde,
            );
          }),

          const SizedBox(height: 16),

        ],
      ),
    );
  }

  /// Constrói um tile expansível para cada planeta
  Widget _buildPlanetTile({
    required Planet planet,
    required ZodiacSign sign,
    required int houseNumber,
    required bool isRetrograde,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 16),
        leading: Text(
          planet.symbol,
          style: const TextStyle(fontSize: 28),
        ),
        title: Row(
          children: [
            Text(
              '${planet.displayName} em ',
              style: TextStyle(
                color: context.gc.softWhite,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              sign.displayName,
              style: TextStyle(
                color: context.gc.lilac,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              sign.symbol,
              style: const TextStyle(fontSize: 16),
            ),
            if (isRetrograde) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: context.gc.alert.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'R',
                  style: TextStyle(
                    color: context.gc.alert,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          'Casa $houseNumber | ${sign.element.symbol} ${sign.element.displayName}',
          style: TextStyle(
            color: context.gc.softWhite.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        iconColor: context.gc.lilac,
        collapsedIconColor: context.gc.lilac.withOpacity(0.6),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.gc.surface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.gc.lilac.withOpacity(0.2),
              ),
            ),
            child: Text(
              PlanetSignInterpretations.getInterpretation(planet, sign),
              style: TextStyle(
                color: context.gc.softWhite,
                height: 1.6,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Mostra dialog com todos os planetas
  Widget _buildAISection(AstrologyProvider provider) {
    final profile = provider.magicalProfile;

    // Se está gerando IA
    if (provider.isGeneratingAI) {
      return MagicalCard(
        child: Column(
          children: [
            CircularProgressIndicator(color: context.gc.lilac),
            const SizedBox(height: 16),
            Text(
              'Gerando sua análise personalizada...',
              style: GoogleFonts.cinzelDecorative(
                fontSize: 18,
                color: context.gc.lilac,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'O Conselheiro Místico está analisando seu mapa astral\ne criando uma interpretação única para você.',
              style: TextStyle(
                color: context.gc.softWhite.withOpacity(0.7),
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
      return Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final isFree = !authProvider.isPremiumEffective;

          return MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título sempre visível
                Row(
                  children: [
                    const Text('🌟', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sua Análise Personalizada',
                        style: GoogleFonts.cinzelDecorative(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.gc.lilac,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Gerada especialmente para você com base no seu mapa astral',
                  style: TextStyle(
                    color: context.gc.softWhite.withOpacity(0.6),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Divider(color: context.gc.lilac),
                const SizedBox(height: 12),
                // FAIL-CLOSED: para free, o texto premium real NUNCA é
                // renderizado (nem com blur) — mostra placeholder desfocado.
                if (isFree) ...[
                  _buildBlurredPlaceholder(),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const PremiumUpgradeSheet(),
                        );
                      },
                      icon: const Icon(Icons.star, size: 18),
                      label: const Text('Seja Premium'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.gc.lilac,
                        foregroundColor: context.gc.onPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  MarkdownBody(
                    data: profile!.aiGeneratedText!,
                    styleSheet: _getMarkdownStyleSheet(),
                  ),
                ],
              ],
            ),
          );
        },
      );
    }

    // Se não tem texto IA e houve erro
    if (provider.error != null) {
      return MagicalCard(
        child: Column(
          children: [
            Icon(Icons.error_outline, color: context.gc.alert, size: 48),
            const SizedBox(height: 16),
            Text(
              'Não foi possível gerar sua análise',
              style: GoogleFonts.cinzelDecorative(
                fontSize: 18,
                color: context.gc.alert,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Verifique sua conexão e tente novamente.',
              style: TextStyle(
                color: context.gc.softWhite.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => provider.generateAIMagicalProfile(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.gc.lilac,
                foregroundColor: context.gc.darkBackground,
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
              color: context.gc.lilac,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Consulte o Conselheiro Místico para uma\nanálise única do seu perfil mágico.',
            style: TextStyle(
              color: context.gc.softWhite.withOpacity(0.8),
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
              backgroundColor: context.gc.lilac,
              foregroundColor: context.gc.darkBackground,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Placeholder desfocado exibido para usuários free no lugar da análise
  /// real (fail-closed: o texto premium não entra na árvore de widgets).
  Widget _buildBlurredPlaceholder() {
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
          child: MarkdownBody(
            data: kPremiumPlaceholderText,
            styleSheet: _getMarkdownStyleSheet(),
          ),
        ),
      ),
    );
  }

  MarkdownStyleSheet _getMarkdownStyleSheet() {
    return MarkdownStyleSheet(
      h2: GoogleFonts.cinzelDecorative(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: context.gc.lilac,
      ),
      p: TextStyle(
        color: context.gc.softWhite,
        height: 1.6,
        fontSize: 15,
      ),
      listBullet: TextStyle(
        color: context.gc.lilac,
        fontSize: 15,
      ),
      strong: TextStyle(
        color: context.gc.lilac,
        fontWeight: FontWeight.bold,
      ),
      em: TextStyle(
        color: context.gc.softWhite.withOpacity(0.9),
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
