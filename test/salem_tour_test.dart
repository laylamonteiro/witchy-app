import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/widgets/mascot/salem_tour.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

// O relato: "o botão de pular o walk-through do Salem não está funcionando
// no webapp". O botão em si sempre chamou `onFinished`; o que morria era o
// State da Home que recebia a chamada (ver splash_screen_test). Este teste
// fixa a metade do overlay: pular e concluir chamam `onFinished` UMA vez.
void main() {
  Future<AppLocalizations> montar(
    WidgetTester tester, {
    required VoidCallback aoConcluir,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SalemTourOverlay(
            onTabChange: (_) {},
            onFinished: aoConcluir,
          ),
        ),
      ),
    );
    // O overlay tem animações contínuas (o anel pulsando): quadros contados,
    // nunca pumpAndSettle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    return AppLocalizations.of(tester.element(find.byType(SalemTourOverlay)));
  }

  testWidgets('"Pular tour" no primeiro passo encerra o tour uma vez',
      (tester) async {
    var concluido = 0;
    final l10n = await montar(tester, aoConcluir: () => concluido++);

    expect(find.text(l10n.salemTourSkip), findsOneWidget);
    await tester.tap(find.text(l10n.salemTourSkip));
    await tester.pump();

    expect(concluido, 1);
  });

  testWidgets('tocar no véu avança os passos e o último conclui',
      (tester) async {
    var concluido = 0;
    final l10n = await montar(tester, aoConcluir: () => concluido++);

    // Avança tocando fora do balão até o botão de pular sumir (último
    // passo), com um teto para o teste nunca rodar para sempre.
    var passos = 0;
    while (find.text(l10n.salemTourSkip).evaluate().isNotEmpty &&
        passos < 12) {
      await tester.tapAt(const Offset(400, 300));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      passos++;
    }
    expect(find.text(l10n.salemTourSkip), findsNothing,
        reason: 'chegou ao último passo em $passos toques');
    expect(concluido, 0);

    await tester.tapAt(const Offset(400, 300));
    await tester.pump();
    expect(concluido, 1);
  });
}
