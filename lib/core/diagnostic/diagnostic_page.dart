import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import '../theme/app_theme.dart';
import '../widgets/magical_card.dart';
import '../ai/ai_service.dart';
import '../ai/groq_credentials.dart';
import '../../features/astrology/data/services/chart_calculator.dart';
import '../../features/astrology/data/services/transit_interpreter.dart';
import '../../core/database/database_helper.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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
            Tab(text: 'IA Groq'),
            Tab(text: 'Mapa Astral'),
            Tab(text: 'Clima Mágico'),
            Tab(text: 'Sugestões'),
          ],
        ),
        actions: [
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
