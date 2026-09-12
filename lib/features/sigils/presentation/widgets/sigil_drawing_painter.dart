import 'package:flutter/material.dart';
import '../../data/models/sigil_wheel_model.dart';
import '../../domain/sigil_trace.dart';

/// Painter do sigilo: percorre o caminho que liga os pontos da roda.
///
/// O percurso é medido uma vez por intenção/tamanho ([SigilTrace]) e
/// reaproveitado; [progress] revela um prefixo dele, e [progress] igual a 1
/// é sempre o símbolo inteiro — é o estado que a exportação usa. Quando as
/// letras mudam de lugar, [previousPositions] e [blend] interpolam a
/// geometria e o traço acompanha as posições corretas.
class SigilDrawingPainter extends CustomPainter {
  final String intention;
  final bool showStartEnd;
  final Map<String, WheelPosition>? customPositions;
  final Map<String, WheelPosition>? previousPositions;
  final double blend;
  final double progress;
  final Color lineColor;
  final Color pointColor;

  SigilDrawingPainter({
    required this.intention,
    required this.lineColor,
    required this.pointColor,
    this.showStartEnd = true,
    this.customPositions,
    this.previousPositions,
    this.blend = 1,
    this.progress = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Percurso calculado com o tamanho REAL do canvas.
    final trace = SigilTrace.of(
      intention: intention,
      size: size,
      positions: customPositions,
      previous: previousPositions,
      blend: blend,
    );
    final points = trace.points;
    if (points.length < 2) return;

    final drawn = progress.clamp(0.0, 1.0).toDouble();

    // Desenhar linhas conectando os pontos
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(trace.upTo(drawn), linePaint);

    if (showStartEnd) {
      final reached = trace.reachedPoints(drawn);

      // Marcar ponto inicial (círculo verde)
      if (reached > 0) {
        final startPaint = Paint()
          ..color = Colors.green.shade300
          ..style = PaintingStyle.fill;
        canvas.drawCircle(points.first, 6.0, startPaint);
      }

      // Desenhar os pontos intermediários já percorridos (círculos lilás)
      final pointPaint = Paint()
        ..color = pointColor
        ..style = PaintingStyle.fill;
      for (int i = 1; i < points.length - 1 && i < reached; i++) {
        canvas.drawCircle(points[i], 4.0, pointPaint);
      }

      // Marcar ponto final (círculo vermelho) só quando o traço chega nele
      if (drawn >= 1) {
        final endPaint = Paint()
          ..color = Colors.red.shade300
          ..style = PaintingStyle.fill;
        canvas.drawCircle(points.last, 6.0, endPaint);
      }
    }

    // Ponta do traço enquanto ele percorre o caminho.
    if (drawn > 0 && drawn < 1) {
      final head = trace.headAt(drawn);
      canvas.drawCircle(head, 5.0, Paint()..color = lineColor.withValues(alpha: .35));
      canvas.drawCircle(head, 2.5, Paint()..color = lineColor);
    }
  }

  @override
  bool shouldRepaint(covariant SigilDrawingPainter oldDelegate) {
    return oldDelegate.intention != intention ||
        oldDelegate.showStartEnd != showStartEnd ||
        oldDelegate.customPositions != customPositions ||
        oldDelegate.previousPositions != previousPositions ||
        oldDelegate.blend != blend ||
        oldDelegate.progress != progress ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.pointColor != pointColor;
  }
}
