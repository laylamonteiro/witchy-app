import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Painter para desenhar a Roda Alfabética das Bruxas
class WitchWheelPainter extends CustomPainter {
  final bool showLetters;
  final double radius;

  WitchWheelPainter({
    this.showLetters = true,
    this.radius = 100.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Desenhar círculo externo
    final circlePaint = Paint()
      ..color = AppColors.surfaceBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, circlePaint);

    // Desenhar círculo interno (menor)
    canvas.drawCircle(center, radius * 0.1, circlePaint);

    // Alfabeto
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    if (showLetters) {
      // Desenhar letras ao redor do círculo
      for (int i = 0; i < alphabet.length; i++) {
        final angle = (i / 26) * 2 * math.pi - math.pi / 2;

        // Posição da letra (um pouco mais afastada do círculo)
        final x = center.dx + (radius + 20) * math.cos(angle);
        final y = center.dy + (radius + 20) * math.sin(angle);

        // Desenhar letra
        final textPainter = TextPainter(
          text: TextSpan(
            text: alphabet[i],
            style: const TextStyle(
              color: AppColors.lilac,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            x - textPainter.width / 2,
            y - textPainter.height / 2,
          ),
        );

        // Desenhar linha do círculo até perto da letra
        final lineStart = Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        );
        final lineEnd = Offset(
          center.dx + (radius + 10) * math.cos(angle),
          center.dy + (radius + 10) * math.sin(angle),
        );

        final linePaint = Paint()
          ..color = AppColors.surfaceBorder.withOpacity(0.3)
          ..strokeWidth = 1.0;

        canvas.drawLine(lineStart, lineEnd, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
