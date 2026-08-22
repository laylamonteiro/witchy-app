import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../../../../core/content/content_locale.dart';
import '../../../../core/offers/offer_engine.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/reading_markdown.dart';
import '../../data/data_sources/daily_weather_content.dart';
import '../../data/models/transit_model.dart';
import '../../data/models/enums.dart';
import '../../data/repositories/daily_weather_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../providers/astrology_provider.dart';
import 'personalized_suggestions_page.dart';

/// Atalho para conteúdo estático localizado (padrão `ContentLocale`,
/// paridade pt/en/es garantida pelos parâmetros obrigatórios).
String _sel({required String pt, required String en, required String es}) =>
    ContentLocale.instance.select(pt: pt, en: en, es: es);

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
  static const _teaserSlot = OfferSlot.dailyWeatherTeaser;

  final DailyWeatherRepository _repository = DailyWeatherRepository();
  DateTime _selectedDate = DateTime.now();
  DailyWeatherCache? _weatherCache;
  bool _isLoading = false;
  String? _error;

  OfferEngine? _engine;

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
      // O gate do pago é conferido ANTES de gerar: sem acesso, a previsão
      // escrita nem chega a ser pedida à IA (fail-closed de verdade — o
      // blur da tela nunca foi proteção).
      final hasAccess = context.read<AuthProvider>().isPremiumEffective;
      print('📡 DailyMagicalWeatherPage: Chamando getDailyWeather...');
      final cache = await _repository.getDailyWeather(
        _selectedDate,
        userId: context.read<AuthProvider>().currentUser.id,
        withAiText: hasAccess,
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

      if (!hasAccess) {
        await _prepareOfferEngine();
      }
    } catch (e, stackTrace) {
      print('❌ DailyMagicalWeatherPage: ERRO ao calcular clima mágico: $e');
      print('📋 Stack trace: $stackTrace');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = ContentLocale.instance.select(
          pt: 'Erro ao carregar clima mágico. Tente novamente.',
          en: 'Could not load the magical weather. Please try again.',
          es: 'Error al cargar el clima mágico. Inténtalo de nuevo.',
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ContentLocale.instance.select(
            pt: 'Erro ao calcular clima mágico. Por favor, tente novamente.',
            en: 'Error calculating the magical weather. Please try again.',
            es: 'Error al calcular el clima mágico. Inténtalo de nuevo.',
          )),
          backgroundColor: context.gc.alert,
        ),
      );
    }
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
          AppLocalizations.of(context).astroDailyWeather,
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: context.gc.darkBackground,
        actions: [
          if (_weatherCache != null)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showInfoDialog(),
              tooltip: ContentLocale.instance.select(
                pt: 'Sobre o clima mágico',
                en: 'About the magical weather',
                es: 'Sobre el clima mágico',
              ),
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
              _sel(
                pt: 'Consultando as estrelas...',
                en: 'Consulting the stars...',
                es: 'Consultando las estrellas...',
              ),
              style: GoogleFonts.cinzelDecorative(
                fontSize: 18,
                color: context.gc.lilac,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _sel(
                pt: 'O Conselheiro Místico está analisando os trânsitos de hoje',
                en: "The Mystic Counselor is analyzing today's transits",
                es: 'El Consejero Místico está analizando los tránsitos de hoy',
              ),
              style: TextStyle(
                color: context.gc.softWhite.withValues(alpha: 0.7),
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
          ContentLocale.instance.select(
            pt: 'Carregando clima mágico...',
            en: 'Loading magical weather...',
            es: 'Cargando clima mágico...',
          ),
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
            _sel(pt: 'Hoje', en: 'Today', es: 'Hoy'),
            style: GoogleFonts.cinzelDecorative(
              fontSize: 24,
              color: context.gc.lilac,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat(
              'dd/MM/yyyy - EEEE',
              ContentLocale.instance.locale.toString(),
            ).format(DateTime.now()),
            style: TextStyle(
              color: context.gc.softWhite.withValues(alpha: 0.7),
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
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzelDecorative(
              fontSize: 24,
              color: context.gc.lilac,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_sel(pt: 'Lua em', en: 'Moon in', es: 'Luna en')} ${weather.moonSign.displayName} ${weather.moonSign.symbol}',
            style: TextStyle(
              color: context.gc.softWhite.withValues(alpha: 0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: weather.moonSign.element.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: weather.moonSign.element.color.withValues(alpha: 0.5),
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
        label: ContentLocale.instance.select(
          pt: 'Abrir Sugestões Personalizadas',
          en: 'Open Personalized Suggestions',
          es: 'Abrir Sugerencias Personalizadas',
        ),
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
                      AppLocalizations.of(context).astroSuggestions,
                      style: TextStyle(
                        color: context.gc.lilac,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _sel(
                        pt: 'Orientações diárias baseadas no seu mapa astral',
                        en: 'Daily guidance based on your birth chart',
                        es: 'Orientación diaria basada en tu carta natal',
                      ),
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
            _sel(
              pt: 'Palavras-chave',
              en: 'Keywords',
              es: 'Palabras clave',
            ),
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
                  color: context.gc.lilac.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.gc.lilac.withValues(alpha: 0.5),
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
                      _sel(
                        pt: 'Previsão Mágica do Dia',
                        en: "Today's Magical Forecast",
                        es: 'Previsión Mágica del Día',
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
                  pt: 'Criada pelo Conselheiro Místico baseada nos trânsitos astrológicos',
                  en: 'Created by the Mystic Counselor based on the astrological transits',
                  es: 'Creada por el Consejero Místico basada en los tránsitos astrológicos',
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
              // Sem acesso: a previsão completa nem foi gerada (o gate está
              // no repositório). O que aparece aqui são os assuntos do dia,
              // pelo nome, com o texto sob véu — e o convite embaixo.
              if (isFree) ...[
                _buildFreeForecastPreview(),
                const SizedBox(height: 16),
                _buildForecastCta(),
              ] else ...[
                ReadingMarkdown(
                  _weatherCache!.aiGeneratedText,
                  refine: _folhaDeEstilo,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// O convite, depois dos assuntos do dia sob véu. Nada de amostra gerada:
  /// o que cria vontade é ver a FORMA da previsão, não um parágrafo solto.
  Widget _buildForecastCta() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _onTeaserCta,
        icon: const Icon(Icons.star, size: 18),
        label: Text(AppLocalizations.of(context).premiumBePremium),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.gc.lilac,
          foregroundColor: context.gc.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
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

  /// Os ajustes desta previsão sobre a base do grimório.
  ///
  /// A previsão é lida de relance, entre uma coisa e outra: corpo um pouco
  /// menor e mais junto que o das leituras longas. O resto — inclusive a
  /// frase que a IA resolva destacar com `> ` — vem vestido da base.
  static MarkdownStyleSheet _folhaDeEstilo(MarkdownStyleSheet base) {
    // `copyWith` TROCA o estilo inteiro — partir do estilo da base é o que
    // mantém a cor do texto vinda do tema. Um `TextStyle` novo aqui deixaria
    // a cor nula e o corpo voltaria ao padrão do pacote.
    return base.copyWith(
      p: base.p?.copyWith(height: 1.6, fontSize: 15),
      listBullet: base.listBullet?.copyWith(fontSize: 15, height: 1.6),
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
                _sel(
                  pt: 'Trânsitos Planetários',
                  en: 'Planetary Transits',
                  es: 'Tránsitos Planetarios',
                ),
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
                _sel(
                  pt: 'Aspectos Significativos',
                  en: 'Significant Aspects',
                  es: 'Aspectos Significativos',
                ),
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
                      color: context.gc.softWhite.withValues(alpha: 0.8),
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
          _sel(
            pt: 'Sobre o Clima Mágico',
            en: 'About the Magical Weather',
            es: 'Sobre el Clima Mágico',
          ),
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
              _sel(
                pt: 'O Clima Mágico é calculado diariamente com base nos trânsitos planetários reais e interpretado pelo Conselheiro Místico para práticas mágicas.',
                en: 'The Magical Weather is calculated daily based on the real planetary transits and interpreted by the Mystic Counselor for magical practices.',
                es: 'El Clima Mágico se calcula a diario a partir de los tránsitos planetarios reales y lo interpreta el Consejero Místico para las prácticas mágicas.',
              ),
              style: TextStyle(
                color: context.gc.softWhite.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _sel(
                pt: 'A previsão é gerada uma vez por dia às 00h e permanece a mesma até a meia-noite seguinte.',
                en: 'The forecast is generated once a day at midnight and stays the same until the following midnight.',
                es: 'La previsión se genera una vez al día a las 00h y permanece igual hasta la medianoche siguiente.',
              ),
              style: TextStyle(
                color: context.gc.softWhite.withValues(alpha: 0.7),
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
              AppLocalizations.of(context).commonUnderstood,
              style: TextStyle(color: context.gc.lilac),
            ),
          ),
        ],
      ),
    );
  }
}
