import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/wheel_of_year/data/models/sabbat_model.dart';

void main() {
  group('SabbatType', () {
    test('all sabbats have name', () {
      for (final sabbat in SabbatType.values) {
        expect(sabbat.name, isNotEmpty);
      }
    });

    test('all sabbats have emoji', () {
      for (final sabbat in SabbatType.values) {
        expect(sabbat.emoji, isNotEmpty);
      }
    });

    test('all sabbats have description', () {
      for (final sabbat in SabbatType.values) {
        expect(sabbat.description, isNotEmpty);
      }
    });

    test('all sabbats have southern hemisphere date', () {
      for (final sabbat in SabbatType.values) {
        expect(sabbat.southernHemisphereDate, isNotEmpty);
      }
    });

    test('all sabbats have northern hemisphere date', () {
      for (final sabbat in SabbatType.values) {
        expect(sabbat.northernHemisphereDate, isNotEmpty);
      }
    });

    test('all sabbats have crystals', () {
      for (final sabbat in SabbatType.values) {
        expect(sabbat.crystals, isNotEmpty);
      }
    });

    test('all sabbats have herbs', () {
      for (final sabbat in SabbatType.values) {
        expect(sabbat.herbs, isNotEmpty);
      }
    });

    test('all sabbats have colors', () {
      for (final sabbat in SabbatType.values) {
        expect(sabbat.colors, isNotEmpty);
      }
    });

    test('all sabbats have foods', () {
      for (final sabbat in SabbatType.values) {
        expect(sabbat.foods, isNotEmpty);
      }
    });

    test('all sabbats have rituals', () {
      for (final sabbat in SabbatType.values) {
        expect(sabbat.rituals, isNotEmpty);
      }
    });

    group('getDateForYear', () {
      test('Samhain is May 1 in southern hemisphere', () {
        final date = SabbatType.samhain.getDateForYear(2024);
        expect(date.month, 5);
        expect(date.day, 1);
        expect(date.year, 2024);
      });

      test('Yule is around June 21 in southern hemisphere', () {
        final date = SabbatType.yule.getDateForYear(2024);
        expect(date.month, 6);
        expect(date.day, inInclusiveRange(20, 22));
      });

      test('Imbolc is August 1 in southern hemisphere', () {
        final date = SabbatType.imbolc.getDateForYear(2024);
        expect(date.month, 8);
        expect(date.day, 1);
      });

      test('Ostara is around September 21 in southern hemisphere', () {
        final date = SabbatType.ostara.getDateForYear(2024);
        expect(date.month, 9);
        expect(date.day, inInclusiveRange(20, 23));
      });

      test('Beltane is October 31 in southern hemisphere', () {
        final date = SabbatType.beltane.getDateForYear(2024);
        expect(date.month, 10);
        expect(date.day, 31);
      });

      test('Litha is around December 21 in southern hemisphere', () {
        final date = SabbatType.litha.getDateForYear(2024);
        expect(date.month, 12);
        expect(date.day, inInclusiveRange(20, 23));
      });

      test('Lammas is February 2 in southern hemisphere', () {
        final date = SabbatType.lammas.getDateForYear(2024);
        expect(date.month, 2);
        expect(date.day, 2);
      });

      test('Mabon is around March 20 in southern hemisphere', () {
        final date = SabbatType.mabon.getDateForYear(2024);
        expect(date.month, 3);
        expect(date.day, inInclusiveRange(19, 21));
      });

      test('all 8 sabbats return valid dates for a given year', () {
        for (final sabbat in SabbatType.values) {
          final date = sabbat.getDateForYear(2025);
          expect(date.year, 2025);
          expect(date.month, inInclusiveRange(1, 12));
          expect(date.day, inInclusiveRange(1, 31));
        }
      });
    });

    test('specific names', () {
      expect(SabbatType.samhain.name, 'Samhain');
      expect(SabbatType.yule.name, 'Yule');
      expect(SabbatType.imbolc.name, 'Imbolc');
      expect(SabbatType.ostara.name, 'Ostara');
      expect(SabbatType.beltane.name, 'Beltane');
      expect(SabbatType.litha.name, 'Litha');
      expect(SabbatType.lammas.name, 'Lammas');
      expect(SabbatType.mabon.name, 'Mabon');
    });
  });

  group('Sabbat', () {
    test('daysUntil calculates difference correctly', () {
      final sabbat = Sabbat(
        type: SabbatType.samhain,
        date: DateTime(2024, 5, 1),
      );
      final now = DateTime(2024, 4, 21);
      expect(sabbat.daysUntil(now), 10);
    });

    test('isPast returns true for past dates', () {
      final sabbat = Sabbat(
        type: SabbatType.samhain,
        date: DateTime(2024, 5, 1),
      );
      final after = DateTime(2024, 5, 2);
      expect(sabbat.isPast(after), isTrue);
    });

    test('isPast returns false for future dates', () {
      final sabbat = Sabbat(
        type: SabbatType.samhain,
        date: DateTime(2024, 5, 1),
      );
      final before = DateTime(2024, 4, 30);
      expect(sabbat.isPast(before), isFalse);
    });

    test('delegates to SabbatType properties', () {
      final sabbat = Sabbat(
        type: SabbatType.yule,
        date: DateTime(2024, 6, 21),
      );
      expect(sabbat.name, SabbatType.yule.name);
      expect(sabbat.emoji, SabbatType.yule.emoji);
      expect(sabbat.description, SabbatType.yule.description);
      expect(sabbat.rituals, SabbatType.yule.rituals);
    });
  });
}
