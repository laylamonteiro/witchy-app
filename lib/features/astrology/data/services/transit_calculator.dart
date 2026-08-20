import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/content/content_locale.dart';
import '../models/birth_chart_model.dart';
import '../models/enums.dart';
import '../models/planet_position_model.dart';
import '../models/transit_model.dart';
import 'sweph_service.dart';

/// Strings do idioma atual sem BuildContext; o locale vem do ContentLocale.
AppLocalizations get _l10n =>
    lookupAppLocalizations(ContentLocale.instance.locale);

/// Calcula trânsitos planetários em tempo real
class TransitCalculator {
  /// O signo em que a Lua estava numa data — só a Lua.
  ///
  /// Existe para quem precisa disso DIA A DIA (a linha do tempo da Leitura
  /// do Ciclo percorre cada dia com registro): [calculateTransits] calcula
  /// todos os corpos e loga cada um, e repetir isso por dia seria pagar
  /// dezenas de vezes por um dado só. Devolve null se as efemérides não
  /// estiverem disponíveis — quem chama segue sem o signo.
  Future<ZodiacSign?> moonSignOn(DateTime date) async {
    try {
      await SwephService.instance.ensureReady();
      final utc = date.toUtc();
      final jd = SwephService.instance.julianDayUt(
        year: utc.year,
        month: utc.month,
        day: utc.day,
        hourUt: utc.hour + utc.minute / 60.0 + utc.second / 3600.0,
      );
      final pos = SwephService.instance
          .bodyPosition(jd, SwephService.heavenlyBody(Planet.moon));
      if (pos.longitude.isNaN || pos.longitude.isInfinite) return null;
      return ZodiacSign.fromLongitude(pos.longitude);
    } catch (_) {
      return null;
    }
  }

  /// Calcula as posições dos planetas para uma data específica.
  ///
  /// Usa o Swiss Ephemeris (Moshier) para precisão de arco-minuto e detecção
  /// real de retrogradação (velocidade < 0). Se o sweph falhar, cai no método
  /// linear aproximado antigo.
  Future<List<Transit>> calculateTransits(DateTime date) async {
    print('🌟 Calculando trânsitos para: $date');
    try {
      await SwephService.instance.ensureReady();
      final utc = date.toUtc();
      final hourUt = utc.hour + utc.minute / 60.0 + utc.second / 3600.0;
      final jd = SwephService.instance.julianDayUt(
        year: utc.year,
        month: utc.month,
        day: utc.day,
        hourUt: hourUt,
      );

      final transits = <Transit>[];
      for (final planet in Planet.values) {
        if (!_isTransitingBody(planet)) continue;
        try {
          final pos = SwephService.instance
              .bodyPosition(jd, SwephService.heavenlyBody(planet));
          if (pos.longitude.isNaN || pos.longitude.isInfinite) continue;
          transits.add(Transit(
            planet: planet,
            sign: ZodiacSign.fromLongitude(pos.longitude),
            degree: pos.longitude % 30,
            isRetrograde: pos.speed < 0,
          ));
        } catch (e) {
          print('  ✗ ${planet.name}: erro no sweph - $e');
        }
      }

      if (transits.isEmpty) {
        throw StateError('Nenhum trânsito calculado via sweph');
      }
      print('✅ Total de trânsitos calculados: ${transits.length}');
      return transits;
    } catch (e) {
      print('⚠️ Sweph indisponível ($e). Usando método linear aproximado.');
      return _calculateTransitsApprox(date);
    }
  }

  /// Corpos considerados nos trânsitos: os 10 planetas clássicos. Nodos e
  /// pontos calculados (MC/IC/DSC/Vértex/Lilith/Parte da Fortuna) ficam de fora.
  /// Switch exaustivo — novos valores do enum exigem uma decisão explícita aqui.
  bool _isTransitingBody(Planet planet) {
    switch (planet) {
      case Planet.sun:
      case Planet.moon:
      case Planet.mercury:
      case Planet.venus:
      case Planet.mars:
      case Planet.jupiter:
      case Planet.saturn:
      case Planet.uranus:
      case Planet.neptune:
      case Planet.pluto:
        return true;
      case Planet.northNode:
      case Planet.southNode:
      case Planet.midheaven:
      case Planet.imumCoeli:
      case Planet.descendant:
      case Planet.vertex:
      case Planet.lilith:
      case Planet.partOfFortune:
        return false;
    }
  }

  /// Fallback linear aproximado (sweph indisponível).
  List<Transit> _calculateTransitsApprox(DateTime date) {
    final transits = <Transit>[];
    for (final planet in Planet.values) {
      if (!_isTransitingBody(planet)) continue;
      try {
        final position = _calculatePlanetPosition(planet, date);
        if (!position.longitude.isNaN && !position.longitude.isInfinite) {
          transits.add(Transit(
            planet: planet,
            sign: position.sign,
            degree: position.degree.toDouble(),
            isRetrograde: position.isRetrograde,
          ));
        }
      } catch (e) {
        print('  ✗ ${planet.name}: erro - $e');
      }
    }
    return transits;
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
      'sun_moon_conjunction': _l10n.transitSunMoonConj,
      'sun_moon_opposition': _l10n.transitSunMoonOpp,
      'venus_mars_trine': _l10n.transitVenusMarsTrine,
      'jupiter_saturn_square': _l10n.transitJupiterSaturnSquare,
      'mercury_retrograde': _l10n.transitMercuryRetro,
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
