import 'package:flutter/material.dart';
import '../../features/grimoire/data/models/spell_model.dart';
import '../theme/grimoire_colors.dart';
import '../theme/grimoire_motion.dart';
import 'moon_glyph.dart';

/// A fase da lua com nome (e, se pedido, o significado) embaixo.
///
/// A lua vem do [MoonGlyph]: o glifo da fase com o brilho do app desenhado
/// atrás. O brilho é o que faltava no navegador e fazia a mesma lua parecer
/// apagada lá.
class MoonPhaseWidget extends StatelessWidget {
  final MoonPhase phase;
  final bool showName;
  final bool showDescription;
  final double size;

  const MoonPhaseWidget({
    super.key,
    required this.phase,
    this.showName = true,
    this.showDescription = false,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    // Entrada única (não é laço), mas mesmo assim vai direto ao estado final
    // para quem pediu movimento reduzido: a regra vale para todo efeito.
    final reduzido = GrimoireMotion.reduced(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: reduzido ? 1.0 : 0.9, end: 1.0),
          duration: reduzido ? Duration.zero : GrimoireMotion.reveal,
          curve: GrimoireMotion.enter,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: MoonGlyph(phase: phase, size: size),
        ),
        if (showName) ...[
          const SizedBox(height: 8),
          Text(
            phase.displayName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.gc.lilac,
                ),
            textAlign: TextAlign.center,
          ),
        ],
        if (showDescription) ...[
          const SizedBox(height: 4),
          Text(
            phase.description,
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
}
