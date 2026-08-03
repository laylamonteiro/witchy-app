import 'package:flutter/material.dart';
import '../../../../core/theme/grimoire_colors.dart';

/// Renderiza a interpretação de sonho destacando os cabeçalhos do formato
/// "elemento a elemento + síntese": as linhas ◈ (cada elemento) saem em
/// lilás e a linha ✦ (o sonho como um todo) ganha destaque em dourado.
/// As duas camadas de cada elemento também ganham cor: o rótulo
/// "Símbolo:" em menta e "No seu sonho:" em rosa (nos 3 idiomas).
/// Linhas sem marcador são texto corrido normal, então interpretações
/// antigas continuam legíveis.
class DreamInterpretationText extends StatelessWidget {
  final String text;

  const DreamInterpretationText(this.text, {super.key});

  /// Rótulos da camada "significado geral do símbolo" (pt/en/es).
  static const List<String> _symbolLabels = [
    'Símbolo:',
    'Simbolo:',
    'Symbol:',
  ];

  /// Rótulos da camada "leitura aplicada ao sonho" (pt/en/es).
  static const List<String> _dreamLabels = [
    'No seu sonho:',
    'In your dream:',
    'En tu sueño:',
    'En tu sueno:',
  ];

  String? _matchLabel(String line, List<String> labels) {
    for (final label in labels) {
      if (line.startsWith(label)) return label;
    }
    return null;
  }

  /// Linha "Rótulo: conteúdo" com o rótulo colorido e o resto em texto
  /// normal, com um leve recuo para aninhar sob o nome do elemento.
  Widget _labeledLine(
    BuildContext context,
    String line,
    String label,
    Color labelColor,
    TextStyle? body,
  ) {
    final rest = line.substring(label.length).trimLeft();
    return Padding(
      padding: const EdgeInsets.only(left: 14, bottom: 2),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(
                color: labelColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(text: rest),
          ],
        ),
        style: body?.copyWith(height: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = Theme.of(context).textTheme.bodyMedium;
    final widgets = <Widget>[];

    for (final rawLine in text.split('\n')) {
      final line = rawLine.trim();
      final symbolLabel = _matchLabel(line, _symbolLabels);
      final dreamLabel = _matchLabel(line, _dreamLabels);
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
      } else if (symbolLabel != null) {
        widgets.add(
            _labeledLine(context, line, symbolLabel, context.gc.mint, body));
      } else if (dreamLabel != null) {
        widgets.add(
            _labeledLine(context, line, dreamLabel, context.gc.pink, body));
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
