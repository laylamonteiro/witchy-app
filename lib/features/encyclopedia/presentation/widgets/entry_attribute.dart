import 'package:flutter/material.dart';

/// Um par emoji + nome (elemento, planeta) como bloco indivisível.
///
/// `mainAxisSize.min` para o [Wrap] que o hospeda medir o par inteiro, e
/// `Flexible` no nome porque um par sozinho ainda pode ser mais largo que o
/// cartão quando a fonte do sistema está no máximo.
///
/// Nasceu copiado letra por letra em dois verbetes (erva e metal), quando o
/// Wrap substituiu a linha rígida que cortava a palavra. Cópia de layout é a
/// pior de todas: o conserto seguinte acha uma das duas e deixa a outra
/// cortando — e ninguém nota, porque a tela que corta é sempre a que a
/// pessoa abriu, nunca a que a gente estava olhando.
class EntryAttribute extends StatelessWidget {
  const EntryAttribute({super.key, required this.emoji, required this.label});

  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
      ],
    );
  }
}
