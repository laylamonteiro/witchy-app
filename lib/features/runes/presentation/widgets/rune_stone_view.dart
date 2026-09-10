import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';

/// A pebble drawn in the active palette. The shape and speckles follow the
/// original cloth slot ([deckPosition]), never the rune underneath, so a
/// face-down stone gives nothing away and keeps its look once chosen.
/// With a [symbol] the glyph is carved on top; [reversed] turns it over.
class RuneStoneView extends StatelessWidget {
  const RuneStoneView({
    super.key,
    required this.size,
    required this.deckPosition,
    this.symbol,
    this.reversed = false,
    this.highlighted = false,
  }) : assert(deckPosition >= 0);

  final double size;
  final int deckPosition;
  final String? symbol;
  final bool reversed;
  final bool highlighted;

  static const double aspectRatio = 1.08;

  @override
  Widget build(BuildContext context) {
    final height = size / aspectRatio;
    final glyph = symbol;
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(size, height),
        painter: _StonePainter(
          colors: context.gc,
          slot: deckPosition,
          highlighted: highlighted,
          carved: glyph != null,
        ),
        child: SizedBox(
          width: size,
          height: height,
          child: glyph == null
              ? null
              : Center(
                  child: RotatedBox(
                    quarterTurns: reversed ? 2 : 0,
                    child: Text(
                      glyph,
                      style: TextStyle(
                        fontSize: size * .5,
                        height: 1,
                        fontWeight: FontWeight.bold,
                        color: context.gc.gold,
                        shadows: [Shadow(
                          color: context.gc.background.withValues(alpha: .6),
                          blurRadius: 3,
                        )],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _StonePainter extends CustomPainter {
  const _StonePainter({
    required this.colors,
    required this.slot,
    required this.highlighted,
    required this.carved,
  });

  final GrimoireColors colors;
  final int slot;
  final bool highlighted;
  final bool carved;

  /// Four pebble silhouettes, cycled by slot.
  static const _corners = [
    [.52, .46, .48, .54],
    [.44, .55, .50, .42],
    [.50, .42, .56, .46],
    [.46, .50, .44, .56],
  ];

  Path _outline(Size size) {
    final c = _corners[slot % _corners.length];
    final w = size.width;
    return Path()
      ..addRRect(RRect.fromRectAndCorners(
        Offset.zero & size,
        topLeft: Radius.elliptical(w * c[0], size.height * c[0]),
        topRight: Radius.elliptical(w * c[1], size.height * c[1]),
        bottomRight: Radius.elliptical(w * c[2], size.height * c[2]),
        bottomLeft: Radius.elliptical(w * c[3], size.height * c[3]),
      ));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final outline = _outline(size);
    final rect = Offset.zero & size;
    final accent = colors.lilac;

    canvas.drawPath(outline.shift(const Offset(0, 2)), Paint()
      ..color = colors.background.withValues(alpha: .45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawPath(outline, Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.4, -.5),
        radius: 1.1,
        colors: [
          Color.lerp(colors.surface, accent, .22)!,
          colors.surface,
          Color.lerp(colors.surface, colors.background, .45)!,
        ],
        stops: const [0, .55, 1],
      ).createShader(rect));

    // Speckles: a tiny deterministic scatter per slot, no randomness at paint.
    final speck = Paint()..color = accent.withValues(alpha: .28);
    var seed = slot * 7919 + 17;
    for (var i = 0; i < 5; i++) {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      final dx = .2 + (seed % 61) / 100;
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      final dy = .2 + (seed % 61) / 100;
      canvas.drawCircle(Offset(size.width * dx, size.height * dy),
          size.width * .018 + (i % 2) * size.width * .01, speck);
    }

    if (carved) {
      canvas.drawPath(outline, Paint()
        ..shader = RadialGradient(
          radius: .6,
          colors: [colors.gold.withValues(alpha: .18), Colors.transparent],
        ).createShader(rect));
    }

    final borderWidth = highlighted ? 2.5 : 1.2;
    canvas.drawPath(outline, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = highlighted ? accent : colors.surfaceBorder);
    // Rim light along the upper-left edge.
    canvas.save();
    canvas.clipPath(outline);
    canvas.drawCircle(
      Offset(size.width * .32, size.height * .22),
      size.width * .3,
      Paint()
        ..color = colors.textPrimary.withValues(alpha: .10)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * .12),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StonePainter old) =>
      old.colors != colors || old.slot != slot ||
      old.highlighted != highlighted || old.carved != carved;
}

/// Stable decorative jitter for a cloth slot: offset in pixels and a small
/// rotation. Purely visual; the session decides orientation and identity.
class RuneStoneScatter {
  const RuneStoneScatter._();

  static Offset offset(int slot, double scale) {
    final a = math.sin(slot * 12.9898) * 43758.5453;
    final b = math.sin(slot * 78.233) * 12345.678;
    return Offset((a - a.floorToDouble() - .5) * scale,
        (b - b.floorToDouble() - .5) * scale);
  }

  static double angle(int slot) {
    final a = math.sin(slot * 39.346) * 6543.21;
    return (a - a.floorToDouble() - .5) * .5;
  }
}
