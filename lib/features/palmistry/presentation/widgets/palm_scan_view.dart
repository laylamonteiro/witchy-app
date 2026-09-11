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

    // A palma primeiro: tudo o mais é medido a partir dela, para a mão não
    // sair com dedos soltos nem linhas fora do lugar.
    final palmWidth = unit * .44;
    final palmHeight = unit * .40;
    final palm = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: centre.translate(0, unit * .14),
        width: palmWidth,
        height: palmHeight,
      ),
      topLeft: Radius.circular(unit * .10),
      topRight: Radius.circular(unit * .10),
      bottomLeft: Radius.circular(unit * .17),
      bottomRight: Radius.circular(unit * .17),
    );
    final outline = Paint()
      ..color = colors.lilac.withValues(alpha: .55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = colors.lilac.withValues(alpha: .10)
      ..style = PaintingStyle.fill;

    // Os dedos saem de dentro da palma e sobem: desenhados antes dela, as
    // bases ficam escondidas e a mão fica inteira, não montada em peças.
    final fingerWidth = palmWidth * .19;
    final heights = [.30, .36, .34, .27];
    for (var i = 0; i < 4; i++) {
      final x = palm.left + palmWidth * (.155 + i * .23);
      final height = unit * heights[i];
      final finger = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x - fingerWidth / 2,
          palm.top - height + unit * .06,
          fingerWidth,
          height,
        ),
        Radius.circular(fingerWidth / 2),
      );
      canvas.drawRRect(finger, fill);
      canvas.drawRRect(finger, outline);
    }

    // O polegar, inclinado, saindo da borda esquerda da palma.
    canvas.save();
    canvas.translate(palm.left + unit * .02, centre.dy + unit * .10);
    canvas.rotate(-0.65);
    final thumb = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset.zero, width: fingerWidth * 1.1, height: unit * .22),
      Radius.circular(fingerWidth * .55),
    );
    canvas.drawRRect(thumb, fill);
    canvas.drawRRect(thumb, outline);
    canvas.restore();

    // A palma por cima das bases dos dedos.
    canvas.drawRRect(palm, fill);
    canvas.drawRRect(palm, outline);

    // As três linhas maiores, todas dentro da palma.
    final linePaint = Paint()
      ..color = colors.starYellow.withValues(alpha: .8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final left = palm.left;
    final right = palm.right;
    final top = palm.top;
    // Coração: da borda esquerda, subindo de leve até a direita.
    canvas.drawPath(
      Path()
        ..moveTo(left + palmWidth * .10, top + palmHeight * .30)
        ..quadraticBezierTo(centre.dx, top + palmHeight * .16,
            right - palmWidth * .12, top + palmHeight * .26),
      linePaint,
    );
    // Cabeça: atravessa a palma, mais reta.
    canvas.drawPath(
      Path()
        ..moveTo(left + palmWidth * .08, top + palmHeight * .48)
        ..quadraticBezierTo(centre.dx, top + palmHeight * .54,
            right - palmWidth * .16, top + palmHeight * .46),
      linePaint,
    );
    // Vida: contorna a base do polegar.
    canvas.drawPath(
      Path()
        ..moveTo(left + palmWidth * .16, top + palmHeight * .20)
        ..quadraticBezierTo(left + palmWidth * .10, top + palmHeight * .72,
            centre.dx, palm.bottom - palmHeight * .06),
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
            colors.gold.withValues(alpha: .38),
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
