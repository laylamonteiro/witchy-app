import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/runes/data/data_sources/runes_data.dart';
import 'package:grimorio_de_bolso/features/runes/presentation/widgets/rune_selection_surface.dart';
import 'package:grimorio_de_bolso/features/runes/presentation/widgets/rune_stone_view.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

void main() {
  final ids = runesData.map((r) => r.name).toList();
  late List<String> selected;
  setUp(() => selected = []);

  Future<void> show(WidgetTester tester, {bool reduced = false,
      bool enabled = true, String? locked, double scale = 1,
      List<String>? stones, List<int>? positions}) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced, textScaler: TextScaler.linear(scale)),
        child: SingleChildScrollView(child: Center(child: SizedBox(width: 360,
          child: RuneSelectionSurface(stoneIds: stones ?? ids, deckPositions: positions,
              enabled: enabled, lockedStoneId: locked, onSelected: selected.add)))),
      )),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('a tap selects the exact hidden stone of that slot', (tester) async {
    await show(tester);
    expect(find.byType(RuneStoneView), findsNWidgets(24));
    expect(tester.widgetList<RuneStoneView>(find.byType(RuneStoneView))
        .every((s) => s.symbol == null), isTrue);
    await tester.tap(find.byKey(const ValueKey('rune-stone-17')));
    expect(selected, [ids[17]]);
  });

  testWidgets('chosen stones leave their slot empty without reshuffling', (tester) async {
    final remaining = [for (var i = 0; i < 24; i++) if (i != 3 && i != 20) i];
    await show(tester, stones: [for (final i in remaining) ids[i]], positions: remaining);
    expect(find.byKey(const ValueKey('rune-stone-3')), findsNothing);
    expect(find.byKey(const ValueKey('rune-stone-20')), findsNothing);
    expect(find.byKey(const ValueKey('rune-stone-21')), findsOneWidget);
    expect(find.text('Stone 1 of 22'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('rune-stone-21')));
    expect(selected, [ids[21]]);
  });

  testWidgets('every stone is reachable by keyboard, including rows and edges', (tester) async {
    await show(tester);
    tester.widget<Focus>(find.byKey(const ValueKey('rune-cloth-focus')))
        .focusNode!.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(find.text('Stone 1 of 24'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(find.text('Stone 7 of 24'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(find.text('Stone 2 of 24'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(find.text('Stone 24 of 24'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(selected, [ids[1], ids[23]]);
  });

  testWidgets('a short lift cancels and a deliberate lift selects once', (tester) async {
    await show(tester);
    final stone = find.byKey(const ValueKey('rune-stone-8'));
    Future<void> lift(double dy) async {
      final gesture = await tester.startGesture(tester.getCenter(stone));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
      await gesture.moveBy(Offset(0, dy));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
    }
    await lift(-20);
    expect(selected, isEmpty);
    await lift(-90);
    expect(selected, [ids[8]]);
  });

  testWidgets('a lift that leaves the cloth cancels', (tester) async {
    await show(tester);
    final gesture = await tester.startGesture(tester.getCenter(
        find.byKey(const ValueKey('rune-stone-8'))));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await gesture.moveBy(const Offset(0, -30));
    await tester.pump();
    await gesture.moveBy(const Offset(600, -100));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(selected, isEmpty);
  });

  testWidgets('a pending persisted choice is locked for retry', (tester) async {
    await show(tester, locked: ids[5]);
    expect(find.text('Stone 6 of 24'), findsOneWidget);
    expect(tester.widget<IconButton>(find.byKey(const ValueKey('rune-next'))).onPressed,
        isNull);
    await tester.tap(find.byKey(const ValueKey('rune-stone-0')));
    await tester.tap(find.byKey(const ValueKey('rune-select')));
    expect(selected, [ids[5], ids[5]]);
  });

  testWidgets('semantics never expose a stone identity; reduced motion and large text work',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await show(tester, reduced: true, scale: 2);
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('Choose your stones'), findsOneWidget);
      for (final id in ids) {
        expect(find.bySemanticsLabel(RegExp(id)), findsNothing);
      }
      await tester.ensureVisible(find.byKey(const ValueKey('rune-select')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('rune-select')));
      expect(selected, [ids[0]]);
      await show(tester, reduced: true, enabled: false);
      final button = tester.widget<FilledButton>(find.byKey(const ValueKey('rune-select')));
      expect(button.onPressed, isNull);
    } finally {
      semantics.dispose();
    }
  });
}
