import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/runes/data/models/rune_model.dart';
import 'package:grimorio_de_bolso/features/runes/data/models/rune_spread_model.dart';

void main() {
  group('Rune', () {
    test('getAllRunes returns 24 runes (Elder Futhark)', () {
      final runes = Rune.getAllRunes();
      expect(runes.length, 24);
    });

    test('all runes have non-empty fields', () {
      for (final rune in Rune.getAllRunes()) {
        expect(rune.name, isNotEmpty);
        expect(rune.symbol, isNotEmpty);
        expect(rune.keywords, isNotEmpty);
        expect(rune.description, isNotEmpty);
      }
    });

    test('all rune names are unique', () {
      final names = Rune.getAllRunes().map((r) => r.name).toSet();
      expect(names.length, 24);
    });

    test('all rune symbols are unique', () {
      final symbols = Rune.getAllRunes().map((r) => r.symbol).toSet();
      expect(symbols.length, 24);
    });

    test('aliases work correctly', () {
      final rune = Rune.getAllRunes().first;
      expect(rune.meaning, rune.description);
      expect(rune.divination, rune.description);
      expect(rune.reversedMeaning, isNull);
    });

    group('findByName', () {
      test('finds rune by exact name', () {
        final rune = Rune.findByName('Fehu');
        expect(rune, isNotNull);
        expect(rune!.name, 'Fehu');
      });

      test('finds rune case-insensitively', () {
        final rune = Rune.findByName('fehu');
        expect(rune, isNotNull);
        expect(rune!.name, 'Fehu');
      });

      test('returns null for non-existent rune', () {
        final rune = Rune.findByName('NonExistent');
        expect(rune, isNull);
      });
    });

    group('JSON serialization', () {
      test('round-trip preserves all fields', () {
        final original = Rune.getAllRunes().first;
        final json = original.toJson();
        final restored = Rune.fromJson(json);

        expect(restored.name, original.name);
        expect(restored.symbol, original.symbol);
        expect(restored.keywords, original.keywords);
        expect(restored.description, original.description);
      });
    });

    test('first rune is Fehu', () {
      expect(Rune.getAllRunes().first.name, 'Fehu');
    });

    test('last rune is Othala', () {
      expect(Rune.getAllRunes().last.name, 'Othala');
    });
  });

  group('RuneSpreadType', () {
    test('all types have displayName', () {
      for (final type in RuneSpreadType.values) {
        expect(type.displayName, isNotEmpty);
      }
    });

    test('all types have description', () {
      for (final type in RuneSpreadType.values) {
        expect(type.description, isNotEmpty);
      }
    });

    test('runeCount values', () {
      expect(RuneSpreadType.single.runeCount, 1);
      expect(RuneSpreadType.threeCast.runeCount, 3);
      expect(RuneSpreadType.nordicCross.runeCount, 5);
      expect(RuneSpreadType.nineWorlds.runeCount, 9);
    });

    test('getPositionMeaning for single', () {
      expect(RuneSpreadType.single.getPositionMeaning(0), 'Mensagem');
    });

    test('getPositionMeaning for threeCast', () {
      expect(RuneSpreadType.threeCast.getPositionMeaning(0), 'Passado');
      expect(RuneSpreadType.threeCast.getPositionMeaning(1), 'Presente');
      expect(RuneSpreadType.threeCast.getPositionMeaning(2), 'Futuro');
    });

    test('getPositionMeaning for nordicCross has 5 positions', () {
      for (int i = 0; i < 5; i++) {
        expect(
          RuneSpreadType.nordicCross.getPositionMeaning(i),
          isNotEmpty,
        );
      }
    });

    test('getPositionMeaning for nineWorlds has 9 positions', () {
      for (int i = 0; i < 9; i++) {
        expect(
          RuneSpreadType.nineWorlds.getPositionMeaning(i),
          isNotEmpty,
        );
      }
    });
  });

  group('RuneReading', () {
    test('JSON and string round-trip', () {
      final rune = Rune.getAllRunes().first;
      final reading = RuneReading(
        id: 'reading-1',
        question: 'What does the future hold?',
        spreadType: RuneSpreadType.single,
        positions: [
          RunePosition(
            position: 0,
            rune: rune,
            isReversed: false,
            positionMeaning: 'Mensagem',
          ),
        ],
        interpretation: 'Prosperity awaits',
        date: DateTime(2024, 6, 15),
      );

      final jsonStr = reading.toJsonString();
      final restored = RuneReading.fromJsonString(jsonStr);

      expect(restored.id, reading.id);
      expect(restored.question, reading.question);
      expect(restored.spreadType, RuneSpreadType.single);
      expect(restored.positions.length, 1);
      expect(restored.positions.first.rune.name, 'Fehu');
      expect(restored.positions.first.isReversed, isFalse);
      expect(restored.interpretation, 'Prosperity awaits');
    });
  });

  group('RunePosition', () {
    test('JSON round-trip', () {
      final rune = Rune.getAllRunes()[5]; // Kenaz
      final pos = RunePosition(
        position: 2,
        rune: rune,
        isReversed: true,
        positionMeaning: 'Futuro',
      );

      final json = pos.toJson();
      final restored = RunePosition.fromJson(json);

      expect(restored.position, 2);
      expect(restored.rune.name, 'Kenaz');
      expect(restored.isReversed, isTrue);
      expect(restored.positionMeaning, 'Futuro');
    });
  });
}
