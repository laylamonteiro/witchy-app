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

  /// Ícone em cima, rótulo embaixo. Com ícone e texto na MESMA linha
  /// (`OutlinedButton.icon`), o preenchimento de 24 px do tema mais o ícone
  /// deixavam ~58 px para o rótulo num aparelho de 360 dp: "Escolher da
  /// galeria" quebrava em duas linhas e "Choose from gallery" em três, o
  /// ícone era empurrado para a borda e os dois botões ficavam com pesos
  /// diferentes. Empilhado, o rótulo recebe a largura inteira do ladrilho.
  Widget _ladrilho({
    required IconData icone,
    required String rotulo,
    required VoidCallback? aoTocar,
  }) {
    return Expanded(
      child: OutlinedButton(
        onPressed: aoTocar,
        // 12 em vez dos 24 do tema: aqui a largura é dividida em dois e cada
        // px de preenchimento sai do rótulo.
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone),
            const SizedBox(height: 8),
            // Duas linhas de teto: numa fonte ampliada, ou num idioma mais
            // comprido, o ladrilho cresce em vez de cortar o texto.
            Text(rotulo, textAlign: TextAlign.center, maxLines: 2),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mesma largura (Expanded), mesma altura (o IntrinsicHeight mede o mais
    // alto dos dois e o stretch estica o outro até lá) e um piso de 88 para
    // os dois ficarem quadrados mesmo com rótulos curtos.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 88),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ladrilho(
              icone: Icons.photo_camera_outlined,
              rotulo: cameraLabel,
              aoTocar: onCamera,
            ),
            const SizedBox(width: 12),
            _ladrilho(
              icone: Icons.photo_library_outlined,
              rotulo: galleryLabel,
              aoTocar: onGallery,
            ),
          ],
        ),
      ),
    );
  }
}
