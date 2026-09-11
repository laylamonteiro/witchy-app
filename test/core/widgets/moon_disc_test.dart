import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/theme/grimoire_colors.dart';
import 'package:grimorio_de_bolso/core/widgets/moon_disc.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/models/spell_model.dart';

/// A lua do Grimório deixou de ser um emoji e passou a ser desenhada.
///
/// O motivo está na queixa que abriu o conserto: a mesma tela, no mesmo dia,
/// mostrava uma lua com relevo no aparelho e um disco chapado no navegador.
/// Enquanto a fase fosse um caractere, a arte era a da FONTE de quem abria o
/// app — e o app não tinha como consertar o que nunca desenhou.
///
/// O que este arquivo tranca:
/// 1. a geometria (quanto acende e de que lado), que é o que faz o desenho
///    concordar com o nome escrito ao lado;
/// 2. as cores nas SEIS paletas — inclusive a clara, onde uma lua pintada de
///    `softWhite` (apelido de `textPrimary`, quase preto ali) viraria carvão;
/// 3. que nenhum glifo de fase sobrou na árvore.
void main() {
  group('geometria da fase', () {
    test('nova apagada, cheia acesa, quartos pela metade', () {
      expect(fracaoIluminada(MoonPhase.newMoon), closeTo(0.0, 1e-9));
      expect(fracaoIluminada(MoonPhase.fullMoon), closeTo(1.0, 1e-9));
      expect(fracaoIluminada(MoonPhase.firstQuarter), closeTo(0.5, 1e-9));
      expect(fracaoIluminada(MoonPhase.lastQuarter), closeTo(0.5, 1e-9));
    });

    test('crescente é fio, gibosa é quase tudo', () {
      expect(fracaoIluminada(MoonPhase.waxingCrescent), lessThan(0.25));
      expect(fracaoIluminada(MoonPhase.waningCrescent), lessThan(0.25));
      expect(fracaoIluminada(MoonPhase.waxingGibbous), greaterThan(0.75));
      expect(fracaoIluminada(MoonPhase.waningGibbous), greaterThan(0.75));
    });

    test('a lunação é simétrica: cada fase tem a irmã do outro lado', () {
      expect(
        fracaoIluminada(MoonPhase.waxingCrescent),
        closeTo(fracaoIluminada(MoonPhase.waningCrescent), 1e-9),
      );
      expect(
        fracaoIluminada(MoonPhase.waxingGibbous),
        closeTo(fracaoIluminada(MoonPhase.waningGibbous), 1e-9),
      );
    });

    test('só a metade que cresce acende à direita', () {
      // É esta a asserção que impede alguém de espelhar a lua numa
      // refatoração distraída: no hemisfério sul o desenho seria o oposto,
      // mas o app inteiro (e o emoji que ele substituiu) lê pelo norte.
      const crescendo = {
        MoonPhase.waxingCrescent,
        MoonPhase.firstQuarter,
        MoonPhase.waxingGibbous,
      };
      for (final fase in MoonPhase.values) {
        expect(
          luaCrescendo(fase),
          crescendo.contains(fase),
          reason: '$fase saiu do lado errado',
        );
      }
    });
  });

  group('as cores funcionam nas seis paletas', () {
    for (final preset in AppThemes.all) {
      final gc = preset.colors;
      final cores = coresDaLua(gc);

      test('${preset.id}: o terminador se enxerga', () {
        // Sem distância entre as duas faces, toda fase vira um disco liso.
        expect(
          _razao(cores.iluminado, cores.sombra),
          greaterThanOrEqualTo(3.0),
        );
      });

      test('${preset.id}: a Lua Nova não some no chão em que está', () {
        // Na Lua Nova o disco inteiro é a face na sombra: se ela empatar com
        // o chão, o card fica vazio no dia mais importante do ciclo. Os dois
        // chãos contam — a lua do hero fica sobre o fundo da tela, e a das
        // listas e do carrossel, dentro de um cartão.
        expect(_razao(cores.sombra, gc.background), greaterThanOrEqualTo(1.2));
        expect(_razao(cores.sombra, gc.surface), greaterThanOrEqualTo(1.2));
      });

      test('${preset.id}: a face acesa lê como elemento gráfico', () {
        // Piso de 3.0 da WCAG para elemento gráfico, com folga.
        expect(
          _razao(cores.iluminado, gc.background),
          greaterThanOrEqualTo(4.0),
        );
        expect(
          _razao(cores.iluminado, gc.surface),
          greaterThanOrEqualTo(4.0),
        );
        expect(
          _razao(cores.iluminado, gc.background),
          greaterThan(_razao(cores.sombra, gc.background)),
          reason: 'a face acesa tem de ser a que mais se destaca do fundo',
        );
      });

      test('${preset.id}: a lua é feita da luz da paleta, não do texto', () {
        // A armadilha que este teste existe para prender: `softWhite` é
        // apelido de `textPrimary`. Nas cinco paletas escuras isso passa
        // despercebido (textPrimary é quase branco), mas na Lavanda-névoa
        // textPrimary é `241F30` — a lua nasceria de carvão. Razão de
        // contraste não pega isso (preto sobre claro contrasta ótimo); o que
        // pega é a distância perceptual até o acento.
        expect(
          _deltaE(cores.iluminado, gc.lilac),
          lessThan(_deltaE(gc.textPrimary, gc.lilac)),
        );
      });
    }
  });

  group('o disco na árvore', () {
    Widget tela(Widget filho, {GrimoireColors? paleta}) => MaterialApp(
          theme: ThemeData(
            extensions: <ThemeExtension<dynamic>>[
              paleta ?? GrimoireColors.classico,
            ],
          ),
          home: Scaffold(body: Center(child: filho)),
        );

    for (final fase in MoonPhase.values) {
      testWidgets('$fase pinta sem emoji e sem estourar', (tester) async {
        await tester.pumpWidget(tela(MoonDisc(phase: fase)));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          find.descendant(
            of: find.byType(MoonDisc),
            matching: find.byType(CustomPaint),
          ),
          findsWidgets,
        );
        // A prova de que a fase não depende mais de fonte nenhuma.
        expect(find.text(fase.emoji), findsNothing);
      });
    }

    testWidgets('também pinta no tema claro', (tester) async {
      await tester.pumpWidget(
        tela(
          const MoonDisc(phase: MoonPhase.waningCrescent),
          paleta: GrimoireColors.lavandaNevoa,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('é mudo para o leitor de tela', (tester) async {
      // Quem fala a fase é o nome que todos os chamadores escrevem ao lado;
      // um rótulo aqui seria leitura dobrada.
      await tester.pumpWidget(tela(const MoonDisc(phase: MoonPhase.fullMoon)));
      expect(
        find.descendant(
          of: find.byType(MoonDisc),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
    });

    testWidgets('ocupa exatamente o tamanho pedido', (tester) async {
      await tester.pumpWidget(
        tela(const MoonDisc(phase: MoonPhase.firstQuarter, size: 44)),
      );
      expect(tester.getSize(find.byType(MoonDisc)), const Size(44, 44));
    });
  });
}

/// Razão de contraste da WCAG 2.1 entre duas cores opacas.
double _razao(Color a, Color b) {
  final la = _luminancia(a);
  final lb = _luminancia(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

double _luminancia(Color cor) =>
    0.2126 * _canal(cor.r) + 0.7152 * _canal(cor.g) + 0.0722 * _canal(cor.b);

double _canal(double v) =>
    v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

/// Distância perceptual (ΔE CIE76 sobre CIELAB/D65): conta matiz e saturação,
/// e não só o quão clara cada cor é.
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
