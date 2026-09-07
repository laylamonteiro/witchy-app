import 'package:flutter/material.dart';

/// Os dois botões de origem da foto — câmera e galeria — lado a lado, com a
/// mesma cara em toda tela que aceita foto. Os rótulos vêm de quem usa (cada
/// fluxo tem as suas chaves de l10n); `null` num callback desabilita o botão.
class PhotoSourceButtons extends StatelessWidget {
  final VoidCallback? onCamera;
  final VoidCallback? onGallery;
  final String cameraLabel;
  final String galleryLabel;

  const PhotoSourceButtons({
    super.key,
    required this.onCamera,
    required this.onGallery,
    required this.cameraLabel,
    required this.galleryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCamera,
            icon: const Icon(Icons.photo_camera_outlined),
            label: Text(cameraLabel),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onGallery,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(galleryLabel),
          ),
        ),
      ],
    );
  }
}
