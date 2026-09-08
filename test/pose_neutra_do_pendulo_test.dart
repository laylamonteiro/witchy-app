import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/divination/domain/inclinacao_do_pendulo.dart';

// O pedido: "deitada na cama, virada para o lado direito, de frente para o
// celular numa posição neutra em relação aos meus olhos, o pêndulo estava
// totalmente virado para a direita". A pose em que a pessoa segura o celular
// tem de ser o centro; inclinar EM RELAÇÃO a ela é o que move o cristal.
//
// Convenção do acelerômetro (Android/iOS): a leitura é a reação à gravidade.
// Celular em pé, tela de frente: (0, +g, 0). Deitado na mesa, tela para
// cima: (0, 0, +g). Deitado sobre a borda direita (a direita da tela aponta
// para o chão): (−g, 0, 0).
void main() {
  const g = InclinacaoDoPendulo.gravidade;
  const dt = 1 / 30;

  /// Gira o aparelho de [angulo] rad em torno de [eixo] (unitário, regra da
  /// mão direita) e devolve a leitura resultante: um vetor fixo do mundo
  /// aparece girado ao contrário no referencial do aparelho.
  Vetor3 girarAparelho(Vetor3 leitura, Vetor3 eixo, double angulo) {
    final k = eixo.unitario;
    final c = cos(-angulo);
    final s = sin(-angulo);
    return leitura
        .vezes(c)
        .mais(k.cruzado(leitura).vezes(s))
        .mais(k.vezes(k.ponto(leitura) * (1 - c)));
  }

  /// Alimenta [pose] com [leitura] parada por [segundos].
  double? alimentar(PoseNeutraDoPendulo pose, Vetor3 leitura, double segundos) {
    double? ultimo;
    for (var t = 0.0; t < segundos; t += dt) {
      ultimo = pose.atualizar(leitura, dt: dt);
    }
    return ultimo;
  }

  const emPe = Vetor3(0, g, 0);
  const naMesa = Vetor3(0, 0, g);
  const deLado = Vetor3(-g, 0, 0);
  const z = Vetor3(0, 0, 1);
  const y = Vetor3(0, 1, 0);

  group('captura da pose', () {
    test('antes de meio segundo não há referência e o cristal fica no centro',
        () {
      final pose = PoseNeutraDoPendulo();
      expect(pose.atualizar(deLado, dt: dt), isNull);
      expect(pose.calibrada, isFalse);
      alimentar(pose, deLado, 0.3);
      expect(pose.calibrada, isFalse);
    });

    test('depois da captura, a pose que a pessoa segura é o zero', () {
      for (final leitura in [emPe, naMesa, deLado, const Vetor3(-5, 7, 3)]) {
        final pose = PoseNeutraDoPendulo();
        final x = alimentar(pose, leitura, 1);
        expect(pose.calibrada, isTrue, reason: '$leitura');
        expect(x, closeTo(0, 1e-9), reason: '$leitura');
      }
    });

    test('leitura sem gravidade (sensor mudo, queda) não vira referência', () {
      final pose = PoseNeutraDoPendulo();
      expect(alimentar(pose, const Vetor3(0, 0, 0), 1), isNull);
      expect(pose.calibrada, isFalse);
    });
  });

  group('inclinar em relação à pose', () {
    test('em pé, rolar a borda direita para baixo dá o mesmo x de antes', () {
      final pose = PoseNeutraDoPendulo();
      alimentar(pose, emPe, 1);
      // Girar o aparelho no sentido horário (visto de frente) = −θ em torno
      // de z: a borda direita desce.
      final leitura = girarAparelho(emPe, z, -pi / 6);
      final x = pose.atualizar(leitura, dt: dt)!;
      expect(x, closeTo(leitura.x, 1e-6), reason: 'em pé, x é o próprio x');
      expect(InclinacaoDoPendulo.normalizar(x), closeTo(1, 1e-6),
          reason: '30° para a direita = fundo de escala à direita');
    });

    test('na mesa, levantar a borda esquerda dá o mesmo x de antes', () {
      final pose = PoseNeutraDoPendulo();
      alimentar(pose, naMesa, 1);
      final leitura = girarAparelho(naMesa, y, pi / 6);
      final x = pose.atualizar(leitura, dt: dt)!;
      expect(x, closeTo(leitura.x, 1e-6));
      expect(InclinacaoDoPendulo.normalizar(x), closeTo(1, 1e-6));
    });

    test('deitada de lado, a mesma rolagem move o cristal do mesmo jeito', () {
      // O caso do pedido: a gravidade já está no eixo x da tela. Sem a pose,
      // normalizar(−g) saturava em +1 (tudo para a direita).
      expect(InclinacaoDoPendulo.normalizar(deLado.x), 1);

      final pose = PoseNeutraDoPendulo();
      alimentar(pose, deLado, 1);
      expect(pose.atualizar(deLado, dt: dt), closeTo(0, 1e-9));

      // Girar o aparelho em torno do próprio eixo da tela (z), como em pé.
      final horario = pose.atualizar(girarAparelho(deLado, z, -pi / 6), dt: dt);
      final antiHorario =
          pose.atualizar(girarAparelho(deLado, z, pi / 6), dt: dt);
      expect(InclinacaoDoPendulo.normalizar(horario!), closeTo(1, 1e-6),
          reason: 'borda direita da tela descendo → cristal para a direita');
      expect(InclinacaoDoPendulo.normalizar(antiHorario!), closeTo(-1, 1e-6));
    });

    test('celular na vertical em QUALQUER giro (de lado, de cabeça para baixo): '
        'rolar no horário é sempre para a direita', () {
      // A família do pedido: tela de frente para o rosto, gravidade no plano
      // da tela, em qualquer ângulo — inclusive o exato oposto do "em pé",
      // onde a rotação mínima é ambígua e tem de continuar a família.
      for (var graus = 0; graus < 360; graus += 15) {
        final phi = graus * pi / 180;
        final leitura = Vetor3(g * sin(phi), g * cos(phi), 0);
        final pose = PoseNeutraDoPendulo();
        alimentar(pose, leitura, 1);
        expect(pose.atualizar(leitura, dt: dt), closeTo(0, 1e-9),
            reason: '$graus°: a pose é o zero');
        final horario =
            pose.atualizar(girarAparelho(leitura, z, -pi / 6), dt: dt)!;
        final antiHorario =
            pose.atualizar(girarAparelho(leitura, z, pi / 6), dt: dt)!;
        expect(horario, closeTo(-g * sin(pi / 6), 1e-6),
            reason: '$graus°: rolar 30° no horário = 30° à direita');
        expect(antiHorario, closeTo(g * sin(pi / 6), 1e-6),
            reason: '$graus°: rolar 30° no anti-horário = 30° à esquerda');
      }
    });

    test('na mesa, girar o celular sobre a mesa não move o cristal', () {
      // Girar em torno do eixo da tela com ela para cima não muda a gravidade
      // — um pêndulo de verdade também não se mexeria.
      final pose = PoseNeutraDoPendulo();
      alimentar(pose, naMesa, 1);
      final x = pose.atualizar(girarAparelho(naMesa, z, pi / 3), dt: dt)!;
      expect(x, closeTo(0, 1e-9));
    });

    test('a leitura girada mantém o módulo (é rotação, não escala)', () {
      final pose = PoseNeutraDoPendulo();
      alimentar(pose, deLado, 1);
      final girada = PoseNeutraDoPendulo.girar(
        const Vetor3(1, 2, 3),
        de: pose.referencia!,
        para: PoseNeutraDoPendulo.emPe,
      );
      expect(girada.norma, closeTo(const Vetor3(1, 2, 3).norma, 1e-9));
    });
  });

  group('trocar de pose', () {
    test('Perguntar refaz a referência na pose de agora', () {
      // Espera de troca automática enorme: aqui só o Perguntar recalibra.
      final pose = PoseNeutraDoPendulo(esperaDaNovaPose: 1000);
      alimentar(pose, emPe, 1);
      // Deitou de lado: sem recalibrar, tudo para um lado — por muito tempo.
      alimentar(pose, deLado, 3);
      expect(pose.atualizar(deLado, dt: dt)!.abs(), greaterThan(g / 2));
      pose.recalibrar();
      // A referência é a gravidade filtrada, já convergida: sobra menos que a
      // zona morta da normalização.
      expect(pose.atualizar(deLado, dt: dt), closeTo(0, 0.01));
    });

    test('uma orientação muito diferente, sustentada, vira o novo centro', () {
      final pose = PoseNeutraDoPendulo();
      alimentar(pose, emPe, 1);
      // 1 s deitada de lado (90° de diferença): ainda inclinado ao máximo.
      alimentar(pose, deLado, 1.0);
      expect(pose.atualizar(deLado, dt: dt)!.abs(), greaterThan(g / 2));
      // Passado o tempo de espera, a pose nova é o zero (a menos do resto
      // do passa-baixa, bem abaixo da zona morta).
      alimentar(pose, deLado, 1.0);
      expect(pose.atualizar(deLado, dt: dt), closeTo(0, 0.05));
    });

    test('uma inclinação deliberada de 30° NÃO recentra, por mais que dure',
        () {
      final pose = PoseNeutraDoPendulo();
      alimentar(pose, emPe, 1);
      final inclinada = girarAparelho(emPe, z, -pi / 6);
      final x = alimentar(pose, inclinada, 10)!;
      expect(InclinacaoDoPendulo.normalizar(x), closeTo(1, 1e-6));
    });

    test('um tranco breve para fora da pose não recentra', () {
      final pose = PoseNeutraDoPendulo();
      alimentar(pose, emPe, 1);
      alimentar(pose, deLado, 0.5);
      final x = alimentar(pose, emPe, 1)!;
      expect(x, closeTo(0, 1e-3));
    });

    test('reiniciar volta ao estado de página recém-aberta', () {
      final pose = PoseNeutraDoPendulo();
      alimentar(pose, emPe, 1);
      pose.reiniciar();
      expect(pose.calibrada, isFalse);
      expect(pose.atualizar(deLado, dt: dt), isNull);
    });
  });

  group('robustez', () {
    test('de cabeça para baixo em relação à pose não gera NaN', () {
      final pose = PoseNeutraDoPendulo();
      alimentar(pose, emPe, 1);
      final x = pose.atualizar(const Vetor3(0, -g, 0), dt: dt)!;
      expect(x.isFinite, isTrue);
      expect(x, closeTo(0, 1e-9));
    });

    test('dt zero, negativo ou infinito não avança o relógio nem explode', () {
      final pose = PoseNeutraDoPendulo();
      for (final ruim in [0.0, -1.0, double.infinity, double.nan]) {
        expect(pose.atualizar(emPe, dt: ruim), isNull, reason: '$ruim');
      }
      expect(pose.calibrada, isFalse);
    });
  });
}
