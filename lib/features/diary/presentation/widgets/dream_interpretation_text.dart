import 'package:flutter/material.dart';
import '../../../../core/theme/grimoire_colors.dart';

/// Renderiza a interpretação de sonho destacando os cabeçalhos do formato
/// "elemento a elemento + síntese": as linhas ◈ (cada elemento) saem em
/// lilás e a linha ✦ (o sonho como um todo) ganha destaque em dourado.
/// Linhas sem marcador são texto corrido normal, então interpretações
/// antigas continuam legíveis.
class DreamInterpretationText extends StatelessWidget {
  final String text;

  const DreamInterpretationText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final body = Theme.of(context).textTheme.bodyMedium;
    final widgets = <Widget>[];

    for (final rawLine in text.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 10));
      } else if (line.startsWith('✦')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 4),
          child: Text(
            line,
            style: TextStyle(
              color: context.gc.starYellow,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ));
      } else if (line.startsWith('◈')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 2),
          child: Text(
            line,
            style: TextStyle(
              color: context.gc.lilac,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ));
      } else {
        widgets.add(Text(line, style: body?.copyWith(height: 1.5)));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
