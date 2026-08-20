import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Microinterações das telas pré-login. Todas respeitam "reduzir movimento"
/// e nenhuma liga loop infinito antes de ler a preferência (testes de widget
/// nunca ficam presos num pumpAndSettle).

/// Encolhe de leve (0.97) enquanto pressionado, com haptic sutil — o toque
/// "responde" imediatamente, antes mesmo da ação executar.
class PressableScale extends StatefulWidget {
  final Widget child;

  const PressableScale({super.key, required this.child});

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
    if (v) HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Sacode o filho na horizontal — o "não" universal para erro de formulário.
/// Dispare com [ShakerState.shake] via GlobalKey.
class Shaker extends StatefulWidget {
  final Widget child;

  const Shaker({super.key, required this.child});

  @override
  ShakerState createState() => ShakerState();
}

class ShakerState extends State<Shaker> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  void shake() {
    if (MediaQuery.disableAnimationsOf(context)) return;
    HapticFeedback.mediumImpact();
    _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        // Seno amortecido: 3 oscilações que morrem suaves.
        final t = _c.value;
        final dx = math.sin(t * math.pi * 6) * (1 - t) * 8;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}

/// Brilho que varre o botão de tempos em tempos — a linguagem "sheen" dos
/// emblemas do app, aplicada ao CTA primário. Parado sob "reduzir movimento".
class SheenSweep extends StatefulWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const SheenSweep({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<SheenSweep> createState() => _SheenSweepState();
}

class _SheenSweepState extends State<SheenSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  bool? _reduced;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced == _reduced) return;
    _reduced = reduced;
    if (reduced) {
      _c.stop();
      _c.value = 0;
    } else {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reduced ?? false) return widget.child;
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        // passthrough: repassa as constraints do pai intactas ao botão.
        // O fit padrão (loose) as afrouxa — num Column(stretch), o botão
        // encolhia para a largura intrínseca em vez de ocupar a linha.
        fit: StackFit.passthrough,
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, _) {
                  // A faixa cruza o botão no primeiro 1/3 do ciclo e
                  // descansa o resto — brilho ocasional, não estroboscópio.
                  // Align (e não translação): o deslocamento é relativo ao
                  // BOTÃO, e além de ±1 a faixa entra/sai pelas bordas,
                  // aparada pelo ClipRRect.
                  final t = (_c.value * 3).clamp(0.0, 1.0);
                  return Align(
                    alignment: Alignment(-1.6 + t * 3.2, 0),
                    child: Transform(
                      transform: Matrix4.skewX(-0.35),
                      child: Container(
                        width: 42,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0),
                              Colors.white.withValues(alpha: 0.28),
                              Colors.white.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Uma faísca ✦ orbitando devagar em volta de um emblema — a linguagem de
/// órbita dos emblemas vivos. Decorativa: invisível para leitores de tela.
class OrbitingSparkle extends StatefulWidget {
  /// Raio da órbita em px.
  final double radius;
  final Color color;

  const OrbitingSparkle({super.key, required this.radius, required this.color});

  @override
  State<OrbitingSparkle> createState() => _OrbitingSparkleState();
}

class _OrbitingSparkleState extends State<OrbitingSparkle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  );

  bool? _reduced;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced == _reduced) return;
    _reduced = reduced;
    if (reduced) {
      _c.stop();
      _c.value = 0.12; // congela num ponto bonito da órbita
    } else {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final ang = _c.value * 2 * math.pi;
            return Transform.translate(
              offset: Offset(
                math.cos(ang) * widget.radius,
                math.sin(ang) * widget.radius * 0.42, // órbita elíptica
              ),
              child: Text(
                '✦',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.color,
                  shadows: [Shadow(color: widget.color, blurRadius: 6)],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
