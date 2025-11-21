import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/astrology_provider.dart';
import 'magical_profile_page.dart';

class BirthChartViewPage extends StatelessWidget {
  const BirthChartViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seu Mapa Astral'),
        backgroundColor: AppColors.darkBackground,
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
      backgroundColor: AppColors.darkBackground,
      body: Consumer<AstrologyProvider>(
        builder: (context, provider, _) {
          final chart = provider.birthChart;

          if (chart == null) {
            return const Center(
              child: Text(
                'Nenhum mapa astral encontrado',
                style: TextStyle(color: AppColors.softWhite),
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
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.lilac,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('dd/MM/yyyy').format(chart.birthDate),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.softWhite,
                            ),
                      ),
                      if (!chart.unknownBirthTime)
                        Text(
                          chart.birthTime.format(context),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.softWhite,
                              ),
                        ),
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
                        '☉ Sol',
                        chart.sun.positionString,
                        'Sua essência',
                      ),
                      _buildPlanetRow(
                        '☽ Lua',
                        chart.moon.positionString,
                        'Suas emoções',
                      ),
                      if (chart.ascendant != null)
                        _buildPlanetRow(
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
                        '☿ Mercúrio',
                        chart.mercury.positionString,
                        'Comunicação',
                      ),
                      _buildPlanetRow(
                        '♀ Vênus',
                        chart.venus.positionString,
                        'Amor e beleza',
                      ),
                      _buildPlanetRow(
                        '♂ Marte',
                        chart.mars.positionString,
                        'Ação e energia',
                      ),
                    ],
                  ),
                  explanation: _PlanetasPessoaisExplanation(),
                ),

                const SizedBox(height: 16),

                // Todos os Planetas - CLICÁVEL
                _buildClickableCard(
                  context: context,
                  title: 'Todos os Planetas',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...chart.planets.map((planet) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${planet.planet.symbol} ${planet.planet.displayName}',
                                style: const TextStyle(
                                  color: AppColors.softWhite,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    planet.positionString,
                                    style: const TextStyle(
                                      color: AppColors.lilac,
                                    ),
                                  ),
                                  Text(
                                    'Casa ${planet.houseNumber}',
                                    style: TextStyle(
                                      color: AppColors.softWhite.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                  explanation: _TodosPlanetasExplanation(),
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
                          final planetsInHouse = chart.getPlanetsInHouse(house.number);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Casa ${house.number}',
                                      style: const TextStyle(
                                        color: AppColors.softWhite,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      house.cuspString,
                                      style: const TextStyle(
                                        color: AppColors.lilac,
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
                                        color: AppColors.softWhite.withOpacity(0.6),
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
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Nenhum aspecto significativo encontrado',
                            style: TextStyle(color: AppColors.softWhite),
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
                                        ? AppColors.success
                                        : aspect.type.isChallenging
                                            ? AppColors.alert
                                            : AppColors.softWhite,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  aspect.interpretation,
                                  style: TextStyle(
                                    color: AppColors.softWhite.withOpacity(0.7),
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
                    backgroundColor: AppColors.lilac,
                    foregroundColor: AppColors.darkBackground,
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
                        color: AppColors.lilac,
                      ),
                ),
                Icon(
                  Icons.info_outline,
                  color: AppColors.lilac.withOpacity(0.6),
                  size: 20,
                ),
              ],
            ),
            const Divider(color: AppColors.lilac),
            content,
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Toque para saber mais',
                style: TextStyle(
                  color: AppColors.lilac.withOpacity(0.5),
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

  void _showExplanationDialog(BuildContext context, String title, Widget content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
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
                    color: AppColors.lilac.withOpacity(0.3),
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
                  color: AppColors.lilac,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Guia para Iniciantes',
                style: TextStyle(
                  color: AppColors.softWhite.withOpacity(0.6),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Divider(color: AppColors.lilac),
              const SizedBox(height: 16),
              content,
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanetRow(String planet, String position, String meaning) {
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
                style: const TextStyle(
                  color: AppColors.softWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                meaning,
                style: TextStyle(
                  color: AppColors.softWhite.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            position,
            style: const TextStyle(
              color: AppColors.lilac,
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
          '☉ O Sol - Sua Essência',
          'O Sol representa quem você realmente é no seu núcleo mais profundo. É a sua identidade '
          'fundamental, seus objetivos de vida e como você brilha no mundo.\n\n'
          'Na bruxaria, o Sol representa sua força vital, sua energia criativa e seu propósito mágico. '
          'O signo solar indica que tipo de magia você naturalmente expressa.',
        ),
        const SizedBox(height: 16),
        _buildSection(
          '☽ A Lua - Suas Emoções',
          'A Lua governa suas emoções, intuição e mundo interior. Ela revela como você processa '
          'sentimentos, o que precisa para se sentir seguro(a) e suas reações instintivas.\n\n'
          'Para praticantes de magia, a Lua é extremamente importante. Ela indica seus dons intuitivos, '
          'sua conexão com o inconsciente e como você se relaciona com os ciclos lunares.',
        ),
        const SizedBox(height: 16),
        _buildSection(
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
            color: AppColors.lilac.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.lilac.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '💡 Por que é importante?',
                style: TextStyle(
                  color: AppColors.lilac,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Esses três pontos formam a base da sua personalidade astrológica. '
                'Se você está começando na astrologia, entender seu Sol, Lua e Ascendente '
                'é o primeiro passo para se conhecer através das estrelas.',
                style: TextStyle(
                  color: AppColors.softWhite.withOpacity(0.8),
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
            color: AppColors.softWhite.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildSection(
          '☿ Mercúrio - Comunicação',
          'Mercúrio governa como você pensa, se comunica e processa informações. '
          'Influencia sua forma de aprender, falar e escrever.\n\n'
          'Na magia: Indica como você lança encantamentos, escreve feitiços e se comunica com o divino.',
        ),
        const SizedBox(height: 16),
        _buildSection(
          '♀ Vênus - Amor e Beleza',
          'Vênus rege o amor, relacionamentos, beleza e prazer. Mostra o que você valoriza, '
          'como se relaciona romanticamente e seu senso estético.\n\n'
          'Na magia: Influencia trabalhos de amor (sempre éticos!), prosperidade e beleza do altar.',
        ),
        const SizedBox(height: 16),
        _buildSection(
          '♂ Marte - Ação e Energia',
          'Marte representa sua energia de ação, como você luta pelo que quer, sua coragem '
          'e também raiva. É o planeta da iniciativa e determinação.\n\n'
          'Na magia: Indica sua energia protetora, capacidade de banimento e força de vontade mágica.',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.mint.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.mint.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '✨ Dica para iniciantes',
                style: TextStyle(
                  color: AppColors.mint,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Esses planetas mudam de signo com frequência, por isso pessoas nascidas no mesmo dia '
                'podem ter posições diferentes. Confira o seu Perfil Mágico para uma análise '
                'personalizada de cada planeta.',
                style: TextStyle(
                  color: AppColors.softWhite.withOpacity(0.8),
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

class _TodosPlanetasExplanation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Além dos planetas pessoais, existem planetas sociais e geracionais que '
          'influenciam aspectos mais amplos da sua vida.',
          style: TextStyle(
            color: AppColors.softWhite.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildSection(
          '♃ Júpiter - Expansão',
          'Planeta da sorte, crescimento e abundância. Mostra onde você tem facilidade na vida.',
        ),
        const SizedBox(height: 12),
        _buildSection(
          '♄ Saturno - Estrutura',
          'Planeta das lições, responsabilidade e maturidade. Indica onde você enfrenta desafios para crescer.',
        ),
        const SizedBox(height: 12),
        _buildSection(
          '♅ Urano - Revolução',
          'Planeta da inovação, mudança súbita e originalidade. Mostra onde você quebra padrões.',
        ),
        const SizedBox(height: 12),
        _buildSection(
          '♆ Netuno - Espiritualidade',
          'Planeta dos sonhos, intuição e transcendência. Indica sua conexão espiritual.',
        ),
        const SizedBox(height: 12),
        _buildSection(
          '♇ Plutão - Transformação',
          'Planeta do poder, morte e renascimento. Mostra onde você passa por transformações profundas.',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.starYellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.starYellow.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📚 O que significa "Casa"?',
                style: TextStyle(
                  color: AppColors.starYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cada planeta está posicionado em um signo E em uma casa. O signo mostra COMO '
                'a energia se expressa, a casa mostra ONDE na sua vida ela atua.',
                style: TextStyle(
                  color: AppColors.softWhite.withOpacity(0.8),
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
            color: AppColors.softWhite.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildHouseRow('Casa 1', 'Identidade, aparência física, como você inicia coisas'),
        _buildHouseRow('Casa 2', 'Recursos, dinheiro, valores pessoais, autoestima'),
        _buildHouseRow('Casa 3', 'Comunicação, irmãos, vizinhos, pensamento'),
        _buildHouseRow('Casa 4', 'Lar, família, raízes, vida privada'),
        _buildHouseRow('Casa 5', 'Criatividade, romance, filhos, diversão'),
        _buildHouseRow('Casa 6', 'Saúde, rotina, trabalho diário, serviço'),
        _buildHouseRow('Casa 7', 'Parcerias, casamento, contratos, o outro'),
        _buildHouseRow('Casa 8', 'Transformação, sexualidade, morte/renascimento, magia'),
        _buildHouseRow('Casa 9', 'Filosofia, viagens, ensino superior, expansão'),
        _buildHouseRow('Casa 10', 'Carreira, reputação, status, missão de vida'),
        _buildHouseRow('Casa 11', 'Amizades, grupos, sonhos, causas sociais'),
        _buildHouseRow('Casa 12', 'Inconsciente, espiritualidade, karma, retiros'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.lilac.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.lilac.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🔮 Casas importantes para bruxaria',
                style: TextStyle(
                  color: AppColors.lilac,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'A Casa 8 (magia, transformação, mistérios) e Casa 12 (espiritualidade, intuição, '
                'conexão com o divino) são especialmente importantes para praticantes de magia. '
                'Veja seu Perfil Mágico para uma análise detalhada dessas casas.',
                style: TextStyle(
                  color: AppColors.softWhite.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHouseRow(String house, String meaning) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              house,
              style: const TextStyle(
                color: AppColors.lilac,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              meaning,
              style: TextStyle(
                color: AppColors.softWhite.withOpacity(0.8),
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
            color: AppColors.softWhite.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildAspectType(
          '☌ Conjunção (0°)',
          'Os planetas estão juntos. Energia intensa e fusionada.',
          AppColors.lilac,
        ),
        _buildAspectType(
          '⚹ Sextil (60°)',
          'Aspecto harmonioso. Oportunidades e talentos naturais.',
          AppColors.success,
        ),
        _buildAspectType(
          '□ Quadratura (90°)',
          'Aspecto desafiador. Tensão que gera crescimento.',
          AppColors.alert,
        ),
        _buildAspectType(
          '△ Trígono (120°)',
          'Aspecto muito harmonioso. Fluxo fácil de energia.',
          AppColors.success,
        ),
        _buildAspectType(
          '☍ Oposição (180°)',
          'Aspecto desafiador. Polaridade e necessidade de equilíbrio.',
          AppColors.alert,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.mint.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.mint.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '💫 Importante saber',
                style: TextStyle(
                  color: AppColors.mint,
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
                  color: AppColors.softWhite.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAspectType(String name, String meaning, Color color) {
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
                    color: AppColors.softWhite.withOpacity(0.8),
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

Widget _buildSection(String title, String content) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: GoogleFonts.cinzelDecorative(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.lilac,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        content,
        style: TextStyle(
          color: AppColors.softWhite.withOpacity(0.9),
          height: 1.6,
        ),
      ),
    ],
  );
}
