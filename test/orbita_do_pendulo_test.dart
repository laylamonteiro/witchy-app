import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/divination/domain/orbita_do_pendulo.dart';

/// Os números da cena real do pêndulo (`pendulum_page.dart`): a área tem 300 de
/// altura, a fixação fica em y=20 e a corda mede metade da altura.
const _ancoraY = 20.0;
const _fixacao = Offset(128, _ancoraY);
const _corda = 150.0;

/// Do ponto onde a corrente prende até a ponta do cristal: o corpo visível é
/// 110/130 do viewBox de 54 px.
const _pontaDoCristal = 54 * 110 / 130;

/// Onde o rótulo "Talvez" começa: 18 px além da ponta em repouso, menos a meia
/// altura do texto. É a folga que a órbita não pode comer.
const _topoDoRotulo = _ancoraY + _corda + _pontaDoCristal + 18 - 8;

ProjecaoDaOrbita _em(double fase,
        {double envelope = 1.0, double anguloNoPlano = 0.0}) =>
    OrbitaDoPendulo.projetar(
      fixacao: _fixacao,
      corda: _corda,
      fase: fase,
      envelope: envelope,
      anguloNoPlano: anguloNoPlano,
    );

/// Varre a volta inteira e ainda o assentamento: enquanto o cristal pousa, o
/// cone fecha e o alvo entra. Nenhum invariante pode quebrar no meio disso.
void _porTodaAVolta(
  void Function(ProjecaoDaOrbita p, double fase, double envelope) conferir, {
  double alvo = 0,
  int passosDoAssentamento = 40,
  int passosDaVolta = 360,
}) {
  for (var s = 0; s <= passosDoAssentamento; s++) {
    final settleV = s / passosDoAssentamento;
    final envelope = 1 - settleV;
    for (var i = 0; i < passosDaVolta; i++) {
      final fase = i * 2 * pi / passosDaVolta;
      conferir(
        _em(fase, envelope: envelope, anguloNoPlano: alvo * settleV),
        fase,
        envelope,
      );
    }
  }
}

void main() {
  group('assentada, a órbita é o arco de sempre', () {
    test('o peso cai exatamente onde a fórmula planar o punha', () {
      for (final angulo in [-0.5, -0.12, 0.0, 0.3, 0.5]) {
        final p = _em(1.234, envelope: 0, anguloNoPlano: angulo);
        expect(p.peso.dx, closeTo(_fixacao.dx + sin(angulo) * _corda, 1e-9),
            reason: 'ângulo $angulo');
        expect(p.peso.dy, closeTo(_fixacao.dy + cos(angulo) * _corda, 1e-9),
            reason: 'ângulo $angulo');
      }
    });

    test('a ponta aponta para o rótulo: o ângulo aparente É o do alvo', () {
      // Sim à esquerda, não à direita, talvez reto para baixo — os mesmos três
      // ângulos que posicionam as palavras na tela.
      for (final alvo in [-0.5, 0.0, 0.5]) {
        final p = _em(2.1, envelope: 0, anguloNoPlano: alvo);
        expect(p.anguloAparente, closeTo(alvo, 1e-9), reason: 'alvo $alvo');
      }
    });

    test('o cristal volta ao tamanho natural, qualquer que seja a fase', () {
      for (final fase in [0.0, pi / 3, pi, 5.9]) {
        expect(_em(fase, envelope: 0).escala, closeTo(1.0, 1e-12));
      }
    });
  });

  group('girando, o peso percorre uma elipse', () {
    test('a razão altura/largura é o achatamento da câmera', () {
      var esquerda = double.infinity, direita = -double.infinity;
      var alto = double.infinity, baixo = -double.infinity;
      for (var i = 0; i < 2000; i++) {
        final peso = _em(i * 2 * pi / 2000).peso;
        esquerda = min(esquerda, peso.dx);
        direita = max(direita, peso.dx);
        alto = min(alto, peso.dy);
        baixo = max(baixo, peso.dy);
      }
      expect((baixo - alto) / (direita - esquerda),
          closeTo(OrbitaDoPendulo.achatamento, 0.005));
    });

    test('o alcance lateral é exatamente o do balanço antigo', () {
      // Fase 0 e π: toda a abertura está no plano da tela, profundidade zero.
      // É o instante em que a órbita chega mais longe — e ela chega ao MESMO
      // ponto de antes, então nada passou a sair do card que já não saísse.
      // Em y ela fica um pouco mais alta: a câmera inclinada comprime a cena
      // inteira, e isso só afasta a ponta do rótulo.
      for (final (fase, lado) in [(0.0, 1.0), (pi, -1.0)]) {
        final p = _em(fase);
        expect(
            p.peso.dx,
            closeTo(
                _fixacao.dx + lado * sin(OrbitaDoPendulo.abertura) * _corda,
                1e-9),
            reason: 'fase $fase');
        expect(
            p.peso.dy,
            lessThanOrEqualTo(
                _fixacao.dy + cos(OrbitaDoPendulo.abertura) * _corda),
            reason: 'fase $fase');
      }
      // E nenhuma fase passa desse alcance.
      _porTodaAVolta((p, fase, _) {
        expect((p.peso.dx - _fixacao.dx).abs(),
            lessThanOrEqualTo(sin(OrbitaDoPendulo.abertura) * _corda + 1e-9),
            reason: 'fase $fase');
      });
    });

    test('a corrente nunca aparenta esticar', () {
      // A projeção é rígida: inclinar a cena e olhar de frente só pode encurtar
      // o que se vê. Uma corrente que cresce denuncia na hora que aquilo não é
      // um pêndulo — e é o que acontece se o achatamento entrar sem a
      // compressão vertical que vem junto com ele.
      _porTodaAVolta((p, fase, _) {
        expect((p.peso - _fixacao).distance, lessThanOrEqualTo(_corda + 1e-9),
            reason: 'fase $fase');
      }, alvo: 0.5);
    });

    test('a órbita nunca desce abaixo do repouso', () {
      _porTodaAVolta((p, fase, _) {
        expect(p.peso.dy, lessThanOrEqualTo(_fixacao.dy + _corda + 1e-9),
            reason: 'fase $fase');
      }, alvo: 0.5);
    });

    test('a ponta do cristal não alcança o rótulo "Talvez"', () {
      // Sem a compressão da câmera, a frente da órbita desceria e a ponta
      // passaria por cima da palavra a cada volta.
      _porTodaAVolta((p, fase, _) {
        final ponta = p.peso.dy + _pontaDoCristal * cos(p.anguloAparente);
        expect(ponta, lessThan(_topoDoRotulo), reason: 'fase $fase');
      }, alvo: 0.5);
    });
  });

  group('o cristal acompanha a corrente desenhada', () {
    test('o ângulo aparente é a direção de fixação para peso', () {
      _porTodaAVolta((p, fase, _) {
        expect(
          p.anguloAparente,
          closeTo(
              atan2(p.peso.dx - _fixacao.dx, p.peso.dy - _fixacao.dy), 1e-9),
          reason: 'fase $fase',
        );
      }, alvo: 0.5);
    });

    test('durante a volta ele diverge da abertura do cone', () {
      // Se fossem iguais, girar o cristal pela abertura bastaria. Não são: no
      // oitavo de volta a diferença já vira vários pixels de cristal descolado
      // do fio, lá na ponta.
      const fase = pi / 4;
      final p = _em(fase);
      // Para onde a corda aponta ANTES da câmera entrar: é o ângulo que se
      // usaria se a projeção fosse ignorada.
      final semACamera = atan2(
        sin(OrbitaDoPendulo.abertura) * cos(fase),
        cos(OrbitaDoPendulo.abertura),
      );
      final divergencia = (p.anguloAparente - semACamera).abs();
      expect(divergencia, greaterThan(0.02));
      expect(divergencia * (_corda + _pontaDoCristal), greaterThan(5),
          reason: 'são vários pixels de cristal descolado do fio');
    });
  });

  group('o relevo vende a profundidade', () {
    test('cresce na frente da órbita e encolhe ao fundo', () {
      // π/2 é a frente: o peso desce na tela, perto de quem olha. 3π/2 é o
      // fundo: sobe, longe.
      final frente = _em(pi / 2), fundo = _em(3 * pi / 2);
      expect(frente.escala, closeTo(1 + OrbitaDoPendulo.relevo, 1e-9));
      expect(fundo.escala, closeTo(1 - OrbitaDoPendulo.relevo, 1e-9));
      expect(frente.peso.dy, greaterThan(fundo.peso.dy),
          reason: 'quem está perto tem de aparecer mais embaixo');
    });

    test('o relevo some junto com a órbita', () {
      expect(_em(pi / 2, envelope: 0.5).escala,
          closeTo(1 + OrbitaDoPendulo.relevo * 0.5, 1e-9));
    });
  });

  test('a fase é contínua ao fechar a volta', () {
    // `repeat()` sem reverse salta de 1 para 0 a cada volta: se o peso pulasse
    // aí, o olho veria um tranco por segundo e meio.
    final antes = _em(2 * pi - 1e-6);
    final depois = _em(0);
    expect((antes.peso - depois.peso).distance, lessThan(1e-3));
    expect((antes.escala - depois.escala).abs(), lessThan(1e-3));
  });
}
