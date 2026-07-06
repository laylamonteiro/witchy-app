import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/utils/input_formatters.dart';

void main() {
  group('parseDate', () {
    test('parses valid date string', () {
      final result = parseDate('15/06/2000');
      expect(result, isNotNull);
      expect(result!.day, 15);
      expect(result.month, 6);
      expect(result.year, 2000);
    });

    test('returns null for invalid format', () {
      expect(parseDate('15-06-2000'), isNull);
      expect(parseDate('15/06'), isNull);
      expect(parseDate('abc'), isNull);
      expect(parseDate(''), isNull);
    });

    test('returns null for out-of-range day', () {
      expect(parseDate('00/06/2000'), isNull);
      expect(parseDate('32/06/2000'), isNull);
    });

    test('returns null for out-of-range month', () {
      expect(parseDate('15/00/2000'), isNull);
      expect(parseDate('15/13/2000'), isNull);
    });

    test('returns null for out-of-range year', () {
      expect(parseDate('15/06/1899'), isNull);
    });

    test('returns null for invalid calendar date like 31/02', () {
      expect(parseDate('31/02/2000'), isNull);
    });

    test('handles leap year correctly', () {
      final result = parseDate('29/02/2000');
      expect(result, isNotNull);
      expect(result!.day, 29);
    });

    test('rejects Feb 29 on non-leap year', () {
      expect(parseDate('29/02/2001'), isNull);
    });
  });

  group('parseTime', () {
    test('parses valid time string', () {
      final result = parseTime('14:30');
      expect(result, isNotNull);
      expect(result!.hour, 14);
      expect(result.minute, 30);
    });

    test('parses midnight', () {
      final result = parseTime('00:00');
      expect(result, isNotNull);
      expect(result!.hour, 0);
      expect(result.minute, 0);
    });

    test('parses end of day', () {
      final result = parseTime('23:59');
      expect(result, isNotNull);
      expect(result!.hour, 23);
      expect(result.minute, 59);
    });

    test('returns null for invalid format', () {
      expect(parseTime('14-30'), isNull);
      expect(parseTime('14'), isNull);
      expect(parseTime('abc'), isNull);
      expect(parseTime(''), isNull);
    });

    test('returns null for out-of-range hour', () {
      expect(parseTime('24:00'), isNull);
      expect(parseTime('-1:00'), isNull);
    });

    test('returns null for out-of-range minute', () {
      expect(parseTime('14:60'), isNull);
      expect(parseTime('14:-1'), isNull);
    });
  });

  group('formatDate', () {
    test('formats date with padding', () {
      final date = DateTime(2000, 6, 5);
      expect(formatDate(date), '05/06/2000');
    });

    test('formats date without padding needed', () {
      final date = DateTime(2000, 12, 25);
      expect(formatDate(date), '25/12/2000');
    });
  });

  group('formatTime', () {
    test('formats time with padding', () {
      const time = TimeOfDay(hour: 5, minute: 3);
      expect(formatTime(time), '05:03');
    });

    test('formats time without padding needed', () {
      const time = TimeOfDay(hour: 14, minute: 30);
      expect(formatTime(time), '14:30');
    });

    test('formats midnight', () {
      const time = TimeOfDay(hour: 0, minute: 0);
      expect(formatTime(time), '00:00');
    });
  });

  group('DateInputFormatter', () {
    late DateInputFormatter formatter;

    setUp(() {
      formatter = DateInputFormatter();
    });

    test('adds slash after day digits', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '150',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );
      expect(result.text, '15/0');
    });

    test('adds slash after month digits', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '15062',
          selection: TextSelection.collapsed(offset: 5),
        ),
      );
      expect(result.text, '15/06/2');
    });

    test('limits to 8 digits', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '150620001',
          selection: TextSelection.collapsed(offset: 9),
        ),
      );
      expect(result.text, '15/06/2000');
    });

    test('strips non-digit characters', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '1a5b0c6',
          selection: TextSelection.collapsed(offset: 7),
        ),
      );
      expect(result.text, '15/06');
    });
  });

  group('TimeInputFormatter', () {
    late TimeInputFormatter formatter;

    setUp(() {
      formatter = TimeInputFormatter();
    });

    test('adds colon after hour digits', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '143',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );
      expect(result.text, '14:3');
    });

    test('limits to 4 digits', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '14305',
          selection: TextSelection.collapsed(offset: 5),
        ),
      );
      expect(result.text, '14:30');
    });

    test('strips non-digit characters', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '1a4b3',
          selection: TextSelection.collapsed(offset: 5),
        ),
      );
      expect(result.text, '14:3');
    });
  });
}
