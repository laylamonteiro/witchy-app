import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/ai/ai_service.dart';
import '../models/enums.dart';
import '../models/transit_model.dart';
import '../services/transit_interpreter.dart';

/// Modelo para armazenar clima mágico diário com IA
class DailyWeatherCache {
  final String id;
  final String date; // formato YYYY-MM-DD
  final String aiGeneratedText;
  final DailyMagicalWeather weatherData;
  final DateTime createdAt;

  DailyWeatherCache({
    required this.id,
    required this.date,
    required this.aiGeneratedText,
    required this.weatherData,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'ai_generated_text': aiGeneratedText,
      'weather_data': jsonEncode(_weatherDataToJson(weatherData)),
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  static Map<String, dynamic> _weatherDataToJson(DailyMagicalWeather weather) {
    return {
      'moonPhase': weather.moonPhase,
      'moonSign': weather.moonSign.name,
      'overallEnergy': weather.overallEnergy.name,
      'energyKeywords': weather.energyKeywords,
      'generalInterpretation': weather.generalInterpretation,
      'recommendedPractices': weather.recommendedPractices,
      'transits': weather.transits.map((t) => {
        'planet': t.planet.name,
        'sign': t.sign.name,
        'degree': t.degree,
        'isRetrograde': t.isRetrograde,
      }).toList(),
      'aspects': weather.aspects.map((a) => {
        'transitPlanet': a.transitPlanet.name,
        'natalPlanet': a.natalPlanet.name,
        'aspectType': a.aspectType.name,
        'orb': a.orb,
        'interpretation': a.interpretation,
        'energyLevel': a.energyLevel.name,
      }).toList(),
    };
  }

  factory DailyWeatherCache.fromJson(Map<String, dynamic> json) {
    final weatherJson = jsonDecode(json['weather_data']);
    return DailyWeatherCache(
      id: json['id'],
      date: json['date'],
      aiGeneratedText: json['ai_generated_text'],
      weatherData: _weatherDataFromJson(weatherJson, json['date']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
    );
  }

  static DailyMagicalWeather _weatherDataFromJson(Map<String, dynamic> json, String dateStr) {
    final dateParts = dateStr.split('-');
    final date = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
    );

    return DailyMagicalWeather(
      date: date,
      moonPhase: json['moonPhase'],
      moonSign: ZodiacSign.values.firstWhere((z) => z.name == json['moonSign']),
      overallEnergy: EnergyLevel.values.firstWhere((e) => e.name == json['overallEnergy']),
      energyKeywords: List<String>.from(json['energyKeywords']),
      generalInterpretation: json['generalInterpretation'],
      recommendedPractices: List<String>.from(json['recommendedPractices']),
      transits: (json['transits'] as List).map((t) => Transit(
        planet: Planet.values.firstWhere((p) => p.name == t['planet']),
        sign: ZodiacSign.values.firstWhere((z) => z.name == t['sign']),
        degree: (t['degree'] as num).toDouble(),
        isRetrograde: t['isRetrograde'],
      )).toList(),
      aspects: (json['aspects'] as List).map((a) => TransitAspect(
        transitPlanet: Planet.values.firstWhere((p) => p.name == a['transitPlanet']),
        natalPlanet: Planet.values.firstWhere((p) => p.name == a['natalPlanet']),
        aspectType: AspectType.values.firstWhere((t) => t.name == a['aspectType']),
        orb: (a['orb'] as num).toDouble(),
        interpretation: a['interpretation'],
        energyLevel: EnergyLevel.values.firstWhere((e) => e.name == a['energyLevel']),
      )).toList(),
    );
  }
}

/// Repositório para gerenciar clima mágico diário com cache de IA
class DailyWeatherRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final AIService _aiService = AIService.instance;
  final TransitInterpreter _interpreter = TransitInterpreter();

  /// Formata data para string YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Verifica se já existe clima para o dia
  Future<DailyWeatherCache?> getCachedWeather(DateTime date) async {
    final dateStr = _formatDate(date);
    final db = await _db.database;

    final results = await db.query(
      'daily_magical_weather',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (results.isEmpty) return null;

    return DailyWeatherCache.fromJson(results.first);
  }

  /// Salva clima no cache
  Future<void> saveWeatherCache(DailyWeatherCache cache) async {
    final db = await _db.database;

    await db.insert(
      'daily_magical_weather',
      cache.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Gera e retorna clima mágico diário
  /// Se já existe para hoje, retorna do cache
  /// Se não existe, gera com IA e salva
  Future<DailyWeatherCache> getDailyWeather(DateTime date) async {
    // Verificar cache primeiro
    final cached = await getCachedWeather(date);
    if (cached != null) {
      print('✅ Clima mágico encontrado no cache para ${_formatDate(date)}');
      return cached;
    }

    print('🔮 Gerando novo clima mágico para ${_formatDate(date)}');

    // Calcular dados astrológicos do dia
    final weatherData = await _interpreter.getDailyMagicalWeather(date);

    // Preparar dados para IA
    final transitsForAI = weatherData.transits.map((t) => {
      'planet': t.planet.displayName,
      'position': t.formattedPosition,
      'retrograde': t.isRetrograde.toString(),
    }).toList();

    final aspectsForAI = weatherData.aspects.map((a) => {
      'description': a.description,
    }).toList();

    // Gerar texto com IA
    String aiText;
    try {
      aiText = await _aiService.generateDailyMagicalWeatherText(
        moonPhase: weatherData.moonPhase,
        moonSign: weatherData.moonSign,
        overallEnergy: weatherData.overallEnergy,
        energyKeywords: weatherData.energyKeywords,
        transits: transitsForAI.cast<Map<String, String>>(),
        aspects: aspectsForAI.cast<Map<String, String>>(),
      );
    } catch (e) {
      print('❌ Erro ao gerar texto IA: $e');
      // Usar interpretação padrão se IA falhar
      aiText = _generateFallbackText(weatherData);
    }

    // Criar cache
    final cache = DailyWeatherCache(
      id: const Uuid().v4(),
      date: _formatDate(date),
      aiGeneratedText: aiText,
      weatherData: weatherData,
      createdAt: DateTime.now(),
    );

    // Salvar no banco
    await saveWeatherCache(cache);
    print('✅ Clima mágico salvo no cache');

    return cache;
  }

  /// Texto fallback se IA falhar
  String _generateFallbackText(DailyMagicalWeather weather) {
    return '''## Energia do Dia

${weather.generalInterpretation}

## A Lua Hoje

A Lua está em ${weather.moonSign.displayName}, trazendo energias do elemento ${weather.moonSign.element.displayName}.
Fase atual: ${weather.moonPhase}.

## Oportunidades Mágicas

${weather.recommendedPractices.map((p) => '- $p').join('\n')}

## Cristais e Aliados

- Quartzo transparente (equilíbrio geral)
- Ametista (proteção espiritual)
- Pedra da Lua (conexão lunar)

## Mensagem das Estrelas

Permita que as energias celestiais guiem seu caminho hoje. Confie em sua intuição e siga o fluxo do universo.
''';
  }

  /// Limpa caches antigos (mais de 7 dias)
  Future<void> cleanOldCache() async {
    final db = await _db.database;
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final dateStr = _formatDate(sevenDaysAgo);

    await db.delete(
      'daily_magical_weather',
      where: 'date < ?',
      whereArgs: [dateStr],
    );
  }
}
