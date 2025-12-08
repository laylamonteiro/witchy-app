import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/magical_card.dart';
import '../ai/ai_service.dart';
import '../ai/groq_credentials.dart';
import '../../features/astrology/data/services/chart_calculator.dart';
import '../../features/astrology/data/services/transit_interpreter.dart';
import '../../features/astrology/data/models/birth_chart_model.dart';
import '../../core/database/database_helper.dart';
import '../../features/auth/auth.dart';
import 'debug_logs_page.dart';
import '../services/payment_service.dart';
import '../config/revenuecat_config.dart';

// Mapa de capitais brasileiras com coordenadas exatas
const Map<String, Map<String, dynamic>> _brazilianCapitals = {
  'sao paulo': {
    'name': 'São Paulo',
    'state': 'São Paulo',
    'lat': -23.5505,
    'lon': -46.6333,
  },
  'rio de janeiro': {
    'name': 'Rio de Janeiro',
    'state': 'Rio de Janeiro',
    'lat': -22.9068,
    'lon': -43.1729,
  },
  'belo horizonte': {
    'name': 'Belo Horizonte',
    'state': 'Minas Gerais',
    'lat': -19.9167,
    'lon': -43.9345,
  },
  'brasilia': {
    'name': 'Brasília',
    'state': 'Distrito Federal',
    'lat': -15.7939,
    'lon': -47.8828,
  },
  'salvador': {
    'name': 'Salvador',
    'state': 'Bahia',
    'lat': -12.9714,
    'lon': -38.5014,
  },
  'fortaleza': {
    'name': 'Fortaleza',
    'state': 'Ceará',
    'lat': -3.7172,
    'lon': -38.5433,
  },
  'recife': {
    'name': 'Recife',
    'state': 'Pernambuco',
    'lat': -8.0476,
    'lon': -34.8770,
  },
  'curitiba': {
    'name': 'Curitiba',
    'state': 'Paraná',
    'lat': -25.4284,
    'lon': -49.2733,
  },
  'porto alegre': {
    'name': 'Porto Alegre',
    'state': 'Rio Grande do Sul',
    'lat': -30.0346,
    'lon': -51.2177,
  },
  'manaus': {
    'name': 'Manaus',
    'state': 'Amazonas',
    'lat': -3.1190,
    'lon': -60.0217,
  },
};

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

  // Controllers para input manual do mapa astral
  final _dateController = TextEditingController(text: '31/03/1994');
  final _timeController = TextEditingController(text: '19:39');
  final _birthPlaceController = TextEditingController();
  final FocusNode _birthPlaceFocusNode = FocusNode();

  // Geolocalização
  List<Location> _locationSuggestions = [];
  List<Placemark> _placemarkSuggestions = [];
  bool _isSearchingLocation = false;
  bool _showSuggestions = false;
  String? _birthPlace;
  double? _selectedLatitude;
  double? _selectedLongitude;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _birthPlaceController.dispose();
    _birthPlaceFocusNode.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (query.length < 3) {
      setState(() {
        _locationSuggestions = [];
        _placemarkSuggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    setState(() {
      _isSearchingLocation = true;
      _showSuggestions = true;
    });

    try {
      // Normalizar string para comparação (remover acentos e lowercase)
      String normalize(String? text) {
        if (text == null) return '';
        return text
            .toLowerCase()
            .replaceAll('á', 'a')
            .replaceAll('à', 'a')
            .replaceAll('ã', 'a')
            .replaceAll('â', 'a')
            .replaceAll('é', 'e')
            .replaceAll('ê', 'e')
            .replaceAll('í', 'i')
            .replaceAll('ó', 'o')
            .replaceAll('ô', 'o')
            .replaceAll('õ', 'o')
            .replaceAll('ú', 'u')
            .replaceAll('ü', 'u')
            .replaceAll('ç', 'c');
      }

      final normalizedQuery = normalize(query.trim());
      final results = <MapEntry<Location, Placemark>>[];

      // PRIORIDADE MÁXIMA: Verificar se é uma capital brasileira conhecida
      if (_brazilianCapitals.containsKey(normalizedQuery)) {
        final capital = _brazilianCapitals[normalizedQuery]!;
        final capitalLocation = Location(
          latitude: capital['lat'] as double,
          longitude: capital['lon'] as double,
          timestamp: DateTime.now(),
        );
        final capitalPlacemark = Placemark(
          locality: capital['name'] as String,
          administrativeArea: capital['state'] as String,
          country: 'Brazil',
        );
        results.add(MapEntry(capitalLocation, capitalPlacemark));
      }

      // Buscar outros resultados via API de geocoding
      String searchQuery = query;
      if (!query.toLowerCase().contains('brasil') &&
          !query.toLowerCase().contains('brazil') &&
          !query.toLowerCase().contains(',')) {
        searchQuery = '$query, Brasil';
      }

      try {
        final locations = await locationFromAddress(searchQuery);

        for (final location in locations.take(10)) {
          try {
            final placemark = await placemarkFromCoordinates(
              location.latitude,
              location.longitude,
            );
            if (placemark.isNotEmpty) {
              // Evitar duplicar capital se já está nos resultados
              final isDuplicate = results.any((existing) {
                final distance = (existing.key.latitude - location.latitude).abs() +
                    (existing.key.longitude - location.longitude).abs();
                return distance < 0.1; // ~10km de tolerância
              });

              if (!isDuplicate) {
                results.add(MapEntry(location, placemark.first));
              }
            }
          } catch (e) {
            // Skip locations that can't be reverse geocoded
          }
        }
      } catch (e) {
        // Se falhar busca da API mas temos capital, continuar
        if (results.isEmpty) rethrow;
      }

      // Ordenar resultados por relevância
      results.sort((a, b) {
        final aPlace = a.value;
        final bPlace = b.value;

        // Prioridade 0: Capitais onde locality == administrativeArea e ambos == query
        // Ex: São Paulo (cidade) no estado de São Paulo
        final aIsCapital = normalize(aPlace.locality) == normalizedQuery &&
            normalize(aPlace.administrativeArea) == normalizedQuery;
        final bIsCapital = normalize(bPlace.locality) == normalizedQuery &&
            normalize(bPlace.administrativeArea) == normalizedQuery;
        if (aIsCapital && !bIsCapital) return -1;
        if (!aIsCapital && bIsCapital) return 1;

        // Prioridade 1: locality exatamente igual ao termo de busca
        final aLocalityMatch = normalize(aPlace.locality) == normalizedQuery;
        final bLocalityMatch = normalize(bPlace.locality) == normalizedQuery;
        if (aLocalityMatch && !bLocalityMatch) return -1;
        if (!aLocalityMatch && bLocalityMatch) return 1;

        // Prioridade 2: subAdministrativeArea exatamente igual
        final aSubMatch = normalize(aPlace.subAdministrativeArea) == normalizedQuery;
        final bSubMatch = normalize(bPlace.subAdministrativeArea) == normalizedQuery;
        if (aSubMatch && !bSubMatch) return -1;
        if (!aSubMatch && bSubMatch) return 1;

        // Prioridade 3: locality contém o termo
        final aLocalityContains = normalize(aPlace.locality).contains(normalizedQuery);
        final bLocalityContains = normalize(bPlace.locality).contains(normalizedQuery);
        if (aLocalityContains && !bLocalityContains) return -1;
        if (!aLocalityContains && bLocalityContains) return 1;

        return 0;
      });

      setState(() {
        _locationSuggestions = results.take(5).map((e) => e.key).toList();
        _placemarkSuggestions = results.take(5).map((e) => e.value).toList();
        _isSearchingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationSuggestions = [];
        _placemarkSuggestions = [];
        _isSearchingLocation = false;
      });
    }
  }

  void _selectLocation(int index) {
    final location = _locationSuggestions[index];
    final placemark = _placemarkSuggestions.length > index
        ? _placemarkSuggestions[index]
        : null;

    String displayName;
    if (placemark != null) {
      final parts = <String>[];
      // Priorizar locality (cidade), mas se não tiver, usar subAdministrativeArea
      if (placemark.locality != null && placemark.locality!.isNotEmpty) {
        parts.add(placemark.locality!);
      } else if (placemark.subAdministrativeArea != null &&
          placemark.subAdministrativeArea!.isNotEmpty) {
        parts.add(placemark.subAdministrativeArea!);
      }
      if (placemark.administrativeArea != null &&
          placemark.administrativeArea!.isNotEmpty) {
        parts.add(placemark.administrativeArea!);
      }
      if (placemark.country != null && placemark.country!.isNotEmpty) {
        parts.add(placemark.country!);
      }
      displayName = parts.join(', ');
    } else {
      displayName = _birthPlaceController.text;
    }

    setState(() {
      _birthPlace = displayName;
      _birthPlaceController.text = displayName;
      _selectedLatitude = location.latitude;
      _selectedLongitude = location.longitude;
      _showSuggestions = false;
      _locationSuggestions = [];
      _placemarkSuggestions = [];
    });

    _birthPlaceFocusNode.unfocus();
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toIso8601String().split('T')[1].substring(0, 8)} - $message');
    });
  }

  void _copyLogs() {
    print('========== DEBUG DE CÓPIA ==========');
    print('📋 Total de linhas em _logs: ${_logs.length}');
    print('📋 _logs.isEmpty: ${_logs.isEmpty}');

    // Print de CADA linha individual
    for (int i = 0; i < _logs.length; i++) {
      print('📋 Linha $i: ${_logs[i].substring(0, _logs[i].length > 60 ? 60 : _logs[i].length)}...');
    }

    print('📋 Primeiras 3: ${_logs.take(3).join(" | ")}');
    if (_logs.length > 3) {
      print('📋 Últimas 3: ${_logs.skip(_logs.length - 3).join(" | ")}');
    }

    final logsText = _logs.join('\n');

    print('📋 Texto total: ${logsText.length} caracteres');
    print('📋 Quebras de linha: ${'\n'.allMatches(logsText).length}');
    print('📋 Primeiros 200 chars: ${logsText.substring(0, logsText.length > 200 ? 200 : logsText.length)}');

    if (logsText.length > 200) {
      print('📋 Últimos 200 chars: ${logsText.substring(logsText.length - 200)}');
    }

    Clipboard.setData(ClipboardData(text: logsText)).then((_) {
      print('✅ Clipboard.setData COMPLETO!');
      print('✅ Dados enviados para clipboard: ${logsText.length} caracteres');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ ${_logs.length} linhas copiadas!\n'
            '${logsText.length} caracteres no total',
            style: const TextStyle(fontSize: 13),
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    }).catchError((error) {
      print('❌ ERRO ao copiar: $error');
    });
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
      // Validar se local foi selecionado
      if (_selectedLatitude == null || _selectedLongitude == null || _birthPlace == null) {
        _addLog('❌ Selecione um local de nascimento');
        setState(() {
          _result = 'ERRO: Local não selecionado';
          _isTesting = false;
        });
        return;
      }

      // Parse inputs
      final dateParts = _dateController.text.split('/');
      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);

      final timeParts = _timeController.text.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      _addLog('📅 Data teste: ${_dateController.text} ${_timeController.text}');
      _addLog('📍 Local: $_birthPlace');
      _addLog('🗺️ Coordenadas: (${_selectedLatitude!.toStringAsFixed(4)}, ${_selectedLongitude!.toStringAsFixed(4)})');

      final calculator = ChartCalculator.instance;
      final chart = await calculator.calculateBirthChart(
        birthDate: DateTime(year, month, day),
        birthTime: TimeOfDay(hour: hour, minute: minute),
        birthPlace: _birthPlace!,
        latitude: _selectedLatitude!,
        longitude: _selectedLongitude!,
        onLog: _addLog,
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
          tabAlignment: TabAlignment.start,
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          labelStyle: const TextStyle(fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          tabs: const [
            Tab(text: 'Debug'),
            Tab(text: 'Pagamentos'),
            Tab(text: 'Login Google'),
            Tab(text: 'IA Groq'),
            Tab(text: 'Mapa Astral'),
            Tab(text: 'Clima Mágico'),
            Tab(text: 'Sugestões'),
          ],
        ),
        actions: [
          // Botão para ver logs persistentes de inicialização
          Tooltip(
            message: 'Ver Logs de Inicialização',
            child: IconButton(
              icon: const Icon(Icons.article_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DebugLogsPage()),
              ),
            ),
          ),
          if (_logs.isNotEmpty)
            Tooltip(
              message: 'Copiar TODOS os logs (${_logs.length} linhas)',
              child: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: _copyLogs,
              ),
            ),
        ],
      ),
      backgroundColor: AppColors.darkBackground,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDebugSection(),
          _buildPaymentsDiagnosticSection(),
          _buildGoogleLoginSection(),
          _buildTestSection(
            icon: Icons.psychology,
            title: 'IA Groq',
            description: 'Testa geração de feitiços com Llama 3.1',
            onTest: _testGroqAPI,
          ),
          _buildBirthChartSection(),
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

  Widget _buildPaymentsDiagnosticSection() {
    final paymentService = PaymentService();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          MagicalCard(
            child: Column(
              children: [
                const Icon(Icons.payment, size: 64, color: AppColors.lilac),
                const SizedBox(height: 16),
                Text(
                  'Diagnóstico de Pagamentos',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.lilac,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Informações do RevenueCat e status das compras',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.softWhite.withOpacity(0.8),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Status de Inicialização
          MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      paymentService.isInitialized
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: paymentService.isInitialized
                          ? AppColors.success
                          : AppColors.alert,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Status de Inicialização',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.lilac,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDiagnosticRow(
                  'RevenueCat SDK',
                  paymentService.isInitialized ? 'Inicializado ✓' : 'Não inicializado ✗',
                  paymentService.isInitialized,
                ),
                _buildDiagnosticRow(
                  'Chaves configuradas',
                  RevenueCatConfig.isConfigured ? 'Sim ✓' : 'Não ✗',
                  RevenueCatConfig.isConfigured,
                ),
                if (RevenueCatConfig.isConfigured) ...[
                  _buildDiagnosticRow(
                    'Chave iOS',
                    RevenueCatConfig.iosApiKey.isEmpty
                        ? 'Ausente'
                        : '${RevenueCatConfig.iosApiKey.substring(0, 10)}...',
                    RevenueCatConfig.iosApiKey.isNotEmpty,
                  ),
                  _buildDiagnosticRow(
                    'Chave Android',
                    RevenueCatConfig.androidApiKey.isEmpty
                        ? 'Ausente'
                        : '${RevenueCatConfig.androidApiKey.substring(0, 10)}...',
                    RevenueCatConfig.androidApiKey.isNotEmpty,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Status Premium
          MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      paymentService.isPro ? Icons.star : Icons.star_border,
                      color: paymentService.isPro
                          ? AppColors.starYellow
                          : AppColors.textSecondary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Status Premium',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.lilac,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDiagnosticRow(
                  'É Premium',
                  paymentService.isPro ? 'Sim ✓' : 'Não',
                  paymentService.isPro,
                ),
                _buildDiagnosticRow(
                  'Assinatura ativa',
                  paymentService.hasActiveSubscription ? 'Sim ✓' : 'Não',
                  paymentService.hasActiveSubscription,
                ),
                if (paymentService.isLifetime)
                  _buildDiagnosticRow(
                    'Tipo',
                    'Vitalício ✓',
                    true,
                  ),
                if (paymentService.subscriptionExpirationDate != null)
                  _buildDiagnosticRow(
                    'Expira em',
                    _formatDate(paymentService.subscriptionExpirationDate!),
                    true,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Ofertas e Produtos
          MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_cart,
                      color: AppColors.mint,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Produtos Disponíveis',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.mint,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDiagnosticRow(
                  'Offering carregada',
                  paymentService.offerings?.current != null ? 'Sim ✓' : 'Não ✗',
                  paymentService.offerings?.current != null,
                ),
                if (paymentService.offerings?.current != null)
                  _buildDiagnosticRow(
                    'Offering ID',
                    paymentService.offerings!.current!.identifier,
                    true,
                  ),
                _buildDiagnosticRow(
                  'Produtos',
                  '${paymentService.products.length} disponíveis',
                  paymentService.products.isNotEmpty,
                ),
                const SizedBox(height: 8),
                if (paymentService.products.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.alert.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.alert.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning,
                          color: AppColors.alert,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Nenhum produto carregado. Verifique a configuração no RevenueCat Dashboard.',
                            style: TextStyle(
                              color: AppColors.alert,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const Divider(color: AppColors.surfaceBorder),
                  const SizedBox(height: 8),
                  ...paymentService.products.map((product) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.mint,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.title,
                                  style: const TextStyle(
                                    color: AppColors.softWhite,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${product.identifier} • ${product.priceString}',
                                  style: TextStyle(
                                    color: AppColors.softWhite.withOpacity(0.6),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Botão para copiar logs
          ElevatedButton.icon(
            onPressed: () {
              final diagnosticInfo = _generatePaymentDiagnosticLogs(paymentService);
              Clipboard.setData(ClipboardData(text: diagnosticInfo));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Diagnóstico copiado! Cole e envie para análise.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copiar Diagnóstico Completo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lilac,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Informações de ajuda
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.lilac.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.lilac,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Como usar',
                      style: TextStyle(
                        color: AppColors.lilac,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Clique em "Copiar Diagnóstico Completo"\n'
                  '2. Cole as informações em uma mensagem\n'
                  '3. Envie para análise do problema\n\n'
                  'Essas informações ajudam a identificar problemas de configuração.',
                  style: TextStyle(
                    color: AppColors.softWhite.withOpacity(0.8),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticRow(String label, String value, bool isOk) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.softWhite.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: isOk ? AppColors.success : AppColors.alert,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _generatePaymentDiagnosticLogs(PaymentService paymentService) {
    final buffer = StringBuffer();
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('DIAGNÓSTICO DE PAGAMENTOS - RevenueCat');
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('Data: ${DateTime.now()}');
    buffer.writeln();

    buffer.writeln('📱 INICIALIZAÇÃO');
    buffer.writeln('  • SDK Inicializado: ${paymentService.isInitialized ? "SIM ✓" : "NÃO ✗"}');
    buffer.writeln('  • Chaves configuradas: ${RevenueCatConfig.isConfigured ? "SIM ✓" : "NÃO ✗"}');
    buffer.writeln('  • Chave iOS: ${RevenueCatConfig.iosApiKey.isEmpty ? "AUSENTE" : "${RevenueCatConfig.iosApiKey.substring(0, 10)}..."}');
    buffer.writeln('  • Chave Android: ${RevenueCatConfig.androidApiKey.isEmpty ? "AUSENTE" : "${RevenueCatConfig.androidApiKey.substring(0, 10)}..."}');
    buffer.writeln();

    buffer.writeln('⭐ STATUS PREMIUM');
    buffer.writeln('  • É Premium: ${paymentService.isPro ? "SIM ✓" : "NÃO"}');
    buffer.writeln('  • Assinatura ativa: ${paymentService.hasActiveSubscription ? "SIM ✓" : "NÃO"}');
    buffer.writeln('  • Tipo: ${paymentService.isLifetime ? "Vitalício" : "Assinatura"}');
    if (paymentService.subscriptionExpirationDate != null) {
      buffer.writeln('  • Expira em: ${_formatDate(paymentService.subscriptionExpirationDate!)}');
    }
    buffer.writeln();

    buffer.writeln('🛒 PRODUTOS');
    buffer.writeln('  • Offering carregada: ${paymentService.offerings?.current != null ? "SIM ✓" : "NÃO ✗"}');
    if (paymentService.offerings?.current != null) {
      buffer.writeln('  • Offering ID: ${paymentService.offerings!.current!.identifier}');
    }
    buffer.writeln('  • Produtos disponíveis: ${paymentService.products.length}');
    buffer.writeln();

    if (paymentService.products.isEmpty) {
      buffer.writeln('  ⚠️  ATENÇÃO: Nenhum produto foi carregado!');
      buffer.writeln('  💡 Verifique:');
      buffer.writeln('     1. Offering "default" existe no RevenueCat Dashboard');
      buffer.writeln('     2. Produtos estão associados à offering');
      buffer.writeln('     3. Produtos foram criados nas lojas (App Store/Google Play)');
    } else {
      buffer.writeln('  Produtos encontrados:');
      for (final product in paymentService.products) {
        buffer.writeln('    • ${product.title}');
        buffer.writeln('      ID: ${product.identifier}');
        buffer.writeln('      Preço: ${product.priceString}');
        buffer.writeln('      Tipo: ${product.type.name}');
        buffer.writeln();
      }
    }

    buffer.writeln();
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('💡 PRÓXIMOS PASSOS:');
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('1. Execute: flutter run --verbose');
    buffer.writeln('2. Tente fazer uma compra');
    buffer.writeln('3. Copie TODOS os logs do console');
    buffer.writeln('4. Envie junto com este diagnóstico');
    buffer.writeln();
    buffer.writeln('📚 Consulte: DEVELOPMENT.md seção "Troubleshooting"');
    buffer.writeln('═══════════════════════════════════════');

    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildDebugSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card de Role Atual
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getRoleIcon(user.role),
                          color: _getRoleColor(user.role),
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Role Atual',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                              Text(
                                _getRoleLabel(user.role),
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: _getRoleColor(user.role),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getRoleColor(user.role).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user.plan.name.toUpperCase(),
                            style: TextStyle(
                              color: _getRoleColor(user.role),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Alternador de Roles
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.swap_horiz,
                          color: AppColors.lilac,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Simular Plano',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.lilac,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Alterne entre roles para testar a experiência de cada tipo de usuário',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildRoleButton(context, 'Free', UserRole.free, authProvider),
                        const SizedBox(width: 8),
                        _buildRoleButton(context, 'Premium', UserRole.premium, authProvider),
                        const SizedBox(width: 8),
                        _buildRoleButton(context, 'Admin', UserRole.admin, authProvider),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Estatísticas de Uso
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.analytics,
                          color: AppColors.mint,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Estatísticas de Uso',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.mint,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStatRow('Feitiços salvos', '${user.spellsCount}/${UserModel.freeSpellsLimit}'),
                    _buildStatRow('Diários este mês', '${user.diaryEntriesThisMonth}/${UserModel.freeDiaryEntriesLimit}'),
                    _buildStatRow('Consultas IA hoje', '${user.aiConsultationsToday}/${UserModel.freeAiConsultationsLimit}'),
                    _buildStatRow('Pêndulo hoje', '${user.pendulumUsesToday}/${UserModel.dailyPendulumLimit}'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Ações de Reset
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.refresh,
                          color: AppColors.alert,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Ações de Reset',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.alert,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await authProvider.resetUser();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Usuário resetado para padrão'),
                                backgroundColor: AppColors.alert,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.person_off),
                        label: const Text('Resetar Usuário'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.alert,
                          side: const BorderSide(color: AppColors.alert),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleButton(
    BuildContext context,
    String label,
    UserRole role,
    AuthProvider authProvider,
  ) {
    final isSelected = authProvider.currentUser.role == role;

    return Expanded(
      child: ElevatedButton(
        onPressed: () => authProvider.setUserRole(role),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? _getRoleColor(role)
              : Colors.white.withOpacity(0.1),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.softWhite.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.softWhite,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.shield;
      case UserRole.premium:
        return Icons.star;
      case UserRole.free:
        return Icons.person;
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFFFFD700);
      case UserRole.premium:
        return const Color(0xFF9C27B0);
      case UserRole.free:
        return const Color(0xFF2196F3);
    }
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.premium:
        return 'Premium';
      case UserRole.free:
        return 'Gratuito';
    }
  }

  Widget _buildBirthChartSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MagicalCard(
            child: Column(
              children: [
                const Icon(Icons.star, size: 64, color: AppColors.lilac),
                const SizedBox(height: 16),
                Text(
                  'Mapa Astral',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.lilac,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Testa cálculos astronômicos locais',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.softWhite.withOpacity(0.8),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Input fields
          MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dados do Nascimento',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.lilac,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _dateController,
                        style: const TextStyle(color: AppColors.softWhite),
                        decoration: const InputDecoration(
                          labelText: 'Data',
                          hintText: 'DD/MM/AAAA',
                          labelStyle: TextStyle(color: AppColors.lilac),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.surfaceBorder),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lilac),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _timeController,
                        style: const TextStyle(color: AppColors.softWhite),
                        decoration: const InputDecoration(
                          labelText: 'Hora',
                          hintText: 'HH:MM',
                          labelStyle: TextStyle(color: AppColors.lilac),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.surfaceBorder),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lilac),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Local de Nascimento',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.lilac,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _birthPlaceController,
                  focusNode: _birthPlaceFocusNode,
                  style: const TextStyle(color: AppColors.softWhite),
                  decoration: InputDecoration(
                    hintText: 'Ex: Campinas, Bueno Brandão, São Paulo...',
                    hintStyle: TextStyle(
                      color: AppColors.softWhite.withOpacity(0.5),
                    ),
                    prefixIcon: const Icon(
                      Icons.location_on,
                      color: AppColors.lilac,
                    ),
                    suffixIcon: _isSearchingLocation
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.lilac,
                                ),
                              ),
                            ),
                          )
                        : (_selectedLatitude != null && _selectedLongitude != null)
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                              )
                            : null,
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _birthPlace = value;
                      _selectedLatitude = null;
                      _selectedLongitude = null;
                    });
                    _searchLocation(value);
                  },
                ),
                if (_showSuggestions && _locationSuggestions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.lilac.withOpacity(0.3),
                      ),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _locationSuggestions.length,
                      separatorBuilder: (context, index) => Divider(
                        color: AppColors.lilac.withOpacity(0.2),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final placemark = _placemarkSuggestions.length > index
                            ? _placemarkSuggestions[index]
                            : null;

                        final loc = _locationSuggestions[index];
                        String displayText;
                        String coordsText =
                            'Lat: ${loc.latitude.toStringAsFixed(4)}, Lon: ${loc.longitude.toStringAsFixed(4)}';

                        if (placemark != null) {
                          final parts = <String>[];

                          // Priorizar locality (cidade), mas se não tiver, usar subAdministrativeArea
                          if (placemark.locality != null &&
                              placemark.locality!.isNotEmpty) {
                            parts.add(placemark.locality!);
                          } else if (placemark.subAdministrativeArea != null &&
                              placemark.subAdministrativeArea!.isNotEmpty) {
                            parts.add(placemark.subAdministrativeArea!);
                          }

                          if (placemark.administrativeArea != null &&
                              placemark.administrativeArea!.isNotEmpty) {
                            parts.add(placemark.administrativeArea!);
                          }

                          if (placemark.country != null &&
                              placemark.country!.isNotEmpty) {
                            parts.add(placemark.country!);
                          }

                          displayText = parts.join(', ');
                        } else {
                          displayText = coordsText;
                        }

                        return ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.place,
                            color: AppColors.lilac,
                            size: 20,
                          ),
                          title: Text(
                            displayText,
                            style: const TextStyle(
                              color: AppColors.softWhite,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            coordsText,
                            style: TextStyle(
                              color: AppColors.softWhite.withOpacity(0.6),
                              fontSize: 11,
                            ),
                          ),
                          onTap: () => _selectLocation(index),
                        );
                      },
                    ),
                  ),
                ],
                if (_selectedLatitude != null && _selectedLongitude != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '✓ $_birthPlace\n'
                            'Lat: ${_selectedLatitude!.toStringAsFixed(4)}, Lon: ${_selectedLongitude!.toStringAsFixed(4)}',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _isTesting ? null : _testBirthChart,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          if (_result != null) ...[
            const SizedBox(height: 16),
            MagicalCard(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _result!.contains('SUCESSO')
                      ? AppColors.success.withOpacity(0.2)
                      : AppColors.alert.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _result!,
                  style: TextStyle(
                    color: _result!.contains('SUCESSO') ? AppColors.success : AppColors.alert,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],

          if (_logs.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Logs de Diagnóstico',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.lilac,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: AppColors.lilac),
                  onPressed: _copyLogs,
                  tooltip: 'Copiar logs',
                ),
              ],
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

  Future<void> _testGoogleLogin() async {
    setState(() {
      _isTesting = true;
      _result = null;
      _logs.clear();
    });

    _addLog('🔑 Testando Google Sign-In...');

    try {
      _addLog('📱 Plataforma: ${kIsWeb ? "WEB" : "MOBILE"}');

      final authProvider = context.read<AuthProvider>();
      final authRepo = context.read<SupabaseAuthRepository>();

      _addLog('🔍 Verificando estado atual do auth...');
      _addLog('   Usuário atual: ${authProvider.currentUser.email}');
      _addLog('   Está autenticado: ${authProvider.isAuthenticated}');

      _addLog('');
      _addLog('🚀 Iniciando Google Sign-In...');

      final result = await authRepo.signInWithGoogle();

      if (result.isSuccess) {
        _addLog('✅ SUCESSO no Google Sign-In!');
        if (result.user != null) {
          _addLog('   Email: ${result.user!.email}');
          _addLog('   Nome: ${result.user!.displayName ?? "Não informado"}');
          _addLog('   ID: ${result.user!.id}');
        }

        setState(() {
          _result = 'SUCESSO: Login realizado!';
          _isTesting = false;
        });
      } else {
        _addLog('❌ ERRO no Google Sign-In');
        _addLog('   Código: ${result.errorCode?.toString() ?? "Desconhecido"}');
        _addLog('   Mensagem: ${result.message}');

        setState(() {
          _result = 'ERRO: ${result.message}';
          _isTesting = false;
        });
      }
    } catch (e, stackTrace) {
      _addLog('💥 EXCEÇÃO CAPTURADA!');
      _addLog('   Tipo: ${e.runtimeType}');
      _addLog('   Mensagem: $e');
      _addLog('');
      _addLog('📋 Stack trace:');
      final stackLines = stackTrace.toString().split('\n').take(5);
      for (final line in stackLines) {
        _addLog('   $line');
      }

      setState(() {
        _result = 'ERRO: $e';
        _isTesting = false;
      });
    }
  }

  Widget _buildGoogleLoginSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              MagicalCard(
                child: Column(
                  children: [
                    const Icon(Icons.login, size: 64, color: AppColors.lilac),
                    const SizedBox(height: 16),
                    Text(
                      'Teste de Login Google',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.lilac,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Teste o fluxo completo de autenticação com Google',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.softWhite.withOpacity(0.8),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Status atual
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          authProvider.isAuthenticated
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: authProvider.isAuthenticated
                              ? AppColors.success
                              : AppColors.alert,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Status Atual',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.lilac,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDiagnosticRow(
                      'Autenticado',
                      authProvider.isAuthenticated ? 'Sim ✓' : 'Não',
                      authProvider.isAuthenticated,
                    ),
                    _buildDiagnosticRow(
                      'Email',
                      authProvider.currentUser.email.isEmpty
                          ? 'Não autenticado'
                          : authProvider.currentUser.email,
                      authProvider.currentUser.email.isNotEmpty,
                    ),
                    _buildDiagnosticRow(
                      'Plataforma',
                      kIsWeb ? 'WEB' : 'MOBILE',
                      true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Botão de teste
              ElevatedButton.icon(
                onPressed: _isTesting ? null : _testGoogleLogin,
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
                label: Text(_isTesting ? 'Testando...' : 'Testar Google Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lilac,
                  foregroundColor: AppColors.darkBackground,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              if (_result != null) ...[
                const SizedBox(height: 16),
                MagicalCard(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _result!.contains('SUCESSO')
                          ? AppColors.success.withOpacity(0.2)
                          : AppColors.alert.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _result!,
                      style: TextStyle(
                        color: _result!.contains('SUCESSO') ? AppColors.success : AppColors.alert,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],

              if (_logs.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Logs de Diagnóstico',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.lilac,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: AppColors.lilac),
                      onPressed: _copyLogs,
                      tooltip: 'Copiar logs',
                    ),
                  ],
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

              const SizedBox(height: 24),

              // Informações de ajuda
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.lilac.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.lilac,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Como usar',
                          style: TextStyle(
                            color: AppColors.lilac,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Clique em "Testar Google Login"\n'
                      '2. Siga o fluxo de autenticação do Google\n'
                      '3. Copie os logs gerados\n'
                      '4. Envie para análise em caso de erro\n\n'
                      'Os logs mostram cada passo do processo de autenticação.',
                      style: TextStyle(
                        color: AppColors.softWhite.withOpacity(0.8),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
