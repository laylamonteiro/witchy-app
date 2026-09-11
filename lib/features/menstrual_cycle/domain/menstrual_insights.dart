import 'menstrual_day.dart';

/// Um intervalo completo: de um começo ao começo seguinte.
class MenstrualInterval {
  const MenstrualInterval({required this.from, required this.to});

  final DateTime from;
  final DateTime to;

  int get days => MenstrualInsights.daysBetween(from, to);
}

/// Um episódio de sangramento: do começo até o último dia observado dele.
class MenstrualEpisode {
  const MenstrualEpisode({required this.start, required this.lastDay});

  final DateTime start;
  final DateTime lastDay;

  /// Contando as duas pontas: de 8 a 10 são três dias.
  int get days => MenstrualInsights.daysBetween(start, lastDay) + 1;
}

/// O que se calcula a partir do histórico — e só isso.
///
/// Tudo aqui é resultado derivado: dia do ciclo, duração de episódios, média
/// e faixa observadas e a referência de próxima data. Por isso nada disto é
/// montado no plano gratuito: `MenstrualAccess.canSeeDerived` decide antes.
///
/// Os critérios são explícitos: um intervalo existe entre dois começos
/// marcados pela pessoa; um escape nunca abre intervalo; e a referência de
/// próxima data é a média observada somada ao último começo, jamais uma
/// previsão de fertilidade ou de ovulação — isso está fora deste trabalho.
class MenstrualInsights {
  const MenstrualInsights._({
    required this.starts,
    required this.intervals,
    required this.episodes,
  });

  final List<DateTime> starts;
  final List<MenstrualInterval> intervals;
  final List<MenstrualEpisode> episodes;

  /// Quantos intervalos completos o resumo do histórico exige.
  static const minimumIntervalsForSummary = 3;

  static MenstrualInsights of(Iterable<MenstrualDay> days) {
    final ordered = [...days]..sort((a, b) => a.day.compareTo(b.day));
    final starts = <DateTime>[];
    final episodes = <MenstrualEpisode>[];
    for (var i = 0; i < ordered.length; i++) {
      if (ordered[i].mark != MenstrualMark.start) continue;
      starts.add(ordered[i].day);
      episodes.add(_episodeFrom(ordered, i));
    }
    final intervals = <MenstrualInterval>[
      for (var i = 1; i < starts.length; i++)
        MenstrualInterval(from: starts[i - 1], to: starts[i]),
    ];
    return MenstrualInsights._(
      starts: starts,
      intervals: intervals,
      episodes: episodes,
    );
  }

  /// O episódio que começa em [index]: segue pelos dias seguidos com
  /// sangramento observado e para no "terminou", no primeiro buraco, ou no
  /// começo seguinte.
  static MenstrualEpisode _episodeFrom(List<MenstrualDay> ordered, int index) {
    var last = ordered[index].day;
    for (var i = index + 1; i < ordered.length; i++) {
      final day = ordered[i];
      if (day.mark == MenstrualMark.start) break;
      if (daysBetween(last, day.day) != 1) break;
      if (day.mark == MenstrualMark.end) {
        last = day.day;
        break;
      }
      if (day.mark == MenstrualMark.note) break;
      last = day.day;
    }
    return MenstrualEpisode(start: ordered[index].day, lastDay: last);
  }

  /// Dias inteiros entre duas datas, sem tropeçar no horário de verão.
  static int daysBetween(DateTime from, DateTime to) =>
      _dayNumber(to) - _dayNumber(from);

  static int _dayNumber(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day).millisecondsSinceEpoch ~/
          Duration.millisecondsPerDay;

  /// A média observada, arredondada. Nula enquanto não houver um intervalo.
  int? get averageIntervalDays {
    if (intervals.isEmpty) return null;
    final total = intervals.fold<int>(0, (sum, item) => sum + item.days);
    return (total / intervals.length).round();
  }

  /// O menor e o maior intervalo observados.
  ({int shortest, int longest})? get intervalRange {
    if (intervals.isEmpty) return null;
    var shortest = intervals.first.days;
    var longest = intervals.first.days;
    for (final interval in intervals) {
      if (interval.days < shortest) shortest = interval.days;
      if (interval.days > longest) longest = interval.days;
    }
    return (shortest: shortest, longest: longest);
  }

  /// O resumo do histórico só aparece com três intervalos completos.
  bool get hasSummary => intervals.length >= minimumIntervalsForSummary;

  /// Em que dia do ciclo [date] cai, contando do último começo até ela.
  /// Nulo antes do primeiro começo registrado: não há de onde contar.
  int? cycleDayOn(DateTime date) {
    DateTime? last;
    for (final start in starts) {
      if (daysBetween(start, date) >= 0) last = start;
    }
    return last == null ? null : daysBetween(last, date) + 1;
  }

  /// Uma referência para a próxima data: o último começo mais a média
  /// observada. Só com o resumo disponível, e só se a pessoa pediu para ver.
  /// É referência, não promessa — e não diz nada sobre fertilidade.
  DateTime? nextReference({required bool optedIn}) {
    if (!optedIn || !hasSummary || starts.isEmpty) return null;
    final average = averageIntervalDays;
    if (average == null) return null;
    final last = starts.last;
    return DateTime(last.year, last.month, last.day + average);
  }
}
