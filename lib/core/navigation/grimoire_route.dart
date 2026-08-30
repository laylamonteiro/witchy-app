import 'package:flutter/material.dart';

import '../theme/grimoire_motion.dart';

/// Transição de rota padrão do Grimório: fade + subida de 8 px, ~220 ms.
/// Discreta de propósito — virar página é metáfora exclusiva da
/// Enciclopédia; o resto do app só "assenta" na tela.
///
/// Uso: `Navigator.push(context, GrimoireRoute(builder: (_) => Tela()))` —
/// mesmo contrato do MaterialPageRoute, para migração 1:1 onde fizer
/// sentido.
///
/// Limite conhecido: sem o mixin Cupertino, o iOS perde o swipe de borda
/// para voltar NESTA rota (o botão/gesto do sistema seguem valendo). Por
/// isso ela entra tela a tela, nas navegações comuns — não em fluxos onde
/// o swipe é parte do hábito.
///
/// Com "reduzir movimento" ativo, a tela aparece pronta (sem fade nem
/// deslocamento).
class GrimoireRoute<T> extends PageRouteBuilder<T> {
  GrimoireRoute({
    required WidgetBuilder builder,
    super.settings,
    super.fullscreenDialog,
  }) : super(
          transitionDuration: GrimoireMotion.route,
          reverseTransitionDuration: const Duration(milliseconds: 180),
          // O MaterialPageRoute embrulha a página em Semantics de rota; o
          // PageRouteBuilder cru não — sem isto, o leitor de tela deixaria
          // de anunciar/escopar a tela nova como rota.
          pageBuilder: (context, animation, secondaryAnimation) => Semantics(
            scopesRoute: true,
            explicitChildNodes: true,
            child: builder(context),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (GrimoireMotion.reduced(context)) return child;
            return _EntradaDaRota(animation: animation, child: child);
          },
        );
}

/// A entrada em si: fade + subida de 8 px.
///
/// É um StatefulWidget porque a curva precisa VIVER mais que um quadro. O
/// `transitionsBuilder` é chamado a cada quadro da transição, e uma
/// CurvedAnimation criada ali dentro registra um listener na animação da
/// rota a cada quadro — listeners que ninguém remove, em toda navegação.
class _EntradaDaRota extends StatefulWidget {
  final Animation<double> animation;
  final Widget child;

  const _EntradaDaRota({required this.animation, required this.child});

  @override
  State<_EntradaDaRota> createState() => _EntradaDaRotaState();
}

class _EntradaDaRotaState extends State<_EntradaDaRota> {
  late CurvedAnimation _curva = _cria();

  CurvedAnimation _cria() => CurvedAnimation(
        parent: widget.animation,
        curve: GrimoireMotion.enter,
        reverseCurve: GrimoireMotion.exit,
      );

  @override
  void didUpdateWidget(covariant _EntradaDaRota old) {
    super.didUpdateWidget(old);
    if (widget.animation == old.animation) return;
    _curva.dispose();
    _curva = _cria();
  }

  @override
  void dispose() {
    _curva.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curva,
      child: AnimatedBuilder(
        animation: _curva,
        builder: (context, inner) => Transform.translate(
          // 8 px fixos (não fração da tela): sutil em qualquer altura.
          offset: Offset(0, (1 - _curva.value) * 8),
          child: inner,
        ),
        child: widget.child,
      ),
    );
  }
}
