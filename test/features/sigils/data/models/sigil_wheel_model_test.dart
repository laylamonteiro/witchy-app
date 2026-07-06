import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/sigils/data/models/sigil_wheel_model.dart';

void main() {
  group('SigilWheel', () {
    group('textToSigilSequence', () {
      test('converts text to unique uppercase letters', () {
        final result = SigilWheel.textToSigilSequence('AMOR');
        expect(result, ['A', 'M', 'O', 'R']);
      });

      test('removes duplicate letters', () {
        final result = SigilWheel.textToSigilSequence('AABBC');
        expect(result, ['A', 'B', 'C']);
      });

      test('removes spaces and non-alphabetic characters', () {
        final result = SigilWheel.textToSigilSequence('A M O R!');
        expect(result, ['A', 'M', 'O', 'R']);
      });

      test('handles lowercase input', () {
        final result = SigilWheel.textToSigilSequence('amor');
        expect(result, ['A', 'M', 'O', 'R']);
      });

      test('normalizes accented characters', () {
        final result = SigilWheel.textToSigilSequence('proteção');
        expect(result, ['P', 'R', 'O', 'T', 'E', 'C', 'A']);
      });

      test('handles empty string', () {
        final result = SigilWheel.textToSigilSequence('');
        expect(result, isEmpty);
      });

      test('handles string with only spaces', () {
        final result = SigilWheel.textToSigilSequence('   ');
        expect(result, isEmpty);
      });

      test('handles string with only numbers', () {
        final result = SigilWheel.textToSigilSequence('12345');
        expect(result, isEmpty);
      });

      test('handles cedilla', () {
        final result = SigilWheel.textToSigilSequence('Ç');
        expect(result, ['C']);
      });

      test('handles tilde on N', () {
        final result = SigilWheel.textToSigilSequence('Ñ');
        expect(result, ['N']);
      });
    });

    group('letterPositions', () {
      test('contains all 26 letters', () {
        expect(SigilWheel.letterPositions.length, 26);
        for (int i = 0; i < 26; i++) {
          final letter = String.fromCharCode('A'.codeUnitAt(0) + i);
          expect(SigilWheel.letterPositions.containsKey(letter), isTrue,
              reason: 'Missing letter: $letter');
        }
      });

      test('inner ring has 6 letters (A-F)', () {
        final inner = SigilWheel.letterPositions.entries
            .where((e) => e.value.ring == 1)
            .toList();
        expect(inner.length, 6);
      });

      test('middle ring has 8 letters (G-N)', () {
        final middle = SigilWheel.letterPositions.entries
            .where((e) => e.value.ring == 2)
            .toList();
        expect(middle.length, 8);
      });

      test('outer ring has 12 letters (O-Z)', () {
        final outer = SigilWheel.letterPositions.entries
            .where((e) => e.value.ring == 3)
            .toList();
        expect(outer.length, 12);
      });
    });

    group('generateSigilPoints', () {
      test('generates correct number of points', () {
        const canvasSize = Size(360, 360);
        final points =
            SigilWheel.generateSigilPoints('AMOR', canvasSize);
        expect(points.length, 4);
      });

      test('all points are within canvas bounds', () {
        const canvasSize = Size(360, 360);
        final points =
            SigilWheel.generateSigilPoints('ABCDEFGHIJKLMNOPQRSTUVWXYZ', canvasSize);
        for (final point in points) {
          expect(point.dx, greaterThanOrEqualTo(0));
          expect(point.dx, lessThanOrEqualTo(360));
          expect(point.dy, greaterThanOrEqualTo(0));
          expect(point.dy, lessThanOrEqualTo(360));
        }
      });

      test('returns empty for empty text', () {
        const canvasSize = Size(360, 360);
        final points = SigilWheel.generateSigilPoints('', canvasSize);
        expect(points, isEmpty);
      });
    });

    group('getCanvasPosition', () {
      test('returns center for unknown letter', () {
        const canvasSize = Size(360, 360);
        final pos = SigilWheel.getCanvasPosition('1', canvasSize);
        expect(pos.dx, 180);
        expect(pos.dy, 180);
      });

      test('inner ring letters are closer to center', () {
        const canvasSize = Size(360, 360);
        final center = const Offset(180, 180);
        final innerPos = SigilWheel.getCanvasPosition('A', canvasSize);
        final outerPos = SigilWheel.getCanvasPosition('Z', canvasSize);

        final innerDist = (innerPos - center).distance;
        final outerDist = (outerPos - center).distance;
        expect(innerDist, lessThan(outerDist));
      });
    });

    group('generateShuffledPositions', () {
      test('returns 26 positions', () {
        final shuffled = SigilWheel.generateShuffledPositions();
        expect(shuffled.length, 26);
      });

      test('keeps letters in their original rings', () {
        final shuffled = SigilWheel.generateShuffledPositions();
        for (final letter in SigilWheel.innerRingLetters) {
          expect(shuffled[letter]!.ring, 1);
        }
        for (final letter in SigilWheel.middleRingLetters) {
          expect(shuffled[letter]!.ring, 2);
        }
        for (final letter in SigilWheel.outerRingLetters) {
          expect(shuffled[letter]!.ring, 3);
        }
      });
    });
  });

  group('SigilData', () {
    test('fromText creates correct sigil data', () {
      const canvasSize = Size(360, 360);
      final data = SigilData.fromText('AMOR', canvasSize, intention: 'Love');

      expect(data.originalText, 'AMOR');
      expect(data.processedText, 'AMOR');
      expect(data.sequence, ['A', 'M', 'O', 'R']);
      expect(data.points.length, 4);
      expect(data.intention, 'Love');
      expect(data.createdAt, isNotNull);
    });

    test('fromText removes duplicates in processed text', () {
      const canvasSize = Size(360, 360);
      final data = SigilData.fromText('AABBCC', canvasSize);
      expect(data.processedText, 'ABC');
      expect(data.sequence, ['A', 'B', 'C']);
    });
  });

  group('WheelPosition', () {
    test('stores ring, angle, and index', () {
      const pos = WheelPosition(ring: 2, angle: 90, index: 3);
      expect(pos.ring, 2);
      expect(pos.angle, 90);
      expect(pos.index, 3);
    });
  });
}
