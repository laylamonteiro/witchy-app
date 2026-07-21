import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../auth/data/models/feature_access.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../data/models/enums.dart';
import '../../data/models/planet_position_model.dart';
import '../providers/astrology_provider.dart';
import 'magical_profile_page.dart';

class BirthChartViewPage extends StatelessWidget {
  const BirthChartViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveAppBarTitle('Seu Mapa Astral'),
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
            tooltip: 'Ver Perfil Mágico',
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
                'Nenhum mapa astral encontrado',
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
                  title: 'Trio Principal',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPlanetRow(
                        context,
                        '☉ Sol',
                        chart.sun.positionString,
                        'Sua essência',
                      ),
                      _buildPlanetRow(
                        context,
                        '☽ Lua',
                        chart.moon.positionString,
                        'Suas emoções',
                      ),
                      if (chart.ascendant != null)
                        _buildPlanetRow(
                          context,
                          '⬆ Ascendente',
                          chart.ascendant!.positionString,
                          'Como você se apresenta',
                        ),
                    ],
                  ),
                  explanation: _TrioPrincipalExplanation(),
                ),

                const SizedBox(height: 16),

                // Planetas Pessoais - CLICÁVEL
                _buildClickableCard(
                  context: context,
                  title: 'Planetas Pessoais',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPlanetRow(
                        context,
                        '☿ Mercúrio',
                        chart.mercury.positionString,
                        'Comunicação',
                      ),
                      _buildPlanetRow(
                        context,
                        '♀ Vênus',
                        chart.venus.positionString,
                        'Amor e beleza',
                      ),
                      _buildPlanetRow(
                        context,
                        '♂ Marte',
                        chart.mars.positionString,
                        'Ação e energia',
                      ),
                    ],
                  ),
                  explanation: _PlanetasPessoaisExplanation(),
                ),

                const SizedBox(height: 16),

                // Planetas Sociais (Júpiter, Saturno) - CLICÁVEL
                _buildClickableCard(
                  context: context,
                  title: 'Planetas Sociais',
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
                  title: 'Planetas Transpessoais',
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
                  title: 'Pontos Astrológicos',
                  content: _buildBodiesList(
                    context,
                    chart.planets,
                    const [Planet.northNode, Planet.southNode],
                  ),
                  explanation: _NodosExplanation(),
                ),

                const SizedBox(height: 16),

                // Casas - CLICÁVEL
                if (!chart.unknownBirthTime)
                  _buildClickableCard(
                    context: context,
                    title: 'Casas Astrológicas',
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
                                      'Casa ${house.number}',
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
                                      'Planetas: ${planetsInHouse.map((p) => p.planet.symbol).join(' ')}',
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
                  title: 'Aspectos Principais',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (chart.aspects.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Nenhum aspecto significativo encontrado',
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
                          label: const Text(
                              'Desbloquear interpretações completas'),
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
                  child: const Text(
                    'Ver Perfil Mágico ✨',
                    style: TextStyle(
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
    final rows = <Widget>[];
    for (final body in bodies) {
      final match = planets.where((p) => p.planet == body);
      if (match.isEmpty) continue;
      final planet = match.first;
      rows.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${planet.planet.symbol} ${planet.planet.displayName}',
              style: TextStyle(
                color: context.gc.softWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(planet.positionString,
                    style: TextStyle(color: context.gc.lilac)),
                Text(
                  'Casa ${planet.houseNumber}',
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
                'Toque para saber mais',
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
                'Guia para Iniciantes',
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
        children: [
          Column(
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

// Widgets de explicação para iniciantes

class _TrioPrincipalExplanation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          context,
          '☉ O Sol - Sua Essência',
          'O Sol representa quem você realmente é no seu núcleo mais profundo. É a sua identidade '
              'fundamental, seus objetivos de vida e como você brilha no mundo.\n\n'
              'Na bruxaria, o Sol representa sua força vital, sua energia criativa e seu propósito mágico. '
              'O signo solar indica que tipo de magia você naturalmente expressa.',
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          '☽ A Lua - Suas Emoções',
          'A Lua governa suas emoções, intuição e mundo interior. Ela revela como você processa '
              'sentimentos, o que precisa para se sentir seguro(a) e suas reações instintivas.\n\n'
              'Para praticantes de magia, a Lua é extremamente importante. Ela indica seus dons intuitivos, '
              'sua conexão com o inconsciente e como você se relaciona com os ciclos lunares.',
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          '⬆ O Ascendente - Sua Máscara',
          'O Ascendente (ou signo nascente) é como você se apresenta ao mundo e as primeiras '
              'impressões que causa. É sua "máscara social" e aparência externa.\n\n'
              'Na prática mágica, o Ascendente influencia como sua energia é percebida pelos outros '
              'e pode indicar que tipo de trabalho mágico você atrai naturalmente.',
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
                '💡 Por que é importante?',
                style: TextStyle(
                  color: context.gc.lilac,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Esses três pontos formam a base da sua personalidade astrológica. '
                'Se você está começando na astrologia, entender seu Sol, Lua e Ascendente '
                'é o primeiro passo para se conhecer através das estrelas.',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Os planetas pessoais são aqueles que se movem rapidamente pelo zodíaco e '
          'influenciam aspectos do dia a dia da sua personalidade.',
          style: TextStyle(
            color: context.gc.softWhite.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          '☿ Mercúrio - Comunicação',
          'Mercúrio governa como você pensa, se comunica e processa informações. '
              'Influencia sua forma de aprender, falar e escrever.\n\n'
              'Na magia: Indica como você lança encantamentos, escreve feitiços e se comunica com o divino.',
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          '♀ Vênus - Amor e Beleza',
          'Vênus rege o amor, relacionamentos, beleza e prazer. Mostra o que você valoriza, '
              'como se relaciona romanticamente e seu senso estético.\n\n'
              'Na magia: Influencia trabalhos de amor (sempre éticos!), prosperidade e beleza do altar.',
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          '♂ Marte - Ação e Energia',
          'Marte representa sua energia de ação, como você luta pelo que quer, sua coragem '
              'e também raiva. É o planeta da iniciativa e determinação.\n\n'
              'Na magia: Indica sua energia protetora, capacidade de banimento e força de vontade mágica.',
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
                '✨ Dica para iniciantes',
                style: TextStyle(
                  color: context.gc.mint,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Esses planetas mudam de signo com frequência, por isso pessoas nascidas no mesmo dia '
                'podem ter posições diferentes. Confira o seu Perfil Mágico para uma análise '
                'personalizada de cada planeta.',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Júpiter e Saturno são os planetas sociais: fazem a ponte entre a sua '
          'personalidade individual e o mundo coletivo — sua relação com a '
          'sociedade, o crescimento, as regras, as responsabilidades e o amadurecimento.',
          style: TextStyle(
            color: context.gc.softWhite.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          '♃ Júpiter - Expansão',
          'Expansão, fé, conhecimento, oportunidades e visão de mundo. Mostra onde '
              'você cresce, confia e encontra facilidade e sorte na vida.',
        ),
        const SizedBox(height: 12),
        _buildSection(
          context,
          '♄ Saturno - Estrutura',
          'Limites, disciplina, dever, medo, estrutura e amadurecimento. Indica onde '
              'você aprende com desafios, assume responsabilidades e constrói solidez.',
        ),
      ],
    );
  }
}

class _PlanetasTranspessoaisExplanation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Urano, Netuno e Plutão são os planetas transpessoais (ou geracionais). '
          'Movem-se lentamente e ficam anos em cada signo, então gerações inteiras '
          'os compartilham — falam de mudanças coletivas, espirituais e profundas.',
          style: TextStyle(
            color: context.gc.softWhite.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          '♅ Urano - Ruptura',
          'Ruptura, liberdade, inovação e revolução. Onde você quebra padrões, '
              'busca autenticidade e abre caminhos novos.',
        ),
        const SizedBox(height: 12),
        _buildSection(
          context,
          '♆ Netuno - Dissolução',
          'Sonhos, espiritualidade, idealização, dissolução e ilusão. Sua conexão '
              'com o transcendente, a imaginação e a compaixão.',
        ),
        const SizedBox(height: 12),
        _buildSection(
          context,
          '♇ Plutão - Transformação',
          'Poder, crise, morte simbólica, transformação e regeneração. Onde você '
              'se reinventa profundamente e renasce.',
        ),
      ],
    );
  }
}

class _NodosExplanation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Os Nodos Lunares não são planetas: são pontos matemáticos formados pelo '
          'cruzamento da órbita da Lua com a trajetória aparente do Sol. Marcam a '
          'direção de desenvolvimento (eixo kármico/evolutivo) e os padrões já conhecidos.',
          style: TextStyle(
            color: context.gc.softWhite.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          '☊ Nodo Norte - Crescimento',
          'Aponta as experiências que exigem crescimento e desenvolvimento — a '
              'direção para onde a sua alma caminha nesta vida.',
        ),
        const SizedBox(height: 12),
        _buildSection(
          context,
          '☋ Nodo Sul - Bagagem',
          'Hábitos, talentos e padrões familiares ou automáticos — o repertório que '
              'você já traz e no qual tende a se acomodar.',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.gc.starYellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.gc.starYellow.withOpacity(0.3)),
          ),
          child: Text(
            '🔭 Existem outros pontos no mapa (Ascendente, Meio do Céu, Lilith, '
            'Parte da Fortuna...) que podem entrar aqui no futuro.',
            style: TextStyle(
              color: context.gc.softWhite.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _CasasExplanation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'As 12 casas astrológicas representam diferentes áreas da sua vida. Cada casa '
          'é governada pelo signo que está na sua cúspide (início).',
          style: TextStyle(
            color: context.gc.softWhite.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildHouseRow(
            context,
            'Casa 1', 'Identidade, aparência física, como você inicia coisas'),
        _buildHouseRow(
            context,
            'Casa 2', 'Recursos, dinheiro, valores pessoais, autoestima'),
        _buildHouseRow(context, 'Casa 3', 'Comunicação, irmãos, vizinhos, pensamento'),
        _buildHouseRow(context, 'Casa 4', 'Lar, família, raízes, vida privada'),
        _buildHouseRow(context, 'Casa 5', 'Criatividade, romance, filhos, diversão'),
        _buildHouseRow(context, 'Casa 6', 'Saúde, rotina, trabalho diário, serviço'),
        _buildHouseRow(context, 'Casa 7', 'Parcerias, casamento, contratos, o outro'),
        _buildHouseRow(
            context,
            'Casa 8', 'Transformação, sexualidade, morte/renascimento, magia'),
        _buildHouseRow(
            context,
            'Casa 9', 'Filosofia, viagens, ensino superior, expansão'),
        _buildHouseRow(
            context,
            'Casa 10', 'Carreira, reputação, status, missão de vida'),
        _buildHouseRow(context, 'Casa 11', 'Amizades, grupos, sonhos, causas sociais'),
        _buildHouseRow(
            context,
            'Casa 12', 'Inconsciente, espiritualidade, karma, retiros'),
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
                '🔮 Casas importantes para bruxaria',
                style: TextStyle(
                  color: context.gc.lilac,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'A Casa 8 (magia, transformação, mistérios) e Casa 12 (espiritualidade, intuição, '
                'conexão com o divino) são especialmente importantes para praticantes de magia. '
                'Veja seu Perfil Mágico para uma análise detalhada dessas casas.',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aspectos são as relações angulares entre os planetas. Eles mostram como as energias '
          'planetárias interagem entre si no seu mapa.',
          style: TextStyle(
            color: context.gc.softWhite.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildAspectType(
          context,
          '☌ Conjunção (0°)',
          'Os planetas estão juntos. Energia intensa e fusionada.',
          context.gc.lilac,
        ),
        _buildAspectType(
          context,
          '⚹ Sextil (60°)',
          'Aspecto harmonioso. Oportunidades e talentos naturais.',
          context.gc.success,
        ),
        _buildAspectType(
          context,
          '□ Quadratura (90°)',
          'Aspecto desafiador. Tensão que gera crescimento.',
          context.gc.alert,
        ),
        _buildAspectType(
          context,
          '△ Trígono (120°)',
          'Aspecto muito harmonioso. Fluxo fácil de energia.',
          context.gc.success,
        ),
        _buildAspectType(
          context,
          '☍ Oposição (180°)',
          'Aspecto desafiador. Polaridade e necessidade de equilíbrio.',
          context.gc.alert,
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
                '💫 Importante saber',
                style: TextStyle(
                  color: context.gc.mint,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aspectos "desafiadores" não são ruins! Eles indicam áreas de crescimento e '
                'potencial. Muitas vezes são onde desenvolvemos nossas maiores forças.\n\n'
                'Na magia, entender seus aspectos ajuda a saber quais energias trabalham '
                'bem juntas e quais precisam de mais atenção nos seus rituais.',
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
