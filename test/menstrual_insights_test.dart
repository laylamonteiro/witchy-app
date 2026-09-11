import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_day.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_insights.dart';
import 'support/short_test_timeout.dart';

void main() {
  useShortTestTimeout();

  MenstrualDay day(DateTime date, MenstrualMark mark) =>
      MenstrualDay(userId: 'u', day: date, mark: mark);

  List<MenstrualDay> episode(DateTime start, int days, {bool closed = true}) => [
        day(start, MenstrualMark.start),
        for (var i = 1; i < days; i++)
          day(DateTime(start.year, start.month, start.day + i),
              i == days - 1 && closed ? MenstrualMark.end : MenstrualMark.flow),
      ];

  test('nothing to derive from a single beginning', () {
    final insights = MenstrualInsights.of(episode(DateTime(2026, 1, 5), 4));
    expect(insights.starts, hasLength(1));
    expect(insights.intervals, isEmpty);
    expect(insights.averageIntervalDays, isNull);
    expect(insights.intervalRange, isNull);
    expect(insights.hasSummary, isFalse);
    expect(insights.nextReference(optedIn: true), isNull,
        reason: 'A reference needs observed intervals, not a guess');
  });

  test('an interval runs from one beginning to the next, and spotting opens none', () {
    final insights = MenstrualInsights.of([
      ...episode(DateTime(2026, 1, 5), 4),
      day(DateTime(2026, 1, 20), MenstrualMark.spotting),
      ...episode(DateTime(2026, 2, 2), 4),
    ]);
    expect(insights.starts, [DateTime(2026, 1, 5), DateTime(2026, 2, 2)]);
    expect(insights.intervals.single.days, 28);
    expect(insights.averageIntervalDays, 28);
    expect(insights.intervalRange, (shortest: 28, longest: 28));
    expect(insights.hasSummary, isFalse, reason: 'One interval is not a history');
  });

  test('the summary needs three complete intervals', () {
    final days = [
      ...episode(DateTime(2026, 1, 1), 4),
      ...episode(DateTime(2026, 1, 29), 4),
      ...episode(DateTime(2026, 2, 27), 4),
    ];
    var insights = MenstrualInsights.of(days);
    expect(insights.intervals, hasLength(2));
    expect(insights.hasSummary, isFalse);
    expect(insights.nextReference(optedIn: true), isNull);

    insights = MenstrualInsights.of([...days, ...episode(DateTime(2026, 3, 28), 4)]);
    expect(insights.intervals, hasLength(3));
    expect(insights.hasSummary, isTrue);
    expect(insights.intervalRange, (shortest: 28, longest: 29));
    expect(insights.averageIntervalDays, 29);
  });

  test('the next date is a reference, and only when it was asked for', () {
    final insights = MenstrualInsights.of([
      ...episode(DateTime(2026, 1, 1), 4),
      ...episode(DateTime(2026, 1, 29), 4),
      ...episode(DateTime(2026, 2, 26), 4),
      ...episode(DateTime(2026, 3, 26), 4),
    ]);
    expect(insights.hasSummary, isTrue);
    expect(insights.nextReference(optedIn: false), isNull,
        reason: 'Opt in first; nothing is shown by default');
    expect(insights.nextReference(optedIn: true), DateTime(2026, 4, 23));
  });

  test('the numbers speak about the recent window, and say how many', () {
    // Oito começos: sete intervalos, e só os seis últimos entram na conta.
    final starts = [
      DateTime(2025, 1, 1),
      DateTime(2025, 2, 10), // 40 dias — o intervalo mais longo, e o mais velho
      DateTime(2025, 3, 10),
      DateTime(2025, 4, 7),
      DateTime(2025, 5, 5),
      DateTime(2025, 6, 2),
      DateTime(2025, 6, 30),
      DateTime(2025, 7, 28),
    ];
    final insights =
        MenstrualInsights.of([for (final start in starts) ...episode(start, 4)]);
    expect(insights.intervals, hasLength(7));
    expect(insights.sampleSize, MenstrualInsights.recentIntervalWindow);
    expect(insights.recentIntervals.first.from, DateTime(2025, 2, 10),
        reason: 'O intervalo mais antigo saiu da janela');
    expect(insights.averageIntervalDays, 28);
    expect(insights.intervalRange, (shortest: 28, longest: 28),
        reason: 'Os 40 dias ficaram para trás junto com o intervalo antigo');
  });

  test('a reference comes from the median, not from one strange interval', () {
    final insights = MenstrualInsights.of([
      ...episode(DateTime(2026, 1, 1), 4),
      ...episode(DateTime(2026, 1, 29), 4), // 28
      ...episode(DateTime(2026, 2, 26), 4), // 28
      ...episode(DateTime(2026, 4, 27), 4), // 60: aconteceu, e não é descartado
    ]);
    expect(insights.intervals, hasLength(3));
    expect(insights.averageIntervalDays, 39, reason: '(28 + 28 + 60) / 3');
    expect(insights.medianIntervalDays, 28);
    expect(insights.nextReference(optedIn: true), DateTime(2026, 5, 25),
        reason: 'O último começo mais a mediana, não mais a média');
    expect(insights.intervalRange, (shortest: 28, longest: 60),
        reason: 'A faixa continua mostrando o que foi observado');
  });

  test('a reference that has passed is out of date, and says only that', () {
    final insights = MenstrualInsights.of([
      ...episode(DateTime(2026, 1, 1), 4),
      ...episode(DateTime(2026, 1, 29), 4),
      ...episode(DateTime(2026, 2, 26), 4),
      ...episode(DateTime(2026, 3, 26), 4),
    ]);
    final reference = insights.nextReference(optedIn: true)!;
    expect(reference, DateTime(2026, 4, 23));
    expect(insights.referenceIsStale(DateTime(2026, 4, 22), optedIn: true),
        isFalse);
    expect(insights.referenceIsStale(reference, optedIn: true), isFalse,
        reason: 'No próprio dia ela ainda não passou');
    expect(insights.referenceIsStale(DateTime(2026, 4, 24), optedIn: true),
        isTrue);
    expect(insights.referenceIsStale(DateTime(2026, 5, 30), optedIn: false),
        isFalse, reason: 'Quem não pediu a referência não recebe nem o aviso');
  });

  test('an episode counts both ends and stops at the gap', () {
    final insights = MenstrualInsights.of([
      ...episode(DateTime(2026, 5, 8), 3),
      // A separate day, days later: it belongs to no episode above.
      day(DateTime(2026, 5, 20), MenstrualMark.spotting),
    ]);
    expect(insights.episodes.single.days, 3,
        reason: 'From the 8th to the 10th is three days');
    expect(insights.episodes.single.start, DateTime(2026, 5, 8));
    expect(insights.episodes.single.lastDay, DateTime(2026, 5, 10));
  });

  test('an open episode stops at the last day observed in a row', () {
    final insights = MenstrualInsights.of([
      day(DateTime(2026, 6, 1), MenstrualMark.start),
      day(DateTime(2026, 6, 2), MenstrualMark.flow),
      // The 3rd was not recorded; the 4th was.
      day(DateTime(2026, 6, 4), MenstrualMark.flow),
    ]);
    expect(insights.episodes.single.days, 2,
        reason: 'A day without a record is not a day of bleeding');
  });

  test('the cycle day counts from the last beginning on or before the date', () {
    final insights = MenstrualInsights.of([
      ...episode(DateTime(2026, 1, 5), 4),
      ...episode(DateTime(2026, 2, 2), 4),
    ]);
    expect(insights.cycleDayOn(DateTime(2026, 1, 5)), 1);
    expect(insights.cycleDayOn(DateTime(2026, 1, 8)), 4);
    expect(insights.cycleDayOn(DateTime(2026, 2, 3)), 2,
        reason: 'The newer beginning takes over');
    expect(insights.cycleDayOn(DateTime(2026, 1, 1)), isNull,
        reason: 'Before the first beginning there is nothing to count from');
  });

  test('whole days are counted even across a daylight saving change', () {
    // Brazil used to move the clock in the middle of October.
    final insights = MenstrualInsights.of([
      day(DateTime(2018, 10, 1), MenstrualMark.start),
      day(DateTime(2018, 10, 29), MenstrualMark.start),
    ]);
    expect(insights.intervals.single.days, 28);
  });
}
