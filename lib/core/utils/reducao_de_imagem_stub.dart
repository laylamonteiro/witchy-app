import 'dart:typed_data';

/// Fora do navegador não há canvas — quem reduz no celular é o
/// `flutter_image_compress`, na outra perna de `compressPickedImage`.
Future<Uint8List?> reduzirImagemNoNavegador(
  Uint8List bytes, {
  required int ladoMaximo,
  required double qualidade,
}) async =>
    null;
