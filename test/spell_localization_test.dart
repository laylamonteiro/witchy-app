import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/data_sources/spell_localizer.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/data_sources/spells_content_en.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/data_sources/spells_content_es.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/data_sources/spells_data.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/models/spell_model.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/repositories/spell_repository.dart';

void main() {
  // Restaura o locale padrão para não vazar estado entre arquivos de teste.
  tearDown(() {
    ContentLocale.instance.setLocale(const Locale('pt', 'BR'));
  });

  SpellModel preloadedSeedSpell() {
    final seed = preloadedSpells.first;
    return SpellModel(
      id: SqfliteSpellLocalStore.preloadedSpellId(seed.name),
      name: seed.name,
      purpose: seed.purpose,
      type: seed.type,
      category: seed.category,
      moonPhase: seed.moonPhase,
      ingredients: seed.ingredients,
      steps: seed.steps,
      duration: seed.duration,
      observations: seed.observations,
      isPreloaded: true,
    );
  }

  group('SpellLocalizer.localize', () {
    test('em pt-BR retorna o feitiço precarregado inalterado', () {
      ContentLocale.instance.setLocale(const Locale('pt', 'BR'));
      final spell = preloadedSeedSpell();

      final localized = SpellLocalizer.localize(spell);

      expect(identical(localized, spell), isTrue);
    });

    test('em en traduz feitiço precarregado sem alterar o id', () {
      ContentLocale.instance.setLocale(const Locale('en'));
      final spell = preloadedSeedSpell();

      final localized = SpellLocalizer.localize(spell);

      expect(localized.id, spell.id);
      expect(localized.name, isNot(spell.name));
      expect(localized.name, spellOverlaysEn[spell.id]!.name);
      expect(localized.purpose, spellOverlaysEn[spell.id]!.purpose);
      expect(localized.isPreloaded, isTrue);
      // Taxonomia e metadados preservados.
      expect(localized.type, spell.type);
      expect(localized.category, spell.category);
      expect(localized.moonPhase, spell.moonPhase);
      expect(localized.duration, spell.duration);
      expect(localized.createdAt, spell.createdAt);
      expect(localized.updatedAt, spell.updatedAt);
      expect(localized.synced, spell.synced);
    });

    test('em es traduz feitiço precarregado sem alterar o id', () {
      ContentLocale.instance.setLocale(const Locale('es'));
      final spell = preloadedSeedSpell();

      final localized = SpellLocalizer.localize(spell);

      expect(localized.id, spell.id);
      expect(localized.name, isNot(spell.name));
      expect(localized.name, spellOverlaysEs[spell.id]!.name);
      expect(localized.purpose, spellOverlaysEs[spell.id]!.purpose);
      expect(localized.ingredients, spellOverlaysEs[spell.id]!.ingredients);
      expect(localized.steps, spellOverlaysEs[spell.id]!.steps);
      expect(localized.isPreloaded, isTrue);
    });

    test('não altera feitiço criado pelo usuário (não-preloaded)', () {
      for (final locale in const [Locale('en'), Locale('es')]) {
        ContentLocale.instance.setLocale(locale);
        final userSpell = SpellModel(
          name: 'Meu Feitiço Pessoal',
          purpose: 'Teste',
          type: SpellType.attraction,
          category: SpellCategory.other,
          ingredients: const ['1 vela'],
          steps: '1. Acenda a vela',
        );

        final localized = SpellLocalizer.localize(userSpell);

        expect(identical(localized, userSpell), isTrue,
            reason: 'feitiço do usuário não deve mudar em $locale');
      }
    });
  });

  group('cobertura dos overlays', () {
    final expectedKeys = preloadedSpells
        .map((s) => SqfliteSpellLocalStore.preloadedSpellId(s.name))
        .toSet();

    test('seed tem 65 feitiços com ids únicos', () {
      expect(preloadedSpells.length, 65);
      expect(expectedKeys.length, 65);
    });

    test('spellOverlaysEn cobre exatamente os 65 feitiços da seed', () {
      expect(spellOverlaysEn.length, 65);
      expect(spellOverlaysEn.keys.toSet(), expectedKeys);
    });

    test('spellOverlaysEs cobre exatamente os 65 feitiços da seed', () {
      expect(spellOverlaysEs.length, 65);
      expect(spellOverlaysEs.keys.toSet(), expectedKeys);
    });
  });
}
