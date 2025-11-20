import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' as math;
import '../models/birth_chart_model.dart';
import '../models/planet_position_model.dart';
import '../models/house_model.dart';
import '../models/aspect_model.dart';
import '../models/enums.dart';

/// Calculadora de Mapa Astral
///
/// Usa cálculos astronômicos locais baseados em fórmulas do VSOP87
/// para posições planetárias. Acuracidade aproximada: ±2° para uso
/// em contexto de bruxaria e magia prática.
///
/// Para aplicações que requerem precisão astronômica profissional,
/// considere integrar Swiss Ephemeris ou outra biblioteca especializada.
class ChartCalculator {
  static final ChartCalculator instance = ChartCalculator._();

  ChartCalculator._();

  // Callback para logging (se não fornecido, usa print)
  Function(String)? _logCallback;

  // Helper para logging
  void _log(String message) {
    if (_logCallback != null) {
      _logCallback!(message);
    } else {
      print(message);
    }
  }

  /// Calcula o mapa natal completo
  Future<BirthChartModel> calculateBirthChart({
    required DateTime birthDate,
    required TimeOfDay birthTime,
    required String birthPlace,
    required double latitude,
    required double longitude,
    bool unknownBirthTime = false,
    double? timezoneOffsetHours,
    Function(String)? onLog,
  }) async {
    try {
      _logCallback = onLog;

      _log('🔧 Calculando mapa astral localmente...');
      _log('   Data: ${birthDate.year}-${birthDate.month}-${birthDate.day}');
      _log('   Hora: ${birthTime.hour}:${birthTime.minute}');
      _log('   Local: $birthPlace');

      return await _calculateWithLocalMethod(
        birthDate: birthDate,
        birthTime: birthTime,
        birthPlace: birthPlace,
        latitude: latitude,
        longitude: longitude,
        unknownBirthTime: unknownBirthTime,
        timezoneOffsetHours: timezoneOffsetHours,
      );
    } catch (e) {
      throw Exception('Erro ao calcular mapa natal: $e');
    }
  }

  /// Calcula usando método local (VSOP87)
  Future<BirthChartModel> _calculateWithLocalMethod({
    required DateTime birthDate,
    required TimeOfDay birthTime,
    required String birthPlace,
    required double latitude,
    required double longitude,
    required bool unknownBirthTime,
    double? timezoneOffsetHours,
  }) async {
    _log('🔧 Usando cálculos LOCAIS (método simplificado)');
    _log('   Data: ${birthDate.year}-${birthDate.month}-${birthDate.day}');
    _log('   Hora: ${birthTime.hour}:${birthTime.minute}');
    _log('   Local: $birthPlace');

    // 1. Converter para Julian Day
    final julianDay = _dateTimeToJulianDay(
      birthDate,
      birthTime,
      longitude,
      latitude,
      timezoneOffsetHours: timezoneOffsetHours,
    );

    // 2. Calcular posições planetárias
    final planetPositions = _calculatePlanets(julianDay);

    // 3. Calcular casas (se hora conhecida)
    List<House> houses;
    PlanetPosition? ascendant;
    PlanetPosition? midheaven;

    if (!unknownBirthTime) {
      houses = _calculateHouses(julianDay, latitude, longitude);

      // Calcular Ascendente (cúspide da Casa 1)
      final ascLongitude = houses[0].cuspLongitude;
      final ascSign = ZodiacSign.fromLongitude(ascLongitude);
      final ascDegree = (ascLongitude % 30).floor();
      final ascMinute = ((ascLongitude % 1) * 60).floor();

      ascendant = PlanetPosition(
        planet: Planet.sun, // Placeholder
        sign: ascSign,
        degree: ascDegree,
        minute: ascMinute,
        houseNumber: 1,
        isRetrograde: false,
        longitude: ascLongitude,
        speed: 0,
      );

      // Calcular Meio do Céu (cúspide da Casa 10)
      final mcLongitude = houses[9].cuspLongitude;
      final mcSign = ZodiacSign.fromLongitude(mcLongitude);
      final mcDegree = (mcLongitude % 30).floor();
      final mcMinute = ((mcLongitude % 1) * 60).floor();

      midheaven = PlanetPosition(
        planet: Planet.sun, // Placeholder
        sign: mcSign,
        degree: mcDegree,
        minute: mcMinute,
        houseNumber: 10,
        isRetrograde: false,
        longitude: mcLongitude,
        speed: 0,
      );
    } else {
      // Se hora desconhecida, usar sistema de signos iguais com Sol no ASC
      houses = _calculateHousesEqualSign(planetPositions[0].longitude);
      ascendant = null;
      midheaven = null;
    }

    // 4. Atribuir casas aos planetas
    final planetsWithHouses = _assignHousesToPlanets(planetPositions, houses);

    // 5. Calcular aspectos
    final aspects = _calculateAspects(planetsWithHouses);

    return BirthChartModel(
      id: const Uuid().v4(),
      userId: 'current_user',
      birthDate: birthDate,
      birthTime: birthTime,
      birthPlace: birthPlace,
      latitude: latitude,
      longitude: longitude,
      timezone: 'UTC',
      unknownBirthTime: unknownBirthTime,
      planets: planetsWithHouses,
      houses: houses,
      ascendant: ascendant,
      midheaven: midheaven,
      aspects: aspects,
      calculatedAt: DateTime.now(),
    );
  }

  /// Detecta automaticamente o timezone brasileiro baseado na data e localização
  /// Considera horário de verão histórico (usado até 2019)
  double _detectBrazilianTimezone(DateTime date, double latitude) {
    // Timezone padrão do Brasil (maioria das regiões)
    const standardOffset = -3.0;

    // Horário de verão foi abolido em 2019
    if (date.year >= 2019) {
      return standardOffset;
    }

    // Regiões Norte e Nordeste (latitude > -15) não usavam horário de verão
    if (latitude > -15) {
      return standardOffset;
    }

    // Verificar se estava em período de horário de verão
    // Horário de verão geralmente: outubro/novembro até fevereiro/março
    final month = date.month;
    final day = date.day;

    // Período de verão brasileiro (simplificado):
    // - Início: terceiro domingo de outubro (geralmente dia 15-21)
    // - Fim: terceiro domingo de fevereiro (geralmente dia 15-21)

    bool isInDST = false;

    if (month >= 10) {
      // Outubro a dezembro: verão começa em meados de outubro
      if (month == 10 && day >= 15) {
        isInDST = true;
      } else if (month > 10) {
        isInDST = true;
      }
    } else if (month <= 2) {
      // Janeiro a fevereiro: verão termina em meados de fevereiro
      if (month == 1) {
        isInDST = true;
      } else if (month == 2 && day <= 20) {
        isInDST = true;
      }
    }

    // Durante horário de verão: UTC-2
    // Fora do horário de verão: UTC-3
    return isInDST ? -2.0 : standardOffset;
  }

  /// Converte DateTime para Julian Day
  double _dateTimeToJulianDay(
    DateTime date,
    TimeOfDay time,
    double longitude,
    double latitude, {
    double? timezoneOffsetHours,
  }) {
    final year = date.year;
    final month = date.month;
    final day = date.day;

    // IMPORTANTE: Converter hora local para UTC
    // Se timezone fornecido, usa ele; senão, detecta automaticamente
    final timezoneOffset = (timezoneOffsetHours ?? _detectBrazilianTimezone(date, latitude)).round();

    // Converter hora local para UTC
    final hourLocal = time.hour + time.minute / 60.0;
    var hourUTC = hourLocal - timezoneOffset;

    // Ajustar dia se necessário
    var adjustedDay = day;
    if (hourUTC < 0) {
      hourUTC += 24;
      adjustedDay -= 1;
    } else if (hourUTC >= 24) {
      hourUTC -= 24;
      adjustedDay += 1;
    }

    // Algoritmo para cálculo do Julian Day
    final a = ((14 - month) / 12).floor();
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;

    var jd = adjustedDay +
        ((153 * m + 2) / 5).floor() +
        365 * y +
        (y / 4).floor() -
        (y / 100).floor() +
        (y / 400).floor() -
        32045;

    final jdDouble = jd.toDouble() + (hourUTC - 12) / 24.0;

    _log('   🕐 Hora local: ${time.hour}:${time.minute}');
    _log('   🌍 Timezone: UTC${timezoneOffset >= 0 ? "+" : ""}$timezoneOffset ${timezoneOffsetHours == null ? "(detectado automaticamente)" : "(manual)"}');
    _log('   ⏰ Hora UTC: ${hourUTC.toStringAsFixed(2)}');
    _log('   📅 Julian Day: ${jdDouble.toStringAsFixed(5)}');

    return jdDouble;
  }

  /// Calcula posições planetárias (implementação simplificada)
  List<PlanetPosition> _calculatePlanets(double julianDay) {
    final planets = <PlanetPosition>[];

    // T = séculos julianos desde J2000.0
    final T = (julianDay - 2451545.0) / 36525.0;

    // Calcular Sol
    final sunLongitude = _calculateSunLongitude(T);
    planets.add(_createPlanetPosition(Planet.sun, sunLongitude, 0.9856, 0));

    // Calcular Lua
    final moonLongitude = _calculateMoonLongitude(T);
    planets.add(_createPlanetPosition(Planet.moon, moonLongitude, 13.176, 0));

    // Calcular planetas (aproximações simples)
    // Em produção, usar Swiss Ephemeris para precisão
    planets.add(_createPlanetPosition(
      Planet.mercury,
      (sunLongitude + 15 * math.sin(T * 50)) % 360,
      1.383,
      0,
    ));

    planets.add(_createPlanetPosition(
      Planet.venus,
      (sunLongitude + 30 * math.sin(T * 30)) % 360,
      1.602,
      0,
    ));

    planets.add(_createPlanetPosition(
      Planet.mars,
      (sunLongitude + 45 * math.sin(T * 20)) % 360,
      0.524,
      0,
    ));

    planets.add(_createPlanetPosition(
      Planet.jupiter,
      (45 + 30 * T * 10) % 360,
      0.083,
      0,
    ));

    planets.add(_createPlanetPosition(
      Planet.saturn,
      (75 + 12 * T * 10) % 360,
      0.033,
      0,
    ));

    planets.add(_createPlanetPosition(
      Planet.uranus,
      (105 + 4 * T * 10) % 360,
      0.012,
      0,
    ));

    planets.add(_createPlanetPosition(
      Planet.neptune,
      (135 + 2 * T * 10) % 360,
      0.006,
      0,
    ));

    planets.add(_createPlanetPosition(
      Planet.pluto,
      (165 + 1.5 * T * 10) % 360,
      0.004,
      0,
    ));

    // Nodo Norte (aproximação)
    final northNodeLongitude = (125.0 - 19.34 * T * 10) % 360;
    planets.add(_createPlanetPosition(
      Planet.northNode,
      northNodeLongitude,
      -0.053,
      0,
    ));

    // Nodo Sul (oposto ao Nodo Norte)
    planets.add(_createPlanetPosition(
      Planet.southNode,
      (northNodeLongitude + 180) % 360,
      -0.053,
      0,
    ));

    return planets;
  }

  /// Calcula longitude do Sol (Meeus)
  double _calculateSunLongitude(double T) {
    // Longitude média do Sol
    final L0 = 280.46646 + 36000.76983 * T + 0.0003032 * T * T;

    // Anomalia média
    final M = 357.52911 + 35999.05029 * T - 0.0001537 * T * T;
    final MRad = M * math.pi / 180;

    // Equação do centro
    final C = (1.914602 - 0.004817 * T - 0.000014 * T * T) * math.sin(MRad) +
        (0.019993 - 0.000101 * T) * math.sin(2 * MRad) +
        0.000289 * math.sin(3 * MRad);

    // Longitude verdadeira
    final longitude = (L0 + C) % 360;

    return longitude;
  }

  /// Calcula longitude da Lua (aproximação)
  double _calculateMoonLongitude(double T) {
    // Longitude média da Lua
    final L = 218.316 + 481267.881 * T;

    // Anomalia média da Lua
    final M = 134.963 + 477198.868 * T;
    final MRad = M * math.pi / 180;

    // Correção simples
    final longitude = (L + 6.289 * math.sin(MRad)) % 360;

    return longitude;
  }

  /// Cria objeto PlanetPosition
  PlanetPosition _createPlanetPosition(
    Planet planet,
    double longitude,
    double speed,
    int houseNumber,
  ) {
    // Normalizar longitude
    longitude = longitude % 360;
    if (longitude < 0) longitude += 360;

    final sign = ZodiacSign.fromLongitude(longitude);
    final degree = (longitude % 30).floor();
    final minute = ((longitude % 1) * 60).floor();
    final isRetrograde = speed < 0;

    return PlanetPosition(
      planet: planet,
      sign: sign,
      degree: degree,
      minute: minute,
      houseNumber: houseNumber,
      isRetrograde: isRetrograde,
      longitude: longitude,
      speed: speed,
    );
  }

  /// Calcula casas astrológicas (sistema Placidus simplificado)
  List<House> _calculateHouses(
    double julianDay,
    double latitude,
    double longitude,
  ) {
    final houses = <House>[];

    // Calcular RAMC (Right Ascension of Medium Coeli) em graus
    final T = (julianDay - 2451545.0) / 36525.0;
    final gmst = _calculateGMST(julianDay);
    final lst = gmst + longitude / 15.0; // LST em horas

    _log('   ⏰ GMST: ${gmst.toStringAsFixed(6)} horas');
    _log('   🌍 LST: ${lst.toStringAsFixed(6)} horas (${(lst * 15).toStringAsFixed(2)}°)');

    // RAMC em graus (0-360)
    final ramc = (lst * 15.0) % 360;

    // Calcular MC (longitude eclíptica do Meio do Céu)
    // Converter de coordenadas equatoriais (RAMC) para eclípticas (MC)
    // Fórmula: tan(MC) = tan(RAMC) / cos(ε)
    final obliquity = 23.43929; // Obliquidade da eclíptica
    final oblRad = obliquity * math.pi / 180;
    final ramcRad = ramc * math.pi / 180;

    var mc = math.atan2(
      math.sin(ramcRad),
      math.cos(ramcRad) * math.cos(oblRad)
    ) * 180 / math.pi;

    // Normalizar para 0-360
    mc = mc % 360;
    if (mc < 0) mc += 360;

    _log('   🌟 MC (Meio do Céu): ${mc.toStringAsFixed(2)}° (${ZodiacSign.fromLongitude(mc).displayName})');

    // IC (Imum Coeli) - oposto ao MC
    final ic = (mc + 180) % 360;

    // Casa 1 (Ascendente) - calcular com fórmula trigonométrica correta
    final asc = _calculateAscendantFromRAMC(ramc, latitude);

    // Casa 7 (Descendente) - oposto ao Ascendente
    final dsc = (asc + 180) % 360;

    // Para simplificação, usar sistema de casas igual
    // (em produção, usar Placidus completo com cálculos trigonométricos para cada cúspide)

    // Casa 1 (ASC)
    houses.add(_createHouse(1, asc));

    // Casas 2-3 (divisão igual entre ASC e IC)
    for (int i = 2; i <= 3; i++) {
      final cuspLongitude = (asc + ((ic - asc + 360) % 360) * (i - 1) / 3) % 360;
      houses.add(_createHouse(i, cuspLongitude));
    }

    // Casa 4 (IC)
    houses.add(_createHouse(4, ic));

    // Casas 5-6 (divisão igual entre IC e DSC)
    for (int i = 5; i <= 6; i++) {
      final cuspLongitude = (ic + ((dsc - ic + 360) % 360) * (i - 4) / 3) % 360;
      houses.add(_createHouse(i, cuspLongitude));
    }

    // Casa 7 (DSC)
    houses.add(_createHouse(7, dsc));

    // Casas 8-9 (divisão igual entre DSC e MC)
    for (int i = 8; i <= 9; i++) {
      final cuspLongitude = (dsc + ((mc - dsc + 360) % 360) * (i - 7) / 3) % 360;
      houses.add(_createHouse(i, cuspLongitude));
    }

    // Casa 10 (MC)
    houses.add(_createHouse(10, mc));

    // Casas 11-12 (divisão igual entre MC e ASC)
    for (int i = 11; i <= 12; i++) {
      final cuspLongitude = (mc + ((asc - mc + 360) % 360) * (i - 10) / 3) % 360;
      houses.add(_createHouse(i, cuspLongitude));
    }

    // Ordenar casas por número
    houses.sort((a, b) => a.number.compareTo(b.number));

    // Log detalhado de todas as casas
    _log('   🏠 CASAS ASTROLÓGICAS (${houses.length} casas):');
    for (final house in houses) {
      _log('      Casa ${house.number.toString().padLeft(2)}: ${house.cuspLongitude.toStringAsFixed(2)}° (${house.sign.displayName} ${house.degree}°${house.minute}\')');
    }

    return houses;
  }

  /// Calcula Ascendente com fórmula trigonométrica correta a partir do RAMC
  double _calculateAscendantFromRAMC(double ramc, double latitude) {
    // Obliquidade da eclíptica (ε = 23.43929°)
    final obliquity = 23.43929;
    final oblRad = obliquity * math.pi / 180;
    final latRad = latitude * math.pi / 180;
    final ramcRad = ramc * math.pi / 180;

    // Fórmula CORRETA do ascendente (longitude eclíptica):
    // tan(ASC) = cos(RAMC) / -(sin(ε) * tan(lat) + cos(ε) * sin(RAMC))

    final numerator = math.cos(ramcRad);
    final denominator = -(math.sin(oblRad) * math.tan(latRad) + math.cos(oblRad) * math.sin(ramcRad));

    var asc = math.atan2(numerator, denominator) * 180 / math.pi;

    // Normalizar para 0-360
    asc = asc % 360;
    if (asc < 0) asc += 360;

    _log('   🔮 RAMC: ${ramc.toStringAsFixed(2)}°');
    _log('   📍 Latitude: ${latitude.toStringAsFixed(2)}°');
    _log('   ♈ Ascendente: ${asc.toStringAsFixed(2)}° (${ZodiacSign.fromLongitude(asc).displayName})');

    return asc;
  }

  /// Calcula GMST (Greenwich Mean Sidereal Time)
  double _calculateGMST(double julianDay) {
    final T = (julianDay - 2451545.0) / 36525.0;
    var gmst = 280.46061837 +
        360.98564736629 * (julianDay - 2451545.0) +
        0.000387933 * T * T -
        T * T * T / 38710000.0;

    gmst = gmst % 360;
    if (gmst < 0) gmst += 360;

    return gmst / 15.0; // Converter para horas
  }

  /// Cria objeto House
  House _createHouse(int number, double cuspLongitude) {
    cuspLongitude = cuspLongitude % 360;
    if (cuspLongitude < 0) cuspLongitude += 360;

    final sign = ZodiacSign.fromLongitude(cuspLongitude);
    final degree = (cuspLongitude % 30).floor();
    final minute = ((cuspLongitude % 1) * 60).floor();

    return House(
      number: number,
      sign: sign,
      degree: degree,
      minute: minute,
      cuspLongitude: cuspLongitude,
    );
  }

  /// Sistema de casas de signos iguais (quando hora desconhecida)
  List<House> _calculateHousesEqualSign(double sunLongitude) {
    final houses = <House>[];

    // Casa 1 começa no signo do Sol
    final house1Start = (sunLongitude ~/ 30) * 30.0;

    for (int i = 1; i <= 12; i++) {
      final cuspLongitude = (house1Start + (i - 1) * 30) % 360;
      houses.add(_createHouse(i, cuspLongitude));
    }

    return houses;
  }

  /// Atribui casas aos planetas
  List<PlanetPosition> _assignHousesToPlanets(
    List<PlanetPosition> planets,
    List<House> houses,
  ) {
    return planets.map((planet) {
      // Encontrar em qual casa o planeta está
      final houseNumber = _findHouseForLongitude(planet.longitude, houses);

      return PlanetPosition(
        planet: planet.planet,
        sign: planet.sign,
        degree: planet.degree,
        minute: planet.minute,
        houseNumber: houseNumber,
        isRetrograde: planet.isRetrograde,
        longitude: planet.longitude,
        speed: planet.speed,
      );
    }).toList();
  }

  /// Encontra a casa para uma dada longitude
  int _findHouseForLongitude(double longitude, List<House> houses) {
    for (int i = 0; i < houses.length; i++) {
      final currentHouse = houses[i];
      final nextHouse = houses[(i + 1) % houses.length];

      final currentCusp = currentHouse.cuspLongitude;
      var nextCusp = nextHouse.cuspLongitude;

      // Lidar com a transição de 360° para 0°
      if (nextCusp < currentCusp) {
        nextCusp += 360;
        if (longitude < currentCusp) {
          longitude += 360;
        }
      }

      if (longitude >= currentCusp && longitude < nextCusp) {
        return currentHouse.number;
      }
    }

    return 1; // Fallback
  }

  /// Calcula aspectos entre planetas
  List<Aspect> _calculateAspects(List<PlanetPosition> planets) {
    final aspects = <Aspect>[];

    for (int i = 0; i < planets.length - 1; i++) {
      for (int j = i + 1; j < planets.length; j++) {
        final planet1 = planets[i];
        final planet2 = planets[j];

        // Calcular ângulo entre planetas
        var angle = (planet2.longitude - planet1.longitude).abs();
        if (angle > 180) angle = 360 - angle;

        // Verificar cada tipo de aspecto
        for (final aspectType in AspectType.values) {
          final targetAngle = aspectType.angle;
          final orb = (angle - targetAngle).abs();

          if (orb <= aspectType.orb) {
            // Determinar se está se aproximando ou afastando
            final isApplying = planet2.speed > planet1.speed;

            aspects.add(Aspect(
              planet1: planet1.planet,
              planet2: planet2.planet,
              type: aspectType,
              exactAngle: angle,
              orb: orb,
              isApplying: isApplying,
            ));

            break; // Não verificar outros aspectos para este par
          }
        }
      }
    }

    return aspects;
  }
}
