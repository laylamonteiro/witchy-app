import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/enums.dart';
import 'package:grimorio_de_bolso/features/cycles/data/services/month_sky_calculator.dart';

/// A matemática do céu do mês, sem o efeméride.
///
/// O `sweph` precisa dos assets e da biblioteca nativa, que não sobem no
/// ambiente de teste — mas o que erra silenciosamente aqui é a aritmética:
/// a conversão de Julian Day, o ângulo centrado que detecta o cruzamento e a
/// bisseção. É isso que este arquivo prova.
void main() {
  group('Ângulo centrado', () {
    test('traz para a faixa -180..180', () {
      expect(MonthSkyCalculator.centrado(0), 0);
      expect(MonthSkyCalculator.centrado(90), 90);
      expect(MonthSkyCalculator.centrado(-90), -90);
      expect(MonthSkyCalculator.centrado(370), closeTo(10, 1e-9));
      expect(MonthSkyCalculator.centrado(-370), closeTo(-10, 1e-9));
    });

    test('logo antes e logo depois do cruzamento troca de sinal', () {
      // É desta troca que a varredura vive: a lua nova é o zero.
      expect(MonthSkyCalculator.centrado(359).isNegative, isTrue);
      expect(MonthSkyCalculator.centrado(1).isNegative, isFalse);
    });

    test('a meia-volta é o rasgo, não um cruzamento', () {
      // Em 180 a função salta de +179 para -179. A varredura descarta saltos
      // maiores que 180 justamente para não anunciar lua nova na lua cheia.
      final antes = MonthSkyCalculator.centrado(179);
      final depois = MonthSkyCalculator.centrado(181);
      expect(antes.isNegative, isFalse);
      expect(depois.isNegative, isTrue);
      expect((depois - antes).abs(), greaterThan(180));
    });
  });

  group('Julian Day para data', () {
    test('a época do Unix é JD 2440587.5', () {
      expect(MonthSkyCalculator.paraData(2440587.5),
          DateTime.utc(1970, 1, 1, 0, 0, 0));
    });

    test('meio dia adiante é meio dia adiante', () {
      expect(MonthSkyCalculator.paraData(2440588.0),
          DateTime.utc(1970, 1, 1, 12, 0, 0));
    });

    test('devolve sempre em UTC', () {
      expect(MonthSkyCalculator.paraData(2460000.5).isUtc, isTrue);
    });
  });

  group('Signo por longitude', () {
    test('cada fatia de 30° é um signo, começando em Áries', () {
      expect(MonthSkyCalculator.signoDe(0), ZodiacSign.aries);
      expect(MonthSkyCalculator.signoDe(29.99), ZodiacSign.aries);
      expect(MonthSkyCalculator.signoDe(30), ZodiacSign.taurus);
      expect(MonthSkyCalculator.signoDe(150), ZodiacSign.virgo);
      expect(MonthSkyCalculator.signoDe(359.99), ZodiacSign.pisces);
    });

    test('dá a volta em 360', () {
      expect(MonthSkyCalculator.signoDe(360), ZodiacSign.aries);
    });
  });

  group('Bisseção', () {
    test('acha a raiz de uma função simples', () {
      final raiz = MonthSkyCalculator.bissecao((x) => x - 0.3, 0, 1);
      expect(raiz, closeTo(0.3, 1e-6));
    });

    test('funciona com a raiz colada nas pontas', () {
      expect(MonthSkyCalculator.bissecao((x) => x - 0.001, 0, 1),
          closeTo(0.001, 1e-6));
      expect(MonthSkyCalculator.bissecao((x) => x - 0.999, 0, 1),
          closeTo(0.999, 1e-6));
    });

    test('acha a raiz de função decrescente', () {
      // Retrogradação: a velocidade cai de positiva para negativa.
      final raiz = MonthSkyCalculator.bissecao((x) => 0.5 - x, 0, 1);
      expect(raiz, closeTo(0.5, 1e-6));
    });

    test('num intervalo de um dia chega perto do segundo', () {
      // 24 passos sobre 1 dia = 86400/2^24 segundos.
      const jdInicio = 2460000.0;
      final raiz = MonthSkyCalculator.bissecao(
          (x) => x - (jdInicio + 0.5), jdInicio, jdInicio + 1);
      final erroEmSegundos =
          ((raiz - (jdInicio + 0.5)).abs() * Duration.secondsPerDay);
      expect(erroEmSegundos, lessThan(1));
    });
  });
}
