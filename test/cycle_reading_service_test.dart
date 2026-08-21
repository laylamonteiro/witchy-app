import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/data/models/cycle_reading_model.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/data/repositories/cycle_reading_repository.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/data/services/cycle_reading_composer.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/data/services/cycle_reading_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:grimorio_de_bolso/core/config/test_build_config.dart';

/// O ciclo de vida do crédito da Leitura do Ciclo: a compra SÓ é consumida
/// quando o relatório foi gerado e salvo; falha mantém o crédito; a
/// regeneração da mesma janela é limitada a 2×.
void main() {
  _guardaDoAfrouxamento();
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

  test('retomada: a segunda tentativa não refaz as seções já prontas',
      () async {
    final credit = await insertCredit();

    // Primeira tentativa: quebra na 3ª seção (sky). As duas anteriores
    // ficam guardadas no rascunho.
    final chamadas = <String>[];
    final quebra = CycleReadingService(
      generateSection: (key, json) async {
        chamadas.add(key);
        if (key == 'sky') throw Exception('429');
        return 'trecho de $key';
      },
    );
    await expectLater(
      quebra.generateForCredit(credit: credit, userId: userId),
      throwsA(isA<Exception>()),
    );
    expect(chamadas, ['portrait', 'threads', 'sky']);

    // Segunda tentativa: retoma do 'sky' — retrato e fios NÃO voltam à IA.
    final segundas = <String>[];
    await CycleReadingService(
      generateSection: (key, json) async {
        segundas.add(key);
        return key == 'seal' ? 'raiz, agua, coragem' : 'trecho de $key';
      },
    ).generateForCredit(credit: credit, userId: userId);

    expect(
      segundas,
      isNot(contains('portrait')),
      reason: 'seção já pronta foi refeita — o rascunho não serviu de nada',
    );
    expect(segundas, isNot(contains('threads')));
    expect(segundas.first, 'sky', reason: 'retoma exatamente onde parou');
  });

  test('material mudou: o rascunho é descartado, não misturado', () async {
    final credit = await insertCredit();
    // Um sonho DENTRO do período: sem ele, desligar os sonhos não mudaria
    // material nenhum, a impressão digital seria a mesma e o rascunho
    // seria reusado — corretamente. O teste só prova algo com a fonte
    // presente.
    final db = await DatabaseHelper.instance.database;
    await db.insert('dreams', {
      'id': 'sonho-1',
      'user_id': userId,
      'title': 'a casa antiga',
      'content': 'voltei ao quintal da infancia',
      'date': periodStart.millisecondsSinceEpoch,
      'created_at': periodStart.millisecondsSinceEpoch,
      'updated_at': periodStart.millisecondsSinceEpoch,
      'synced': 0,
    });

    final quebra = CycleReadingService(
      generateSection: (key, json) async =>
          key == 'sky' ? throw Exception('429') : 'trecho de $key',
    );
    await expectLater(
      quebra.generateForCredit(credit: credit, userId: userId),
      throwsA(isA<Exception>()),
    );

    // Ela desliga os sonhos na privacidade: o material deixa de ser o mesmo,
    // e reusar seções escritas com o material antigo citaria o que ela
    // acabou de excluir.
    final segundas = <String>[];
    await CycleReadingService(
      generateSection: (key, json) async {
        segundas.add(key);
        return key == 'seal' ? 'raiz, agua, coragem' : 'trecho de $key';
      },
    ).generateForCredit(
      credit: credit,
      userId: userId,
      options: const CycleReadingSourceOptions(includeDreams: false),
    );

    expect(
      segundas,
      contains('portrait'),
      reason: 'material diferente exige reescrever tudo',
    );
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

  group('intervalo entre leituras (uma semanal por semana, mensal por mês)',
      () {
    Future<void> gerada(String periodType, DateTime createdAt) async {
      final repo = CycleReadingRepository();
      await repo.insert(CycleReadingModel(
        userId: userId,
        periodType: periodType,
        periodStart: periodStart,
        periodEnd: periodEnd,
        status: CycleReadingStatus.generated,
        createdAt: createdAt,
      ));
    }

    test('sem leitura anterior, está liberada', () async {
      final next = await CycleReadingService()
          .nextAllowedAt(userId, CycleReadingPeriodType.week);
      expect(next, isNull);
    });

    test('semanal feita ontem ainda está travada', () async {
      // Truncado ao milissegundo: é essa a precisão que sobrevive à ida e
      // volta pelo SQLite (created_at é INTEGER em millis), e sem isso a
      // comparação falharia por microssegundos.
      final ontem = DateTime.fromMillisecondsSinceEpoch(
        DateTime.now()
            .subtract(const Duration(days: 1))
            .millisecondsSinceEpoch,
      );
      await gerada(CycleReadingPeriodType.week, ontem);

      final next = await CycleReadingService()
          .nextAllowedAt(userId, CycleReadingPeriodType.week);
      expect(next, isNotNull);
      expect(next, ontem.add(const Duration(days: 7)));
    });

    test('semanal feita há 8 dias liberou', () async {
      await gerada(CycleReadingPeriodType.week,
          DateTime.now().subtract(const Duration(days: 8)));

      final next = await CycleReadingService()
          .nextAllowedAt(userId, CycleReadingPeriodType.week);
      expect(next, isNull);
    });

    test('o intervalo é por tipo: a semanal não trava a lunação', () async {
      await gerada(CycleReadingPeriodType.week, DateTime.now());

      expect(
        await CycleReadingService()
            .nextAllowedAt(userId, CycleReadingPeriodType.lunation),
        isNull,
      );
      expect(
        await CycleReadingService()
            .nextAllowedAt(userId, CycleReadingPeriodType.week),
        isNotNull,
      );
    });

    test('crédito pendente não conta como leitura feita', () async {
      final repo = CycleReadingRepository();
      await repo.insert(CycleReadingModel(
        userId: userId,
        periodType: CycleReadingPeriodType.week,
        periodStart: periodStart,
        periodEnd: periodEnd,
        // pending: comprou e ainda não gerou — não pode travar a próxima.
        createdAt: DateTime.now(),
      ));

      expect(
        await CycleReadingService()
            .nextAllowedAt(userId, CycleReadingPeriodType.week),
        isNull,
      );
    });

    test('lunação usa 30 dias, semana usa 7', () {
      expect(
        CycleReadingService.cooldownFor(CycleReadingPeriodType.week),
        const Duration(days: 7),
      );
      expect(
        CycleReadingService.cooldownFor(CycleReadingPeriodType.lunation),
        const Duration(days: 30),
      );
    });
  });

  group('período escolhido a dedo vira semana ou lunação pelo tamanho', () {
    test('até 7 dias é leitura da semana', () {
      expect(
        CycleReadingService.periodTypeForSpan(
            DateTime(2026, 8, 1), DateTime(2026, 8, 8)),
        CycleReadingPeriodType.week,
      );
      expect(
        CycleReadingService.periodTypeForSpan(
            DateTime(2026, 8, 1), DateTime(2026, 8, 4)),
        CycleReadingPeriodType.week,
      );
    });

    test('de 8 a 31 dias é leitura da lunação', () {
      expect(
        CycleReadingService.periodTypeForSpan(
            DateTime(2026, 8, 1), DateTime(2026, 8, 9)),
        CycleReadingPeriodType.lunation,
      );
      expect(
        CycleReadingService.periodTypeForSpan(
            DateTime(2026, 8, 1), DateTime(2026, 9, 1)),
        CycleReadingPeriodType.lunation,
      );
    });

    test('o teto é 31 dias (há meses de 31)', () {
      expect(CycleReadingService.maxCustomPeriodDays, 31);
      expect(
        CycleReadingService.spanInDays(
            DateTime(2026, 8, 1), DateTime(2026, 9, 1)),
        31,
      );
    });
  });

  group('período a dedo: ritmo só para o acesso incluído', () {
    // Sobreposição e cooldown são o RITMO do Vitalício (onde a leitura não
    // custa por unidade). Quem paga por leitura escolhe qualquer janela,
    // quantas vezes quiser — os dois últimos testes do grupo provam isso.
    final hoje = DateTime(2026, 8, 20);

    Future<void> geradaNoPeriodo(
      String periodType,
      DateTime inicio,
      DateTime fim, {
      DateTime? createdAt,
    }) async {
      await CycleReadingRepository().insert(CycleReadingModel(
        userId: userId,
        periodType: periodType,
        periodStart: inicio,
        periodEnd: fim,
        status: CycleReadingStatus.generated,
        createdAt: createdAt ?? DateTime(2026, 1, 1),
      ));
    }

    test('um pedaço retroativo nunca lido é aceito', () async {
      final v = await CycleReadingService().validateCustomPeriod(
        userId: userId,
        start: DateTime(2026, 5, 1),
        end: DateTime(2026, 5, 8),
        now: hoje,
      );
      expect(v.reason, isNull);
      expect(v.periodType, CycleReadingPeriodType.week);
    });

    test('cruzar um período já lido é recusado, mesmo sem cooldown',
        () async {
      // createdAt bem antigo: o cooldown já venceu há muito. O que barra
      // aqui é a sobreposição, e é isso que o teste prova.
      await geradaNoPeriodo(
        CycleReadingPeriodType.week,
        DateTime(2026, 5, 1),
        DateTime(2026, 5, 8),
        createdAt: DateTime(2026, 5, 8),
      );
      final v = await CycleReadingService().validateCustomPeriod(
        userId: userId,
        start: DateTime(2026, 5, 5),
        end: DateTime(2026, 5, 12),
        includedByLifetime: true,
        now: hoje,
      );
      expect(v.reason, CycleReadingService.rejectionOverlaps);
      expect(v.conflict, isNotNull);
    });

    test('encostar não é cruzar: começar onde a outra terminou passa',
        () async {
      await geradaNoPeriodo(
        CycleReadingPeriodType.week,
        DateTime(2026, 5, 1),
        DateTime(2026, 5, 8),
        createdAt: DateTime(2026, 5, 8),
      );
      final v = await CycleReadingService().validateCustomPeriod(
        userId: userId,
        start: DateTime(2026, 5, 8),
        end: DateTime(2026, 5, 15),
        includedByLifetime: true,
        now: hoje,
      );
      expect(v.reason, isNull);
    });

    test('período novo ainda respeita o cooldown da compra recente',
        () async {
      // Leitura de OUTRO pedaço, feita ontem: sem sobreposição, mas a
      // trava de intervalo entre compras continua valendo.
      await geradaNoPeriodo(
        CycleReadingPeriodType.week,
        DateTime(2026, 3, 1),
        DateTime(2026, 3, 8),
        createdAt: hoje.subtract(const Duration(days: 1)),
      );
      final v = await CycleReadingService().validateCustomPeriod(
        userId: userId,
        start: DateTime(2026, 6, 1),
        end: DateTime(2026, 6, 8),
        includedByLifetime: true,
        now: hoje,
      );
      expect(v.reason, CycleReadingService.rejectionCooldown);
      expect(v.releaseAt, isNotNull);
    });

    test('quem paga por leitura pode reler um período já lido', () async {
      await geradaNoPeriodo(
        CycleReadingPeriodType.week,
        DateTime(2026, 5, 1),
        DateTime(2026, 5, 8),
        createdAt: hoje.subtract(const Duration(days: 1)),
      );
      // Mesma janela, cooldown fresquíssimo — e ainda assim aceita: sem o
      // acesso incluído, cada leitura é uma compra.
      final v = await CycleReadingService().validateCustomPeriod(
        userId: userId,
        start: DateTime(2026, 5, 1),
        end: DateTime(2026, 5, 8),
        now: hoje,
      );
      expect(v.reason, isNull);
    });

    test('os limites estruturais valem para todo mundo', () async {
      // Sem acesso incluído, mas 40 dias continua sendo grande demais e o
      // futuro continua não vivido — isso não é ritmo, é o que a leitura
      // consegue fazer.
      final longo = await CycleReadingService().validateCustomPeriod(
        userId: userId,
        start: DateTime(2026, 4, 1),
        end: DateTime(2026, 5, 10),
        now: hoje,
      );
      expect(longo.reason, CycleReadingService.rejectionTooLong);

      final futuro = await CycleReadingService().validateCustomPeriod(
        userId: userId,
        start: hoje,
        end: hoje.add(const Duration(days: 5)),
        now: hoje,
      );
      expect(futuro.reason, CycleReadingService.rejectionFuture);
    });

    test('a janela que termina amanhã 00h (cobre hoje) é aceita', () async {
      final v = await CycleReadingService().validateCustomPeriod(
        userId: userId,
        start: hoje.subtract(const Duration(days: 6)),
        end: hoje.add(const Duration(days: 1)),
        now: hoje,
      );
      expect(v.reason, isNull);
    });
  });

  test('semana corrente cobre 7 dias e inclui hoje', () {
    final now = DateTime(2026, 8, 19, 15);
    final week = CycleReadingService.currentWeek(now: now);
    expect(week.start, DateTime(2026, 8, 13));
    expect(week.end, DateTime(2026, 8, 20));
    expect(week.end.difference(week.start).inDays, 7);
  });

  group('o Vitalício cobre as duas janelas', () {
    // Decisão de produto (reafirmada pela dona): semana E lunação entram no
    // Vitalício. O custo é conhecido e aceito — no limite, ~208 gerações de
    // IA por ano por pessoa vitalícia. Se um dia voltar a ser só a lunação,
    // é aqui e em lifetimeCovers que se reverte.
    test('a lunação entra na compra vitalícia', () {
      expect(
        CycleReadingService.lifetimeCovers(CycleReadingPeriodType.lunation),
        isTrue,
      );
    });

    test('a semana também entra na compra vitalícia', () {
      expect(
        CycleReadingService.lifetimeCovers(CycleReadingPeriodType.week),
        isTrue,
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

/// O afrouxamento de build de teste NÃO pode vazar para produção.
///
/// `flutter test` não passa `--dart-define`, então aqui a flag tem de estar
/// desligada — e é assim que uma build de release sem o define também fica.
/// Se alguém trocar a constante por algo ligado por padrão, este teste cai.
void _guardaDoAfrouxamento() {
  group('Afrouxamento de teste', () {
    test('vem DESLIGADO quando o define não é passado', () {
      expect(TestBuildConfig.unlimitedCycleReadings, isFalse);
    });

    test('com ele desligado, o intervalo entre leituras é o de produção', () {
      expect(CycleReadingService.cooldownFor(CycleReadingPeriodType.week),
          const Duration(days: 7));
      expect(CycleReadingService.cooldownFor(CycleReadingPeriodType.lunation),
          const Duration(days: 30));
    });
  });
}

