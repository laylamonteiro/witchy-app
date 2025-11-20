import 'package:dio/dio.dart';
import '../models/planet_position_model.dart';
import '../models/house_model.dart';
import '../models/enums.dart';

/// Serviço para calcular mapas astrais usando API externa (Prokerala)
///
/// Para obter uma API key gratuita (sem cartão de crédito):
/// 1. Acesse https://api.prokerala.com/
/// 2. Clique em "Sign Up" e crie uma conta gratuita
/// 3. Acesse o painel e copie sua API Key
/// 4. Substitua abaixo em _apiKey
///
/// Plano gratuito: Forever free, sem limite de tempo
class ExternalChartAPI {
  static final ExternalChartAPI instance = ExternalChartAPI._();

  ExternalChartAPI._();

  // TODO: Obtenha sua API key gratuita em: https://api.prokerala.com/
  static const _apiKey = 'SUBSTITUA_PELA_SUA_CHAVE_API_PROKERALA_AQUI';
  static const _userId = 'SUBSTITUA_PELO_SEU_USER_ID_AQUI';
  static const _baseUrl = 'https://api.prokerala.com/v2';

  final Dio _dio = Dio();

  /// Calcula mapa natal usando API externa
  Future<Map<String, dynamic>> calculateBirthChart({
    required DateTime birthDate,
    required double latitude,
    required double longitude,
    String houseSystem = 'placidus',
  }) async {
    try {
      // Formatar datetime no formato ISO 8601
      final datetime = birthDate.toIso8601String();

      // Construir URL do endpoint
      final url = '$_baseUrl/astrology/western/natal-chart';

      // Fazer requisição à API
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
        queryParameters: {
          'datetime': datetime,
          'coordinates': '$latitude,$longitude',
          'house_system': houseSystem,
          'la': 'en', // linguagem
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Erro na API: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception(
          'API key inválida. Obtenha uma chave gratuita em https://api.prokerala.com/',
        );
      } else if (e.response?.statusCode == 429) {
        throw Exception(
          'Limite de requisições excedido. Aguarde alguns minutos.',
        );
      } else if (e.response?.statusCode == 403) {
        throw Exception(
          'Acesso negado. Verifique suas credenciais da API.',
        );
      }
      throw Exception('Erro na conexão com a API: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao processar resposta da API: $e');
    }
  }

  /// Processa resposta da API e converte para nossos modelos
  Map<String, dynamic> parseAPIResponse(Map<String, dynamic> apiData) {
    try {
      final planets = <PlanetPosition>[];
      final houses = <House>[];

      // Extrair dados dos planetas
      if (apiData['data'] != null) {
        final data = apiData['data'];

        // Processar posições planetárias
        if (data['planet_positions'] != null) {
          final planetPositions = data['planet_positions'] as List;

          for (final planetData in planetPositions) {
            final planet = _parsePlanetFromAPI(planetData['name']);
            if (planet == null) continue;

            final longitude = (planetData['longitude'] as num).toDouble();
            final sign = ZodiacSign.fromLongitude(longitude);
            final degree = (longitude % 30).floor();
            final minute = ((longitude % 1) * 60).floor();
            final isRetrograde = planetData['is_retrograde'] ?? false;
            final speed = (planetData['speed'] as num?)?.toDouble() ?? 0.0;

            planets.add(PlanetPosition(
              planet: planet,
              sign: sign,
              degree: degree,
              minute: minute,
              houseNumber: planetData['house'] ?? 0,
              isRetrograde: isRetrograde,
              longitude: longitude,
              speed: speed,
            ));
          }
        }

        // Processar casas
        if (data['houses'] != null) {
          final housesData = data['houses'] as List;

          for (final houseData in housesData) {
            final number = houseData['house'] as int;
            final longitude = (houseData['longitude'] as num).toDouble();
            final sign = ZodiacSign.fromLongitude(longitude);
            final degree = (longitude % 30).floor();
            final minute = ((longitude % 1) * 60).floor();

            houses.add(House(
              number: number,
              sign: sign,
              degree: degree,
              minute: minute,
              cuspLongitude: longitude,
            ));
          }
        }

        // Extrair Ascendente e Meio do Céu dos ângulos
        PlanetPosition? ascendant;
        PlanetPosition? midheaven;

        if (data['angles'] != null) {
          final angles = data['angles'];

          if (angles['ascendant'] != null) {
            final ascLong = (angles['ascendant']['longitude'] as num).toDouble();
            final ascSign = ZodiacSign.fromLongitude(ascLong);

            ascendant = PlanetPosition(
              planet: Planet.sun, // Placeholder
              sign: ascSign,
              degree: (ascLong % 30).floor(),
              minute: ((ascLong % 1) * 60).floor(),
              houseNumber: 1,
              isRetrograde: false,
              longitude: ascLong,
              speed: 0,
            );
          }

          if (angles['midheaven'] != null) {
            final mcLong = (angles['midheaven']['longitude'] as num).toDouble();
            final mcSign = ZodiacSign.fromLongitude(mcLong);

            midheaven = PlanetPosition(
              planet: Planet.sun, // Placeholder
              sign: mcSign,
              degree: (mcLong % 30).floor(),
              minute: ((mcLong % 1) * 60).floor(),
              houseNumber: 10,
              isRetrograde: false,
              longitude: mcLong,
              speed: 0,
            );
          }
        }

        return {
          'planets': planets,
          'houses': houses,
          'ascendant': ascendant,
          'midheaven': midheaven,
        };
      }

      throw Exception('Formato de resposta da API inválido');
    } catch (e) {
      throw Exception('Erro ao processar dados da API: $e');
    }
  }

  /// Converte nome do planeta da API para nosso enum
  Planet? _parsePlanetFromAPI(String name) {
    final nameLower = name.toLowerCase();

    if (nameLower.contains('sun')) return Planet.sun;
    if (nameLower.contains('moon')) return Planet.moon;
    if (nameLower.contains('mercury')) return Planet.mercury;
    if (nameLower.contains('venus')) return Planet.venus;
    if (nameLower.contains('mars')) return Planet.mars;
    if (nameLower.contains('jupiter')) return Planet.jupiter;
    if (nameLower.contains('saturn')) return Planet.saturn;
    if (nameLower.contains('uranus')) return Planet.uranus;
    if (nameLower.contains('neptune')) return Planet.neptune;
    if (nameLower.contains('pluto')) return Planet.pluto;
    if (nameLower.contains('north') && nameLower.contains('node')) {
      return Planet.northNode;
    }
    if (nameLower.contains('south') && nameLower.contains('node')) {
      return Planet.southNode;
    }

    return null;
  }
}
