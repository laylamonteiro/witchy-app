import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

/// Comprime a imagem escolhida: corrige a rotação do EXIF, remove metadados
/// e limita o tamanho do envio.
///
/// Existe porque a API por CAMINHO de arquivo do flutter_image_compress não
/// funciona na web — lá não há filesystem, e o "path" de um XFile é um blob do
/// navegador. Só a variante por bytes serve. Concentrar a diferença aqui evita
/// espalhar `if (kIsWeb)` por cada tela que aceita foto.
///
/// Devolve null quando a compressão falha; quem chama decide o que fazer
/// (normalmente seguir com os bytes originais).
Future<Uint8List?> compressPickedImage(
  XFile picked, {
  int minWidth = 1024,
  int minHeight = 1024,
  int quality = 82,
}) async {
  if (kIsWeb) {
    try {
      return await FlutterImageCompress.compressWithList(
        await picked.readAsBytes(),
        minWidth: minWidth,
        minHeight: minHeight,
        quality: quality,
        format: CompressFormat.jpeg,
      );
    } catch (e) {
      // Na web `compressWithList` LANÇA (não devolve null) quando o
      // navegador não decodifica a imagem ou o plugin não está pronto.
      // Honra o contrato desta função: null, e quem chama segue com os
      // bytes originais.
      debugPrint('compressPickedImage: falha na web: $e');
      return null;
    }
  }
  return FlutterImageCompress.compressWithFile(
    picked.path,
    minWidth: minWidth,
    minHeight: minHeight,
    quality: quality,
    format: CompressFormat.jpeg,
  );
}
