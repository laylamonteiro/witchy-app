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
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (GrimoireMotion.reduced(context)) return child;
            final curved = CurvedAnimation(
              parent: animation,
              curve: GrimoireMotion.enter,
              reverseCurve: GrimoireMotion.exit,
            );
            return FadeTransition(
              opacity: curved,
              child: AnimatedBuilder(
                animation: curved,
                builder: (context, inner) => Transform.translate(
                  // 8 px fixos (não fração da tela): sutil em qualquer altura.
                  offset: Offset(0, (1 - curved.value) * 8),
                  child: inner,
                ),
                child: child,
              ),
            );
          },
        );
}
