import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Mascote animado (gato preto) que pisca e muda de expressão
class MascotWidget extends StatefulWidget {
  final String currentPage;

  const MascotWidget({
    super.key,
    required this.currentPage,
  });

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with SingleTickerProviderStateMixin {
  bool _isBlinking = false;
  late Timer _blinkTimer;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  // Expressões do mascote baseadas na página atual
  String get _mascotExpression {
    switch (widget.currentPage) {
      case 'Lua':
        return '🌙✨'; // Lua com estrelas
      case 'Grimório':
        return '📚🔮'; // Livro com bola de cristal
      case 'Diários':
        return '📔💭'; // Diário com pensamentos
      case 'Enciclopédia':
        return '💎✨'; // Cristal com brilho
      default:
        return '🐈‍⬛'; // Gato preto padrão
    }
  }

  @override
  void initState() {
    super.initState();

    // Animação de bounce quando troca de página
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    // Timer para piscar aleatoriamente
    _blinkTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _blink();
      }
    });
  }

  @override
  void didUpdateWidget(MascotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animar quando a página muda
    if (oldWidget.currentPage != widget.currentPage) {
      _bounceController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _blinkTimer.cancel();
    _bounceController.dispose();
    super.dispose();
  }

  void _blink() {
    if (!mounted) return;
    setState(() {
      _isBlinking = true;
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _isBlinking = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _bounceAnimation,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.surfaceBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            _isBlinking ? '😸' : _mascotExpression,
            key: ValueKey(_isBlinking ? 'blink' : widget.currentPage),
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
