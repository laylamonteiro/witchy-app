import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/theme/grimoire_colors.dart';
import 'package:grimorio_de_bolso/features/grimoire/presentation/widgets/crystal_ball_view.dart';

/// A bola do Conselheiro (set/2026): uma ilustração com camadas vivas.
///
/// A esfera e a base deixaram de ser desenhadas em código — são a ilustração
/// que a dona escolheu. O que o código pinta é o que está em volta e por
/// dentro dela, e o que se confere por cálculo é a CONTENÇÃO: a esfera medida
/// na imagem fica dentro da imagem, e a aura e a órbita mais larga das faíscas
/// ficam dentro da caixa que o widget reserva. Fora da caixa, o card cortaria.
void main() {
  group('geometria: a cena cabe na caixa', () {
    // 120 é o tamanho de repouso e 64 o do teclado aberto. Tudo é derivado da
    // largura, então as duas medidas têm de dar a mesma cena.
    for (final largura in <double>[64, 120]) {
      test('em $largura px', () {
        final g = CrystalBallGeometry(largura);

        // 1. A esfera medida na ilustração está dentro da ilustração.
        expect(g.sphere.left, greaterThanOrEqualTo(g.imageRect.left));
        expect(g.sphere.right, lessThanOrEqualTo(g.imageRect.right));
        expect(g.sphere.top, greaterThanOrEqualTo(g.imageRect.top));
        expect(g.sphere.bottom, lessThanOrEqualTo(g.imageRect.bottom));

        // 2. A ilustração está dentro da caixa, com a margem do halo.
        final box = Rect.fromLTWH(0, 0, g.box.width, g.box.height);
        expect(box.contains(g.imageRect.topLeft), isTrue);
        expect(g.imageRect.right, lessThanOrEqualTo(box.right));
        expect(g.imageRect.bottom, lessThanOrEqualTo(box.bottom));

        // 3. A aura, mesmo respirando (+3%), não encosta na borda de cima
        // nem nas laterais.
        final aura = g.auraRadius * 1.03;
        expect(g.center.dy - aura, greaterThanOrEqualTo(0));
        expect(g.center.dx - aura, greaterThanOrEqualTo(0));
        expect(g.center.dx + aura, lessThanOrEqualTo(box.right));

        // 4. A órbita mais larga das faíscas, com a própria faísca na ponta,
        // cabe na largura da caixa. É isto que dimensiona o halo.
        final alcance = g.sparkOrbitMax + g.sparkSize;
        expect(g.center.dx - alcance, greaterThanOrEqualTo(0));
        expect(g.center.dx + alcance, lessThanOrEqualTo(box.right));

        // 5. A proporção da ilustração é a do arquivo (691 × 1004).
        expect(g.imageRect.height / g.imageRect.width,
            moreOrLessEquals(1004 / 691, epsilon: 1e-9));
      });
    }

    test('as faíscas saem no tamanho do teclado aberto', () {
      expect(const CrystalBallGeometry(64).showsSparks, isFalse);
      expect(const CrystalBallGeometry(120).showsSparks, isTrue);
    });

    test('a névoa nasce dentro da esfera, no mesmo ponto em qualquer tamanho',
        () {
      // O voo da resposta parte daqui. O meio da CAIXA cairia no anel
      // dourado da base; e a fração não pode depender do tamanho, senão a
      // névoa sairia de um lugar com o teclado aberto e de outro sem ele.
      final pequena = const CrystalBallGeometry(64).sphereAnchor;
      final grande = const CrystalBallGeometry(120).sphereAnchor;
      expect(pequena.x, moreOrLessEquals(grande.x, epsilon: 1e-9));
      expect(pequena.y, moreOrLessEquals(grande.y, epsilon: 1e-9));

      for (final largura in <double>[64, 120]) {
        final g = CrystalBallGeometry(largura);
        final ponto = g.sphereAnchor
            .withinRect(Rect.fromLTWH(0, 0, g.box.width, g.box.height));
        expect((ponto - g.center).distance, lessThan(g.radius * .01),
            reason: 'a âncora é o centro da esfera, em $largura px');
      }
    });

    test('a caixa de repouso é a ilustração mais o halo', () {
      final g = const CrystalBallGeometry(120);
      expect(g.box.width, moreOrLessEquals(120 + 2 * g.halo, epsilon: 1e-9));
      expect(g.box.height,
          moreOrLessEquals(120 * CrystalBallGeometry.imageAspect + 2 * g.halo,
              epsilon: 1e-9));
    });
  });

  group('cores: as seis paletas, inclusive a clara', () {
    for (final preset in AppThemes.all) {
      test(preset.id, () {
        final p = CrystalBallPalette(preset.colors);

        // A esfera é a ilustração, lilás em qualquer tema: o que se pinta por
        // cima dela tem de CLAREAR, e não seguir a paleta.
        expect(p.mist.computeLuminance(), greaterThan(.8),
            reason: 'névoa escura vira fuligem dentro do cristal');
        expect(p.star.computeLuminance(), greaterThan(.8),
            reason: 'estrela escura não é estrela');

        // O que amarra a ilustração ao tema é a aura e o ouro das faíscas.
        expect(p.aura, preset.colors.lilac);
        expect(p.spark, preset.colors.gold);
        expect(p.sparkCore.computeLuminance(),
            greaterThan(preset.colors.gold.computeLuminance()),
            reason: 'o miolo da faísca é o ouro clareado');
      });
    }
  });

  testWidgets('a bola pinta nas seis paletas sem estourar, parada e em movimento',
      (tester) async {
    for (final preset in AppThemes.all) {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [preset.colors]),
        home: const Scaffold(body: Center(child: CrystalBallView())),
      ));
      await tester.pump();
      // Alguns quadros do loop: as camadas mudam de fase sem exceção.
      await tester.pump(const Duration(milliseconds: 2400));
      await tester.pump(const Duration(milliseconds: 2400));

      expect(tester.takeException(), isNull, reason: preset.id);
      expect(tester.getSize(find.byType(CrystalBallView)),
          const CrystalBallGeometry(120).box);
    }
    // Sem isto o loop segue agendando quadros depois do teste.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('com movimento reduzido a cena fica num quadro parado',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [AppThemes.all.first.colors]),
      home: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: const Scaffold(body: Center(child: CrystalBallView())),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    expect(tester.binding.hasScheduledFrame, isFalse,
        reason: 'com movimento reduzido o loop não roda');
  });
}
