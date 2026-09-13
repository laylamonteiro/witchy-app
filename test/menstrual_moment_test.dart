import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/models/spell_model.dart';
import 'package:grimorio_de_bolso/features/lunar/presentation/providers/lunar_provider.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/lunar_comparison.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_day.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_moment.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_shortcut.dart';

/// O momento que "Práticas para este momento" lê, e a contagem de Luas dos
/// começos.
///
/// As duas coisas saem SÓ do que ela marcou. Nada aqui projeta, estima ou
/// prevê — e é por isso que a seção não passa pelo gate do Premium, que cobre
/// resultado calculado a partir do histórico (dia do ciclo, duração, média,
/// próxima data).
void main() {
  MenstrualDay dia(DateTime day, MenstrualMark mark) =>
      MenstrualDay(userId: 'ela', day: day, mark: mark);

  group('MenstrualMoment', () {
    final hoje = DateTime(2026, 3, 12);

    test('sem registro nenhum, hoje não é dia de sangue', () {
      final momento = MenstrualMoment.of(today: hoje, history: const []);
      expect(momento.bleeding, isFalse);
      expect(momento.sharesClosing, isFalse);
      expect(momento.shortcuts, contains(MenstrualShortcut.cultivate));
      expect(momento.shortcuts, isNot(contains(MenstrualShortcut.release)));
    });

    test('começo, fluxo e escape são dias de sangue; fim e anotação não', () {
      for (final mark in [
        MenstrualMark.start,
        MenstrualMark.flow,
        MenstrualMark.spotting,
      ]) {
        final momento =
            MenstrualMoment.of(today: hoje, history: [dia(hoje, mark)]);
        expect(momento.bleeding, isTrue, reason: mark.name);
        expect(momento.shortcuts, contains(MenstrualShortcut.release),
            reason: mark.name);
      }
      for (final mark in [MenstrualMark.end, MenstrualMark.note]) {
        final momento =
            MenstrualMoment.of(today: hoje, history: [dia(hoje, mark)]);
        expect(momento.bleeding, isFalse, reason: mark.name);
      }
    });

    test('um dia apagado não faz de hoje um dia de sangue', () {
      final apagado = dia(hoje, MenstrualMark.flow)
          .copyWith(deleted: true, revision: 2);
      final momento = MenstrualMoment.of(today: hoje, history: [apagado]);
      expect(momento.bleeding, isFalse);
    });

    test('o sangue de ontem não é o de hoje', () {
      final momento = MenstrualMoment.of(
        today: hoje,
        history: [dia(hoje.subtract(const Duration(days: 1)), MenstrualMark.flow)],
      );
      expect(momento.bleeding, isFalse);
    });

    test('as práticas estão sempre na lista, sangrando ou não', () {
      expect(
        MenstrualMoment.of(today: hoje, history: const []).shortcuts,
        contains(MenstrualShortcut.practices),
      );
      expect(
        MenstrualMoment.of(today: hoje, history: [dia(hoje, MenstrualMark.flow)])
            .shortcuts,
        contains(MenstrualShortcut.practices),
      );
    });

    test('a correspondência de encerramento pede as DUAS pontas', () {
      // Um dia de Lua que recolhe, achado pelo próprio calendário do app para
      // não depender de uma data escolhida à mão.
      DateTime? minguante;
      for (var i = 0; i < 40; i++) {
        final candidato = DateTime(2026, 3, 1).add(Duration(days: i));
        if (MenstrualMoment.closingPhases
            .contains(LunarProvider.phaseOn(LunarComparison.noonOf(candidato)))) {
          minguante = candidato;
          break;
        }
      }
      expect(minguante, isNotNull, reason: 'um mês tem Lua que recolhe');

      // Sangrando + Lua que recolhe: a correspondência é oferecida.
      expect(
        MenstrualMoment.of(
          today: minguante!,
          history: [dia(minguante, MenstrualMark.flow)],
        ).sharesClosing,
        isTrue,
      );
      // A mesma Lua, sem sangue: nada é dito. É melhor calar do que inventar
      // um encontro que não aconteceu.
      expect(
        MenstrualMoment.of(today: minguante, history: const []).sharesClosing,
        isFalse,
      );
    });
  });

  group('A Lua que se repete entre os começos', () {
    /// Começos de Cheia em Cheia — os mesmos do teste do domínio lunar.
    final cheias = [
      DateTime(2024, 11, 16),
      DateTime(2024, 12, 15),
      DateTime(2025, 1, 14),
      DateTime(2025, 2, 12),
    ];

    test('antes de quatro começos não há padrão a observar', () {
      for (var n = 0; n < LunarComparison.minimumStarts; n++) {
        final dias = [
          for (final start in cheias.take(n)) dia(start, MenstrualMark.start),
        ];
        expect(LunarComparison.phaseTally(dias), isNull, reason: '$n começos');
      }
    });

    test('quatro começos na mesma Lua viram uma contagem', () {
      final dias = [for (final start in cheias) dia(start, MenstrualMark.start)];
      final tally = LunarComparison.phaseTally(dias);
      expect(tally, isNotNull);
      expect(tally!.phase, MoonPhase.fullMoon);
      expect(tally.count, 4);
      expect(tally.total, 4);
    });

    test('a contagem entra no relatório que o card lê', () {
      final dias = [for (final start in cheias) dia(start, MenstrualMark.start)];
      final report =
          LunarComparison.report(dias, today: DateTime(2025, 3, 1));
      expect(report.tally?.phase, MoonPhase.fullMoon);
      expect(report.latestStart?.day, cheias.last);
    });

    test('sem começo nenhum não há último começo nem contagem', () {
      final report = LunarComparison.report(const [], today: DateTime(2025, 3, 1));
      expect(report.latestStart, isNull);
      expect(report.tally, isNull);
    });
  });
}
