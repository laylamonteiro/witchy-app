import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';

/// The advisor's crystal ball drawn in the active palette: base, sphere,
/// reflections and mist. While [active] the mist swirls for as long as the
/// real request lasts; otherwise, and under reduced motion, it rests on the
/// still frame. The loop is a ticker, so TickerMode pauses it off-screen.
class CrystalBallView extends StatefulWidget {
  const CrystalBallView({super.key, this.size = 120, this.active = false});

  final double size;
  final bool active;

  @override
  State<CrystalBallView> createState() => _CrystalBallViewState();
}

class _CrystalBallViewState extends State<CrystalBallView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _mist = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2400));
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = GrimoireMotion.reduced(context);
    _sync();
  }

  @override
  void didUpdateWidget(CrystalBallView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _sync();
  }

  void _sync() {
    if (widget.active && !_reduced) {
      if (!_mist.isAnimating) _mist.repeat();
    } else {
      _mist.stop();
      _mist.value = 0;
    }
  }

  @override
  void dispose() {
    _mist.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AnimatedContainer(
      duration: _reduced ? Duration.zero : GrimoireMotion.state,
      curve: GrimoireMotion.enter,
      width: widget.size,
      height: widget.size * 1.1,
      child: AnimatedBuilder(
        animation: _mist,
        builder: (context, _) => CustomPaint(
          painter: _CrystalBallPainter(
            colors: context.gc,
            phase: _mist.value,
            active: widget.active,
          ),
        ),
      ),
    ),
  );
}

class _CrystalBallPainter extends CustomPainter {
  const _CrystalBallPainter({required this.colors, required this.phase, required this.active});

  final GrimoireColors colors;
  final double phase;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width * .42;
    final center = Offset(size.width / 2, size.width * .46);

    // Base.
    final base = Rect.fromCenter(center: Offset(center.dx, size.height * .9),
        width: r * 1.5, height: r * .5);
    canvas.drawOval(base, Paint()
      ..shader = LinearGradient(colors: [
        Color.lerp(colors.surface, colors.gold, .35)!,
        Color.lerp(colors.surface, colors.background, .4)!,
      ]).createShader(base));
    canvas.drawOval(base.deflate(1), Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = colors.gold.withValues(alpha: .6));

    // Sphere.
    final sphere = Rect.fromCircle(center: center, radius: r);
    canvas.drawCircle(center, r, Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.35, -.4),
        radius: .95,
        colors: [
          Color.lerp(colors.surface, colors.lilac, .55)!,
          Color.lerp(colors.surface, colors.lilac, .25)!,
          Color.lerp(colors.background, colors.lilac, .25)!,
        ],
        stops: const [0, .55, 1],
      ).createShader(sphere));

    // Mist: three arcs drifting with the phase; still and faint when idle.
    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));
    for (var i = 0; i < 3; i++) {
      final angle = phase * math.pi * 2 + i * 2.1;
      final drift = Offset(math.cos(angle) * r * .25, math.sin(angle * .7) * r * .2);
      final alpha = active ? .22 + .12 * math.sin(angle) : .10;
      canvas.drawOval(
        Rect.fromCenter(center: center + drift, width: r * (1.3 - i * .2), height: r * .55),
        Paint()
          ..color = colors.textPrimary.withValues(alpha: alpha.clamp(0.0, 1.0).toDouble())
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * .18),
      );
    }
    canvas.restore();

    // Rim and highlight.
    canvas.drawCircle(center, r, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = colors.lilac.withValues(alpha: .7));
    canvas.drawOval(
      Rect.fromCenter(center: center + Offset(-r * .35, -r * .45), width: r * .5, height: r * .25),
      Paint()..color = colors.textPrimary.withValues(alpha: .35),
    );
  }

  @override
  bool shouldRepaint(_CrystalBallPainter old) =>
      old.phase != phase || old.active != active || old.colors != colors;
}
