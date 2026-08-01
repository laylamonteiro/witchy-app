import 'package:flutter/material.dart';

import '../theme/grimoire_colors.dart';

/// Anel de progresso animado (0..1) com conteúdo opcional no centro.
///
/// Cada tela do app construía o seu inline (jornadas, Grimório Vivo, perfil,
/// analytics, tarot); este é o compartilhado — sempre anima do valor anterior
/// para o novo, então subir de nível/XP é visível.
class MagicalProgressRing extends StatelessWidget {
  final double value;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Widget? center;

  const MagicalProgressRing({
    super.key,
    required this.value,
    this.size = 56,
    this.strokeWidth = 5,
    this.color,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    final ringColor = color ?? context.gc.lilac;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: animated,
                strokeWidth: strokeWidth,
                backgroundColor: ringColor.withValues(alpha: 0.18),
                valueColor: AlwaysStoppedAnimation<Color>(ringColor),
              ),
            ),
            if (center != null) center!,
          ],
        ),
      ),
    );
  }
}

/// Barra de progresso animada (0..1), cantos arredondados.
class MagicalProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  final double height;

  const MagicalProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? context.gc.lilac;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) => ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: LinearProgressIndicator(
          value: animated,
          minHeight: height,
          backgroundColor: barColor.withValues(alpha: 0.18),
          valueColor: AlwaysStoppedAnimation<Color>(barColor),
        ),
      ),
    );
  }
}
