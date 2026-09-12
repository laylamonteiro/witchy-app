import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';

/// The ritual circle: one arc per step, lit as the step is completed. When
/// every arc is lit the circle closes with a single glow. Segments follow
/// the persisted checklist, never the other way around; reduced motion
/// shows the final state.
class RitualCircle extends StatelessWidget {
  const RitualCircle({
    super.key,
    required this.steps,
    required this.lit,
    this.size = 88,
    this.emblem,
  });

  final int steps;
  final int lit;
  final double size;
  final String? emblem;

  bool get isClosed => steps > 0 && lit >= steps;

  @override
  Widget build(BuildContext context) {
    final reduced = GrimoireMotion.reduced(context);
    return Semantics(
      // Nó próprio: lado a lado, dois círculos não podem virar um rótulo só.
      container: true,
      label: '$lit/$steps',
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: lit.toDouble()),
        duration: reduced ? Duration.zero : GrimoireMotion.state,
        curve: GrimoireMotion.enter,
        builder: (context, litNow, _) => TweenAnimationBuilder<double>(
          tween: Tween<double>(end: isClosed ? 1 : 0),
          duration: reduced ? Duration.zero : GrimoireMotion.celebration,
          curve: GrimoireMotion.enter,
          builder: (context, closed, __) => SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _CirclePainter(
                colors: context.gc, steps: steps, lit: litNow, closed: closed),
              // O emblema é decoração: lido em voz alta, ele viraria parte
              // do rótulo do círculo, que precisa dizer só o progresso.
              child: emblem == null
                  ? null
                  : ExcludeSemantics(
                      child: Center(child: Text(emblem!,
                          style: TextStyle(fontSize: size * .3, height: 1))),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  const _CirclePainter({
    required this.colors,
    required this.steps,
    required this.lit,
    required this.closed,
  });

  final GrimoireColors colors;
  final int steps;
  final double lit;
  final double closed;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * .42;
    final rect = Rect.fromCircle(center: center, radius: radius);
    if (closed > 0) {
      canvas.drawCircle(center, radius * (1 + .15 * closed), Paint()
        ..color = colors.gold.withValues(alpha: .35 * math.sin(closed * math.pi))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * .3));
    }
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * .07
      ..strokeCap = StrokeCap.round
      ..color = colors.surfaceBorder;
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * .07
      ..strokeCap = StrokeCap.round
      ..color = Color.lerp(colors.lilac, colors.gold, closed)!;
    if (steps <= 0) {
      canvas.drawCircle(center, radius, track);
      return;
    }
    final gap = steps == 1 ? 0.0 : .18;
    final sweep = math.pi * 2 / steps - gap;
    for (var i = 0; i < steps; i++) {
      final start = -math.pi / 2 + i * (sweep + gap);
      canvas.drawArc(rect, start, sweep, false, track);
      final portion = (lit - i).clamp(0.0, 1.0);
      if (portion > 0) canvas.drawArc(rect, start, sweep * portion, false, glow);
    }
    if (closed >= 1) {
      canvas.drawCircle(center, radius, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = colors.gold.withValues(alpha: .8));
    }
  }

  @override
  bool shouldRepaint(_CirclePainter old) =>
      old.steps != steps || old.lit != lit || old.closed != closed || old.colors != colors;
}
