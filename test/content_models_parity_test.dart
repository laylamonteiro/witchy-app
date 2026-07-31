import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/features/diary/data/data_sources/affirmation_content_en.dart';
import 'package:grimorio_de_bolso/features/diary/data/data_sources/affirmation_content_es.dart';
import 'package:grimorio_de_bolso/features/diary/data/data_sources/affirmation_localizer.dart';
import 'package:grimorio_de_bolso/features/diary/data/models/affirmation_model.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/models/spell_model.dart';
import 'package:grimorio_de_bolso/features/journeys/data/models/journey_model.dart';
import 'package:grimorio_de_bolso/features/journeys/data/models/journey_texts_en.dart';
import 'package:grimorio_de_bolso/features/journeys/data/models/journey_texts_es.dart';
import 'package:grimorio_de_bolso/features/journeys/data/models/journey_texts_pt.dart';
import 'package:grimorio_de_bolso/features/wheel_of_year/data/models/sabbat_content_en.dart';
import 'package:grimorio_de_bolso/features/wheel_of_year/data/models/sabbat_content_es.dart';
import 'package:grimorio_de_bolso/features/wheel_of_year/data/models/sabbat_content_pt.dart';
import 'package:grimorio_de_bolso/features/wheel_of_year/data/models/sabbat_model.dart';

/// Paridade pt/en/es dos modelos de conteúdo: sabbats (nomes próprios
/// invariantes; textos traduzidos), jornadas (ids invariantes) e o overlay
/// de exibição das afirmações pré-carregadas.
void main() {
  tearDown(() => ContentLocale.instance.setLocale(const Locale('pt', 'BR')));

  group('Sabbats', () {
    test('todas as 8 chaves em todos os mapas das 3 línguas', () {
      final all = SabbatType.values.toSet();
      final maps = <String, Map<SabbatType, Object>>{
        'descPt': sabbatDescriptionsPt, 'descEn': sabbatDescriptionsEn,
        'descEs': sabbatDescriptionsEs,
        'southPt': sabbatSouthDatesPt, 'southEn': sabbatSouthDatesEn,
        'southEs': sabbatSouthDatesEs,
        'northPt': sabbatNorthDatesPt, 'northEn': sabbatNorthDatesEn,
        'northEs': sabbatNorthDatesEs,
        'crysPt': sabbatCrystalsPt, 'crysEn': sabbatCrystalsEn,
        'crysEs': sabbatCrystalsEs,
        'herbPt': sabbatHerbsPt, 'herbEn': sabbatHerbsEn,
        'herbEs': sabbatHerbsEs,
        'colPt': sabbatColorsPt, 'colEn': sabbatColorsEn,
        'colEs': sabbatColorsEs,
        'foodPt': sabbatFoodsPt, 'foodEn': sabbatFoodsEn,
        'foodEs': sabbatFoodsEs,
        'ritPt': sabbatRitualsPt, 'ritEn': sabbatRitualsEn,
        'ritEs': sabbatRitualsEs,
      };
      maps.forEach((name, map) {
        expect(map.keys.toSet(), all, reason: name);
      });
    });

    test('listas com a mesma contagem por sabbat nas 3 línguas', () {
      for (final s in SabbatType.values) {
        expect(sabbatCrystalsEn[s]!.length, sabbatCrystalsPt[s]!.length);
        expect(sabbatCrystalsEs[s]!.length, sabbatCrystalsPt[s]!.length);
        expect(sabbatHerbsEn[s]!.length, sabbatHerbsPt[s]!.length);
        expect(sabbatHerbsEs[s]!.length, sabbatHerbsPt[s]!.length);
        expect(sabbatRitualsEn[s]!.length, sabbatRitualsPt[s]!.length);
        expect(sabbatRitualsEs[s]!.length, sabbatRitualsPt[s]!.length);
      }
    });

    test('nome do sabbat é invariante e descrição muda por idioma', () {
      ContentLocale.instance.setLocale(const Locale('en'));
      expect(SabbatType.samhain.name, 'Samhain');
      expect(SabbatType.samhain.description, contains('Witches'));
      ContentLocale.instance.setLocale(const Locale('es'));
      expect(SabbatType.samhain.name, 'Samhain');
      expect(SabbatType.samhain.description, contains('Brujas'));
    });
  });

  group('Jornadas', () {
    test('todas as jornadas e etapas têm textos nas 3 línguas', () {
      for (final j in AvailableJourneys.all) {
        for (final m in [journeyTextsPt, journeyTextsEn, journeyTextsEs]) {
          expect(m[j.id], isNotNull, reason: j.id);
          expect(m[j.id]!.title.trim(), isNotEmpty, reason: j.id);
          expect(m[j.id]!.description.trim(), isNotEmpty, reason: j.id);
        }
        for (final step in j.steps) {
          for (final m in [
            journeyStepTextsPt,
            journeyStepTextsEn,
            journeyStepTextsEs
          ]) {
            expect(m[step.id], isNotNull, reason: '${j.id}/${step.id}');
          }
        }
      }
    });

    test('localizedTitle segue o idioma e cai no campo PT sem entrada', () {
      final j = AvailableJourneys.all.first;
      ContentLocale.instance.setLocale(const Locale('en'));
      expect(j.localizedTitle, 'First Steps');
      ContentLocale.instance.setLocale(const Locale('pt', 'BR'));
      expect(j.localizedTitle, j.title);
    });
  });

  group('Enums do grimório (spell_model)', () {
    test('displayName/description cobrem todos os valores nas 3 línguas', () {
      final samples = <String>{};
      for (final locale in const [Locale('pt', 'BR'), Locale('en'), Locale('es')]) {
        ContentLocale.instance.setLocale(locale);
        for (final t in SpellType.values) {
          expect(t.displayName.trim(), isNotEmpty, reason: '$locale $t');
        }
        for (final c in SpellCategory.values) {
          expect(c.displayName.trim(), isNotEmpty, reason: '$locale $c');
        }
        for (final p in MoonPhase.values) {
          expect(p.displayName.trim(), isNotEmpty, reason: '$locale $p');
          expect(p.description.trim(), isNotEmpty, reason: '$locale $p');
        }
        samples.add(MoonPhase.fullMoon.displayName);
      }
      // Os três idiomas produzem textos distintos.
      expect(samples.length, 3);
    });
  });

  group('Afirmações pré-carregadas', () {
    test('overlays EN/ES cobrem exatamente os textos da seed', () {
      final seedTexts = AffirmationModel.getPreloadedAffirmations()
          .map((a) => a.text)
          .toSet();
      expect(affirmationOverlaysEn.keys.toSet(), seedTexts);
      expect(affirmationOverlaysEs.keys.toSet(), seedTexts);
      for (final v in [
        ...affirmationOverlaysEn.values,
        ...affirmationOverlaysEs.values
      ]) {
        expect(v.trim(), isNotEmpty);
      }
    });

    test('localize traduz preloaded na exibição e preserva as do usuário', () {
      final preloaded = AffirmationModel.getPreloadedAffirmations().first;
      final custom = AffirmationModel(
        text: 'Minha afirmação pessoal cheia de magia própria',
        category: AffirmationCategory.love,
        isPreloaded: false,
      );

      ContentLocale.instance.setLocale(const Locale('en'));
      final localized = AffirmationLocalizer.localize(preloaded);
      expect(localized.text, isNot(preloaded.text));
      expect(localized.id, preloaded.id);
      expect(AffirmationLocalizer.localize(custom).text, custom.text);

      ContentLocale.instance.setLocale(const Locale('pt', 'BR'));
      expect(AffirmationLocalizer.localize(preloaded).text, preloaded.text);
    });
  });
}
