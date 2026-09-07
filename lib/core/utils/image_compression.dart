import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import 'reducao_de_imagem.dart';
import 'reducao_de_imagem_stub.dart'
    if (dart.library.js_interop) 'reducao_de_imagem_web.dart';

/// Reduz a imagem escolhida: corrige a rotação do EXIF, remove metadados e
/// limita o tamanho do envio. A ÚNICA porta de redução do app — verbete,
/// quiromancia e diagnóstico passam por aqui.
///
/// Na web o app reduz por conta própria (canvas do navegador, ver
/// `reducao_de_imagem_web.dart`): os plugins são cegos ao formato — o
/// redimensionador do image_picker devolve o arquivo original quando o
/// navegador não decodifica, e a compressão por bytes depende da versão do
/// plugin. No celular, o `flutter_image_compress` nativo (que decodifica
/// HEIC) continua.
///
/// Devolve null quando a redução falha; quem chama decide o que fazer
/// (no celular, seguir com os bytes originais; na web, null quer dizer que o
/// navegador não abre a imagem — nem a tela conseguiria mostrá-la).
Future<Uint8List?> compressPickedImage(
  XFile picked, {
  int minWidth = 1024,
  int minHeight = 1024,
  int quality = 82,
  int ladoMaximoWeb = ladoMaximoDaFoto,
  double qualidadeWeb = qualidadeDaFoto,
}) async {
  if (kIsWeb) {
    try {
      return await reduzirImagemNoNavegador(
        await picked.readAsBytes(),
        ladoMaximo: ladoMaximoWeb,
        qualidade: qualidadeWeb,
      );
    } catch (e) {
      debugPrint('compressPickedImage: falha na web: $e');
      return null;
    }
  }
  try {
    return await FlutterImageCompress.compressWithFile(
      picked.path,
      minWidth: minWidth,
      minHeight: minHeight,
      quality: quality,
      format: CompressFormat.jpeg,
    );
  } catch (e) {
    debugPrint('compressPickedImage: falha no aparelho: $e');
    return null;
  }
}
