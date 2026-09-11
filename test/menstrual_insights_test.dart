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
