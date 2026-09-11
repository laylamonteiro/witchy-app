import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/presentation/widgets/menstrual_source_tile.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/repositories/menstrual_cycle_repository.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_day.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_reading_scope.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/short_test_timeout.dart';

/// A fonte íntima na tela de fontes: desligada por padrão, fechada sem
/// Premium, e — mesmo aberta — sem autorizar nada até ela marcar.
class _Records extends MenstrualCycleRepository {
  _Records(this.days);

  final List<MenstrualDay> days;

  @override
  Future<List<MenstrualDay>> between({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async =>
      days;
}

void main() {
  useShortTestTimeout();

  final period = (start: DateTime(2026, 3, 1), end: DateTime(2026, 4, 1));
  final days = [
    MenstrualDay(
        userId: 'she',
        day: DateTime(2026, 3, 4),
        mark: MenstrualMark.start,
        symptoms: const ['cramps'],
        note: 'um dia quieto'),
    MenstrualDay(
        userId: 'she', day: DateTime(2026, 3, 6), mark: MenstrualMark.spotting),
  ];

  Future<void> settle(WidgetTester tester, bool Function() ready) async {
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      if (ready()) return;
    }
    fail('A prévia não chegou');
  }

  Future<List<MenstrualReadingScope>> show(
    WidgetTester tester, {
    bool premium = true,
    bool consented = true,
  }) async {
    SharedPreferences.setMockInitialValues(
        consented ? {'menstrual_consent_record_she': true} : {});
    final emitted = <MenstrualReadingScope>[];
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: MenstrualSourceTile(
            userId: 'she',
            period: period,
            premium: premium,
            repository: _Records(days),
            onChanged: emitted.add,
          ),
        ),
      ),
    ));
    await tester.pump();
    return emitted;
  }

  testWidgets('sem Premium a chave não abre nada', (tester) async {
    final emitted = await show(tester, premium: false);
    final tile = tester.widget<SwitchListTile>(
        find.byKey(const ValueKey('cycle-reading-menstrual')));
    expect(tile.value, isFalse, reason: 'A fonte nasce desligada');
    expect(tile.onChanged, isNull,
        reason: 'Sem Premium nem é possível abrir a prévia');
    expect(find.byKey(const ValueKey('cycle-reading-menstrual-all')),
        findsNothing);
    expect(emitted, isEmpty);
  });

  testWidgets('abrir traz o período marcado, e ela desmarca o que não quer',
      (tester) async {
    final emitted = await show(tester);
    await tester.tap(find.byKey(const ValueKey('cycle-reading-menstrual')));
    await settle(
        tester,
        () => find
            .byKey(const ValueKey('cycle-reading-menstrual-2026-03-04'))
            .evaluate()
            .isNotEmpty);

    expect(find.byKey(const ValueKey('cycle-reading-menstrual-2026-03-06')),
        findsOneWidget);
    // O sim está na chave: abrir já traz o período inteiro marcado.
    expect(find.text('2 records included'), findsOneWidget);
    expect(emitted.last.recordCount, 2);
    expect(emitted.last.start, period.start);
    expect(emitted.last.end, period.end);
    expect(emitted.last.includesWrittenWords, isTrue,
        reason: 'Abrir a fonte manda o período inteiro, relato incluso');

    // E daqui em diante ela DESmarca o que não quiser mandar.
    await tester.tap(
        find.byKey(const ValueKey('cycle-reading-menstrual-2026-03-04')));
    await tester.pump();
    expect(emitted.last.recordCount, 1);
    expect(emitted.last.entries.single.dayKey, '2026-03-06');

    await tester.tap(find.byKey(const ValueKey('cycle-reading-menstrual-none')));
    await tester.pump();
    expect(emitted.last.isEmpty, isTrue);

    await tester.tap(find.byKey(const ValueKey('cycle-reading-menstrual-all')));
    await tester.pump();
    expect(emitted.last.recordCount, 2);
  });

  testWidgets('as palavras dela saem no instante em que ela pede',
      (tester) async {
    final emitted = await show(tester);
    await tester.tap(find.byKey(const ValueKey('cycle-reading-menstrual')));
    await settle(
        tester,
        () => find
            .byKey(const ValueKey('cycle-reading-menstrual-all'))
            .evaluate()
            .isNotEmpty);
    expect(emitted.last.includesWrittenWords, isTrue);
    expect(emitted.last.fields, contains(MenstrualField.note));
    expect(emitted.last.fields, contains(MenstrualField.seasonNote));

    // Uma chave desliga o relato e deixa o resto do período de pé.
    await tester.tap(
        find.byKey(const ValueKey('cycle-reading-menstrual-words')));
    await tester.pump();
    expect(emitted.last.includesWrittenWords, isFalse);
    expect(emitted.last.fields, isNot(contains(MenstrualField.note)));
    expect(emitted.last.fields, isNot(contains(MenstrualField.seasonNote)));
    expect(emitted.last.recordCount, 2,
        reason: 'Tirar as palavras não tira os dias');

    // Desligar a fonte devolve um escopo vazio: nada fica autorizado.
    await tester.tap(find.byKey(const ValueKey('cycle-reading-menstrual')));
    await tester.pump();
    expect(emitted.last.isEmpty, isTrue);
    expect(emitted.last.includesWrittenWords, isFalse);
  });

  testWidgets('sem consentimento de registro não há prévia', (tester) async {
    await show(tester, consented: false);
    await tester.tap(find.byKey(const ValueKey('cycle-reading-menstrual')));
    await settle(
        tester,
        () => find
            .byKey(const ValueKey('cycle-reading-menstrual-empty'))
            .evaluate()
            .isNotEmpty);
    expect(find.byKey(const ValueKey('cycle-reading-menstrual-all')),
        findsNothing);
  });
}
