import 'package:flutter/material.dart';

import '../theme/grimoire_colors.dart';

/// O Sol com a mesma "respiração" da [BreathingMoon], mas sem o acoplamento
/// com fases lunares: escala pulsando suavemente e um halo dourado que
/// cresce e recolhe. Pensado para o hero da página do Sol (as estrelinhas
/// ficam por conta do StarfieldBackground atrás).
class BreathingSun extends StatefulWidget {
  final double size;

  const BreathingSun({super.key, this.size = 80});

  @override
  State<BreathingSun> createState() => _BreathingSunState();
}

class _BreathingSunState extends State<BreathingSun>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Halo dourado pulsante.
        AnimatedBuilder(
          animation: _glow,
          builder: (context, _) => Container(
            width: widget.size + 30,
            height: widget.size + 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  context.gc.starYellow.withValues(alpha: _glow.value),
                  context.gc.background.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),

        // O Sol respirando.
        ScaleTransition(
          scale: _scale,
          child: Text(
            '☀️',
            style: TextStyle(
              fontSize: widget.size,
              shadows: [
                Shadow(
                  color: context.gc.gold.withValues(alpha: 0.5),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
