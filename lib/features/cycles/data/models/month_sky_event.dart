import '../../../astrology/data/models/enums.dart';

/// O que acontece no céu neste mês.
enum MonthSkyKind {
  /// Lua nova: o começo de um ciclo lunar.
  newMoon,

  /// Lua cheia: o ponto alto dele.
  fullMoon,

  /// O Sol muda de signo — a virada de estação do mês.
  sunIngress,

  /// Um planeta começa a retrogradar.
  retrogradeStart,

  /// Um planeta volta a andar para a frente.
  retrogradeEnd,
}

/// Um evento do céu do mês, com data exata.
///
/// Sai do efeméride, não da média do ciclo lunar: uma seção que NOMEIA datas
/// não pode errar o dia, e a conta média chega a desviar meio dia da lua
/// nova verdadeira.
class MonthSkyEvent {
  const MonthSkyEvent({
    required this.kind,
    required this.instanteUtc,
    this.signo,
    this.planeta,
  });

  final MonthSkyKind kind;

  /// Sempre em UTC; a tela converte para o fuso do aparelho.
  final DateTime instanteUtc;

  /// O signo em que o evento acontece (lunações e ingresso do Sol).
  final ZodiacSign? signo;

  /// O planeta envolvido (retrogradações).
  final Planet? planeta;

  bool get ehLunacao =>
      kind == MonthSkyKind.newMoon || kind == MonthSkyKind.fullMoon;
}
