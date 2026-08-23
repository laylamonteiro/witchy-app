import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/presentation/widgets/cycle_period_picker_sheet.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

/// O seletor de período da Leitura do Ciclo: os atalhos que poupam o desenho
/// dia a dia, e a regra do confirmar — janela FECHADA e com mais de um dia
/// (decisão da dona, 23/08: um toque só deixa a seleção pela metade, e uma
/// leitura de 24 horas não tem ciclo para contar).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final l10n = lookupAppLocalizations(const Locale('pt', 'BR'));

  // Agosto/2026 inteiro disponível, sem registro nenhum (o calor não importa
  // para estas regras).
  final primeiroDia = DateTime(2026, 8, 1);
  final ultimoDia = DateTime(2026, 8, 31);

  Widget tela({({DateTime start, DateTime end})? inicial}) => MaterialApp(
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: CyclePeriodPickerSheet(
              embedded: true,
              dailyCounts: const {},
              firstDate: primeiroDia,
              lastDate: ultimoDia,
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

  /// Toca num dia do mês visível. `find.text` acha a célula do dia porque o
  /// número aparece uma vez só na grade.
  Future<void> tocarDia(WidgetTester tester, int dia) async {
    await tester.tap(find.text('$dia'));
    await tester.pump();
  }

  testWidgets('sem seleção o confirmar fica apagado', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(tela());
    expect(confirmarHabilitado(tester), isFalse);
  });

  testWidgets('um dia só não basta para confirmar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(tela());
    await tocarDia(tester, 5);

    expect(confirmarHabilitado(tester), isFalse,
        reason: 'a janela ainda está pela metade');
  });

  testWidgets('com o dia final escolhido o confirmar acende', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(tela());
    await tocarDia(tester, 5);
    await tocarDia(tester, 12);

    expect(confirmarHabilitado(tester), isTrue);
  });

  testWidgets('o atalho de 7 dias já deixa a janela pronta', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(tela());
    await tester.tap(find.text(l10n.cyclePreset7Days));
    await tester.pump();

    expect(confirmarHabilitado(tester), isTrue,
        reason: 'o atalho fecha a janela sozinho: 1 a 7 de agosto');
  });

  testWidgets('"Outro período" limpa a seleção e volta a apagar o confirmar',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      tela(inicial: (start: DateTime(2026, 8, 3), end: DateTime(2026, 8, 10))),
    );
    expect(confirmarHabilitado(tester), isTrue);

    await tester.tap(find.text(l10n.cyclePresetOther));
    await tester.pump();

    expect(confirmarHabilitado(tester), isFalse);
    expect(find.text(l10n.cycleReadingCustomPeriodHint), findsOneWidget,
        reason: 'sem nada marcado, a dica de tamanho volta');
  });
}
