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
    final maxRadius = math.min(size.width, size.height) * 0.45;  // Aumentado de 0.4 para 0.45 - usa mais espaço
    
    // Paint para as linhas da grade (MUITO mais visível)
    final gridPaint = Paint()
      ..color = const Color(0xFFC9A7FF)  // Lilás sem opacidade - totalmente visível
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;  // Aumentado para 4 para melhor visibilidade

    // Paint para as divisões (mais visível)
    final dividerPaint = Paint()
      ..color = const Color(0xFFC9A7FF).withOpacity(0.3)  // Lilás mais suave
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // Desenha os 3 círculos concêntricos
    if (showGrid) {
      // Centro (ponto maior e mais visível)
      canvas.drawCircle(center, 6, Paint()
        ..color = const Color(0xFFC9A7FF)
        ..style = PaintingStyle.fill);
      canvas.drawCircle(center, 8, Paint()
        ..color = const Color(0xFFC9A7FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);

      // Anel interno (raio 33%) - VERMELHO para debug
      canvas.drawCircle(center, maxRadius * 0.33, Paint()
        ..color = const Color(0xFFFF0000)  // VERMELHO
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4);

      // Anel médio (raio 66%) - VERDE para debug
      canvas.drawCircle(center, maxRadius * 0.66, Paint()
        ..color = const Color(0xFF00FF00)  // VERDE
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4);

      // Anel externo (raio 100%) - AZUL para debug
      canvas.drawCircle(center, maxRadius, Paint()
        ..color = const Color(0xFF0000FF)  // AZUL
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4);

      // Desenha as divisões radiais (como fatias)
      _drawRadialDivisions(canvas, center, maxRadius, dividerPaint);
    }
    
    // Desenha as letras
    if (showLetters) {
      _drawLetters(canvas, size, center, maxRadius);
    }
    
    // Desenha o sigilo se houver pontos
    if (sigilPoints != null && sigilPoints!.isNotEmpty) {
      _drawSigil(canvas, sigilPoints!);
    }
  }
  
  void _drawRadialDivisions(Canvas canvas, Offset center, double maxRadius, Paint paint) {
    // Anel externo - 12 divisões (30° cada)
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * (math.pi / 180);
      final start = Offset(
        center.dx + (maxRadius * 0.66) * math.cos(angle - math.pi / 2),
        center.dy + (maxRadius * 0.66) * math.sin(angle - math.pi / 2),
      );
      final end = Offset(
        center.dx + maxRadius * math.cos(angle - math.pi / 2),
        center.dy + maxRadius * math.sin(angle - math.pi / 2),
      );
      canvas.drawLine(start, end, paint);
    }
    
    // Anel médio - 8 divisões (45° cada)
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45 + 15) * (math.pi / 180);
      final start = Offset(
        center.dx + (maxRadius * 0.33) * math.cos(angle - math.pi / 2),
        center.dy + (maxRadius * 0.33) * math.sin(angle - math.pi / 2),
      );
      final end = Offset(
        center.dx + (maxRadius * 0.66) * math.cos(angle - math.pi / 2),
        center.dy + (maxRadius * 0.66) * math.sin(angle - math.pi / 2),
      );
      canvas.drawLine(start, end, paint);
    }
    
    // Anel interno - 6 divisões (60° cada)
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * (math.pi / 180);
      final start = center;
      final end = Offset(
        center.dx + (maxRadius * 0.33) * math.cos(angle - math.pi / 2),
        center.dy + (maxRadius * 0.33) * math.sin(angle - math.pi / 2),
      );
      canvas.drawLine(start, end, paint);
    }
  }
  
  void _drawLetters(Canvas canvas, Size size, Offset center, double maxRadius) {
    final textStyle = TextStyle(
      color: highlightedLetters?.isEmpty ?? true
        ? const Color(0xFFE8D6FF)  // Cor mais clara e visível
        : const Color(0xFFE8D6FF).withOpacity(0.4),
      fontSize: 14,  // Fonte legível
      fontWeight: FontWeight.bold,  // Negrito para mais destaque
    );

    SigilWheel.letterPositions.forEach((letter, position) {
      // Calcula o raio baseado no anel - posiciona ENTRE os círculos
      double radius;
      switch (position.ring) {
        case 1: // Anel interno (A-F) - entre centro e primeiro círculo
          radius = maxRadius * 0.20;  // Dentro do primeiro círculo
          break;
        case 2: // Anel médio (G-N) - entre primeiro e segundo círculo
          radius = maxRadius * 0.50;  // Entre círculos de 33% e 66%
          break;
        case 3: // Anel externo (O-Z) - entre segundo e terceiro círculo
          radius = maxRadius * 0.83;  // Entre círculos de 66% e 100%
          break;
        default:
          radius = maxRadius;
      }
      
      // Calcula a posição
      final angle = position.angle * (math.pi / 180);
      final x = center.dx + radius * math.cos(angle - math.pi / 2);
      final y = center.dy + radius * math.sin(angle - math.pi / 2);
      
      // Determina a cor baseado se está destacado
      Color letterColor = const Color(0xFFB7B2D6);
      if (highlightedLetters != null) {
        if (highlightedLetters!.contains(letter)) {
          letterColor = const Color(0xFFFFE8A3); // Amarelo para destacado
        } else {
          letterColor = letterColor.withOpacity(0.3); // Apagado se não destacado
        }
      }
      
      // Desenha a letra
      final textSpan = TextSpan(
        text: letter,
        style: textStyle.copyWith(color: letterColor),
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
    });
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
