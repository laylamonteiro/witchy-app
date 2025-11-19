import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget que exibe a lua com animação de "respiração" (pulsação suave)
class BreathingMoon extends StatefulWidget {
  final String moonEmoji;
  final double size;
  final bool showStars;

  const BreathingMoon({
    super.key,
    required this.moonEmoji,
    this.size = 80,
    this.showStars = true,
  });

  @override
  State<BreathingMoon> createState() => _BreathingMoonState();
}

class _BreathingMoonState extends State<BreathingMoon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Animação de respiração (loop infinito)
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Brilho pulsante ao redor da lua
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              width: widget.size + 30,
              height: widget.size + 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.lilac.withOpacity(_glowAnimation.value),
                    AppColors.background.withOpacity(0),
                  ],
                ),
              ),
            );
          },
        ),

        // Lua com respiração
        ScaleTransition(
          scale: _scaleAnimation,
          child: Text(
            widget.moonEmoji,
            style: TextStyle(
              fontSize: widget.size,
              shadows: [
                Shadow(
                  color: AppColors.lilac.withOpacity(0.5),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
        ),

        // Estrelas piscantes ao redor
        if (widget.showStars) ..._buildStars(),
      ],
    );
  }

  List<Widget> _buildStars() {
    final stars = <Widget>[];
    final positions = [
      const Offset(-50, -40),
      const Offset(50, -35),
      const Offset(-45, 40),
      const Offset(45, 45),
    ];

    for (int i = 0; i < positions.length; i++) {
      stars.add(
        Positioned(
          left: widget.size / 2 + positions[i].dx,
          top: widget.size / 2 + positions[i].dy,
          child: _BlinkingStar(delay: Duration(milliseconds: i * 400)),
        ),
      );
    }

    return stars;
  }
}

class _BlinkingStar extends StatefulWidget {
  final Duration delay;

  const _BlinkingStar({required this.delay});

  @override
  State<_BlinkingStar> createState() => _BlinkingarState();
}

class _BlinkingarState extends State<_BlinkingStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Aguardar delay antes de iniciar
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Text(
        '✨',
        style: TextStyle(
          fontSize: 16,
          shadows: [
            Shadow(
              color: AppColors.starYellow.withOpacity(0.8),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}
