import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/theme/grimoire_colors.dart';
import 'package:grimorio_de_bolso/features/grimoire/presentation/widgets/advisor_mist_flight.dart';

/// O voo da névoa: sai da bola, atravessa a tela por cima da rolagem e some
/// ao pousar no card. Quem espera por ele é a escrita da resposta, então o
/// que este teste guarda é o CONTRATO: a promessa sempre volta, com ou sem
/// voo, e nada fica pendurado na tela depois.
void main() {
  Future<BuildContext> palco(
    WidgetTester tester,
    GlobalKey bola,
    GlobalKey card, {
    bool reduced = false,
  }) async {
    late BuildContext capturado;
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [AppThemes.all.first.colors]),
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Scaffold(
          body: Builder(builder: (context) {
            capturado = context;
            return Column(
              children: [
                SizedBox(key: bola, height: 120, width: 120),
                const Spacer(),
                SizedBox(key: card, height: 200, width: 300),
              ],
            );
          }),
        ),
      ),
    ));
    return capturado;
  }

  testWidgets('a névoa entra por cima de tudo e sai quando pousa',
      (tester) async {
    final bola = GlobalKey();
    final card = GlobalKey();
    final context = await palco(tester, bola, card);

    final voo = AdvisorMistFlight.play(context: context, from: bola, to: card);
    await tester.pump();
    expect(find.byType(AdvisorMistFlight), findsOneWidget);
    expect(voo, isA<Future<void>>());

    // No meio do caminho ela está desenhando, sem estourar.
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);

    await tester.pump(AdvisorMistFlight.duration);
    await voo;
    await tester.pump();
    expect(find.byType(AdvisorMistFlight), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('com movimento reduzido não há voo, e a promessa volta na hora',
      (tester) async {
    final bola = GlobalKey();
    final card = GlobalKey();
    final context =
        await palco(tester, bola, card, reduced: true);

    var pousou = false;
    AdvisorMistFlight.play(context: context, from: bola, to: card)
        .then((_) => pousou = true);
    await tester.pump();
    expect(find.byType(AdvisorMistFlight), findsNothing);
    await tester.pump();
    expect(pousou, isTrue);
  });

  testWidgets('a tela saindo de baixo do voo avisa quem espera', (tester) async {
    // Quem espera é a escrita da resposta. Se o voo ficasse preso a um
    // relógio solto, ela esperaria uma cena que já não existe — e o teste
    // ainda acusaria um timer pendurado depois do fim.
    final bola = GlobalKey();
    final card = GlobalKey();
    final context = await palco(tester, bola, card);

    var pousou = false;
    unawaited(AdvisorMistFlight.play(context: context, from: bola, to: card)
        .then((_) => pousou = true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(pousou, isFalse, reason: 'o voo ainda está no meio');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(pousou, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sem retângulo medido o voo é dispensado', (tester) async {
    final bola = GlobalKey();
    final card = GlobalKey();
    final context = await palco(tester, bola, card);

    // Uma chave que nunca foi montada não tem posição na tela.
    var pousou = false;
    AdvisorMistFlight.play(context: context, from: GlobalKey(), to: card)
        .then((_) => pousou = true);
    await tester.pump();
    expect(find.byType(AdvisorMistFlight), findsNothing);
    await tester.pump();
    expect(pousou, isTrue);
    expect(AdvisorMistFlight.rectOf(bola), isNotNull);
    expect(AdvisorMistFlight.rectOf(GlobalKey()), isNull);
  });
}
