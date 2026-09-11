import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/tools/tool_identity.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'support/short_test_timeout.dart';

void main() {
  useShortTestTimeout();

  test('the twelve tools each have their own emblem and their own tag', () {
    expect(ToolId.values, hasLength(12));
    for (final tool in ToolId.values) {
      expect(ToolIdentity.emblems[tool], isNotNull, reason: '${tool.name} has no emblem');
      expect(ToolIdentity.emblemOf(tool).trim(), isNotEmpty);
    }
    final emblems = [for (final t in ToolId.values) ToolIdentity.emblemOf(t).trim()];
    expect(emblems.toSet(), hasLength(ToolId.values.length),
        reason: 'Two tools sharing a symbol would fly into each other');
    final tags = [for (final t in ToolId.values) ToolIdentity.heroTag(t)];
    expect(tags.toSet(), hasLength(ToolId.values.length));
    // The tag is built from the identity, never from a translated name.
    expect(ToolIdentity.heroTag(ToolId.tarot), 'tool-emblem-tarot');
  });

  Widget wrap(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Center(child: child)),
      );

  testWidgets('the card and the heading draw the same symbol, in any language',
      (tester) async {
    for (final locale in [const Locale('en'), const Locale('pt'), const Locale('es')]) {
      await tester.pumpWidget(wrap(
        Column(children: [
          ToolEmblem(tool: ToolId.runes, flies: false),
          ToolHeading(tool: ToolId.runes, title: 'Runes', flies: false),
        ]),
        locale: locale,
      ));
      await tester.pump();
      expect(find.text(ToolIdentity.emblemOf(ToolId.runes)), findsNWidgets(2),
          reason: 'The symbol does not depend on the language');
      expect(find.text('Runes'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('opening a tool carries its emblem from the card into the heading',
      (tester) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigator,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: Center(child: ToolEmblem(tool: ToolId.tarot)),
      ),
    ));
    await tester.pump();
    expect(find.byType(Hero), findsOneWidget);

    navigator.currentState!.push(MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const ToolHeading(tool: ToolId.tarot, title: 'Tarot'),
        ),
        body: const SizedBox.shrink(),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // Mid flight the emblem lives in the overlay, above both screens.
    expect(find.byType(Hero), findsWidgets);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Tarot'), findsOneWidget);
    expect(find.text(ToolIdentity.emblemOf(ToolId.tarot)), findsWidgets);
    expect(tester.takeException(), isNull,
        reason: 'Two heroes with the same tag on screen would throw');

    navigator.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Tarot'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a long title shrinks instead of pushing the emblem out', (tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        appBar: AppBar(
          title: const ToolHeading(
            tool: ToolId.livingGrimoire,
            title: 'A very long tool name that would never fit a narrow phone',
            flies: false,
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(find.byType(FittedBox), findsWidgets);
    expect(find.text(ToolIdentity.emblemOf(ToolId.livingGrimoire)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
