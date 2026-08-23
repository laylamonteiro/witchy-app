import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/data/models/cycle_reading_model.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/data/repositories/cycle_reading_repository.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/data/services/cycle_reading_composer.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/data/services/cycle_reading_service.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/models/spell_model.dart'
    show MoonPhase;
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Os números do ciclo são a parte que o APP calcula (a IA continua só
/// narrando): contagens determinísticas que viram a seção "O ciclo em
/// números" do relatório e o bloco "numbers" do material. Aqui se prova que
/// a conta está certa, que empates não flutuam entre gerações e que a seção
/// entra no relatório como as outras — sem nunca passar pela IA.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final start = DateTime(2026, 8, 1);
  final end = DateTime(2026, 8, 30);

  /// Material sintético: só o que o cálculo precisa, sem banco nem IA.
  NumerosDoCiclo calcular({
    Map<String, int> countsByDay = const {},
    Map<String, MoonPhase> phaseByDay = const {},
    Map<String, int> countsBySource = const {},
    int previous = 0,
  }) =>
      NumerosDoCiclo.calcular(
        start: start,
        end: end,
        countsByDay: countsByDay,
        phaseByDay: phaseByDay,
        countsBySource: countsBySource,
        previousPeriodRecords: previous,
      );

  group('total e dias ativos', () {
    test('somam os registros por dia e contam cada dia uma vez', () {
      final numeros = calcular(
        countsByDay: {'2026-08-03': 2, '2026-08-10': 1, '2026-08-20': 3},
      );
      expect(numeros.totalRecords, 6);
      expect(numeros.activeDays, 3);
      // A janela 01/08 00h → 30/08 00h (fim exclusivo) tem 29 dias vividos.
      expect(numeros.periodDays, 29);
    });

    test('um fim fora da meia-noite conta o dia já começado', () {
      final numeros = NumerosDoCiclo.calcular(
        start: DateTime(2026, 8, 1),
        end: DateTime(2026, 8, 30, 12),
        countsByDay: const {},
        phaseByDay: const {},
        countsBySource: const {},
        previousPeriodRecords: 0,
      );
      expect(numeros.periodDays, 30);
    });

    test('período vazio: sem fase top, sem fonte top, sem sequência', () {
      final numeros = calcular();
      expect(numeros.totalRecords, 0);
      expect(numeros.activeDays, 0);
      expect(numeros.topPhase, isNull);
      expect(numeros.topSource, isNull);
      expect(numeros.longestStreak, 0);
    });
  });

  group('fase da lua com mais registros', () {
    test('soma os registros de cada dia na fase daquele dia', () {
      final numeros = calcular(
        countsByDay: {'2026-08-03': 1, '2026-08-04': 2, '2026-08-20': 1},
        phaseByDay: {
          '2026-08-03': MoonPhase.fullMoon,
          '2026-08-04': MoonPhase.fullMoon,
          '2026-08-20': MoonPhase.newMoon,
        },
      );
      expect(numeros.topPhase, MoonPhase.fullMoon);
      expect(numeros.topPhaseCount, 3);
    });

    test('empate é resolvido pela ordem do enum — sempre a mesma campeã', () {
      // 2 registros na lua nova (em dois dias) e 2 na cheia (num dia só):
      // empate. A campeã tem de ser a MESMA em toda geração do mesmo
      // material — vence a primeira na ordem do enum (a nova vem antes).
      final numeros = calcular(
        countsByDay: {'2026-08-03': 1, '2026-08-04': 1, '2026-08-20': 2},
        phaseByDay: {
          '2026-08-03': MoonPhase.newMoon,
          '2026-08-04': MoonPhase.newMoon,
          '2026-08-20': MoonPhase.fullMoon,
        },
      );
      expect(numeros.topPhase, MoonPhase.newMoon);
      expect(numeros.topPhaseCount, 2);
    });
  });

  group('fonte mais presente', () {
    test('vence a de maior contagem', () {
      final numeros = calcular(
        countsBySource: {
          NumerosDoCiclo.sourceDreams: 1,
          NumerosDoCiclo.sourceDivination: 4,
          NumerosDoCiclo.sourcePractice: 2,
        },
      );
      expect(numeros.topSource, NumerosDoCiclo.sourceDivination);
      expect(numeros.topSourceCount, 4);
    });

    test('empate fica com a primeira da ordem canônica', () {
      // Sonhos e prática empatados em 2: vence a que vem primeiro na ordem
      // canônica (a mesma dos desligamentos de privacidade da intro).
      final numeros = calcular(
        countsBySource: {
          NumerosDoCiclo.sourceDreams: 2,
          NumerosDoCiclo.sourcePractice: 2,
        },
      );
      expect(numeros.topSource, NumerosDoCiclo.sourceDreams);
    });
  });

  group('maior sequência de dias seguidos', () {
    test('sem registros é zero', () {
      expect(calcular().longestStreak, 0);
    });

    test('um dia só vale 1', () {
      expect(
        calcular(countsByDay: {'2026-08-10': 3}).longestStreak,
        1,
      );
    });

    test('a sequência no FIM do período também é contada', () {
      // O laço não pode fechar a conta antes do último dia: a maior
      // sequência aqui é a que termina no fim da janela (27→29).
      final numeros = calcular(countsByDay: {
        '2026-08-02': 1,
        '2026-08-03': 1,
        '2026-08-10': 1,
        '2026-08-27': 1,
        '2026-08-28': 2,
        '2026-08-29': 1,
      });
      expect(numeros.longestStreak, 3);
    });

    test('dias fora de ordem no mapa não confundem a conta', () {
      // O mapa não garante ordem de chaves; a conta ordena antes de medir.
      final numeros = calcular(countsByDay: {
        '2026-08-20': 1,
        '2026-08-05': 1,
        '2026-08-19': 1,
        '2026-08-21': 1,
      });
      expect(numeros.longestStreak, 3);
    });
  });

  group('a seção montada por código', () {
    // O idioma dos textos esperados: o mesmo fallback (pt-BR) que o service
    // usa fora da árvore de widgets.
    final l10n = lookupAppLocalizations(const Locale('pt', 'BR'));

    test('traz cada número na sua linha, nas chaves l10n', () {
      final body = CycleReadingService.numbersSectionBody(calcular(
        countsByDay: {'2026-08-03': 1, '2026-08-04': 1},
        phaseByDay: {
          '2026-08-03': MoonPhase.fullMoon,
          '2026-08-04': MoonPhase.fullMoon,
        },
        countsBySource: {NumerosDoCiclo.sourceDreams: 2},
        previous: 5,
      ));

      expect(body, contains(l10n.cycleNumbersRecords(2, 2, 29)));
      expect(body, contains(l10n.cycleNumbersStreak(2)));
      expect(body, contains(l10n.cycleNumbersPrevious(5)));
      // A fonte é nomeada com a MESMA chave do desligamento da intro.
      expect(
        body,
        contains(l10n.cycleNumbersTopSource(l10n.cycleSourceDreams, 2)),
      );
    });

    test('linhas sem dado não entram (período vazio)', () {
      final body = CycleReadingService.numbersSectionBody(calcular());
      // Sobram só o total (zero é informação) e o período anterior.
      expect(body.split('\n'), hasLength(2));
      expect(body, contains(l10n.cycleNumbersRecords(0, 0, 29)));
      expect(body, contains(l10n.cycleNumbersPrevious(0)));
    });
  });

  group('a seção no relatório de verdade', () {
    const userId = 'user-1';

    setUpAll(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      // Base exclusiva DESTE arquivo: a suíte roda os arquivos de teste em
      // paralelo e o banco padrão compartilhado colide entre isolates.
      await databaseFactory.setDatabasesPath(
        Directory.systemTemp.createTempSync('numeros_do_ciclo_test').path,
      );
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final db = await DatabaseHelper.instance.database;
      await db.delete('cycle_readings');
      await db.delete('free_writings');
      await db.delete('dreams');
    });

    test('entra logo após o retrato, com cabeçalho ## como as demais — '
        'e nunca é pedida à IA', () async {
      final inPeriod = DateTime(2026, 8, 10).millisecondsSinceEpoch;
      final db = await DatabaseHelper.instance.database;
      await db.insert('dreams', {
        'id': 'sonho-1',
        'user_id': userId,
        'title': 'Sonho',
        'content': 'sonhei com o mar',
        'date': inPeriod,
        'created_at': inPeriod,
        'updated_at': inPeriod,
        'synced': 0,
      });

      final credit = CycleReadingModel(
        userId: userId,
        periodStart: start,
        periodEnd: end,
      );
      await CycleReadingRepository().insert(credit);

      final pedidas = <String>[];
      final result = await CycleReadingService(
        generateSection: (key, json) async {
          pedidas.add(key);
          return key == 'affirmation'
              ? '"Eu confio no meu ciclo."'
              : key == 'seal'
                  ? 'raiz, agua, coragem'
                  : 'Texto da secao $key.';
        },
      ).generateForCredit(credit: credit, userId: userId);

      // A regra inteira desta feature: os números NUNCA viram chamada de IA.
      expect(pedidas, isNot(contains(CycleReadingSections.numbers)));

      final markdown = result.writing.content;
      final l10n = lookupAppLocalizations(const Locale('pt', 'BR'));
      final cabecalho = '## ${l10n.cycleReadingSectionNumbers}';
      expect(markdown, contains(cabecalho));
      // Logo após a primeira seção (o retrato), antes dos fios.
      final retrato = markdown.indexOf('## ${l10n.cycleReadingSectionPortrait}');
      final numeros = markdown.indexOf(cabecalho);
      final fios = markdown.indexOf('## ${l10n.cycleReadingSectionThreads}');
      expect(retrato, isNot(-1));
      expect(fios, isNot(-1));
      expect(numeros, greaterThan(retrato));
      expect(numeros, lessThan(fios));
      // E as linhas calculadas: 1 registro em 1 de 29 dias, sem anterior.
      expect(markdown, contains(l10n.cycleNumbersRecords(1, 1, 29)));
      expect(markdown, contains(l10n.cycleNumbersStreak(1)));
      expect(markdown, contains(l10n.cycleNumbersPrevious(0)));
    });
  });
}
