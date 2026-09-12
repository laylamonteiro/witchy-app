import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/sigils/data/models/sigil_model.dart';
import 'package:grimorio_de_bolso/features/sigils/data/models/sigil_wheel_model.dart';
import 'package:grimorio_de_bolso/features/sigils/domain/sigil_trace.dart';

double drawnLength(Path path) {
  var total = 0.0;
  for (final metric in path.computeMetrics()) {
    total += metric.length;
  }
  return total;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const size = Size(360, 360);
  const intention = 'PROTECAO';

  setUp(SigilTrace.resetCache);

  test('the route is the wheel rule, measured once and reused', () {
    final trace = SigilTrace.of(intention: intention, size: size);
    expect(trace.points, SigilWheel.generateSigilPoints(intention, size));
    expect(trace.length, greaterThan(0));
    expect(identical(SigilTrace.of(intention: intention, size: size), trace), isTrue,
        reason: 'The same data and the same canvas reuse the measurement');
    expect(
        identical(SigilTrace.of(intention: intention, size: const Size(200, 200)), trace),
        isFalse,
        reason: 'A different canvas is measured again');
    expect(identical(SigilTrace.of(intention: 'OUTRA', size: size), trace), isFalse);
  });

  test('progress only reveals a prefix; the finished symbol never changes', () {
    final trace = SigilTrace.of(intention: intention, size: size);
    expect(drawnLength(trace.upTo(0)), 0);
    expect(drawnLength(trace.upTo(.5)), closeTo(trace.length / 2, 0.5));
    expect(drawnLength(trace.upTo(1)), closeTo(trace.length, 0.5));
    expect(drawnLength(trace.upTo(2)), closeTo(trace.length, 0.5),
        reason: 'Beyond the end there is nothing more to draw');
    // Anticipating or watching the whole tracing lands on the same points.
    expect(trace.upTo(1).getBounds(), trace.path.getBounds());
    expect(trace.headAt(0), trace.points.first);
    expect(trace.headAt(1), trace.points.last);
    expect(trace.reachedPoints(0), 0);
    expect(trace.reachedPoints(1), trace.points.length);
    expect(trace.reachedPoints(.5), lessThan(trace.points.length));
  });

  test('while the letters move, the trace follows the interpolated geometry', () {
    // A deliberate arrangement: only P changes place, and by a known angle.
    final moved = Map<String, WheelPosition>.from(SigilWheel.letterPositions);
    moved['P'] = const WheelPosition(ring: 3, angle: 90, index: 3);
    final from = SigilWheel.generateSigilPoints(intention, size);
    final to = SigilWheel.generateSigilPointsWithCustom(intention, size, moved);
    final halfway = SigilTrace.of(
        intention: intention,
        size: size,
        positions: moved,
        previous: SigilWheel.letterPositions,
        blend: .5);
    for (var i = 0; i < from.length; i++) {
      expect(halfway.points[i].dx, closeTo(Offset.lerp(from[i], to[i], .5)!.dx, 0.001));
      expect(halfway.points[i].dy, closeTo(Offset.lerp(from[i], to[i], .5)!.dy, 0.001));
    }
    final settled = SigilTrace.of(
        intention: intention,
        size: size,
        positions: moved,
        previous: SigilWheel.letterPositions,
        blend: 1);
    expect(settled.points, to, reason: 'Arrived, only the new arrangement counts');
  });

  test('an intention with fewer than two letters has nothing to trace', () {
    final trace = SigilTrace.of(intention: 'A', size: size);
    expect(trace.points, hasLength(1));
    expect(drawnLength(trace.upTo(.5)), 0);
    expect(trace.headAt(.5), trace.points.first);
  });

  test('the presentation knows what was removed; the rule decides what stays', () {
    expect(SigilWheel.normalizedLetters('PROTEÇÃO'),
        ['P', 'R', 'O', 'T', 'E', 'C', 'A', 'O']);
    expect(SigilWheel.textToSigilSequence('PROTEÇÃO'),
        ['P', 'R', 'O', 'T', 'E', 'C', 'A'],
        reason: 'The repetition rule is untouched');
    expect(SigilWheel.keptIndexes('PROTEÇÃO'), {0, 1, 2, 3, 4, 5, 6});
    expect(SigilWheel.normalizedLetters('AMOR PRÓPRIO!').join(), 'AMORPROPRIO');
    expect(SigilWheel.keptIndexes('AMOR PRÓPRIO!'), {0, 1, 2, 3, 4, 9},
        reason: 'Only the first occurrence of each letter survives');
    // The kept indexes always spell exactly the sigil's letters.
    for (final text in ['PROTEÇÃO', 'amor próprio!', 'ABRACADABRA', 'lua']) {
      final letters = SigilWheel.normalizedLetters(text);
      final kept = SigilWheel.keptIndexes(text).toList()..sort();
      expect([for (final i in kept) letters[i]], SigilWheel.textToSigilSequence(text));
      expect(Sigil.fromIntention(text).processedLetters,
          SigilWheel.textToSigilSequence(text).join());
    }
  });
}
