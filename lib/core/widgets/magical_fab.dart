import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// FloatingActionButton mágico com animação de escala e explosão de partículas
class MagicalFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const MagicalFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<MagicalFAB> createState() => _MagicalFABState();
}

class _MagicalFABState extends State<MagicalFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    _createParticles();
    widget.onPressed();
  }

  void _createParticles() {
    setState(() {
      _particles.clear();
      final count = 4 + _random.nextInt(3);
      for (int i = 0; i < count; i++) {
        _particles.add(_Particle(
          angle: (i / count) * 2 * math.pi + _random.nextDouble() * 0.5,
          distance: 35.0 + _random.nextDouble() * 20,
          color: i % 2 == 0 ? AppColors.starYellow : AppColors.lilac,
        ));
      }
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _particles.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Partículas
          ..._particles.map((particle) {
            final offsetX = math.cos(particle.angle) * 10;
            final offsetY = math.sin(particle.angle) * 10;

            return Positioned(
              left: offsetX,
              top: offsetY,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  final dx = math.cos(particle.angle) * particle.distance * value;
                  final dy = math.sin(particle.angle) * particle.distance * value - 20 * value;

                  return Transform.translate(
                    offset: Offset(dx, dy),
                    child: Opacity(
                      opacity: 1.0 - value,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: particle.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: particle.color.withOpacity(0.7),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          // FloatingActionButton
          FloatingActionButton(
            onPressed: _handleTap,
            backgroundColor: widget.backgroundColor ?? AppColors.lilac,
            foregroundColor: widget.foregroundColor ?? const Color(0xFF2B2143),
            child: Icon(widget.icon),
          ),
        ],
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  final Color color;

  _Particle({
    required this.angle,
    required this.distance,
    required this.color,
  });
}
