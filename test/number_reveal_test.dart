import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/numerology/domain/numerology_calculator.dart';
import 'package:grimorio_de_bolso/features/numerology/presentation/widgets/number_reveal.dart';
import 'support/short_test_timeout.dart';

void main() {
  useShortTestTimeout();

  Future<void> show(WidgetTester tester, int value, {bool reduced = false}) async {
    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Scaffold(body: Center(child: NumberReveal(value: value))),
      ),
    ));
    await tester.pump();
  }

  testWidgets('the count lands on the calculated number and stays there',
      (tester) async {
    await show(tester, 7);
    expect(find.text('0'), findsOneWidget, reason: 'It starts from the beginning');
    await tester.pump(const Duration(milliseconds: 200));
    final midway = int.parse(tester.widget<Text>(find.byType(Text)).data!);
    expect(midway, lessThanOrEqualTo(7));
    await tester.pumpAndSettle();
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('reduced motion shows the calculated number at once', (tester) async {
    await show(tester, 22, reduced: true);
    expect(find.text('22'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('22'), findsOneWidget);
  });

  testWidgets('a master number is never reduced by the animation', (tester) async {
    // O cálculo é quem preserva 11, 22 e 33 — a contagem só chega neles.
    for (final master in [11, 22, 33]) {
      await show(tester, master);
      await tester.pumpAndSettle();
      expect(find.text('$master'), findsOneWidget);
    }
    expect(NumerologyCalculator.reduce(29), 11,
        reason: 'The rule that keeps masters is the calculator, untouched');
  });

  testWidgets('the semantics always announce the final number', (tester) async {
    final semantics = tester.ensureSemantics();
    await show(tester, 9);
    expect(find.bySemanticsLabel('9'), findsOneWidget,
        reason: 'Before the count arrives, the announced value is the real one');
    await tester.pumpAndSettle();
    expect(find.text('9'), findsOneWidget);
    semantics.dispose();
  });
}
