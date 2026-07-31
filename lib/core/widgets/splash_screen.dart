import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:flutter/services.dart';
import '../theme/grimoire_colors.dart';

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

    // Configurar animações
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

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Iniciar animação
    _controller.forward();

    // Navegar para a próxima tela após a animação
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ícone principal - Lua crescente com bola de cristal
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Círculo de fundo com brilho mágico
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              context.gc.lilac.withOpacity(0.4),
                              context.gc.mint.withOpacity(0.2),
                              context.gc.background,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                      // Segundo círculo para efeito de profundidade
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              context.gc.lilac.withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Bola de cristal central
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '🔮',
                            style: TextStyle(fontSize: 90),
                          ),
                          const SizedBox(height: 4),
                          // Lua pequena acima da bola de cristal
                          const Text(
                            '🌙',
                            style: TextStyle(fontSize: 40),
                          ),
                        ],
                      ),
                      // Estrelas ao redor em posições específicas
                      Positioned(
                        left: 30,
                        top: 40,
                        child: _buildStar(0),
                      ),
                      Positioned(
                        right: 30,
                        top: 40,
                        child: _buildStar(1),
                      ),
                      Positioned(
                        left: 20,
                        bottom: 50,
                        child: _buildStar(2),
                      ),
                      Positioned(
                        right: 20,
                        bottom: 50,
                        child: _buildStar(3),
                      ),
                      Positioned(
                        left: 60,
                        top: 20,
                        child: _buildStar(4),
                      ),
                      Positioned(
                        right: 60,
                        top: 20,
                        child: _buildStar(5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Nome do app
                  Text(
                    'Grimório de Bolso',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: context.gc.lilac,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Subtítulo
                  Text(
                    AppLocalizations.of(context).splashTagline,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  // Loading indicator místico
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.gc.lilac.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStar(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + (index * 100)),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Text(
            '✨',
            style: TextStyle(
              fontSize: 16 + (4 * (index % 3)),
              shadows: [
                Shadow(
                  color: context.gc.starYellow.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
