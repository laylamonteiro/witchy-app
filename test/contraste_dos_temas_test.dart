import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/theme/grimoire_colors.dart';

/// O contraste de CADA tema, medido — não olhado.
///
/// Os seis presets nasceram por gosto, um de cada vez, e ninguém mediu
/// nenhum. Dois passaram: o dourado do tema claro era o mesmo dos temas
/// escuros (2.25 sobre a superfície clara — o selo Premium e a barra do
/// convite sumiam), e o acento da Ardósia Lavanda vivia a 92% de
/// luminosidade, o que dá contraste ótimo com o fundo e mesmo assim faz o
/// título parecer branco.
///
/// Esse segundo caso é o que este arquivo tem de menos óbvio: **contraste
/// alto com o fundo não é o mesmo que "o título tem cor"**. O que separa um
/// título colorido do texto comum é a distância dele para o TEXTO ao lado.
/// Por isso a última regra existe.
///
/// Os pisos são os da WCAG 2.1: 4.5 para texto normal, 3.0 para texto
/// grande e para elemento gráfico (ícone, barra, selo).
void main() {
  group('contraste dos temas', () {
    for (final preset in AppThemes.all) {
      final c = preset.colors;
      final nome = preset.id;

      test('$nome: texto legível sobre superfície e fundo', () {
        expect(_razao(c.textPrimary, c.surface), greaterThanOrEqualTo(4.5),
            reason: 'texto principal sobre cartão');
        expect(_razao(c.textPrimary, c.background), greaterThanOrEqualTo(4.5),
            reason: 'texto principal sobre a tela');
        expect(_razao(c.textSecondary, c.surface), greaterThanOrEqualTo(4.5),
            reason: 'texto secundário sobre cartão');
        expect(_razao(c.textSecondary, c.background), greaterThanOrEqualTo(4.5),
            reason: 'texto secundário sobre a tela');
      });

      test('$nome: o acento serve para título e para toque', () {
        // O lilás é o acento: título de seção, rótulo de convite, chevron.
        expect(_razao(c.lilac, c.surface), greaterThanOrEqualTo(4.5));
        expect(_razao(c.lilac, c.background), greaterThanOrEqualTo(4.5));
      });

      test('$nome: dourado e estrela visíveis (selo, barra, conquista)', () {
        // Piso de elemento gráfico: o dourado quase nunca é texto corrido —
        // é selo Premium, barra de progresso e estrela de Jornada.
        expect(_razao(c.gold, c.surface), greaterThanOrEqualTo(3.0),
            reason: 'a barra do convite e o selo Premium vivem no cartão');
        expect(_razao(c.starYellow, c.surface), greaterThanOrEqualTo(3.0));
        expect(_razao(c.gold, c.background), greaterThanOrEqualTo(3.0));
      });

      test('$nome: o rótulo do botão contrasta com o botão', () {
        // onPrimary é o texto DENTRO do botão lilás.
        expect(_razao(c.onPrimary, c.lilac), greaterThanOrEqualTo(4.5));
      });

      test('$nome: estado de erro e de sucesso não somem', () {
        expect(_razao(c.alert, c.surface), greaterThanOrEqualTo(3.0));
        expect(_razao(c.success, c.surface), greaterThanOrEqualTo(3.0));
      });

      test('$nome: título colorido PARECE colorido ao lado do texto', () {
        // A regra que faltava, e a única aqui que não é da WCAG.
        //
        // Contraste com o FUNDO não responde "o título tem cor?": o acento
        // antigo da Ardósia Lavanda tinha 8.17 contra o fundo — ótimo — e
        // mesmo assim os títulos saíam brancos, porque ele era branco com
        // um sopro de lilás e o texto ao lado também é branco.
        //
        // Razão de contraste não serve para medir isso: ela só enxerga
        // luminosidade, e reprovaria o verde-jade da Esmeralda (1.38), que
        // é obviamente colorido. O que responde é distância PERCEPTUAL —
        // ΔE em Lab, que conta matiz e saturação junto.
        //
        // Piso 25: o acento reprovado media 16.6 e todos os aprovados
        // passam de 33.
        expect(
          _deltaE(c.lilac, c.textPrimary),
          greaterThanOrEqualTo(25),
          reason: 'acento indistinguível do texto: os títulos perdem a cor',
        );
      });
    }

    test('a borda do cartão se enxerga contra o fundo', () {
      for (final preset in AppThemes.all) {
        final c = preset.colors;
        expect(
          _razao(c.surfaceBorder, c.background),
          greaterThanOrEqualTo(1.2),
          reason: '${preset.id}: cartão sem contorno visível',
        );
      }
    });
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
  return 0.2126 * _canal(cor.r) + 0.7152 * _canal(cor.g) + 0.0722 * _canal(cor.b);
}

double _canal(double v) =>
    v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

/// Distância perceptual entre duas cores (ΔE CIE76, sobre CIELAB / D65).
///
/// Existe para a regra do "título com cor": ao contrário da razão de
/// contraste, conta matiz e saturação, e não só o quão claro cada uma é.
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

  // sRGB → XYZ, normalizado pelo branco D65.
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
