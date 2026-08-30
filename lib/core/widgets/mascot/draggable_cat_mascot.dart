import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Using raster PNG assets for the mascot images instead of SVG
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/grimoire_colors.dart';

/// Poses do mascote baseadas nos novos SVG assets
enum MascotPose {
  sitting,      // Sentado normal (usa tail animations)
  lyingRelaxed, // Deitado relaxado
  sleeping,     // Dormindo
}

/// Widget do mascote gatinho preto arrastável com efeitos mágicos
///
/// Features:
/// - Sombra lilás sempre visível
/// - Arrastável pela tela sem bloquear outras interações
/// - Efeitos de partículas ao clicar e arrastar
/// - Rastro mágico durante o arraste
/// - Animações de flutuação
/// - Poses dinâmicas: sentado, deitado, dormindo
/// - Expressões: bravo (padrão), neutro, feliz
class DraggableCatMascot extends StatefulWidget {
  final double initialX;
  final double initialY;
  final VoidCallback? onTap;
  final double size;
  final ValueNotifier<Offset>? positionNotifier;
  /// Pasta base onde estão os assets do mascote (ex: 'assets/icons/new_cat')
  final String assetFolder;

  /// Chamado quando o 5º toque rápido dissolve o Salem em fumaça — o pai
  /// esconde o mascote (5 toques seguidos na tela o trazem de volta).
  final VoidCallback? onDismissed;

  /// Ao montar, o Salem MATERIALIZA em fumaça (espelho do sumiço) — usado
  /// quando ele volta do esconderijo.
  final bool appearInSmoke;

  /// Fim da animação de materializar (o pai consome a flag transitória).
  final VoidCallback? onAppeared;

  /// Contador de reações vindas de fora: quando muda, o Salem comemora um
  /// acontecimento raro (level up, milestone de streak) sozinho, sem toque.
  final int reactionTick;

  const DraggableCatMascot({
    super.key,
    this.initialX = 50,
    this.initialY = 100,
    this.onTap,
    this.size = 85,
    this.positionNotifier,
    this.assetFolder = 'assets/icons/new_cat',
    this.onDismissed,
    this.appearInSmoke = false,
    this.onAppeared,
    this.reactionTick = 0,
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
  bool _isHappy = false; // Expressão feliz quando toca
  bool _isSleepWarning = false;
  bool _isDismissing = false; // Sumindo em fumaça (5 toques rápidos)
  bool _isMaterializing = false; // Voltando do esconderijo em fumaça

  // Pose atual do mascote
  MascotPose _currentPose = MascotPose.sitting;

  // Timer para idle (dormir após inatividade)
  Timer? _idleTimer;
  Timer? _sleepTransitionTimer;
  static const Duration _idleTimeout = Duration(seconds: 12);
  static const Duration _lyingRelaxedIdleTimeout = Duration(seconds: 5);

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
    widget.positionNotifier?.value = Offset(_x, _y);

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
      curve: Curves.easeInOutCirc,
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

    // Voltando do esconderijo: nasce invisível, solta a fumaça e cresce
    // (mesma nuvem do sumiço, ao contrário).
    if (widget.appearInSmoke) {
      _isMaterializing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _createSmokeBurst(_x + widget.size / 2, _y + widget.size / 2);
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) setState(() => _isMaterializing = false);
        });
        Future.delayed(const Duration(milliseconds: 550), () {
          if (mounted) widget.onAppeared?.call();
        });
      });
    }

    _startBlinking();
    _resetIdleTimer();
  }

  /// Retorna o asset SVG correto baseado no estado atual
  String get _currentSpriteAsset {
    // Se dormindo
    if (_currentPose == MascotPose.sleeping) {
      return '${widget.assetFolder}/cat_sleep.png';
    }

    // Se deitado relaxado
    if (_currentPose == MascotPose.lyingRelaxed) {
      return '${widget.assetFolder}/cat_lie_relaxed.png';
    }

    // Sentado - várias expressões
    if (_isBlinking) {
      return '${widget.assetFolder}/cat_sit_blink.png';
    }

    // Feliz quando está sendo arrastado ou após tap
    if (_isHappy || _isDragging) {
      return '${widget.assetFolder}/cat_sit_happy.png';
    }

    // Só usar angry como aviso de sono, não como expressão padrão
    if (_isSleepWarning && _currentPose == MascotPose.sitting) {
      return '${widget.assetFolder}/cat_sit_angry.png';
    }

    // Usar wobble para alternar cauda esquerda/direita quando não está arrastando
    if (!_isDragging && _wobbleController.isAnimating) {
      final wobbleValue = _wobbleAnimation.value;
      if (wobbleValue <= 0) {
        return '${widget.assetFolder}/cat_sit_tail_left.png';
      }
      return '${widget.assetFolder}/cat_sit_tail_right.png';
    }

    // Expressão padrão sentada neutra utilizando cauda esquerda
    return '${widget.assetFolder}/cat_sit_tail_left.png';
  }

  /// Reseta o timer de inatividade
  /// [resetPose] - se true, força a pose para sitting (default: false)
  void _cancelSleepTransitionTimer() {
    _sleepTransitionTimer?.cancel();
    _sleepTransitionTimer = null;
  }

  void _resetIdleTimer({bool resetPose = false}) {
    _idleTimer?.cancel();
    _cancelSleepTransitionTimer();

    // Se solicitado, acordar completamente
    if (resetPose && _currentPose != MascotPose.sitting) {
      setState(() {
        _currentPose = MascotPose.sitting;
        _isSleepWarning = false;
      });
    } else {
      _isSleepWarning = false;
    }

    final idleDuration = _currentPose == MascotPose.lyingRelaxed
        ? _lyingRelaxedIdleTimeout
        : _idleTimeout;

    _idleTimer = Timer(idleDuration, () {
      if (!mounted || _isDragging) return;

      if (_currentPose == MascotPose.lyingRelaxed) {
        setState(() {
          _currentPose = MascotPose.sleeping;
          _isSleepWarning = false;
        });
        return;
      }

      setState(() {
        _isSleepWarning = true;
      });

      _sleepTransitionTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && !_isDragging) {
          setState(() {
            _currentPose = MascotPose.sleeping;
            _isSleepWarning = false;
          });
        }
      });
    });
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
    _idleTimer?.cancel();
    _scaleController.dispose();
    _shadowController.dispose();
    _particleController.dispose();
    _floatController.dispose();
    _blinkController.dispose();
    _jumpController.dispose();
    _purringController.dispose();
    _wobbleController.dispose();
    _sparkleController.dispose();
    _cancelSleepTransitionTimer();
    super.dispose();
  }

  @override
  void didUpdateWidget(DraggableCatMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reactionTick != oldWidget.reactionTick) {
      _reacaoDeConquista();
    }
  }

  /// A mesma alegria do toque — expressão feliz, faíscas e pulinho — mas
  /// disparada por um acontecimento raro, sem passar pela contagem de
  /// toques. Fica quieta no arraste, no sumiço ou desmontado.
  void _reacaoDeConquista() {
    if (!mounted || _isDragging || _isDismissing) return;
    // Sob "reduzir movimento" a comemoração vai direto ao estado final: só a
    // carinha feliz por um instante, sem pulo, escala nem faíscas.
    if (MediaQuery.disableAnimationsOf(context)) {
      setState(() => _isHappy = true);
      Future.delayed(const Duration(milliseconds: 260), () {
        if (mounted) setState(() => _isHappy = false);
      });
      return;
    }
    setState(() => _isHappy = true);
    _createParticleBurst(_x + widget.size / 2, _y + widget.size / 2);
    if (!_scaleController.isAnimating) {
      _scaleController.forward().then((_) {
        if (mounted) _scaleController.reverse();
      });
    }
    if (!_jumpController.isAnimating) {
      _jumpController.forward().then((_) {
        if (mounted) {
          _jumpController.reverse().then((_) {
            if (mounted) setState(() => _isHappy = false);
          });
        }
      });
    }
  }

  void _onTap() {
    // Evitar cliques durante arraste
    if (_isDragging) return;

    // Um clique leve responde ao toque no mascote (pedido explícito da
    // Bruxa). No arraste não — o guard acima já saiu.
    HapticFeedback.selectionClick();

    // Se estava dormindo, vai para deitado relaxado primeiro
    if (_currentPose == MascotPose.sleeping) {
      setState(() {
        _currentPose = MascotPose.lyingRelaxed;
      });
      _resetIdleTimer();
      return;
    }

    // Se estava deitado, levanta
    if (_currentPose == MascotPose.lyingRelaxed) {
      setState(() {
        _currentPose = MascotPose.sitting;
      });
      _resetIdleTimer();
      return;
    }

    // Resetar timer de inatividade
    _resetIdleTimer();

    final now = DateTime.now();

    // Resetar contador se passou mais de 1 segundo desde o último tap
    if (_lastTapTime != null && now.difference(_lastTapTime!).inMilliseconds > 1000) {
      _rapidTapCount = 0;
    }

    if (_isDismissing) return;

    // 5º toque rápido: o Salem some em fumaça (se o pai quiser saber).
    if (_rapidTapCount >= _maxRapidTaps - 1 && widget.onDismissed != null) {
      _dismissInSmoke();
      return;
    }

    // Limitar a 5 taps rápidos
    if (_rapidTapCount >= _maxRapidTaps) return;

    _rapidTapCount++;
    _lastTapTime = now;

    // Ativar expressão feliz
    setState(() => _isHappy = true);

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
            // Voltar para expressão normal após animação
            if (mounted) {
              setState(() => _isHappy = false);
            }
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

  /// Handler para long press - deita o gatinho
  void _onLongPress() {
    if (_isDragging) return;

    _resetIdleTimer();

    // Se está sentado, deita relaxado
    if (_currentPose == MascotPose.sitting) {
      setState(() {
        _currentPose = MascotPose.lyingRelaxed;
      });

      // Criar algumas partículas de conforto
      _createParticleBurst(_x + widget.size / 2, _y + widget.size / 2);
    }
  }

  /// 5º toque rápido: nuvem de fumaça, o sprite encolhe/some e o pai é
  /// avisado para esconder o Salem.
  void _dismissInSmoke() {
    if (_isDismissing) return;
    setState(() => _isDismissing = true);
    _createSmokeBurst(_x + widget.size / 2, _y + widget.size / 2);
    Future.delayed(const Duration(milliseconds: 550), () {
      if (mounted) widget.onDismissed?.call();
    });
  }

  void _createSmokeBurst(double x, double y) {
    if (_particles.length >= _maxParticles) {
      _particles.removeRange(0, 20);
    }
    final random = math.Random();
    for (int i = 0; i < 22; i++) {
      final gray = 150 + random.nextInt(80);
      final smokeColors = [
        Color.fromARGB(255, gray, gray, gray),
        context.gc.lilac.withValues(alpha: 0.8),
      ];
      _particles.add(MagicParticle(
        x: x + (random.nextDouble() - 0.5) * widget.size * 0.6,
        y: y + (random.nextDouble() - 0.5) * widget.size * 0.6,
        vx: (random.nextDouble() - 0.5) * 3,
        vy: -random.nextDouble() * 3 - 1, // fumaça sobe
        size: random.nextDouble() * 10 + 6,
        color: smokeColors[random.nextInt(smokeColors.length)],
        opacity: 0.9,
        isHeart: false,
        isStar: false,
      ));
    }
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
        context.gc.lilac,
        context.gc.starYellow,
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
          ? context.gc.lilac.withValues(alpha: 0.7)
          : context.gc.starYellow.withValues(alpha: 0.7),
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
          child: AnimatedOpacity(
            opacity: (_isDismissing || _isMaterializing) ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 450),
            child: AnimatedScale(
            scale: (_isDismissing || _isMaterializing) ? 0.2 : 1.0,
            duration: const Duration(milliseconds: 450),
            curve: _isDismissing ? Curves.easeInBack : Curves.easeOutBack,
            child: GestureDetector(
            onTap: _onTap,
            onLongPress: _onLongPress,
            onPanStart: (details) {
              // Resetar contador de taps
              _rapidTapCount = 0;

              // Resetar timer de inatividade e acordar o gato
              _resetIdleTimer(resetPose: true);

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
              widget.positionNotifier?.value = Offset(_x, _y);
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
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // Forma circular para brilho redondo
                    // Sombra lilás sempre visível
                    boxShadow: [
                      BoxShadow(
                        color: context.gc.lilac.withValues(
                          alpha: _shadowOpacityAnimation.value
                        ),
                        blurRadius: _shadowBlurAnimation.value,
                        spreadRadius: 2,
                        offset: const Offset(0, 5), // Centraliza o brilho abaixo do gato
                      ),
                      // Segunda sombra para efeito de brilho
                      if (_isDragging)
                        BoxShadow(
                          color: context.gc.starYellow.withValues(alpha: 0.2),
                          blurRadius: 15,
                          spreadRadius: 3,
                          offset: const Offset(0, 5),
                        ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_purringAnimation, _wobbleAnimation]),
                    builder: (context, child) => Transform.rotate(
                      angle: _isDragging ? 0 : _wobbleAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value * (_isDragging ? 1.0 : _purringAnimation.value),
                        child: Image.asset(
                          _currentSpriteAsset,
                          width: widget.size,
                          height: widget.size,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('Mascot asset load failed: $_currentSpriteAsset -> $error');
                            final filename = _currentSpriteAsset.split('/').last;
                            final svgPath = 'assets/icons/old_cat/${filename.replaceAll('.png', '.svg')}';
                            try {
                              return SvgPicture.asset(
                                svgPath,
                                width: widget.size,
                                height: widget.size,
                                fit: BoxFit.contain,
                              );
                            } catch (e) {
                              debugPrint('SVG fallback failed: $svgPath -> $e');
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          ),
          ),
        ),

        // Camada de partículas de rastro (na frente do gato)
        ..._buildTrailParticles(),

        // Brilhos mágicos ao redor do mascote
        ..._buildSparkles(),
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
              color: Colors.white.withValues(alpha: particle.opacity),
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
              color: Colors.white.withValues(alpha: particle.opacity),
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
            color: particle.color.withValues(alpha: particle.opacity),
            boxShadow: [
              BoxShadow(
                color: particle.color.withValues(alpha: particle.opacity * 0.5),
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
                    particle.color.withValues(alpha: particle.opacity),
                    particle.color.withValues(alpha: 0),
                  ],
                ),
              ),
              child: CustomPaint(
                painter: StarPainter(
                  color: particle.color.withValues(alpha: particle.opacity),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  /// Constrói os brilhos mágicos ao redor do mascote
  List<Widget> _buildSparkles() {
    // Posições relativas dos brilhos ao redor do gato
    final sparklePositions = [
      const Offset(-15, -10),  // Esquerda superior
      const Offset(15, -15),   // Direita superior
      const Offset(-20, 20),   // Esquerda inferior
      const Offset(20, 15),    // Direita inferior
      const Offset(0, -20),    // Topo
    ];

    final sparkleSymbols = ['✦', '✧', '✦', '✧', '⋆'];
    final sparkleColors = [
      context.gc.starYellow,
      context.gc.lilac,
      context.gc.starYellow,
      context.gc.lilac,
      context.gc.starYellow,
    ];

    return List.generate(sparklePositions.length, (index) {
      // Cada brilho tem um delay diferente para criar efeito cascata
      final delay = index * 0.2;

      return AnimatedBuilder(
        animation: _sparkleController,
        builder: (context, child) {
          // Calcular opacidade com base no controller e delay
          final progress = (_sparkleController.value + delay) % 1.0;
          final opacity = (math.sin(progress * math.pi * 2) * 0.5 + 0.5) * 0.8;
          final scale = 0.8 + (math.sin(progress * math.pi * 2) * 0.2);

          return Positioned(
            left: _x + widget.size / 2 + sparklePositions[index].dx +
                (_isDragging ? 0 : _floatAnimation.value * 0.3),
            top: _y + widget.size / 2 + sparklePositions[index].dy +
                (_isDragging ? 0 : _floatAnimation.value) +
                _jumpAnimation.value,
            child: IgnorePointer(
              child: Transform.scale(
                scale: scale,
                child: Text(
                  sparkleSymbols[index],
                  style: TextStyle(
                    fontSize: 10,
                    color: sparkleColors[index].withValues(alpha: opacity),
                    shadows: [
                      Shadow(
                        color: sparkleColors[index].withValues(alpha: opacity * 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
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
