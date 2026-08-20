import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/living_emblem.dart' show BlinkStar;

/// Emblema "vivo" das telas pré-login: o distintivo circular da tela
/// (cadeado, pena, lua...) sob a mesma respiração de 3s do LivingEmblem e
/// da BreathingMoon, com halo pulsante e estrelas ✦ piscando ao redor.
///
/// Congela num quadro bonito quando o sistema pede "reduzir movimento":
/// halo fixo a meia-luz, sem escala, estrelas paradas.
class BreathingBadge extends StatefulWidget {
  /// O distintivo em si (normalmente o círculo com o ícone da tela).
  final Widget child;

  /// Cor do halo e das estrelas — a cor de destaque da tela.
  final Color glowColor;

  /// Diâmetro do halo atrás do distintivo.
  final double haloSize;

  final bool showStars;

  const BreathingBadge({
    super.key,
    required this.child,
    required this.glowColor,
    this.haloSize = 120,
    this.showStars = true,
  });

  @override
  State<BreathingBadge> createState() => _BreathingBadgeState();
}

class _BreathingBadgeState extends State<BreathingBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathe = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );

  // Tipado como CurvedAnimation (e não Animation) porque também precisa
  // ser liberado no dispose.
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _breathe,
    curve: Curves.easeInOut,
  );

  /// null = primeira leitura de dependências ainda não aconteceu.
  bool? _reduced;

  /// O loop infinito só liga depois de ler a preferência de acessibilidade
  /// (e nunca em quem pediu movimento reduzido) — ligar no initState também
  /// prenderia qualquer teste de widget num pumpAndSettle eterno.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced == _reduced) return;
    _reduced = reduced;
    if (reduced) {
      _breathe.stop();
      _breathe.value = 0.5;
    } else {
      _breathe.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _breathe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = _reduced ?? false;
    final spread = widget.haloSize / 2;

    return SizedBox(
      width: widget.haloSize + 40,
      height: widget.haloSize + 40,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Halo pulsante
          AnimatedBuilder(
            animation: _curve,
            builder: (context, _) {
              final t = _curve.value;
              return Container(
                width: widget.haloSize + t * 16,
                height: widget.haloSize + t * 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.glowColor.withValues(alpha: 0.18 + t * 0.22),
                      widget.glowColor.withValues(alpha: 0),
                    ],
                  ),
                ),
              );
            },
          ),
          // O distintivo respirando
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.05).animate(_curve),
            child: widget.child,
          ),
          // Estrelas piscando ao redor — a assinatura da casa
          if (widget.showStars) ...[
            Positioned(
              top: 6,
              left: spread - 26,
              child: BlinkStar(
                delay: Duration.zero,
                color: context.gc.starYellow,
                reduced: reduced,
              ),
            ),
            Positioned(
              top: spread - 18,
              right: 2,
              child: BlinkStar(
                delay: const Duration(milliseconds: 600),
                color: context.gc.starYellow,
                reduced: reduced,
                size: 9,
              ),
            ),
            Positioned(
              bottom: 10,
              left: 8,
              child: BlinkStar(
                delay: const Duration(milliseconds: 1100),
                color: context.gc.starYellow,
                reduced: reduced,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Brilho respirando atrás do botão principal da tela — chama o olhar para
/// a ação primária sem gritar. Mesmo ciclo de 3s dos emblemas; fica num
/// brilho fixo e discreto sob "reduzir movimento".
class BreathingGlow extends StatefulWidget {
  final Widget child;
  final Color color;
  final BorderRadius borderRadius;

  const BreathingGlow({
    super.key,
    required this.child,
    required this.color,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<BreathingGlow> createState() => _BreathingGlowState();
}

class _BreathingGlowState extends State<BreathingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathe = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );

  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _breathe,
    curve: Curves.easeInOut,
  );

  bool? _reduced;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced == _reduced) return;
    _reduced = reduced;
    if (reduced) {
      _breathe.stop();
      _breathe.value = 0.4;
    } else {
      _breathe.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _breathe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.20 + _curve.value * 0.18),
              blurRadius: 18 + _curve.value * 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}
