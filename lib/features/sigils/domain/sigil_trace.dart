import 'dart:ui';

import '../data/models/sigil_wheel_model.dart';

/// The route the sigil draws through the wheel, measured once. The same
/// intention on the same canvas always yields the same points, and the
/// tracing only ever reveals a prefix of that route: the final symbol never
/// depends on how much of the animation ran. Nothing here decides which
/// letters the intention keeps — that rule lives in [SigilWheel].
class SigilTrace {
  SigilTrace._(this.points, this.path, this.length, this._reached);

  /// The wheel points in order, already interpolated when the letters are
  /// moving between two arrangements.
  final List<Offset> points;

  /// The complete path, from the first point to the last.
  final Path path;

  /// Total length of [path], in logical pixels.
  final double length;

  /// Distance travelled when each point is reached.
  final List<double> _reached;

  static SigilTrace? _cached;
  static _TraceKey? _cachedKey;

  /// Builds (or reuses) the trace for [intention] on a canvas of [size].
  ///
  /// [positions] and [previous] are wheel arrangements; while letters move
  /// from one to the other, [blend] interpolates every point. Only a settled
  /// arrangement is cached — during the movement the geometry changes each
  /// frame, and rebuilding it is a handful of lerps.
  static SigilTrace of({
    required String intention,
    required Size size,
    Map<String, WheelPosition>? positions,
    Map<String, WheelPosition>? previous,
    double blend = 1,
  }) {
    final settled = previous == null || blend >= 1;
    if (settled) {
      final key = _TraceKey(intention, size, positions);
      final cached = _cached;
      if (cached != null && _cachedKey == key) return cached;
      final built = _build(pointsFor(
          intention: intention, size: size, positions: positions));
      _cached = built;
      _cachedKey = key;
      return built;
    }
    return _build(pointsFor(
        intention: intention, size: size, positions: positions,
        previous: previous, blend: blend));
  }

  /// The wheel points for this intention, interpolated between arrangements
  /// when the letters are moving. Uses the existing wheel rules untouched.
  static List<Offset> pointsFor({
    required String intention,
    required Size size,
    Map<String, WheelPosition>? positions,
    Map<String, WheelPosition>? previous,
    double blend = 1,
  }) {
    final target =
        SigilWheel.generateSigilPointsWithCustom(intention, size, positions);
    if (previous == null || blend >= 1) return target;
    final from =
        SigilWheel.generateSigilPointsWithCustom(intention, size, previous);
    if (from.length != target.length) return target;
    final t = blend.clamp(0.0, 1.0).toDouble();
    return [
      for (var i = 0; i < target.length; i++) Offset.lerp(from[i], target[i], t)!,
    ];
  }

  static SigilTrace _build(List<Offset> points) {
    final path = Path();
    final reached = <double>[];
    if (points.isEmpty) return SigilTrace._(points, path, 0, reached);
    path.moveTo(points.first.dx, points.first.dy);
    reached.add(0);
    var travelled = 0.0;
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
      travelled += (points[i] - points[i - 1]).distance;
      reached.add(travelled);
    }
    return SigilTrace._(points, path, travelled, reached);
  }

  /// The path drawn so far, for a [progress] between 0 and 1. At 1 it is the
  /// complete path — the state every export and every saved image uses.
  Path upTo(double progress) {
    if (points.length < 2) return path;
    final t = progress.clamp(0.0, 1.0).toDouble();
    if (t >= 1) return path;
    if (t <= 0 || length <= 0) return Path();
    final target = length * t;
    final drawn = Path();
    var travelled = 0.0;
    for (final metric in path.computeMetrics()) {
      if (travelled + metric.length <= target) {
        drawn.addPath(metric.extractPath(0, metric.length), Offset.zero);
        travelled += metric.length;
      } else {
        drawn.addPath(metric.extractPath(0, target - travelled), Offset.zero);
        break;
      }
    }
    return drawn;
  }

  /// How many points the tracing has already touched at [progress].
  int reachedPoints(double progress) {
    if (points.isEmpty) return 0;
    final t = progress.clamp(0.0, 1.0).toDouble();
    if (t >= 1) return points.length;
    if (t <= 0) return 0;
    final target = length * t;
    var count = 0;
    for (final at in _reached) {
      if (at <= target) count++;
    }
    return count;
  }

  /// Where the tracing point sits at [progress], for the moving head.
  Offset headAt(double progress) {
    if (points.isEmpty) return Offset.zero;
    final t = progress.clamp(0.0, 1.0).toDouble();
    if (t >= 1 || points.length < 2 || length <= 0) return points.last;
    if (t <= 0) return points.first;
    final target = length * t;
    for (var i = 1; i < points.length; i++) {
      if (_reached[i] >= target) {
        final span = _reached[i] - _reached[i - 1];
        final within = span <= 0 ? 1.0 : (target - _reached[i - 1]) / span;
        return Offset.lerp(points[i - 1], points[i], within)!;
      }
    }
    return points.last;
  }

  /// Forgets the measured route. Only tests need this.
  static void resetCache() {
    _cached = null;
    _cachedKey = null;
  }
}

class _TraceKey {
  const _TraceKey(this.intention, this.size, this.positions);

  final String intention;
  final Size size;
  final Map<String, WheelPosition>? positions;

  @override
  bool operator ==(Object other) =>
      other is _TraceKey &&
      other.intention == intention &&
      other.size == size &&
      identical(other.positions, positions);

  @override
  int get hashCode => Object.hash(intention, size, identityHashCode(positions));
}
