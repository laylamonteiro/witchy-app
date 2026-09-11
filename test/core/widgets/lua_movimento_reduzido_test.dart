import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/theme/grimoire_colors.dart';
import 'package:grimorio_de_bolso/core/widgets/breathing_moon.dart';
import 'package:grimorio_de_bolso/core/widgets/moon_disc.dart';
import 'package:grimorio_de_bolso/core/widgets/moon_phase_widget.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/models/spell_model.dart';

/// O contrato que a lua não tinha: sob "reduzir movimento" ela PARA.
///
/// A [BreathingMoon] ligava `repeat(reverse: true)` no `initState`, sem
/// consultar ninguém, e as estrelinhas faziam o mesmo por um `Future.delayed`.
/// Além de atropelar a preferência de acessibilidade, isso prendia qualquer
/// `pumpAndSettle` para sempre — e é por isso que nenhuma das telas da lua
/// tinha teste até aqui. Cada `pumpAndSettle` deste arquivo é a asserção.
void main() {
  Widget tela(Widget filho, {bool reduzirMovimento = false}) => MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[GrimoireColors.classico],
        ),
        home: Builder(
          // `copyWith` a partir do context, e não um MediaQueryData cru: um
          // cru zeraria o tamanho da tela e o layout inteiro viraria zero.
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(disableAnimations: reduzirMovimento),
            child: Scaffold(body: Center(child: filho)),
          ),
        ),
      );

  testWidgets('lua que respira: com movimento reduzido, o laço nem começa',
      (tester) async {
    await tester.pumpWidget(
      tela(
        const BreathingMoon(phase: MoonPhase.fullMoon, showStars: false),
        reduzirMovimento: true,
      ),
    );
    // Antes daqui não se voltava.
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(MoonDisc), findsOneWidget);
  });

  testWidgets('as estrelas também param (o atraso escalonado não é agendado)',
      (tester) async {
    await tester.pumpWidget(
      tela(
        const BreathingMoon(phase: MoonPhase.newMoon, showStars: true),
        reduzirMovimento: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('sem a preferência, a lua continua respirando', (tester) async {
    await tester.pumpWidget(
      tela(const BreathingMoon(phase: MoonPhase.fullMoon, showStars: false)),
    );
    // Laço infinito de propósito: quadros contados, nunca pumpAndSettle.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    expect(find.byType(MoonDisc), findsOneWidget);
  });

  testWidgets('a fase no carrossel assenta mesmo com movimento reduzido',
      (tester) async {
    await tester.pumpWidget(
      tela(
        const MoonPhaseWidget(
          phase: MoonPhase.waxingGibbous,
          showName: false,
        ),
        reduzirMovimento: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    // Entrada de escala vai direto a 1: o disco já está no tamanho final.
    expect(tester.getSize(find.byType(MoonDisc)), const Size(60, 60));
  });

  testWidgets('o halo da lua pede size + 30 de largura', (tester) async {
    // O slot do card "Seu Rito de Hoje" era um SizedBox de 64 para uma lua de
    // 56: o halo (86) chegava raspado dos dois lados. Este número é o que
    // justifica o slot de 88 lá — se o halo mudar de tamanho, o card tem de
    // saber.
    await tester.pumpWidget(
      tela(
        const BreathingMoon(
          phase: MoonPhase.fullMoon,
          size: 56,
          showStars: false,
        ),
      ),
    );
    await tester.pump();
    expect(tester.getSize(find.byType(BreathingMoon)).width, 56 + 30);
  });
}
