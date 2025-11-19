import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Painter para desenhar o sigilo (linhas conectando os pontos)
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

    final center = Offset(size.width / 2, size.height / 2);

    // Desenhar linhas conectando os pontos
    final linePaint = Paint()
      ..color = AppColors.starYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Ajustar pontos para centralizar
    final firstPoint = points[0];
    path.moveTo(
      center.dx + firstPoint.dx - 100,
      center.dy + firstPoint.dy - 100,
    );

    for (int i = 1; i < points.length; i++) {
      final point = points[i];
      path.lineTo(
        center.dx + point.dx - 100,
        center.dy + point.dy - 100,
      );
    }

    canvas.drawPath(path, linePaint);

    if (showStartEnd) {
      // Marcar ponto inicial (círculo verde)
      final startPaint = Paint()
        ..color = Colors.green.shade300
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(
          center.dx + firstPoint.dx - 100,
          center.dy + firstPoint.dy - 100,
        ),
        6.0,
        startPaint,
      );

      // Marcar ponto final (círculo vermelho)
      final endPaint = Paint()
        ..color = Colors.red.shade300
        ..style = PaintingStyle.fill;

      final lastPoint = points.last;
      canvas.drawCircle(
        Offset(
          center.dx + lastPoint.dx - 100,
          center.dy + lastPoint.dy - 100,
        ),
        6.0,
        endPaint,
      );

      // Desenhar todos os pontos intermediários (círculos lilás)
      final pointPaint = Paint()
        ..color = AppColors.lilac
        ..style = PaintingStyle.fill;

      for (int i = 1; i < points.length - 1; i++) {
        final point = points[i];
        canvas.drawCircle(
          Offset(
            center.dx + point.dx - 100,
            center.dy + point.dy - 100,
          ),
          4.0,
          pointPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
