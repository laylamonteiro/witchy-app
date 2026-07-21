import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/zodiac_signs_data_en.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/zodiac_signs_data_es.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/zodiac_signs_data_pt.dart';
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
}
