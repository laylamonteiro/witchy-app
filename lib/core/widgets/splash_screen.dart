import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/grimoire_colors.dart';

/// Abertura do app: apenas o logo, sem texto.
///
/// A versão anterior empilhava emoji de bola de cristal, estrelas animadas,
/// nome do app, subtítulo e indicador de progresso — muita coisa para uma
/// tela que dura dois segundos e meio. O logo sozinho identifica o app e
/// deixa a entrada limpa.
class SplashScreen extends StatefulWidget {
  final Widget child;

  const SplashScreen({super.key, required this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Tempo e transição preservados: só o conteúdo da tela mudou.
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                widget.child,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.gc.background,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                'assets/app_icon.png',
                width: 160,
                height: 160,
                // Sem texto de reserva: se o logo não carregar, a tela fica
                // apenas no fundo do app e segue para o conteúdo.
                errorBuilder: (_, __, ___) => const SizedBox(
                  width: 160,
                  height: 160,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
