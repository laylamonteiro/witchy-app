import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/planet_sign_interpretations_en.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/planet_sign_interpretations_es.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/planet_sign_interpretations_pt.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/enums.dart';

/// Garante que as variantes pt/en/es das interpretações planeta-signo têm as
/// mesmas chaves (`'<planeta>_<signo>'`) e que as funções de template cobrem
/// todos os planetas e signos nas três línguas.
void main() {
  group('Interpretações planeta-signo', () {
    test('as três línguas têm 60 chaves idênticas (5 planetas × 12 signos)',
        () {
      expect(planetSignInterpretationsPt.length, 60);
      expect(planetSignInterpretationsEn.keys.toList(),
          planetSignInterpretationsPt.keys.toList());
      expect(planetSignInterpretationsEs.keys.toList(),
          planetSignInterpretationsPt.keys.toList());
    });

    test('as chaves seguem o padrão planeta_signo com nomes de enum válidos',
        () {
      final planetNames = Planet.values.map((p) => p.name).toSet();
      final signNames = ZodiacSign.values.map((s) => s.name).toSet();
      for (final key in planetSignInterpretationsPt.keys) {
        final parts = key.split('_');
        expect(parts.length, 2, reason: key);
        expect(planetNames, contains(parts[0]), reason: key);
        expect(signNames, contains(parts[1]), reason: key);
      }
    });

    test('todos os valores são não vazios nas três línguas', () {
      for (final map in [
        planetSignInterpretationsPt,
        planetSignInterpretationsEn,
        planetSignInterpretationsEs,
      ]) {
        for (final entry in map.entries) {
          expect(entry.value.trim(), isNotEmpty, reason: entry.key);
        }
      }
    });

    test(
        'as funções de interpretação padrão cobrem todos os planetas e signos',
        () {
      for (final planet in Planet.values) {
        for (final sign in ZodiacSign.values) {
          for (final fn in [
            planetSignDefaultInterpretationPt,
            planetSignDefaultInterpretationEn,
            planetSignDefaultInterpretationEs,
          ]) {
            final text = fn(planet, sign);
            expect(text.trim(), isNotEmpty,
                reason: '${planet.name}_${sign.name}');
            expect(text, isNot(contains('null')),
                reason: '${planet.name}_${sign.name}');
          }
        }
      }
    });

    test('as funções de resumo curto cobrem todos os planetas e signos', () {
      for (final planet in Planet.values) {
        for (final sign in ZodiacSign.values) {
          for (final fn in [
            planetSignShortInterpretationPt,
            planetSignShortInterpretationEn,
            planetSignShortInterpretationEs,
          ]) {
            final text = fn(planet, sign);
            expect(text.trim(), isNotEmpty,
                reason: '${planet.name}_${sign.name}');
            expect(text, isNot(contains('null')),
                reason: '${planet.name}_${sign.name}');
          }
        }
      }
    });
  });
}
