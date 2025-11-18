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
      for (int i = 0; i < 5; i++) {
        _particles.add(_Particle());
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
          ..._particles.map((particle) => Positioned(
                left: particle.offsetX,
                top: particle.offsetY,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.0, end: 0.0),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, -20 * (1 - value)),
                        child: Icon(
                          Icons.star,
                          size: 12,
                          color: particle.color,
                        ),
                      ),
                    );
                  },
                ),
              )),
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
  final double offsetX;
  final double offsetY;
  final Color color;

  _Particle()
      : offsetX = (DateTime.now().millisecondsSinceEpoch % 100 - 50).toDouble(),
        offsetY = (DateTime.now().millisecondsSinceEpoch % 50 - 25).toDouble(),
        color = DateTime.now().millisecondsSinceEpoch % 2 == 0
            ? AppColors.starYellow
            : AppColors.lilac;
}
