import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/widgets/reading_focus_panel.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'support/short_test_timeout.dart';

/// O painel de foco: a peça fica, o texto troca, e percorrer as posições
/// nunca depende de um só caminho.
void main() {
  useShortTestTimeout();

  Future<List<int>> show(
    WidgetTester tester, {
    required int index,
    required int total,
    bool withStage = true,
    String keyPrefix = 'oracle',
  }) async {
    final asked = <int>[];
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: ReadingFocusPanel(
            keyPrefix: keyPrefix,
            index: index,
            total: total,
            onFocus: asked.add,
            stage: withStage
                ? const SizedBox(key: ValueKey('a-stage'), width: 80, height: 120)
                : null,
            child: Text('posição $index'),
          ),
        ),
      ),
    ));
    await tester.pump();
    return asked;
  }

  testWidgets('as setas andam uma posição e param nas pontas', (tester) async {
    var asked = await show(tester, index: 1, total: 3);
    await tester.tap(find.byKey(const ValueKey('oracle-focus-next')));
    await tester.pump();
    expect(asked, [2]);
    await tester.tap(find.byKey(const ValueKey('oracle-focus-prev')));
    await tester.pump();
    expect(asked, [2, 0]);

    // Na ponta a seta continua lá e continua focável — ela só não leva a
    // lugar nenhum, senão o teclado perderia o lugar no fim da lista.
    asked = await show(tester, index: 0, total: 3);
    await tester.tap(find.byKey(const ValueKey('oracle-focus-prev')));
    await tester.pump();
    expect(asked, isEmpty, reason: 'Não existe posição antes da primeira');

    asked = await show(tester, index: 2, total: 3);
    await tester.tap(find.byKey(const ValueKey('oracle-focus-next')));
    await tester.pump();
    expect(asked, isEmpty, reason: 'Nem depois da última');
  });

  testWidgets('arrastar na horizontal anda; um arrasto lento não', (tester) async {
    var asked = await show(tester, index: 1, total: 3);
    await tester.fling(
        find.byKey(const ValueKey('oracle-focus')), const Offset(-300, 0), 800);
    await tester.pumpAndSettle();
    expect(asked, [2]);

    asked = await show(tester, index: 1, total: 3);
    await tester.fling(
        find.byKey(const ValueKey('oracle-focus')), const Offset(300, 0), 800);
    await tester.pumpAndSettle();
    expect(asked, [0]);

    asked = await show(tester, index: 1, total: 3);
    await tester.drag(
        find.byKey(const ValueKey('oracle-focus')), const Offset(-40, 0));
    await tester.pumpAndSettle();
    expect(asked, isEmpty, reason: 'Um arrasto curto e lento não é um pedido');

    asked = await show(tester, index: 2, total: 3);
    await tester.fling(
        find.byKey(const ValueKey('oracle-focus')), const Offset(-300, 0), 800);
    await tester.pumpAndSettle();
    expect(asked, isEmpty, reason: 'Não há posição depois da última');
  });

  testWidgets('uma posição só não ganha setas nem contador', (tester) async {
    await show(tester, index: 0, total: 1, withStage: false);
    expect(find.byKey(const ValueKey('oracle-focus-next')), findsNothing);
    expect(find.byKey(const ValueKey('oracle-focus-prev')), findsNothing);
    expect(find.textContaining('of'), findsNothing);
    expect(find.byKey(const ValueKey('a-stage')), findsNothing);
    expect(find.text('posição 0'), findsOneWidget);
  });

  testWidgets('o contador diz onde ela está', (tester) async {
    await show(tester, index: 1, total: 5);
    expect(find.text('Position 2 of 5'), findsOneWidget);
  });

  testWidgets('as runas usam o mesmo painel, com as chaves delas',
      (tester) async {
    final asked = await show(tester, index: 0, total: 3, keyPrefix: 'runes');
    expect(find.byKey(const ValueKey('runes-focus')), findsOneWidget);
    expect(find.byKey(const ValueKey('runes-focus-prev')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('runes-focus-next')));
    await tester.pump();
    expect(asked, [1]);
  });
}
