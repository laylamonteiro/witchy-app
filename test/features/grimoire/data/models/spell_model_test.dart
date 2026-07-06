import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/models/spell_model.dart';

void main() {
  group('SpellModel', () {
    late SpellModel spell;
    final fixedDate = DateTime(2024, 6, 15, 10, 30);

    setUp(() {
      spell = SpellModel(
        id: 'test-id',
        userId: 'user-1',
        name: 'Protection Spell',
        purpose: 'Protection',
        type: SpellType.banishment,
        category: SpellCategory.protection,
        moonPhase: MoonPhase.fullMoon,
        ingredients: ['Salt', 'Candle', 'Rosemary'],
        steps: 'Light the candle and chant',
        duration: 7,
        observations: 'Best during full moon',
        isPreloaded: false,
        createdAt: fixedDate,
        updatedAt: fixedDate,
        synced: true,
      );
    });

    test('constructor generates UUID when id is null', () {
      final s = SpellModel(
        name: 'Test',
        purpose: 'Test',
        type: SpellType.attraction,
        category: SpellCategory.other,
        ingredients: [],
        steps: '',
      );
      expect(s.id, isNotEmpty);
      expect(s.id.length, greaterThan(10));
    });

    test('constructor defaults dates to now when not provided', () {
      final before = DateTime.now();
      final s = SpellModel(
        name: 'Test',
        purpose: 'Test',
        type: SpellType.attraction,
        category: SpellCategory.other,
        ingredients: [],
        steps: '',
      );
      expect(s.createdAt.isAfter(before) || s.createdAt.isAtSameMomentAs(before), isTrue);
      expect(s.isPreloaded, isFalse);
      expect(s.synced, isFalse);
    });

    group('toMap / fromMap', () {
      test('round-trip preserves all fields', () {
        final map = spell.toMap();
        final restored = SpellModel.fromMap(map);

        expect(restored.id, spell.id);
        expect(restored.userId, spell.userId);
        expect(restored.name, spell.name);
        expect(restored.purpose, spell.purpose);
        expect(restored.type, spell.type);
        expect(restored.category, spell.category);
        expect(restored.moonPhase, spell.moonPhase);
        expect(restored.ingredients, spell.ingredients);
        expect(restored.steps, spell.steps);
        expect(restored.duration, spell.duration);
        expect(restored.observations, spell.observations);
        expect(restored.isPreloaded, spell.isPreloaded);
        expect(restored.synced, spell.synced);
      });

      test('toMap serializes ingredients with ||| separator', () {
        final map = spell.toMap();
        expect(map['ingredients'], 'Salt|||Candle|||Rosemary');
      });

      test('toMap serializes booleans as integers', () {
        final map = spell.toMap();
        expect(map['is_preloaded'], 0);
        expect(map['synced'], 1);
      });

      test('toMap serializes dates as milliseconds', () {
        final map = spell.toMap();
        expect(map['created_at'], fixedDate.millisecondsSinceEpoch);
      });

      test('toMap uses local_user when userId is null', () {
        final s = SpellModel(
          name: 'Test',
          purpose: 'Test',
          type: SpellType.attraction,
          category: SpellCategory.other,
          ingredients: [],
          steps: '',
        );
        expect(s.toMap()['user_id'], 'local_user');
      });

      test('fromMap handles null moonPhase', () {
        final map = spell.toMap();
        map['moon_phase'] = null;
        final restored = SpellModel.fromMap(map);
        expect(restored.moonPhase, isNull);
      });

      test('fromMap handles empty ingredients', () {
        final map = spell.toMap();
        map['ingredients'] = '';
        final restored = SpellModel.fromMap(map);
        expect(restored.ingredients, isEmpty);
      });

      test('fromMap handles null ingredients', () {
        final map = spell.toMap();
        map['ingredients'] = null;
        final restored = SpellModel.fromMap(map);
        expect(restored.ingredients, isEmpty);
      });

      test('fromMap defaults to attraction for unknown type', () {
        final map = spell.toMap();
        map['type'] = 'unknown';
        final restored = SpellModel.fromMap(map);
        expect(restored.type, SpellType.attraction);
      });

      test('fromMap defaults to other for unknown category', () {
        final map = spell.toMap();
        map['category'] = 'unknown';
        final restored = SpellModel.fromMap(map);
        expect(restored.category, SpellCategory.other);
      });
    });

    group('copyWith', () {
      test('copies with new name', () {
        final copy = spell.copyWith(name: 'New Name');
        expect(copy.name, 'New Name');
        expect(copy.id, spell.id);
        expect(copy.purpose, spell.purpose);
      });

      test('copyWith resets synced to false by default', () {
        final copy = spell.copyWith(name: 'Updated');
        expect(copy.synced, isFalse);
      });

      test('copyWith can set synced to true', () {
        final copy = spell.copyWith(synced: true);
        expect(copy.synced, isTrue);
      });

      test('copyWith preserves createdAt but updates updatedAt', () {
        final copy = spell.copyWith(name: 'Updated');
        expect(copy.createdAt, spell.createdAt);
        expect(copy.updatedAt.isAfter(spell.updatedAt) ||
            copy.updatedAt.isAtSameMomentAs(spell.updatedAt), isTrue);
      });
    });
  });

  group('SpellType extension', () {
    test('displayName returns correct values', () {
      expect(SpellType.attraction.displayName, contains('Atração'));
      expect(SpellType.banishment.displayName, contains('Banimento'));
    });
  });

  group('SpellCategory extension', () {
    test('all categories have displayName', () {
      for (final category in SpellCategory.values) {
        expect(category.displayName, isNotEmpty);
      }
    });

    test('all categories have icon', () {
      for (final category in SpellCategory.values) {
        expect(category.icon, isNotEmpty);
      }
    });

    test('specific displayNames', () {
      expect(SpellCategory.love.displayName, 'Amor e Romance');
      expect(SpellCategory.protection.displayName, 'Proteção');
      expect(SpellCategory.prosperity.displayName, 'Prosperidade');
    });
  });

  group('MoonPhase extension', () {
    test('all phases have displayName', () {
      for (final phase in MoonPhase.values) {
        expect(phase.displayName, isNotEmpty);
      }
    });

    test('all phases have emoji', () {
      for (final phase in MoonPhase.values) {
        expect(phase.emoji, isNotEmpty);
      }
    });

    test('all phases have description', () {
      for (final phase in MoonPhase.values) {
        expect(phase.description, isNotEmpty);
      }
    });

    test('specific displayNames', () {
      expect(MoonPhase.newMoon.displayName, 'Lua Nova');
      expect(MoonPhase.fullMoon.displayName, 'Lua Cheia');
    });
  });
}
