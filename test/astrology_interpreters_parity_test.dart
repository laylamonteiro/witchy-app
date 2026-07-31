import 'dart:ui' show Locale;

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/magical_interpreter_texts.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/magical_interpreter_texts_en.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/magical_interpreter_texts_es.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/magical_interpreter_texts_pt.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/planet_sign_interpretations.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/transit_interpreter_texts.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/transit_interpreter_texts_en.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/transit_interpreter_texts_es.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/transit_interpreter_texts_pt.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/aspect_model.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/birth_chart_model.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/enums.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/house_model.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/planet_position_model.dart';
import 'package:grimorio_de_bolso/features/astrology/data/services/magical_interpreter.dart';

/// Paridade pt/en/es dos geradores de texto de astrologia
/// (magical_interpreter, transit_interpreter e os templates padrão dos pontos
/// místicos em planet_sign_interpretations): mesmas chaves nas três línguas e
/// saídas não vazias exercitando as funções públicas em cada locale.
void main() {
  const locales = {
    'pt': Locale('pt', 'BR'),
    'en': Locale('en', 'US'),
    'es': Locale('es', 'ES'),
  };

  final magicalByLang = {
    'pt': magicalInterpreterTextsPt,
    'en': magicalInterpreterTextsEn,
    'es': magicalInterpreterTextsEs,
  };

  final transitByLang = {
    'pt': transitInterpreterTextsPt,
    'en': transitInterpreterTextsEn,
    'es': transitInterpreterTextsEs,
  };

  // Restaura o padrão do app após cada teste para não vazar estado global.
  tearDown(() {
    ContentLocale.instance.setLocale(const Locale('pt', 'BR'));
  });

  /// Executa [check] com cada locale ativo.
  void forEachLocale(void Function(String lang) check) {
    locales.forEach((lang, locale) {
      ContentLocale.instance.setLocale(locale);
      check(lang);
    });
  }

  group('MagicalInterpreterTexts — paridade pt/en/es', () {
    test('mapas por signo cobrem as mesmas chaves nas três línguas', () {
      final ptMoonKeys = magicalInterpreterTextsPt.moonBySign.keys.toSet();
      magicalByLang.forEach((lang, texts) {
        expect(texts.sunEssence.keys.toSet(), ZodiacSign.values.toSet(),
            reason: 'sunEssence [$lang]');
        expect(texts.moonBySign.keys.toSet(), ptMoonKeys,
            reason: 'moonBySign [$lang]');
      });
    });

    test('mapas por elemento cobrem todos os elementos nas três línguas', () {
      magicalByLang.forEach((lang, texts) {
        expect(texts.mercuryByElement.keys.toSet(), Element.values.toSet(),
            reason: 'mercuryByElement [$lang]');
        expect(texts.practicesByElement.keys.toSet(), Element.values.toSet(),
            reason: 'practicesByElement [$lang]');
        expect(texts.toolsByElement.keys.toSet(), Element.values.toSet(),
            reason: 'toolsByElement [$lang]');
      });
    });

    test('listas têm o mesmo tamanho nas três línguas', () {
      final pt = magicalInterpreterTextsPt;
      magicalByLang.forEach((lang, texts) {
        for (final element in Element.values) {
          expect(texts.practicesByElement[element]!.length,
              pt.practicesByElement[element]!.length,
              reason: 'practicesByElement[$element] [$lang]');
          expect(texts.toolsByElement[element]!.length,
              pt.toolsByElement[element]!.length,
              reason: 'toolsByElement[$element] [$lang]');
        }
        expect(texts.practicesHouse8.length, pt.practicesHouse8.length,
            reason: 'practicesHouse8 [$lang]');
        expect(texts.practicesHouse12.length, pt.practicesHouse12.length,
            reason: 'practicesHouse12 [$lang]');
      });
    });

    test('todos os textos e templates são não vazios nas três línguas', () {
      magicalByLang.forEach((lang, texts) {
        void check(String label, String value) {
          expect(value.trim(), isNotEmpty, reason: '$label [$lang]');
          expect(value, isNot(contains('null')), reason: '$label [$lang]');
        }

        texts.sunEssence.forEach((sign, v) => check('sunEssence.$sign', v));
        texts.moonBySign.forEach((sign, v) => check('moonBySign.$sign', v));
        texts.mercuryByElement
            .forEach((el, v) => check('mercuryByElement.$el', v));
        for (final el in Element.values) {
          for (final v in texts.practicesByElement[el]!) {
            check('practicesByElement.$el', v);
          }
          for (final v in texts.toolsByElement[el]!) {
            check('toolsByElement.$el', v);
          }
        }
        for (final v in [
          ...texts.practicesHouse8,
          ...texts.practicesHouse12,
        ]) {
          check('practicesHouse', v);
        }

        check('moonIntro', texts.moonIntro('Leo', 8));
        check('moonByElement', texts.moonByElement('Fire'));
        check('venus', texts.venus('Libra', 'Air'));
        check('mars', texts.mars('Aries', 'Fire'));
        check('house8Intro', texts.house8Intro('Scorpio'));
        check('house8NoPlanets', texts.house8NoPlanets);
        check('house8WithPlanets', texts.house8WithPlanets(2, 'Moon, Pluto'));
        check('house8Moon', texts.house8Moon);
        check('house8Pluto', texts.house8Pluto);
        check('house12Intro', texts.house12Intro('Pisces'));
        check('house12NoPlanets', texts.house12NoPlanets);
        check('house12WithPlanets', texts.house12WithPlanets(1, 'Neptune'));
        check('house12Neptune', texts.house12Neptune);
        check('house12Moon', texts.house12Moon);
        check('strengthPsychicIntuition', texts.strengthPsychicIntuition);
        check('strengthSunMoonBalance', texts.strengthSunMoonBalance);
        check('strengthMagicAffinity', texts.strengthMagicAffinity);
        check(
            'strengthSpiritualConnection', texts.strengthSpiritualConnection);
        check('strengthDominantElement',
            texts.strengthDominantElement('Water'));
        check('sunCrystal', texts.sunCrystal('Leo'));
        check('moonHerb', texts.moonHerb('Cancer'));
        check('shadowSunMoon', texts.shadowSunMoon);
        check('shadowSaturn', texts.shadowSaturn);
        check('shadowHouse12', texts.shadowHouse12);
      });
    });
  });

  group('TransitInterpreterTexts — paridade pt/en/es', () {
    test('mapas por fase cobrem as chaves canônicas nas três línguas', () {
      final canonical = kMoonPhaseKeys.toSet();
      transitByLang.forEach((lang, texts) {
        expect(texts.phaseNames.keys.toSet(), canonical,
            reason: 'phaseNames [$lang]');
        expect(texts.phaseInterpretations.keys.toSet(), canonical,
            reason: 'phaseInterpretations [$lang]');
        expect(texts.phasePractices.keys.toSet(), canonical,
            reason: 'phasePractices [$lang]');
        expect(texts.phaseKeywords.keys.toSet(), canonical,
            reason: 'phaseKeywords [$lang]');
      });
    });

    test('palavras-chave por fase têm o mesmo tamanho nas três línguas', () {
      final pt = transitInterpreterTextsPt;
      transitByLang.forEach((lang, texts) {
        for (final key in kMoonPhaseKeys) {
          expect(texts.phaseKeywords[key]!.length,
              pt.phaseKeywords[key]!.length,
              reason: 'phaseKeywords[$key] [$lang]');
        }
        expect(texts.conjunctionPractices.length,
            pt.conjunctionPractices.length,
            reason: 'conjunctionPractices [$lang]');
        expect(texts.harmoniousPractices.length, pt.harmoniousPractices.length,
            reason: 'harmoniousPractices [$lang]');
        expect(texts.challengingPractices.length,
            pt.challengingPractices.length,
            reason: 'challengingPractices [$lang]');
        expect(texts.moonSuggestionPractices.length,
            pt.moonSuggestionPractices.length,
            reason: 'moonSuggestionPractices [$lang]');
      });
    });

    test('descrições de energia cobrem os níveis usados nas três línguas', () {
      const usedLevels = {
        EnergyLevel.intense,
        EnergyLevel.challenging,
        EnergyLevel.moderate,
        EnergyLevel.harmonious,
      };
      transitByLang.forEach((lang, texts) {
        expect(texts.energyDescriptions.keys.toSet(), usedLevels,
            reason: 'energyDescriptions [$lang]');
      });
    });

    test('todos os textos e templates são não vazios nas três línguas', () {
      transitByLang.forEach((lang, texts) {
        void check(String label, String value) {
          expect(value.trim(), isNotEmpty, reason: '$label [$lang]');
          expect(value, isNot(contains('null')), reason: '$label [$lang]');
        }

        texts.phaseNames.forEach((k, v) => check('phaseNames.$k', v));
        texts.phaseInterpretations
            .forEach((k, v) => check('phaseInterpretations.$k', v));
        texts.phasePractices.forEach((k, v) => check('phasePractices.$k', v));
        texts.phaseKeywords.forEach((k, words) {
          for (final w in words) {
            check('phaseKeywords.$k', w);
          }
        });
        texts.energyDescriptions
            .forEach((k, v) => check('energyDescriptions.$k', v));
        for (final v in [
          ...texts.conjunctionPractices,
          ...texts.harmoniousPractices,
          ...texts.challengingPractices,
          ...texts.moonSuggestionPractices,
        ]) {
          check('suggestionPractices', v);
        }

        check('phaseFallback', texts.phaseFallback);
        check('moonInSign', texts.moonInSign('Leo', 'expressive'));
        check('practiceIntenseDay', texts.practiceIntenseDay);
        check('practiceHarmoniousDay', texts.practiceHarmoniousDay);
        check('keywordIntensity', texts.keywordIntensity);
        check('keywordHarmony', texts.keywordHarmony);
        check('transitAspect', texts.transitAspect('Sun', '☌', 'Moon', 'x'));
        check('conjunctionTitle', texts.conjunctionTitle('Sun', 'Moon'));
        check('conjunctionDescription',
            texts.conjunctionDescription('Sun', 'Moon'));
        check('harmoniousTitle', texts.harmoniousTitle);
        check('harmoniousDescription',
            texts.harmoniousDescription('Sun', '△', 'Moon'));
        check('challengingTitle', texts.challengingTitle);
        check('challengingDescription',
            texts.challengingDescription('Quadratura', 'Sun', 'Moon'));
        check('moonSuggestionTitle', texts.moonSuggestionTitle('Cancer'));
        check('moonSuggestionDescription',
            texts.moonSuggestionDescription('Cancer', 'Water'));
      });
    });

    test('o seletor por locale devolve a variante correta', () {
      forEachLocale((lang) {
        expect(identical(transitInterpreterTexts, transitByLang[lang]), isTrue,
            reason: 'transitInterpreterTexts [$lang]');
        expect(identical(magicalInterpreterTexts, magicalByLang[lang]), isTrue,
            reason: 'magicalInterpreterTexts [$lang]');
      });
    });
  });

  group('MagicalInterpreter.interpretChart nos três locales', () {
    PlanetPosition pp(Planet planet, ZodiacSign sign, {int house = 1}) =>
        PlanetPosition(
          planet: planet,
          sign: sign,
          degree: 10,
          minute: 0,
          houseNumber: house,
          isRetrograde: false,
          longitude: sign.index * 30.0 + 10,
          speed: 1.0,
        );

    final chart = BirthChartModel(
      id: 'chart-test',
      userId: 'user-test',
      birthDate: DateTime(1990, 6, 15),
      birthTime: const TimeOfDay(hour: 12, minute: 0),
      birthPlace: 'Teste',
      latitude: 0,
      longitude: 0,
      timezone: 'UTC',
      planets: [
        pp(Planet.sun, ZodiacSign.leo, house: 5),
        // Gêmeos não tem texto lunar próprio -> exercita moonByElement.
        pp(Planet.moon, ZodiacSign.gemini, house: 8),
        pp(Planet.mercury, ZodiacSign.virgo, house: 6),
        pp(Planet.venus, ZodiacSign.libra, house: 7),
        pp(Planet.mars, ZodiacSign.aries, house: 1),
        pp(Planet.jupiter, ZodiacSign.sagittarius, house: 9),
        pp(Planet.saturn, ZodiacSign.capricorn, house: 10),
        pp(Planet.uranus, ZodiacSign.aquarius, house: 11),
        pp(Planet.neptune, ZodiacSign.pisces, house: 12),
        pp(Planet.pluto, ZodiacSign.scorpio, house: 8),
      ],
      houses: [
        for (var i = 1; i <= 12; i++)
          House(
            number: i,
            sign: ZodiacSign.values[(i - 1) % 12],
            degree: 0,
            minute: 0,
            cuspLongitude: (i - 1) * 30.0,
          ),
      ],
      aspects: const [
        Aspect(
          planet1: Planet.moon,
          planet2: Planet.neptune,
          type: AspectType.trine,
          exactAngle: 120,
          orb: 2,
        ),
        Aspect(
          planet1: Planet.sun,
          planet2: Planet.moon,
          type: AspectType.square,
          exactAngle: 90,
          orb: 3,
        ),
        Aspect(
          planet1: Planet.saturn,
          planet2: Planet.mars,
          type: AspectType.opposition,
          exactAngle: 180,
          orb: 1,
        ),
      ],
      calculatedAt: DateTime(2024, 1, 1),
    );

    test('gera perfil completo e não vazio em cada locale', () {
      forEachLocale((lang) {
        final profile = MagicalInterpreter.instance.interpretChart(chart);

        for (final entry in {
          'magicalEssence': profile.magicalEssence,
          'intuitiveGifts': profile.intuitiveGifts,
          'communicationStyle': profile.communicationStyle,
          'loveAndBeauty': profile.loveAndBeauty,
          'protectiveEnergy': profile.protectiveEnergy,
          'houseOfMagic': profile.houseOfMagic,
          'houseOfSpirit': profile.houseOfSpirit,
        }.entries) {
          expect(entry.value.trim(), isNotEmpty,
              reason: '${entry.key} [$lang]');
          expect(entry.value, isNot(contains('null')),
              reason: '${entry.key} [$lang]');
        }

        expect(profile.magicalEssence,
            magicalByLang[lang]!.sunEssence[ZodiacSign.leo],
            reason: 'magicalEssence deve seguir o locale [$lang]');

        // Lua e Plutão na Casa 8, Netuno na Casa 12 -> textos condicionais.
        expect(profile.houseOfMagic, contains(magicalByLang[lang]!.house8Moon),
            reason: 'house8Moon [$lang]');
        expect(
            profile.houseOfMagic, contains(magicalByLang[lang]!.house8Pluto),
            reason: 'house8Pluto [$lang]');
        expect(profile.houseOfSpirit,
            contains(magicalByLang[lang]!.house12Neptune),
            reason: 'house12Neptune [$lang]');

        for (final list in [
          profile.magicalStrengths,
          profile.recommendedPractices,
          profile.favorableTools,
          profile.shadowWork,
        ]) {
          expect(list, isNotEmpty, reason: 'listas do perfil [$lang]');
          for (final item in list) {
            expect(item.trim(), isNotEmpty, reason: 'item de lista [$lang]');
          }
        }
      });
    });
  });

  group('Interpretação padrão dos pontos místicos nos três locales', () {
    test('usa o possessivo correto por idioma (Sua/Seu, Your, Tu)', () {
      final expectedByLang = {
        'pt': {Planet.lilith: 'Sua ', Planet.vertex: 'Seu '},
        'en': {Planet.lilith: 'Your ', Planet.vertex: 'Your '},
        'es': {Planet.lilith: 'Tu ', Planet.vertex: 'Tu '},
      };
      forEachLocale((lang) {
        expectedByLang[lang]!.forEach((planet, prefix) {
          final text = PlanetSignInterpretations.getInterpretation(
              planet, ZodiacSign.scorpio);
          expect(text, startsWith(prefix), reason: '${planet.name} [$lang]');
        });
      });
    });

    test('cobre todos os planetas/pontos e signos, sem texto vazio', () {
      forEachLocale((lang) {
        for (final planet in Planet.values) {
          for (final sign in ZodiacSign.values) {
            final text =
                PlanetSignInterpretations.getInterpretation(planet, sign);
            expect(text.trim(), isNotEmpty,
                reason: '${planet.name}_${sign.name} [$lang]');
            expect(text, isNot(contains('null')),
                reason: '${planet.name}_${sign.name} [$lang]');

            final short =
                PlanetSignInterpretations.getShortInterpretation(planet, sign);
            expect(short.trim(), isNotEmpty,
                reason: 'short ${planet.name}_${sign.name} [$lang]');
          }
        }
      });
    });
  });
}
