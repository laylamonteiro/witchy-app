import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/sigil_wheel_model.dart';

/// Painter para desenhar o sigilo (linhas conectando os pontos)
/// Calcula os pontos no momento da pintura usando o tamanho real do canvas
class SigilDrawingPainter extends CustomPainter {
  final String intention;
  final bool showStartEnd;
  final Map<String, WheelPosition>? customPositions;

  SigilDrawingPainter({
    required this.intention,
    this.showStartEnd = true,
    this.customPositions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calcular pontos usando o tamanho REAL do canvas
    final points = customPositions != null
        ? SigilWheel.generateSigilPointsWithCustom(intention, size, customPositions)
        : SigilWheel.generateSigilPoints(intention, size);

    if (points.length < 2) return;

    // Desenhar linhas conectando os pontos
    final linePaint = Paint()
      ..color = AppColors.starYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    final firstPoint = points[0];
    path.moveTo(firstPoint.dx, firstPoint.dy);

    for (int i = 1; i < points.length; i++) {
      final point = points[i];
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(path, linePaint);

    if (showStartEnd) {
      // Marcar ponto inicial (círculo verde)
      final startPaint = Paint()
        ..color = Colors.green.shade300
        ..style = PaintingStyle.fill;

      canvas.drawCircle(firstPoint, 6.0, startPaint);

      // Marcar ponto final (círculo vermelho)
      final endPaint = Paint()
        ..color = Colors.red.shade300
        ..style = PaintingStyle.fill;

      canvas.drawCircle(points.last, 6.0, endPaint);

      // Desenhar todos os pontos intermediários (círculos lilás)
      final pointPaint = Paint()
        ..color = AppColors.lilac
        ..style = PaintingStyle.fill;

      for (int i = 1; i < points.length - 1; i++) {
        canvas.drawCircle(points[i], 4.0, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SigilDrawingPainter oldDelegate) {
    return oldDelegate.intention != intention ||
        oldDelegate.showStartEnd != showStartEnd ||
        oldDelegate.customPositions != customPositions;
  }
}
