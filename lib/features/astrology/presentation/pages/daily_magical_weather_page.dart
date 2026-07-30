import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/data_sources/daily_weather_content.dart';
import '../../data/models/transit_model.dart';
import '../../data/models/enums.dart';
import '../../data/repositories/daily_weather_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../providers/astrology_provider.dart';
import 'personalized_suggestions_page.dart';

/// Extrai somente a estrutura editorial da previsão. O texto Premium não é
/// exposto ao usuário Free, mas os assuntos continuam legíveis.
class DailyForecastPreview {
  static List<String> get fallbackHeadings =>
      DailyWeatherContent.fallbackHeadings;

  static List<String> headingsFromMarkdown(String markdown) {
    final heading = RegExp(r'^\s{0,3}#{1,6}\s+(.+?)\s*#*\s*$');
    final result = <String>[];
    for (final line in markdown.split('\n')) {
      final match = heading.firstMatch(line);
      final value = match?.group(1)?.trim();
      if (value != null && value.isNotEmpty && !result.contains(value)) {
        result.add(value);
      }
    }
    return result.isEmpty ? fallbackHeadings : result;
  }
}

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
      final cache = await _repository.getDailyWeather(
        _selectedDate,
        userId: context.read<AuthProvider>().currentUser.id,
        natalChart: context.read<AstrologyProvider>().birthChart,
      );
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
        SnackBar(
          content: Text(
              'Erro ao calcular clima mágico. Por favor, tente novamente.'),
          backgroundColor: context.gc.alert,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveAppBarTitle(
          'Clima Mágico Diário',
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: context.gc.darkBackground,
        actions: [
          if (_weatherCache != null)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showInfoDialog(),
              tooltip: 'Sobre o clima mágico',
            ),
        ],
      ),
      backgroundColor: context.gc.darkBackground,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: context.gc.lilac),
            const SizedBox(height: 24),
            Text(
              'Consultando as estrelas...',
              style: GoogleFonts.cinzelDecorative(
                fontSize: 18,
                color: context.gc.lilac,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'O Conselheiro Místico está analisando os trânsitos de hoje',
              style: TextStyle(
                color: context.gc.softWhite.withOpacity(0.7),
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
            Icon(Icons.error_outline, color: context.gc.alert, size: 48),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: context.gc.softWhite),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadWeather,
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

    if (_weatherCache == null) {
      return Center(
        child: Text(
          'Carregando clima mágico...',
          style: TextStyle(color: context.gc.softWhite),
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
          _buildPersonalizedSuggestionsButton(),
          const SizedBox(height: 16),
          _buildMoonSection(weather),
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
              color: context.gc.lilac,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('dd/MM/yyyy - EEEE', 'pt_BR').format(DateTime.now()),
            style: TextStyle(
              color: context.gc.softWhite.withOpacity(0.7),
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
              color: context.gc.lilac,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lua em ${weather.moonSign.displayName} ${weather.moonSign.symbol}',
            style: TextStyle(
              color: context.gc.softWhite.withOpacity(0.9),
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

  Widget _buildPersonalizedSuggestionsButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Semantics(
        button: true,
        label: 'Abrir Sugestões Personalizadas',
        child: ElevatedButton(
          key: const Key('daily-personalized-suggestions-button'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PersonalizedSuggestionsPage(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: context.gc.surface,
            foregroundColor: context.gc.softWhite,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: context.gc.lilac.withValues(alpha: 0.55),
              ),
            ),
          ),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0x332196F3),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(11),
                  child: Text('🔮', style: TextStyle(fontSize: 25)),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sugestões Personalizadas',
                      style: TextStyle(
                        color: context.gc.lilac,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Orientações diárias baseadas no seu mapa astral',
                      style: TextStyle(
                        color: context.gc.softWhite,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, color: context.gc.lilac, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeywordsSection(DailyMagicalWeather weather) {
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Palavras-chave',
            style: TextStyle(
              color: context.gc.lilac,
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
                  color: context.gc.lilac.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.gc.lilac.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  keyword,
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
    );
  }

  Widget _buildAIInterpretationSection() {
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
                  const Text('✨', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Previsão Mágica do Dia',
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
                'Criada pelo Conselheiro Místico baseada nos trânsitos astrológicos',
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
                _buildFreeForecastPreview(),
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
                  data: _weatherCache!.aiGeneratedText,
                  styleSheet: _getMarkdownStyleSheet(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFreeForecastPreview() {
    final headings = DailyForecastPreview.headingsFromMarkdown(
      _weatherCache!.aiGeneratedText,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < headings.length; index++) ...[
          Text(
            headings[index],
            style: GoogleFonts.cinzelDecorative(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.gc.lilac,
            ),
          ),
          const SizedBox(height: 7),
          _buildBlurredForecastContent(),
          if (index < headings.length - 1) const SizedBox(height: 18),
        ],
      ],
    );
  }

  /// Apenas o corpo fica oculto. O placeholder evita expor o texto Premium
  /// real na semântica ou na árvore de widgets.
  Widget _buildBlurredForecastContent() {
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Text(
            DailyWeatherContent.premiumPlaceholder,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.gc.softWhite,
              height: 1.55,
              fontSize: 15,
            ),
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

  Widget _buildTransitsSection(DailyMagicalWeather weather) {
    // Ordem astrologica classica: pessoais, sociais e transpessoais.
    const order = <Planet>[
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
    ];
    final importantPlanets = [
      for (final p in order)
        ...weather.transits.where((t) => t.planet == p),
    ];

    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🪐', style: TextStyle(fontSize: 24)),
              SizedBox(width: 8),
              Text(
                'Trânsitos Planetários',
                style: TextStyle(
                  color: context.gc.lilac,
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
                    style: TextStyle(
                      color: context.gc.lilac,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      transit.formattedPosition,
                      style: TextStyle(
                        color: context.gc.softWhite,
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
          Row(
            children: [
              Text('⭐', style: TextStyle(fontSize: 24)),
              SizedBox(width: 8),
              Text(
                'Aspectos Significativos',
                style: TextStyle(
                  color: context.gc.lilac,
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
                    style: TextStyle(
                      color: context.gc.lilac,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    aspect.interpretation,
                    style: TextStyle(
                      color: context.gc.softWhite.withOpacity(0.8),
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
        backgroundColor: context.gc.surface,
        title: Text(
          'Sobre o Clima Mágico',
          style: GoogleFonts.cinzelDecorative(
            color: context.gc.lilac,
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
                color: context.gc.softWhite.withOpacity(0.9),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'A previsão é gerada uma vez por dia às 00h e permanece a mesma até a meia-noite seguinte.',
              style: TextStyle(
                color: context.gc.softWhite.withOpacity(0.7),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Entendi',
              style: TextStyle(color: context.gc.lilac),
            ),
          ),
        ],
      ),
    );
  }
}
