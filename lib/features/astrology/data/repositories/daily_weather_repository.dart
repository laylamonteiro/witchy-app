import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/ai/ai_service.dart';
import '../../../../core/services/data_sync_service.dart';
import '../data_sources/daily_weather_content.dart';
import '../models/enums.dart';
import '../models/transit_model.dart';
import '../models/birth_chart_model.dart';
import '../services/transit_interpreter.dart';

/// Modelo para armazenar clima mágico diário com IA
class DailyWeatherCache {
  final String id;
  final String date; // formato YYYY-MM-DD
  final String aiGeneratedText;
  final DailyMagicalWeather weatherData;
  final DateTime createdAt;
  final String userId;
  final String contextKey;

  DailyWeatherCache({
    required this.id,
    required this.date,
    required this.aiGeneratedText,
    required this.weatherData,
    required this.createdAt,
    required this.userId,
    required this.contextKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date,
      'ai_generated_text': aiGeneratedText,
      'weather_data': jsonEncode(
        _weatherDataToJson(weatherData, contextKey),
      ),
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': createdAt.millisecondsSinceEpoch,
      'synced': 0,
    };
  }

  static Map<String, dynamic> _weatherDataToJson(
    DailyMagicalWeather weather,
    String contextKey,
  ) {
    return {
      'contextKey': contextKey,
      'moonPhase': weather.moonPhase,
      'moonSign': weather.moonSign.name,
      'overallEnergy': weather.overallEnergy.name,
      'energyKeywords': weather.energyKeywords,
      'generalInterpretation': weather.generalInterpretation,
      'recommendedPractices': weather.recommendedPractices,
      'transits': weather.transits
          .map((t) => {
                'planet': t.planet.name,
                'sign': t.sign.name,
                'degree': t.degree,
                'isRetrograde': t.isRetrograde,
              })
          .toList(),
      'aspects': weather.aspects
          .map((a) => {
                'transitPlanet': a.transitPlanet.name,
                'natalPlanet': a.natalPlanet.name,
                'aspectType': a.aspectType.name,
                'orb': a.orb,
                'interpretation': a.interpretation,
                'energyLevel': a.energyLevel.name,
              })
          .toList(),
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
      userId: json['user_id'] ?? 'local_user',
      contextKey: weatherJson['contextKey'] ?? 'general',
    );
  }

  static DailyMagicalWeather _weatherDataFromJson(
      Map<String, dynamic> json, String dateStr) {
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
      overallEnergy:
          EnergyLevel.values.firstWhere((e) => e.name == json['overallEnergy']),
      energyKeywords: List<String>.from(json['energyKeywords']),
      generalInterpretation: json['generalInterpretation'],
      recommendedPractices: List<String>.from(json['recommendedPractices']),
      transits: (json['transits'] as List)
          .map((t) => Transit(
                planet: Planet.values.firstWhere((p) => p.name == t['planet']),
                sign: ZodiacSign.values.firstWhere((z) => z.name == t['sign']),
                degree: (t['degree'] as num).toDouble(),
                isRetrograde: t['isRetrograde'],
              ))
          .toList(),
      aspects: (json['aspects'] as List)
          .map((a) => TransitAspect(
                transitPlanet: Planet.values
                    .firstWhere((p) => p.name == a['transitPlanet']),
                natalPlanet:
                    Planet.values.firstWhere((p) => p.name == a['natalPlanet']),
                aspectType: AspectType.values
                    .firstWhere((t) => t.name == a['aspectType']),
                orb: (a['orb'] as num).toDouble(),
                interpretation: a['interpretation'],
                energyLevel: EnergyLevel.values
                    .firstWhere((e) => e.name == a['energyLevel']),
              ))
          .toList(),
    );
  }
}

/// Repositório para gerenciar clima mágico diário com cache de IA
class DailyWeatherRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final AIService _aiService = AIService.instance;
  final TransitInterpreter _interpreter = TransitInterpreter();
  final DataSyncService _syncService = DataSyncService();

  /// Formata data para string YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Chave de contexto do cache: 'general' sem mapa natal, senão o hash do
  /// mapa. Público para que leitores externos (ex.: card do Seu Dia) consultem
  /// o cache com a MESMA chave usada na geração.
  static String contextKeyFor(BirthChartModel? natalChart) {
    return natalChart == null
        ? 'general'
        : sha256.convert(utf8.encode(natalChart.toJsonString())).toString();
  }

  /// Verifica se já existe clima para o dia
  Future<DailyWeatherCache?> getCachedWeather(
    DateTime date,
    String userId,
    String contextKey,
  ) async {
    final dateStr = _formatDate(date);
    final db = await _db.database;

    final results = await db.query(
      'daily_magical_weather',
      where: 'date = ? AND user_id = ?',
      whereArgs: [dateStr, userId],
    );

    if (results.isEmpty) return null;

    final cache = DailyWeatherCache.fromJson(results.first);
    return cache.contextKey == contextKey ? cache : null;
  }

  /// Salva clima no cache — e apaga o resto.
  ///
  /// O clima vale por UM dia e nenhuma tela lê data passada, então guardar
  /// o histórico só engordava o banco (e a nuvem) para sempre: fica
  /// exatamente uma linha por pessoa, substituída a cada recálculo.
  Future<void> saveWeatherCache(DailyWeatherCache cache) async {
    final db = await _db.database;

    final data = cache.toJson();
    await db.insert(
      'daily_magical_weather',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await keepOnlyDate(cache.userId, cache.date);
    await _syncService.syncItem(SyncEntity.dailyMagicalWeather, data);
    await _syncService.pruneOtherDays(
      SyncEntity.dailyMagicalWeather,
      cache.date,
    );
  }

  /// Mantém só o dia informado no cache da pessoa.
  Future<void> keepOnlyDate(String userId, String date) async {
    final db = await _db.database;
    await db.delete(
      'daily_magical_weather',
      where: 'user_id = ? AND date != ?',
      whereArgs: [userId, date],
    );
  }

  /// Gera e retorna clima mágico diário
  /// Se já existe para hoje, retorna do cache
  /// Se não existe, gera com IA e salva
  ///
  /// [withAiText] é o gate do produto pago: a previsão escrita é Premium, e
  /// texto Premium não é gerado nem devolvido para quem não tem acesso
  /// (fail-closed — não adianta esconder na tela o que já está no aparelho).
  /// Sem acesso, volta só o [DailyMagicalWeather] calculado localmente, que
  /// é a matéria-prima da degustação; a chamada de IA cara nem acontece.
  Future<DailyWeatherCache> getDailyWeather(
    DateTime date, {
    required String userId,
    required bool withAiText,
    BirthChartModel? natalChart,
  }) async {
    final contextKey = contextKeyFor(natalChart);
    // Verificar cache primeiro. Um cache incompleto (ex.: fallback antigo com
    // menos seções, salvo quando a IA estava indisponível) é tratado como
    // obsoleto e regerado.
    final cached = await getCachedWeather(date, userId, contextKey);
    if (withAiText &&
        cached != null &&
        DailyWeatherContent.looksComplete(cached.aiGeneratedText)) {
      return cached;
    }

    // Calcular dados astrológicos do dia
    final weatherData = await _interpreter.getDailyMagicalWeather(
      date,
      natalChart: natalChart,
    );

    // Sem acesso: devolve os fatos do céu e para por aqui. Um texto salvo de
    // uma assinatura antiga também não volta — o acesso é conferido agora.
    if (!withAiText) {
      return DailyWeatherCache(
        id: const Uuid().v4(),
        date: _formatDate(date),
        aiGeneratedText: '',
        weatherData: weatherData,
        createdAt: DateTime.now(),
        userId: userId,
        contextKey: contextKey,
      );
    }

    // Gerar texto com IA
    String aiText;
    bool usedFallback = false;
    try {
      aiText = await _aiService.generateDailyMagicalWeatherText(
        moonPhase: weatherData.moonPhase,
        moonSign: weatherData.moonSign,
        overallEnergy: weatherData.overallEnergy,
        energyKeywords: weatherData.energyKeywords,
        transits: _transitsForAI(weatherData),
        aspects: _aspectsForAI(weatherData),
      );
    } catch (e) {
      // Usar interpretação padrão se IA falhar
      aiText = DailyWeatherContent.fallbackText(weatherData);
      usedFallback = true;
    }

    // Criar cache
    final cache = DailyWeatherCache(
      id: const Uuid().v4(),
      date: _formatDate(date),
      aiGeneratedText: aiText,
      weatherData: weatherData,
      createdAt: DateTime.now(),
      userId: userId,
      contextKey: contextKey,
    );

    // Só persiste quando o texto veio da IA. Assim um fallback (ex.: IA fora do
    // ar por rate limit) não fica preso no cache o dia inteiro — a IA é tentada
    // novamente na próxima abertura.
    if (!usedFallback) {
      await saveWeatherCache(cache);
    }

    return cache;
  }

  /// Degustação da previsão para quem não tem acesso: 2 frases REAIS tiradas
  /// dos mesmos fatos do céu. Chamada curta — a previsão completa continua
  /// sem existir no aparelho. Cabe a quem chama cachear por dia.
  Future<String> generateTeaser(DailyMagicalWeather weatherData) {
    return _aiService.generateDailyWeatherTeaser(
      moonPhase: weatherData.moonPhase,
      moonSign: weatherData.moonSign,
      overallEnergy: weatherData.overallEnergy,
      energyKeywords: weatherData.energyKeywords,
      transits: _transitsForAI(weatherData),
      aspects: _aspectsForAI(weatherData),
    );
  }

  List<Map<String, String>> _transitsForAI(DailyMagicalWeather weatherData) =>
      weatherData.transits
          .map((t) => {
                'planet': t.planet.displayName,
                'position': t.formattedPosition,
                'retrograde': t.isRetrograde.toString(),
              })
          .toList();

  List<Map<String, String>> _aspectsForAI(DailyMagicalWeather weatherData) =>
      weatherData.aspects.map((a) => {'description': a.description}).toList();

}
