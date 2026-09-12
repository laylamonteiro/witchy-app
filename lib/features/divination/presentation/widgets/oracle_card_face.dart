import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../tarot/presentation/widgets/tarot_card_view.dart';
import '../../data/models/oracle_card_model.dart';
import '../oracle_art_registry.dart';

/// The illustrated front of an Oracle card. Uses the registry asset when it
/// exists and otherwise the vector frame with the card's emoji as figure.
/// The name is rendered by the UI, never baked into art. [sceneProgress]
/// 0..1 drives the card's own small action; 1 is the static final frame.
class OracleCardFace extends StatelessWidget {
  const OracleCardFace({
    super.key,
    required this.card,
    this.width = 110,
    this.sceneProgress = 1,
    this.highlighted = false,
  });

  final OracleCard card;
  final double width;
  final double sceneProgress;
  final bool highlighted;

  static const double aspectRatio = TarotCardView.aspectRatio;

  @override
  Widget build(BuildContext context) {
    final height = width / aspectRatio;
    final art = OracleArtRegistry.of(card.id);
    final colors = context.gc;
    final asset = art.assetPath;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlighted ? colors.lilac : colors.surfaceBorder,
          width: highlighted ? 2 : 1,
        ),
        boxShadow: [BoxShadow(
          color: colors.lilac.withValues(alpha: highlighted ? .35 : .18),
          blurRadius: highlighted ? 14 : 10,
        )],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(colors.surface, colors.lilac, .16)!,
            colors.surface,
            Color.lerp(colors.surface, colors.background, .3)!,
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Column(children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(width * .06),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.gold.withValues(alpha: .5), width: .8),
                ),
                child: Stack(fit: StackFit.expand, children: [
                  if (asset != null)
                    Image.asset(asset, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _Figure(card: card, width: width))
                  else
                    _Figure(card: card, width: width),
                  if (art.hasScene)
                    IgnorePointer(child: CustomPaint(
                      painter: _ScenePainter(
                          scene: art.scene, t: sceneProgress.clamp(0.0, 1.0).toDouble(),
                          colors: colors),
                    )),
                ]),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(width * .06, 0, width * .06, width * .07),
            child: Text(
              card.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: width * .1,
                height: 1.15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.card, required this.width});
  final OracleCard card;
  final double width;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(card.emoji, style: TextStyle(fontSize: width * .34, height: 1)),
  );
}

/// One-shot action of the focused card. Plays 0→1 whenever [playToken]
/// changes; reduced motion and other cards show the final frame.
class OracleSceneCard extends StatelessWidget {
  const OracleSceneCard({
    super.key,
    required this.card,
    required this.playToken,
    this.width = 150,
    this.highlighted = false,
  });

  final OracleCard card;
  final Object playToken;
  final double width;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final reduced = GrimoireMotion.reduced(context);
    return TweenAnimationBuilder<double>(
      key: ValueKey(playToken),
      tween: Tween<double>(begin: reduced ? 1 : 0, end: 1),
      duration: reduced ? Duration.zero : GrimoireMotion.celebration,
      curve: GrimoireMotion.enter,
      builder: (context, t, _) => OracleCardFace(
        card: card, width: width, sceneProgress: t, highlighted: highlighted,
      ),
    );
  }
}

/// Brief vector actions drawn over the figure. Every scene ends on a still
/// frame at t = 1; nothing loops.
class _ScenePainter extends CustomPainter {
  const _ScenePainter({required this.scene, required this.t, required this.colors});

  final OracleScene scene;
  final double t;
  final GrimoireColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    switch (scene) {
      case OracleScene.none:
        return;
      case OracleScene.candle:
        _candle(canvas, size);
      case OracleScene.cauldron:
        _cauldron(canvas, size);
      case OracleScene.cat:
        _cat(canvas, size);
      case OracleScene.seed:
        _seed(canvas, size);
      case OracleScene.key:
        _key(canvas, size);
      case OracleScene.door:
        _door(canvas, size);
    }
  }

  void _candle(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .32);
    final radius = size.shortestSide * (.12 + .38 * t);
    canvas.drawCircle(center, radius, Paint()
      ..shader = RadialGradient(colors: [
        colors.gold.withValues(alpha: .45 * t), colors.gold.withValues(alpha: 0),
      ]).createShader(Rect.fromCircle(center: center, radius: radius)));
    final flame = Path()
      ..moveTo(center.dx, center.dy - size.height * .14 * t)
      ..quadraticBezierTo(center.dx + size.width * .07 * t, center.dy - size.height * .02,
          center.dx, center.dy + size.height * .04)
      ..quadraticBezierTo(center.dx - size.width * .07 * t, center.dy - size.height * .02,
          center.dx, center.dy - size.height * .14 * t);
    canvas.drawPath(flame, Paint()..color = colors.gold.withValues(alpha: .85 * t));
  }

  void _cauldron(Canvas canvas, Size size) {
    for (var i = 0; i < 5; i++) {
      final p = ((t * 1.4) - i * .12).clamp(0.0, 1.0);
      if (p <= 0) continue;
      final x = size.width * (.3 + .1 * i) + math.sin(p * math.pi * 2 + i) * size.width * .03;
      final y = size.height * (.72 - .5 * p);
      canvas.drawCircle(Offset(x, y), size.width * (.025 + .012 * (i % 3)), Paint()
        ..color = colors.lilac.withValues(alpha: (.7 * (1 - p)).clamp(0.0, 1.0).toDouble())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2);
    }
  }

  void _cat(Canvas canvas, Size size) {
    final open = Curves.easeOutBack.transform(t).clamp(0.0, 1.0);
    for (final x in [size.width * .4, size.width * .6]) {
      final rect = Rect.fromCenter(center: Offset(x, size.height * .36),
          width: size.width * .11, height: size.width * .11 * open);
      canvas.drawOval(rect, Paint()..color = colors.gold.withValues(alpha: .9));
      canvas.drawOval(Rect.fromCenter(center: rect.center,
          width: rect.width * .22, height: rect.height * .85),
          Paint()..color = colors.background.withValues(alpha: .95));
    }
  }

  void _seed(Canvas canvas, Size size) {
    final base = Offset(size.width / 2, size.height * .78);
    final top = Offset(base.dx, base.dy - size.height * .42 * t);
    canvas.drawLine(base, top, Paint()
      ..color = colors.lilac
      ..strokeWidth = size.width * .025
      ..strokeCap = StrokeCap.round);
    final leaf = ((t - .55) / .45).clamp(0.0, 1.0);
    if (leaf <= 0) return;
    for (final side in [-1, 1]) {
      final origin = Offset(top.dx, top.dy + size.height * .1);
      final path = Path()
        ..moveTo(origin.dx, origin.dy)
        ..quadraticBezierTo(origin.dx + side * size.width * .12 * leaf,
            origin.dy - size.height * .1 * leaf,
            origin.dx + side * size.width * .16 * leaf, origin.dy)
        ..quadraticBezierTo(origin.dx + side * size.width * .09 * leaf,
            origin.dy + size.height * .05 * leaf, origin.dx, origin.dy);
      canvas.drawPath(path, Paint()..color = colors.lilac.withValues(alpha: .85));
    }
  }

  void _key(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .62);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 2 * Curves.easeInOutCubic.transform(t));
    final paint = Paint()
      ..color = colors.gold.withValues(alpha: .85)
      ..strokeWidth = size.width * .03
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(-size.width * .12, 0), size.width * .06, paint);
    canvas.drawLine(Offset(-size.width * .06, 0), Offset(size.width * .16, 0), paint);
    canvas.drawLine(Offset(size.width * .16, 0), Offset(size.width * .16, size.width * .06), paint);
    canvas.drawLine(Offset(size.width * .10, 0), Offset(size.width * .10, size.width * .045), paint);
    canvas.restore();
  }

  void _door(Canvas canvas, Size size) {
    final frame = Rect.fromCenter(center: Offset(size.width / 2, size.height * .5),
        width: size.width * .34, height: size.height * .5);
    final light = Path()
      ..moveTo(frame.left, frame.top)
      ..lineTo(frame.left + frame.width * (.15 + .85 * t), frame.top + frame.height * .1 * (1 - t))
      ..lineTo(frame.left + frame.width * (.15 + .85 * t), frame.bottom - frame.height * .1 * (1 - t))
      ..lineTo(frame.left, frame.bottom)
      ..close();
    canvas.drawPath(light, Paint()..color = colors.gold.withValues(alpha: .35 * t));
    final panel = Rect.fromLTWH(frame.left, frame.top,
        frame.width * (1 - .65 * t), frame.height);
    canvas.drawRRect(RRect.fromRectAndRadius(panel, Radius.circular(size.width * .02)), Paint()
      ..color = colors.background.withValues(alpha: .55)
      ..style = PaintingStyle.fill);
    canvas.drawRRect(RRect.fromRectAndRadius(frame, Radius.circular(size.width * .02)), Paint()
      ..color = colors.gold.withValues(alpha: .6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(_ScenePainter old) =>
      old.scene != scene || old.t != t || old.colors != colors;
}
