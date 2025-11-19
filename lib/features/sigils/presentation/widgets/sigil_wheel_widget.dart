import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:grimorio_de_bolso/features/sigils/data/models/sigil_wheel_model.dart';

class SigilWheelWidget extends StatelessWidget {
  final double size;
  final List<String>? highlightedLetters;
  final List<Offset>? sigilPoints;
  final bool showGrid;
  final bool showLetters;
  
  const SigilWheelWidget({
    super.key,
    this.size = 300,
    this.highlightedLetters,
    this.sigilPoints,
    this.showGrid = true,
    this.showLetters = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF171425),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: const Color(0xFFC9A7FF).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC9A7FF).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: SigilWheelPainter(
          highlightedLetters: highlightedLetters,
          sigilPoints: sigilPoints,
          showGrid: showGrid,
          showLetters: showLetters,
        ),
      ),
    );
  }
}

class SigilWheelPainter extends CustomPainter {
  final List<String>? highlightedLetters;
  final List<Offset>? sigilPoints;
  final bool showGrid;
  final bool showLetters;
  
  SigilWheelPainter({
    this.highlightedLetters,
    this.sigilPoints,
    this.showGrid = true,
    this.showLetters = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.42;

    // Paint para o círculo principal
    final circlePaint = Paint()
      ..color = const Color(0xFFC9A7FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Desenha círculo único simples
    if (showGrid) {
      // Centro
      canvas.drawCircle(center, 4, Paint()
        ..color = const Color(0xFFC9A7FF)
        ..style = PaintingStyle.fill);

      // Círculo principal
      canvas.drawCircle(center, maxRadius, circlePaint);
    }

    // Desenha as letras
    if (showLetters) {
      _drawLettersSimple(canvas, size, center, maxRadius);
    }

    // Desenha o sigilo se houver pontos
    if (sigilPoints != null && sigilPoints!.isNotEmpty) {
      _drawSigil(canvas, sigilPoints!);
    }
  }

  void _drawLettersSimple(Canvas canvas, Size size, Offset center, double maxRadius) {
    final textStyle = const TextStyle(
      color: Color(0xFFE8D6FF),
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    // Desenha todas as letras ao redor do círculo
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    final totalLetters = letters.length;

    for (int i = 0; i < totalLetters; i++) {
      final angle = (i * 360 / totalLetters) * (math.pi / 180);
      final radius = maxRadius + 20; // Fora do círculo

      final x = center.dx + radius * math.cos(angle - math.pi / 2);
      final y = center.dy + radius * math.sin(angle - math.pi / 2);

      final textSpan = TextSpan(
        text: letters[i],
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }
  
  void _drawSigil(Canvas canvas, List<Offset> points) {
    if (points.isEmpty) return;
    
    // Paint para as linhas do sigilo
    final sigilPaint = Paint()
      ..color = const Color(0xFFC9A7FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    // Paint para os pontos
    final pointPaint = Paint()
      ..color = const Color(0xFFFFE8A3)
      ..style = PaintingStyle.fill;
    
    // Paint para o brilho
    final glowPaint = Paint()
      ..color = const Color(0xFFC9A7FF).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    // Desenha o caminho do sigilo
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    
    // Desenha o brilho
    canvas.drawPath(path, glowPaint);
    
    // Desenha a linha principal
    canvas.drawPath(path, sigilPaint);
    
    // Desenha os pontos nos vértices
    for (int i = 0; i < points.length; i++) {
      // Ponto principal
      canvas.drawCircle(points[i], 4, pointPaint);
      
      // Anel ao redor do ponto
      canvas.drawCircle(
        points[i],
        6,
        Paint()
          ..color = const Color(0xFFFFE8A3).withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      
      // Marca especial para início e fim
      if (i == 0) {
        // Início - círculo maior verde
        canvas.drawCircle(
          points[i],
          8,
          Paint()
            ..color = const Color(0xFFA7F0D8).withOpacity(0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      } else if (i == points.length - 1) {
        // Fim - quadrado vermelho
        final rect = Rect.fromCenter(
          center: points[i],
          width: 12,
          height: 12,
        );
        canvas.drawRect(
          rect,
          Paint()
            ..color = const Color(0xFFFF6B81).withOpacity(0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
