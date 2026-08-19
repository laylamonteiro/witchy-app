import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/data/models/cycle_reading_model.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/data/repositories/cycle_reading_repository.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/data/services/cycle_reading_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// O ciclo de vida do crédito da Leitura do Ciclo: a compra SÓ é consumida
/// quando o relatório foi gerado e salvo; falha mantém o crédito; a
/// regeneração da mesma janela é limitada a 2×.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const userId = 'user-1';
  final periodStart = DateTime(2026, 8, 1);
  final periodEnd = DateTime(2026, 8, 30);

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // Base exclusiva DESTE arquivo: a suíte roda os arquivos de teste em
    // paralelo e o banco padrão compartilhado colide entre isolates
    // ("database is locked").
    await databaseFactory.setDatabasesPath(
      Directory.systemTemp.createTempSync('cycle_reading_service_test').path,
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    await db.delete('cycle_readings');
    await db.delete('free_writings');
  });

  Future<String> fakeSection(String key, String json) async =>
      key == 'affirmation'
          ? '"Eu confio no meu ciclo."'
          : key == 'seal'
              ? 'raiz, agua, coragem'
              : 'Texto da secao $key.';

  CycleReadingService service() =>
      CycleReadingService(generateSection: fakeSection);

  Future<CycleReadingModel> insertCredit() async {
    final credit = CycleReadingModel(
      userId: userId,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
    await CycleReadingRepository().insert(credit);
    return credit;
  }

  test('gerar consome o crédito e salva o relatório no acervo', () async {
    final credit = await insertCredit();
    final result = await service().generateForCredit(
      credit: credit,
      userId: userId,
    );

    expect(result.reading.isGenerated, isTrue);
    expect(result.reading.writingId, result.writing.id);
    expect(result.writing.source, 'cycle_reading');
    expect(result.affirmation, 'Eu confio no meu ciclo.');
    expect(result.sealKeywords, ['raiz', 'agua', 'coragem']);

    // Persistido: o crédito desta janela está consumido…
    final stored =
        await CycleReadingRepository().findForPeriod(userId, periodStart);
    expect(stored!.isGenerated, isTrue);

    // …e o relatório contém as 7 seções na ordem + os compartilháveis.
    final markdown = result.writing.content;
    final headings = RegExp(r'^## ', multiLine: true).allMatches(markdown);
    expect(headings.length, 7);
    expect(markdown, contains('> Eu confio no meu ciclo.'));
    expect(markdown, contains('**raiz**'));
    expect(
      CycleReadingService.affirmationFromMarkdown(markdown),
      'Eu confio no meu ciclo.',
    );
    expect(
      CycleReadingService.sealFromMarkdown(markdown),
      ['raiz', 'agua', 'coragem'],
    );
  });

  test('falha na geração NÃO consome o crédito nem salva relatório',
      () async {
    final credit = await insertCredit();
    final failing = CycleReadingService(
      generateSection: (key, json) async =>
          key == 'sky' ? throw Exception('429') : 'ok',
    );

    await expectLater(
      failing.generateForCredit(credit: credit, userId: userId),
      throwsA(isA<Exception>()),
    );

    final stored =
        await CycleReadingRepository().findForPeriod(userId, periodStart);
    expect(stored!.isPending, isTrue, reason: 'crédito preservado');
    final db = await DatabaseHelper.instance.database;
    expect(await db.query('free_writings'), isEmpty);
  });

  test('regeneração substitui o mesmo relatório e respeita o teto de 2×',
      () async {
    final credit = await insertCredit();
    var generated = (await service().generateForCredit(
      credit: credit,
      userId: userId,
    ))
        .reading;

    // 1ª e 2ª regenerações: mesmo id de relatório, contador avança.
    for (var expected = 1; expected <= 2; expected++) {
      final result = await service().generateForCredit(
        credit: generated,
        userId: userId,
        regenerate: true,
      );
      expect(result.reading.regenerationsUsed, expected);
      expect(result.writing.id, generated.writingId);
      generated = result.reading;
    }

    // 3ª: bloqueada.
    expect(generated.canRegenerate, isFalse);
    await expectLater(
      service().generateForCredit(
        credit: generated,
        userId: userId,
        regenerate: true,
      ),
      throwsA(isA<StateError>()),
    );

    // O acervo tem UMA entrada só (regeneração nunca duplica).
    final db = await DatabaseHelper.instance.database;
    expect((await db.query('free_writings')).length, 1);
  });

  test('leitura da SEMANA sai com 4 seções, sem prática/rituais/selo',
      () async {
    final week = CycleReadingService.currentWeek();
    final credit = CycleReadingModel(
      userId: userId,
      periodType: CycleReadingPeriodType.week,
      periodStart: week.start,
      periodEnd: week.end,
      productId: 'leitura_ciclo_semana',
    );
    await CycleReadingRepository().insert(credit);

    final asked = <String>[];
    final service = CycleReadingService(
      generateSection: (key, json) async {
        asked.add(key);
        return fakeSection(key, json);
      },
    );
    final result =
        await service.generateForCredit(credit: credit, userId: userId);

    expect(asked, CycleReadingSections.weekly);
    expect(asked, isNot(contains(CycleReadingSections.practice)));
    expect(asked, isNot(contains(CycleReadingSections.rituals)));
    expect(asked, isNot(contains(CycleReadingSections.seal)));

    final markdown = result.writing.content;
    expect(RegExp(r'^## ', multiLine: true).allMatches(markdown).length, 4);
    // A afirmação (o cartão compartilhável) continua nas duas janelas.
    expect(result.affirmation, 'Eu confio no meu ciclo.');
    expect(result.sealKeywords, isEmpty);
    expect(result.reading.isWeekly, isTrue);
  });

  test('semana e lunação são créditos distintos da mesma pessoa', () async {
    final week = CycleReadingService.currentWeek();
    await CycleReadingRepository().insert(CycleReadingModel(
      userId: userId,
      periodType: CycleReadingPeriodType.week,
      periodStart: week.start,
      periodEnd: week.end,
    ));

    final repo = CycleReadingRepository();
    expect(
      await repo.findForPeriod(userId, week.start,
          periodType: CycleReadingPeriodType.week),
      isNotNull,
    );
    // Comprar a semana não entrega a lunação (nem o contrário).
    expect(
      await repo.findForPeriod(userId, week.start,
          periodType: CycleReadingPeriodType.lunation),
      isNull,
    );
  });

  test('semana corrente cobre 7 dias e inclui hoje', () {
    final now = DateTime(2026, 8, 19, 15);
    final week = CycleReadingService.currentWeek(now: now);
    expect(week.start, DateTime(2026, 8, 13));
    expect(week.end, DateTime(2026, 8, 20));
    expect(week.end.difference(week.start).inDays, 7);
  });

  group('o Vitalício cobre a lunação, e só ela', () {
    test('a lunação entra na compra vitalícia', () {
      expect(
        CycleReadingService.lifetimeCovers(CycleReadingPeriodType.lunation),
        isTrue,
      );
    });

    test('a semana continua avulsa mesmo para quem tem o Vitalício', () {
      // Se isto virar true sem decisão de produto, o Vitalício passa a
      // custear 208 chamadas de IA por ano por pessoa, para sempre.
      expect(
        CycleReadingService.lifetimeCovers(CycleReadingPeriodType.week),
        isFalse,
      );
    });

    test('o crédito do Vitalício nasce sem produto e com origem própria',
        () async {
      final repo = CycleReadingRepository();
      final period = CycleReadingService.currentLunation();
      final credit = CycleReadingModel(
        userId: userId,
        periodType: CycleReadingPeriodType.lunation,
        periodStart: period.start,
        periodEnd: period.end,
        origin: CycleReadingOrigin.lifetime,
      );
      await repo.insert(credit);

      final saved = await repo.findForPeriod(userId, period.start,
          periodType: CycleReadingPeriodType.lunation);
      expect(saved, isNotNull);
      expect(saved!.origin, CycleReadingOrigin.lifetime);
      expect(saved.productId, isNull);
      // Nasce pendente como qualquer crédito: só vira 'gerada' quando o
      // relatório foi salvo.
      expect(saved.isPending, isTrue);
    });
  });

  test('lunação corrente cobre a data de agora', () {
    final period = CycleReadingService.currentLunation();
    final now = DateTime.now();
    expect(period.start.isBefore(now), isTrue);
    expect(period.end.isAfter(now), isTrue);
    // Uma lunação dura ~29,5 dias.
    final days = period.end.difference(period.start).inDays;
    expect(days, inInclusiveRange(29, 30));
  });
}
