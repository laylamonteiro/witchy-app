import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

/// Partícula de brilho que aparece quando o gato é arrastado
class _SparkleParticle {
  final Offset position;
  final double opacity;
  final double size;
  final Color color;
  final int createdAt;

  _SparkleParticle({
    required this.position,
    required this.opacity,
    required this.size,
    required this.color,
    required this.createdAt,
  });
}

/// Mascote arrastável (gato preto) que deixa rastros de brilho
class DraggableCatMascot extends StatefulWidget {
  const DraggableCatMascot({super.key});

  @override
  State<DraggableCatMascot> createState() => _DraggableCatMascotState();
}

class _DraggableCatMascotState extends State<DraggableCatMascot>
    with SingleTickerProviderStateMixin {
  Offset _position = const Offset(100, 100);
  final List<_SparkleParticle> _sparkles = [];
  late AnimationController _sparkleController;
  final _random = math.Random();
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();

    // Animação contínua para atualizar os brilhos
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(_updateSparkles);

    _sparkleController.repeat();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  void _updateSparkles() {
    if (!mounted) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      // Remover partículas antigas (mais de 800ms)
      _sparkles.removeWhere((sparkle) => now - sparkle.createdAt > 800);
    });
  }

  void _addSparkle(Offset position) {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Adicionar 2-3 partículas aleatórias
    final count = 2 + _random.nextInt(2);
    for (int i = 0; i < count; i++) {
      final offsetX = (_random.nextDouble() - 0.5) * 30;
      final offsetY = (_random.nextDouble() - 0.5) * 30;

      _sparkles.add(_SparkleParticle(
        position: Offset(
          position.dx + offsetX,
          position.dy + offsetY,
        ),
        opacity: 0.8 + _random.nextDouble() * 0.2,
        size: 3 + _random.nextDouble() * 4,
        color: i % 2 == 0 ? AppColors.starYellow : AppColors.lilac,
        createdAt: now,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Renderizar partículas de brilho
        ..._sparkles.map((sparkle) {
          final now = DateTime.now().millisecondsSinceEpoch;
          final age = now - sparkle.createdAt;
          final opacity = sparkle.opacity * (1 - age / 800); // Fade out

          return Positioned(
            left: sparkle.position.dx,
            top: sparkle.position.dy,
            child: IgnorePointer(
              child: Container(
                width: sparkle.size,
                height: sparkle.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sparkle.color.withOpacity(opacity),
                  boxShadow: [
                    BoxShadow(
                      color: sparkle.color.withOpacity(opacity * 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        // Mascote arrastável
        Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                _isDragging = true;
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _position = Offset(
                  _position.dx + details.delta.dx,
                  _position.dy + details.delta.dy,
                );
              });

              // Adicionar brilhos enquanto arrasta
              _addSparkle(_position);
            },
            onPanEnd: (details) {
              setState(() {
                _isDragging = false;
              });
            },
            child: AnimatedScale(
              scale: _isDragging ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isDragging
                      ? [
                          BoxShadow(
                            color: AppColors.lilac.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: SvgPicture.asset(
                  'assets/icons/black_cat_mascot.svg',
                  width: 64,
                  height: 64,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
