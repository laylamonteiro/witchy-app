import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
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
      // Fotos pessoais são guardadas como caminho de arquivo local (tiradas no
      // mobile). Na web não há acesso ao filesystem e Image.file estoura no
      // build — dados sincronizados do mobile podem trazer esses caminhos.
      // Mostra o placeholder em vez de derrubar a tela inteira.
      if (kIsWeb) {
        return _buildFallback(context);
      }
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

  Widget _buildFallback(BuildContext context) {
    if (errorBuilder != null) {
      return errorBuilder!(
        context,
        UnsupportedError('Imagem de arquivo local indisponível na web'),
        StackTrace.current,
      );
    }
    return SizedBox(
      width: width,
      height: height,
      child: const Icon(Icons.image_not_supported_outlined),
    );
  }
}
