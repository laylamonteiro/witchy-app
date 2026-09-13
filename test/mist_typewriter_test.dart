import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/theme/grimoire_colors.dart';
import 'package:grimorio_de_bolso/core/widgets/motion/mist_typewriter.dart';

/// A escrita da resposta do Conselheiro: o texto inteiro está na árvore
/// desde o primeiro quadro (a parte ainda não escrita é transparente), a
/// escrita espera a névoa pousar, e um toque completa na hora.
void main() {
  const body = 'The waxing moon favors protection and gentle beginnings. '
      'Light a white candle and speak your intention aloud.';

  Future<void> show(
    WidgetTester tester, {
    required List<RevealSpan> spans,
    bool reveal = true,
    bool started = true,
    bool reduced = false,
    bool ticking = true,
    String? skipLabel,
  }) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [AppThemes.all.first.colors]),
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: 220,
              child: TickerMode(
                enabled: ticking,
                child: MistTypewriterText(
                  spans: spans,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                  reveal: reveal,
                  started: started,
                  skipLabel: skipLabel,
                  skipKey: const ValueKey('skip'),
                ),
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

  /// Quanto do texto já foi escrito (o resto está transparente).
  int written(WidgetTester tester) => spansOf(tester)
      .where((s) => s.style?.color != Colors.transparent)
      .fold(0, (total, s) => total + (s.text?.length ?? 0));

  testWidgets('o texto inteiro está na árvore e vai sendo escrito',
      (tester) async {
    await show(tester, spans: const [RevealSpan(body)]);
    await tester.pump();
    expect(find.text(body), findsOneWidget);
    expect(written(tester), 0, reason: 'nada escrito ainda');

    await tester.pump(const Duration(milliseconds: 900));
    final meio = written(tester);
    expect(meio, greaterThan(0));
    expect(meio, lessThan(body.length));

    await tester.pump(MistTypewriterText.durationFor(body.length));
    expect(written(tester), body.length);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a escrita espera a névoa pousar', (tester) async {
    await show(tester,
        spans: const [RevealSpan(body)], started: false, skipLabel: 'Show all');
    await tester.pump(const Duration(seconds: 2));
    expect(find.text(body), findsOneWidget, reason: 'o texto já ocupa o lugar');
    expect(written(tester), 0);
    expect(find.byKey(const ValueKey('skip')), findsNothing,
        reason: 'não há o que pular enquanto a névoa vem');

    // A névoa pousou.
    await show(tester,
        spans: const [RevealSpan(body)], skipLabel: 'Show all');
    await tester.pump(const Duration(milliseconds: 900));
    expect(written(tester), greaterThan(0));
    expect(find.byKey(const ValueKey('skip')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tocar no texto ou em "Mostrar tudo" completa na hora',
      (tester) async {
    await show(tester, spans: const [RevealSpan(body)], skipLabel: 'Show all');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('mist-typewriter-text')));
    await tester.pump();
    expect(written(tester), body.length);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('skip')), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await show(tester, spans: const [RevealSpan(body)], skipLabel: 'Show all');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('skip')));
    await tester.pump();
    expect(written(tester), body.length);
    expect(tester.takeException(), isNull);
  });

  testWidgets('resposta restaurada e movimento reduzido aparecem inteiras',
      (tester) async {
    await show(tester, spans: const [RevealSpan(body)], reveal: false);
    await tester.pump();
    expect(written(tester), body.length);

    await tester.pumpWidget(const SizedBox.shrink());
    await show(tester, spans: const [RevealSpan(body)], reduced: true);
    await tester.pump();
    expect(written(tester), body.length);
    expect(tester.takeException(), isNull);
  });

  testWidgets('com o ticker mudo o relógio de segurança mostra a resposta',
      (tester) async {
    // A escrita anda por ticker, e o desta cena pode ficar mudo (aba em
    // segundo plano, tela que saiu da frente). Sem a rede de segurança a
    // resposta ficaria invisível para sempre: o que falta escrever é
    // transparente.
    await show(tester, spans: const [RevealSpan(body)], ticking: false);
    await tester.pump(const Duration(seconds: 2));
    expect(written(tester), 0, reason: 'nada anda com o ticker mudo');

    await tester.pump(MistTypewriterText.durationFor(body.length) +
        MistTypewriterText.guard +
        const Duration(milliseconds: 100));
    await tester.pump();
    expect(written(tester), body.length);
    expect(tester.takeException(), isNull);
  });

  testWidgets('um link continua tocável, e sair da tela não deixa rastro',
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
    final link = spansOf(tester).singleWhere((s) => s.text == 'Tarot');
    expect(link.style?.fontWeight, FontWeight.w700);
    expect(link.recognizer, isA<TapGestureRecognizer>());
    (link.recognizer! as TapGestureRecognizer).onTap!();
    expect(taps, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
