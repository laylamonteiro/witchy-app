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

  /// Cabeçalho ◈/✦. Quando o conteúdo vem NA MESMA linha (padrão da
  /// quiromancia: "◈ Formato da mão: texto..."), só o cabeçalho ganha cor
  /// e o resto segue como texto normal — antes o parágrafo inteiro saía
  /// colorido, ilegível. Linha curta sem conteúdo (padrão dos sonhos)
  /// fica toda colorida, como título.
  Widget _headerLine(
    BuildContext context,
    String line,
    Color color,
    double fontSize,
    TextStyle? body,
  ) {
    final headerStyle = TextStyle(
      color: color,
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
    );
    final colon = line.indexOf(':');
    if (colon != -1 && colon < 60 && colon < line.length - 1) {
      return Text.rich(
        TextSpan(children: [
          TextSpan(text: line.substring(0, colon + 1), style: headerStyle),
          TextSpan(
            text: ' ${line.substring(colon + 1).trimLeft()}',
            style: body?.copyWith(height: 1.5),
          ),
        ]),
      );
    }
    if (line.length > 60) {
      // Parágrafo longo iniciado pelo marcador, sem dois-pontos: colore
      // só o marcador para não pintar o bloco inteiro.
      return Text.rich(
        TextSpan(children: [
          TextSpan(text: line.substring(0, 1), style: headerStyle),
          TextSpan(
            text: ' ${line.substring(1).trimLeft()}',
            style: body?.copyWith(height: 1.5),
          ),
        ]),
      );
    }
    return Text(line, style: headerStyle);
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
          child: _headerLine(context, line, context.gc.starYellow, 16, body),
        ));
      } else if (line.startsWith('◈')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 2),
          child: _headerLine(context, line, context.gc.lilac, 15, body),
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
