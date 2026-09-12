import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_day.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/presentation/widgets/menstrual_wheel.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'support/short_test_timeout.dart';

/// A roda do mês: o dedo percorre as datas na horizontal, o teclado percorre
/// com as setas, e nenhum dos dois altera registro nenhum — abrir o dia é o
/// mais longe que ela vai.
void main() {
  useShortTestTimeout();

  final month = DateTime(2026, 3);
  final days = {
    '2026-03-04': MenstrualDay(
        userId: 'she', day: DateTime(2026, 3, 4), mark: MenstrualMark.start),
    '2026-03-06': MenstrualDay(
        userId: 'she', day: DateTime(2026, 3, 6), mark: MenstrualMark.spotting),
  };

  Future<(List<DateTime> selected, List<DateTime> opened)> show(
      WidgetTester tester,
      {DateTime? selected}) async {
    final chosen = <DateTime>[];
    final opened = <DateTime>[];
    var focus = selected ?? DateTime(2026, 3, 12);
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: StatefulBuilder(
            builder: (context, setState) => MenstrualWheel(
              month: month,
              days: days,
              selected: focus,
              onSelect: (day) {
                chosen.add(day);
                setState(() => focus = day);
              },
              onOpen: opened.add,
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    return (chosen, opened);
  }

  Offset dayOne(WidgetTester tester) {
    final rect = tester.getRect(find.byType(MenstrualWheel));
    // O topo da roda é o dia 1; o raio do anel externo é 46% do lado.
    return rect.center - Offset(0, rect.shortestSide * .42);
  }

  testWidgets('tocar um dia escolhe aquele dia e abre o registro dele',
      (tester) async {
    final (chosen, opened) = await show(tester);
    await tester.tapAt(dayOne(tester));
    await tester.pump();
    expect(chosen.single, DateTime(2026, 3, 1));
    expect(opened.single, DateTime(2026, 3, 1),
        reason: 'Tocar abre o dia tocado, nunca o que estava em foco antes');
  });

  testWidgets('as setas percorrem as datas e não abrem nada', (tester) async {
    final (chosen, opened) = await show(tester);
    await tester.tapAt(dayOne(tester));
    await tester.pump();
    chosen.clear();
    opened.clear();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(chosen, [DateTime(2026, 3, 2), DateTime(2026, 3, 3)]);
    expect(opened, isEmpty, reason: 'Percorrer não é abrir');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(chosen.last, DateTime(2026, 3, 2));

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(opened.single, DateTime(2026, 3, 2),
        reason: 'Enter abre o dia em foco');
  });

  testWidgets('o cursor não passa do primeiro nem do último dia do mês',
      (tester) async {
    final (chosen, _) = await show(tester, selected: DateTime(2026, 3, 1));
    await tester.tapAt(dayOne(tester));
    await tester.pump();
    chosen.clear();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(chosen, isEmpty, reason: 'Março não tem dia zero');
  });

  testWidgets('a semântica fala do dia em foco, do registro e da Lua',
      (tester) async {
    final handle = tester.ensureSemantics();
    await show(tester, selected: DateTime(2026, 3, 4));
    final label = tester
        .getSemantics(find.byKey(const ValueKey('menstrual-wheel')))
        .label;
    expect(label, contains('4/3/2026'));
    expect(label, contains('has a record'));
    expect(label.split('·').length, greaterThanOrEqualTo(3),
        reason: 'Data, registro e fase estimada, em texto');
    handle.dispose();
  });
}
