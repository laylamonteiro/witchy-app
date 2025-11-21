import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import '../../../core/theme/app_theme.dart';
import 'cat_svg_poses.dart';

/// Widget do mascote gatinho preto arrastável com efeitos mágicos
///
/// Features:
/// - Sombra lilás sempre visível
/// - Arrastável pela tela sem bloquear outras interações
/// - Efeitos de partículas ao clicar e arrastar
/// - Rastro mágico durante o arraste
/// - Animações de flutuação
class DraggableCatMascot extends StatefulWidget {
  final double initialX;
  final double initialY;
  final VoidCallback? onTap;
  final double size;

  const DraggableCatMascot({
    super.key,
    this.initialX = 50,
    this.initialY = 100,
    this.onTap,
    this.size = 60,
  });

  @override
  State<DraggableCatMascot> createState() => _DraggableCatMascotState();
}

class _DraggableCatMascotState extends State<DraggableCatMascot>
    with TickerProviderStateMixin {
  late double _x;
  late double _y;
  bool _isDragging = false;
  bool _isBlinking = false;

  // Controladores de animação
  late AnimationController _scaleController;
  late AnimationController _shadowController;
  late AnimationController _particleController;
  late AnimationController _floatController;
  late AnimationController _blinkController;
  late AnimationController _jumpController;
  late AnimationController _purringController;
  late AnimationController _wobbleController;
  late AnimationController _sparkleController;

  // Animações
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowOpacityAnimation;
  late Animation<double> _shadowBlurAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _jumpAnimation;
  late Animation<double> _purringAnimation;
  late Animation<double> _wobbleAnimation;

  // Lista de partículas
  final List<MagicParticle> _particles = [];
  final List<TrailParticle> _trailParticles = [];

  // Para o rastro durante arraste
  DateTime? _lastParticleTime;

  // Limite de partículas e debounce
  static const int _maxParticles = 100;
  static const int _maxTrailParticles = 50;
  static const int _maxRapidTaps = 5;
  int _rapidTapCount = 0;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _x = widget.initialX;
    _y = widget.initialY;

    // Controlador de escala
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Controlador de sombra
    _shadowController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _shadowOpacityAnimation = Tween<double>(
      begin: 0.2,
      end: 0.4,
    ).animate(CurvedAnimation(
      parent: _shadowController,
      curve: Curves.easeInOut,
    ));

    _shadowBlurAnimation = Tween<double>(
      begin: 8,
      end: 12,
    ).animate(CurvedAnimation(
      parent: _shadowController,
      curve: Curves.easeInOut,
    ));

    // Controlador de partículas
    _particleController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..addListener(() {
      setState(() {
        // Atualizar partículas
        _particles.removeWhere((p) => p.opacity <= 0);
        for (var particle in _particles) {
          particle.update();
        }

        // Atualizar rastro
        _trailParticles.removeWhere((p) => p.opacity <= 0);
        for (var particle in _trailParticles) {
          particle.update();
        }
      });
    });

    // Controlador de flutuação mais bouncy
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: -5,
      end: 5,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOutBack,
    ));

    // Controlador de "ronronar" (respiração fofa)
    _purringController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _purringAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _purringController,
      curve: Curves.easeInOut,
    ));

    // Controlador de balanço lateral fofo
    _wobbleController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    )..repeat(reverse: true);

    _wobbleAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _wobbleController,
      curve: Curves.easeInOut,
    ));

    // Controlador de brilhos
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Controlador de piscar
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Controlador de pulo (quando clica)
    _jumpController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _jumpAnimation = Tween<double>(
      begin: 0,
      end: -30,
    ).animate(CurvedAnimation(
      parent: _jumpController,
      curve: Curves.easeOut,
    ));

    // Iniciar animação de partículas em loop contínuo
    _particleController.repeat();

    _startBlinking();
  }

  void _startBlinking() {
    Future.delayed(Duration(seconds: 3 + math.Random().nextInt(4)), () {
      if (mounted && !_isDragging) {
        setState(() => _isBlinking = true);
        _blinkController.forward().then((_) {
          if (mounted) {
            setState(() => _isBlinking = false);
            _blinkController.reverse();
            _startBlinking();
          }
        });
      } else if (mounted) {
        _startBlinking();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shadowController.dispose();
    _particleController.dispose();
    _floatController.dispose();
    _blinkController.dispose();
    _jumpController.dispose();
    _purringController.dispose();
    _wobbleController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  void _onTap() {
    // Evitar cliques durante arraste
    if (_isDragging) return;

    final now = DateTime.now();

    // Resetar contador se passou mais de 1 segundo desde o último tap
    if (_lastTapTime != null && now.difference(_lastTapTime!).inMilliseconds > 1000) {
      _rapidTapCount = 0;
    }

    // Limitar a 5 taps rápidos
    if (_rapidTapCount >= _maxRapidTaps) return;

    _rapidTapCount++;
    _lastTapTime = now;

    // Criar explosão de partículas (com limite)
    _createParticleBurst(_x + widget.size / 2, _y + widget.size / 2);

    // Animação de "pulo" - escala e movimento vertical
    if (!_scaleController.isAnimating) {
      _scaleController.forward().then((_) {
        if (mounted) _scaleController.reverse();
      });
    }

    // Animação de pulo para cima
    if (!_jumpController.isAnimating) {
      _jumpController.forward().then((_) {
        if (mounted) {
          _jumpController.reverse().then((_) {
            // Resetar contador após animação completa se passou tempo suficiente
            if (mounted && _lastTapTime != null &&
                DateTime.now().difference(_lastTapTime!).inMilliseconds > 500) {
              _rapidTapCount = 0;
            }
          });
        }
      });
    }

    // Callback opcional
    widget.onTap?.call();
  }

  void _createParticleBurst(double x, double y) {
    // Limitar quantidade de partículas
    if (_particles.length >= _maxParticles) {
      // Remover as mais antigas
      _particles.removeRange(0, 20);
    }

    final random = math.Random();
    // Partículas mágicas com cores fofas (reduzido para 12)
    for (int i = 0; i < 12; i++) {
      final colors = [
        AppColors.lilac,
        AppColors.starYellow,
        const Color(0xFFFFB6C1), // Rosa fofo
        const Color(0xFFFFE4E1), // Rosa claro
      ];
      _particles.add(MagicParticle(
        x: x,
        y: y,
        vx: (random.nextDouble() - 0.5) * 6,
        vy: (random.nextDouble() - 0.5) * 6 - 4,
        size: random.nextDouble() * 5 + 3,
        color: colors[random.nextInt(colors.length)],
        opacity: 1.0,
        isHeart: random.nextDouble() > 0.6, // 40% chance de ser coração
        isStar: random.nextDouble() > 0.75, // 25% chance de ser estrela
      ));
    }
  }

  void _createTrailParticle(double x, double y) {
    // Limitar quantidade de partículas de rastro
    if (_trailParticles.length >= _maxTrailParticles) {
      _trailParticles.removeRange(0, 10);
    }

    final now = DateTime.now();
    // Intervalo para rastro (40ms)
    if (_lastParticleTime == null ||
        now.difference(_lastParticleTime!).inMilliseconds > 40) {
      _lastParticleTime = now;

      final random = math.Random();
      _trailParticles.add(TrailParticle(
        x: x + widget.size / 2 + (random.nextDouble() - 0.5) * 10,
        y: y + widget.size / 2 + (random.nextDouble() - 0.5) * 10,
        size: random.nextDouble() * 3 + 1.5,
        color: random.nextBool()
          ? AppColors.lilac.withOpacity(0.7)
          : AppColors.starYellow.withOpacity(0.7),
        opacity: 1.0,
        rotation: random.nextDouble() * math.pi * 2,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Camada de partículas (atrás do gato)
        ..._buildParticles(),

        // Gato arrastável
        AnimatedBuilder(
          animation: Listenable.merge([_floatAnimation, _jumpAnimation]),
          builder: (context, child) => Positioned(
            left: _x,
            top: _y +
                (_isDragging ? 0 : _floatAnimation.value) +
                _jumpAnimation.value,
            child: child!,
          ),
          child: GestureDetector(
            onTap: _onTap,
            onPanStart: (details) {
              // Resetar contador de taps
              _rapidTapCount = 0;

              // Parar animações em andamento antes de iniciar arraste
              if (_jumpController.isAnimating) {
                _jumpController.stop();
                _jumpController.reset();
              }

              setState(() {
                _isDragging = true;
              });
              _shadowController.forward();
              _scaleController.forward();
            },
            onPanUpdate: (details) {
              setState(() {
                _x += details.delta.dx;
                _y += details.delta.dy;

                // Limitar aos bounds da tela
                _x = _x.clamp(0.0, screenSize.width - widget.size);
                _y = _y.clamp(0.0, screenSize.height - widget.size - 100);

                // Criar partículas de rastro
                _createTrailParticle(_x, _y);
              });
            },
            onPanEnd: (details) {
              setState(() {
                _isDragging = false;
              });
              _shadowController.reverse();
              // Só reverter se estiver no estado forward
              if (_scaleController.status == AnimationStatus.completed ||
                  _scaleController.status == AnimationStatus.forward) {
                _scaleController.reverse();
              }
            },
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _scaleAnimation,
                _shadowOpacityAnimation,
                _shadowBlurAnimation,
              ]),
              builder: (context, child) {
                return Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // Forma circular para brilho redondo
                    // Sombra lilás sempre visível
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lilac.withOpacity(
                          _shadowOpacityAnimation.value
                        ),
                        blurRadius: _shadowBlurAnimation.value,
                        spreadRadius: 2,
                      ),
                      // Segunda sombra para efeito de brilho
                      if (_isDragging)
                        BoxShadow(
                          color: AppColors.starYellow.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_purringAnimation, _wobbleAnimation]),
                    builder: (context, child) => Transform.rotate(
                      angle: _isDragging ? 0 : _wobbleAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value * (_isDragging ? 1.0 : _purringAnimation.value),
                        child: SvgPicture.string(
                          getCatSvgForPose(CatPose.sitting, _isBlinking),
                          width: widget.size,
                          height: widget.size,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Camada de partículas de rastro (na frente do gato)
        ..._buildTrailParticles(),
      ],
    );
  }

  List<Widget> _buildParticles() {
    return _particles.map((particle) {
      Widget particleWidget;

      if (particle.isHeart) {
        // Coração fofo
        particleWidget = Transform.rotate(
          angle: particle.rotation,
          child: Text(
            '💖',
            style: TextStyle(
              fontSize: particle.size * 1.5,
              color: Colors.white.withOpacity(particle.opacity),
            ),
          ),
        );
      } else if (particle.isStar) {
        // Estrela brilhante
        particleWidget = Transform.rotate(
          angle: particle.rotation,
          child: Text(
            '✨',
            style: TextStyle(
              fontSize: particle.size * 1.2,
              color: Colors.white.withOpacity(particle.opacity),
            ),
          ),
        );
      } else {
        // Partícula circular padrão
        particleWidget = Container(
          width: particle.size,
          height: particle.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: particle.color.withOpacity(particle.opacity),
            boxShadow: [
              BoxShadow(
                color: particle.color.withOpacity(particle.opacity * 0.5),
                blurRadius: particle.size * 2,
                spreadRadius: particle.size / 2,
              ),
            ],
          ),
        );
      }

      return Positioned(
        left: particle.x - particle.size,
        top: particle.y - particle.size,
        child: IgnorePointer(child: particleWidget),
      );
    }).toList();
  }

  List<Widget> _buildTrailParticles() {
    return _trailParticles.map((particle) {
      return Positioned(
        left: particle.x - particle.size / 2,
        top: particle.y - particle.size / 2,
        child: IgnorePointer(
          child: Transform.rotate(
            angle: particle.rotation, // Usar rotação fixa da partícula
            child: Container(
              width: particle.size * 2,
              height: particle.size,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    particle.color.withOpacity(particle.opacity),
                    particle.color.withOpacity(0),
                  ],
                ),
              ),
              child: CustomPaint(
                painter: StarPainter(
                  color: particle.color.withOpacity(particle.opacity),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

// Classe para partículas de clique (com corações e estrelas!)
class MagicParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double opacity;
  bool isHeart;
  bool isStar;
  double rotation;

  MagicParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.opacity,
    this.isHeart = false,
    this.isStar = false,
  }) : rotation = math.Random().nextDouble() * math.pi * 2;

  void update() {
    x += vx;
    y += vy;
    vy += 0.15; // Gravidade mais suave
    vx *= 0.98; // Fricção horizontal
    opacity -= 0.012; // Dura mais tempo
    size *= 0.985;
    rotation += 0.1; // Girar suavemente
  }
}

// Classe para partículas de rastro
class TrailParticle {
  double x;
  double y;
  double size;
  Color color;
  double opacity;
  final double rotation; // Ângulo de rotação fixo

  TrailParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.opacity,
    required this.rotation,
  });

  void update() {
    opacity -= 0.02; // Reduzido de 0.05 para 0.02 - rastro mais longo
    size *= 1.03; // Cresce mais lentamente
  }
}

// Painter para desenhar estrelinhas
class StarPainter extends CustomPainter {
  final Color color;

  StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Desenhar uma estrela de 4 pontas simples
    for (int i = 0; i < 8; i++) {
      final angle = (math.pi / 4) * i;
      final distance = i.isEven ? radius : radius * 0.4;
      final x = center.dx + distance * math.cos(angle);
      final y = center.dy + distance * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
