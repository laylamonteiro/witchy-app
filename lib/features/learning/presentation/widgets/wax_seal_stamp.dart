import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';

/// A wax seal pressed onto the page: it lands from above, settles with a
/// short overshoot and glows once. Vector-only, in the active palette, with
/// the emblem rendered as text so nothing is baked into art. Reduced motion
/// shows the pressed seal at once.
class WaxSealStamp extends StatelessWidget {
  const WaxSealStamp({
    super.key,
    this.size = 96,
    this.emblem = '✦',
    this.playToken = 0,
  });

  final double size;
  final String emblem;

  /// Changing it replays the stamping.
  final Object playToken;

  @override
  Widget build(BuildContext context) {
    final reduced = GrimoireMotion.reduced(context);
    return TweenAnimationBuilder<double>(
      key: ValueKey(playToken),
      tween: Tween<double>(begin: reduced ? 1 : 0, end: 1),
      duration: reduced ? Duration.zero : GrimoireMotion.celebration,
      curve: Curves.linear,
      builder: (context, t, _) {
        final press = Curves.easeOutBack.transform(t.clamp(0.0, 1.0));
        final scale = 1.6 - .6 * press;
        final glow = math.sin(t * math.pi).clamp(0.0, 1.0);
        return SizedBox(
          width: size,
          height: size,
          child: Opacity(
            opacity: (.2 + .8 * t).clamp(0.0, 1.0),
            child: Transform.scale(
              scale: scale,
              child: CustomPaint(
                painter: _WaxPainter(colors: context.gc, glow: glow),
                child: Center(
                  child: Text(
                    emblem,
                    style: TextStyle(
                      fontSize: size * .34,
                      height: 1,
                      color: context.gc.background.withValues(alpha: .7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WaxPainter extends CustomPainter {
  const _WaxPainter({required this.colors, required this.glow});

  final GrimoireColors colors;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * .42;
    final wax = Path();
    // A slightly irregular blob: twelve lobes with a stable wobble.
    for (var i = 0; i <= 36; i++) {
      final angle = i / 36 * math.pi * 2;
      final wobble = 1 + .06 * math.sin(angle * 6) + .03 * math.cos(angle * 11);
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius * wobble;
      if (i == 0) {
        wax.moveTo(point.dx, point.dy);
      } else {
        wax.lineTo(point.dx, point.dy);
      }
    }
    wax.close();
    if (glow > 0) {
      canvas.drawCircle(center, radius * (1.1 + .3 * glow), Paint()
        ..color = colors.gold.withValues(alpha: .35 * glow)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * .35));
    }
    canvas.drawPath(wax.shift(const Offset(0, 2)), Paint()
      ..color = colors.background.withValues(alpha: .4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawPath(wax, Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.3, -.4),
        colors: [
          Color.lerp(colors.gold, colors.textPrimary, .25)!,
          colors.gold,
          Color.lerp(colors.gold, colors.background, .35)!,
        ],
        stops: const [0, .5, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius)));
    canvas.drawCircle(center, radius * .72, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = colors.background.withValues(alpha: .35));
  }

  @override
  bool shouldRepaint(_WaxPainter old) => old.glow != glow || old.colors != colors;
}
