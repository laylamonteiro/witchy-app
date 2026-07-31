import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/guided_rituals/data/models/guided_rituals_data.dart';
import 'package:grimorio_de_bolso/features/guided_rituals/data/models/guided_rituals_en.dart';
import 'package:grimorio_de_bolso/features/guided_rituals/data/models/guided_rituals_es.dart';
import 'package:grimorio_de_bolso/features/guided_rituals/data/models/guided_rituals_pt.dart';
import 'package:grimorio_de_bolso/features/guided_rituals/data/models/magical_moment_data.dart';
import 'package:grimorio_de_bolso/features/guided_rituals/data/models/magical_moment_en.dart';
import 'package:grimorio_de_bolso/features/guided_rituals/data/models/magical_moment_es.dart';
import 'package:grimorio_de_bolso/features/guided_rituals/data/models/magical_moment_pt.dart';

/// Paridade PT/EN/ES do conteúdo dos rituais guiados e do Momento Mágico.
/// Segue o padrão dos demais testes de paridade (content_parity_test.dart).
void main() {
  final allIds = AllGuidedRituals.all.map((r) => r.id).toSet();

  group('AllGuidedRituals', () {
    test('ids são únicos', () {
      expect(allIds.length, AllGuidedRituals.all.length);
    });

    test('todo sabbat tem exatamente um ritual', () {
      final sabbats = AllGuidedRituals.all
          .where((r) => r.sabbat != null)
          .map((r) => r.sabbat)
          .toList();
      expect(sabbats.toSet().length, sabbats.length);
      expect(sabbats.length, 8);
    });

    test('byId resolve todos os ids e rejeita desconhecidos', () {
      for (final id in allIds) {
        expect(AllGuidedRituals.byId(id), isNotNull, reason: id);
      }
      expect(AllGuidedRituals.byId('nao_existe'), isNull);
    });
  });

  group('Paridade de textos dos rituais', () {
    test('textos principais cobrem todos os rituais nos 3 idiomas', () {
      for (final map in [
        guidedRitualTextsPt,
        guidedRitualTextsEn,
        guidedRitualTextsEs
      ]) {
        expect(map.keys.toSet(), allIds);
        for (final entry in map.entries) {
          expect(entry.value.title, isNotEmpty, reason: entry.key);
          expect(entry.value.intro, isNotEmpty, reason: entry.key);
          expect(entry.value.timing, isNotEmpty, reason: entry.key);
        }
      }
    });

    test('passos cobrem todos os rituais com a mesma contagem por idioma', () {
      expect(guidedRitualStepsPt.keys.toSet(), allIds);
      expect(guidedRitualStepsEn.keys.toSet(), allIds);
      expect(guidedRitualStepsEs.keys.toSet(), allIds);
      for (final id in allIds) {
        final pt = guidedRitualStepsPt[id]!;
        expect(pt.length, greaterThanOrEqualTo(5),
            reason: '$id deve ter pelo menos 5 passos');
        expect(guidedRitualStepsEn[id]!.length, pt.length, reason: id);
        expect(guidedRitualStepsEs[id]!.length, pt.length, reason: id);
        for (final step in pt) {
          expect(step.title, isNotEmpty);
          expect(step.description, isNotEmpty);
        }
      }
    });

    test('materiais têm as mesmas chaves nos 3 idiomas', () {
      expect(guidedRitualMaterialsEn.keys.toSet(),
          guidedRitualMaterialsPt.keys.toSet());
      expect(guidedRitualMaterialsEs.keys.toSet(),
          guidedRitualMaterialsPt.keys.toSet());
      for (final id in guidedRitualMaterialsPt.keys) {
        expect(guidedRitualMaterialsEn[id]!.length,
            guidedRitualMaterialsPt[id]!.length,
            reason: id);
        expect(guidedRitualMaterialsEs[id]!.length,
            guidedRitualMaterialsPt[id]!.length,
            reason: id);
      }
    });

    test('usos e correspondências têm as mesmas chaves nos 3 idiomas', () {
      expect(guidedRitualUsesEn.keys.toSet(), guidedRitualUsesPt.keys.toSet());
      expect(guidedRitualUsesEs.keys.toSet(), guidedRitualUsesPt.keys.toSet());
      expect(guidedRitualCrystalsEn.keys.toSet(),
          guidedRitualCrystalsPt.keys.toSet());
      expect(guidedRitualCrystalsEs.keys.toSet(),
          guidedRitualCrystalsPt.keys.toSet());
      expect(
          guidedRitualHerbsEn.keys.toSet(), guidedRitualHerbsPt.keys.toSet());
      expect(
          guidedRitualHerbsEs.keys.toSet(), guidedRitualHerbsPt.keys.toSet());
    });

    test('águas mágicas têm lista de usos', () {
      expect(guidedRitualUsesPt['moon_water'], isNotEmpty);
      expect(guidedRitualUsesPt['sun_water'], isNotEmpty);
    });

    test('getters do modelo resolvem sem erro para todos os rituais', () {
      for (final ritual in AllGuidedRituals.all) {
        expect(ritual.title, isNotEmpty, reason: ritual.id);
        expect(ritual.steps, isNotEmpty, reason: ritual.id);
        // Correspondências: sabbats vêm da Roda do Ano, demais das listas locais.
        expect(ritual.crystals, isNotEmpty, reason: ritual.id);
        expect(ritual.herbs, isNotEmpty, reason: ritual.id);
      }
    });
  });

  group('Momento Mágico', () {
    test('dias da semana 1–7 cobertos nos 3 idiomas', () {
      final weekdays = {for (var d = 1; d <= 7; d++) d};
      for (final map in [weekdayTextsPt, weekdayTextsEn, weekdayTextsEs]) {
        expect(map.keys.toSet(), weekdays);
        for (final entry in map.entries) {
          expect(entry.value.theme, isNotEmpty, reason: '${entry.key}');
          expect(entry.value.goodFor, isNotEmpty, reason: '${entry.key}');
          expect(entry.value.suggestion, isNotEmpty, reason: '${entry.key}');
        }
      }
    });

    test('períodos do dia cobertos nos 3 idiomas', () {
      for (final map in [dayPeriodTextsPt, dayPeriodTextsEn, dayPeriodTextsEs]) {
        expect(map.keys.toSet(), DayPeriod.values.toSet());
        for (final entry in map.entries) {
          expect(entry.value.title, isNotEmpty, reason: '${entry.key}');
          expect(entry.value.goodFor, isNotEmpty, reason: '${entry.key}');
        }
      }
    });

    test('toda hora 0–23 mapeia para um período', () {
      for (var hour = 0; hour < 24; hour++) {
        expect(() => DayPeriod.fromHour(hour), returnsNormally);
      }
    });

    test('MagicalMoment.of resolve para qualquer dia da semana', () {
      for (var d = 0; d < 7; d++) {
        final when = DateTime(2026, 1, 5 + d, 12); // 2026-01-05 é segunda
        final moment = MagicalMoment.of(when);
        expect(moment.day.planetName, isNotEmpty);
        expect(moment.day.planetEmoji, isNotEmpty);
        expect(moment.period.title, isNotEmpty);
      }
    });
  });
}
