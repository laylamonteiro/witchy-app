import 'package:flutter/material.dart';

/// Estrela usada para representar a ferramenta de sigilos no app.
const String kSigilIconGlyph = ' ⛤';

/// Ícone reutilizável de sigilos.
class SigilIcon extends StatelessWidget {
  const SigilIcon({
    super.key,
    this.size = 32,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      kSigilIconGlyph,
      style: TextStyle(fontSize: size),
    );
  }
}
