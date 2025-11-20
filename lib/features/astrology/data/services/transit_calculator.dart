import 'dart:math';
import '../models/enums.dart';
import '../models/transit_model.dart';
import '../models/planet_position_model.dart';
import '../models/birth_chart_model.dart';

/// Calcula trânsitos planetários em tempo real
class TransitCalculator {
  /// Calcula as posições dos planetas para uma data específica
  Future<List<Transit>> calculateTransits(DateTime date) async {
    print('🌟 Calculando trânsitos para: $date');
    final transits = <Transit>[];

    try {
      // Calcular posição de cada planeta para a data
      for (final planet in Planet.values) {
        if (planet == Planet.northNode || planet == Planet.southNode) {
          continue; // Skip nodes for simplicity
        }

        try {
          final position = _calculatePlanetPosition(planet, date);

          // Verificar se a posição é válida
          if (!position.longitude.isNaN && !position.longitude.isInfinite) {
            transits.add(Transit(
              planet: planet,
              sign: position.sign,
              degree: position.degree.toDouble(),
              isRetrograde: position.isRetrograde,
            ));
            print('  ✓ ${planet.name}: ${position.sign.name} ${position.degree}°');
          } else {
            print('  ✗ ${planet.name}: posição inválida (NaN/Infinite)');
          }
        } catch (e) {
          print('  ✗ ${planet.name}: erro - $e');
          // Continua com os outros planetas
        }
      }

      print('✅ Total de trânsitos calculados: ${transits.length}');
      return transits;
    } catch (e) {
      print('❌ Erro em calculateTransits: $e');
      rethrow;
    }
  }

  /// Calcula aspectos entre trânsitos e mapa natal
  Future<List<TransitAspect>> calculateTransitAspects(
    List<Transit> transits,
    BirthChartModel natalChart,
  ) async {
    final aspects = <TransitAspect>[];

    // Para cada planeta em trânsito
    for (final transit in transits) {
      final transitLongitude =
          _getAbsoluteLongitude(transit.sign, transit.degree);

      // Verificar aspectos com planetas natais
      for (final natalPlanet in natalChart.planets) {
        final natalLongitude =
            _getAbsoluteLongitude(natalPlanet.sign, natalPlanet.degree.toDouble());

        // Calcular diferença angular
        var diff = (transitLongitude - natalLongitude).abs();
        if (diff > 180) diff = 360 - diff;

        // Verificar cada tipo de aspecto
        for (final aspectType in AspectType.values) {
          final orb = (diff - aspectType.angle).abs();

          if (orb <= aspectType.maxOrb) {
            aspects.add(TransitAspect(
              transitPlanet: transit.planet,
              natalPlanet: natalPlanet.planet,
              aspectType: aspectType,
              orb: orb,
              interpretation:
                  _getAspectInterpretation(transit.planet, natalPlanet.planet, aspectType),
              energyLevel: _getAspectEnergy(aspectType, transit.planet),
            ));
          }
        }
      }
    }

    // Ordenar por orb (aspectos mais exatos primeiro)
    aspects.sort((a, b) => a.orb.compareTo(b.orb));

    return aspects;
  }

  /// Calcula a posição simplificada de um planeta para uma data
  PlanetPosition _calculatePlanetPosition(Planet planet, DateTime date) {
    final daysSinceEpoch = date.difference(DateTime(2000, 1, 1)).inDays;
    final longitude = _getApproximateLongitude(planet, daysSinceEpoch.toDouble());

    final signIndex = (longitude / 30).floor() % 12;
    final degree = longitude % 30;

    return PlanetPosition(
      planet: planet,
      sign: ZodiacSign.values[signIndex],
      degree: degree.floor(),
      minute: ((degree - degree.floor()) * 60).floor(),
      houseNumber: 1, // House não é relevante para trânsitos
      isRetrograde: _isRetrograde(planet, daysSinceEpoch.toDouble()),
      longitude: longitude,
      speed: 0.0, // Speed não é calculado aqui
    );
  }

  /// Calcula longitude aproximada do planeta
  /// NOTA: Esta é uma implementação simplificada para demonstração
  /// Para produção, use cálculos astronômicos precisos com sweph
  double _getApproximateLongitude(Planet planet, double days) {
    // Velocidades médias aproximadas (graus por dia)
    final speeds = {
      Planet.sun: 0.9856,
      Planet.moon: 13.1764,
      Planet.mercury: 1.3833,
      Planet.venus: 1.2,
      Planet.mars: 0.5240,
      Planet.jupiter: 0.0831,
      Planet.saturn: 0.0335,
      Planet.uranus: 0.0117,
      Planet.neptune: 0.0060,
      Planet.pluto: 0.0040,
    };

    // Posições iniciais aproximadas em 1 de janeiro de 2000
    final initialPositions = {
      Planet.sun: 280.0,
      Planet.moon: 218.0,
      Planet.mercury: 253.0,
      Planet.venus: 181.0,
      Planet.mars: 355.0,
      Planet.jupiter: 34.0,
      Planet.saturn: 51.0,
      Planet.uranus: 316.0,
      Planet.neptune: 301.0,
      Planet.pluto: 251.0,
    };

    final speed = speeds[planet] ?? 1.0;
    final initial = initialPositions[planet] ?? 0.0;

    return (initial + (speed * days)) % 360;
  }

  /// Verifica se o planeta está retrógrado (simplificado)
  bool _isRetrograde(Planet planet, double days) {
    // Ciclos retrógrados aproximados
    final retroCycles = {
      Planet.mercury: 116, // ~3-4 vezes por ano
      Planet.venus: 584,
      Planet.mars: 780,
      Planet.jupiter: 399,
      Planet.saturn: 378,
      Planet.uranus: 369,
      Planet.neptune: 367,
      Planet.pluto: 366,
    };

    if (!retroCycles.containsKey(planet)) return false;

    final cycle = retroCycles[planet]!;
    final position = (days % cycle) / cycle;

    // Simplificado: retrógrado por ~20% do ciclo
    return position >= 0.4 && position <= 0.6;
  }

  /// Converte signo + grau para longitude absoluta (0-360)
  double _getAbsoluteLongitude(ZodiacSign sign, double degree) {
    return (sign.index * 30.0) + degree;
  }

  /// Retorna interpretação do aspecto para contexto mágico
  String _getAspectInterpretation(
      Planet transitPlanet, Planet natalPlanet, AspectType aspect) {
    final combinations = {
      'sun_moon_conjunction':
          'Momento poderoso para integrar vontade consciente com intuição',
      'sun_moon_opposition':
          'Tensão entre ego e emoções - momento para equilibrar',
      'venus_mars_trine':
          'Harmonia entre amor e ação - ótimo para magia de atração',
      'jupiter_saturn_square':
          'Desafio entre expansão e disciplina - momento de escolhas',
      'mercury_retrograde':
          'Revisão, reflexão e magia introspectiva são favorecidas',
    };

    final key =
        '${transitPlanet.name}_${natalPlanet.name}_${aspect.name}';
    return combinations[key] ??
        '${transitPlanet.displayName} ${aspect.symbol} ${natalPlanet.displayName} natal';
  }

  /// Determina o nível de energia do aspecto
  EnergyLevel _getAspectEnergy(AspectType aspect, Planet planet) {
    if (aspect == AspectType.conjunction ||
        aspect == AspectType.opposition) {
      return EnergyLevel.intense;
    }

    if (aspect == AspectType.trine || aspect == AspectType.sextile) {
      return EnergyLevel.harmonious;
    }

    if (aspect == AspectType.square) {
      return EnergyLevel.challenging;
    }

    return EnergyLevel.moderate;
  }
}
