import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_motion.dart';

/// O número que o cálculo deu, chegando por contagem.
///
/// A animação não decide nada: ela percorre o caminho até [value], que é o
/// valor calculado, e para nele. Com movimento reduzido — ou quando o
/// número muda — o que aparece é sempre o mesmo resultado. Números mestres
/// (11, 22, 33) chegam inteiros, porque quem os preserva é o cálculo.
class NumberReveal extends StatelessWidget {
  const NumberReveal({
    super.key,
    required this.value,
    this.style,
    this.duration = GrimoireMotion.reveal,
    this.semanticsLabel,
  });

  /// O número calculado. É sempre ele que fica na tela no fim.
  final int value;

  final TextStyle? style;
  final Duration duration;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final reduced = GrimoireMotion.reduced(context);
    return TweenAnimationBuilder<int>(
      // Trocar de número recomeça a contagem a partir do anterior.
      tween: IntTween(begin: reduced ? value : 0, end: value),
      duration: reduced ? Duration.zero : duration,
      curve: GrimoireMotion.enter,
      builder: (context, shown, _) => Text(
        '$shown',
        style: style,
        semanticsLabel: semanticsLabel ?? '$value',
        textAlign: TextAlign.center,
      ),
    );
  }
}
