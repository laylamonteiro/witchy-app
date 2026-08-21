import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:sweph/sweph.dart' show HeavenlyBody;

import '../../../astrology/data/models/enums.dart';
import '../../../astrology/data/services/sweph_service.dart';
import '../models/month_sky_event.dart';

/// O céu do mês, calculado no aparelho.
///
/// Nada de IA e nada de média: cada data sai do Swiss Ephemeris, refinada por
/// bisseção até o minuto. A conta média do ciclo lunar, que o calendário do
/// app usa, desvia até meia dia da lua nova verdadeira — tolerável para dizer
/// "a lua está crescente", inaceitável para uma seção que anuncia "dia 12".
class MonthSkyCalculator {
  MonthSkyCalculator._();

  /// Planetas cuja retrogradação vale contar. Sol e Lua nunca retrogradam.
  static const _planetasRetrogradaveis = [
    Planet.mercury,
    Planet.venus,
    Planet.mars,
    Planet.jupiter,
    Planet.saturn,
    Planet.uranus,
    Planet.neptune,
    Planet.pluto,
  ];

  /// Eventos do mês que contém [algumDiaDoMes], em ordem cronológica.
  static Future<List<MonthSkyEvent>> doMes(DateTime algumDiaDoMes) async {
    await SwephService.instance.ensureReady();

    final inicio = DateTime.utc(algumDiaDoMes.year, algumDiaDoMes.month, 1);
    final fim = DateTime.utc(
      algumDiaDoMes.month == 12 ? algumDiaDoMes.year + 1 : algumDiaDoMes.year,
      algumDiaDoMes.month == 12 ? 1 : algumDiaDoMes.month + 1,
      1,
    );

    final eventos = <MonthSkyEvent>[
      ..._lunacoes(inicio, fim),
      ..._ingressoDoSol(inicio, fim),
      ..._retrogradacoes(inicio, fim),
    ]..sort((a, b) => a.instanteUtc.compareTo(b.instanteUtc));

    return eventos;
  }

  // ---------------------------------------------------------------- lunações

  /// Lua nova e lua cheia: a distância angular entre Lua e Sol cruzando 0° e
  /// 180°. Varre dia a dia procurando a troca de sinal e refina por bisseção.
  static List<MonthSkyEvent> _lunacoes(DateTime inicio, DateTime fim) {
    final saida = <MonthSkyEvent>[];

    for (final (alvo, kind) in [
      (0.0, MonthSkyKind.newMoon),
      (180.0, MonthSkyKind.fullMoon),
    ]) {
      double f(double jd) => centrado(
            _lon(jd, HeavenlyBody.SE_MOON) - _lon(jd, HeavenlyBody.SE_SUN) - alvo,
          );

      for (final jd in _passosDiarios(inicio, fim)) {
        final a = f(jd);
        final b = f(jd + 1);
        // A função é contínua e crescente ~13°/dia; a troca de sinal só é
        // um cruzamento verdadeiro quando o salto é pequeno (o salto grande
        // é o rasgo de -180 para +180, que não é evento nenhum).
        if (a.sign == b.sign || (b - a).abs() > 180) continue;

        final exato = bissecao(f, jd, jd + 1);
        final quando = paraData(exato);
        if (quando.isBefore(inicio) || !quando.isBefore(fim)) continue;

        saida.add(MonthSkyEvent(
          kind: kind,
          instanteUtc: quando,
          signo: signoDe(_lon(exato, HeavenlyBody.SE_MOON)),
        ));
      }
    }
    return saida;
  }

  // --------------------------------------------------------- ingresso do Sol

  /// O dia em que o Sol troca de signo — a virada do mês.
  static List<MonthSkyEvent> _ingressoDoSol(DateTime inicio, DateTime fim) {
    final saida = <MonthSkyEvent>[];

    for (final jd in _passosDiarios(inicio, fim)) {
      final antes = _lon(jd, HeavenlyBody.SE_SUN);
      final depois = _lon(jd + 1, HeavenlyBody.SE_SUN);
      final signoAntes = (antes / 30).floor();
      final signoDepois = (depois / 30).floor();
      if (signoAntes == signoDepois) continue;

      // Fronteira do signo novo. Na virada de Peixes para Áries a fronteira
      // é 0°, e a longitude "cai" de 359 para 0 — daí o caso separado.
      final fronteira = signoDepois == 0 ? 360.0 : signoDepois * 30.0;
      double f(double x) {
        var lon = _lon(x, HeavenlyBody.SE_SUN);
        if (signoDepois == 0 && lon < 180) lon += 360;
        return lon - fronteira;
      }

      final exato = bissecao(f, jd, jd + 1);
      final quando = paraData(exato);
      if (quando.isBefore(inicio) || !quando.isBefore(fim)) continue;

      saida.add(MonthSkyEvent(
        kind: MonthSkyKind.sunIngress,
        instanteUtc: quando,
        signo: ZodiacSign.values[signoDepois % 12],
      ));
    }
    return saida;
  }

  // ---------------------------------------------------------- retrogradações

  /// Onde a velocidade de um planeta troca de sinal: aí ele estaciona e vira.
  static List<MonthSkyEvent> _retrogradacoes(DateTime inicio, DateTime fim) {
    final saida = <MonthSkyEvent>[];

    for (final planeta in _planetasRetrogradaveis) {
      final corpo = SwephService.heavenlyBody(planeta);
      double v(double jd) =>
          SwephService.instance.bodyPosition(jd, corpo).speed;

      for (final jd in _passosDiarios(inicio, fim)) {
        final a = v(jd);
        final b = v(jd + 1);
        if (a == 0 || a.sign == b.sign) continue;

        final exato = bissecao(v, jd, jd + 1);
        final quando = paraData(exato);
        if (quando.isBefore(inicio) || !quando.isBefore(fim)) continue;

        saida.add(MonthSkyEvent(
          // Velocidade indo de positiva para negativa: começou a retrogradar.
          kind: a > 0
              ? MonthSkyKind.retrogradeStart
              : MonthSkyKind.retrogradeEnd,
          instanteUtc: quando,
          planeta: planeta,
          signo: signoDe(_lon(exato, corpo)),
        ));
      }
    }
    return saida;
  }

  // ------------------------------------------------------------- ferramentas

  static double _lon(double jd, HeavenlyBody corpo) =>
      SwephService.instance.bodyPosition(jd, corpo).longitude;

  @visibleForTesting
  static ZodiacSign signoDe(double longitude) =>
      ZodiacSign.values[((longitude / 30).floor()) % 12];

  /// Traz um ângulo para a faixa -180..180, onde o zero é o cruzamento.
  @visibleForTesting
  static double centrado(double graus) {
    var g = (graus + 180) % 360;
    if (g < 0) g += 360;
    return g - 180;
  }

  /// Um JD por dia do intervalo, mais um dia de folga no fim para o último
  /// passo enxergar o dia seguinte.
  static Iterable<double> _passosDiarios(DateTime inicio, DateTime fim) sync* {
    var dia = inicio;
    while (dia.isBefore(fim)) {
      yield SwephService.instance.julianDayUt(
        year: dia.year,
        month: dia.month,
        day: dia.day,
        hourUt: 0,
      );
      dia = dia.add(const Duration(days: 1));
    }
  }

  /// Bisseção: 24 passos num intervalo de um dia chegam a ~5 segundos, muito
  /// além do que a tela mostra — e o custo é irrisório.
  @visibleForTesting
  static double bissecao(double Function(double) f, double a, double b) {
    var lo = a;
    var hi = b;
    final sinalLo = f(lo).sign;
    for (var i = 0; i < 24; i++) {
      final meio = (lo + hi) / 2;
      if (f(meio).sign == sinalLo) {
        lo = meio;
      } else {
        hi = meio;
      }
    }
    return (lo + hi) / 2;
  }

  /// Julian Day (UT) de volta para DateTime UTC.
  ///
  /// JD 2440587.5 é 1970-01-01T00:00Z — a época do Unix.
  @visibleForTesting
  static DateTime paraData(double jd) => DateTime.fromMillisecondsSinceEpoch(
        ((jd - 2440587.5) * Duration.millisecondsPerDay).round(),
        isUtc: true,
      );
}
