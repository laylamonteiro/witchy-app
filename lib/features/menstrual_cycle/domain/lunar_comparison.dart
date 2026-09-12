import '../../grimoire/data/models/spell_model.dart';
import '../../lunar/presentation/providers/lunar_provider.dart';
import 'menstrual_day.dart';

/// Perto de quê, quando está perto de alguma coisa.
enum LunarNearness { newMoon, fullMoon, neither }

/// Um começo marcado por ela, ao lado da Lua que o app estima para aquele dia.
class LunarObservation {
  const LunarObservation({
    required this.day,
    required this.phase,
    required this.nearness,
    required this.daysFromNewMoon,
    required this.daysFromFullMoon,
  });

  final DateTime day;

  /// A fase estimada pelo app para o meio-dia daquele dia.
  final MoonPhase phase;

  final LunarNearness nearness;
  final double daysFromNewMoon;
  final double daysFromFullMoon;
}

/// O resumo: os começos contados, e quantos ficaram perto de cada ponta.
class LunarComparisonSummary {
  const LunarComparisonSummary({
    required this.observations,
    required this.closing,
  });

  /// Os começos que abrem os três intervalos completos mais recentes.
  final List<LunarObservation> observations;

  /// O começo que FECHA o terceiro intervalo. Ele continua na linha do tempo
  /// e não entra no denominador de três: um ciclo só está completo quando o
  /// seguinte começou.
  final LunarObservation closing;

  int get total => observations.length;

  int get nearNewMoon =>
      observations.where((o) => o.nearness == LunarNearness.newMoon).length;

  int get nearFullMoon =>
      observations.where((o) => o.nearness == LunarNearness.fullMoon).length;
}

/// Uma emoção anotada nos dias de sangue e quantas vezes ela apareceu.
class MoodTally {
  const MoodTally({required this.mood, required this.count});

  /// A grafia mais usada por ela. A contagem ignora maiúsculas e espaços nas
  /// pontas, mas quem aparece na tela é a palavra do jeito que ela escreve.
  final String mood;

  final int count;
}

/// Tudo o que o card "A Lua e você" lê, calculado de uma vez a partir do
/// histórico: a linha do tempo dos começos, o resumo quando há começos
/// suficientes e as emoções mais anotadas nos dias de sangue.
class LunarComparisonReport {
  const LunarComparisonReport({
    required this.timeline,
    required this.summary,
    required this.moods,
    required this.moodsByPhase,
  });

  /// Todos os começos, do primeiro ao mais recente, com a Lua de cada um.
  final List<LunarObservation> timeline;

  /// Nulo enquanto não houver quatro começos.
  final LunarComparisonSummary? summary;

  /// As emoções mais anotadas nos dias de sangue, da mais frequente para a
  /// menos — no máximo [LunarComparison.topMoods].
  final List<MoodTally> moods;

  /// As mesmas emoções, separadas pela Lua estimada do dia em que foram
  /// anotadas. Só as fases com alguma anotação aparecem no mapa.
  final Map<MoonPhase, List<MoodTally>> moodsByPhase;

  bool get isEmpty => timeline.isEmpty && moods.isEmpty;
}

/// A comparação entre o que ela marcou e a Lua estimada pelo app.
///
/// As regras são convenções de produto, e por isso ficam nomeadas aqui:
///
/// * a janela é **simétrica**, de ±[windowDays] dias em torno da Nova e da
///   Cheia estimadas;
/// * um registro não tem hora: a comparação usa sempre o **meio-dia
///   local** do dia observado ([noonOf]). É o que garante que trocar o fuso
///   do aparelho não reclassifique o histórico — e é a mesma convenção que
///   a roda do ciclo e a leitura usam para perguntar a fase de um dia;
/// * o resumo olha para os começos que abrem os **três intervalos completos
///   mais recentes**, o que exige quatro começos. O quarto fecha o terceiro
///   intervalo, continua visível e não vira uma quarta observação num
///   denominador de três;
/// * as emoções vêm do texto livre que ela escreve nos dias de sangue
///   (começo e fluxo). A contagem normaliza a escrita; a tela mostra a grafia
///   mais comum dela.
///
/// Daqui não sai porcentagem, previsão nem frase de causa: sai o que ela
/// marcou, ao lado da Lua daquele dia.
abstract final class LunarComparison {
  /// A janela simétrica, em dias, em torno de Nova e Cheia.
  static const windowDays = 2;

  /// Quantos começos o resumo exige: três intervalos completos.
  static const minimumStarts = 4;

  /// Quantas emoções a tela lista.
  static const topMoods = 3;

  /// A convenção de cálculo: o meio-dia local do dia observado.
  static DateTime noonOf(DateTime day) =>
      DateTime(day.year, day.month, day.day, 12);

  /// Distância em dias até a Lua Nova estimada mais próxima.
  static double daysFromNewMoon(DateTime day) {
    final position = LunarProvider.lunationPositionOn(noonOf(day));
    final fraction = position <= .5 ? position : 1 - position;
    return fraction * LunarProvider.lunarCycleDays;
  }

  /// Distância em dias até a Lua Cheia estimada.
  static double daysFromFullMoon(DateTime day) {
    final position = LunarProvider.lunationPositionOn(noonOf(day));
    return (position - .5).abs() * LunarProvider.lunarCycleDays;
  }

  static LunarObservation observe(DateTime day) {
    final fromNew = daysFromNewMoon(day);
    final fromFull = daysFromFullMoon(day);
    // As duas pontas estão a quase quinze dias uma da outra: com uma janela
    // de dois dias, nenhum dia cai nas duas.
    final nearness = fromNew <= windowDays
        ? LunarNearness.newMoon
        : fromFull <= windowDays
            ? LunarNearness.fullMoon
            : LunarNearness.neither;
    return LunarObservation(
      day: DateTime(day.year, day.month, day.day),
      phase: LunarProvider.phaseOn(noonOf(day)),
      nearness: nearness,
      daysFromNewMoon: fromNew,
      daysFromFullMoon: fromFull,
    );
  }

  /// Os começos que ela marcou, em ordem. Só a marca "começou" abre um
  /// ciclo: escape e fluxo nunca viram começo, e uma lápide não conta.
  static List<DateTime> startsOf(Iterable<MenstrualDay> days) {
    final starts = <DateTime>{
      for (final day in days)
        if (!day.deleted && day.mark == MenstrualMark.start) day.day,
    };
    return starts.toList()..sort();
  }

  /// Cada começo com a Lua daquele dia, do primeiro ao mais recente.
  static List<LunarObservation> timelineOf(Iterable<MenstrualDay> days) =>
      [for (final start in startsOf(days)) observe(start)];

  /// O resumo, quando há começos suficientes. Nulo antes disso — e, se ela
  /// apagar um começo e o histórico cair abaixo do mínimo, ele some sem
  /// levar nenhum registro junto.
  static LunarComparisonSummary? summarize(Iterable<MenstrualDay> days) {
    final starts = startsOf(days);
    if (starts.length < minimumStarts) return null;
    final window = starts.sublist(starts.length - minimumStarts);
    return LunarComparisonSummary(
      observations: [
        for (final start in window.sublist(0, window.length - 1))
          observe(start),
      ],
      closing: observe(window.last),
    );
  }

  /// As emoções mais anotadas nos dias de sangue: as [topMoods] mais
  /// frequentes, e o empate é desfeito pela ordem alfabética para que a lista
  /// não mude de lugar entre uma abertura e outra.
  static List<MoodTally> moodsOf(Iterable<MenstrualDay> days) =>
      _rank(_tally(_bleedingWithMood(days)));

  /// As mesmas emoções, separadas pela Lua estimada do dia da anotação.
  static Map<MoonPhase, List<MoodTally>> moodsByPhaseOf(
      Iterable<MenstrualDay> days) {
    final byPhase = <MoonPhase, List<MenstrualDay>>{};
    for (final day in _bleedingWithMood(days)) {
      byPhase
          .putIfAbsent(LunarProvider.phaseOn(noonOf(day.day)), () => [])
          .add(day);
    }
    return {
      for (final entry in byPhase.entries)
        entry.key: _rank(_tally(entry.value)),
    };
  }

  /// Tudo o que o card lê, a partir do histórico até [today]. Um dia marcado
  /// adiante de hoje ainda não aconteceu, e por isso fica de fora.
  static LunarComparisonReport report(
    Iterable<MenstrualDay> days, {
    required DateTime today,
  }) {
    final limit = DateTime(today.year, today.month, today.day);
    final seen = [
      for (final day in days)
        if (!day.deleted && !day.day.isAfter(limit)) day,
    ];
    return LunarComparisonReport(
      timeline: timelineOf(seen),
      summary: summarize(seen),
      moods: moodsOf(seen),
      moodsByPhase: moodsByPhaseOf(seen),
    );
  }

  /// Os dias de sangue (começo e fluxo) em que ela escreveu alguma emoção.
  static Iterable<MenstrualDay> _bleedingWithMood(
          Iterable<MenstrualDay> days) =>
      days.where((day) =>
          !day.deleted &&
          (day.mark == MenstrualMark.start || day.mark == MenstrualMark.flow) &&
          (day.mood?.trim().isNotEmpty ?? false));

  /// Conta cada emoção pela forma normalizada (sem espaços nas pontas, em
  /// minúsculas) e guarda, por dentro, quantas vezes cada grafia apareceu.
  ///
  /// Os dias entram em ordem, e uma grafia que reaparece vai para o fim do
  /// mapa: é assim que [_commonSpelling] sabe qual foi a mais recente.
  static Map<String, Map<String, int>> _tally(Iterable<MenstrualDay> days) {
    final ordered = days.toList()..sort((a, b) => a.day.compareTo(b.day));
    final counts = <String, Map<String, int>>{};
    for (final day in ordered) {
      final written = day.mood!.trim();
      final spellings = counts.putIfAbsent(written.toLowerCase(), () => {});
      final seen = spellings.remove(written) ?? 0;
      spellings[written] = seen + 1;
    }
    return counts;
  }

  static List<MoodTally> _rank(Map<String, Map<String, int>> counts) {
    final ranked = [
      for (final entry in counts.entries)
        (
          key: entry.key,
          tally: MoodTally(
            mood: _commonSpelling(entry.value),
            count: entry.value.values.fold(0, (sum, n) => sum + n),
          ),
        ),
    ]..sort((a, b) {
        final byCount = b.tally.count.compareTo(a.tally.count);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });
    return [for (final item in ranked.take(topMoods)) item.tally];
  }

  /// A grafia que ela mais usou; empatadas, a mais recente — é o jeito atual
  /// de ela escrever, e não uma forma antiga nem uma escolhida pelo app.
  static String _commonSpelling(Map<String, int> spellings) {
    var chosen = spellings.keys.first;
    var best = 0;
    for (final entry in spellings.entries) {
      if (entry.value >= best) {
        chosen = entry.key;
        best = entry.value;
      }
    }
    return chosen;
  }
}
