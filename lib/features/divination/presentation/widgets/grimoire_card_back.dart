import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';

enum _BackSymbol { moon, sun, star, eye, crystal, leaf }

/// Decorative marks follow the original shuffled position, never the face ID.
/// Keeping that position through selection also keeps the back unchanged.
class GrimoireCardBack extends StatelessWidget {
  const GrimoireCardBack({
    super.key,
    required this.width,
    required this.height,
    required this.deckPosition,
    this.highlighted = false,
  }) : assert(deckPosition >= 0);

  final double width;
  final double height;
  final int deckPosition;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      size: Size(width, height),
      painter: _CardBackPainter(
        colors: context.gc,
        symbol: _BackSymbol.values[deckPosition % _BackSymbol.values.length],
        highlighted: highlighted,
      ),
    ),
  );
}

class _CardBackPainter extends CustomPainter {
  const _CardBackPainter({
    required this.colors,
    required this.symbol,
    required this.highlighted,
  });

  final GrimoireColors colors;
  final _BackSymbol symbol;
  final bool highlighted;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final outline = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    final accent = colors.lilac;
    final trim = colors.gold;
    final center = rect.center;
    final w = size.width;

    canvas.drawRRect(outline, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(colors.surface, accent, .10)!,
          colors.surface,
          Color.lerp(colors.surface, colors.background, .35)!,
        ],
      ).createShader(rect));

    // Both borders are painted over the art and remain inside the hit box.
    final borderWidth = highlighted ? 2.5 : 1.5;
    canvas.drawRRect(outline.deflate(borderWidth / 2), Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = accent.withValues(alpha: highlighted ? 1 : .85));
    canvas.drawRRect(outline.deflate(w * .045), Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7
      ..color = trim.withValues(alpha: .5));

    final ornament = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8
      ..color = accent.withValues(alpha: .28);
    canvas.drawCircle(center, w * .30, ornament);
    canvas.drawCircle(center, w * .265,
        ornament..color = trim.withValues(alpha: .32));
    ornament.color = accent.withValues(alpha: .35);
    canvas.drawLine(Offset(center.dx, size.height * .20),
        center - Offset(0, w * .36), ornament);
    canvas.drawLine(center + Offset(0, w * .36),
        Offset(center.dx, size.height * .80), ornament);

    _drawSymbol(canvas, symbol, center, w * .46, accent);
    // Either side of the fan exposes a corner even when the center is covered.
    for (final x in [.14, .86]) {
      for (final y in [.11, .89]) {
        _drawSymbol(canvas, symbol, Offset(w * x, size.height * y),
            w * .17, accent);
      }
    }
    for (final y in [.15, .85]) {
      _drawSymbol(canvas, _BackSymbol.star,
          Offset(center.dx, size.height * y), w * .065, trim);
    }
  }

  /// All six marks share a 24-unit drawing space and the same line weight.
  void _drawSymbol(Canvas canvas, _BackSymbol symbol, Offset center,
      double diameter, Color color) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(diameter / 24);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color.withValues(alpha: .14);

    switch (symbol) {
      case _BackSymbol.moon:
        final moon = Path()
          ..moveTo(4, -10)
          ..cubicTo(-12, -11, -13, 9, 2, 10)
          ..cubicTo(6, 10, 9, 8, 10, 5)
          ..cubicTo(-1, 8, -5, -4, 4, -10)
          ..close();
        canvas.drawPath(moon, fill);
        canvas.drawPath(moon, stroke);
      case _BackSymbol.sun:
        canvas.drawCircle(Offset.zero, 5, fill);
        canvas.drawCircle(Offset.zero, 5, stroke);
        for (var i = 0; i < 8; i++) {
          final angle = i * math.pi / 4;
          final direction = Offset(math.cos(angle), math.sin(angle));
          canvas.drawLine(direction * 8, direction * 11, stroke);
        }
      case _BackSymbol.star:
        final star = Path();
        for (var i = 0; i < 8; i++) {
          final angle = i * math.pi / 4 - math.pi / 2;
          final radius = i.isEven ? 11.0 : 3.5;
          final point = Offset(math.cos(angle), math.sin(angle)) * radius;
          if (i == 0) {
            star.moveTo(point.dx, point.dy);
          } else {
            star.lineTo(point.dx, point.dy);
          }
        }
        star.close();
        canvas.drawPath(star, fill);
        canvas.drawPath(star, stroke);
      case _BackSymbol.eye:
        final eye = Path()
          ..moveTo(-11, 0)
          ..quadraticBezierTo(0, -13, 11, 0)
          ..quadraticBezierTo(0, 13, -11, 0)
          ..close();
        canvas.drawPath(eye, fill);
        canvas.drawPath(eye, stroke);
        canvas.drawCircle(Offset.zero, 3.5, stroke);
        canvas.drawCircle(Offset.zero, 1.2, Paint()..color = color);
      case _BackSymbol.crystal:
        final crystal = Path()
          ..moveTo(0, -11)
          ..lineTo(7, -5)
          ..lineTo(7, 6)
          ..lineTo(0, 11)
          ..lineTo(-7, 6)
          ..lineTo(-7, -5)
          ..close();
        canvas.drawPath(crystal, fill);
        canvas.drawPath(crystal, stroke);
        canvas.drawPath(Path()
          ..moveTo(0, -11)
          ..lineTo(-2, -4)
          ..lineTo(-2, 5)
          ..lineTo(0, 11)
          ..moveTo(-7, -5)
          ..lineTo(-2, -4)
          ..lineTo(7, -5)
          ..moveTo(-7, 6)
          ..lineTo(-2, 5)
          ..lineTo(7, 6), stroke);
      case _BackSymbol.leaf:
        canvas.drawPath(Path()
          ..moveTo(-5, 11)
          ..quadraticBezierTo(1, 3, 2, -10), stroke);
        for (final y in [-6.0, 2.0]) {
          final leaves = Path()
            ..moveTo(0, y + 3)
            ..quadraticBezierTo(-9, y + 3, -9, y - 4)
            ..quadraticBezierTo(-1, y - 4, 0, y + 3)
            ..moveTo(1, y)
            ..quadraticBezierTo(9, y + 1, 10, y - 6)
            ..quadraticBezierTo(3, y - 6, 1, y);
          canvas.drawPath(leaves, fill);
          canvas.drawPath(leaves, stroke);
        }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CardBackPainter oldDelegate) =>
      oldDelegate.colors != colors ||
      oldDelegate.symbol != symbol ||
      oldDelegate.highlighted != highlighted;
}
