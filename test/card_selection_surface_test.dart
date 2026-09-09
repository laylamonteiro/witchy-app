import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/divination/presentation/widgets/card_selection_surface.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

void main() {
  final ids = List.generate(78, (i) => 'card-$i');
  late List<String> selected;
  setUp(() => selected = []);

  Future<void> show(WidgetTester tester, {bool reduced = false,
      bool enabled = true, String? locked, double scale = 1}) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced, textScaler: TextScaler.linear(scale)),
        child: SingleChildScrollView(child: Center(child: SizedBox(width: 360,
          child: CardSelectionSurface(cardIds: ids, enabled: enabled,
              lockedCardId: locked, onSelected: selected.add)))),
      )),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('horizontal exploration does not select on release', (tester) async {
    await show(tester);
    await tester.drag(find.byKey(const ValueKey('card-fan-gesture')), const Offset(-160, 0));
    await tester.pumpAndSettle();
    expect(selected, isEmpty);
    expect(find.text('Card 40 of 78'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('fan-select')));
    expect(selected, hasLength(1));
    expect(ids, contains(selected.single));
  });

  testWidgets('a tap selects the actual frontmost hidden ID', (tester) async {
    await show(tester);
    await tester.tap(find.byKey(const ValueKey('fan-card-39')));
    expect(selected, ['card-39']);
  });

  testWidgets('all positions are reachable by keyboard, including the edges', (tester) async {
    await show(tester);
    tester.widget<Focus>(find.byKey(const ValueKey('card-fan-focus')))
        .focusNode!.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(find.text('Card 1 of 78'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(find.text('Card 78 of 78'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(selected, ['card-0', 'card-77']);
  });

  testWidgets('short withdrawal cancels and deliberate withdrawal selects once', (tester) async {
    await show(tester);
    final card = find.byKey(const ValueKey('fan-card-39'));
    await tester.drag(card, const Offset(0, -40));
    await tester.pumpAndSettle();
    expect(selected, isEmpty);
    await tester.drag(card, const Offset(0, -140));
    await tester.pumpAndSettle();
    expect(selected, ['card-39']);
  });

  testWidgets('a withdrawal outside the surface cancels', (tester) async {
    await show(tester);
    final gesture = await tester.startGesture(tester.getCenter(
        find.byKey(const ValueKey('fan-card-39'))));
    await gesture.moveBy(const Offset(0, -35));
    await tester.pump();
    await gesture.moveBy(const Offset(500, -100));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(selected, isEmpty);
  });

  testWidgets('a pending persisted choice is locked for retry', (tester) async {
    await show(tester, locked: ids.first);
    expect(find.text('Card 1 of 78'), findsOneWidget);
    await tester.drag(find.byKey(const ValueKey('card-fan-gesture')), const Offset(-160, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('fan-select')));
    expect(selected, [ids.first]);
  });

  testWidgets('reduced motion, large text and disabled state keep usable semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);
    await show(tester, reduced: true, scale: 2);
    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel('Choose your card'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('fan-select')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('fan-select')).hitTestable(), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('fan-select')));
    expect(selected, ['card-39']);
    await show(tester, reduced: true, enabled: false);
    final button = tester.widget<FilledButton>(find.byKey(const ValueKey('fan-select')));
    expect(button.onPressed, isNull);
  });
}
