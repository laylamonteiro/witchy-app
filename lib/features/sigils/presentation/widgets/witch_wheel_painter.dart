import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/sigil_wheel_model.dart';

/// Painter para desenhar a Roda Alfabética das Bruxas
/// Baseado no livro - 3 anéis concêntricos
class WitchWheelPainter extends CustomPainter {
  final bool showLetters;
  final double radius;

  WitchWheelPainter({
    this.showLetters = true,
    this.radius = SigilWheel.wheelRadius, // Usa a constante do modelo
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final circlePaint = Paint()
      ..color = AppColors.surfaceBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Desenhar 3 círculos concêntricos
    // Anel Externo (raio = 1.0) - 12 letras O-Z
    canvas.drawCircle(center, radius, circlePaint);

    // Anel Médio (raio = 0.66) - 8 letras G-N
    canvas.drawCircle(center, radius * 0.66, circlePaint);

    // Anel Interno (raio = 0.33) - 6 letras A-F
    canvas.drawCircle(center, radius * 0.33, circlePaint);

    // Círculo central (ponto inicial)
    canvas.drawCircle(center, radius * 0.08, circlePaint);

    // Círculo dourado em volta das letras externas
    final goldCirclePaint = Paint()
      ..color = AppColors.starYellow.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius + 30, goldCirclePaint);

    if (showLetters) {
      // Desenhar letras usando as posições definidas no modelo
      SigilWheel.letterPositions.forEach((letter, position) {
        _drawLetter(canvas, center, letter, position);
      });
    }
  }

  /// Desenha uma letra na posição correta do anel
  void _drawLetter(
    Canvas canvas,
    Offset center,
    String letter,
    WheelPosition position,
  ) {
    // Calcula o raio baseado no anel
    double ringRadius;
    switch (position.ring) {
      case 1: // Anel interno (A-F)
        ringRadius = radius * 0.33;
        break;
      case 2: // Anel médio (G-N)
        ringRadius = radius * 0.66;
        break;
      case 3: // Anel externo (O-Z)
        ringRadius = radius;
        break;
      default:
        ringRadius = radius;
    }

    // Converte ângulo para radianos (subtrai 90° para começar do topo)
    final angleRad = (position.angle - 90) * (math.pi / 180);

    // Posição da letra (um pouco mais afastada do círculo)
    final letterDistance = ringRadius + 20;
    final x = center.dx + letterDistance * math.cos(angleRad);
    final y = center.dy + letterDistance * math.sin(angleRad);

    // Desenhar letra
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
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
      center.dx + ringRadius * math.cos(angleRad),
      center.dy + ringRadius * math.sin(angleRad),
    );
    final lineEnd = Offset(
      center.dx + (ringRadius + 10) * math.cos(angleRad),
      center.dy + (ringRadius + 10) * math.sin(angleRad),
    );

    final linePaint = Paint()
      ..color = AppColors.surfaceBorder.withOpacity(0.3)
      ..strokeWidth = 1.0;

    canvas.drawLine(lineStart, lineEnd, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
