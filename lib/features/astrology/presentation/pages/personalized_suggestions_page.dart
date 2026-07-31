import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/content/content_locale.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/database/database_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../data/data_sources/personalized_suggestions_content.dart';
import '../../data/models/transit_model.dart';
import '../../data/models/birth_chart_model.dart';
import '../../data/models/enums.dart';
import '../../data/services/transit_interpreter.dart';
import '../../data/services/transit_calculator.dart';
import 'birth_chart_input_page.dart';

/// Ícones (invariantes entre idiomas) dos planetas retrógrados.
const Map<Planet, String> _retrogradeIcons = {
  Planet.mercury: '☿️',
  Planet.venus: '♀️',
  Planet.mars: '♂️',
  Planet.jupiter: '♃',
  Planet.saturn: '♄',
  Planet.uranus: '♅',
  Planet.neptune: '♆',
  Planet.pluto: '♇',
};

class PersonalizedSuggestionsPage extends StatefulWidget {
  const PersonalizedSuggestionsPage({super.key});

  @override
  State<PersonalizedSuggestionsPage> createState() =>
      _PersonalizedSuggestionsPageState();
}

class _PersonalizedSuggestionsPageState
    extends State<PersonalizedSuggestionsPage> {
  final TransitInterpreter _interpreter = TransitInterpreter();
  DateTime _selectedDate = DateTime.now();
  List<PersonalizedSuggestion>? _suggestions;
  BirthChartModel? _natalChart;
  bool _isLoading = false;
  bool _hasNatalChart = false;
  List<Transit>? _retrogradePlanets;

  @override
  void initState() {
    super.initState();
    _loadNatalChart();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarregar quando a página aparecer novamente
    // (por exemplo, após criar um mapa astral)
    if (_hasNatalChart == false && !_isLoading) {
      _loadNatalChart();
    }
  }

  Future<void> _loadNatalChart() async {
    print('🔮 PersonalizedSuggestionsPage: Iniciando carregamento mapa natal...');
    setState(() => _isLoading = true);

    try {
      print('📂 PersonalizedSuggestionsPage: Buscando no banco...');
      final db = await DatabaseHelper.instance.database;
      final charts = await db.query(
        'birth_charts',
        where: 'user_id = ?',
        whereArgs: [context.read<AuthProvider>().currentUser.id],
        orderBy: 'calculated_at DESC',
        limit: 1,
      );

      if (charts.isNotEmpty) {
        print('✅ PersonalizedSuggestionsPage: Mapa natal encontrado!');
        final chartData = charts.first['chart_data'] as String;
        final chart = BirthChartModel.fromJsonString(chartData);

        setState(() {
          _natalChart = chart;
          _hasNatalChart = true;
        });
        print('📊 PersonalizedSuggestionsPage: Estado atualizado, carregando sugestões...');

        await _loadSuggestions();
      } else {
        print('⚠️ PersonalizedSuggestionsPage: Nenhum mapa natal encontrado');
        setState(() {
          _hasNatalChart = false;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ PersonalizedSuggestionsPage: ERRO ao carregar mapa natal: $e');
      print('📋 Stack trace: $stackTrace');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(personalizedSuggestionsContent.ui['errorLoadChart']!),
            backgroundColor: context.gc.alert,
          ),
        );
      }
    }
  }

  Future<void> _loadSuggestions() async {
    if (_natalChart == null) {
      print('⚠️ PersonalizedSuggestionsPage: Não pode gerar sugestões: mapa natal não encontrado');
      return;
    }

    print('📡 PersonalizedSuggestionsPage: Gerando sugestões...');
    setState(() => _isLoading = true);

    try {
      print('📊 PersonalizedSuggestionsPage: Chamando generatePersonalizedSuggestions...');

      // Carregar sugestões e planetas retrógrados em paralelo
      final calculator = TransitCalculator();
      final transits = await calculator.calculateTransits(_selectedDate);

      // Filtrar planetas retrógrados
      final retrograde = transits.where((t) => t.isRetrograde).toList();

      final suggestions = await _interpreter.generatePersonalizedSuggestions(
        _selectedDate,
        _natalChart!,
      );

      print('✅ PersonalizedSuggestionsPage: ${suggestions.length} sugestões geradas');
      print('🔄 PersonalizedSuggestionsPage: ${retrograde.length} planetas retrógrados');

      if (!mounted) {
        print('⚠️ PersonalizedSuggestionsPage: Widget não está montado, abortando');
        return;
      }

      setState(() {
        _suggestions = suggestions;
        _retrogradePlanets = retrograde;
        _isLoading = false;
      });
      print('✅ PersonalizedSuggestionsPage: Estado atualizado! _suggestions.length=${_suggestions?.length}');
    } catch (e, stackTrace) {
      print('❌ PersonalizedSuggestionsPage: ERRO ao gerar sugestões: $e');
      print('📋 Stack trace: $stackTrace');

      if (!mounted) return;

      setState(() {
        _suggestions = [];
        _retrogradePlanets = [];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(personalizedSuggestionsContent.ui['errorGenerate']!),
          backgroundColor: context.gc.alert,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 PersonalizedSuggestionsPage.build: _isLoading=$_isLoading, _hasNatalChart=$_hasNatalChart, _suggestions?.length=${_suggestions?.length}');

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isFree = !authProvider.isPremiumEffective;

        return Scaffold(
          appBar: AppBar(
            title: ResponsiveAppBarTitle(
              AppLocalizations.of(context).astroSuggestions,
              style: const TextStyle(fontSize: 18),
            ),
            backgroundColor: context.gc.darkBackground,
          ),
          backgroundColor: context.gc.darkBackground,
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(color: context.gc.lilac),
                )
              : !_hasNatalChart
                  ? _buildNoChartView()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildDateSelector(),
                          const SizedBox(height: 16),
                          _buildInfoCard(),
                          const SizedBox(height: 16),
                          // Botão premium para usuários free
                          if (isFree) ...[
                            _buildPremiumBanner(context),
                            const SizedBox(height: 16),
                          ],
                          if (_retrogradePlanets != null &&
                              _retrogradePlanets!.isNotEmpty)
                            _buildRetrogradeCard(isFree: isFree),
                          if (_retrogradePlanets != null &&
                              _retrogradePlanets!.isNotEmpty)
                            const SizedBox(height: 16),
                          if (_suggestions != null && _suggestions!.isNotEmpty)
                            ..._suggestions!.map((s) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child:
                                      _buildSuggestionCard(s, isFree: isFree),
                                )),
                          if (_suggestions != null && _suggestions!.isEmpty)
                            _buildNoSuggestionsCard(),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildPremiumBanner(BuildContext context) {
    return MagicalCard(
      child: Column(
        children: [
          Row(
            children: [
              const Text('🔮', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).premiumContentLabel,
                      style: TextStyle(
                        color: context.gc.lilac,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      personalizedSuggestionsContent
                          .ui['premiumUnlockSubtitle']!,
                      style: TextStyle(
                        color: context.gc.softWhite.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
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
              label: Text(AppLocalizations.of(context).premiumBePremium),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.gc.lilac,
                foregroundColor: context.gc.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoChartView() {
    final content = personalizedSuggestionsContent;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: MagicalCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌟', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                content.ui['chartNeededTitle']!,
                style: TextStyle(
                  color: context.gc.lilac,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                content.ui['chartNeededBody']!,
                style: TextStyle(
                  color: context.gc.softWhite.withOpacity(0.8),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BirthChartInputPage(),
                    ),
                  );
                  if (!mounted) return;
                  await _loadNatalChart();
                },
                icon: const Icon(Icons.assignment_ind_outlined),
                label: Text(content.ui['fillChartButton']!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.gc.lilac,
                  foregroundColor: context.gc.darkBackground,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return MagicalCard(
      child: Column(
        children: [
          Text(
            personalizedSuggestionsContent.ui['today']!,
            style: TextStyle(
              color: context.gc.lilac,
              fontSize: 20,
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
              color: context.gc.softWhite.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return MagicalCard(
      child: Row(
        children: [
          const Text('✨', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              personalizedSuggestionsContent.ui['infoBanner']!,
              style: TextStyle(
                color: context.gc.softWhite.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetrogradeCard({bool isFree = false}) {
    final content = personalizedSuggestionsContent;
    final retrogradeInfo = content.retrogradeInfo;

    // Verificar se Mercúrio está retrógrado (destaque especial)
    final mercuryRetrograde =
        _retrogradePlanets!.any((p) => p.planet == Planet.mercury);

    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                mercuryRetrograde ? '☿️' : '🔄',
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mercuryRetrograde
                          ? content.ui['mercuryRetrogradeActive']!
                          : content.ui['retrogradePlanets']!,
                      style: TextStyle(
                        color:
                            mercuryRetrograde ? Colors.orange : context.gc.lilac,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      (_retrogradePlanets!.length > 1
                              ? content.ui['retrogradeCountMany']!
                              : content.ui['retrogradeCountOne']!)
                          .replaceAll(
                              '{count}', '${_retrogradePlanets!.length}'),
                      style: TextStyle(
                        color: context.gc.softWhite.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: context.gc.lilac),
          const SizedBox(height: 12),
          ..._retrogradePlanets!.map((planet) {
            final info = retrogradeInfo[planet.planet];
            if (info == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título sempre visível
                  Row(
                    children: [
                      Text(_retrogradeIcons[planet.planet] ?? '🔄',
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          content.ui['retrogradeInSign']!
                              .replaceAll('{title}', info.title)
                              .replaceAll(
                                  '{sign}', planet.sign.displayName),
                          style: TextStyle(
                            color: context.gc.lilac,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Título "Efeitos" sempre visível
                  Text(
                    content.ui['effectsLabel']!,
                    style: TextStyle(
                      color: context.gc.lilac,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // FAIL-CLOSED: para free, mostra placeholder desfocado — o
                  // conteúdo real não entra na árvore de widgets.
                  if (isFree)
                    _blurredPlaceholder(
                      style: TextStyle(
                        color: context.gc.softWhite.withOpacity(0.8),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    )
                  else
                    Text(
                      info.effects,
                      style: TextStyle(
                        color: context.gc.softWhite.withOpacity(0.8),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Título "Dicas" sempre visível
                  Text(
                    content.ui['tipsLabel']!,
                    style: TextStyle(
                      color: context.gc.lilac,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (isFree)
                    _blurredPlaceholder(
                      style: TextStyle(
                        color: context.gc.softWhite.withOpacity(0.6),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    )
                  else
                    Text(
                      info.tips,
                      style: TextStyle(
                        color: context.gc.softWhite.withOpacity(0.6),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
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

  Widget _buildSuggestionCard(PersonalizedSuggestion suggestion,
      {bool isFree = false}) {
    final categoryIcons = {
      'ritual': '🕯️',
      'spell': '✨',
      'meditation': '🧘',
      'divination': '🔮',
    };

    final priorityColors = {
      EnergyLevel.intense: Colors.purple,
      EnergyLevel.challenging: Colors.orange,
      EnergyLevel.moderate: Colors.blue,
      EnergyLevel.harmonious: Colors.green,
    };

    // FAIL-CLOSED: para free, o conteúdo real é substituído por um
    // placeholder desfocado (nunca renderizado, nem atrás de blur).
    Widget blurIfFree(Widget child) {
      if (isFree) {
        return _blurredPlaceholder(
          style: TextStyle(
            color: context.gc.softWhite,
            fontSize: 12,
            height: 1.4,
          ),
        );
      }
      return child;
    }

    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título principal sempre visível
          Row(
            children: [
              Text(
                categoryIcons[suggestion.category] ?? '⭐',
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.title,
                      style: TextStyle(
                        color: context.gc.lilac,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColors[suggestion.priority]!
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: priorityColors[suggestion.priority]!
                              .withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        suggestion.priority.displayName,
                        style: TextStyle(
                          color: priorityColors[suggestion.priority],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: context.gc.lilac),
          const SizedBox(height: 8),
          // Descrição - blur apenas no conteúdo
          blurIfFree(
            Text(
              suggestion.description,
              style: TextStyle(
                color: context.gc.softWhite,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Título "Práticas Sugeridas" sempre visível
          Text(
            personalizedSuggestionsContent.ui['suggestedPracticesLabel']!,
            style: TextStyle(
              color: context.gc.lilac,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Lista de práticas - blur apenas no conteúdo
          ...suggestion.practices.map((practice) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      color: context.gc.lilac,
                      fontSize: 14,
                    ),
                  ),
                  Expanded(
                    child: blurIfFree(
                      Text(
                        practice,
                        style: TextStyle(
                          color: context.gc.softWhite.withOpacity(0.9),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (suggestion.relevantAspects.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(color: context.gc.lilac),
            const SizedBox(height: 8),
            // Título "Aspectos Relevantes" sempre visível
            Text(
              personalizedSuggestionsContent.ui['relevantAspectsLabel']!,
              style: TextStyle(
                color: context.gc.lilac,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            // Lista de aspectos - blur apenas no conteúdo
            ...suggestion.relevantAspects.map((aspect) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: blurIfFree(
                  Text(
                    aspect.description,
                    style: TextStyle(
                      color: context.gc.softWhite.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  /// Placeholder desfocado exibido para free no lugar do conteúdo premium
  /// (fail-closed: o texto real não entra na árvore de widgets).
  Widget _blurredPlaceholder({TextStyle? style, int maxLines = 2}) {
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Text(
            kPremiumPlaceholderText,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ),
    );
  }

  Widget _buildNoSuggestionsCard() {
    return MagicalCard(
      child: Column(
        children: [
          const Text('💫', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            personalizedSuggestionsContent.ui['noSuggestionsTitle']!,
            style: TextStyle(
              color: context.gc.lilac,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            personalizedSuggestionsContent.ui['noSuggestionsBody']!,
            style: TextStyle(
              color: context.gc.softWhite.withOpacity(0.8),
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
