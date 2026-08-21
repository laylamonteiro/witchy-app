import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/ai/ai_service.dart';
import '../../../../core/content/content_locale.dart';
import '../../../../core/offers/offer_engine.dart';
import '../../../../core/offers/teaser_cache.dart';
import '../../../../core/offers/teaser_reveal.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../providers/astrology_provider.dart';
import '../../data/models/enums.dart';
import '../../data/data_sources/planet_sign_interpretations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';

/// Atalho para conteúdo estático localizado (padrão `ContentLocale`,
/// paridade pt/en/es garantida pelos parâmetros obrigatórios).
String _sel({required String pt, required String en, required String es}) =>
    ContentLocale.instance.select(pt: pt, en: en, es: es);

class MagicalProfilePage extends StatefulWidget {
  const MagicalProfilePage({super.key});

  @override
  State<MagicalProfilePage> createState() => _MagicalProfilePageState();
}

class _MagicalProfilePageState extends State<MagicalProfilePage> {
  static const _teaserSlot = OfferSlot.magicalProfileTeaser;

  /// Degustação de quem não tem acesso: 2 frases reais sobre o mapa.
  String? _teaser;
  bool _isTeasing = false;
  OfferEngine? _engine;

  @override
  void initState() {
    super.initState();
    _prepareTeaser();
  }

  /// Recupera a amostra já gerada para este mapa, se houver. A geração só
  /// acontece no toque — degustação não gasta IA de quem só passou.
  Future<void> _prepareTeaser() async {
    final chartId = context.read<AstrologyProvider>().birthChart?.id;
    if (chartId == null) return;
    final engine = await OfferEngine.load();
    final cached = await TeaserAiCache.get(_teaserSlot.name, chartId);
    if (!mounted) return;
    setState(() {
      _engine = engine;
      _teaser = cached;
    });
    engine.recordWallExposure(_teaserSlot);
  }

  Future<void> _generateProfileTeaser(AstrologyProvider provider) async {
    final chart = provider.birthChart;
    final profile = provider.magicalProfile;
    if (_isTeasing || chart == null || profile == null) return;
    setState(() => _isTeasing = true);
    final messenger = ScaffoldMessenger.of(context);
    final alertColor = context.gc.alert;
    try {
      final sample = await AIService.instance.generateMagicalProfileTeaser(
        birthChart: chart,
        profile: profile,
      );
      await TeaserAiCache.put(_teaserSlot.name, chart.id, sample);
      if (!mounted) return;
      setState(() => _teaser = sample);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text('$e'.replaceAll('Exception: ', '')),
        backgroundColor: alertColor,
      ));
    } finally {
      if (mounted) setState(() => _isTeasing = false);
    }
  }

  void _onTeaserCta() {
    _engine?.recordClick(_teaserSlot);
    showPremiumUpgradePaywall(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(
            AppLocalizations.of(context).astroMagicalProfile),
        backgroundColor: context.gc.darkBackground,
        actions: [
          Consumer<AstrologyProvider>(
            builder: (context, provider, _) {
              if (provider.hasAIGeneratedProfile) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: provider.isGeneratingAI
                      ? null
                      : () => provider.regenerateAIMagicalProfile(
                            hasFullAccess: context
                                .read<AuthProvider>()
                                .isPremiumEffective,
                          ),
                  tooltip: ContentLocale.instance.select(
                    pt: 'Regenerar análise',
                    en: 'Regenerate analysis',
                    es: 'Regenerar análisis',
                  ),
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
                ContentLocale.instance.select(
                  pt: 'Perfil mágico não encontrado',
                  en: 'Magical profile not found',
                  es: 'Perfil mágico no encontrado',
                ),
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
                        _sel(
                          pt: 'Seu Perfil Mágico',
                          en: 'Your Magical Profile',
                          es: 'Tu Perfil Mágico',
                        ),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: context.gc.lilac,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _sel(
                          pt: 'Interpretação astrológica adaptada para bruxaria',
                          en: 'Astrological interpretation adapted for witchcraft',
                          es: 'Interpretación astrológica adaptada a la brujería',
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.gc.softWhite.withValues(alpha: 0.8),
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
                            _sel(
                              pt: 'Elemento ${profile.dominantElement.displayName}',
                              en: '${profile.dominantElement.displayName} Element',
                              es: 'Elemento ${profile.dominantElement.displayName}',
                            ),
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
                        _sel(
                          pt: 'Distribuição:',
                          en: 'Distribution:',
                          es: 'Distribución:',
                        ),
                        style: TextStyle(
                          color: context.gc.softWhite.withValues(alpha: 0.7),
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
                                '${entry.value} ${_sel(pt: 'planeta(s)', en: 'planet(s)', es: 'planeta(s)')}',
                                style: TextStyle(
                                  color: context.gc.softWhite.withValues(alpha: 0.6),
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
                        _sel(
                          pt: 'Modalidade ${profile.dominantModality.displayName}',
                          en: '${profile.dominantModality.displayName} Modality',
                          es: 'Modalidad ${profile.dominantModality.displayName}',
                        ),
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
                Consumer<AuthProvider>(
                  builder: (context, auth, _) =>
                      _buildAISection(provider, auth.isPremiumEffective),
                ),

                const SizedBox(height: 24),

                // Ferramentas Favoráveis
                if (profile.favorableTools.isNotEmpty)
                  MagicalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _sel(
                            pt: '🔮 Ferramentas Favoráveis',
                            en: '🔮 Favorable Tools',
                            es: '🔮 Herramientas Favorables',
                          ),
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
                                color: context.gc.lilac.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: context.gc.lilac.withValues(alpha: 0.5),
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
                  _sel(
                    pt: 'Seus Planetas nos Signos',
                    en: 'Your Planets in the Signs',
                    es: 'Tus Planetas en los Signos',
                  ),
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
            _sel(
              pt: 'Toque em cada planeta para entender seu significado no seu mapa',
              en: 'Tap each planet to understand its meaning in your chart',
              es: 'Toca cada planeta para entender su significado en tu carta',
            ),
            style: TextStyle(
              color: context.gc.softWhite.withValues(alpha: 0.6),
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
              '${planet.displayName} ${_sel(pt: 'em', en: 'in', es: 'en')} ',
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
                  color: context.gc.alert.withValues(alpha: 0.2),
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
          '${_sel(pt: 'Casa', en: 'House', es: 'Casa')} $houseNumber | ${sign.element.symbol} ${sign.element.displayName}',
          style: TextStyle(
            color: context.gc.softWhite.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        iconColor: context.gc.lilac,
        collapsedIconColor: context.gc.lilac.withValues(alpha: 0.6),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.gc.surface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.gc.lilac.withValues(alpha: 0.2),
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
  Widget _buildAISection(AstrologyProvider provider, bool hasFullAccess) {
    final profile = provider.magicalProfile;

    // Sem acesso, a análise completa nem chega a ser gerada (o gate está no
    // provider). O que esta pessoa vê é a degustação — e ela aparece mesmo
    // sem nenhum texto salvo, porque nunca vai haver um.
    if (!hasFullAccess) {
      return _buildProfileTeaserCard(provider);
    }

    // Se está gerando IA
    if (provider.isGeneratingAI) {
      return MagicalCard(
        child: Column(
          children: [
            CircularProgressIndicator(color: context.gc.lilac),
            const SizedBox(height: 16),
            Text(
              _sel(
                pt: 'Gerando sua análise personalizada...',
                en: 'Generating your personalized analysis...',
                es: 'Generando tu análisis personalizado...',
              ),
              style: GoogleFonts.cinzelDecorative(
                fontSize: 18,
                color: context.gc.lilac,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _sel(
                pt: 'O Conselheiro Místico está analisando seu mapa astral\ne criando uma interpretação única para você.',
                en: 'The Mystic Counselor is analyzing your birth chart\nand creating a unique interpretation for you.',
                es: 'El Consejero Místico está analizando tu carta natal\ny creando una interpretación única para ti.',
              ),
              style: TextStyle(
                color: context.gc.softWhite.withValues(alpha: 0.7),
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
            _buildAISectionHeader(),
            MarkdownBody(
              data: profile!.aiGeneratedText!,
              styleSheet: _getMarkdownStyleSheet(),
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
            Icon(Icons.error_outline, color: context.gc.alert, size: 48),
            const SizedBox(height: 16),
            Text(
              ContentLocale.instance.select(
                pt: 'Não foi possível gerar sua análise',
                en: 'We could not generate your analysis',
                es: 'No fue posible generar tu análisis',
              ),
              style: GoogleFonts.cinzelDecorative(
                fontSize: 18,
                color: context.gc.alert,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ContentLocale.instance.select(
                pt: 'Verifique sua conexão e tente novamente.',
                en: 'Check your connection and try again.',
                es: 'Verifica tu conexión e inténtalo de nuevo.',
              ),
              style: TextStyle(
                color: context.gc.softWhite.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => provider.generateAIMagicalProfile(
                    hasFullAccess:
                        context.read<AuthProvider>().isPremiumEffective,
                  ),
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).commonTryAgain),
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
            _sel(
              pt: 'Análise Personalizada',
              en: 'Personalized Analysis',
              es: 'Análisis Personalizado',
            ),
            style: GoogleFonts.cinzelDecorative(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.gc.lilac,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _sel(
              pt: 'Consulte o Conselheiro Místico para uma\nanálise única do seu perfil mágico.',
              en: 'Consult the Mystic Counselor for a\nunique analysis of your magical profile.',
              es: 'Consulta al Consejero Místico para un\nanálisis único de tu perfil mágico.',
            ),
            style: TextStyle(
              color: context.gc.softWhite.withValues(alpha: 0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => provider.generateAIMagicalProfile(
                    hasFullAccess:
                        context.read<AuthProvider>().isPremiumEffective,
                  ),
            icon: const Icon(Icons.auto_awesome),
            label: Text(ContentLocale.instance.select(
              pt: 'Gerar Análise',
              en: 'Generate Analysis',
              es: 'Generar Análisis',
            )),
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

  /// Cabeçalho da análise personalizada — o mesmo para quem lê e para quem
  /// está degustando.
  Widget _buildAISectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🌟', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _sel(
                  pt: 'Sua Análise Personalizada',
                  en: 'Your Personalized Analysis',
                  es: 'Tu Análisis Personalizado',
                ),
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
          _sel(
            pt: 'Gerada especialmente para você com base no seu mapa astral',
            en: 'Created especially for you based on your birth chart',
            es: 'Creada especialmente para ti a partir de tu carta natal',
          ),
          style: TextStyle(
            color: context.gc.softWhite.withValues(alpha: 0.6),
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),
        Divider(color: context.gc.lilac),
        const SizedBox(height: 12),
      ],
    );
  }

  /// Degustação da análise: duas frases verdadeiras sobre o mapa desta
  /// pessoa, no lugar do paywall frio.
  Widget _buildProfileTeaserCard(AstrologyProvider provider) {
    final l10n = AppLocalizations.of(context);
    final sample = _teaser;
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAISectionHeader(),
          if (sample == null) ...[
            Text(
              l10n.profileTeaserIntro,
              style: TextStyle(
                color: context.gc.softWhite.withValues(alpha: 0.75),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: OutlinedButton.icon(
                onPressed:
                    _isTeasing ? null : () => _generateProfileTeaser(provider),
                icon: _isTeasing
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.gc.lilac,
                        ),
                      )
                    : const Icon(Icons.auto_awesome, size: 18),
                label: Text(l10n.profileTeaserPeek),
              ),
            ),
          ] else
            TeaserReveal(
              sample: Text(
                sample,
                style: TextStyle(
                  color: context.gc.softWhite,
                  height: 1.55,
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                ),
              ),
              onCta: _onTeaserCta,
            ),
          _buildTeaserSumario(l10n),
        ],
      ),
    );
  }

  /// O sumário do que a análise completa traz.
  ///
  /// A amostra mostra COMO a análise fala; esta lista mostra DO QUE ela
  /// fala. Sem as duas, a degustação era só um parágrafo bonito seguido de
  /// um borrão: quem lia não fazia ideia do tamanho do que estava atrás do
  /// cadeado — e ninguém compra o que não consegue imaginar.
  Widget _buildTeaserSumario(AppLocalizations l10n) {
    final itens = [
      l10n.profileTeaserItem1,
      l10n.profileTeaserItem2,
      l10n.profileTeaserItem3,
      l10n.profileTeaserItem4,
      l10n.profileTeaserItem5,
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: context.gc.surfaceBorder),
          const SizedBox(height: 10),
          Text(
            l10n.profileTeaserWhatTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: context.gc.lilac,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          for (final item in itens)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lock,
                    size: 15,
                    color: context.gc.textSecondary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: context.gc.softWhite.withValues(alpha: 0.9),
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Text(
            l10n.profileTeaserFooter,
            style: TextStyle(
              color: context.gc.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
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
        color: context.gc.softWhite.withValues(alpha: 0.9),
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
