import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/magical_card.dart';
import '../ai/ai_service.dart';
import '../ai/groq_credentials.dart';
import '../../features/astrology/data/services/chart_calculator.dart';
import '../../features/astrology/data/services/transit_interpreter.dart';
import '../../core/database/database_helper.dart';
import '../../features/astrology/data/models/birth_chart_model.dart';

/// Página de diagnóstico completo do app
/// Testa todas as funcionalidades críticas
class DiagnosticPage extends StatefulWidget {
  const DiagnosticPage({super.key});

  @override
  State<DiagnosticPage> createState() => _DiagnosticPageState();
}

class _DiagnosticPageState extends State<DiagnosticPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _logs = [];
  bool _isTesting = false;
  String? _result;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toIso8601String().split('T')[1].substring(0, 8)} - $message');
    });
  }

  void _copyLogs() {
    final logsText = _logs.join('\n');
    Clipboard.setData(ClipboardData(text: logsText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs copiados para a área de transferência'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _testGroqAPI() async {
    setState(() {
      _isTesting = true;
      _result = null;
      _logs.clear();
    });

    _addLog('🤖 Iniciando teste da API Groq...');

    try {
      _addLog('🔑 Verificando credenciais...');
      final apiKey = GroqCredentials.apiKey;

      if (apiKey == 'SUBSTITUA_PELA_SUA_CHAVE_GROQ_AQUI' || apiKey.isEmpty) {
        _addLog('❌ API KEY NÃO CONFIGURADA!');
        _addLog('📝 Edite lib/core/ai/groq_credentials.dart');
        _addLog('🌐 Obtenha em: https://console.groq.com/keys');
        setState(() {
          _result = 'ERRO: API Key não configurada';
          _isTesting = false;
        });
        return;
      }

      _addLog('✅ API Key: ${apiKey.substring(0, 10)}...');
      _addLog('📡 Testando geração de feitiço...');
      _addLog('💭 Intenção: "Atrair prosperidade"');

      final spell = await AIService.instance.generateSpell('Atrair prosperidade');

      _addLog('✅ FEITIÇO GERADO!');
      _addLog('   Nome: ${spell.name}');
      _addLog('   Categoria: ${spell.category.name}');
      _addLog('   Ingredientes: ${spell.ingredients.length}');

      setState(() {
        _result = 'SUCESSO: IA funcionando!';
        _isTesting = false;
      });
    } catch (e, stackTrace) {
      _addLog('❌ ERRO: $e');
      _addLog('');
      _addLog('📋 Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');

      setState(() {
        _result = 'ERRO: ${e.toString()}';
        _isTesting = false;
      });
    }
  }

  Future<void> _testBirthChart() async {
    setState(() {
      _isTesting = true;
      _result = null;
      _logs.clear();
    });

    _addLog('🌟 Testando cálculo de mapa astral...');

    try {
      _addLog('📅 Data teste: 31/03/1994 19:39');
      _addLog('📍 Local: São Paulo (-23.5505, -46.6333)');

      final calculator = ChartCalculator.instance;
      final chart = await calculator.calculateBirthChart(
        birthDate: DateTime(1994, 3, 31),
        birthTime: const TimeOfDay(hour: 19, minute: 39),
        birthPlace: 'São Paulo',
        latitude: -23.5505,
        longitude: -46.6333,
      );

      _addLog('✅ MAPA CALCULADO!');
      _addLog('   Planetas: ${chart.planets.length}');
      _addLog('   Casas: ${chart.houses.length}');
      _addLog('   Aspectos: ${chart.aspects.length}');

      if (chart.planets.isNotEmpty) {
        final sun = chart.planets.firstWhere((p) => p.planet.toString().contains('sun'));
        _addLog('   Sol: ${sun.sign.name} ${sun.degree}°${sun.minute}\'');
      }
      if (chart.ascendant != null) {
        _addLog('   ASC: ${chart.ascendant!.sign.name} ${chart.ascendant!.degree}°');
      }

      setState(() {
        _result = 'SUCESSO: Mapa calculado!';
        _isTesting = false;
      });
    } catch (e, stackTrace) {
      _addLog('❌ ERRO: $e');
      _addLog('');
      _addLog('📋 Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');

      setState(() {
        _result = 'ERRO: ${e.toString()}';
        _isTesting = false;
      });
    }
  }

  Future<void> _testMagicalWeather() async {
    setState(() {
      _isTesting = true;
      _result = null;
      _logs.clear();
    });

    _addLog('🌙 Testando Clima Mágico Diário...');

    try {
      _addLog('📅 Data: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}');

      final interpreter = TransitInterpreter();
      final weather = await interpreter.getDailyMagicalWeather(DateTime.now());

      _addLog('✅ CLIMA CALCULADO!');
      _addLog('   Trânsitos: ${weather.transits.length}');
      _addLog('   Lua: ${weather.moonPhase ?? "N/A"}');
      _addLog('   Energia: ${weather.overallEnergy.name}');
      _addLog('   Palavras-chave: ${weather.energyKeywords.join(", ")}');

      setState(() {
        _result = 'SUCESSO: Clima calculado!';
        _isTesting = false;
      });
    } catch (e, stackTrace) {
      _addLog('❌ ERRO: $e');
      _addLog('');
      _addLog('📋 Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');

      setState(() {
        _result = 'ERRO: ${e.toString()}';
        _isTesting = false;
      });
    }
  }

  Future<void> _testSuggestions() async {
    setState(() {
      _isTesting = true;
      _result = null;
      _logs.clear();
    });

    _addLog('🔮 Testando Sugestões Personalizadas...');

    try {
      // Buscar mapa natal do banco
      _addLog('📂 Buscando mapa natal no banco...');
      final db = await DatabaseHelper.instance.database;
      final maps = await db.query('birth_charts', limit: 1);

      if (maps.isEmpty) {
        _addLog('⚠️ Nenhum mapa natal encontrado no banco');
        _addLog('💡 Crie um mapa astral primeiro');
        setState(() {
          _result = 'AVISO: Sem mapa natal no banco';
          _isTesting = false;
        });
        return;
      }

      _addLog('✅ Mapa encontrado');

      final mapData = maps.first;
      final chart = BirthChartModel.fromJson(mapData);

      _addLog('📡 Gerando sugestões...');
      final interpreter = TransitInterpreter();
      final suggestions = await interpreter.generatePersonalizedSuggestions(
        DateTime.now(),
        chart,
      );

      _addLog('✅ SUGESTÕES GERADAS!');
      _addLog('   Total: ${suggestions.length}');
      for (final suggestion in suggestions.take(3)) {
        _addLog('   • ${suggestion.title ?? "Sugestão sem título"}');
      }

      setState(() {
        _result = 'SUCESSO: ${suggestions.length} sugestões!';
        _isTesting = false;
      });
    } catch (e, stackTrace) {
      _addLog('❌ ERRO: $e');
      _addLog('');
      _addLog('📋 Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');

      setState(() {
        _result = 'ERRO: ${e.toString()}';
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico Completo'),
        backgroundColor: AppColors.darkBackground,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.lilac,
          isScrollable: true,
          tabs: const [
            Tab(text: 'IA Groq'),
            Tab(text: 'Mapa Astral'),
            Tab(text: 'Clima Mágico'),
            Tab(text: 'Sugestões'),
          ],
        ),
        actions: [
          if (_logs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyLogs,
              tooltip: 'Copiar logs',
            ),
        ],
      ),
      backgroundColor: AppColors.darkBackground,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTestSection(
            icon: Icons.psychology,
            title: 'IA Groq',
            description: 'Testa geração de feitiços com Llama 3.1',
            onTest: _testGroqAPI,
          ),
          _buildTestSection(
            icon: Icons.star,
            title: 'Mapa Astral',
            description: 'Testa cálculos astronômicos locais',
            onTest: _testBirthChart,
          ),
          _buildTestSection(
            icon: Icons.wb_twilight,
            title: 'Clima Mágico',
            description: 'Testa trânsitos planetários diários',
            onTest: _testMagicalWeather,
          ),
          _buildTestSection(
            icon: Icons.lightbulb,
            title: 'Sugestões',
            description: 'Testa sugestões personalizadas',
            onTest: _testSuggestions,
          ),
        ],
      ),
    );
  }

  Widget _buildTestSection({
    required IconData icon,
    required String title,
    required String description,
    required Future<void> Function() onTest,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MagicalCard(
            child: Column(
              children: [
                Icon(icon, size: 64, color: AppColors.lilac),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.lilac,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.softWhite.withOpacity(0.8),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _isTesting ? null : onTest,
            icon: _isTesting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkBackground),
                    ),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(_isTesting ? 'Testando...' : 'Executar Teste'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lilac,
              foregroundColor: AppColors.darkBackground,
              padding: const EdgeInsets.symmetric(vertical: 16),
              disabledBackgroundColor: AppColors.lilac.withOpacity(0.3),
            ),
          ),

          if (_result != null) ...[
            const SizedBox(height: 16),
            MagicalCard(
              child: Row(
                children: [
                  Icon(
                    _result!.startsWith('SUCESSO')
                        ? Icons.check_circle
                        : _result!.startsWith('AVISO')
                            ? Icons.warning
                            : Icons.error,
                    color: _result!.startsWith('SUCESSO')
                        ? AppColors.success
                        : _result!.startsWith('AVISO')
                            ? AppColors.starYellow
                            : AppColors.alert,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _result!,
                      style: TextStyle(
                        color: _result!.startsWith('SUCESSO')
                            ? AppColors.success
                            : _result!.startsWith('AVISO')
                                ? AppColors.starYellow
                                : AppColors.alert,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (_logs.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Logs de Diagnóstico',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.lilac,
                  ),
            ),
            const SizedBox(height: 8),
            MagicalCard(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _logs.join('\n'),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: AppColors.softWhite,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
