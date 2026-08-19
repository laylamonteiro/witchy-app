import 'dart:async';

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

/// Entrada em cascata para LISTAS builder (ListView.builder): envolva cada
/// item informando o [index] — os primeiros [maxAnimated] entram em cascata
/// na primeira montagem da lista, o resto aparece direto.
///
/// Envolva a lista num [CascadeScope]: sem ele, rolar para longe e voltar
/// remonta os primeiros itens e reanima a entrada.
class CascadeIn extends StatelessWidget {
  final int index;
  final Widget child;

  /// Atraso entre um item e o próximo.
  final Duration step;

  /// Duração da entrada de cada item.
  final Duration duration;

  /// Quantos itens animam (o que está abaixo da dobra não precisa).
  final int maxAnimated;

  const CascadeIn({
    super.key,
    required this.index,
    required this.child,
    this.step = const Duration(milliseconds: 70),
    this.duration = const Duration(milliseconds: 420),
    this.maxAnimated = 6,
  });

  @override
  Widget build(BuildContext context) {
    if (index >= maxAnimated ||
        MediaQuery.disableAnimationsOf(context) ||
        !CascadeScope.isFresh(context)) {
      return child;
    }
    return _FadeSlideIn(delay: step * index, duration: duration, child: child);
  }
}

/// Marca o nascimento de uma lista: os [CascadeIn] que montarem logo em
/// seguida (janela de ~900ms) cascateiam; os que montarem depois — a
/// rolagem voltando ao topo — entram parados, sem repetir o show.
class CascadeScope extends StatefulWidget {
  final Widget child;

  const CascadeScope({super.key, required this.child});

  /// true sem escopo por perto (uso avulso) ou com a lista recém-nascida.
  static bool isFresh(BuildContext context) {
    final state = context.findAncestorStateOfType<_CascadeScopeState>();
    if (state == null) return true;
    return DateTime.now().difference(state._born) <
        const Duration(milliseconds: 900);
  }

  @override
  State<CascadeScope> createState() => _CascadeScopeState();
}

class _CascadeScopeState extends State<CascadeScope> {
  final DateTime _born = DateTime.now();

  @override
  Widget build(BuildContext context) => widget.child;
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

  // Tipado como CurvedAnimation (e não Animation) porque ele também precisa
  // ser liberado no dispose.
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  /// A espera até a entrada começar. Fica guardada para ser CANCELADA no
  /// dispose: um `Future.delayed` solto continua vivo depois que a tela sai
  /// (o `mounted` evita o crash, mas o timer segue pendente até disparar) —
  /// e um timer pendente é justamente o que trava um teste de widget.
  Timer? _entrada;

  @override
  void initState() {
    super.initState();
    _entrada = Timer(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _entrada?.cancel();
    _curve.dispose();
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
