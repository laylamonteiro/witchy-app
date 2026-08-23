import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/presentation/widgets/cycle_period_picker_sheet.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

/// O seletor de período da Leitura do Ciclo: os atalhos que poupam o desenho
/// dia a dia, e a regra do confirmar — janela FECHADA e com mais de um dia
/// (decisão da dona, 23/08: um toque só deixa a seleção pela metade, e uma
/// leitura de 24 horas não tem ciclo para contar).
///
/// As datas saem do relógio de verdade, e não de um agosto cravado: os
/// atalhos apontam para as janelas CORRENTES do produto (esta lunação, esta
/// semana), então um teste com mês fixo passaria hoje e quebraria amanhã.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final l10n = lookupAppLocalizations(const Locale('pt', 'BR'));

  final agora = DateTime.now();
  final hoje = DateTime(agora.year, agora.month, agora.day);
  final umAnoAtras = hoje.subtract(const Duration(days: 365));

  Widget tela({({DateTime start, DateTime end})? inicial}) => MaterialApp(
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: CyclePeriodPickerSheet(
              embedded: true,
              dailyCounts: const {},
              firstDate: umAnoAtras,
              lastDate: hoje,
              initialRange: inicial,
              onConfirm: (_) {},
            ),
          ),
        ),
      );

  /// O botão de confirmar aceita toque agora?
  bool confirmarHabilitado(WidgetTester tester) {
    final botao = tester.widget<ElevatedButton>(
      find.widgetWithText(
        ElevatedButton,
        l10n.cycleReadingCustomPeriodConfirm,
      ),
    );
    return botao.onPressed != null;
  }

  /// Toca num dia do mês visível. Dias 1 e 2 existem em todo mês e nunca
  /// caem no futuro, então servem para qualquer data de execução.
  Future<void> tocarDia(WidgetTester tester, int dia) async {
    await tester.tap(find.text('$dia'));
    await tester.pump();
  }

  Future<void> montar(WidgetTester tester, Widget host) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(host);
  }

  testWidgets('sem seleção o confirmar fica apagado', (tester) async {
    await montar(tester, tela());
    expect(confirmarHabilitado(tester), isFalse);
  });

  testWidgets('um dia só não basta para confirmar', (tester) async {
    await montar(tester, tela());
    await tocarDia(tester, 1);

    expect(confirmarHabilitado(tester), isFalse,
        reason: 'a janela ainda está pela metade');
  });

  testWidgets('com o dia final escolhido o confirmar acende', (tester) async {
    await montar(tester, tela());
    await tocarDia(tester, 1);
    await tocarDia(tester, 2);

    expect(confirmarHabilitado(tester), isTrue);
  });

  testWidgets('o atalho da semana já deixa a janela pronta', (tester) async {
    await montar(tester, tela());
    await tester.tap(find.text(l10n.cyclePresetWeek));
    await tester.pump();

    expect(confirmarHabilitado(tester), isTrue,
        reason: 'o atalho traz a semana corrente inteira, já fechada');
  });

  testWidgets('o atalho da lunação também nasce pronto', (tester) async {
    await montar(tester, tela());
    await tester.tap(find.text(l10n.cyclePresetLunation));
    await tester.pump();

    expect(confirmarHabilitado(tester), isTrue);
  });

  testWidgets('"Outro período" limpa a seleção e volta a apagar o confirmar',
      (tester) async {
    await montar(
      tester,
      tela(
        inicial: (
          start: hoje.subtract(const Duration(days: 10)),
          end: hoje.subtract(const Duration(days: 2)),
        ),
      ),
    );
    expect(confirmarHabilitado(tester), isTrue);

    await tester.tap(find.text(l10n.cyclePresetOther));
    await tester.pump();

    expect(confirmarHabilitado(tester), isFalse);
    expect(find.text(l10n.cycleReadingCustomPeriodHint), findsOneWidget,
        reason: 'sem nada marcado, a dica de tamanho volta');
  });
}
