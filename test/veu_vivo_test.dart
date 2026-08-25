import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/widgets/veu_vivo.dart';

/// O véu que se mexe — e o que ele continua NÃO fazendo.
///
/// O movimento é enfeite; o fail-closed é regra. Espiar afasta o véu e
/// acende o brilho, mas o que está por baixo segue sendo o mesmo conteúdo
/// de enfeite que já estava lá: nenhum toque faz aparecer palavra nova, e
/// nada disso chega à árvore de semântica.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const enfeite = 'texto de enfeite sob o véu';

  Widget tela({bool reduzirMovimento = false}) => MaterialApp(
        home: Builder(
          // `copyWith` a partir do context, e não um MediaQueryData cru: um
          // cru zeraria o tamanho da tela e o layout inteiro viraria zero.
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(disableAnimations: reduzirMovimento),
            child: const Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  child: VeuVivo(child: Text(enfeite)),
                ),
              ),
            ),
          ),
        ),
      );

  testWidgets('espiar não faz nascer palavra nenhuma', (tester) async {
    await tester.pumpWidget(tela());
    await tester.pump(const Duration(milliseconds: 300));

    final antes = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .toList();

    await tester.tap(find.byType(VeuVivo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 550));

    final depois = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .toList();

    expect(depois, antes,
        reason: 'espiar mostra luz, nunca conteúdo — o fail-closed é regra');
    expect(depois, [enfeite]);
  });

  testWidgets('o véu inteiro fica fora da árvore de semântica',
      (tester) async {
    await tester.pumpWidget(tela());
    await tester.pump(const Duration(milliseconds: 300));

    // Não só o texto: o gesto de espiar também não é ação para leitor de
    // tela, porque não leva a lugar nenhum.
    expect(
      find.descendant(
        of: find.byType(ExcludeSemantics),
        matching: find.byType(GestureDetector),
      ),
      findsWidgets,
    );
    expect(
      find.descendant(
        of: find.byType(ExcludeSemantics),
        matching: find.text(enfeite),
      ),
      findsOneWidget,
    );
  });

  testWidgets('com "reduzir movimento" a tela assenta — nada anima em laço',
      (tester) async {
    // Este é o teste que prova o congelamento: `pumpAndSettle` espera os
    // quadros PARAREM. Se o brilho continuasse em laço com a acessibilidade
    // ligada, ele estouraria o tempo e o teste falharia aqui.
    await tester.pumpWidget(tela(reduzirMovimento: true));
    await tester.pumpAndSettle();

    expect(find.text(enfeite), findsOneWidget);
  });

  testWidgets('com "reduzir movimento" o toque não dispara animação',
      (tester) async {
    await tester.pumpWidget(tela(reduzirMovimento: true));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(VeuVivo));
    await tester.pumpAndSettle();

    expect(find.text(enfeite), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quem espia pode ser avisado (para o motor de ofertas)',
      (tester) async {
    var espiadas = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 300,
            child: VeuVivo(
              aoEspiar: () => espiadas++,
              child: const Text(enfeite),
            ),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.byType(VeuVivo));
    await tester.pump(const Duration(milliseconds: 200));

    expect(espiadas, 1);
  });
}
