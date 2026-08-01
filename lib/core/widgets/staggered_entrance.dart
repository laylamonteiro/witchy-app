import 'package:flutter/material.dart';

/// Entrada em cascata: cada filho aparece com um leve atraso, subindo e
/// surgindo. Dá vida à primeira abertura de uma tela sem custar interação.
///
/// A animação roda UMA vez, na montagem — reconstruções normais (mudou o
/// streak, marcou um rito) não fazem a tela piscar de novo.
class StaggeredEntrance extends StatelessWidget {
  final List<Widget> children;

  /// Atraso entre um filho e o próximo.
  final Duration step;

  /// Duração da entrada de cada filho.
  final Duration duration;

  /// Quantos filhos animam antes de o resto aparecer direto (o que está
  /// abaixo da dobra não precisa de animação — ninguém vê).
  final int maxAnimated;

  const StaggeredEntrance({
    super.key,
    required this.children,
    this.step = const Duration(milliseconds: 70),
    this.duration = const Duration(milliseconds: 420),
    this.maxAnimated = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++)
          if (i < maxAnimated)
            _FadeSlideIn(
              delay: step * i,
              duration: duration,
              child: children[i],
            )
          else
            children[i],
      ],
    );
  }
}

class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const _FadeSlideIn({
    required this.child,
    required this.delay,
    required this.duration,
  });

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
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
      opacity: _curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(_curve),
        child: widget.child,
      ),
    );
  }
}
