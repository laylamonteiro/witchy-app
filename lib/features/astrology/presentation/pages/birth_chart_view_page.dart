import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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

                // Sol, Lua e Ascendente
                MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trio Principal',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.lilac,
                            ),
                      ),
                      const Divider(color: AppColors.lilac),
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
                ),

                const SizedBox(height: 16),

                // Planetas Pessoais
                MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Planetas Pessoais',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.lilac,
                            ),
                      ),
                      const Divider(color: AppColors.lilac),
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
                ),

                const SizedBox(height: 16),

                // Todos os Planetas
                MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Todos os Planetas',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.lilac,
                            ),
                      ),
                      const Divider(color: AppColors.lilac),
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
                      }).toList(),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Casas
                if (!chart.unknownBirthTime)
                  MagicalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Casas Astrológicas',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.lilac,
                              ),
                        ),
                        const Divider(color: AppColors.lilac),
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
                        }).toList(),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Aspectos
                MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aspectos Principais',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.lilac,
                            ),
                      ),
                      const Divider(color: AppColors.lilac),
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
                        }).toList(),
                    ],
                  ),
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
