import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../data/data_sources/blood_lore_content.dart';

/// A etiqueta editorial de um verbete, do tamanho de uma legenda.
///
/// Ela é o que separa história de invenção nesta área, e por isso aparece
/// SEMPRE ao lado do título — na lista e na leitura. Discreta de propósito:
/// informa a origem sem disputar com o texto.
class BloodLoreTagChip extends StatelessWidget {
  const BloodLoreTagChip({super.key, required this.tag});

  final BloodLoreTag tag;

  @override
  Widget build(BuildContext context) {
    final colors = context.gc;
    return Container(
      key: ValueKey('blood-lore-tag-${tag.name}'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.lilac.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.lilac.withValues(alpha: 0.3)),
      ),
      child: Text(
        '${tag.emoji} ${bloodLoreContent.tagLabels[tag]!}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.lilac,
              fontSize: 11,
              height: 1.2,
            ),
      ),
    );
  }
}
