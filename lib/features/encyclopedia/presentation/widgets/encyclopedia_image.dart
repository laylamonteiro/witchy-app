import 'package:flutter/material.dart';

import '../../../../core/widgets/stored_image.dart';

/// Imagem de verbete da enciclopédia: assets do app OU foto tirada pela
/// usuária (Supabase Storage, ou caminho local nas entradas antigas).
///
/// A resolução de cada origem fica em [StoredImage]; aqui ficam só o formato
/// esperado pelas telas da enciclopédia.
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
    return StoredImage(
      reference: path,
      width: width,
      height: height,
      fit: fit,
      placeholderBuilder: errorBuilder == null
          ? null
          : (context) => errorBuilder!(
                context,
                Exception('Imagem indisponível: $path'),
                StackTrace.current,
              ),
    );
  }
}
