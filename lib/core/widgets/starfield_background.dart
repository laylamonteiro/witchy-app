import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/grimoire_colors.dart';

/// Céu estrelado sutil atrás de um conteúdo — atmosfera sem custo de imagem.
///
/// Um único controller pinta todas as estrelas (em vez de N widgets animados),
/// e as posições vêm de uma semente fixa: elas não "pulam" a cada rebuild.
class StarfieldBackground extends StatefulWidget {
  final Widget child;
  final int starCount;
  final Color? color;

  /// Opacidade máxima de uma estrela no auge do brilho.
  final double intensity;

  const StarfieldBackground({
    super.key,
    required this.child,
    this.starCount = 26,
    this.color,
    this.intensity = 0.75,
  });

  @override
  State<StarfieldBackground> createState() => _StarfieldBackgroundState();
}

class _StarfieldBackgroundState extends State<StarfieldBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  late final List<_Star> _stars = _buildStars(widget.starCount);

  /// O cintilar só começa depois do primeiro frame e SÓ quando o aparelho
  /// aceita animação: quem pediu "reduzir movimento" no sistema recebe o céu
  /// parado (e a bateria agradece). Como o ciclo é infinito, ligá-lo no
  /// initState também deixaria qualquer teste da página preso para sempre
  /// num pumpAndSettle.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animar = !MediaQuery.disableAnimationsOf(context);
    if (animar && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!animar && _controller.isAnimating) {
      _controller.stop();
    }
  }

  static List<_Star> _buildStars(int count) {
    // Semente fixa: mesmo céu em todas as aberturas do app.
    final random = math.Random(20260801);
    return List.generate(
      count,
      (_) => _Star(
        dx: random.nextDouble(),
        dy: random.nextDouble(),
        radius: 0.6 + random.nextDouble() * 1.4,
        phase: random.nextDouble(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _StarfieldPainter(
                  stars: _stars,
                  time: _controller.value,
                  color: widget.color ?? context.gc.starYellow,
                  intensity: widget.intensity,
                ),
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Star {
  final double dx;
  final double dy;
  final double radius;
  final double phase;

  const _Star({
    required this.dx,
    required this.dy,
    required this.radius,
    required this.phase,
  });
}

class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double time;
  final Color color;
  final double intensity;

  const _StarfieldPainter({
    required this.stars,
    required this.time,
    required this.color,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final star in stars) {
      // Cada estrela pisca no seu próprio ritmo (fase própria).
      final twinkle =
          (math.sin((time + star.phase) * 2 * math.pi) * 0.5 + 0.5);
      paint.color = color.withValues(alpha: 0.15 + twinkle * intensity * 0.85);
      canvas.drawCircle(
        Offset(star.dx * size.width, star.dy * size.height),
        star.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) =>
      oldDelegate.time != time ||
      oldDelegate.color != color ||
      oldDelegate.intensity != intensity;
}
