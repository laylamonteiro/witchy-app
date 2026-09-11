import '../../grimoire/data/models/spell_model.dart';
import '../../lunar/presentation/providers/lunar_provider.dart';
import 'menstrual_insights.dart';

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

  /// A fase estimada pelo app — não é efeméride.
  final MoonPhase phase;

  final LunarNearness nearness;
  final double daysFromNewMoon;
  final double daysFromFullMoon;
}

/// O resumo: as observações contadas, e quantas ficaram perto de cada ponta.
class LunarComparisonSummary {
  const LunarComparisonSummary({
    required this.observations,
    required this.closing,
  });

  /// Os começos que abrem os três intervalos completos mais recentes.
  final List<LunarObservation> observations;

  /// O começo que FECHA o terceiro intervalo. Ele continua visível na linha
  /// do tempo e não entra no denominador de três.
  final LunarObservation closing;

  int get total => observations.length;

  int get nearNewMoon =>
      observations.where((o) => o.nearness == LunarNearness.newMoon).length;

  int get nearFullMoon =>
      observations.where((o) => o.nearness == LunarNearness.fullMoon).length;
}

/// A comparação entre os começos que ela marcou e a Lua estimada pelo app.
///
/// As regras são heurísticas de produto, versionadas e testáveis — não
/// validação clínica, e nada aqui afirma causa:
///
/// * a janela é **simétrica**, de ±2 dias em torno da Nova e da Cheia
///   estimadas. É convenção de apresentação, não definição histórica nem
///   fisiológica, e a tela diz qual janela usou;
/// * um registro não tem hora: a comparação usa o **meio-dia local** do dia
///   observado, identificado como convenção de cálculo — não é o horário de
///   nada que aconteceu com ela, e trocar o fuso do aparelho não
///   reclassifica o histórico;
/// * o resumo usa os começos que abrem os **três intervalos completos mais
///   recentes**, o que exige quatro começos válidos. O quarto fecha o
///   terceiro intervalo, continua visível e não vira uma quarta observação
///   num denominador de três;
/// * daqui não sai porcentagem de "sincronia", pontuação, ranking nem
///   previsão de que voltará a acontecer. Datas próximas autorizam uma
///   comparação e uma leitura poética, não uma conclusão.
///
/// O card "Você e a Lua" foi removido da página do Ciclo, e com ele o único
/// consumidor de [LunarComparison.observe] e [LunarComparison.summarize] em
/// lib/ — eles continuam aqui, com teste, porque a regra é o que custou a ser
/// escrita. Já [LunarComparison.noonOf] segue em uso pela roda e pela leitura
/// do ciclo: este arquivo não é código morto.
abstract final class LunarComparison {
  /// A janela simétrica, em dias, em torno de Nova e Cheia.
  static const windowDays = 2;

  /// Versão do algoritmo. Muda quando a janela ou o critério mudarem, para
  /// que um resumo antigo não seja lido com as regras novas.
  static const version = 1;

  /// Quantos começos o resumo exige: três intervalos completos.
  static const minimumStarts = MenstrualInsights.minimumIntervalsForSummary + 1;

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
      day: day,
      phase: LunarProvider.phaseOn(noonOf(day)),
      nearness: nearness,
      daysFromNewMoon: fromNew,
      daysFromFullMoon: fromFull,
    );
  }

  /// O resumo, quando há começos suficientes. Nulo antes disso — e, se a
  /// pessoa apagar um começo e a revisão cair abaixo do mínimo, ele some sem
  /// levar nenhum registro junto.
  static LunarComparisonSummary? summarize(MenstrualInsights insights) {
    final starts = insights.starts;
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
}
