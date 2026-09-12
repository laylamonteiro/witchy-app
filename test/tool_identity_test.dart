import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/theme/grimoire_colors.dart';
import 'package:grimorio_de_bolso/core/tools/tool_emblem_art.dart';
import 'package:grimorio_de_bolso/core/tools/tool_identity.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'support/short_test_timeout.dart';

void main() {
  useShortTestTimeout();

  test('the twelve tools each have their own emblem and their own tag', () {
    expect(ToolId.values, hasLength(12));
    for (final tool in ToolId.values) {
      final emoji = ToolIdentity.emojiOf(tool);
      final drawing = ToolIdentity.drawingOf(tool);
      // Ou emoji, ou desenho: nunca os dois, nunca nenhum — um emblema
      // vazio deixaria o card e o cabeçalho sem a arte que os liga.
      expect(emoji == null, drawing != null,
          reason: '${tool.name}: emblem must be either an emoji or a drawing');
      if (emoji != null) expect(emoji.trim(), isNotEmpty);
    }
    final emblems = [
      for (final t in ToolId.values)
        ToolIdentity.emojiOf(t)?.trim() ?? ToolIdentity.drawingOf(t)!.name,
    ];
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
        Column(children: const [
          ToolEmblem(tool: ToolId.runes, flies: false),
          ToolHeading(tool: ToolId.runes, title: 'Runes', flies: false),
        ]),
        locale: locale,
      ));
      await tester.pump();
      // Runas é um dos três emblemas DESENHADOS (a runa Raidho): o que os
      // dois lados compartilham é o desenho, não mais um glifo de fonte.
      final artes =
          tester.widgetList<ToolDrawingArt>(find.byType(ToolDrawingArt)).toList();
      expect(artes, hasLength(2),
          reason: 'The drawing does not depend on the language');
      expect(artes.every((a) => a.drawing == ToolDrawing.raidho), isTrue);
      expect(artes.map((a) => a.size).toSet(), {40.0, 22.0},
          reason: 'Card at 40, heading at 22: same drawing, two sizes');
      expect(find.text('Runes'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('the emblem does not repeat the name that sits beside it',
      (tester) async {
    await tester.pumpWidget(wrap(const ToolHeading(
      tool: ToolId.sigils,
      title: 'Sigils',
      flies: false,
    )));
    await tester.pump();
    // O desenho é arte AO LADO do nome da ferramenta, nos dois lugares em que
    // o emblema aparece: rotulá-lo faria o leitor de tela dizer "Sigilos,
    // Sigilos". Sem rótulo ele sai da árvore de semântica, como o emblema do
    // RitualCircle.
    final arte = tester.widget<ToolDrawingArt>(find.byType(ToolDrawingArt));
    expect(arte.label, isNull,
        reason: 'A drawing next to its own name must stay decorative');
    expect(
        find.descendant(
          of: find.byType(ToolDrawingArt),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget);
    expect(find.text('Sigils'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('given a label, the drawing announces itself', (tester) async {
    final semantics = tester.ensureSemantics();
    // O caminho de reuso: onde o desenho aparecer SOZINHO, longe do nome, o
    // rótulo é a única coisa que o leitor de tela tem para anunciar.
    await tester.pumpWidget(wrap(const ToolDrawingArt(
      drawing: ToolDrawing.pentagram,
      size: 40,
      label: 'Sigils',
    )));
    await tester.pump();
    expect(find.bySemanticsLabel('Sigils'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('the drawn emblems paint in all six palettes', (tester) async {
    for (final preset in AppThemes.all) {
      for (final tool in [ToolId.sigils, ToolId.runes, ToolId.pendulum]) {
        await tester.pumpWidget(MaterialApp(
          theme: ThemeData(extensions: [preset.colors]),
          locale: const Locale('pt'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Center(child: ToolEmblem(tool: tool, flies: false)),
          ),
        ));
        await tester.pump();
        expect(find.byType(ToolDrawingArt), findsOneWidget,
            reason: '${tool.name} na paleta ${preset.id}');
        expect(tester.takeException(), isNull,
            reason: '${tool.name} na paleta ${preset.id}');
      }
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
    expect(find.text(ToolIdentity.emojiOf(ToolId.tarot)!), findsWidgets);
    expect(tester.takeException(), isNull,
        reason: 'Two heroes with the same tag on screen would throw');

    navigator.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Tarot'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a drawn emblem flies just like an emoji one', (tester) async {
    await tester.pumpWidget(wrap(const ToolEmblem(tool: ToolId.pendulum)));
    await tester.pump();
    expect(find.byType(Hero), findsOneWidget);
    expect(find.byType(ToolDrawingArt), findsOneWidget);
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
    expect(find.text(ToolIdentity.emojiOf(ToolId.livingGrimoire)!), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
