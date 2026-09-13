import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/theme/grimoire_colors.dart';
import 'package:grimorio_de_bolso/core/widgets/motion/mist_typewriter.dart';

/// A revelação com névoa do Conselheiro: o texto inteiro está na árvore
/// desde o primeiro quadro, a cauda ainda não escrita é transparente, a
/// névoa desce com a linha em escrita, e tocar completa na hora.
void main() {
  const body = 'The waxing moon favors protection and gentle beginnings. '
      'Light a white candle, speak your intention aloud, and let the '
      'flame carry it upward while you breathe slowly.';

  Future<void> show(
    WidgetTester tester, {
    required List<RevealSpan> spans,
    bool reveal = true,
    bool reduced = false,
    String? skipLabel,
  }) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [AppThemes.all.first.colors]),
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              child: MistTypewriterText(
                spans: spans,
                style: const TextStyle(fontSize: 14, height: 1.5),
                fogColor: Colors.black,
                reveal: reveal,
                skipLabel: skipLabel,
                skipKey: const ValueKey('skip'),
              ),
            ),
          ),
        ),
      ),
    ));
  }

  List<TextSpan> spansOf(WidgetTester tester) {
    final text =
        tester.widget<Text>(find.byKey(const ValueKey('mist-typewriter-text')));
    return (text.textSpan! as TextSpan).children!.cast<TextSpan>();
  }

  bool hasTransparentTail(WidgetTester tester) =>
      spansOf(tester).any((s) => s.style?.color == Colors.transparent);

  MistFogPainter? fogOf(WidgetTester tester) {
    final paints = find.byWidgetPredicate(
        (w) => w is CustomPaint && w.foregroundPainter is MistFogPainter);
    if (paints.evaluate().isEmpty) return null;
    return tester.widget<CustomPaint>(paints).foregroundPainter!
        as MistFogPainter;
  }

  testWidgets('the whole text is there from the first frame, written over time',
      (tester) async {
    await show(tester, spans: const [RevealSpan(body)]);
    await tester.pump();
    expect(find.text(body), findsOneWidget);
    expect(hasTransparentTail(tester), isTrue,
        reason: 'nothing is written yet');
    final fogStart = fogOf(tester);
    expect(fogStart, isNotNull);

    await tester.pump(const Duration(milliseconds: 1500));
    final fogLater = fogOf(tester);
    expect(fogLater, isNotNull);
    expect(fogLater!.front, greaterThan(fogStart!.front),
        reason: 'the mist descends with the writing');

    await tester.pump(MistTypewriterText.durationFor(body.length));
    await tester.pump();
    expect(hasTransparentTail(tester), isFalse);
    expect(fogOf(tester), isNull, reason: 'the mist lifts when done');
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping the text or "show all" completes at once',
      (tester) async {
    await show(tester, spans: const [RevealSpan(body)], skipLabel: 'Show all');
    await tester.pump();
    expect(find.byKey(const ValueKey('skip')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('mist-typewriter-text')));
    await tester.pump();
    expect(hasTransparentTail(tester), isFalse);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('skip')), findsNothing);

    await show(tester, spans: const [RevealSpan('$body $body')], skipLabel: 'Show all');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('skip')));
    await tester.pump();
    expect(hasTransparentTail(tester), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a restored answer and reduced motion show everything at once',
      (tester) async {
    await show(tester, spans: const [RevealSpan(body)], reveal: false);
    await tester.pump();
    expect(hasTransparentTail(tester), isFalse);
    expect(fogOf(tester), isNull);

    await show(tester, spans: const [RevealSpan(body)], reduced: true);
    await tester.pump();
    expect(hasTransparentTail(tester), isFalse);
    expect(fogOf(tester), isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a link span keeps its tap while written and is disposed cleanly',
      (tester) async {
    var taps = 0;
    await show(tester, spans: [
      const RevealSpan('Open the '),
      RevealSpan('Tarot',
          style: const TextStyle(fontWeight: FontWeight.w700),
          onTap: () => taps++,
          semanticsLabel: 'Open Tarot'),
      const RevealSpan(' tonight.'),
    ]);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    final link = spansOf(tester).singleWhere((s) => s.text == 'Tarot');
    expect(link.style?.fontWeight, FontWeight.w700);
    expect(link.recognizer, isA<TapGestureRecognizer>());
    (link.recognizer! as TapGestureRecognizer).onTap!();
    expect(taps, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
