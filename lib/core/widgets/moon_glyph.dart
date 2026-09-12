import 'package:flutter/material.dart';

import '../theme/grimoire_colors.dart';
import '../../features/grimoire/data/models/spell_model.dart';

/// A lua do Grimório: o glifo da fase com o brilho do app atrás dele.
///
/// Houve uma tentativa de DESENHAR a lua (disco na sombra, região iluminada
/// recortada) para fugir da fonte do aparelho. O desenho era coerente entre
/// plataformas e visualmente pior: virava um disco chapado, sem o relevo e
/// sem as manchas que dão à lua cara de lua. A dona vetou, e ela tem razão —
/// a diferença que incomodava no navegador era o BRILHO faltando, não a
/// forma do glifo.
///
/// Então o glifo volta, e o brilho passa a ser do app: um halo radial
/// desenhado em código, que aparece igual em Android e navegador porque não
/// depende de fonte nenhuma. Quem já tem halo próprio — a [BreathingMoon],
/// cujo brilho pulsa — desliga este com `halo: false`, senão os dois somados
/// viram neon.
///
/// É enfeite para o leitor de tela: quem fala é o nome da fase, que todos os
/// chamadores escrevem ao lado.
class MoonGlyph extends StatelessWidget {
  final MoonPhase phase;

  /// Corpo da lua. É o `fontSize` do glifo, com `height: 1` para a caixa de
  /// texto medir exatamente isso — o halo transborda por fora, como halo
  /// deve fazer.
  final double size;

  /// O brilho atrás. Desligue quando quem chama já tem o seu.
  final bool halo;

  const MoonGlyph({
    super.key,
    required this.phase,
    this.size = 62,
    this.halo = true,
  });

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final glifo = Text(
      phase.emoji,
      style: TextStyle(
        fontSize: size,
        height: 1,
        shadows: [
          Shadow(color: gc.lilac.withValues(alpha: .5), blurRadius: size * .3),
        ],
      ),
    );

    if (!halo) return ExcludeSemantics(child: glifo);

    return ExcludeSemantics(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Desenhado, não herdado da fonte: é esta camada que faltava no
          // navegador e fazia a mesma lua parecer apagada lá.
          Container(
            width: size * 1.45,
            height: size * 1.45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  gc.lilac.withValues(alpha: .45),
                  gc.lilac.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          glifo,
        ],
      ),
    );
  }
}
