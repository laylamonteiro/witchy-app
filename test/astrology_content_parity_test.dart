import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/birth_chart_content.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/birth_chart_content_en.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/birth_chart_content_es.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/birth_chart_content_pt.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/personalized_suggestions_content.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/personalized_suggestions_content_en.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/personalized_suggestions_content_es.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/personalized_suggestions_content_pt.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/zodiac_signs_data_en.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/zodiac_signs_data_es.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/zodiac_signs_data_pt.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/aspect_model.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/enums.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/house_model.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/zodiac_sign_data.dart';

/// Garante que o conteúdo de astrologia localizado (signos do zodíaco e
/// significados das casas) tem paridade pt/en/es: mesma contagem, mesma ordem,
/// campos invariantes preservados e nenhum texto vazio — a tradução não pode
/// alterar a estrutura nem deixar buracos que quebrem telas ou serviços sem
/// `BuildContext`.
void main() {
  // Restaura o padrão do app após cada teste para não vazar estado global.
  tearDown(() {
    ContentLocale.instance.setLocale(const Locale('pt', 'BR'));
  });

  group('Signos do zodíaco', () {
    test('as três línguas têm 12 signos na mesma ordem (sign invariante)', () {
      expect(zodiacSignsPt.length, 12);
      expect(zodiacSignsEn.length, zodiacSignsPt.length);
      expect(zodiacSignsEs.length, zodiacSignsPt.length);

      // A ordem deve corresponder à ordem canônica do enum ZodiacSign.
      expect(
        zodiacSignsPt.map((d) => d.sign).toList(),
        ZodiacSign.values,
      );

      for (var i = 0; i < zodiacSignsPt.length; i++) {
        // O campo `sign` é invariante entre idiomas.
        expect(zodiacSignsEn[i].sign, zodiacSignsPt[i].sign);
        expect(zodiacSignsEs[i].sign, zodiacSignsPt[i].sign);
      }
    });

    test('nenhum campo textual é vazio em qualquer idioma', () {
      final lists = {
        'pt': zodiacSignsPt,
        'en': zodiacSignsEn,
        'es': zodiacSignsEs,
      };

      final getters = <String, String Function(ZodiacSignData)>{
        'dateRange': (d) => d.dateRange,
        'rulingPlanet': (d) => d.rulingPlanet,
        'keywords': (d) => d.keywords,
        'personality': (d) => d.personality,
        'magicalGifts': (d) => d.magicalGifts,
        'bestPractices': (d) => d.bestPractices,
        'crystals': (d) => d.crystals,
        'herbs': (d) => d.herbs,
        'colors': (d) => d.colors,
      };

      lists.forEach((lang, list) {
        for (final data in list) {
          getters.forEach((field, getter) {
            expect(
              getter(data).trim(),
              isNotEmpty,
              reason: '$field vazio em "$lang" para ${data.sign}',
            );
          });
        }
      });
    });
  });

  group('Casas astrológicas', () {
    const locales = {
      'pt': Locale('pt', 'BR'),
      'en': Locale('en', 'US'),
      'es': Locale('es', 'ES'),
    };

    House houseOf(int number) => House(
          number: number,
          sign: ZodiacSign.aries,
          degree: 0,
          minute: 0,
          cuspLongitude: 0,
        );

    test('meaning cobre as casas 1..12 sem vazio nas 3 línguas', () {
      locales.forEach((lang, locale) {
        ContentLocale.instance.setLocale(locale);
        for (var n = 1; n <= 12; n++) {
          expect(
            houseOf(n).meaning.trim(),
            isNotEmpty,
            reason: 'House($n).meaning vazio em "$lang"',
          );
        }
      });
    });

    test('magicalMeaning cobre as casas 1..12 sem vazio nas 3 línguas', () {
      locales.forEach((lang, locale) {
        ContentLocale.instance.setLocale(locale);
        for (var n = 1; n <= 12; n++) {
          expect(
            houseOf(n).magicalMeaning.trim(),
            isNotEmpty,
            reason: 'House($n).magicalMeaning vazio em "$lang"',
          );
        }
      });
    });

    test('meaning muda com o locale ativo (amostra)', () {
      ContentLocale.instance.setLocale(const Locale('en', 'US'));
      expect(houseOf(1).meaning,
          'Personality, appearance, how you present yourself to the world');

      ContentLocale.instance.setLocale(const Locale('es', 'ES'));
      expect(houseOf(1).meaning,
          'Personalidad, apariencia, cómo te presentas ante el mundo');
    });
  });

  group('Conteúdo da página do mapa astral (BirthChartContent)', () {
    const contents = {
      'pt': birthChartContentPt,
      'en': birthChartContentEn,
      'es': birthChartContentEs,
    };

    test('ui tem as mesmas chaves nas 3 línguas e nenhum texto vazio', () {
      final ptKeys = birthChartContentPt.ui.keys.toSet();
      contents.forEach((lang, content) {
        expect(content.ui.keys.toSet(), ptKeys,
            reason: 'chaves de ui divergentes em "$lang"');
        content.ui.forEach((key, value) {
          expect(value.trim(), isNotEmpty,
              reason: 'ui["$key"] vazio em "$lang"');
        });
      });
    });

    test('planetRowMeanings cobre os mesmos planetas sem vazio', () {
      final ptKeys = birthChartContentPt.planetRowMeanings.keys.toSet();
      expect(
        ptKeys,
        {Planet.sun, Planet.moon, Planet.mercury, Planet.venus, Planet.mars},
      );
      contents.forEach((lang, content) {
        expect(content.planetRowMeanings.keys.toSet(), ptKeys,
            reason: 'planetRowMeanings divergentes em "$lang"');
        content.planetRowMeanings.forEach((planet, value) {
          expect(value.trim(), isNotEmpty,
              reason: 'planetRowMeanings[$planet] vazio em "$lang"');
        });
      });
    });

    test('seções têm mesma contagem, ordem estável e nenhum texto vazio', () {
      final sectionLists = <String, List<BirthChartSection> Function(
          BirthChartContent)>{
        'trioSections': (c) => c.trioSections,
        'personalSections': (c) => c.personalSections,
        'socialSections': (c) => c.socialSections,
        'transpersonalSections': (c) => c.transpersonalSections,
        'pointsSections': (c) => c.pointsSections,
      };
      const expectedLengths = {
        'trioSections': 3,
        'personalSections': 3,
        'socialSections': 2,
        'transpersonalSections': 3,
        'pointsSections': 8,
      };

      contents.forEach((lang, content) {
        sectionLists.forEach((name, getter) {
          final sections = getter(content);
          expect(sections.length, expectedLengths[name],
              reason: '$name com contagem errada em "$lang"');
          for (final section in sections) {
            expect(section.title.trim(), isNotEmpty,
                reason: 'título vazio em $name ("$lang")');
            expect(section.body.trim(), isNotEmpty,
                reason: 'corpo vazio em $name ("$lang")');
          }
        });
      });
    });

    test('intros e tips não são vazios nas 3 línguas', () {
      contents.forEach((lang, content) {
        final texts = <String, String>{
          'personalIntro': content.personalIntro,
          'socialIntro': content.socialIntro,
          'transpersonalIntro': content.transpersonalIntro,
          'pointsIntro': content.pointsIntro,
          'housesIntro': content.housesIntro,
          'aspectsIntro': content.aspectsIntro,
          'trioTip.title': content.trioTip.title,
          'trioTip.body': content.trioTip.body,
          'personalTip.title': content.personalTip.title,
          'personalTip.body': content.personalTip.body,
          'housesTip.title': content.housesTip.title,
          'housesTip.body': content.housesTip.body,
          'aspectsTip.title': content.aspectsTip.title,
          'aspectsTip.body': content.aspectsTip.body,
        };
        texts.forEach((name, value) {
          expect(value.trim(), isNotEmpty, reason: '$name vazio em "$lang"');
        });
      });
    });

    test('houseMeanings cobre as casas 1..12 sem vazio', () {
      contents.forEach((lang, content) {
        for (var n = 1; n <= 12; n++) {
          expect(content.houseMeanings[n]?.trim(), isNotEmpty,
              reason: 'houseMeanings[$n] vazio em "$lang"');
        }
        expect(content.houseMeanings.length, 12,
            reason: 'houseMeanings com contagem errada em "$lang"');
      });
    });

    test('aspectTypeMeanings cobre todos os AspectType sem vazio', () {
      contents.forEach((lang, content) {
        for (final type in AspectType.values) {
          expect(content.aspectTypeMeanings[type]?.trim(), isNotEmpty,
              reason: 'aspectTypeMeanings[$type] vazio em "$lang"');
        }
      });
    });

    test('acessor muda com o locale ativo (amostra)', () {
      ContentLocale.instance.setLocale(const Locale('en', 'US'));
      expect(birthChartContent.ui['sectionMainTrio'], 'Main Trio');

      ContentLocale.instance.setLocale(const Locale('es', 'ES'));
      expect(birthChartContent.ui['sectionMainTrio'], 'Trío Principal');

      ContentLocale.instance.setLocale(const Locale('pt', 'BR'));
      expect(birthChartContent.ui['sectionMainTrio'], 'Trio Principal');
    });
  });

  group('Sugestões personalizadas (PersonalizedSuggestionsContent)', () {
    const contents = {
      'pt': personalizedSuggestionsContentPt,
      'en': personalizedSuggestionsContentEn,
      'es': personalizedSuggestionsContentEs,
    };

    test('ui tem as mesmas chaves nas 3 línguas e nenhum texto vazio', () {
      final ptKeys = personalizedSuggestionsContentPt.ui.keys.toSet();
      contents.forEach((lang, content) {
        expect(content.ui.keys.toSet(), ptKeys,
            reason: 'chaves de ui divergentes em "$lang"');
        content.ui.forEach((key, value) {
          expect(value.trim(), isNotEmpty,
              reason: 'ui["$key"] vazio em "$lang"');
        });
      });
    });

    test('templates preservam os placeholders invariantes', () {
      contents.forEach((lang, content) {
        expect(content.ui['retrogradeCountOne'], contains('{count}'),
            reason: 'retrogradeCountOne sem {count} em "$lang"');
        expect(content.ui['retrogradeCountMany'], contains('{count}'),
            reason: 'retrogradeCountMany sem {count} em "$lang"');
        expect(content.ui['retrogradeInSign'], contains('{title}'),
            reason: 'retrogradeInSign sem {title} em "$lang"');
        expect(content.ui['retrogradeInSign'], contains('{sign}'),
            reason: 'retrogradeInSign sem {sign} em "$lang"');
      });
    });

    test('retrogradeInfo cobre os mesmos planetas sem vazio', () {
      final ptKeys = personalizedSuggestionsContentPt.retrogradeInfo.keys.toSet();
      expect(ptKeys, {
        Planet.mercury,
        Planet.venus,
        Planet.mars,
        Planet.jupiter,
        Planet.saturn,
        Planet.uranus,
        Planet.neptune,
        Planet.pluto,
      });
      contents.forEach((lang, content) {
        expect(content.retrogradeInfo.keys.toSet(), ptKeys,
            reason: 'retrogradeInfo divergente em "$lang"');
        content.retrogradeInfo.forEach((planet, info) {
          expect(info.title.trim(), isNotEmpty,
              reason: 'title vazio para $planet em "$lang"');
          expect(info.effects.trim(), isNotEmpty,
              reason: 'effects vazio para $planet em "$lang"');
          expect(info.tips.trim(), isNotEmpty,
              reason: 'tips vazio para $planet em "$lang"');
        });
      });
    });

    test('acessor muda com o locale ativo (amostra)', () {
      ContentLocale.instance.setLocale(const Locale('en', 'US'));
      expect(
        personalizedSuggestionsContent.retrogradeInfo[Planet.mercury]!.title,
        'Mercury Retrograde',
      );

      ContentLocale.instance.setLocale(const Locale('es', 'ES'));
      expect(
        personalizedSuggestionsContent.retrogradeInfo[Planet.mercury]!.title,
        'Mercurio Retrógrado',
      );

      ContentLocale.instance.setLocale(const Locale('pt', 'BR'));
      expect(
        personalizedSuggestionsContent.retrogradeInfo[Planet.mercury]!.title,
        'Mercúrio Retrógrado',
      );
    });
  });

  group('Textos de aspecto (Aspect)', () {
    const locales = {
      'pt': Locale('pt', 'BR'),
      'en': Locale('en', 'US'),
      'es': Locale('es', 'ES'),
    };

    Aspect aspectOf(Planet p1, Planet p2, AspectType type) => Aspect(
          planet1: p1,
          planet2: p2,
          type: type,
          exactAngle: type.angle,
          orb: 1,
        );

    // Combinações que exercitam todos os ramos de magicalInterpretation,
    // nas variantes harmoniosa e desafiadora.
    final combos = <List<Planet>>[
      [Planet.sun, Planet.moon],
      [Planet.moon, Planet.neptune],
      [Planet.mercury, Planet.neptune],
      [Planet.venus, Planet.saturn],
      [Planet.mars, Planet.saturn],
      // Sem interpretação específica -> cai em `interpretation`.
      [Planet.jupiter, Planet.saturn],
    ];

    test('interpretation e magicalInterpretation nunca vazios nas 3 línguas',
        () {
      locales.forEach((lang, locale) {
        ContentLocale.instance.setLocale(locale);
        for (final combo in combos) {
          for (final type in AspectType.values) {
            final aspect = aspectOf(combo[0], combo[1], type);
            expect(aspect.interpretation.trim(), isNotEmpty,
                reason: 'interpretation vazio em "$lang" para '
                    '${combo[0]} $type ${combo[1]}');
            expect(aspect.magicalInterpretation.trim(), isNotEmpty,
                reason: 'magicalInterpretation vazio em "$lang" para '
                    '${combo[0]} $type ${combo[1]}');
            // Nenhum placeholder pode vazar para o texto final.
            expect(aspect.interpretation, isNot(contains('{p1}')));
            expect(aspect.interpretation, isNot(contains('{p2}')));
          }
        }
      });
    });

    test('interpretation muda com o locale ativo (amostra)', () {
      final aspect =
          aspectOf(Planet.jupiter, Planet.saturn, AspectType.trine);

      // Os textos de aspecto não levam ponto final (padrão do mapa em
      // aspect_model.dart, igual nas três línguas).
      ContentLocale.instance.setLocale(const Locale('en', 'US'));
      expect(aspect.interpretation,
          'Harmonious connection between Jupiter and Saturn');

      ContentLocale.instance.setLocale(const Locale('es', 'ES'));
      expect(aspect.interpretation,
          'Conexión armoniosa entre Júpiter y Saturno');

      ContentLocale.instance.setLocale(const Locale('pt', 'BR'));
      expect(aspect.interpretation,
          'Conexão harmoniosa entre Júpiter e Saturno');
    });
  });
}
