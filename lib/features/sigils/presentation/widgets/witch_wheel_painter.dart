import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/sigil_wheel_model.dart';

/// Painter para desenhar a Roda Alfabética das Bruxas
/// Baseado no livro - 3 anéis concêntricos com letras dentro dos segmentos
class WitchWheelPainter extends CustomPainter {
  final bool showLetters;
  final Set<String> highlightedLetters;
  final Map<String, WheelPosition>? customPositions;

  WitchWheelPainter({
    this.showLetters = true,
    this.highlightedLetters = const {},
    this.customPositions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // IMPORTANTE: Calcular radius proporcionalmente ao canvas
    // Mesma fórmula usada em SigilWheel.getCanvasPosition para garantir consistência
    final radius = math.min(size.width, size.height) * (140.0 / 360.0);

    // Paint para os círculos principais
    final circlePaint = Paint()
      ..color = AppColors.surfaceBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Paint para círculo externo decorativo
    final outerDecorPaint = Paint()
      ..color = AppColors.starYellow.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Raios dos anéis (posicionamento das letras no meio de cada faixa)
    // IMPORTANTE: Mesmos multiplicadores de SigilWheel.getCanvasPosition
    final innerRingRadius = radius * 0.22; // Centro do anel interno
    final middleRingRadius = radius * 0.50; // Centro do anel médio
    final outerRingRadius = radius * 0.80; // Centro do anel externo

    // Bordas dos anéis
    final innerBorder = radius * 0.35;
    final middleBorder = radius * 0.65;
    final outerBorder = radius;

    // Círculo dourado externo único
    final goldOuterPaint = Paint()
      ..color = AppColors.starYellow.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius + 4, goldOuterPaint);

    // Desenhar os 3 círculos de borda
    canvas.drawCircle(center, outerBorder, circlePaint);
    canvas.drawCircle(center, middleBorder, circlePaint);
    canvas.drawCircle(center, innerBorder, circlePaint);

    // Círculo central (ponto de início/fim)
    final centerPaint = Paint()
      ..color = AppColors.starYellow
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.06, centerPaint);

    final centerBorderPaint = Paint()
      ..color = AppColors.lilac
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 0.06, centerBorderPaint);

    // Desenhar linhas divisórias para cada anel
    _drawDivisionLines(canvas, center, innerBorder, 6, 0, radius); // 6 divisões (A-F)
    _drawDivisionLines(canvas, center, middleBorder, 8, innerBorder, radius); // 8 divisões (G-N)
    _drawDivisionLines(canvas, center, outerBorder, 12, middleBorder, radius); // 12 divisões (O-Z)

    if (showLetters) {
      final positions = customPositions ?? SigilWheel.letterPositions;
      // Desenhar letras dentro dos segmentos
      positions.forEach((letter, position) {
        _drawLetterInSegment(
          canvas,
          center,
          letter,
          position,
          innerRingRadius,
          middleRingRadius,
          outerRingRadius,
        );
      });
    }
  }

  /// Desenha linhas divisórias radiais para um anel
  void _drawDivisionLines(
    Canvas canvas,
    Offset center,
    double outerRadius,
    int divisions,
    double innerRadius,
    double radius,
  ) {
    final linePaint = Paint()
      ..color = AppColors.surfaceBorder.withOpacity(0.5)
      ..strokeWidth = 1.0;

    final angleStep = 360.0 / divisions;
    for (int i = 0; i < divisions; i++) {
      final angle = (i * angleStep - 90) * (math.pi / 180);

      final startRadius = innerRadius > 0 ? innerRadius : radius * 0.08;
      final start = Offset(
        center.dx + startRadius * math.cos(angle),
        center.dy + startRadius * math.sin(angle),
      );
      final end = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );

      canvas.drawLine(start, end, linePaint);
    }
  }

  /// Desenha uma letra no centro do seu segmento
  void _drawLetterInSegment(
    Canvas canvas,
    Offset center,
    String letter,
    WheelPosition position,
    double innerRingRadius,
    double middleRingRadius,
    double outerRingRadius,
  ) {
    // Calcula o raio baseado no anel (posição no centro da faixa)
    double ringRadius;
    double fontSize;
    switch (position.ring) {
      case 1: // Anel interno (A-F)
        ringRadius = innerRingRadius;
        fontSize = 11;
        break;
      case 2: // Anel médio (G-N)
        ringRadius = middleRingRadius;
        fontSize = 12;
        break;
      case 3: // Anel externo (O-Z)
        ringRadius = outerRingRadius;
        fontSize = 13;
        break;
      default:
        ringRadius = outerRingRadius;
        fontSize = 12;
    }

    // Converte ângulo para radianos (subtrai 90° para começar do topo)
    final angleRad = (position.angle - 90) * (math.pi / 180);

    // Posição da letra no centro do segmento
    final x = center.dx + ringRadius * math.cos(angleRad);
    final y = center.dy + ringRadius * math.sin(angleRad);

    // Verifica se a letra está destacada
    final isHighlighted = highlightedLetters.contains(letter);

    // Desenhar fundo circular se destacada
    if (isHighlighted) {
      final highlightPaint = Paint()
        ..color = AppColors.lilac.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), fontSize * 0.8, highlightPaint);
    }

    // Desenhar letra
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          color: isHighlighted ? AppColors.starYellow : AppColors.lilac,
          fontSize: fontSize,
          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
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
  }

  @override
  bool shouldRepaint(covariant WitchWheelPainter oldDelegate) {
    return oldDelegate.highlightedLetters != highlightedLetters ||
        oldDelegate.customPositions != customPositions ||
        oldDelegate.showLetters != showLetters;
  }
}
