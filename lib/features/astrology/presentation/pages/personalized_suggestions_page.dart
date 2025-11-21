import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/models/transit_model.dart';
import '../../data/models/birth_chart_model.dart';
import '../../data/models/planet_position_model.dart';
import '../../data/models/enums.dart';
import '../../data/services/transit_interpreter.dart';
import '../../data/services/transit_calculator.dart';

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
  List<PlanetPosition>? _retrogradePlanets;

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
          const SnackBar(
            content: Text('Erro ao carregar mapa astral. Por favor, crie seu mapa astral primeiro.'),
            backgroundColor: AppColors.alert,
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
        const SnackBar(
          content: Text('Erro ao gerar sugestões. Tente novamente mais tarde.'),
          backgroundColor: AppColors.alert,
        ),
      );
    }
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _suggestions = null;
    });
    _loadSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 PersonalizedSuggestionsPage.build: _isLoading=$_isLoading, _hasNatalChart=$_hasNatalChart, _suggestions?.length=${_suggestions?.length}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sugestões Personalizadas'),
        backgroundColor: AppColors.darkBackground,
      ),
      backgroundColor: AppColors.darkBackground,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.lilac),
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
                      if (_retrogradePlanets != null && _retrogradePlanets!.isNotEmpty)
                        _buildRetrogradeCard(),
                      if (_retrogradePlanets != null && _retrogradePlanets!.isNotEmpty)
                        const SizedBox(height: 16),
                      if (_suggestions != null && _suggestions!.isNotEmpty)
                        ..._suggestions!.map((s) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildSuggestionCard(s),
                            )),
                      if (_suggestions != null && _suggestions!.isEmpty)
                        _buildNoSuggestionsCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildNoChartView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: MagicalCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔮', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text(
                'Mapa Astral Necessário',
                style: TextStyle(
                  color: AppColors.lilac,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Para receber sugestões personalizadas baseadas nos trânsitos astrológicos, você precisa criar seu mapa astral primeiro.',
                style: TextStyle(
                  color: AppColors.softWhite.withOpacity(0.8),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar para Astrologia'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lilac,
                  foregroundColor: AppColors.darkBackground,
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
            'Hoje',
            style: const TextStyle(
              color: AppColors.lilac,
              fontSize: 20,
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

  Widget _buildInfoCard() {
    return MagicalCard(
      child: Row(
        children: [
          const Text('✨', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sugestões baseadas nos trânsitos planetários e seu mapa astral',
              style: TextStyle(
                color: AppColors.softWhite.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetrogradeCard() {
    final retrogradeInfo = {
      Planet.mercury: {
        'icon': '☿️',
        'title': 'Mercúrio Retrógrado',
        'effects': 'Comunicação confusa, atrasos em viagens, problemas tecnológicos',
        'tips': 'Revise contratos, evite iniciar projetos novos, faça backup de dados',
      },
      Planet.venus: {
        'icon': '♀️',
        'title': 'Vênus Retrógrada',
        'effects': 'Questões de relacionamento, gastos impulsivos, autoestima',
        'tips': 'Reavalie relacionamentos, evite cirurgias estéticas, reflita sobre valores',
      },
      Planet.mars: {
        'icon': '♂️',
        'title': 'Marte Retrógrado',
        'effects': 'Energia baixa, frustrações, agressividade reprimida',
        'tips': 'Evite conflitos, não inicie batalhas legais, pratique paciência',
      },
      Planet.jupiter: {
        'icon': '♃',
        'title': 'Júpiter Retrógrado',
        'effects': 'Expansão interior, reavaliação de crenças e filosofias',
        'tips': 'Momento de introspecção espiritual, revise metas de longo prazo',
      },
      Planet.saturn: {
        'icon': '♄',
        'title': 'Saturno Retrógrado',
        'effects': 'Responsabilidades passadas retornam, karma sendo trabalhado',
        'tips': 'Resolva assuntos pendentes, trabalhe disciplina interior',
      },
      Planet.uranus: {
        'icon': '♅',
        'title': 'Urano Retrógrado',
        'effects': 'Mudanças internas antes de externas, revelações pessoais',
        'tips': 'Liberte-se de padrões antigos, aceite mudanças graduais',
      },
      Planet.neptune: {
        'icon': '♆',
        'title': 'Netuno Retrógrado',
        'effects': 'Véus se levantam, ilusões reveladas, intuição aguçada',
        'tips': 'Medite, trabalhe sonhos, cuidado com escapismo',
      },
      Planet.pluto: {
        'icon': '♇',
        'title': 'Plutão Retrógrado',
        'effects': 'Transformação profunda, confronto com sombras',
        'tips': 'Trabalho de sombra, deixe ir o que não serve mais',
      },
    };

    // Verificar se Mercúrio está retrógrado (destaque especial)
    final mercuryRetrograde = _retrogradePlanets!.any((p) => p.planet == Planet.mercury);

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
                          ? 'Mercúrio Retrógrado Ativo!'
                          : 'Planetas Retrógrados',
                      style: TextStyle(
                        color: mercuryRetrograde ? Colors.orange : AppColors.lilac,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_retrogradePlanets!.length} planeta${_retrogradePlanets!.length > 1 ? 's' : ''} em movimento retrógrado',
                      style: TextStyle(
                        color: AppColors.softWhite.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.lilac),
          const SizedBox(height: 12),
          ..._retrogradePlanets!.map((planet) {
            final info = retrogradeInfo[planet.planet];
            if (info == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(info['icon']!, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${info['title']} em ${planet.sign.displayName}',
                          style: const TextStyle(
                            color: AppColors.lilac,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Efeitos: ${info['effects']}',
                    style: TextStyle(
                      color: AppColors.softWhite.withOpacity(0.8),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dicas: ${info['tips']}',
                    style: TextStyle(
                      color: AppColors.softWhite.withOpacity(0.6),
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

  Widget _buildSuggestionCard(PersonalizedSuggestion suggestion) {
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

    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      style: const TextStyle(
                        color: AppColors.lilac,
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
          const Divider(color: AppColors.lilac),
          const SizedBox(height: 8),
          Text(
            suggestion.description,
            style: const TextStyle(
              color: AppColors.softWhite,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Práticas Sugeridas:',
            style: TextStyle(
              color: AppColors.lilac,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...suggestion.practices.map((practice) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: AppColors.lilac,
                      fontSize: 14,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      practice,
                      style: TextStyle(
                        color: AppColors.softWhite.withOpacity(0.9),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          if (suggestion.relevantAspects.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.lilac),
            const SizedBox(height: 8),
            const Text(
              'Aspectos Relevantes:',
              style: TextStyle(
                color: AppColors.lilac,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            ...suggestion.relevantAspects.map((aspect) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  aspect.description,
                  style: TextStyle(
                    color: AppColors.softWhite.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildNoSuggestionsCard() {
    return MagicalCard(
      child: Column(
        children: [
          const Text('💫', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text(
            'Sem Sugestões Especiais',
            style: TextStyle(
              color: AppColors.lilac,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Não há trânsitos significativos afetando seu mapa natal neste dia. Continue suas práticas regulares.',
            style: TextStyle(
              color: AppColors.softWhite.withOpacity(0.8),
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
