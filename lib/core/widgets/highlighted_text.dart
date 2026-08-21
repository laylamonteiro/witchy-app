import 'package:flutter/material.dart';

import '../theme/grimoire_colors.dart';

/// Texto de leitura com trechos realçados.
///
/// Parágrafo longo e uniforme é difícil de varrer no celular: a pessoa lê a
/// primeira linha e desiste. Realçar duas ou três expressões por parágrafo dá
/// pontos de apoio para o olho e faz a leitura parecer escrita para ela.
///
/// A marcação é `**assim**`, a mesma do Markdown — só que interpretada aqui,
/// sem carregar um renderizador inteiro para dois negritos por parágrafo. O
/// realce é de COR, não de peso: o texto continua com o mesmo ritmo.
class HighlightedText extends StatelessWidget {
  const HighlightedText(
    this.text, {
    super.key,
    this.style,
    this.highlight,
    this.textAlign,
  });

  final String text;

  /// Estilo do corpo. O realce herda dele e só troca a cor.
  final TextStyle? style;

  /// Cor do realce (padrão: o lilás da marca).
  final Color? highlight;

  final TextAlign? textAlign;

  /// Divide em pedaços alternando fora/dentro de `**`.
  ///
  /// Um `**` sem fechamento não estraga nada: o resto do texto sai como
  /// corpo normal, que é o pior caso aceitável para conteúdo editorial.
  static List<({String texto, bool realce})> partes(String bruto) {
    final saida = <({String texto, bool realce})>[];
    var resto = bruto;

    while (true) {
      final abre = resto.indexOf('**');
      if (abre == -1) break;
      final fecha = resto.indexOf('**', abre + 2);
      if (fecha == -1) break;

      if (abre > 0) {
        saida.add((texto: resto.substring(0, abre), realce: false));
      }
      final dentro = resto.substring(abre + 2, fecha);
      if (dentro.isNotEmpty) saida.add((texto: dentro, realce: true));
      resto = resto.substring(fecha + 2);
    }

    if (resto.isNotEmpty) saida.add((texto: resto, realce: false));
    return saida;
  }

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.bodyMedium;
    final corDoRealce = highlight ?? context.gc.lilac;
    final pedacos = partes(text);

    // Sem marcação, um Text simples basta.
    if (pedacos.length == 1 && !pedacos.first.realce) {
      return Text(text, style: base, textAlign: textAlign);
    }

    return Text.rich(
      TextSpan(
        children: [
          for (final pedaco in pedacos)
            TextSpan(
              text: pedaco.texto,
              style: pedaco.realce ? base?.copyWith(color: corDoRealce) : null,
            ),
        ],
      ),
      style: base,
      textAlign: textAlign,
    );
  }
}
