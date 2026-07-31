import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/models/spell_model.dart'
    show MoonPhase;
import 'package:grimorio_de_bolso/features/lunar/data/models/moon_content_data.dart';
import 'package:grimorio_de_bolso/features/lunar/data/models/moon_content_en.dart';
import 'package:grimorio_de_bolso/features/lunar/data/models/moon_content_es.dart';
import 'package:grimorio_de_bolso/features/lunar/data/models/moon_content_pt.dart';
import 'package:grimorio_de_bolso/features/sun/data/models/sun_content_data.dart';
import 'package:grimorio_de_bolso/features/sun/data/models/sun_content_en.dart';
import 'package:grimorio_de_bolso/features/sun/data/models/sun_content_es.dart';
import 'package:grimorio_de_bolso/features/sun/data/models/sun_content_pt.dart';

/// Paridade PT/EN/ES do conhecimento da Lua e do Sol (páginas da
/// Enciclopédia). Segue o padrão dos demais testes de paridade.
void main() {
  tearDown(() {
    ContentLocale.instance.setLocale(const Locale('pt', 'BR'));
  });

  group('MoonContent', () {
    test('intro não vazia nos 3 idiomas', () {
      for (final intro in [moonIntroPt, moonIntroEn, moonIntroEs]) {
        expect(intro.trim(), isNotEmpty);
      }
    });

    test('phaseKnowledge cobre as 8 fases nos 3 idiomas', () {
      for (final map in [
        moonPhaseKnowledgePt,
        moonPhaseKnowledgeEn,
        moonPhaseKnowledgeEs
      ]) {
        expect(map.keys.toSet(), MoonPhase.values.toSet());
        for (final entry in map.entries) {
          expect(entry.value.favors, isNotEmpty, reason: '${entry.key}');
          expect(entry.value.goodFor, isNotEmpty, reason: '${entry.key}');
        }
      }
      for (final phase in MoonPhase.values) {
        expect(moonPhaseKnowledgeEn[phase]!.goodFor.length,
            moonPhaseKnowledgePt[phase]!.goodFor.length,
            reason: '$phase');
        expect(moonPhaseKnowledgeEs[phase]!.goodFor.length,
            moonPhaseKnowledgePt[phase]!.goodFor.length,
            reason: '$phase');
      }
    });

    test('esbats com o quê/como nos 3 idiomas', () {
      for (final esbats in [moonEsbatsPt, moonEsbatsEn, moonEsbatsEs]) {
        expect(esbats.what.trim(), isNotEmpty);
        expect(esbats.how.trim(), isNotEmpty);
      }
    });

    test('correspondências com a mesma contagem nos 3 idiomas', () {
      expect(moonCorrespondencesEn.length, moonCorrespondencesPt.length);
      expect(moonCorrespondencesEs.length, moonCorrespondencesPt.length);
    });

    test('getters resolvem pelo ContentLocale', () {
      ContentLocale.instance.setLocale(const Locale('en'));
      expect(MoonContent.intro, moonIntroEn);
      expect(MoonContent.phaseKnowledge, moonPhaseKnowledgeEn);
      ContentLocale.instance.setLocale(const Locale('es'));
      expect(MoonContent.esbats, moonEsbatsEs);
      expect(MoonContent.correspondences, moonCorrespondencesEs);
    });
  });

  group('SunContent', () {
    test('intro não vazia nos 3 idiomas', () {
      for (final intro in [sunIntroPt, sunIntroEn, sunIntroEs]) {
        expect(intro.trim(), isNotEmpty);
      }
    });

    test('sabbats solares: mesmos 4 sabbats na mesma ordem nos 3 idiomas', () {
      final ptOrder = sunSabbatsPt.map((s) => s.sabbat).toList();
      expect(ptOrder.toSet().length, 4);
      expect(sunSabbatsEn.map((s) => s.sabbat).toList(), ptOrder);
      expect(sunSabbatsEs.map((s) => s.sabbat).toList(), ptOrder);
      for (final list in [sunSabbatsPt, sunSabbatsEn, sunSabbatsEs]) {
        for (final entry in list) {
          expect(entry.meaning.trim(), isNotEmpty, reason: '${entry.sabbat}');
        }
      }
    });

    test('correspondências com a mesma contagem nos 3 idiomas', () {
      expect(sunCorrespondencesEn.length, sunCorrespondencesPt.length);
      expect(sunCorrespondencesEs.length, sunCorrespondencesPt.length);
    });

    test('divindades: mesma contagem e textos não vazios nos 3 idiomas', () {
      expect(sunDeitiesEn.length, sunDeitiesPt.length);
      expect(sunDeitiesEs.length, sunDeitiesPt.length);
      for (final list in [sunDeitiesPt, sunDeitiesEn, sunDeitiesEs]) {
        for (final deity in list) {
          expect(deity.name.trim(), isNotEmpty);
          expect(deity.description.trim(), isNotEmpty, reason: deity.name);
        }
      }
    });

    test('getters resolvem pelo ContentLocale', () {
      ContentLocale.instance.setLocale(const Locale('en'));
      expect(SunContent.intro, sunIntroEn);
      ContentLocale.instance.setLocale(const Locale('es'));
      expect(SunContent.solarDeities, sunDeitiesEs);
    });
  });
}
