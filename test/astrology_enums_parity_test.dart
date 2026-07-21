import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/enums.dart';

/// Garante que os getters de texto localizados dos enums de astrologia cobrem
/// todos os valores nas três línguas (pt/en/es) e nunca retornam vazio — a
/// tradução não pode deixar buracos que quebrem telas ou os serviços sem
/// `BuildContext` (magical_interpreter, transit_interpreter).
void main() {
  const locales = {
    'pt': Locale('pt', 'BR'),
    'en': Locale('en', 'US'),
    'es': Locale('es', 'ES'),
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

  void expectAllNonEmpty<T>(
    String enumName,
    List<T> values,
    String Function(T) getter,
  ) {
    forEachLocale((lang) {
      for (final value in values) {
        final text = getter(value);
        expect(
          text.trim(),
          isNotEmpty,
          reason: '$enumName.$value vazio em "$lang"',
        );
      }
    });
  }

  group('Planet', () {
    test('displayName cobre todos os valores nas 3 línguas', () {
      expectAllNonEmpty('Planet.displayName', Planet.values, (p) => p.displayName);
    });
  });

  group('ZodiacSign', () {
    test('displayName cobre todos os valores nas 3 línguas', () {
      expectAllNonEmpty(
          'ZodiacSign.displayName', ZodiacSign.values, (s) => s.displayName);
    });

    test('magicalDescription cobre todos os valores nas 3 línguas', () {
      expectAllNonEmpty('ZodiacSign.magicalDescription', ZodiacSign.values,
          (s) => s.magicalDescription);
    });
  });

  group('Element', () {
    test('displayName cobre todos os valores nas 3 línguas', () {
      expectAllNonEmpty(
          'Element.displayName', Element.values, (e) => e.displayName);
    });

    test('magicalDescription cobre todos os valores nas 3 línguas', () {
      expectAllNonEmpty('Element.magicalDescription', Element.values,
          (e) => e.magicalDescription);
    });
  });

  group('Modality', () {
    test('displayName cobre todos os valores nas 3 línguas', () {
      expectAllNonEmpty(
          'Modality.displayName', Modality.values, (m) => m.displayName);
    });

    test('description cobre todos os valores nas 3 línguas', () {
      expectAllNonEmpty(
          'Modality.description', Modality.values, (m) => m.description);
    });
  });

  group('AspectType', () {
    test('displayName cobre todos os valores nas 3 línguas', () {
      expectAllNonEmpty(
          'AspectType.displayName', AspectType.values, (a) => a.displayName);
    });

    test('description cobre todos os valores nas 3 línguas', () {
      expectAllNonEmpty(
          'AspectType.description', AspectType.values, (a) => a.description);
    });
  });

  group('EnergyLevel', () {
    test('displayName cobre todos os valores nas 3 línguas', () {
      expectAllNonEmpty(
          'EnergyLevel.displayName', EnergyLevel.values, (e) => e.displayName);
    });
  });

  test('locale desconhecido faz fallback para português', () {
    ContentLocale.instance.setLocale(const Locale('fr', 'FR'));
    expect(Planet.sun.displayName, 'Sol');
    expect(ZodiacSign.aries.displayName, 'Áries');
  });

  test('displayName muda com o locale ativo (amostra)', () {
    ContentLocale.instance.setLocale(const Locale('en', 'US'));
    expect(Planet.moon.displayName, 'Moon');
    expect(ZodiacSign.scorpio.displayName, 'Scorpio');

    ContentLocale.instance.setLocale(const Locale('es', 'ES'));
    expect(Planet.moon.displayName, 'Luna');
    expect(ZodiacSign.scorpio.displayName, 'Escorpio');
  });
}
