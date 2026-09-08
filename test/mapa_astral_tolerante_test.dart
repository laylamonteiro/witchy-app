import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/birth_chart_model.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/enums.dart';

// O mapa astral virava "erro genérico" logo depois do login na web, com
// `null is not a subtype of double` no log. Os campos numéricos dos planetas,
// casas e aspectos eram lidos por downcast direto do JSON gravado — o que
// estoura com o campo ausente E com um número inteiro (`"speed": 0`), porque
// em Dart `int` não é `double`. Pior: como o parse morria antes, o
// `calcVersion` (que existe para recalcular mapas velhos) nunca era lido.
//
// Estes casos são o formato de uma linha gravada, não o que o app escreve
// hoje: é exatamente isso que precisa sobreviver.
void main() {
  Map<String, dynamic> mapa({
    Map<String, dynamic>? planeta,
    Map<String, dynamic>? casa,
    Map<String, dynamic>? aspecto,
  }) =>
      {
        'id': 'chart-1',
        'userId': 'u1',
        'birthDate': '1990-05-10T00:00:00.000',
        'birthTimeHour': 14,
        'birthTimeMinute': 30,
        'birthPlace': 'São Paulo',
        'latitude': -23.5505,
        'longitude': -46.6333,
        'timezone': 'America/Sao_Paulo',
        'planets': [
          planeta ??
              {
                'planet': 'sun',
                'sign': 'taurus',
                'degree': 19,
                'minute': 30,
                'houseNumber': 10,
                'isRetrograde': false,
                'longitude': 49.5,
                'speed': 0.96,
              }
        ],
        'houses': [
          casa ??
              {
                'number': 1,
                'sign': 'virgo',
                'degree': 12,
                'minute': 0,
                'cuspLongitude': 162.0,
              }
        ],
        'aspects': [
          aspecto ??
              {
                'planet1': 'sun',
                'planet2': 'moon',
                'type': 'trine',
                'exactAngle': 120.0,
                'orb': 2.5,
                'isApplying': true,
              }
        ],
        'calculatedAt': '2026-01-01T00:00:00.000',
        'calcVersion': 1,
      };

  test('mapa completo continua sendo lido como sempre', () {
    final chart = BirthChartModel.fromJsonString(jsonEncode(mapa()));

    expect(chart.planets.single.longitude, 49.5);
    expect(chart.planets.single.speed, 0.96);
    expect(chart.houses.single.cuspLongitude, 162.0);
    expect(chart.aspects.single.orb, 2.5);
    expect(chart.calcVersion, 1);
  });

  test('linha antiga sem longitude e sem speed não derruba o mapa', () {
    final chart = BirthChartModel.fromJsonString(jsonEncode(mapa(
      planeta: {
        'planet': 'sun',
        'sign': 'taurus',
        'degree': 19,
        'minute': 30,
        'houseNumber': 10,
        'isRetrograde': false,
      },
      casa: {'number': 1, 'sign': 'virgo', 'degree': 12, 'minute': 0},
      aspecto: {'planet1': 'sun', 'planet2': 'moon', 'type': 'trine'},
    )));

    // A longitude se reconstrói do signo + grau + minuto (touro começa em 30°).
    expect(chart.planets.single.longitude, closeTo(49.5, 0.001));
    expect(chart.planets.single.speed, 0.0);
    expect(chart.houses.single.cuspLongitude, closeTo(162.0, 0.001));
    // O ângulo exato do trígono é o do próprio aspecto.
    expect(chart.aspects.single.exactAngle, AspectType.trine.angle);
    expect(chart.aspects.single.orb, 0.0);
    // E o que importa para o conserto: a versão sobrevive ao parse.
    expect(chart.calcVersion, 1);
  });

  test('número inteiro no JSON também é aceito', () {
    final chart = BirthChartModel.fromJsonString(jsonEncode(mapa(
      planeta: {
        'planet': 'sun',
        'sign': 'taurus',
        'degree': 19,
        'minute': 30,
        'houseNumber': 10,
        'isRetrograde': false,
        'longitude': 49,
        'speed': 0,
      },
      casa: {
        'number': 1,
        'sign': 'virgo',
        'degree': 12,
        'minute': 0,
        'cuspLongitude': 162,
      },
      aspecto: {
        'planet1': 'sun',
        'planet2': 'moon',
        'type': 'trine',
        'exactAngle': 120,
        'orb': 2,
        'isApplying': true,
      },
    )));

    expect(chart.planets.single.longitude, 49.0);
    expect(chart.planets.single.speed, 0.0);
    expect(chart.houses.single.cuspLongitude, 162.0);
    expect(chart.aspects.single.exactAngle, 120.0);
    expect(chart.aspects.single.orb, 2.0);
  });
}
