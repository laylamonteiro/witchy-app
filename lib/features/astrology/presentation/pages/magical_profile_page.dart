import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/content/content_locale.dart';
import '../../../../core/offers/offer_engine.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/premium_locked_preview.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../providers/astrology_provider.dart';
import 'magical_profile_section_page.dart';
import '../../data/models/enums.dart';
import '../../data/models/magical_profile_report.dart';
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

  OfferEngine? _engine;

  @override
  void initState() {
    super.initState();
    _prepareOfferEngine();
  }

  Future<void> _prepareOfferEngine() async {
    final engine = await OfferEngine.load();
    if (!mounted) return;
    setState(() => _engine = engine);
    engine.recordWallExposure(_teaserSlot);
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
      ),
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
            // Sem o glifo do signo ao lado do nome: em muitos aparelhos ele
            // vira um emoji colorido em caixa, que destoa do resto da linha.
            Text(
              sign.displayName,
              style: TextStyle(
                color: context.gc.lilac,
                fontWeight: FontWeight.bold,
              ),
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

  /// A Análise Personalizada: dez cards, tecidos um a um.
  Widget _buildAISection(AstrologyProvider provider, bool hasFullAccess) {
    // Sem acesso, a análise nem chega a ser gerada (o gate está no
    // provider). O que esta pessoa vê são os títulos do que existe atrás do
    // cadeado.
    if (!hasFullAccess) return _buildProfileTeaserCard();

    // Perfil do formato antigo: veio inteiro numa geração só, com os
    // títulos escritos no próprio texto. Continua abrindo como está.
    final antigas = provider.profileSections
        .where((secao) => secao.key == null)
        .toList();
    if (antigas.isNotEmpty) return _buildAnaliseEmCards(antigas);

    return _buildAnaliseEmCards(null);
  }

  /// A análise como uma lista de cards — um por tema, cada um abrindo uma
  /// leitura que desliza.
  ///
  /// Era um markdown corrido de doze seções numa tela só: quem abria via uma
  /// parede de texto e rolava até o fim sem ler. Card com título, uma linha
  /// dizendo do que ele trata e uma seta é um convite; a parede não era.
  Widget _buildAnaliseEmCards(List<ProfileSection>? antigas) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MagicalCard(child: _buildAISectionHeader()),
        if (antigas != null)
          for (final secao in antigas)
            _buildSectionCard(l10n, chave: null, secao: secao)
        else
          for (final chave in MagicalProfileSections.ordered)
            _buildSectionCard(l10n, chave: chave),
      ],
    );
  }

  /// Um card por tema. Com [chave], ele abre a leitura e tece a seção se
  /// ainda não existir; sem ela (perfil antigo), só abre o que já está lá.
  Widget _buildSectionCard(
    AppLocalizations l10n, {
    required String? chave,
    ProfileSection? secao,
  }) {
    final rotulo = profileSectionLabel(l10n, chave ?? secao?.key);
    final titulo = rotulo?.title ?? secao?.legacyTitle ?? '';
    if (titulo.isEmpty) return const SizedBox.shrink();

    // O Consumer acima já escuta o provider: ler aqui não perde rebuild.
    final guardada =
        secao ?? (chave == null ? null : context.read<AstrologyProvider>().profileSection(chave));
    final tecida = guardada != null;

    return MagicalCard(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MagicalProfileSectionPage(
            title: titulo,
            sectionKey: chave,
            section: guardada,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.gc.lilac,
                  ),
                ),
                if (rotulo != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    rotulo.subtitle,
                    style: TextStyle(
                      color: context.gc.textSecondary,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
                if (chave != null && !tecida) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.profileSectionUnread,
                    style: TextStyle(
                      color: context.gc.lilac.withValues(alpha: 0.75),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.gc.lilac.withValues(alpha: 0.18),
            ),
            child: Icon(
              tecida ? Icons.arrow_outward : Icons.auto_awesome,
              size: 18,
              color: context.gc.lilac,
            ),
          ),
        ],
      ),
    );
  }

  /// Cabeçalho da análise personalizada — o mesmo para quem lê e para quem
  /// está vendo só os títulos.
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
      ],
    );
  }

  /// O que a análise completa traria — os títulos à vista, o texto sob véu.
  ///
  /// Não gera nada: os títulos são fixos, do l10n, e o conteúdo verdadeiro
  /// nem chega a ser pedido para quem não tem acesso.
  Widget _buildProfileTeaserCard() {
    final l10n = AppLocalizations.of(context);
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAISectionHeader(),
          PremiumLockedPreview(
            titles: [
              for (final chave in MagicalProfileSections.ordered)
                profileSectionLabel(l10n, chave)!.title,
            ],
            linesPerSection: 1,
            onCta: _onTeaserCta,
          ),
        ],
      ),
    );
  }
}
