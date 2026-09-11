import 'package:flutter/material.dart';
import '../theme/grimoire_colors.dart';
import '../theme/grimoire_motion.dart';
import '../../features/grimoire/data/models/spell_model.dart';
import 'moon_disc.dart';

/// A lua em destaque: disco desenhado ([MoonDisc]) com halo pulsante e, se
/// pedido, estrelas piscando ao redor.
///
/// A fase chega como [MoonPhase], não como emoji: o glifo dependia da fonte
/// de cada plataforma e desenhava uma lua no aparelho e outra no navegador.
class BreathingMoon extends StatefulWidget {
  final MoonPhase phase;
  final double size;
  final bool showStars;
  final bool showName;
  final bool showDescription;

  const BreathingMoon({
    super.key,
    required this.phase,
    this.size = 80,
    this.showStars = true,
    this.showName = false,
    this.showDescription = false,
  });

  @override
  State<BreathingMoon> createState() => _BreathingMoonState();
}

class _BreathingMoonState extends State<BreathingMoon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  /// null = as dependências ainda não foram lidas uma primeira vez.
  bool? _reduzido;

  @override
  void initState() {
    super.initState();

    // O laço NÃO liga aqui: só depois de ler a preferência de movimento
    // (ver didChangeDependencies). Ligar no initState também prenderia
    // qualquer pumpAndSettle da suíte para sempre.
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduzido = GrimoireMotion.reduced(context);
    if (reduzido == _reduzido) return;
    _reduzido = reduzido;
    if (reduzido) {
      _controller.stop();
      // Meio do ciclo: a lua fica parada num brilho intermediário, nem
      // apagada nem estourada.
      _controller.value = 0.5;
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
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
                        context.gc.lilac.withValues(alpha: _glowAnimation.value),
                        // A MESMA cor com alpha 0, e não o fundo transparente:
                        // interpolar lilás → fundo atravessa um cinza morto no
                        // meio do gradiente e suja o halo.
                        context.gc.lilac.withValues(alpha: 0),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Lua com respiração. O halo do disco fica desligado: o pulsante
            // acima já é o halo desta cena, e dois somados viram neon.
            ScaleTransition(
              scale: _scaleAnimation,
              child: MoonDisc(
                phase: widget.phase,
                size: widget.size,
                halo: false,
              ),
            ),

            // Estrelas piscantes ao redor
            if (widget.showStars) ..._buildStars(),
          ],
        ),
        if (widget.showName) ...[
          const SizedBox(height: 8),
          Text(
            widget.phase.displayName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.gc.lilac,
                ),
            textAlign: TextAlign.center,
          ),
        ],
        if (widget.showDescription) ...[
          const SizedBox(height: 4),
          Text(
            widget.phase.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.gc.textSecondary,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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

  bool? _reduzido;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduzido = GrimoireMotion.reduced(context);
    if (reduzido == _reduzido) return;
    _reduzido = reduzido;
    if (reduzido) {
      _controller.stop();
      // Estrelas congeladas a meia-luz: quem pediu calma não fica com um céu
      // apagado, só com um céu quieto.
      _controller.value = 0.5;
      return;
    }
    // O atraso escalonado é o que faz as estrelas acenderem em sequência, e
    // não todas no mesmo instante.
    Future.delayed(widget.delay, () {
      if (mounted && _reduzido == false) {
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
              color: context.gc.starYellow.withValues(alpha: 0.8),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}
