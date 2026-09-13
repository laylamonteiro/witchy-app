import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/presentation/widgets/menstrual_source_tile.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/repositories/menstrual_cycle_repository.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_day.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_reading_scope.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/short_test_timeout.dart';

/// A fonte íntima na tela de fontes: LIGADA por padrão, como as outras
/// quatro. O gate de Premium saiu — a Leitura do Ciclo é comprada à parte, e
/// o registro do ciclo é gratuito; barrar aqui cobrava duas vezes pela mesma
/// coisa. O que continua de pé é o consentimento do registro, sem o qual não
/// há prévia porque não há registro.
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

/// Um banco que devolve só os dias DA JANELA pedida — o `_Records` devolve
/// sempre os mesmos, e com a fonte reabrindo sozinha isso esconderia a troca
/// de período.
class _PorJanela extends MenstrualCycleRepository {
  _PorJanela(this.days);

  final List<MenstrualDay> days;

  @override
  Future<List<MenstrualDay>> between({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async =>
      [
        for (final day in days)
          if (!day.day.isBefore(from) && !day.day.isAfter(to)) day,
      ];
}

/// Um banco que só responde quando o teste mandar.
///
/// É o único jeito de observar a prévia ATRASADA — a que chega depois de ela
/// ter desligado a fonte — e provar que ela não religa nada.
class _Portao extends MenstrualCycleRepository {
  _Portao(this.days);

  final List<MenstrualDay> days;
  final _resposta = Completer<List<MenstrualDay>>();

  void responder() => _resposta.complete(days);

  @override
  Future<List<MenstrualDay>> between({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) =>
      _resposta.future;
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
    bool consented = true,
    MenstrualCycleRepository? repository,
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
            repository: repository ?? _Records(days),
            onChanged: emitted.add,
          ),
        ),
      ),
    ));
    await tester.pump();
    return emitted;
  }

  SwitchListTile chave(WidgetTester tester) => tester.widget<SwitchListTile>(
      find.byKey(const ValueKey('cycle-reading-menstrual')));

  Finder diaDe(String dayKey) =>
      find.byKey(ValueKey('cycle-reading-menstrual-$dayKey'));

  testWidgets('a fonte nasce ligada e já traz o período marcado',
      (tester) async {
    final emitted = await show(tester);
    await settle(tester, () => diaDe('2026-03-04').evaluate().isNotEmpty);

    expect(chave(tester).value, isTrue,
        reason: 'É a quinta fonte da tela, e as outras quatro nascem ligadas');
    expect(chave(tester).onChanged, isNotNull,
        reason: 'Nenhum plano fecha esta chave: a leitura é que se compra');
    expect(diaDe('2026-03-06'), findsOneWidget);
    expect(find.text('2 records included'), findsOneWidget);
    expect(emitted.last.recordCount, 2);
    expect(emitted.last.start, period.start);
    expect(emitted.last.end, period.end);
    expect(emitted.last.includesWrittenWords, isTrue);
  });

  testWidgets('daqui em diante ela DESmarca o que não quer mandar',
      (tester) async {
    final emitted = await show(tester);
    await settle(tester, () => diaDe('2026-03-04').evaluate().isNotEmpty);

    await tester.tap(diaDe('2026-03-04'));
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

  testWidgets('as palavras dela saem da leitura sem levar os dias junto',
      (tester) async {
    final emitted = await show(tester);
    await settle(
        tester,
        () => find
            .byKey(const ValueKey('cycle-reading-menstrual-all'))
            .evaluate()
            .isNotEmpty);
    expect(emitted.last.includesWrittenWords, isTrue);
    expect(emitted.last.fields, contains(MenstrualField.note));

    await tester.tap(
        find.byKey(const ValueKey('cycle-reading-menstrual-words')));
    await tester.pump();
    expect(emitted.last.includesWrittenWords, isFalse);
    expect(emitted.last.fields, isNot(contains(MenstrualField.note)));
    expect(emitted.last.recordCount, 2,
        reason: 'Tirar as palavras não tira os dias');

    // Desligar a fonte devolve um escopo vazio: nada fica autorizado.
    await tester.tap(find.byKey(const ValueKey('cycle-reading-menstrual')));
    await tester.pump();
    expect(emitted.last.isEmpty, isTrue);
    expect(emitted.last.includesWrittenWords, isFalse);
  });

  testWidgets('trocar a janela desfaz o que estava marcado e reabre na nova',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {'menstrual_consent_record_she': true});
    final emitted = <MenstrualReadingScope>[];
    Future<void> mostrar(({DateTime start, DateTime end}) janela) =>
        tester.pumpWidget(MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: MenstrualSourceTile(
                userId: 'she',
                period: janela,
                repository: _PorJanela(days),
                onChanged: emitted.add,
              ),
            ),
          ),
        ));

    await mostrar(period);
    await settle(tester, () => diaDe('2026-03-04').evaluate().isNotEmpty);
    expect(emitted.last.recordCount, 2);

    // Ela mexe no calendário da tela de compra: outro período, outra
    // pergunta. Os dias marcados eram os de março, e o escopo carrega as
    // próprias datas — mantê-los mandaria para a leitura os dias da janela
    // errada, sem que nada avisasse.
    await mostrar((start: DateTime(2026, 4, 1), end: DateTime(2026, 5, 1)));
    await settle(
        tester,
        () => find
            .byKey(const ValueKey('cycle-reading-menstrual-empty'))
            .evaluate()
            .isNotEmpty);

    expect(chave(tester).value, isTrue,
        reason: 'A chave é dela: trocar de mês não desliga a fonte');
    expect(diaDe('2026-03-04'), findsNothing,
        reason: 'Os dias de março não seguem autorizados em abril');
    expect(emitted.last.isEmpty, isTrue);
  });

  testWidgets('a fonte desligada continua desligada quando a janela muda',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {'menstrual_consent_record_she': true});
    final emitted = <MenstrualReadingScope>[];
    Future<void> mostrar(({DateTime start, DateTime end}) janela) =>
        tester.pumpWidget(MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: MenstrualSourceTile(
                userId: 'she',
                period: janela,
                repository: _PorJanela(days),
                onChanged: emitted.add,
              ),
            ),
          ),
        ));

    await mostrar(period);
    await settle(tester, () => diaDe('2026-03-04').evaluate().isNotEmpty);
    await tester.tap(find.byKey(const ValueKey('cycle-reading-menstrual')));
    await tester.pump();
    expect(chave(tester).value, isFalse);

    await mostrar((start: DateTime(2026, 4, 1), end: DateTime(2026, 5, 1)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(chave(tester).value, isFalse,
        reason: 'Trocar de mês não é pedir a fonte de volta');
    expect(emitted.last.isEmpty, isTrue);
  });

  testWidgets('desligar cancela a prévia que ainda vinha a caminho',
      (tester) async {
    final portao = _Portao(days);
    final emitted = await show(tester, repository: portao);
    await tester.pump();

    // A fonte nasceu ligada e está esperando o banco; ela desliga antes da
    // resposta.
    await tester.tap(find.byKey(const ValueKey('cycle-reading-menstrual')));
    await tester.pump();
    expect(emitted.last.isEmpty, isTrue);

    // O banco responde agora, para uma pergunta que já foi retirada.
    portao.responder();
    await tester.pump();
    await tester.pump();

    expect(chave(tester).value, isFalse,
        reason: 'A chave ficou desligada, e a tela não pode mentir sobre ela');
    expect(diaDe('2026-03-04'), findsNothing);
    expect(emitted.last.isEmpty, isTrue,
        reason: 'A prévia atrasada não autoriza o que ela já desligou');
  });

  testWidgets('sem consentimento de registro não há prévia', (tester) async {
    // A chave abre, porque plano nenhum a fecha — mas não há o que ler: sem
    // o sim do registro não existe registro.
    await show(tester, consented: false);
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
