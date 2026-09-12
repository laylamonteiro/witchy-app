import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/theme/grimoire_colors.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/personalized_suggestions_content_pt.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/enums.dart';
import 'package:grimorio_de_bolso/features/astrology/presentation/widgets/retrograde_planet_color.dart';

/// A cor de cada planeta retrógrado, medida nos seis temas.
///
/// O card de retrógrados lista um planeta por linha, e o que separava uma
/// linha da outra era só o glifo astrológico (☿ ♀ ♂ ...). Glifo é a
/// pista mais frágil que existe: os oito não estão em toda fonte, e
/// onde falta um sai o mesmo quadradinho para todo mundo — oito linhas
/// idênticas. A cor entrou como o segundo canal, e este arquivo existe para
/// que ela não vire uma decoração que só funciona no tema escuro.
///
/// São cinco perguntas, e nenhuma delas é "está bonito":
///
///  1. as oito cores são MESMO diferentes entre si, em cada paleta?
///  2. o bloco de cor aparece sobre o cartão?
///  3. o glifo desenhado dentro do bloco continua legível?
///  4. a cor sobrevive a quem não enxerga cor?
///  5. o glifo cabe no bloco quando a fonte do sistema cresce?
///
/// A pergunta 2 é medida em ΔE e não em razão de contraste, de
/// propósito. A razão só enxerga luminosidade, e o bloco não é texto: é
/// uma área chapada de 30px cuja função é ter COR. O mesmo raciocínio já
/// está em test/contraste_dos_temas_test.dart, onde a razão reprovaria o
/// jade da Esmeralda (1,38) que é obviamente colorido. Onde há texto — o glifo
/// dentro do bloco — a medida volta a ser a razão da WCAG.
void main() {
  group('cor por planeta retrógrado', () {
    test('o mapa de cor cobre exatamente os planetas que têm conteúdo', () {
      // Se um nono planeta ganhar texto de retrógrado, ele entra na lista
      // sem cor própria e cai no acento do tema — duas linhas iguais. Este
      // teste é o aviso.
      expect(
        kRetrogradePlanets.toSet(),
        personalizedSuggestionsContentPt.retrogradeInfo.keys.toSet(),
      );
    });

    test('o glifo continua sendo uma pista independente da cor', () {
      // A cor é o segundo canal, não o primeiro: o desenho tem de continuar
      // distinto planeta a planeta (e não vazio), senão o daltônico e o
      // aparelho com fonte completa ficam com a mesma pista só.
      final glifos = kRetrogradePlanets.map((p) => p.symbol).toList();
      expect(glifos.where((g) => g.isEmpty), isEmpty);
      expect(glifos.toSet().length, kRetrogradePlanets.length);
    });

    test('o glifo não cresce junto com a fonte do sistema', () {
      // O quadrado de cor é FIXO em 30px — é o que mantém as oito linhas
      // alinhadas na mesma coluna. Com o glifo escalando junto com a fonte
      // do sistema, a 1,6x um texto de 19px passa de 30 e vaza para fora
      // do bloco, por cima do cartão. O glifo entrou no lugar de um
      // `Icon`, que também nunca cresce; quem precisa de letra grande
      // continua atendido pelo NOME do planeta ao lado, que é texto de
      // verdade e cresce.
      final fonte = File('lib/features/astrology/presentation/pages/'
              'personalized_suggestions_page.dart')
          .readAsStringSync();
      expect(
        fonte.contains('TextScaler.noScaling'),
        isTrue,
        reason: 'o glifo do bloco voltou a crescer com a fonte do sistema '
            'dentro de um quadrado de tamanho fixo',
      );
    });

    for (final preset in AppThemes.all) {
      final c = preset.colors;
      final nome = preset.id;
      final Map<Planet, Color> cores = {
        for (final p in kRetrogradePlanets) p: retrogradePlanetColor(c, p),
      };

      test('$nome: cada planeta tem uma cor que não é a do vizinho', () {
        // Piso 12: o par mais apertado das seis paletas é Urano/Netuno no
        // Lavanda-névoa (13,4), e os dois verdes escuros do tema claro são
        // o limite do que a paleta consegue dar para oito planetas. Se
        // alguém trocar um slot por outro mais parecido, cai aqui.
        for (final a in kRetrogradePlanets) {
          for (final b in kRetrogradePlanets) {
            if (a.index >= b.index) continue;
            expect(
              _deltaE(cores[a]!, cores[b]!),
              greaterThanOrEqualTo(12),
              reason: '$nome: ${a.name} e ${b.name} viram a mesma linha',
            );
          }
        }
      });

      test('$nome: o bloco de cor se enxerga sobre o cartão', () {
        // Piso 25, o mesmo do "título com cor" de contraste_dos_temas: é a
        // distância em que duas cores param de parecer a mesma. O pior caso
        // real é 52, então há folga de sobra — o teste existe para o
        // dia em que alguém escolher um slot parecido com a superfície.
        for (final p in kRetrogradePlanets) {
          expect(
            _deltaE(cores[p]!, c.surface),
            greaterThanOrEqualTo(25),
            reason: '$nome: o bloco de ${p.name} some dentro do cartão',
          );
        }
      });

      test('$nome: o glifo dentro do bloco continua legível', () {
        // Aqui é texto, então vale a razão da WCAG. O glifo é desenhado a
        // 19px em negrito, que a norma trata como texto grande: piso 3,0.
        // O pior caso das seis paletas é Vênus no tema claro (3,97) — e é
        // exatamente por causa dele que o glifo é pintado SOBRE o bloco, e
        // não com a cor do planeta direto no cartão, onde o rosa do tema
        // claro mediria 2,74.
        for (final p in kRetrogradePlanets) {
          expect(
            _razao(c.onPrimary, cores[p]!),
            greaterThanOrEqualTo(3.0),
            reason: '$nome: o glifo de ${p.name} some dentro do próprio bloco',
          );
        }
      });

      test('$nome: o título de alerta do card se lê', () {
        // O estado "Mercúrio retrógrado" é anunciado por TEXTO, e é esse
        // texto que fica na cor de alerta. A 19px em negrito o piso é 3,0
        // (texto grande); a 16px, como era antes, seria 4,5 — e o vermelho
        // do tema claro mede 3,17, ou seja, o anúncio do estado estava
        // reprovado justamente na paleta mais clara.
        expect(_razao(c.alert, c.surface), greaterThanOrEqualTo(3.0));
        // O estado comum usa o acento, que já é obrigado a 4,5 no outro
        // arquivo; aqui só se confirma que os dois estados não são a mesma
        // cor, senão a moldura e o ícone parariam de distinguir nada.
        expect(_deltaE(c.alert, c.lilac), greaterThanOrEqualTo(25));
      });
    }
  });
}

/// Razão de contraste da WCAG 2.1 entre duas cores opacas.
double _razao(Color a, Color b) {
  final la = _luminancia(a);
  final lb = _luminancia(b);
  final claro = math.max(la, lb);
  final escuro = math.min(la, lb);
  return (claro + 0.05) / (escuro + 0.05);
}

double _luminancia(Color cor) {
  return 0.2126 * _canal(cor.r) +
      0.7152 * _canal(cor.g) +
      0.0722 * _canal(cor.b);
}

double _canal(double v) =>
    v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

/// Distância perceptual entre duas cores (ΔE CIE76, sobre CIELAB / D65).
double _deltaE(Color a, Color b) {
  final (la, aa, ba) = _lab(a);
  final (lb, ab, bb) = _lab(b);
  return math.sqrt(
    math.pow(la - lb, 2) + math.pow(aa - ab, 2) + math.pow(ba - bb, 2),
  );
}

(double, double, double) _lab(Color cor) {
  final r = _canal(cor.r);
  final g = _canal(cor.g);
  final b = _canal(cor.b);

  final x = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047;
  final y = 0.2126 * r + 0.7152 * g + 0.0722 * b;
  final z = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883;

  double f(double t) =>
      t > 0.008856 ? math.pow(t, 1 / 3).toDouble() : 7.787 * t + 16 / 116;

  final fx = f(x);
  final fy = f(y);
  final fz = f(z);
  return (116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz));
}
