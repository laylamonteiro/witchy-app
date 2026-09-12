import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/theme/grimoire_colors.dart';
import 'package:grimorio_de_bolso/features/divination/presentation/widgets/grimoire_card_back.dart';
import 'package:grimorio_de_bolso/features/tarot/presentation/widgets/tarot_card_view.dart';

/// O verso é pintado em código, sem asset nenhum, e é o MESMO widget no leque
/// do Tarô e no do Oráculo. Por isso duas coisas precisam de guarda: que o
/// desenho não estoure em nenhuma das seis paletas (uma delas é clara, onde o
/// dourado corre risco de contraste), e que quem chama sem dizer o baralho
/// continue recebendo o verso do Tarô — o leque é compartilhado, e uma troca
/// silenciosa ali mudaria a cara do Tarô sem ninguém pedir.
void main() {
  Widget moldura(GrimoireColors colors, Widget child) => MaterialApp(
        theme: ThemeData(extensions: [colors]),
        home: Scaffold(body: Center(child: child)),
      );

  double razao(Color a, Color b) {
    final alta = a.computeLuminance() > b.computeLuminance();
    final maior = alta ? a.computeLuminance() : b.computeLuminance();
    final menor = alta ? b.computeLuminance() : a.computeLuminance();
    return (maior + .05) / (menor + .05);
  }

  testWidgets('os dois versos pintam nas seis paletas', (tester) async {
    for (final preset in AppThemes.all) {
      for (final face in GrimoireBackFace.values) {
        // Posições espalhadas: cobrem todas as marcas dos dois baralhos (seis
        // no Tarô, quatro no Oráculo) sem renderizar 44 vezes por paleta.
        for (final deckPosition in const [0, 1, 2, 3, 4, 5, 43]) {
          await tester.pumpWidget(moldura(
            preset.colors,
            GrimoireCardBack(
              width: 110,
              height: 110 / TarotCardView.aspectRatio,
              deckPosition: deckPosition,
              face: face,
            ),
          ));
          await tester.pump();
          expect(tester.takeException(), isNull,
              reason: 'verso ${face.name} na paleta ${preset.id}, '
                  'posição $deckPosition');
        }
      }
    }
  });

  testWidgets('o verso do Oráculo tem a proporção clássica da carta',
      (tester) async {
    await tester.pumpWidget(moldura(
      AppThemes.all.first.colors,
      const OracleCardBack(width: 100, deckPosition: 7),
    ));
    await tester.pump();
    final caixa = tester.getSize(find.byType(OracleCardBack));
    expect(caixa.width, closeTo(100, 0.01));
    expect(caixa.height, closeTo(100 / TarotCardView.aspectRatio, 0.01));
    final interno = tester.widget<GrimoireCardBack>(find.descendant(
        of: find.byType(OracleCardBack),
        matching: find.byType(GrimoireCardBack)));
    expect(interno.face, GrimoireBackFace.oracle);
    expect(interno.deckPosition, 7,
        reason: 'A marca segue o lugar embaralhado, nunca o id da frente');
  });

  group('a moldura de fora do Oráculo é dourada: ela precisa se ver', () {
    for (final preset in AppThemes.all) {
      test(preset.id, () {
        // O Tarô usa o dourado só num filete fino por dentro; no Oráculo ele
        // é a borda externa, que é o que separa os dois baralhos no leque.
        // Piso de 3.0 da WCAG para elemento gráfico — inclusive no tema claro,
        // onde o dourado é um bronze escuro de propósito.
        expect(razao(preset.colors.gold, preset.colors.surface),
            greaterThanOrEqualTo(3.0));
      });
    }
  });

  test('sem dizer o baralho, o verso continua sendo o do Tarô', () {
    const verso = GrimoireCardBack(width: 10, height: 10, deckPosition: 0);
    expect(verso.face, GrimoireBackFace.tarot);
  });
}
