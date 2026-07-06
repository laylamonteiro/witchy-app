import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/enums.dart';

void main() {
  group('Planet', () {
    test('all planets have displayName', () {
      for (final planet in Planet.values) {
        expect(planet.displayName, isNotEmpty);
      }
    });

    test('all planets have symbol', () {
      for (final planet in Planet.values) {
        expect(planet.symbol, isNotEmpty);
      }
    });

    test('swephId values are unique except south/north node', () {
      final ids = <int>{};
      for (final planet in Planet.values) {
        if (planet != Planet.southNode) {
          expect(ids.add(planet.swephId), isTrue,
              reason: '${planet.name} has duplicate swephId');
        }
      }
      expect(Planet.southNode.swephId, Planet.northNode.swephId);
    });
  });

  group('ZodiacSign', () {
    test('all signs have displayName', () {
      for (final sign in ZodiacSign.values) {
        expect(sign.displayName, isNotEmpty);
      }
    });

    test('all signs have symbol', () {
      for (final sign in ZodiacSign.values) {
        expect(sign.symbol, isNotEmpty);
      }
    });

    test('all signs have element', () {
      for (final sign in ZodiacSign.values) {
        expect(Element.values.contains(sign.element), isTrue);
      }
    });

    test('all signs have modality', () {
      for (final sign in ZodiacSign.values) {
        expect(Modality.values.contains(sign.modality), isTrue);
      }
    });

    test('element distribution: 3 fire, 3 earth, 3 air, 3 water', () {
      final elementCounts = <Element, int>{};
      for (final sign in ZodiacSign.values) {
        elementCounts[sign.element] =
            (elementCounts[sign.element] ?? 0) + 1;
      }
      expect(elementCounts[Element.fire], 3);
      expect(elementCounts[Element.earth], 3);
      expect(elementCounts[Element.air], 3);
      expect(elementCounts[Element.water], 3);
    });

    test('modality distribution: 4 cardinal, 4 fixed, 4 mutable', () {
      final modalityCounts = <Modality, int>{};
      for (final sign in ZodiacSign.values) {
        modalityCounts[sign.modality] =
            (modalityCounts[sign.modality] ?? 0) + 1;
      }
      expect(modalityCounts[Modality.cardinal], 4);
      expect(modalityCounts[Modality.fixed], 4);
      expect(modalityCounts[Modality.mutable], 4);
    });

    group('fromLongitude', () {
      test('0 degrees is Aries', () {
        expect(ZodiacSign.fromLongitude(0), ZodiacSign.aries);
      });

      test('30 degrees is Taurus', () {
        expect(ZodiacSign.fromLongitude(30), ZodiacSign.taurus);
      });

      test('59.9 degrees is still Taurus', () {
        expect(ZodiacSign.fromLongitude(59.9), ZodiacSign.taurus);
      });

      test('60 degrees is Gemini', () {
        expect(ZodiacSign.fromLongitude(60), ZodiacSign.gemini);
      });

      test('330 degrees is Pisces', () {
        expect(ZodiacSign.fromLongitude(330), ZodiacSign.pisces);
      });

      test('359 degrees is Pisces', () {
        expect(ZodiacSign.fromLongitude(359), ZodiacSign.pisces);
      });

      test('all 12 signs at exact boundaries', () {
        final expected = [
          ZodiacSign.aries,
          ZodiacSign.taurus,
          ZodiacSign.gemini,
          ZodiacSign.cancer,
          ZodiacSign.leo,
          ZodiacSign.virgo,
          ZodiacSign.libra,
          ZodiacSign.scorpio,
          ZodiacSign.sagittarius,
          ZodiacSign.capricorn,
          ZodiacSign.aquarius,
          ZodiacSign.pisces,
        ];
        for (int i = 0; i < 12; i++) {
          expect(ZodiacSign.fromLongitude(i * 30.0), expected[i]);
        }
      });
    });

    test('specific fire signs', () {
      expect(ZodiacSign.aries.element, Element.fire);
      expect(ZodiacSign.leo.element, Element.fire);
      expect(ZodiacSign.sagittarius.element, Element.fire);
    });

    test('specific cardinal signs', () {
      expect(ZodiacSign.aries.modality, Modality.cardinal);
      expect(ZodiacSign.cancer.modality, Modality.cardinal);
      expect(ZodiacSign.libra.modality, Modality.cardinal);
      expect(ZodiacSign.capricorn.modality, Modality.cardinal);
    });
  });

  group('Element', () {
    test('all elements have displayName', () {
      for (final elem in Element.values) {
        expect(elem.displayName, isNotEmpty);
      }
    });

    test('all elements have symbol', () {
      for (final elem in Element.values) {
        expect(elem.symbol, isNotEmpty);
      }
    });

    test('all elements have magicalDescription', () {
      for (final elem in Element.values) {
        expect(elem.magicalDescription, isNotEmpty);
      }
    });
  });

  group('Modality', () {
    test('all modalities have displayName', () {
      for (final mod in Modality.values) {
        expect(mod.displayName, isNotEmpty);
      }
    });

    test('all modalities have description', () {
      for (final mod in Modality.values) {
        expect(mod.description, isNotEmpty);
      }
    });
  });

  group('AspectType', () {
    test('all types have displayName', () {
      for (final type in AspectType.values) {
        expect(type.displayName, isNotEmpty);
      }
    });

    test('angle values', () {
      expect(AspectType.conjunction.angle, 0);
      expect(AspectType.sextile.angle, 60);
      expect(AspectType.square.angle, 90);
      expect(AspectType.trine.angle, 120);
      expect(AspectType.opposition.angle, 180);
    });

    test('orb values are positive', () {
      for (final type in AspectType.values) {
        expect(type.orb, greaterThan(0));
      }
    });

    test('maxOrb equals orb', () {
      for (final type in AspectType.values) {
        expect(type.maxOrb, type.orb);
      }
    });

    test('isHarmonious', () {
      expect(AspectType.trine.isHarmonious, isTrue);
      expect(AspectType.sextile.isHarmonious, isTrue);
      expect(AspectType.square.isHarmonious, isFalse);
      expect(AspectType.opposition.isHarmonious, isFalse);
      expect(AspectType.conjunction.isHarmonious, isFalse);
    });

    test('isChallenging', () {
      expect(AspectType.square.isChallenging, isTrue);
      expect(AspectType.opposition.isChallenging, isTrue);
      expect(AspectType.trine.isChallenging, isFalse);
      expect(AspectType.sextile.isChallenging, isFalse);
      expect(AspectType.conjunction.isChallenging, isFalse);
    });
  });

  group('EnergyLevel', () {
    test('all levels have displayName', () {
      for (final level in EnergyLevel.values) {
        expect(level.displayName, isNotEmpty);
      }
    });

    test('all levels have symbol', () {
      for (final level in EnergyLevel.values) {
        expect(level.symbol, isNotEmpty);
      }
    });
  });
}
