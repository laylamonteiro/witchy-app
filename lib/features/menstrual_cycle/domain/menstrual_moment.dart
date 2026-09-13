import '../../grimoire/data/models/spell_model.dart';
import '../../lunar/presentation/providers/lunar_provider.dart';
import 'lunar_comparison.dart';
import 'menstrual_day.dart';
import 'menstrual_shortcut.dart';

/// O momento em que ela está, para a seção "Práticas para este momento".
///
/// Duas informações, e só duas: **ela marcou sangue hoje?** e **qual é a Lua
/// de hoje?**
///
/// As duas são dado INSERIDO ou público, nunca derivado:
///
/// * o sangramento vem da marca que ela escolheu para o dia de hoje — não de
///   uma projeção do histórico, de uma média nem de uma estimativa. Nada
///   nesta área é calculado a partir do histórico: dia do ciclo, duração,
///   média e próxima data não existem, e não é por falta de plano — é por
///   decisão;
/// * a Lua é a mesma do calendário lunar do app, que já aparece para todo
///   mundo nesta página.
///
/// Daqui não sai diagnóstico, previsão nem frase de causa. O que sai é uma
/// lista de portas para ferramentas que já existem, e — quando as duas pontas
/// falam da mesma coisa — uma correspondência simbólica oferecida como
/// possibilidade.
class MenstrualMoment {
  const MenstrualMoment({
    required this.day,
    required this.phase,
    required this.bleeding,
  });

  /// Lê o momento a partir do histórico que a tela já tem em mãos.
  ///
  /// Não consulta repositório nem provider: quem monta decide o que ele vê, e
  /// o teste o monta sozinho — a mesma regra de [LunarComparison].
  factory MenstrualMoment.of({
    required DateTime today,
    required Iterable<MenstrualDay> history,
  }) {
    final at = DateTime(today.year, today.month, today.day);
    final key = MenstrualDay.keyOf(at);
    var bleeding = false;
    for (final day in history) {
      if (day.deleted || day.dayKey != key) continue;
      bleeding = day.mark == MenstrualMark.start ||
          day.mark == MenstrualMark.flow ||
          day.mark == MenstrualMark.spotting;
    }
    return MenstrualMoment(
      day: at,
      // O meio-dia local é a convenção de cálculo de toda a área.
      phase: LunarProvider.phaseOn(LunarComparison.noonOf(at)),
      bleeding: bleeding,
    );
  }

  final DateTime day;

  /// A Lua estimada para hoje.
  final MoonPhase phase;

  /// Ela marcou sangue hoje (começo, fluxo ou escape)?
  final bool bleeding;

  /// As Luas que a magia lunar costuma associar a recolhimento e fim.
  static const closingPhases = {
    MoonPhase.waningGibbous,
    MoonPhase.lastQuarter,
    MoonPhase.waningCrescent,
  };

  /// Sangramento e Lua que recolhe compartilham uma correspondência
  /// simbólica de encerramento. É o único cruzamento que a tela oferece, e
  /// ele é oferecido como possibilidade — nunca como estado dela.
  bool get sharesClosing => bleeding && closingPhases.contains(phase);

  /// Os atalhos deste momento, na ordem em que aparecem.
  ///
  /// Sangrando, o convite é de encerramento e escuta; fora disso, de começo.
  /// As práticas fecham a lista nos dois casos: elas são desta funcionalidade
  /// e estão sempre disponíveis.
  List<MenstrualShortcut> get shortcuts => bleeding
      ? const [
          MenstrualShortcut.release,
          MenstrualShortcut.oracle,
          MenstrualShortcut.dream,
          MenstrualShortcut.practices,
        ]
      : const [
          MenstrualShortcut.cultivate,
          MenstrualShortcut.intention,
          MenstrualShortcut.dream,
          MenstrualShortcut.practices,
        ];
}
