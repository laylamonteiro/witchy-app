import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/models/transit_model.dart';
import '../../data/models/birth_chart_model.dart';
import '../../data/models/enums.dart';
import '../../data/services/transit_interpreter.dart';

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
  BirthChart? _natalChart;
  bool _isLoading = false;
  bool _hasNatalChart = false;

  @override
  void initState() {
    super.initState();
    _loadNatalChart();
  }

  Future<void> _loadNatalChart() async {
    setState(() => _isLoading = true);

    try {
      final db = await DatabaseHelper.instance.database;
      final charts = await db.query(
        'birth_charts',
        orderBy: 'created_at DESC',
        limit: 1,
      );

      if (charts.isNotEmpty) {
        final chartData = charts.first['chart_data'] as String;
        final chart = BirthChart.fromJsonString(chartData);

        setState(() {
          _natalChart = chart;
          _hasNatalChart = true;
        });

        await _loadSuggestions();
      } else {
        setState(() {
          _hasNatalChart = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar mapa natal: $e')),
        );
      }
    }
  }

  Future<void> _loadSuggestions() async {
    if (_natalChart == null) return;

    setState(() => _isLoading = true);

    try {
      final suggestions = await _interpreter.generatePersonalizedSuggestions(
        _selectedDate,
        _natalChart!,
      );

      setState(() {
        _suggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar sugestões: $e')),
        );
      }
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
                'Mapa Natal Necessário',
                style: TextStyle(
                  color: AppColors.lilac,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Para receber sugestões personalizadas baseadas nos trânsitos astrológicos, você precisa criar seu mapa natal primeiro.',
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
                  isToday
                      ? 'Hoje'
                      : DateFormat('dd/MM/yyyy').format(_selectedDate),
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

  Widget _buildInfoCard() {
    return MagicalCard(
      child: Row(
        children: [
          const Text('✨', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sugestões baseadas nos trânsitos planetários e seu mapa natal',
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
