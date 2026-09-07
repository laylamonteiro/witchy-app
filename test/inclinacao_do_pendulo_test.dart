import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/divination/domain/inclinacao_do_pendulo.dart';

/// O pedido: a inclinação leva o cristal quase até as bordas do card (antes
/// eram ±18 px) e a corrente reage a qualquer movimento — SEM sair da tela e
/// sem tremer nos extremos. A geometria e a física ficam provadas aqui; no
/// aparelho só resta olhar.
void main() {
  // Medidas reais da PendulumPage: ponta do cristal a corda (150) + corpo
  // (54·110/130) da fixação; caixa do cristal com 54·120/130 de largura.
  const raioDaPonta = 150 + 54 * 110 / 130;
  const larguraDoCristal = 54 * 120 / 130;

  group('normalizar', () {
    test('parado é zero; ~30° de rolagem é o fundo de escala', () {
      expect(InclinacaoDoPendulo.normalizar(0), 0);
      final aos30 = -InclinacaoDoPendulo.gravidade * sin(pi / 6);
      expect(InclinacaoDoPendulo.normalizar(aos30), closeTo(1, 1e-9));
      expect(InclinacaoDoPendulo.normalizar(-aos30), closeTo(-1, 1e-9));
    });

    test('além do fundo de escala satura em ±1', () {
      expect(InclinacaoDoPendulo.normalizar(-20), 1);
      expect(InclinacaoDoPendulo.normalizar(20), -1);
    });

    test('zona morta engole o ruído de mão parada, sem degrau na borda', () {
      const escala =
          InclinacaoDoPendulo.gravidade * InclinacaoDoPendulo.escalaCheia;
      expect(InclinacaoDoPendulo.normalizar(-escala * 0.01), 0);
      expect(InclinacaoDoPendulo.normalizar(escala * 0.01), 0);
      final logoDepois =
          -escala * (InclinacaoDoPendulo.zonaMorta + 1e-6);
      expect(InclinacaoDoPendulo.normalizar(logoDepois).abs(), lessThan(1e-4));
    });

    test('ímpar e monotônica', () {
      var anterior = double.infinity;
      for (var ax = -20.0; ax <= 20; ax += 0.25) {
        final v = InclinacaoDoPendulo.normalizar(ax);
        expect(v, closeTo(-InclinacaoDoPendulo.normalizar(-ax), 1e-12));
        // ax cresce → o pêndulo pende para o outro lado: nunca sobe.
        expect(v, lessThanOrEqualTo(anterior + 1e-12));
        anterior = v;
      }
    });
  });

  group('FiltroDeInclinacao', () {
    test('converge para o alvo sem passar dele', () {
      final filtro = FiltroDeInclinacao();
      var anterior = 0.0;
      for (var i = 0; i < 60; i++) {
        final v = filtro.atualizar(1);
        expect(v, lessThanOrEqualTo(1));
        expect(v, greaterThanOrEqualTo(anterior));
        anterior = v;
      }
      expect(filtro.valor, greaterThan(0.99));
    });
  });

  group('saturar', () {
    test('zero, bordas exatas e overshoot preso', () {
      expect(InclinacaoDoPendulo.saturar(0), 0);
      expect(InclinacaoDoPendulo.saturar(1), closeTo(1, 1e-12));
      expect(InclinacaoDoPendulo.saturar(-1), closeTo(-1, 1e-12));
      expect(InclinacaoDoPendulo.saturar(1.6), closeTo(1, 1e-12));
      expect(InclinacaoDoPendulo.saturar(-1.6), closeTo(-1, 1e-12));
    });

    test('monotônica e ímpar', () {
      var anterior = -2.0;
      for (var t = -1.0; t <= 1; t += 0.05) {
        final v = InclinacaoDoPendulo.saturar(t);
        expect(v, greaterThanOrEqualTo(anterior));
        expect(v, closeTo(-InclinacaoDoPendulo.saturar(-t), 1e-12));
        anterior = v;
      }
    });
  });

  group('anguloMaximo', () {
    test('a ponta do cristal nunca sai da área, mesmo com overshoot', () {
      for (var w = 280.0; w <= 600; w += 20) {
        final max = InclinacaoDoPendulo.anguloMaximo(
          larguraDaArea: w,
          raioDaPonta: raioDaPonta,
          larguraDoCristal: larguraDoCristal,
        );
        expect(max, lessThanOrEqualTo(InclinacaoDoPendulo.tetoEmRepouso));
        for (final theta in [-1.6, -1.0, -0.5, 0.5, 1.0, 1.6]) {
          final a = InclinacaoDoPendulo.angulo(theta, anguloMaximo: max);
          final x = w / 2 + sin(a) * raioDaPonta;
          expect(x - larguraDoCristal / 2,
              greaterThanOrEqualTo(InclinacaoDoPendulo.margem - 1e-6),
              reason: 'largura $w, θ $theta');
          expect(x + larguraDoCristal / 2,
              lessThanOrEqualTo(w - InclinacaoDoPendulo.margem + 1e-6),
              reason: 'largura $w, θ $theta');
        }
      }
    });

    test('cresce com a largura e é muito maior que os 0,12 rad de antes', () {
      var anterior = 0.0;
      for (var w = 280.0; w <= 600; w += 20) {
        final max = InclinacaoDoPendulo.anguloMaximo(
          larguraDaArea: w,
          raioDaPonta: raioDaPonta,
          larguraDoCristal: larguraDoCristal,
        );
        expect(max, greaterThanOrEqualTo(anterior));
        anterior = max;
      }
      final numCelular = InclinacaoDoPendulo.anguloMaximo(
        larguraDaArea: 328,
        raioDaPonta: raioDaPonta,
        larguraDoCristal: larguraDoCristal,
      );
      expect(numCelular, greaterThan(0.6));
      expect(numCelular, greaterThan(InclinacaoDoPendulo.tetoAmortecido * 5));
    });

    test('área menor que o cristal → sem inclinação', () {
      expect(
        InclinacaoDoPendulo.anguloMaximo(
          larguraDaArea: 40,
          raioDaPonta: raioDaPonta,
          larguraDoCristal: larguraDoCristal,
        ),
        0,
      );
    });
  });

  group('MolaDoPendulo', () {
    test('degrau: passa do alvo (corrente) e assenta em ~3 s', () {
      final mola = MolaDoPendulo();
      var pico = 0.0;
      for (var i = 0; i < 180; i++) {
        pico = max(pico, mola.avancar(1 / 60, 1));
      }
      expect(pico, greaterThan(1.05), reason: 'sem overshoot não é corrente');
      expect((mola.theta - 1).abs(), lessThan(0.02));
      expect(mola.emRepousoEm(1, tolerancia: 0.02), isTrue);
    });

    test('um tranco curto balança e decai', () {
      final mola = MolaDoPendulo();
      // 100 ms de alvo em 1 e volta a zero: o tranco da mão.
      for (var i = 0; i < 6; i++) {
        mola.avancar(1 / 60, 1);
      }
      var primeiroSegundo = 0.0;
      for (var i = 0; i < 60; i++) {
        primeiroSegundo = max(primeiroSegundo, mola.avancar(1 / 60, 0).abs());
      }
      var terceiroSegundo = 0.0;
      for (var i = 0; i < 120; i++) {
        final v = mola.avancar(1 / 60, 0).abs();
        if (i >= 60) terceiroSegundo = max(terceiroSegundo, v);
      }
      expect(primeiroSegundo, greaterThan(0.1));
      expect(terceiroSegundo, lessThan(primeiroSegundo / 5));
    });

    test('dt absurdo não explode nem gera NaN', () {
      final mola = MolaDoPendulo();
      for (final dt in [0.0, -1.0, double.nan, double.infinity, 120.0]) {
        final v = mola.avancar(dt, 1);
        expect(v.isFinite, isTrue, reason: 'dt $dt');
        expect(v.abs(), lessThan(3));
      }
    });
  });
}
