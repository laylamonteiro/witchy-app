import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Painter para desenhar o sigilo (linhas conectando os pontos)
/// Os pontos já vêm calculados nas coordenadas corretas do canvas
/// pela Roda Alfabética das Bruxas com 3 anéis concêntricos
class SigilDrawingPainter extends CustomPainter {
  final List<Offset> points;
  final bool showStartEnd;

  SigilDrawingPainter({
    required this.points,
    this.showStartEnd = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    // Desenhar linhas conectando os pontos
    final linePaint = Paint()
      ..color = AppColors.starYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Os pontos já vêm nas coordenadas corretas, usar diretamente
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
