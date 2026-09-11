import 'package:flutter/material.dart';
import '../../features/grimoire/data/models/spell_model.dart';
import '../theme/grimoire_colors.dart';
import '../theme/grimoire_motion.dart';
import 'moon_disc.dart';

/// A fase da lua com nome (e, se pedido, o significado) embaixo.
///
/// O disco é pintado pelo [MoonDisc]: era um emoji, e emoji é arte da fonte
/// de quem abre o app — mesma tela e mesmo dia saíam diferentes no aparelho
/// e no navegador.
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
          child: MoonDisc(phase: phase, size: size),
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
