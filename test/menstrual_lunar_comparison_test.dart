import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/models/spell_model.dart';
import 'package:grimorio_de_bolso/features/lunar/presentation/providers/lunar_provider.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/lunar_comparison.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_day.dart';

/// A comparação com a Lua: proximidade medida pela mesma conta do calendário
/// lunar, numa janela simétrica de dois dias, sobre os começos que ela
/// marcou — e as emoções que ela escreveu nos dias de sangue.
///
/// As datas de fase foram escolhidas com folga: nenhuma fica a menos de um
/// dia da borda de fase mais próxima, então o fuso da máquina que roda o
/// teste (que desloca o meio-dia em até meio dia) não muda o veredito. As da
/// borda da JANELA são as que sobram: Nova e Cheia caindo perto da meia-noite
/// UTC, para que dois dias antes e dois depois fiquem a meio dia da borda dos
/// dois lados.
void main() {
  MenstrualDay start(DateTime day, {String? mood}) => MenstrualDay(
      userId: 'she', day: day, mark: MenstrualMark.start, mood: mood);

  MenstrualDay flow(DateTime day, {String? mood}) => MenstrualDay(
      userId: 'she', day: day, mark: MenstrualMark.flow, mood: mood);

  // Quatro começos de Cheia em Cheia: 16/11/2024, 15/12, 14/01 e 12/02.
  final fullMoonStarts = [
    start(DateTime(2024, 11, 16)),
    start(DateTime(2024, 12, 15)),
    start(DateTime(2025, 1, 14)),
    start(DateTime(2025, 2, 12)),
  ];

  group('a convenção do meio-dia', () {
    // Exatamente o que a roda do ciclo e a leitura executam: o dia vira
    // meio-dia local, e é esse ponto que vai perguntar a fase.
    MoonPhase phaseAtNoon(DateTime day) =>
        LunarProvider.phaseOn(LunarComparison.noonOf(day));

    test('é o meio-dia local do dia observado', () {
      expect(LunarComparison.noonOf(DateTime(2026, 3, 12)),
          DateTime(2026, 3, 12, 12));
    });

    test('a hora do registro não vaza para a conta', () {
      // Dois momentos do mesmo dia perguntam à Lua exatamente o mesmo ponto:
      // é o dia que importa, não a hora em que ela abriu o app para marcar.
      expect(LunarComparison.noonOf(DateTime(2026, 3, 12, 23, 40)),
          LunarComparison.noonOf(DateTime(2026, 3, 12, 0, 5)));
    });

    // Estas duas âncoras são o único lugar em que a lunação é conferida
    // contra datas de calendário: um erro de sinal ou de referência
    // apareceria aqui antes de aparecer na roda do ciclo e na leitura.
    test('16/11/2024 ao meio-dia é Cheia', () {
      expect(phaseAtNoon(DateTime(2024, 11, 16)), MoonPhase.fullMoon);
    });

    test('08/11/2024 ao meio-dia é Quarto Crescente', () {
      expect(phaseAtNoon(DateTime(2024, 11, 8)), MoonPhase.firstQuarter);
    });
  });

  group('perto de quê', () {
    test('perto da Nova, perto da Cheia, e nem uma coisa nem outra', () {
      final newMoon = LunarComparison.observe(DateTime(2024, 11, 1));
      expect(newMoon.nearness, LunarNearness.newMoon);
      expect(newMoon.phase, MoonPhase.newMoon);
      expect(newMoon.daysFromNewMoon, lessThan(1));

      final fullMoon = LunarComparison.observe(DateTime(2024, 11, 16));
      expect(fullMoon.nearness, LunarNearness.fullMoon);
      expect(fullMoon.phase, MoonPhase.fullMoon);
      expect(fullMoon.daysFromFullMoon, lessThan(1));

      final between = LunarComparison.observe(DateTime(2024, 11, 8));
      expect(between.nearness, LunarNearness.neither,
          reason: 'Um quarto não é nem Nova nem Cheia, e a tela não força '
              'uma');
      expect(between.daysFromNewMoon, greaterThan(LunarComparison.windowDays));
      expect(between.daysFromFullMoon, greaterThan(LunarComparison.windowDays));
    });

    test('a janela em torno da Cheia é simétrica', () {
      // A Cheia estimada de junho de 2025 cai às 00:17 UTC do dia 11: dois
      // dias antes e dois depois entram, três de cada lado ficam fora.
      LunarNearness near(int day) =>
          LunarComparison.observe(DateTime(2025, 6, day)).nearness;
      expect(near(9), LunarNearness.fullMoon);
      expect(near(12), LunarNearness.fullMoon);
      expect(near(8), LunarNearness.neither);
      expect(near(13), LunarNearness.neither);
    });

    test('a janela em torno da Nova é simétrica', () {
      // A Nova estimada de fevereiro de 2026 cai às 00:31 UTC do dia 17.
      LunarNearness near(int day) =>
          LunarComparison.observe(DateTime(2026, 2, day)).nearness;
      expect(near(15), LunarNearness.newMoon);
      expect(near(18), LunarNearness.newMoon);
      expect(near(14), LunarNearness.neither);
      expect(near(19), LunarNearness.neither);
    });

    test('a observação guarda o dia sem hora', () {
      expect(LunarComparison.observe(DateTime(2024, 11, 16, 22, 15)).day,
          DateTime(2024, 11, 16));
    });
  });

  group('os começos', () {
    test('só a marca "começou" abre um ciclo, em ordem e sem repetir', () {
      final starts = LunarComparison.startsOf([
        start(DateTime(2025, 1, 14)),
        flow(DateTime(2024, 11, 17)),
        MenstrualDay(
            userId: 'she',
            day: DateTime(2024, 12, 2),
            mark: MenstrualMark.spotting),
        start(DateTime(2024, 11, 16)),
        start(DateTime(2024, 11, 16)),
        start(DateTime(2024, 12, 15), mood: 'x').copyWith(deleted: true),
      ]);
      expect(starts, [DateTime(2024, 11, 16), DateTime(2025, 1, 14)],
          reason: 'Escape e fluxo nunca viram começo, e a lápide não conta');
    });

    test('a linha do tempo vai do primeiro começo ao mais recente', () {
      final timeline = LunarComparison.timelineOf([
        ...fullMoonStarts,
        start(DateTime(2024, 11, 1)),
      ]);
      expect(timeline.map((o) => o.day), [
        DateTime(2024, 11, 1),
        DateTime(2024, 11, 16),
        DateTime(2024, 12, 15),
        DateTime(2025, 1, 14),
        DateTime(2025, 2, 12),
      ]);
      expect(timeline.first.nearness, LunarNearness.newMoon);
      expect(timeline.last.nearness, LunarNearness.fullMoon);
    });
  });

  group('o resumo', () {
    test('sem quatro começos não há resumo', () {
      expect(LunarComparison.summarize(fullMoonStarts.sublist(0, 3)), isNull,
          reason: 'Três intervalos completos exigem quatro começos');
      expect(LunarComparison.summarize(const []), isNull);
    });

    test('o quarto começo fecha o terceiro intervalo e não entra na conta',
        () {
      final summary = LunarComparison.summarize(fullMoonStarts)!;
      expect(summary.total, 3);
      expect(summary.observations.map((o) => o.day), [
        DateTime(2024, 11, 16),
        DateTime(2024, 12, 15),
        DateTime(2025, 1, 14),
      ]);
      expect(summary.closing.day, DateTime(2025, 2, 12),
          reason: 'Ele fecha o terceiro intervalo e continua visível');
      expect(summary.nearFullMoon, 3);
      expect(summary.nearNewMoon, 0);
    });

    test('com mais histórico, o resumo olha para os três mais recentes', () {
      final summary = LunarComparison.summarize([
        start(DateTime(2024, 11, 1)),
        ...fullMoonStarts,
      ])!;
      expect(summary.observations.first.day, DateTime(2024, 11, 16),
          reason: 'O começo mais antigo saiu da janela de três intervalos');
      expect(summary.nearNewMoon, 0);
      expect(summary.nearFullMoon, 3);
    });

    test('Nova e Cheia são contadas separadamente', () {
      final summary = LunarComparison.summarize([
        start(DateTime(2024, 11, 16)),
        start(DateTime(2024, 12, 15)),
        start(DateTime(2025, 1, 29)),
        start(DateTime(2025, 2, 28)),
      ])!;
      expect(summary.nearFullMoon, 2);
      expect(summary.nearNewMoon, 1);
      expect(summary.closing.nearness, LunarNearness.newMoon,
          reason: 'O que fecha tem a sua Lua, mas não está no denominador');
    });
  });

  group('as emoções', () {
    test('a contagem normaliza a escrita e mostra a grafia mais recente', () {
      final moods = LunarComparison.moodsOf([
        start(DateTime(2025, 3, 1), mood: 'Cansada'),
        flow(DateTime(2025, 3, 2), mood: '  cansada '),
        flow(DateTime(2025, 3, 3), mood: 'sensível'),
        flow(DateTime(2025, 3, 4), mood: 'cansada'),
      ]);
      expect(moods.map((m) => m.mood), ['cansada', 'sensível']);
      expect(moods.first.count, 3);
      expect(moods.last.count, 1);
    });

    test('a grafia mais usada vence, mesmo não sendo a última', () {
      final moods = LunarComparison.moodsOf([
        start(DateTime(2025, 3, 1), mood: 'Sensível'),
        flow(DateTime(2025, 3, 2), mood: 'Sensível'),
        flow(DateTime(2025, 3, 3), mood: 'sensível'),
      ]);
      expect(moods.single.mood, 'Sensível');
      expect(moods.single.count, 3);
    });

    test('só as três mais frequentes, e o empate é alfabético', () {
      final moods = LunarComparison.moodsOf([
        start(DateTime(2025, 3, 1), mood: 'calma'),
        flow(DateTime(2025, 3, 2), mood: 'brava'),
        flow(DateTime(2025, 3, 3), mood: 'doce'),
        flow(DateTime(2025, 3, 4), mood: 'doce'),
        flow(DateTime(2025, 3, 5), mood: 'ansiosa'),
      ]);
      expect(moods.map((m) => m.mood), ['doce', 'ansiosa', 'brava'],
          reason: 'Com o mesmo número, a ordem alfabética decide — e '
              '"calma" fica de fora por ser a quarta');
    });

    test('só dia de sangue com emoção escrita conta', () {
      final moods = LunarComparison.moodsOf([
        start(DateTime(2025, 3, 1)),
        flow(DateTime(2025, 3, 2), mood: '   '),
        MenstrualDay(
            userId: 'she',
            day: DateTime(2025, 3, 8),
            mark: MenstrualMark.spotting,
            mood: 'irritada'),
        MenstrualDay(
            userId: 'she',
            day: DateTime(2025, 3, 20),
            mark: MenstrualMark.note,
            mood: 'leve'),
        flow(DateTime(2025, 3, 3), mood: 'quieta').copyWith(deleted: true),
      ]);
      expect(moods, isEmpty,
          reason: 'Começo sem emoção, escape, anotação e lápide não '
              'entram');
    });

    test('as emoções também ficam separadas pela Lua do dia', () {
      final byPhase = LunarComparison.moodsByPhaseOf([
        start(DateTime(2024, 11, 16), mood: 'sensível'),
        flow(DateTime(2024, 11, 17), mood: 'sensível'),
        flow(DateTime(2024, 11, 8), mood: 'quieta'),
      ]);
      expect(byPhase.keys,
          containsAll([MoonPhase.fullMoon, MoonPhase.firstQuarter]));
      expect(byPhase[MoonPhase.fullMoon]!.single.mood, 'sensível');
      expect(byPhase[MoonPhase.fullMoon]!.single.count, 2);
      expect(byPhase[MoonPhase.firstQuarter]!.single.mood, 'quieta');
      expect(byPhase.containsKey(MoonPhase.newMoon), isFalse,
          reason: 'Fase sem anotação não aparece no mapa');
    });
  });

  group('o relatório', () {
    test('junta linha do tempo, resumo e emoções de uma vez', () {
      final report = LunarComparison.report([
        ...fullMoonStarts,
        flow(DateTime(2025, 2, 13), mood: 'cansada'),
      ], today: DateTime(2025, 3, 1));
      expect(report.timeline, hasLength(4));
      expect(report.summary, isNotNull);
      expect(report.moods.single.mood, 'cansada');
      expect(report.isEmpty, isFalse);
    });

    test('um começo marcado adiante de hoje ainda não aconteceu', () {
      final report = LunarComparison.report(
        fullMoonStarts,
        today: DateTime(2025, 2, 11, 23, 59),
      );
      expect(report.timeline.map((o) => o.day), [
        DateTime(2024, 11, 16),
        DateTime(2024, 12, 15),
        DateTime(2025, 1, 14),
      ]);
      expect(report.summary, isNull,
          reason: 'Sem o quarto começo, não há três intervalos completos');
    });

    test('sem registro nenhum, o relatório é vazio', () {
      final report =
          LunarComparison.report(const [], today: DateTime(2025, 3, 1));
      expect(report.isEmpty, isTrue);
      expect(report.timeline, isEmpty);
      expect(report.moods, isEmpty);
      expect(report.moodsByPhase, isEmpty);
    });
  });
}
