import 'package:dio/dio.dart';
import '../models/planet_position_model.dart';
import '../models/house_model.dart';
import '../models/enums.dart';
import 'prokerala_credentials.dart';

/// Serviço para calcular mapas astrais usando API externa (Prokerala)
///
/// Autenticação: OAuth 2.0 Client Credentials
///
/// ⚠️ SEGURANÇA:
/// As credenciais agora estão em um arquivo separado (prokerala_credentials.dart)
/// que NÃO é commitado no Git (protegido pelo .gitignore).
///
/// Para configurar suas próprias credenciais:
/// 1. Copie prokerala_credentials.example.dart para prokerala_credentials.dart
/// 2. Edite prokerala_credentials.dart com suas credenciais reais
/// 3. Obtenha credenciais gratuitas em https://api.prokerala.com/
class ExternalChartAPI {
  static final ExternalChartAPI instance = ExternalChartAPI._();

  ExternalChartAPI._();

  // Credenciais OAuth 2.0 (importadas de arquivo seguro)
  static final _clientId = ProkeralaCredentials.clientId;
  static final _clientSecret = ProkeralaCredentials.clientSecret;
  static const _tokenUrl = 'https://api.prokerala.com/token';
  static const _baseUrl = 'https://api.prokerala.com/v2';

  final Dio _dio = Dio();

  // Cache do token de acesso
  String? _accessToken;
  DateTime? _tokenExpiry;

  /// Obtém token de acesso OAuth 2.0
  Future<String> _getAccessToken() async {
    // Se já temos um token válido, retorná-lo
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      print('🔑 Usando token em cache (ainda válido)');
      return _accessToken!;
    }

    print('🔑 Solicitando novo token OAuth 2.0...');
    try {
      // Requisitar novo token usando Client Credentials
      final response = await _dio.post(
        _tokenUrl,
        data: {
          'grant_type': 'client_credentials',
          'client_id': _clientId,
          'client_secret': _clientSecret,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      print('🔑 Resposta do token: status=${response.statusCode}');

      if (response.statusCode == 200) {
        _accessToken = response.data['access_token'];

        // Calcular expiração (geralmente 3600 segundos = 1 hora)
        final expiresIn = response.data['expires_in'] ?? 3600;
        _tokenExpiry = DateTime.now().add(
          Duration(seconds: expiresIn - 60), // Renovar 1 min antes
        );

        print('✅ Token obtido com sucesso! Expira em $expiresIn segundos');
        return _accessToken!;
      } else {
        throw Exception('Erro ao obter token: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Erro ao obter token: ${e.response?.statusCode} - ${e.message}');
      print('Resposta: ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception(
          'Credenciais inválidas. Verifique Client ID e Secret.',
        );
      }
      throw Exception('Erro na autenticação: ${e.message}');
    }
  }

  /// Calcula mapa natal usando API externa
  Future<Map<String, dynamic>> calculateBirthChart({
    required DateTime birthDate,
    required double latitude,
    required double longitude,
    String houseSystem = 'placidus',
  }) async {
    try {
      print('📍 Calculando mapa: $birthDate, lat=$latitude, long=$longitude');

      // Obter token de acesso
      final accessToken = await _getAccessToken();

      // Formatar datetime no formato ISO 8601
      final datetime = birthDate.toIso8601String();
      print('📅 DateTime formatado: $datetime');

      // Construir URL do endpoint
      final url = '$_baseUrl/astrology/western/natal-chart';
      print('🌐 Endpoint: $url');

      // Fazer requisição à API
      print('📡 Fazendo requisição...');
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
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

      print('📊 Resposta da API: status=${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Resposta recebida com sucesso!');
        return response.data;
      } else {
        throw Exception('Erro na API: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.statusCode} - ${e.message}');
      print('Resposta da API: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        // Token expirado, limpar cache e tentar novamente
        _accessToken = null;
        _tokenExpiry = null;
        throw Exception(
          'Token expirado. Tente novamente.',
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
      print('❌ Exceção geral: $e');
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
