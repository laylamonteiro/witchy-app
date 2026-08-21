import 'package:flutter/material.dart';

import '../theme/grimoire_colors.dart';

/// Os pontinhos que indicam em que página a pessoa está.
///
/// O app tinha três cópias deste mesmo desenho, com geometrias levemente
/// diferentes (carrossel lunar, onboarding e tour do Salem). Esta é a versão
/// única; as outras podem migrar para cá numa limpeza separada.
///
/// Com [onTap] os pontos viram alvo de toque para pular direto para a página;
/// sem ele são apenas decorativos — e nesse caso saem da árvore de semântica,
/// porque um leitor de tela não tem o que fazer com eles.
class PageDots extends StatelessWidget {
  const PageDots({
    super.key,
    required this.count,
    required this.index,
    this.onTap,
    this.activeWidth = 18,
    this.size = 6,
  });

  /// Quantas páginas existem.
  final int count;

  /// A página ativa (0-based).
  final int index;

  /// Se informado, tocar num ponto pede para ir àquela página.
  final ValueChanged<int>? onTap;

  /// Largura do ponto ativo — ele vira um traço, os outros ficam redondos.
  final double activeWidth;

  /// Altura de todos os pontos, e largura dos inativos.
  final double size;

  @override
  Widget build(BuildContext context) {
    // Uma página só não tem o que indicar.
    if (count <= 1) return const SizedBox.shrink();

    final linha = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final ativo = i == index;
        final ponto = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: ativo ? activeWidth : size,
            height: size,
            decoration: BoxDecoration(
              color: ativo
                  ? context.gc.lilac
                  : context.gc.lilac.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(size / 2),
            ),
          ),
        );

        final aoTocar = onTap;
        if (aoTocar == null) return ponto;

        return GestureDetector(
          onTap: () => aoTocar(i),
          behavior: HitTestBehavior.opaque,
          child: ponto,
        );
      }),
    );

    return onTap == null ? ExcludeSemantics(child: linha) : linha;
  }
}
