import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';

/// Variations are tied to the original slot, never to the hidden rune.
class RuneStone extends StatelessWidget {
  const RuneStone({super.key, required this.slot, this.size = 64,
    this.symbol, this.reversed = false, this.highlighted = false});
  final int slot;
  final double size;
  final String? symbol;
  final bool reversed;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      painter: _StonePainter(context.gc.surface, context.gc.lilac,
          context.gc.gold, slot, highlighted),
      child: SizedBox.square(dimension: size, child: Center(
        child: ExcludeSemantics(child: Transform.rotate(
          angle: reversed ? math.pi : 0,
          child: Text(symbol ?? '', style: TextStyle(
              fontSize: size * .46, height: 1, color: context.gc.textPrimary)),
        )),
      )),
    ),
  );
}

class _StonePainter extends CustomPainter {
  const _StonePainter(this.surface, this.accent, this.gold, this.slot, this.focused);
  final Color surface, accent, gold;
  final int slot;
  final bool focused;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width, size.height);
    final v = (slot % 4) * .012;
    final outline = Path()
      ..moveTo(.30 + v, .085)
      ..cubicTo(.58, .035, .87, .11 + v, .91, .36)
      ..cubicTo(.97, .62, .87 - v, .88, .64, .925)
      ..cubicTo(.38, .975, .13, .88 - v, .09, .63)
      ..cubicTo(.02, .39, .12, .14, .30 + v, .085)
      ..close();
    canvas.drawShadow(outline, Colors.black.withValues(alpha: .45), .035, true);
    canvas.drawPath(outline, Paint()..shader = LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color.lerp(surface, accent, .30)!, surface,
        Color.lerp(surface, Colors.black, .18)!],
    ).createShader(const Rect.fromLTWH(0, 0, 1, 1)));
    canvas.drawPath(outline, Paint()
      ..style = PaintingStyle.stroke ..strokeWidth = focused ? .027 : .016
      ..color = focused ? accent : gold.withValues(alpha: .55));
    final edge = Path()..moveTo(.17, .38)
      ..quadraticBezierTo(.20, .16, .42, .14)
      ..quadraticBezierTo(.70, .10, .83, .30);
    canvas.drawPath(edge, Paint()..style = PaintingStyle.stroke
      ..strokeWidth = .013 ..color = accent.withValues(alpha: .30));
    final vein = Path()..moveTo(.19, .62 + v)
      ..quadraticBezierTo(.29, .68, .32, .81)
      ..moveTo(.74, .21)..quadraticBezierTo(.65, .28, .71, .36);
    canvas.drawPath(vein, Paint()..style = PaintingStyle.stroke
      ..strokeWidth = .01 ..color = gold.withValues(alpha: .18));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StonePainter old) => surface != old.surface ||
      accent != old.accent || gold != old.gold || slot != old.slot || focused != old.focused;
}

class RuneCloth extends StatelessWidget {
  const RuneCloth({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: RadialGradient(radius: .9, colors: [
        Color.lerp(context.gc.surface, context.gc.lilac, .10)!, context.gc.background,
      ]),
    ),
    child: CustomPaint(painter: _ClothPainter(context.gc.lilac, context.gc.gold),
        child: Padding(padding: const EdgeInsets.all(12), child: child)),
  );
}

class _ClothPainter extends CustomPainter {
  const _ClothPainter(this.accent, this.gold);
  final Color accent, gold;
  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(bounds, const Radius.circular(24)));
    final thread = Paint()..color = accent.withValues(alpha: .035)..strokeWidth = 1;
    for (double x = -size.height; x < size.width; x += 14) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), thread);
    }
    canvas.drawRRect(RRect.fromRectAndRadius(bounds.deflate(5), const Radius.circular(20)),
        Paint()..style = PaintingStyle.stroke..strokeWidth = 1
          ..color = gold.withValues(alpha: .25));
    canvas.drawRRect(RRect.fromRectAndRadius(bounds.deflate(9), const Radius.circular(16)),
        Paint()..style = PaintingStyle.stroke..strokeWidth = .5
          ..color = accent.withValues(alpha: .20));
    canvas.restore();
  }
  @override
  bool shouldRepaint(_ClothPainter old) => old.accent != accent || old.gold != gold;
}

class RunePouch extends StatelessWidget {
  const RunePouch({super.key, required this.open});
  final double open;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: CustomPaint(
    size: const Size(72, 56),
    painter: _PouchPainter(context.gc.surface, context.gc.lilac, context.gc.gold, open),
  ));
}

class _PouchPainter extends CustomPainter {
  const _PouchPainter(this.surface, this.accent, this.gold, this.open);
  final Color surface, accent, gold;
  final double open;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 72, size.height / 56);
    final body = Path()..moveTo(21, 12)..quadraticBezierTo(8, 29, 14, 43)
      ..cubicTo(22, 56, 55, 56, 59, 41)..quadraticBezierTo(62, 26, 51, 12)..close();
    canvas.drawPath(body, Paint()..color = Color.lerp(surface, accent, .2)!);
    canvas.drawPath(body, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2
      ..color = gold.withValues(alpha: .65));
    final mouth = Rect.fromCenter(center: const Offset(36, 12), width: 14 + 22 * open,
        height: 3 + 7 * open);
    canvas.drawOval(mouth, Paint()..color = surface);
    canvas.drawOval(mouth, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.4..color = gold);
    final cord = Path()..moveTo(mouth.left, 12)..quadraticBezierTo(10, 8, 7, 22)
      ..moveTo(mouth.right, 12)..quadraticBezierTo(65, 8, 68, 22);
    canvas.drawPath(cord, Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = gold);
    canvas.drawCircle(const Offset(36, 34), 8, Paint()..color = gold.withValues(alpha: .6));
    canvas.drawCircle(const Offset(40, 31), 7, Paint()..color = Color.lerp(surface, accent, .2)!);
    canvas.restore();
  }
  @override
  bool shouldRepaint(_PouchPainter old) => surface != old.surface ||
      accent != old.accent || gold != old.gold || open != old.open;
}
