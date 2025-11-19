import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MagicalButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final IconData? icon;

  const MagicalButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.icon,
  });

  @override
  State<MagicalButton> createState() => _MagicalButtonState();
}

class _MagicalButtonState extends State<MagicalButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
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
      // Criar 3-5 partículas
      final count = 3 + _random.nextInt(3);
      for (int i = 0; i < count; i++) {
        _particles.add(_Particle(
          angle: (i / count) * 2 * math.pi,
          distance: 40.0 + _random.nextDouble() * 20,
          color: i % 2 == 0 ? AppColors.starYellow : AppColors.lilac,
        ));
      }
    });
    Future.delayed(const Duration(milliseconds: 400), () {
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
            final offsetX = math.cos(particle.angle) * particle.distance;
            final offsetY = math.sin(particle.angle) * particle.distance;

            return Positioned(
              left: offsetX,
              top: offsetY,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: 1.0 - value,
                    child: Transform.translate(
                      offset: Offset(
                        offsetX * value * 0.5,
                        offsetY * value * 0.5 - 15 * value,
                      ),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: particle.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: particle.color.withOpacity(0.6),
                              blurRadius: 4,
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
          // Botão
          widget.isOutlined
              ? OutlinedButton.icon(
                  onPressed: _handleTap,
                  icon: widget.icon != null
                      ? Icon(widget.icon)
                      : const SizedBox.shrink(),
                  label: Text(widget.text),
                )
              : ElevatedButton.icon(
                  onPressed: _handleTap,
                  icon: widget.icon != null
                      ? Icon(widget.icon)
                      : const SizedBox.shrink(),
                  label: Text(widget.text),
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
