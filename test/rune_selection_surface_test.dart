import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/runes/presentation/widgets/rune_selection_surface.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

void main() {
  final ids = List.generate(24, (i) => 'secret-rune-$i');
  late List<String> choices;
  setUp(() => choices = []);

  Future<void> show(WidgetTester tester, {bool reduced = false, bool enabled = true,
      double scale = 1, List<String> selected = const []}) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced, textScaler: TextScaler.linear(scale)),
        child: SingleChildScrollView(child: Center(child: SizedBox(width: 360,
          child: RuneSelectionSurface(stoneIds: ids, selectedIds: selected,
              enabled: enabled, onSelected: choices.add)))),
      )),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('tapping a stone selects the actual ID at its original place', (tester) async {
    await show(tester);
    await tester.tap(find.byKey(const ValueKey('rune-stone-7')));
    expect(choices, ['secret-rune-7']);
  });

  testWidgets('horizontal exploration never chooses on release', (tester) async {
    await show(tester);
    await tester.drag(find.byKey(const ValueKey('rune-stone-4')), const Offset(150, 0));
    await tester.pumpAndSettle();
    expect(choices, isEmpty);
    await tester.ensureVisible(find.byKey(const ValueKey('rune-select')));
    await tester.tap(find.byKey(const ValueKey('rune-select')));
    expect(choices, hasLength(1));
    expect(ids, contains(choices.single));
  });

  testWidgets('vertical scrolling does not accidentally select a stone', (tester) async {
    await show(tester);
    await tester.drag(find.byKey(const ValueKey('rune-stone-8')), const Offset(0, -180));
    await tester.pumpAndSettle();
    expect(choices, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keyboard reaches both edges and skips removed positions on resume', (tester) async {
    await show(tester, selected: [ids.first, ids.last]);
    tester.widget<Focus>(find.byKey(const ValueKey('rune-selection-focus')))
        .focusNode!.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(choices, [ids[1], ids[22]]);
    expect(find.byKey(const ValueKey('rune-stone-0')), findsNothing);
    expect(find.byKey(const ValueKey('rune-stone-23')), findsNothing);
  });

  testWidgets('large text and reduced motion preserve choices without revealing identities', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await show(tester, reduced: true, scale: 1.8);
      expect(find.bySemanticsLabel(RegExp('secret-rune')), findsNothing);
      expect(find.bySemanticsLabel('Stone 8 of 24'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(const ValueKey('rune-select')));
      await tester.tap(find.byKey(const ValueKey('rune-select')));
      expect(choices, [ids.first]);
      await show(tester, reduced: true, enabled: false);
      expect(tester.widget<FilledButton>(find.byKey(const ValueKey('rune-select'))).onPressed, isNull);
    } finally {
      semantics.dispose();
    }
  });
}
