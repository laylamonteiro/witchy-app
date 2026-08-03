import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';

/// Card-cabeçalho das abas do Grimório Digital ("Astrologia Mística" e
/// "Ferramentas Mágicas"): um único layout com as mesmas cores e ALTURA
/// idêntica entre as abas — o glifo vive numa caixa de corpo fixo e o
/// subtítulo reserva sempre o espaço de duas linhas, então o card não muda
/// de tamanho ao trocar de aba.
class GrimoireHeaderCard extends StatelessWidget {
  final String glyph;
  final String title;
  final String subtitle;

  const GrimoireHeaderCard({
    super.key,
    required this.glyph,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: context.gc.textSecondary,
          height: 1.4,
        );
    // Altura exata de duas linhas do subtítulo, respeitando a escala de
    // fonte do sistema — é o que garante a mesma altura com textos de
    // comprimentos diferentes.
    final subtitleFontSize = subtitleStyle?.fontSize ?? 14;
    final twoLines =
        MediaQuery.textScalerOf(context).scale(subtitleFontSize) * 1.4 * 2;

    return MagicalCard(
      child: Column(
        children: [
          SizedBox(
            height: 56,
            child: Center(
              child: Text(glyph, style: const TextStyle(fontSize: 45)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: context.gc.lilac,
                ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: twoLines,
            child: Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: subtitleStyle,
            ),
          ),
        ],
      ),
    );
  }
}
