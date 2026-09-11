import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/models/spell_model.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/lunar_comparison.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_day.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_insights.dart';

/// A comparação com a Lua: proximidade medida pela mesma conta do calendário
/// lunar, numa janela simétrica de dois dias, sobre os começos que ela marcou.
///
/// As datas do teste foram escolhidas com folga — nenhuma delas fica a menos
/// de meio dia da borda da janela, então o fuso do aparelho que roda o teste
/// não muda o resultado.
void main() {
  MenstrualDay start(DateTime day) =>
      MenstrualDay(userId: 'she', day: day, mark: MenstrualMark.start);

  test('perto da Nova, perto da Cheia, e nem uma coisa nem outra', () {
    final newMoon = LunarComparison.observe(DateTime(2024, 11, 1));
    expect(newMoon.nearness, LunarNearness.newMoon);
    expect(newMoon.phase, MoonPhase.newMoon);
    expect(newMoon.daysFromNewMoon, lessThan(1));

    final fullMoon = LunarComparison.observe(DateTime(2024, 11, 16));
    expect(fullMoon.nearness, LunarNearness.fullMoon);
    expect(fullMoon.daysFromFullMoon, lessThan(1));

    final between = LunarComparison.observe(DateTime(2024, 11, 8));
    expect(between.nearness, LunarNearness.neither,
        reason: 'Um quarto não é nem Nova nem Cheia, e a tela não força uma');
    expect(between.daysFromNewMoon, greaterThan(LunarComparison.windowDays));
    expect(between.daysFromFullMoon, greaterThan(LunarComparison.windowDays));
  });

  test('a janela é simétrica e a convenção é o meio-dia', () {
    // Dois dias antes e dois dias depois da mesma Cheia entram os dois.
    expect(LunarComparison.observe(DateTime(2024, 11, 14)).nearness,
        LunarNearness.fullMoon);
    expect(LunarComparison.observe(DateTime(2024, 11, 18)).nearness,
        LunarNearness.fullMoon);
    expect(LunarComparison.noonOf(DateTime(2026, 3, 12)),
        DateTime(2026, 3, 12, 12));
  });

  test('sem quatro começos não há resumo', () {
    final insights = MenstrualInsights.of([
      start(DateTime(2024, 11, 16)),
      start(DateTime(2024, 12, 15)),
      start(DateTime(2025, 1, 14)),
    ]);
    expect(insights.intervals, hasLength(2));
    expect(LunarComparison.summarize(insights), isNull,
        reason: 'Três intervalos completos exigem quatro começos');
  });

  test('o quarto começo fecha o terceiro intervalo e não entra na conta', () {
    final insights = MenstrualInsights.of([
      start(DateTime(2024, 11, 16)),
      start(DateTime(2024, 12, 15)),
      start(DateTime(2025, 1, 14)),
      start(DateTime(2025, 2, 12)),
    ]);
    final summary = LunarComparison.summarize(insights)!;
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
    final insights = MenstrualInsights.of([
      start(DateTime(2024, 11, 1)),
      start(DateTime(2024, 11, 16)),
      start(DateTime(2024, 12, 15)),
      start(DateTime(2025, 1, 14)),
      start(DateTime(2025, 2, 12)),
    ]);
    final summary = LunarComparison.summarize(insights)!;
    expect(summary.observations.first.day, DateTime(2024, 11, 16),
        reason: 'O começo mais antigo saiu da janela de três intervalos');
    expect(summary.nearNewMoon, 0);
    expect(summary.nearFullMoon, 3);
  });
}
