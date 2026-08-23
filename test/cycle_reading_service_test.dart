import 'dart:io';

import 'package:flutter/material.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart'
    show lookupAppLocalizations;
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

    // …e o relatório contém as 11 seções de IA (previsão + as três áreas
    // da vida: amor, trabalho e família — decisão da dona, 23/08) + a seção
    // determinística "O ciclo em números" (montada por código) + os
    // compartilháveis.
    final markdown = result.writing.content;
    final headings = RegExp(r'^## ', multiLine: true).allMatches(markdown);
    expect(headings.length, 12);
    // A previsão fica entre a prática e os rituais: primeiro o que o céu
    // que vem anuncia, depois a prática que responde a ele.
    final previsao = markdown.indexOf('Texto da secao forecast.');
    expect(previsao, greaterThan(markdown.indexOf('Texto da secao practice.')));
    expect(previsao, lessThan(markdown.indexOf('Texto da secao rituals.')));
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

  test('a afirmação sai sem a marcação de realce', () async {
    // O prompt pede realce nos PARÁGRAFOS e o modelo marca a afirmação
    // junto. Ela vira imagem para compartilhar e legenda da imagem: ali
    // `**` não é realce, é sujeira na tela.
    final credit = await insertCredit();
    final marcada = CycleReadingService(
      generateSection: (key, json) async => key == 'affirmation'
          ? 'Eu **honro minhas conquistas** e sigo.'
          : key == 'seal'
              ? 'raiz, agua, coragem'
              : 'Texto da secao $key.',
    );
    final result = await marcada.generateForCredit(
      credit: credit,
      userId: userId,
    );

    expect(result.affirmation, 'Eu honro minhas conquistas e sigo.');
    expect(result.writing.content, contains('> Eu honro minhas conquistas'));
    expect(result.writing.content, isNot(contains('**honro')));
    // E ao reabrir do acervo, o mesmo: leituras antigas trazem o realce
    // dentro da citação e precisam sair limpas.
    expect(
      CycleReadingService.affirmationFromMarkdown(
        '> Eu **honro minhas conquistas** e sigo.',
      ),
      'Eu honro minhas conquistas e sigo.',
    );
  });

  test('palavra imediatamente duplicada colapsa na afirmação', () {
    // "me me permito" — gagueira de geração vista numa afirmação real
    // (23/08). Repetição imediata da MESMA palavra nunca é intencional.
    expect(
      CycleReadingService.semPalavraDuplicada(
        'Eu confio no meu saber, libero o controle e me me permito encantar.',
      ),
      'Eu confio no meu saber, libero o controle e me permito encantar.',
    );
    // Palavras DIFERENTES em sequência ficam como estão.
    expect(
      CycleReadingService.semPalavraDuplicada('dia a dia, passo a passo'),
      'dia a dia, passo a passo',
    );
    // Colapsa mesmo variando a caixa, preservando a primeira grafia.
    expect(
      CycleReadingService.semPalavraDuplicada('Que que floresça'),
      'Que floresça',
    );
  });

  test('reabrir do acervo recorta a afirmação da SEÇÃO dela, não o gancho',
      () {
    // A leitura ABRE com um gancho em citação; era ele que saía no cartão
    // de compartilhar enquanto a tela mostrava a afirmação certa (visto no
    // preview, 23/08). O título da seção é o do idioma da geração.
    final titulo = lookupAppLocalizations(const Locale('pt', 'BR'))
        .cycleReadingSectionAffirmation;
    final markdown = '''
# Leitura da Lunação

## 🕯️ Retrato do momento

> Da tempestade interna ao nascimento das suas criações.

Texto do retrato.

## $titulo

> Eu confio na minha criação.

## 🔮 Selo do ciclo

**raiz** · **agua**
''';
    expect(
      CycleReadingService.affirmationFromMarkdown(markdown),
      'Eu confio na minha criação.',
    );
  });

  test('reler a janela EXATA reescreve o registro em vez de criar outro',
      () async {
    final primeira = await service().generateForCredit(
      credit: await insertCredit(),
      userId: userId,
    );

    // Uma leitura NOVA das mesmas datas: herda o id e a entrada do acervo,
    // como faz a tela ao encontrar `findForExactPeriod`.
    final anterior = await CycleReadingRepository()
        .findForExactPeriod(userId, periodStart, periodEnd);
    expect(anterior, isNotNull);

    final segunda = CycleReadingModel(
      id: anterior!.id,
      writingId: anterior.writingId,
      userId: userId,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
    await CycleReadingRepository().insert(segunda);
    final refeita = await CycleReadingService(
      generateSection: (key, json) async => key == 'affirmation'
          ? 'Outra afirmação.'
          : key == 'seal'
              ? 'raiz, agua, coragem'
              : 'Texto NOVO da secao $key.',
    ).generateForCredit(credit: segunda, userId: userId);

    // Um registro só, e uma entrada só no acervo — com o conteúdo novo.
    final db = await DatabaseHelper.instance.database;
    expect((await db.query('cycle_readings')).length, 1);
    expect((await db.query('free_writings')).length, 1);
    expect(refeita.writing.id, primeira.writing.id);
    expect(refeita.writing.content, contains('Texto NOVO'));
    expect(refeita.reading.regenerationsUsed, 0);
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

  test('leitura da SEMANA sai com 8 seções, sem prática/rituais/selo',
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
    // A previsão ENTRA na semana (decisão da dona, 23/08: é pra isso que o
    // usuário paga); o que fica só na lunação é prática, rituais e selo.
    expect(asked, contains(CycleReadingSections.forecast));
    expect(asked, isNot(contains(CycleReadingSections.practice)));
    expect(asked, isNot(contains(CycleReadingSections.rituals)));
    expect(asked, isNot(contains(CycleReadingSections.seal)));

    final markdown = result.writing.content;
    // 8 seções de IA (previsão + amor/trabalho/família) + a seção
    // determinística dos números, que existe nas duas janelas (é calculada
    // pelo app, sem chamada de IA).
    expect(RegExp(r'^## ', multiLine: true).allMatches(markdown).length, 9);
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

  group('convite de volta (lembrete, não trava)', () {
    // Não existe mais espera entre leituras: o ritmo que sobrou é só o do
    // lembrete que convida a pessoa a voltar quando o ciclo se repete.
    test('uma semana para a semanal, uma lunação para a mensal', () {
      expect(
        CycleReadingService.inviteBackAfter(CycleReadingPeriodType.week),
        const Duration(days: 8),
      );
      expect(
        CycleReadingService.inviteBackAfter(CycleReadingPeriodType.lunation),
        const Duration(days: 30),
      );
    });
  });

  group('período escolhido a dedo vira semana ou lunação pelo tamanho', () {
    test('até 8 dias (o giro de segunda a segunda) é leitura da semana', () {
      expect(
        CycleReadingService.periodTypeForSpan(
            DateTime(2026, 8, 1), DateTime(2026, 8, 9)),
        CycleReadingPeriodType.week,
      );
      expect(
        CycleReadingService.periodTypeForSpan(
            DateTime(2026, 8, 1), DateTime(2026, 8, 4)),
        CycleReadingPeriodType.week,
      );
    });

    test('de 9 a 31 dias é leitura da lunação', () {
      expect(
        CycleReadingService.periodTypeForSpan(
            DateTime(2026, 8, 1), DateTime(2026, 8, 10)),
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

  group('período a dedo: recusa só o impossível, o resto é aviso', () {
    // Não há mais ritmo nenhum — nem espera, nem proibição de reler. O que
    // sobrevive são os limites do que a leitura CONSEGUE fazer, e um aviso
    // informativo quando a janela cruza um período já lido.
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

    test('cruzar um período já lido passa, mas volta como aviso', () async {
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
        now: hoje,
      );
      // Aceita — e entrega a leitura conflitante para a tela poder dizer
      // "este pedaço você já leu" sem fechar a porta.
      expect(v.reason, isNull);
      expect(v.conflict, isNotNull);
      expect(v.conflict!.periodStart, DateTime(2026, 5, 1));
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
        now: hoje,
      );
      expect(v.reason, isNull);
      expect(v.conflict, isNull);
    });

    test('leitura recente de outro pedaço não trava a janela nova', () async {
      // Comprou ontem, outro pedaço: antes isso travava por 7 dias quem
      // tinha o acesso incluído. Agora não trava ninguém.
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
        now: hoje,
      );
      expect(v.reason, isNull);
    });

    test('reler exatamente a mesma janela é aceito', () async {
      await geradaNoPeriodo(
        CycleReadingPeriodType.week,
        DateTime(2026, 5, 1),
        DateTime(2026, 5, 8),
        createdAt: hoje.subtract(const Duration(days: 1)),
      );
      // Mesma janela, leitura de ontem — e ainda assim aceita: quem quer
      // reler, relê.
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

  test('semana corrente é o giro completo: 8 dias, hoje incluído', () {
    // Decisão da dona (23/08): o ciclo semanal fecha no MESMO dia da semana
    // em que começou (segunda a segunda) — 8 dias vividos, não 7.
    final now = DateTime(2026, 8, 19, 15);
    final week = CycleReadingService.currentWeek(now: now);
    expect(week.start, DateTime(2026, 8, 12));
    expect(week.end, DateTime(2026, 8, 20));
    expect(week.end.difference(week.start).inDays, 8);
    // Mesmo dia da semana nas duas pontas vividas (12 e 19: quartas).
    expect(week.start.weekday, DateTime(2026, 8, 19).weekday);
  });

  test('as telas estampam o último dia VIVIDO, nunca o fim exclusivo', () {
    // O `end` guardado é a meia-noite do dia seguinte ao último lido;
    // estampá-lo cru dizia que a leitura cobre um dia que não cobre.
    expect(
      CycleReadingService.lastDayOf(DateTime(2026, 8, 30)),
      DateTime(2026, 8, 29),
    );
    // Fim fora da meia-noite: o próprio dia já foi vivido em parte.
    expect(
      CycleReadingService.lastDayOf(DateTime(2026, 8, 30, 12)),
      DateTime(2026, 8, 30),
    );
    expect(
      CycleReadingService.reportTitle(
        DateTime(2026, 8, 1),
        DateTime(2026, 8, 30),
      ),
      contains('01/08–29/08'),
    );
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

    test('com ele desligado, o teto de regerações é o de produção', () {
      final noTeto = CycleReadingModel(
        userId: 'u',
        periodType: CycleReadingPeriodType.week,
        periodStart: DateTime(2026, 8, 1),
        periodEnd: DateTime(2026, 8, 8),
        status: CycleReadingStatus.generated,
        regenerationsUsed: CycleReadingModel.maxRegenerations,
      );
      expect(noTeto.canRegenerate, isFalse);
    });
  });
}

