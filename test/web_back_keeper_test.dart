import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/navigation/web_back_keeper.dart';

/// Na web o voltar caminha pelo histórico do NAVEGADOR. Quando as entradas do
/// app acabam, a próxima é a página anterior da aba — depois de um login
/// social, a do Google. O app parecia ter quebrado.
///
/// O contrato aqui é curto e vale a feature inteira: NUNCA deixar a entrada
/// de baixo ser a visível. Enquanto houver app por cima, o voltar tem o que
/// gastar.
void main() {
  Widget arvore() => MaterialApp(
        navigatorObservers: [appRouteObserver],
        home: WebBackKeeper(
          ativo: true,
          pagina: (_) => const Scaffold(body: Text('APP')),
        ),
      );

  testWidgets('empurra a Home sobre a entrada de baixo ao abrir',
      (tester) async {
    await tester.pumpWidget(arvore());
    await tester.pumpAndSettle();

    expect(find.text('APP'), findsOneWidget);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isTrue, reason: 'há entrada do app para gastar');
  });

  testWidgets('repõe a entrada quando o voltar consome a de cima',
      (tester) async {
    await tester.pumpWidget(arvore());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pop();
    await tester.pumpAndSettle();

    // Sem a reposição, o próximo voltar sairia do site.
    expect(find.text('APP'), findsOneWidget);
    expect(navigator.canPop(), isTrue);
  });

  testWidgets('repõe quantas vezes for — o voltar nunca chega ao fim',
      (tester) async {
    await tester.pumpWidget(arvore());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    for (var volta = 0; volta < 5; volta++) {
      navigator.pop();
      await tester.pumpAndSettle();
      expect(navigator.canPop(), isTrue, reason: 'voltar número ${volta + 1}');
    }
    expect(find.text('APP'), findsOneWidget);
  });

  testWidgets('fora da web não mexe em nada', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [appRouteObserver],
        home: WebBackKeeper(
          ativo: false,
          pagina: (_) => const Scaffold(body: Text('APP')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
    expect(find.text('APP'), findsNothing);
  });
}
