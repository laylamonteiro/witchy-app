import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/models/transit_model.dart';
import '../../data/models/enums.dart';
import '../../data/services/transit_interpreter.dart';

class DailyMagicalWeatherPage extends StatefulWidget {
  const DailyMagicalWeatherPage({super.key});

  @override
  State<DailyMagicalWeatherPage> createState() =>
      _DailyMagicalWeatherPageState();
}

class _DailyMagicalWeatherPageState extends State<DailyMagicalWeatherPage> {
  final TransitInterpreter _interpreter = TransitInterpreter();
  DateTime _selectedDate = DateTime.now();
  DailyMagicalWeather? _weather;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() => _isLoading = true);

    try {
      final weather = await _interpreter.getDailyMagicalWeather(_selectedDate);
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao calcular clima mágico: $e')),
        );
      }
    }
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _weather = null;
    });
    _loadWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima Mágico Diário'),
        backgroundColor: AppColors.darkBackground,
      ),
      backgroundColor: AppColors.darkBackground,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.lilac),
            )
          : _weather == null
              ? const Center(
                  child: Text('Carregando clima mágico...'),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDateSelector(),
                      const SizedBox(height: 16),
                      _buildMoonSection(),
                      const SizedBox(height: 16),
                      _buildEnergySection(),
                      const SizedBox(height: 16),
                      _buildKeywordsSection(),
                      const SizedBox(height: 16),
                      _buildInterpretationSection(),
                      const SizedBox(height: 16),
                      _buildPracticesSection(),
                      const SizedBox(height: 16),
                      _buildTransitsSection(),
                      if (_weather!.aspects.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildAspectsSection(),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildDateSelector() {
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());

    return MagicalCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeDate(-1),
            icon: const Icon(Icons.chevron_left, color: AppColors.lilac),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  isToday ? 'Hoje' : DateFormat('dd/MM/yyyy').format(_selectedDate),
                  style: const TextStyle(
                    color: AppColors.lilac,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isToday)
                  Text(
                    DateFormat('EEEE', 'pt_BR').format(_selectedDate),
                    style: TextStyle(
                      color: AppColors.softWhite.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _changeDate(1),
            icon: const Icon(Icons.chevron_right, color: AppColors.lilac),
          ),
        ],
      ),
    );
  }

  Widget _buildMoonSection() {
    return MagicalCard(
      child: Column(
        children: [
          const Text('🌙', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(
            _weather!.moonPhase,
            style: const TextStyle(
              color: AppColors.lilac,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lua em ${_weather!.moonSign.displayName} ${_weather!.moonSign.symbol}',
            style: TextStyle(
              color: AppColors.softWhite.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _weather!.moonSign.element.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _weather!.moonSign.element.color.withOpacity(0.5),
              ),
            ),
            child: Text(
              _weather!.moonSign.element.displayName,
              style: TextStyle(
                color: _weather!.moonSign.element.color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergySection() {
    final energyIcons = {
      EnergyLevel.intense: '⚡',
      EnergyLevel.challenging: '🔥',
      EnergyLevel.moderate: '💫',
      EnergyLevel.harmonious: '✨',
    };

    final energyColors = {
      EnergyLevel.intense: Colors.purple,
      EnergyLevel.challenging: Colors.orange,
      EnergyLevel.moderate: Colors.blue,
      EnergyLevel.harmonious: Colors.green,
    };

    return MagicalCard(
      child: Column(
        children: [
          Text(
            energyIcons[_weather!.overallEnergy] ?? '✨',
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 12),
          Text(
            'Energia do Dia',
            style: TextStyle(
              color: AppColors.softWhite.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _weather!.overallEnergy.displayName,
            style: TextStyle(
              color: energyColors[_weather!.overallEnergy],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordsSection() {
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Palavras-chave',
            style: TextStyle(
              color: AppColors.lilac,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _weather!.energyKeywords.map((keyword) {
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
                  keyword,
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
    );
  }

  Widget _buildInterpretationSection() {
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📖', style: TextStyle(fontSize: 24)),
              SizedBox(width: 8),
              Text(
                'Interpretação',
                style: TextStyle(
                  color: AppColors.lilac,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _weather!.generalInterpretation,
            style: const TextStyle(
              color: AppColors.softWhite,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticesSection() {
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('✨', style: TextStyle(fontSize: 24)),
              SizedBox(width: 8),
              Text(
                'Práticas Recomendadas',
                style: TextStyle(
                  color: AppColors.lilac,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(_weather!.recommendedPractices.map((practice) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
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
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList()),
        ],
      ),
    );
  }

  Widget _buildTransitsSection() {
    // Mostrar apenas planetas lentos + Lua + Sol
    final importantPlanets = _weather!.transits.where((t) =>
        t.planet == Planet.sun ||
        t.planet == Planet.moon ||
        t.planet == Planet.jupiter ||
        t.planet == Planet.saturn ||
        t.planet == Planet.uranus ||
        t.planet == Planet.neptune ||
        t.planet == Planet.pluto);

    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🪐', style: TextStyle(fontSize: 24)),
              SizedBox(width: 8),
              Text(
                'Trânsitos Planetários',
                style: TextStyle(
                  color: AppColors.lilac,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...importantPlanets.map((transit) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    transit.planet.symbol,
                    style: const TextStyle(
                      color: AppColors.lilac,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      transit.formattedPosition,
                      style: const TextStyle(
                        color: AppColors.softWhite,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (transit.isRetrograde)
                    const Text(
                      'R',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAspectsSection() {
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('⭐', style: TextStyle(fontSize: 24)),
              SizedBox(width: 8),
              Text(
                'Aspectos Significativos',
                style: TextStyle(
                  color: AppColors.lilac,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(_weather!.aspects.take(5).map((aspect) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aspect.description,
                    style: const TextStyle(
                      color: AppColors.lilac,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    aspect.interpretation,
                    style: TextStyle(
                      color: AppColors.softWhite.withOpacity(0.8),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          }).toList()),
        ],
      ),
    );
  }
}
