import 'dart:io';

import 'package:flutter/material.dart';

/// Imagem de verbete da enciclopédia: assets do app OU foto tirada pela
/// usuária (entradas pessoais guardam caminho absoluto de arquivo).
class EncyclopediaImage extends StatelessWidget {
  final String path;
  final double width;
  final double height;
  final BoxFit fit;
  final ImageErrorWidgetBuilder? errorBuilder;

  const EncyclopediaImage({
    super.key,
    required this.path,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final isFile = path.startsWith('/') || path.startsWith('file:');
    if (isFile) {
      return Image.file(
        File(path.replaceFirst('file://', '')),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder,
      );
    }
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }
}
