import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/planet_position_model.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/house_model.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/aspect_model.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/enums.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/transit_model.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/magical_profile_model.dart';

void main() {
  group('PlanetPosition', () {
    late PlanetPosition position;

    setUp(() {
      position = const PlanetPosition(
        planet: Planet.sun,
        sign: ZodiacSign.aries,
        degree: 15,
        minute: 30,
        houseNumber: 1,
        isRetrograde: false,
        longitude: 15.5,
        speed: 1.0,
      );
    });

    test('positionString format', () {
      expect(position.positionString, contains('15'));
      expect(position.positionString, contains('30'));
    });

    test('fullDescription includes retrograde indicator', () {
      const retrograde = PlanetPosition(
        planet: Planet.mercury,
        sign: ZodiacSign.virgo,
        degree: 10,
        minute: 15,
        houseNumber: 6,
        isRetrograde: true,
        longitude: 160.25,
        speed: -0.5,
      );
      expect(retrograde.fullDescription, contains('\u211E'));
    });

    test('fullDescription omits retrograde when not retrograde', () {
      expect(position.fullDescription, isNot(contains('\u211E')));
    });

    group('JSON serialization', () {
      test('round-trip preserves all fields', () {
        final json = position.toJson();
        final restored = PlanetPosition.fromJson(json);

        expect(restored.planet, position.planet);
        expect(restored.sign, position.sign);
        expect(restored.degree, position.degree);
        expect(restored.minute, position.minute);
        expect(restored.houseNumber, position.houseNumber);
        expect(restored.isRetrograde, position.isRetrograde);
        expect(restored.longitude, position.longitude);
        expect(restored.speed, position.speed);
      });
    });
  });

  group('House', () {
    late House house;

    setUp(() {
      house = const House(
        number: 8,
        sign: ZodiacSign.scorpio,
        degree: 20,
        minute: 45,
        cuspLongitude: 230.75,
      );
    });

    test('meaning returns text for valid house numbers', () {
      for (int i = 1; i <= 12; i++) {
        final h = House(
          number: i,
          sign: ZodiacSign.aries,
          degree: 0,
          minute: 0,
          cuspLongitude: 0,
        );
        expect(h.meaning, isNotEmpty);
      }
    });

    test('meaning returns empty for invalid house number', () {
      const h = House(
        number: 13,
        sign: ZodiacSign.aries,
        degree: 0,
        minute: 0,
        cuspLongitude: 0,
      );
      expect(h.meaning, isEmpty);
    });

    test('magicalMeaning returns text for all 12 houses', () {
      for (int i = 1; i <= 12; i++) {
        final h = House(
          number: i,
          sign: ZodiacSign.aries,
          degree: 0,
          minute: 0,
          cuspLongitude: 0,
        );
        expect(h.magicalMeaning, isNotEmpty);
      }
    });

    test('cuspString includes sign symbol', () {
      expect(house.cuspString, contains(ZodiacSign.scorpio.symbol));
    });

    group('JSON serialization', () {
      test('round-trip preserves all fields', () {
        final json = house.toJson();
        final restored = House.fromJson(json);

        expect(restored.number, house.number);
        expect(restored.sign, house.sign);
        expect(restored.degree, house.degree);
        expect(restored.minute, house.minute);
        expect(restored.cuspLongitude, house.cuspLongitude);
      });
    });
  });

  group('Aspect', () {
    test('description format', () {
      const aspect = Aspect(
        planet1: Planet.sun,
        planet2: Planet.moon,
        type: AspectType.trine,
        exactAngle: 120.5,
        orb: 0.5,
      );
      expect(aspect.description, contains(Planet.sun.displayName));
      expect(aspect.description, contains(Planet.moon.displayName));
    });

    test('interpretation for harmonious aspect', () {
      const aspect = Aspect(
        planet1: Planet.sun,
        planet2: Planet.moon,
        type: AspectType.trine,
        exactAngle: 120,
        orb: 1.0,
      );
      expect(aspect.interpretation, contains('harmoniosa'));
    });

    test('interpretation for challenging aspect', () {
      const aspect = Aspect(
        planet1: Planet.sun,
        planet2: Planet.moon,
        type: AspectType.square,
        exactAngle: 90,
        orb: 2.0,
      );
      expect(aspect.interpretation, contains('desafiadora'));
    });

    test('magicalInterpretation for Sun-Moon aspect', () {
      const harmonious = Aspect(
        planet1: Planet.sun,
        planet2: Planet.moon,
        type: AspectType.trine,
        exactAngle: 120,
        orb: 1.0,
      );
      expect(harmonious.magicalInterpretation, contains('masculino'));

      const challenging = Aspect(
        planet1: Planet.sun,
        planet2: Planet.moon,
        type: AspectType.square,
        exactAngle: 90,
        orb: 2.0,
      );
      expect(challenging.magicalInterpretation, contains('ego'));
    });

    test('magicalInterpretation for Moon-Neptune aspect', () {
      const aspect = Aspect(
        planet1: Planet.moon,
        planet2: Planet.neptune,
        type: AspectType.trine,
        exactAngle: 120,
        orb: 1.0,
      );
      expect(aspect.magicalInterpretation, contains('intui'));
    });

    test('magicalInterpretation for Venus aspect', () {
      const aspect = Aspect(
        planet1: Planet.venus,
        planet2: Planet.jupiter,
        type: AspectType.sextile,
        exactAngle: 60,
        orb: 2.0,
      );
      expect(aspect.magicalInterpretation, contains('amor'));
    });

    test('magicalInterpretation for Mars aspect', () {
      const aspect = Aspect(
        planet1: Planet.mars,
        planet2: Planet.saturn,
        type: AspectType.trine,
        exactAngle: 120,
        orb: 3.0,
      );
      expect(aspect.magicalInterpretation, contains('prote'));
    });

    group('JSON serialization', () {
      test('round-trip preserves all fields', () {
        const aspect = Aspect(
          planet1: Planet.sun,
          planet2: Planet.moon,
          type: AspectType.conjunction,
          exactAngle: 5.0,
          orb: 5.0,
          isApplying: false,
        );
        final json = aspect.toJson();
        final restored = Aspect.fromJson(json);

        expect(restored.planet1, aspect.planet1);
        expect(restored.planet2, aspect.planet2);
        expect(restored.type, aspect.type);
        expect(restored.exactAngle, aspect.exactAngle);
        expect(restored.orb, aspect.orb);
        expect(restored.isApplying, aspect.isApplying);
      });
    });
  });

  group('Transit', () {
    test('formattedPosition includes planet and sign', () {
      const transit = Transit(
        planet: Planet.jupiter,
        sign: ZodiacSign.taurus,
        degree: 15.5,
        isRetrograde: false,
      );
      expect(transit.formattedPosition, contains('J'));
      expect(transit.formattedPosition, contains('Touro'));
    });

    test('JSON round-trip', () {
      const transit = Transit(
        planet: Planet.saturn,
        sign: ZodiacSign.pisces,
        degree: 12.3,
        isRetrograde: true,
      );
      final json = transit.toJson();
      final restored = Transit.fromJson(json);

      expect(restored.planet, transit.planet);
      expect(restored.sign, transit.sign);
      expect(restored.degree, transit.degree);
      expect(restored.isRetrograde, transit.isRetrograde);
    });
  });

  group('TransitAspect', () {
    test('isActive when orb is within maxOrb', () {
      const aspect = TransitAspect(
        transitPlanet: Planet.jupiter,
        natalPlanet: Planet.sun,
        aspectType: AspectType.trine,
        orb: 3.0,
        interpretation: 'Test',
        energyLevel: EnergyLevel.harmonious,
      );
      expect(aspect.isActive, isTrue);
    });

    test('isActive is false when orb exceeds maxOrb', () {
      const aspect = TransitAspect(
        transitPlanet: Planet.jupiter,
        natalPlanet: Planet.sun,
        aspectType: AspectType.sextile,
        orb: 7.0,
        interpretation: 'Test',
        energyLevel: EnergyLevel.low,
      );
      expect(aspect.isActive, isFalse);
    });

    test('JSON round-trip', () {
      const aspect = TransitAspect(
        transitPlanet: Planet.mars,
        natalPlanet: Planet.venus,
        aspectType: AspectType.conjunction,
        orb: 2.0,
        interpretation: 'Passionate energy',
        energyLevel: EnergyLevel.intense,
      );
      final json = aspect.toJson();
      final restored = TransitAspect.fromJson(json);

      expect(restored.transitPlanet, aspect.transitPlanet);
      expect(restored.natalPlanet, aspect.natalPlanet);
      expect(restored.aspectType, aspect.aspectType);
      expect(restored.orb, aspect.orb);
      expect(restored.interpretation, aspect.interpretation);
      expect(restored.energyLevel, aspect.energyLevel);
    });
  });

  group('DailyMagicalWeather', () {
    test('JSON and string round-trip', () {
      final weather = DailyMagicalWeather(
        date: DateTime(2024, 6, 15),
        transits: const [
          Transit(
            planet: Planet.sun,
            sign: ZodiacSign.gemini,
            degree: 25.0,
            isRetrograde: false,
          ),
        ],
        aspects: const [
          TransitAspect(
            transitPlanet: Planet.sun,
            natalPlanet: Planet.moon,
            aspectType: AspectType.trine,
            orb: 2.0,
            interpretation: 'Good day',
            energyLevel: EnergyLevel.harmonious,
          ),
        ],
        generalInterpretation: 'A good day for magic',
        recommendedPractices: ['Meditation', 'Crystal work'],
        energyKeywords: ['harmony', 'flow'],
        overallEnergy: EnergyLevel.harmonious,
        moonSign: ZodiacSign.cancer,
        moonPhase: 'Waxing Gibbous',
      );

      final jsonStr = weather.toJsonString();
      final restored = DailyMagicalWeather.fromJsonString(jsonStr);

      expect(restored.date, weather.date);
      expect(restored.transits.length, 1);
      expect(restored.aspects.length, 1);
      expect(restored.generalInterpretation, weather.generalInterpretation);
      expect(restored.recommendedPractices, weather.recommendedPractices);
      expect(restored.energyKeywords, weather.energyKeywords);
      expect(restored.overallEnergy, weather.overallEnergy);
      expect(restored.moonSign, weather.moonSign);
      expect(restored.moonPhase, weather.moonPhase);
    });
  });

  group('MagicalProfile', () {
    test('JSON and string round-trip', () {
      final profile = MagicalProfile(
        userId: 'user-1',
        birthChartId: 'chart-1',
        dominantElement: Element.water,
        elementDistribution: {
          Element.fire: 1,
          Element.earth: 2,
          Element.air: 1,
          Element.water: 3,
        },
        dominantModality: Modality.fixed,
        modalityDistribution: {
          Modality.cardinal: 2,
          Modality.fixed: 3,
          Modality.mutable: 2,
        },
        magicalEssence: 'Deep intuition',
        intuitiveGifts: 'Dreams and visions',
        communicationStyle: 'Empathic',
        loveAndBeauty: 'Romantic',
        protectiveEnergy: 'Fierce',
        houseOfMagic: 'Scorpio',
        houseOfSpirit: 'Pisces',
        magicalStrengths: ['Intuition', 'Healing'],
        recommendedPractices: ['Moon rituals', 'Water magic'],
        favorableTools: ['Moonstone', 'Silver'],
        shadowWork: ['Emotional boundaries'],
        generatedAt: DateTime(2024, 6, 15),
        aiGeneratedText: 'AI text',
        chartHash: 'abc123',
      );

      final jsonStr = profile.toJsonString();
      final restored = MagicalProfile.fromJsonString(jsonStr);

      expect(restored.userId, profile.userId);
      expect(restored.dominantElement, Element.water);
      expect(restored.elementDistribution[Element.water], 3);
      expect(restored.dominantModality, Modality.fixed);
      expect(restored.magicalStrengths, profile.magicalStrengths);
      expect(restored.aiGeneratedText, 'AI text');
      expect(restored.chartHash, 'abc123');
    });

    test('copyWith updates specific fields', () {
      final profile = MagicalProfile(
        userId: 'user-1',
        birthChartId: 'chart-1',
        dominantElement: Element.fire,
        elementDistribution: {Element.fire: 4},
        dominantModality: Modality.cardinal,
        modalityDistribution: {Modality.cardinal: 4},
        magicalEssence: 'Original',
        intuitiveGifts: 'Original',
        communicationStyle: 'Original',
        loveAndBeauty: 'Original',
        protectiveEnergy: 'Original',
        houseOfMagic: 'Original',
        houseOfSpirit: 'Original',
        magicalStrengths: [],
        recommendedPractices: [],
        favorableTools: [],
        shadowWork: [],
        generatedAt: DateTime(2024, 1, 1),
      );

      final updated = profile.copyWith(
        magicalEssence: 'Updated',
        aiGeneratedText: 'New AI text',
      );
      expect(updated.magicalEssence, 'Updated');
      expect(updated.aiGeneratedText, 'New AI text');
      expect(updated.userId, 'user-1');
    });
  });

  group('PersonalizedSuggestion', () {
    test('JSON and string round-trip', () {
      final suggestion = PersonalizedSuggestion(
        id: 'sug-1',
        date: DateTime(2024, 6, 15),
        title: 'Moon ritual',
        description: 'Perform a moon ritual tonight',
        practices: ['Meditation', 'Crystal cleansing'],
        relevantAspects: const [
          TransitAspect(
            transitPlanet: Planet.moon,
            natalPlanet: Planet.neptune,
            aspectType: AspectType.trine,
            orb: 1.5,
            interpretation: 'Psychic energy',
            energyLevel: EnergyLevel.high,
          ),
        ],
        priority: EnergyLevel.high,
        category: 'ritual',
      );

      final jsonStr = suggestion.toJsonString();
      final restored = PersonalizedSuggestion.fromJsonString(jsonStr);

      expect(restored.id, suggestion.id);
      expect(restored.title, suggestion.title);
      expect(restored.practices, suggestion.practices);
      expect(restored.relevantAspects.length, 1);
      expect(restored.priority, EnergyLevel.high);
      expect(restored.category, 'ritual');
    });
  });
}
