import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../auth/data/models/feature_access.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../data/data_sources/birth_chart_content.dart';
import '../../data/models/enums.dart';
import '../../data/models/planet_position_model.dart';
import '../providers/astrology_provider.dart';
import 'magical_profile_page.dart';

class BirthChartViewPage extends StatelessWidget {
  const BirthChartViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final content = birthChartContent;
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).chartYourChart),
        backgroundColor: context.gc.darkBackground,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MagicalProfilePage(),
                ),
              );
            },
            tooltip: content.ui['viewMagicalProfileTooltip'],
          ),
        ],
      ),
      backgroundColor: context.gc.darkBackground,
      body: Consumer<AstrologyProvider>(
        builder: (context, provider, _) {
          final chart = provider.birthChart;

          if (chart == null) {
            return Center(
              child: Text(
                content.ui['noChartFound']!,
                style: TextStyle(color: context.gc.softWhite),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Informações de nascimento
                MagicalCard(
                  child: Column(
                    children: [
                      const Text('🌟', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      Text(
                        chart.birthPlace,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: context.gc.lilac,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('dd/MM/yyyy').format(chart.birthDate),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: context.gc.softWhite,
                            ),
                      ),
                      if (!chart.unknownBirthTime)
                        Text(
                          chart.birthTime.format(context),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: context.gc.softWhite,
                                  ),
                        ),
                      if (chart.timezone.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.schedule,
                                size: 14, color: context.gc.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              chart.timezone,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: context.gc.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Sol, Lua e Ascendente - CLICÁVEL
                _buildClickableCard(
                  context: context,
                  title: content.ui['sectionMainTrio']!,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPlanetRow(
                        context,
                        '${Planet.sun.symbol} ${Planet.sun.displayName}',
                        chart.sun.positionString,
                        content.planetRowMeanings[Planet.sun]!,
                      ),
                      _buildPlanetRow(
                        context,
                        '${Planet.moon.symbol} ${Planet.moon.displayName}',
                        chart.moon.positionString,
                        content.planetRowMeanings[Planet.moon]!,
                      ),
                      if (chart.ascendant != null)
                        _buildPlanetRow(
                          context,
                          '⬆ ${content.ui['ascendant']}',
                          chart.ascendant!.positionString,
                          content.ui['ascendantMeaning']!,
                        ),
                    ],
                  ),
                  explanation: _TrioPrincipalExplanation(),
                ),

                const SizedBox(height: 16),

                // Planetas Pessoais - CLICÁVEL
                _buildClickableCard(
                  context: context,
                  title: content.ui['sectionPersonalPlanets']!,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPlanetRow(
                        context,
                        '${Planet.mercury.symbol} ${Planet.mercury.displayName}',
                        chart.mercury.positionString,
                        content.planetRowMeanings[Planet.mercury]!,
                      ),
                      _buildPlanetRow(
                        context,
                        '${Planet.venus.symbol} ${Planet.venus.displayName}',
                        chart.venus.positionString,
                        content.planetRowMeanings[Planet.venus]!,
                      ),
                      _buildPlanetRow(
                        context,
                        '${Planet.mars.symbol} ${Planet.mars.displayName}',
                        chart.mars.positionString,
                        content.planetRowMeanings[Planet.mars]!,
                      ),
                    ],
                  ),
                  explanation: _PlanetasPessoaisExplanation(),
                ),

                const SizedBox(height: 16),

                // Planetas Sociais (Júpiter, Saturno) - CLICÁVEL
                _buildClickableCard(
                  context: context,
                  title: content.ui['sectionSocialPlanets']!,
                  content: _buildBodiesList(
                    context,
                    chart.planets,
                    const [Planet.jupiter, Planet.saturn],
                  ),
                  explanation: _PlanetasSociaisExplanation(),
                ),

                const SizedBox(height: 16),

                // Planetas Transpessoais (Urano, Netuno, Plutão) - CLICÁVEL
                _buildClickableCard(
                  context: context,
                  title: content.ui['sectionTranspersonalPlanets']!,
                  content: _buildBodiesList(
                    context,
                    chart.planets,
                    const [Planet.uranus, Planet.neptune, Planet.pluto],
                  ),
                  explanation: _PlanetasTranspessoaisExplanation(),
                ),

                const SizedBox(height: 16),

                // Pontos Astrológicos / Nodos - CLICÁVEL
                _buildClickableCard(
                  context: context,
                  title: content.ui['sectionAstroPoints']!,
                  content: _buildBodiesList(
                    context,
                    chart.planets,
                    const [
                      Planet.midheaven,
                      Planet.imumCoeli,
                      Planet.descendant,
                      Planet.vertex,
                      Planet.lilith,
                      Planet.partOfFortune,
                      Planet.northNode,
                      Planet.southNode,
                    ],
                  ),
                  explanation: _NodosExplanation(),
                ),

                const SizedBox(height: 16),

                // Casas - CLICÁVEL
                if (!chart.unknownBirthTime)
                  _buildClickableCard(
                    context: context,
                    title: content.ui['sectionHouses']!,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...chart.houses.map((house) {
                          final planetsInHouse =
                              chart.getPlanetsInHouse(house.number);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${content.ui['houseWord']} ${house.number}',
                                      style: TextStyle(
                                        color: context.gc.softWhite,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      house.cuspString,
                                      style: TextStyle(
                                        color: context.gc.lilac,
                                      ),
                                    ),
                                  ],
                                ),
                                if (planetsInHouse.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '${content.ui['planetsInHousePrefix']} ${planetsInHouse.map((p) => p.planet.symbol).join(' ')}',
                                      style: TextStyle(
                                        color: context.gc.softWhite
                                            .withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                    explanation: _CasasExplanation(),
                  ),

                const SizedBox(height: 16),

                // Aspectos - CLICÁVEL
                _buildClickableCard(
                  context: context,
                  title: content.ui['sectionAspects']!,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (chart.aspects.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            content.ui['noAspects']!,
                            style: TextStyle(color: context.gc.softWhite),
                          ),
                        )
                      else
                        ...chart.aspects.take(10).map((aspect) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  aspect.description,
                                  style: TextStyle(
                                    color: aspect.type.isHarmonious
                                        ? context.gc.success
                                        : aspect.type.isChallenging
                                            ? context.gc.alert
                                            : context.gc.softWhite,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Interpretação é conteúdo Premium
                                // (fail-closed: free vê placeholder desfocado)
                                PremiumBlurText(
                                  text: aspect.interpretation,
                                  feature: AppFeature.astrologyBirthChart,
                                  maxLines: 3,
                                  style: TextStyle(
                                    color: context.gc.softWhite.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                  explanation: _AspectosExplanation(),
                ),

                const SizedBox(height: 24),

                // Banner premium para usuários free (interpretações completas)
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    if (authProvider.isPremiumEffective) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Center(
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
                          label: Text(content.ui['unlockFullInterpretations']!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9C27B0),
                            foregroundColor: context.gc.textPrimary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Botão para ver perfil mágico
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MagicalProfilePage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.gc.lilac,
                    foregroundColor: context.gc.darkBackground,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    content.ui['viewMagicalProfileButton']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Lista de corpos (na ordem pedida) com posição e casa, para os cards de
  /// categoria de planetas.
  Widget _buildBodiesList(
    BuildContext context,
    List<PlanetPosition> planets,
    List<Planet> bodies,
  ) {
    final houseWord = birthChartContent.ui['houseWord']!;
    final rows = <Widget>[];
    for (final body in bodies) {
      final match = planets.where((p) => p.planet == body);
      if (match.isEmpty) continue;
      final planet = match.first;
      rows.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                '${planet.planet.symbol} ${planet.planet.displayName}',
                style: TextStyle(
                  color: context.gc.softWhite,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(planet.positionString,
                    style: TextStyle(color: context.gc.lilac)),
                Text(
                  '$houseWord ${planet.houseNumber}',
                  style: TextStyle(
                    color: context.gc.softWhite.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }

  Widget _buildClickableCard({
    required BuildContext context,
    required String title,
    required Widget content,
    required Widget explanation,
  }) {
    return GestureDetector(
      onTap: () => _showExplanationDialog(context, title, explanation),
      child: MagicalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: context.gc.lilac,
                      ),
                ),
                Icon(
                  Icons.info_outline,
                  color: context.gc.lilac.withOpacity(0.6),
                  size: 20,
                ),
              ],
            ),
            Divider(color: context.gc.lilac),
            content,
            const SizedBox(height: 8),
            Center(
              child: Text(
                birthChartContent.ui['tapToLearnMore']!,
                style: TextStyle(
                  color: context.gc.lilac.withOpacity(0.5),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExplanationDialog(
      BuildContext context, String title, Widget content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.gc.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.gc.lilac.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: GoogleFonts.cinzelDecorative(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: context.gc.lilac,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                birthChartContent.ui['beginnersGuide']!,
                style: TextStyle(
                  color: context.gc.softWhite.withOpacity(0.6),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Divider(color: context.gc.lilac),
              const SizedBox(height: 16),
              content,
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanetRow(BuildContext context, String planet, String position, String meaning) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planet,
                  style: TextStyle(
                    color: context.gc.softWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  meaning,
                  style: TextStyle(
                    color: context.gc.softWhite.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            position,
            style: TextStyle(
              color: context.gc.lilac,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Widgets de explicação para iniciantes (conteúdo localizado via
// birthChartContent / ContentLocale).

class _TrioPrincipalExplanation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final content = birthChartContent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final section in content.trioSections) ...[
          _buildSection(context, section.title, section.body),
          const SizedBox(height: 16),
        ],
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.gc.lilac.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.gc.lilac.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content.trioTip.title,
                style: TextStyle(
                  color: context.gc.lilac,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content.trioTip.body,
                style: TextStyle(
                  color: context.gc.softWhite.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanetasPessoaisExplanation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final content = birthChartContent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          content.personalIntro,
          style: TextStyle(
            color: context.gc.softWhite.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        for (final section in content.personalSections) ...[
          _buildSection(context, section.title, section.body),
          const SizedBox(height: 16),
        ],
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.gc.mint.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.gc.mint.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content.personalTip.title,
                style: TextStyle(
                  color: context.gc.mint,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content.personalTip.body,
                style: TextStyle(
                  color: context.gc.softWhite.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanetasSociaisExplanation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final content = birthChartContent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          content.socialIntro,
          style: TextStyle(
            color: context.gc.softWhite.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < content.socialSections.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _buildSection(
            context,
            content.socialSections[i].title,
            content.socialSections[i].body,
          ),
        ],
      ],
    );
  }
}

class _PlanetasTranspessoaisExplanation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final content = birthChartContent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          content.transpersonalIntro,
          style: TextStyle(
            color: context.gc.softWhite.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < content.transpersonalSections.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _buildSection(
            context,
            content.transpersonalSections[i].title,
            content.transpersonalSections[i].body,
          ),
        ],
      ],
    );
  }
}

class _NodosExplanation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final content = birthChartContent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          content.pointsIntro,
          style: TextStyle(
            color: context.gc.softWhite.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < content.pointsSections.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _buildSection(
            context,
            content.pointsSections[i].title,
            content.pointsSections[i].body,
          ),
        ],
      ],
    );
  }
}

class _CasasExplanation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final content = birthChartContent;
    final houseWord = content.ui['houseWord']!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          content.housesIntro,
          style: TextStyle(
            color: context.gc.softWhite.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        for (var n = 1; n <= 12; n++)
          _buildHouseRow(
            context,
            '$houseWord $n',
            content.houseMeanings[n]!,
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.gc.lilac.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.gc.lilac.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content.housesTip.title,
                style: TextStyle(
                  color: context.gc.lilac,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content.housesTip.body,
                style: TextStyle(
                  color: context.gc.softWhite.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHouseRow(BuildContext context, String house, String meaning) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              house,
              style: TextStyle(
                color: context.gc.lilac,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              meaning,
              style: TextStyle(
                color: context.gc.softWhite.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AspectosExplanation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final content = birthChartContent;

    Color colorFor(AspectType type) {
      if (type.isHarmonious) return context.gc.success;
      if (type.isChallenging) return context.gc.alert;
      return context.gc.lilac;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          content.aspectsIntro,
          style: TextStyle(
            color: context.gc.softWhite.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        for (final type in AspectType.values)
          _buildAspectType(
            context,
            '${type.symbol} ${type.displayName} (${type.angle.toInt()}°)',
            content.aspectTypeMeanings[type]!,
            colorFor(type),
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.gc.mint.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.gc.mint.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content.aspectsTip.title,
                style: TextStyle(
                  color: context.gc.mint,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content.aspectsTip.body,
                style: TextStyle(
                  color: context.gc.softWhite.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAspectType(BuildContext context, String name, String meaning, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  meaning,
                  style: TextStyle(
                    color: context.gc.softWhite.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildSection(BuildContext context, String title, String content) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: GoogleFonts.cinzelDecorative(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: context.gc.lilac,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        content,
        style: TextStyle(
          color: context.gc.softWhite.withOpacity(0.9),
          height: 1.6,
        ),
      ),
    ],
  );
}
