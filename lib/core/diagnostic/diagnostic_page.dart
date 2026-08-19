import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/grimoire_colors.dart';
import '../widgets/magical_card.dart';
import '../ai/ai_service.dart';
import '../utils/image_compression.dart';
import '../ai/groq_credentials.dart';
import '../../features/astrology/data/services/chart_calculator.dart';
import '../../features/astrology/data/services/transit_interpreter.dart';
import '../../features/astrology/data/models/birth_chart_model.dart';
import '../../core/database/database_helper.dart';
import '../../features/auth/auth.dart';
import 'debug_logs_page.dart';
import '../services/payment_service.dart';
import '../config/revenuecat_config.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../providers/notification_provider.dart';
import '../../features/lunar/presentation/providers/lunar_provider.dart';
import '../../features/wheel_of_year/presentation/providers/wheel_of_year_provider.dart';

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

class _DiagnosticPageState extends State<DiagnosticPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _logs = [];
  bool _isTesting = false;
  String? _result;

  // Payload da notificação de teste (null = destino padrão, aba Lua).
  String? _debugNotifPayload;
  static const Map<String, String?> _debugNotifPayloads = {
    'Padrão (aba Lua)': null,
    'Sabbats (aba)': 'encyclopedia/sabbats',
    'Ritual guiado: Imbolc': 'ritual/sabbat/imbolc',
    'Ritual guiado: Lua Cheia': 'ritual/full_moon',
    'Ritual guiado: Lua Nova': 'ritual/new_moon',
    'Ritual guiado: Água Solar': 'ritual/sun_water',
  };

  // Diagnóstico de Quiromancia (visão)
  final _palmPicker = ImagePicker();
  bool _isTestingPalm = false;
  Map<String, dynamic>? _palmResult;

  // Controllers para input manual do mapa astral
  final _dateController = TextEditingController(text: 'dd/mm/aaaa');
  final _timeController = TextEditingController(text: 'HH:MM');
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
    _tabController = TabController(length: 9, vsync: this);
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
                final distance =
                    (existing.key.latitude - location.latitude).abs() +
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
        final aSubMatch =
            normalize(aPlace.subAdministrativeArea) == normalizedQuery;
        final bSubMatch =
            normalize(bPlace.subAdministrativeArea) == normalizedQuery;
        if (aSubMatch && !bSubMatch) return -1;
        if (!aSubMatch && bSubMatch) return 1;

        // Prioridade 3: locality contém o termo
        final aLocalityContains =
            normalize(aPlace.locality).contains(normalizedQuery);
        final bLocalityContains =
            normalize(bPlace.locality).contains(normalizedQuery);
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
      _logs.add(
          '${DateTime.now().toIso8601String().split('T')[1].substring(0, 8)} - $message');
    });
  }

  void _copyLogs() {
    print('========== DEBUG DE CÓPIA ==========');
    print('📋 Total de linhas em _logs: ${_logs.length}');
    print('📋 _logs.isEmpty: ${_logs.isEmpty}');

    // Print de CADA linha individual
    for (int i = 0; i < _logs.length; i++) {
      print(
          '📋 Linha $i: ${_logs[i].substring(0, _logs[i].length > 60 ? 60 : _logs[i].length)}...');
    }

    print('📋 Primeiras 3: ${_logs.take(3).join(" | ")}');
    if (_logs.length > 3) {
      print('📋 Últimas 3: ${_logs.skip(_logs.length - 3).join(" | ")}');
    }

    final logsText = _logs.join('\n');

    print('📋 Texto total: ${logsText.length} caracteres');
    print('📋 Quebras de linha: ${'\n'.allMatches(logsText).length}');
    print(
        '📋 Primeiros 200 chars: ${logsText.substring(0, logsText.length > 200 ? 200 : logsText.length)}');

    if (logsText.length > 200) {
      print(
          '📋 Últimos 200 chars: ${logsText.substring(logsText.length - 200)}');
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
          backgroundColor: context.gc.success,
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

      final spell =
          await AIService.instance.generateSpell('Atrair prosperidade');

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
      _addLog(
          '📋 Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');

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
      if (_selectedLatitude == null ||
          _selectedLongitude == null ||
          _birthPlace == null) {
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
      _addLog(
          '🗺️ Coordenadas: (${_selectedLatitude!.toStringAsFixed(4)}, ${_selectedLongitude!.toStringAsFixed(4)})');

      final calculator = ChartCalculator.instance;
      final chart = await calculator.calculateBirthChart(
        userId: 'diagnostic_user',
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
        final sun = chart.planets
            .firstWhere((p) => p.planet.toString().contains('sun'));
        _addLog('   Sol: ${sun.sign.name} ${sun.degree}°${sun.minute}\'');
      }
      if (chart.ascendant != null) {
        _addLog(
            '   ASC: ${chart.ascendant!.sign.name} ${chart.ascendant!.degree}°');
      }

      setState(() {
        _result = 'SUCESSO: Mapa calculado!';
        _isTesting = false;
      });
    } catch (e, stackTrace) {
      _addLog('❌ ERRO: $e');
      _addLog('');
      _addLog(
          '📋 Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');

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
      _addLog(
          '📅 Data: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}');

      final interpreter = TransitInterpreter();
      final weather = await interpreter.getDailyMagicalWeather(DateTime.now());

      _addLog('✅ CLIMA CALCULADO!');
      _addLog('   Trânsitos: ${weather.transits.length}');
      _addLog('   Lua: ${weather.moonPhase}');
      _addLog('   Energia: ${weather.overallEnergy.name}');
      _addLog('   Palavras-chave: ${weather.energyKeywords.join(", ")}');

      setState(() {
        _result = 'SUCESSO: Clima calculado!';
        _isTesting = false;
      });
    } catch (e, stackTrace) {
      _addLog('❌ ERRO: $e');
      _addLog('');
      _addLog(
          '📋 Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');

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
        _addLog('   • ${suggestion.title}');
      }

      setState(() {
        _result = 'SUCESSO: ${suggestions.length} sugestões!';
        _isTesting = false;
      });
    } catch (e, stackTrace) {
      _addLog('❌ ERRO: $e');
      _addLog('');
      _addLog(
          '📋 Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');

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
        title: const ResponsiveAppBarTitle('Diagnóstico Completo'),
        backgroundColor: context.gc.darkBackground,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: context.gc.lilac,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          labelStyle: const TextStyle(fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          tabs: const [
            Tab(text: 'Debug'),
            Tab(text: 'Notificações'),
            Tab(text: 'Login Social'), // Nova aba para login social
            Tab(text: 'Pagamentos'),
            Tab(text: 'IA Groq'),
            Tab(text: 'Mapa Astral'),
            Tab(text: 'Clima Mágico'),
            Tab(text: 'Sugestões'),
            Tab(text: 'Quiromancia'),
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
      backgroundColor: context.gc.darkBackground,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDebugSection(),
          _buildNotificationsDiagnosticSection(),
          _buildSocialLoginDiagnosticSection(), // Nova seção para login social
          _buildPaymentsDiagnosticSection(),
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
          _buildPalmistryDiagnosticSection(),
        ],
      ),
    );
  }

  // ============================================================
  // SEÇÃO DE DIAGNÓSTICO DE QUIROMANCIA (visão Groq)
  // ============================================================
  Future<void> _testPalmistry(ImageSource source) async {
    if (_isTestingPalm) return;
    try {
      final picked = await _palmPicker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (picked == null || !mounted) return;

      setState(() {
        _isTestingPalm = true;
        _palmResult = null;
      });

      // Mesmo pipeline da Quiromancia real: comprime, corrige EXIF, remove
      // metadados.
      final compressed = await compressPickedImage(picked);
      final bytes = compressed ?? await picked.readAsBytes();

      final result =
          await AIService.instance.analyzePalmDebug(jpegBytes: bytes);
      if (!mounted) return;
      setState(() => _palmResult = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _palmResult = {
            'ok': false,
            'model': AIService.instance.visionModel,
            'statusCode': null,
            'elapsedMs': 0,
            'imageBytes': 0,
            'body': '$e',
          });
    } finally {
      if (mounted) setState(() => _isTestingPalm = false);
    }
  }

  Widget _buildPalmistryDiagnosticSection() {
    final r = _palmResult;
    final ok = r?['ok'] == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MagicalCard(
            child: Column(
              children: [
                Icon(Icons.back_hand, size: 64, color: context.gc.lilac),
                const SizedBox(height: 16),
                Text(
                  'Diagnóstico de Quiromancia',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: context.gc.lilac),
                ),
                const SizedBox(height: 8),
                Text(
                  'Envia uma foto ao modelo de visão do Groq e mostra a '
                  'resposta crua (modelo, status HTTP, tempo e corpo/erro).',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.gc.softWhite.withValues(alpha: 0.8),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDiagnosticRow(
                  'Modelo de visão',
                  AIService.instance.visionModel,
                  true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isTestingPalm
                      ? null
                      : () => _testPalmistry(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Câmera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.gc.lilac,
                    foregroundColor: context.gc.darkBackground,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isTestingPalm
                      ? null
                      : () => _testPalmistry(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library, size: 18),
                  label: const Text('Galeria'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isTestingPalm)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: CircularProgressIndicator(color: context.gc.lilac),
              ),
            ),
          if (r != null && !_isTestingPalm) ...[
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(ok ? Icons.check_circle : Icons.cancel,
                          color: ok ? context.gc.success : context.gc.alert),
                      const SizedBox(width: 8),
                      Text(
                        ok ? 'Sucesso' : 'Falhou',
                        style: TextStyle(
                          color: ok ? context.gc.success : context.gc.alert,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDiagnosticRow('Modelo', '${r['model']}', true),
                  _buildDiagnosticRow(
                    'Status HTTP',
                    '${r['statusCode'] ?? 'sem resposta'}',
                    ok,
                  ),
                  _buildDiagnosticRow('Tempo', '${r['elapsedMs']} ms', true),
                  _buildDiagnosticRow(
                    'Imagem enviada',
                    '${((r['imageBytes'] as int) / 1024).toStringAsFixed(0)} KB',
                    true,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ok ? 'Resposta:' : 'Erro (corpo cru):',
                    style: TextStyle(
                      color: context.gc.lilac,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 320),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.gc.softWhite.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        '${r['body']}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: context.gc.softWhite,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                          text: 'Quiromancia debug\n'
                              'model: ${r['model']}\n'
                              'status: ${r['statusCode']}\n'
                              'elapsedMs: ${r['elapsedMs']}\n'
                              'imageBytes: ${r['imageBytes']}\n\n'
                              '${r['body']}'));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Diagnóstico copiado!'),
                            backgroundColor: context.gc.success,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copiar diagnóstico'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.gc.lilac,
                      foregroundColor: context.gc.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // SEÇÃO DE DIAGNÓSTICO DE NOTIFICAÇÕES
  // ============================================================
  Widget _buildNotificationsDiagnosticSection() {
    final provider = context.watch<NotificationProvider>();

    Widget kv(String label, String value, {Color? color}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 150,
                child: Text(label,
                    style: TextStyle(
                        color: context.gc.softWhite.withValues(alpha: 0.7),
                        fontSize: 13)),
              ),
              Expanded(
                child: Text(value,
                    style: TextStyle(
                        color: color ?? context.gc.softWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MagicalCard(
            child: Column(
              children: [
                Icon(Icons.notifications_active,
                    size: 64, color: context.gc.lilac),
                const SizedBox(height: 16),
                Text('Diagnóstico de Notificações',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: context.gc.lilac)),
                const SizedBox(height: 8),
                Text(
                  'Permissões, agendamento e notificações pendentes',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: context.gc.softWhite.withValues(alpha: 0.8)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Estado geral
          MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estado',
                    style: TextStyle(
                        color: context.gc.lilac,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                kv(
                  'Inicializado',
                  provider.isInitialized ? 'Sim ✓' : 'Não',
                  color: provider.isInitialized
                      ? const Color(0xFF4CAF50)
                      : context.gc.alert,
                ),
                kv(
                  'Permissão (agendamento)',
                  provider.permissionGranted == null
                      ? 'Desconhecida'
                      : (provider.permissionGranted!
                          ? 'Concedida ✓'
                          : 'Negada'),
                  color: provider.permissionGranted == true
                      ? const Color(0xFF4CAF50)
                      : (provider.permissionGranted == false
                          ? context.gc.alert
                          : context.gc.softWhite),
                ),
                FutureBuilder<bool?>(
                  future: provider.areNotificationsEnabled(),
                  builder: (context, snap) => kv(
                    'Habilitadas no SO',
                    snap.connectionState != ConnectionState.done
                        ? '...'
                        : (snap.data == null
                            ? 'N/D'
                            : (snap.data! ? 'Sim ✓' : 'Não')),
                    color: snap.data == true
                        ? const Color(0xFF4CAF50)
                        : (snap.data == false
                            ? context.gc.alert
                            : context.gc.softWhite),
                  ),
                ),
                kv('Agendadas (contador)', '${provider.scheduledCount}'),
                kv('Lua cheia', provider.fullMoonNotifications ? 'On' : 'Off'),
                kv('Lua nova', provider.newMoonNotifications ? 'On' : 'Off'),
                kv('Sabbats', provider.sabbatNotifications ? 'On' : 'Off'),
                kv(
                  'Último erro',
                  provider.lastError ?? 'Nenhum',
                  color: provider.lastError != null
                      ? context.gc.alert
                      : const Color(0xFF4CAF50),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Prévia para o usuário',
                    style: TextStyle(
                        color: context.gc.lilac,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  'Este é o conteúdo exato enviado pelo botão de teste:',
                  style: TextStyle(
                      color: context.gc.softWhite.withValues(alpha: 0.7),
                      fontSize: 12),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.gc.softWhite.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: context.gc.lilac.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: context.gc.lilac,
                        child: Icon(Icons.auto_stories,
                            size: 19, color: Color(0xFF2B2143)),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text('Grimório de Bolso',
                                      style: TextStyle(
                                          color: context.gc.softWhite,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ),
                                Text('agora',
                                    style: TextStyle(
                                        color: context.gc.softWhite,
                                        fontSize: 10)),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text(AppLocalizations.of(context).notifDebugTitle,
                                style: TextStyle(
                                    color: context.gc.softWhite,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 2),
                            Text(AppLocalizations.of(context).notifDebugBody,
                                style: TextStyle(
                                    color: context.gc.softWhite,
                                    fontSize: 12,
                                    height: 1.25)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: _debugNotifPayload,
                  decoration: const InputDecoration(
                    labelText: 'Destino ao tocar (payload)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: _debugNotifPayloads.entries
                      .map((entry) => DropdownMenuItem<String?>(
                            value: entry.value,
                            child: Text(entry.key,
                                style: const TextStyle(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _debugNotifPayload = value),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await provider.sendDebugNotification(
                          payload: _debugNotifPayload);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result.success
                              ? 'Notificação enviada ao dispositivo.'
                              : result.error ??
                                  'Não foi possível enviar a notificação.'),
                          backgroundColor:
                              result.success ? null : context.gc.alert,
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_to_mobile, size: 18),
                    label: const Text('Enviar notificação de teste'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: context.gc.lilac,
                        foregroundColor: const Color(0xFF2B2143)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A aparência final pode variar conforme Android/iOS e as configurações do aparelho.',
                  style: TextStyle(
                      color: context.gc.softWhite.withValues(alpha: 0.6),
                      fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Notificações pendentes (próximas agendadas)
          MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notificações agendadas',
                    style: TextStyle(
                        color: context.gc.lilac,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                FutureBuilder<List<PendingNotificationRequest>>(
                  future: provider.pendingNotifications(),
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(
                            child: CircularProgressIndicator(
                                color: context.gc.lilac)),
                      );
                    }
                    if (snap.hasError) {
                      return kv('Erro', '${snap.error}',
                          color: context.gc.alert);
                    }
                    final items = snap.data ?? [];
                    if (items.isEmpty) {
                      return Text('Nenhuma notificação agendada.',
                          style: TextStyle(
                              color: context.gc.softWhite.withValues(alpha: 0.7)));
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: items.map((n) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('#${n.id}  ${n.title ?? "(sem título)"}',
                                  style: TextStyle(
                                      color: context.gc.softWhite,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                              if (n.body != null && n.body!.isNotEmpty)
                                Text(n.body!,
                                    style: TextStyle(
                                        color: context.gc.softWhite
                                            .withValues(alpha: 0.7),
                                        fontSize: 12)),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Ações
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final lunar = context.read<LunarProvider>();
                    final wheel = context.read<WheelOfYearProvider>();
                    await provider.scheduleNotifications(
                        lunarProvider: lunar, wheelProvider: wheel);
                    if (mounted) setState(() {});
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reagendar'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: context.gc.lilac,
                      foregroundColor: const Color(0xFF2B2143)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async => setState(() {}),
                  icon: const Icon(Icons.sync, size: 18),
                  label: const Text('Atualizar'),
                ),
              ),
            ],
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
                Icon(Icons.payment, size: 64, color: context.gc.lilac),
                const SizedBox(height: 16),
                Text(
                  'Diagnóstico de Pagamentos',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: context.gc.lilac,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Informações do RevenueCat e status das compras',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.gc.softWhite.withValues(alpha: 0.8),
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
                          ? context.gc.success
                          : context.gc.alert,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Status de Inicialização',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: context.gc.lilac,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDiagnosticRow(
                  'RevenueCat SDK',
                  paymentService.isInitialized
                      ? 'Inicializado ✓'
                      : 'Não inicializado ✗',
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
                          ? context.gc.starYellow
                          : context.gc.textSecondary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Status Premium',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: context.gc.lilac,
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
                    Icon(
                      Icons.shopping_cart,
                      color: context.gc.mint,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Produtos Disponíveis',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: context.gc.mint,
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
                      color: context.gc.alert.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: context.gc.alert.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: context.gc.alert,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Nenhum produto carregado. Verifique a configuração no RevenueCat Dashboard.',
                            style: TextStyle(
                              color: context.gc.alert,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Divider(color: context.gc.surfaceBorder),
                  const SizedBox(height: 8),
                  ...paymentService.products.map((product) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: context.gc.mint,
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
                                  style: TextStyle(
                                    color: context.gc.softWhite,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${product.identifier} • ${product.priceString}',
                                  style: TextStyle(
                                    color: context.gc.softWhite.withValues(alpha: 0.6),
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
              final diagnosticInfo =
                  _generatePaymentDiagnosticLogs(paymentService);
              Clipboard.setData(ClipboardData(text: diagnosticInfo));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Diagnóstico copiado! Cole e envie para análise.'),
                    backgroundColor: context.gc.success,
                  ),
                );
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copiar Diagnóstico Completo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.gc.lilac,
              foregroundColor: context.gc.textPrimary,
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
              color: context.gc.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.gc.lilac.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: context.gc.lilac,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Como usar',
                      style: TextStyle(
                        color: context.gc.lilac,
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
                    color: context.gc.softWhite.withValues(alpha: 0.8),
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
              color: context.gc.softWhite.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: isOk ? context.gc.success : context.gc.alert,
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
    buffer.writeln(
        '  • SDK Inicializado: ${paymentService.isInitialized ? "SIM ✓" : "NÃO ✗"}');
    buffer.writeln(
        '  • Chaves configuradas: ${RevenueCatConfig.isConfigured ? "SIM ✓" : "NÃO ✗"}');
    buffer.writeln(
        '  • Chave iOS: ${RevenueCatConfig.iosApiKey.isEmpty ? "AUSENTE" : "${RevenueCatConfig.iosApiKey.substring(0, 10)}..."}');
    buffer.writeln(
        '  • Chave Android: ${RevenueCatConfig.androidApiKey.isEmpty ? "AUSENTE" : "${RevenueCatConfig.androidApiKey.substring(0, 10)}..."}');
    buffer.writeln();

    buffer.writeln('⭐ STATUS PREMIUM');
    buffer.writeln('  • É Premium: ${paymentService.isPro ? "SIM ✓" : "NÃO"}');
    buffer.writeln(
        '  • Assinatura ativa: ${paymentService.hasActiveSubscription ? "SIM ✓" : "NÃO"}');
    buffer.writeln(
        '  • Tipo: ${paymentService.isLifetime ? "Vitalício" : "Assinatura"}');
    if (paymentService.subscriptionExpirationDate != null) {
      buffer.writeln(
          '  • Expira em: ${_formatDate(paymentService.subscriptionExpirationDate!)}');
    }
    buffer.writeln();

    buffer.writeln('🛒 PRODUTOS');
    buffer.writeln(
        '  • Offering carregada: ${paymentService.offerings?.current != null ? "SIM ✓" : "NÃO ✗"}');
    if (paymentService.offerings?.current != null) {
      buffer.writeln(
          '  • Offering ID: ${paymentService.offerings!.current!.identifier}');
    }
    buffer
        .writeln('  • Produtos disponíveis: ${paymentService.products.length}');
    buffer.writeln();

    if (paymentService.products.isEmpty) {
      buffer.writeln('  ⚠️  ATENÇÃO: Nenhum produto foi carregado!');
      buffer.writeln('  💡 Verifique:');
      buffer
          .writeln('     1. Offering "default" existe no RevenueCat Dashboard');
      buffer.writeln('     2. Produtos estão associados à offering');
      buffer.writeln(
          '     3. Produtos foram criados nas lojas (App Store/Google Play)');
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

  Widget _buildSocialLoginDiagnosticSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MagicalCard(
                child: Column(
                  children: [
                    Icon(Icons.login, size: 64, color: context.gc.lilac),
                    const SizedBox(height: 16),
                    Text(
                      'Diagnóstico de Login Social',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: context.gc.lilac,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Testa o fluxo de login com provedores sociais como Google.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.gc.softWhite.withValues(alpha: 0.8),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  // Lógica para iniciar o login do Google
                  // Isso deve chamar o método signInWithGoogle do SupabaseAuthRepository
                  // e logar os resultados.
                  _addLog('Iniciando teste de login com Google...');
                  final authRepo = SupabaseAuthRepository();
                  final result = await authRepo.signInWithGoogle();

                  // Na web o login sai do app por redirect: nao ha resultado
                  // para julgar aqui, a pagina inteira sera recarregada.
                  if (result.redirecting) {
                    _addLog('Redirecionando para o Google...');
                    return;
                  }

                  if (result.success) {
                    _addLog(
                        'Login com Google SUCESSO! Usuário: ${result.user?.email}');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Login com Google SUCESSO!'),
                          backgroundColor: context.gc.success,
                        ),
                      );
                    }
                  } else {
                    _addLog('Login com Google FALHOU: ${result.errorMessage}');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Login com Google FALHOU: ${result.errorMessage}'),
                          backgroundColor: context.gc.alert,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Testar Login com Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.gc.lilac,
                  foregroundColor: context.gc.darkBackground,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Logs de Login Social',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: context.gc.lilac,
                    ),
              ),
              const SizedBox(height: 8),
              MagicalCard(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _logs.join('\n'),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: context.gc.softWhite,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _copyLogs,
                icon: const Icon(Icons.copy),
                label: const Text('Copiar Logs de Login Social'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.gc.lilac,
                  foregroundColor: context.gc.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: context.gc.textSecondary,
                                    ),
                              ),
                              Text(
                                _getRoleLabel(user.role),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: _getRoleColor(user.role),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getRoleColor(user.role).withValues(alpha: 0.2),
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
                        Icon(
                          Icons.swap_horiz,
                          color: context.gc.lilac,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Simular Plano',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: context.gc.lilac,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Alterne entre roles para testar a experiência de cada tipo de usuário',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.gc.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildRoleButton(
                            context, 'Free', UserRole.free, authProvider),
                        const SizedBox(width: 8),
                        _buildRoleButton(
                            context, 'Premium', UserRole.premium, authProvider),
                        const SizedBox(width: 8),
                        _buildRoleButton(
                            context, 'Admin', UserRole.admin, authProvider),
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
                        Icon(
                          Icons.analytics,
                          color: context.gc.mint,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Estatísticas de Uso',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: context.gc.mint,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStatRow('Feitiços salvos',
                        '${user.spellsCount}/${UserModel.freeSpellsLimit}'),
                    _buildStatRow('Diários este mês',
                        '${user.diaryEntriesThisMonth}/${UserModel.freeDiaryEntriesLimit}'),
                    _buildStatRow('Consultas IA hoje',
                        '${user.aiConsultationsToday}/${UserModel.freeAiConsultationsLimit}'),
                    _buildStatRow('Pêndulo hoje',
                        '${user.pendulumUsesToday}/${UserModel.dailyPendulumLimit}'),
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
                        Icon(
                          Icons.refresh,
                          color: context.gc.alert,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Ações de Reset',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: context.gc.alert,
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
                              SnackBar(
                                content: Text('Usuário resetado para padrão'),
                                backgroundColor: context.gc.alert,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.person_off),
                        label: const Text('Resetar Usuário'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.gc.alert,
                          side: BorderSide(color: context.gc.alert),
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
          backgroundColor:
              isSelected ? _getRoleColor(role) : context.gc.textPrimary.withValues(alpha: 0.1),
          foregroundColor: context.gc.textPrimary,
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
              color: context.gc.softWhite.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: context.gc.softWhite,
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
                Icon(Icons.star, size: 64, color: context.gc.lilac),
                const SizedBox(height: 16),
                Text(
                  'Mapa Astral',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: context.gc.lilac,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Testa cálculos astronômicos locais',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.gc.softWhite.withValues(alpha: 0.8),
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
                        color: context.gc.lilac,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _dateController,
                        style: TextStyle(color: context.gc.softWhite),
                        decoration: InputDecoration(
                          labelText: 'Data',
                          hintText: 'DD/MM/AAAA',
                          labelStyle: TextStyle(color: context.gc.lilac),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: context.gc.surfaceBorder),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: context.gc.lilac),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _timeController,
                        style: TextStyle(color: context.gc.softWhite),
                        decoration: InputDecoration(
                          labelText: 'Hora',
                          hintText: 'HH:MM',
                          labelStyle: TextStyle(color: context.gc.lilac),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: context.gc.surfaceBorder),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: context.gc.lilac),
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
                        color: context.gc.lilac,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _birthPlaceController,
                  focusNode: _birthPlaceFocusNode,
                  style: TextStyle(color: context.gc.softWhite),
                  decoration: InputDecoration(
                    hintText: 'Ex: Campinas, Bueno Brandão, São Paulo...',
                    hintStyle: TextStyle(
                      color: context.gc.softWhite.withValues(alpha: 0.5),
                    ),
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: context.gc.lilac,
                    ),
                    suffixIcon: _isSearchingLocation
                        ? Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  context.gc.lilac,
                                ),
                              ),
                            ),
                          )
                        : (_selectedLatitude != null &&
                                _selectedLongitude != null)
                            ? Icon(
                                Icons.check_circle,
                                color: context.gc.success,
                              )
                            : null,
                    filled: true,
                    fillColor: context.gc.cardBackground,
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
                      color: context.gc.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.gc.lilac.withValues(alpha: 0.3),
                      ),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _locationSuggestions.length,
                      separatorBuilder: (context, index) => Divider(
                        color: context.gc.lilac.withValues(alpha: 0.2),
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
                          leading: Icon(
                            Icons.place,
                            color: context.gc.lilac,
                            size: 20,
                          ),
                          title: Text(
                            displayText,
                            style: TextStyle(
                              color: context.gc.softWhite,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            coordsText,
                            style: TextStyle(
                              color: context.gc.softWhite.withValues(alpha: 0.6),
                              fontSize: 11,
                            ),
                          ),
                          onTap: () => _selectLocation(index),
                        );
                      },
                    ),
                  ),
                ],
                if (_selectedLatitude != null &&
                    _selectedLongitude != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.gc.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: context.gc.success.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: context.gc.success,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '✓ $_birthPlace\n'
                            'Lat: ${_selectedLatitude!.toStringAsFixed(4)}, Lon: ${_selectedLongitude!.toStringAsFixed(4)}',
                            style: TextStyle(
                              color: context.gc.success,
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
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          context.gc.darkBackground),
                    ),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(_isTesting ? 'Testando...' : 'Executar Teste'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.gc.lilac,
              foregroundColor: context.gc.darkBackground,
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
                      ? context.gc.success.withValues(alpha: 0.2)
                      : context.gc.alert.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _result!,
                  style: TextStyle(
                    color: _result!.contains('SUCESSO')
                        ? context.gc.success
                        : context.gc.alert,
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
                        color: context.gc.lilac,
                      ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, color: context.gc.lilac),
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
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: context.gc.softWhite,
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
                Icon(icon, size: 64, color: context.gc.lilac),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: context.gc.lilac,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.gc.softWhite.withValues(alpha: 0.8),
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
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          context.gc.darkBackground),
                    ),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(_isTesting ? 'Testando...' : 'Executar Teste'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.gc.lilac,
              foregroundColor: context.gc.darkBackground,
              padding: const EdgeInsets.symmetric(vertical: 16),
              disabledBackgroundColor: context.gc.lilac.withValues(alpha: 0.3),
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
                        ? context.gc.success
                        : _result!.startsWith('AVISO')
                            ? context.gc.starYellow
                            : context.gc.alert,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _result!,
                      style: TextStyle(
                        color: _result!.startsWith('SUCESSO')
                            ? context.gc.success
                            : _result!.startsWith('AVISO')
                                ? context.gc.starYellow
                                : context.gc.alert,
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
                    color: context.gc.lilac,
                  ),
            ),
            const SizedBox(height: 8),
            MagicalCard(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _logs.join('\n'),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: context.gc.softWhite,
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
