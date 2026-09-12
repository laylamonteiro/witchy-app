import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/theme/grimoire_colors.dart';
import 'package:grimorio_de_bolso/features/grimoire/presentation/widgets/crystal_ball_view.dart';

/// A diagramação da bola do Conselheiro (set/2026).
///
/// A dona disse que a bola estava mal diagramada, e o defeito era calculável:
/// o pedestal ficava INTEIRO abaixo da esfera (topo em .885 da largura, fundo
/// da bola em .88), 25% mais estreito que ela, com degradê horizontal e aro de
/// ouro forte — lia como uma sombra solta, não como uma peça em que a bola
/// pousa. Nada disso precisa de olho para ser travado: é relação entre duas
/// elipses e comparação de luminância entre as seis paletas.
double _contraste(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + .05) / (math.min(la, lb) + .05);
}

void main() {
  group('geometria: a bola pousa no pedestal', () {
    // 120 é o tamanho de repouso e 64 o do teclado aberto. Tudo é derivado da
    // largura, então as duas medidas têm de dar a mesma cena.
    for (final largura in <double>[64, 120]) {
      test('em $largura px', () {
        final g = CrystalBallGeometry(largura);

        // 1. Há sobreposição de verdade: o topo do pedestal fica ACIMA do
        // fundo da esfera. Era exatamente isto que faltava.
        expect(g.pedestal.top, lessThan(g.sphere.bottom));
        expect(g.sphere.bottom - g.pedestal.top,
            greaterThan(g.width * .05),
            reason: 'sobreposição rasa demais volta a parecer sombra solta');

        // 2. O ponto mais alto do pedestal está DENTRO do círculo da esfera,
        // e as pontas laterais estão FORA. Juntas, as duas condições provam
        // que as silhuetas se cruzam: o pedestal emerge de trás da bola em
        // vez de aparecer descolado embaixo dela.
        final topo = Offset(g.center.dx, g.pedestal.top);
        expect((topo - g.center).distance, lessThan(g.radius));
        final ponta = Offset(g.pedestal.right, g.pedestal.center.dy);
        expect((ponta - g.center).distance, greaterThan(g.radius));

        // 3. Pedestal mais estreito que a bola (é um pedestal), mas não a
        // ponto de virar disquinho: antes eram 75% da largura da esfera.
        final razao = g.pedestal.width / g.sphere.width;
        expect(razao, lessThan(1.0));
        expect(razao, greaterThan(.8));

        // 4. A cena inteira cabe na caixa pintada, sem sobra morta embaixo:
        // a caixa é a altura que o widget reserva no Column do card.
        expect(g.pedestal.bottom, lessThanOrEqualTo(g.height));
        expect(g.height - g.pedestal.bottom, lessThan(g.width * .06),
            reason: 'sobra morta embaixo vira um vão entre a bola e o texto');
        expect(g.pedestal.left, greaterThanOrEqualTo(0));
        expect(g.pedestal.right, lessThanOrEqualTo(g.width));
        expect(g.sphere.top, greaterThanOrEqualTo(0));

        // 5. A sombra de contato mora no pedestal — ela é recortada nele, mas
        // se nascer maior a borda recortada vira um corte reto visível.
        expect(g.contactShadow.width, lessThan(g.pedestal.width));
        expect(g.contactShadow.bottom, lessThan(g.pedestal.bottom));

        // 6. O reflexo mora na esfera: o canto mais distante do centro ainda
        // cai dentro do círculo, senão ele encosta no aro.
        final canto = Offset(
          g.glint.center.dx - g.center.dx - g.glint.width / 2,
          g.glint.center.dy - g.center.dy - g.glint.height / 2,
        );
        expect(canto.distance, lessThan(g.radius));
      });
    }
  });

  group('cores: as seis paletas, inclusive a clara', () {
    for (final preset in AppThemes.all) {
      test(preset.id, () {
        final p = CrystalBallPalette(preset.colors);
        final carta = preset.colors.surface;

        // O que escurece tem de escurecer. No tema claro `background` é MAIS
        // CLARO que o pedestal: usá-lo como sombra iluminava a peça por baixo.
        expect(p.shade.computeLuminance(),
            lessThan(p.pedestalTop.computeLuminance()),
            reason: 'a sombra de contato precisa escurecer, não clarear');
        expect(p.pedestalBottom.computeLuminance(),
            lessThan(p.pedestalTop.computeLuminance()),
            reason: 'a luz vem de cima: o pé do pedestal é o lado escuro');

        // O que clareia tem de clarear. `textPrimary` é quase preto no tema
        // claro, e era ele que pintava o brilho especular.
        expect(p.specular.computeLuminance(),
            greaterThan(p.sphereTop.computeLuminance()),
            reason: 'brilho que escurece a bola não é brilho');

        // E o pedestal tem de se separar do card em que a cena é montada.
        expect(_contraste(p.pedestalTop, carta), greaterThan(1.25));
        expect(_contraste(p.pedestalBottom, carta), greaterThan(1.25));
      });
    }
  });

  testWidgets('a bola pinta nas seis paletas sem estourar', (tester) async {
    for (final preset in AppThemes.all) {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [preset.colors]),
        home: const Scaffold(body: Center(child: CrystalBallView())),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull, reason: preset.id);
      expect(tester.getSize(find.byType(CrystalBallView)),
          const Size(120, 126));
    }
  });
}
