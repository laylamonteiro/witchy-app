import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';

/// A mão sob leitura: a silhueta e as linhas desenhadas na paleta ativa,
/// com uma faixa de luz que percorre a palma enquanto a análise real dura.
///
/// A faixa é um ticker — o `TickerMode` a suspende fora da tela — e só anda
/// enquanto [active]. Parada, a mão continua legível: com movimento
/// reduzido, ou sem requisição em voo, é uma ilustração estática. Nada aqui
/// lê a foto nem produz resultado.
class PalmScanView extends StatefulWidget {
  const PalmScanView({super.key, this.size = 160, this.active = false});

  final double size;
  final bool active;

  @override
  State<PalmScanView> createState() => _PalmScanViewState();
}

class _PalmScanViewState extends State<PalmScanView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800));
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = GrimoireMotion.reduced(context);
    _sync();
  }

  @override
  void didUpdateWidget(PalmScanView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _sync();
  }

  void _sync() {
    if (widget.active && !_reduced) {
      if (!_sweep.isAnimating) _sweep.repeat();
    } else {
      _sweep.stop();
      _sweep.value = 0;
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: AnimatedBuilder(
          animation: _sweep,
          builder: (context, _) => CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _PalmPainter(
              colors: context.gc,
              phase: _sweep.value,
              active: widget.active,
            ),
          ),
        ),
      );
}

class _PalmPainter extends CustomPainter {
  const _PalmPainter({
    required this.colors,
    required this.phase,
    required this.active,
  });

  final GrimoireColors colors;
  final double phase;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = math.min(size.width, size.height);
    final centre = Offset(size.width / 2, size.height / 2);

    // Palma: um quadrado de cantos muito arredondados.
    final palm = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: centre.translate(0, unit * .12),
          width: unit * .52,
          height: unit * .5),
      Radius.circular(unit * .16),
    );
    canvas.drawRRect(
        palm,
        Paint()
          ..color = colors.lilac.withValues(alpha: .10)
          ..style = PaintingStyle.fill);
    canvas.drawRRect(
        palm,
        Paint()
          ..color = colors.lilac.withValues(alpha: .55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4);

    // Quatro dedos e o polegar, como cápsulas.
    final fingerPaint = Paint()
      ..color = colors.lilac.withValues(alpha: .45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (var i = 0; i < 4; i++) {
      final x = centre.dx - unit * .195 + i * unit * .13;
      final height = unit * (i == 1 ? .30 : (i == 2 ? .28 : .24));
      final top = centre.dy - unit * .13 - height;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - unit * .045, top, unit * .09, height + unit * .06),
          Radius.circular(unit * .045),
        ),
        fingerPaint,
      );
    }
    canvas.save();
    canvas.translate(centre.dx - unit * .26, centre.dy + unit * .04);
    canvas.rotate(-0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-unit * .045, -unit * .11, unit * .09, unit * .22),
        Radius.circular(unit * .045),
      ),
      fingerPaint,
    );
    canvas.restore();

    // As três linhas maiores da palma.
    final linePaint = Paint()
      ..color = colors.starYellow.withValues(alpha: .75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final left = centre.dx - unit * .25;
    final right = centre.dx + unit * .25;
    final top = centre.dy - unit * .12;
    canvas.drawPath(
      Path()
        ..moveTo(left + unit * .03, top + unit * .06)
        ..quadraticBezierTo(
            centre.dx, top + unit * .02, right - unit * .04, top + unit * .10),
      linePaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(left + unit * .02, top + unit * .16)
        ..quadraticBezierTo(
            centre.dx, top + unit * .20, right - unit * .06, top + unit * .17),
      linePaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(left + unit * .08, top + unit * .02)
        ..quadraticBezierTo(left + unit * .06, centre.dy + unit * .20,
            centre.dx + unit * .06, centre.dy + unit * .34),
      linePaint,
    );

    // A faixa de luz: só existe enquanto a leitura real acontece.
    if (!active) return;
    final band = palm.outerRect;
    final y = band.top + band.height * phase;
    final glow =
        Rect.fromLTWH(band.left, y - unit * .05, band.width, unit * .10);
    canvas.save();
    canvas.clipRRect(palm);
    canvas.drawRect(
      glow,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.gold.withValues(alpha: 0),
            colors.gold.withValues(alpha: .35),
            colors.gold.withValues(alpha: 0),
          ],
        ).createShader(glow),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PalmPainter old) =>
      old.phase != phase || old.active != active || old.colors != colors;
}
