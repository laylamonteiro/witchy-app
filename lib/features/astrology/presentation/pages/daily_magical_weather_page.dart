import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/models/transit_model.dart';
import '../../data/models/enums.dart';
import '../../data/repositories/daily_weather_repository.dart';

class DailyMagicalWeatherPage extends StatefulWidget {
  const DailyMagicalWeatherPage({super.key});

  @override
  State<DailyMagicalWeatherPage> createState() =>
      _DailyMagicalWeatherPageState();
}

class _DailyMagicalWeatherPageState extends State<DailyMagicalWeatherPage> {
  final DailyWeatherRepository _repository = DailyWeatherRepository();
  DateTime _selectedDate = DateTime.now();
  DailyWeatherCache? _weatherCache;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    print('🌙 DailyMagicalWeatherPage: Iniciando carregamento...');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('📡 DailyMagicalWeatherPage: Chamando getDailyWeather...');
      final cache = await _repository.getDailyWeather(_selectedDate);
      print('✅ DailyMagicalWeatherPage: Recebeu weather cache');

      if (!mounted) {
        print('⚠️ DailyMagicalWeatherPage: Widget não está montado, abortando');
        return;
      }

      print('📊 DailyMagicalWeatherPage: Atualizando estado...');
      setState(() {
        _weatherCache = cache;
        _isLoading = false;
      });
      print('✅ DailyMagicalWeatherPage: Estado atualizado!');
    } catch (e, stackTrace) {
      print('❌ DailyMagicalWeatherPage: ERRO ao calcular clima mágico: $e');
      print('📋 Stack trace: $stackTrace');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = 'Erro ao carregar clima mágico. Tente novamente.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao calcular clima mágico. Por favor, tente novamente.'),
          backgroundColor: AppColors.alert,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima Mágico Diário'),
        backgroundColor: AppColors.darkBackground,
        actions: [
          if (_weatherCache != null)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showInfoDialog(),
              tooltip: 'Sobre o clima mágico',
            ),
        ],
      ),
      backgroundColor: AppColors.darkBackground,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.lilac),
            const SizedBox(height: 24),
            Text(
              'Consultando as estrelas...',
              style: GoogleFonts.cinzelDecorative(
                fontSize: 18,
                color: AppColors.lilac,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'O Conselheiro Místico está analisando os trânsitos de hoje',
              style: TextStyle(
                color: AppColors.softWhite.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.alert, size: 48),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.softWhite),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadWeather,
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

    if (_weatherCache == null) {
      return const Center(
        child: Text(
          'Carregando clima mágico...',
          style: TextStyle(color: AppColors.softWhite),
        ),
      );
    }

    final weather = _weatherCache!.weatherData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateSection(),
          const SizedBox(height: 16),
          _buildMoonSection(weather),
          const SizedBox(height: 16),
          _buildEnergySection(weather),
          const SizedBox(height: 16),
          _buildKeywordsSection(weather),
          const SizedBox(height: 24),
          _buildAIInterpretationSection(),
          const SizedBox(height: 16),
          _buildTransitsSection(weather),
          if (weather.aspects.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildAspectsSection(weather),
          ],
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return MagicalCard(
      child: Column(
        children: [
          const Text('🌟', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            'Hoje',
            style: GoogleFonts.cinzelDecorative(
              fontSize: 24,
              color: AppColors.lilac,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('dd/MM/yyyy - EEEE', 'pt_BR').format(DateTime.now()),
            style: TextStyle(
              color: AppColors.softWhite.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoonSection(DailyMagicalWeather weather) {
    return MagicalCard(
      child: Column(
        children: [
          const Text('🌙', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(
            weather.moonPhase,
            style: GoogleFonts.cinzelDecorative(
              fontSize: 24,
              color: AppColors.lilac,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lua em ${weather.moonSign.displayName} ${weather.moonSign.symbol}',
            style: TextStyle(
              color: AppColors.softWhite.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: weather.moonSign.element.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: weather.moonSign.element.color.withOpacity(0.5),
              ),
            ),
            child: Text(
              weather.moonSign.element.displayName,
              style: TextStyle(
                color: weather.moonSign.element.color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergySection(DailyMagicalWeather weather) {
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
            energyIcons[weather.overallEnergy] ?? '✨',
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
            weather.overallEnergy.displayName,
            style: TextStyle(
              color: energyColors[weather.overallEnergy],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordsSection(DailyMagicalWeather weather) {
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
            children: weather.energyKeywords.map((keyword) {
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

  Widget _buildAIInterpretationSection() {
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                'Previsão Mágica do Dia',
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
            'Criada pelo Conselheiro Místico baseada nos trânsitos astrológicos',
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
            data: _weatherCache!.aiGeneratedText,
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

  Widget _buildTransitsSection(DailyMagicalWeather weather) {
    // Mostrar apenas planetas lentos + Lua + Sol
    final importantPlanets = weather.transits.where((t) =>
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
          }),
        ],
      ),
    );
  }

  Widget _buildAspectsSection(DailyMagicalWeather weather) {
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
          ...(weather.aspects.take(5).map((aspect) {
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
          })),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Sobre o Clima Mágico',
          style: GoogleFonts.cinzelDecorative(
            color: AppColors.lilac,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O Clima Mágico é calculado diariamente com base nos trânsitos planetários reais e interpretado pelo Conselheiro Místico para práticas mágicas.',
              style: TextStyle(
                color: AppColors.softWhite.withOpacity(0.9),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'A previsão é gerada uma vez por dia às 00h e permanece a mesma até a meia-noite seguinte.',
              style: TextStyle(
                color: AppColors.softWhite.withOpacity(0.7),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Entendi',
              style: TextStyle(color: AppColors.lilac),
            ),
          ),
        ],
      ),
    );
  }
}
