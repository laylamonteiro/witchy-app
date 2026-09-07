import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../services/debug_log_service.dart';
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
/// Teto de espera da redução na web. Existe aqui, e não em cada tela, porque
/// uma foto HEIC/HEIF passa pelo decodificador que o app carrega sob demanda
/// (1,5 MB + compilação do wasm + decodificação): sem um teto único, a
/// quiromancia e o diagnóstico, que não tinham nenhum, ficariam esperando
/// para sempre. É maior que o limite interno da ponte, de propósito — quem
/// deve responder "não deu" é ela, não este relógio.
const Duration limiteDaReducaoWeb = Duration(seconds: 60);

Future<Uint8List?> compressPickedImage(
  XFile picked, {
  int minWidth = 1024,
  int minHeight = 1024,
  int quality = 82,
  int ladoMaximoWeb = ladoMaximoDaFoto,
  double qualidadeWeb = qualidadeDaFoto,
}) async {
  if (kIsWeb) {
    // Cada passo vai para o log de diagnóstico (chip FOTO): quando uma foto
    // "não abre", é ali que se lê em que passo e em quanto tempo morreu.
    void relatar(String o) => unawaited(debugLog('FOTO', o));
    try {
      final bytes = await picked.readAsBytes();
      relatar('lida: ${bytes.length} bytes, ${picked.mimeType ?? '?'}');
      final saida = await reduzirImagemNoNavegador(
        bytes,
        ladoMaximo: ladoMaximoWeb,
        qualidade: qualidadeWeb,
        relatar: relatar,
      ).timeout(limiteDaReducaoWeb);
      relatar(saida == null ? 'sem redução' : 'reduzida: ${saida.length} bytes');
      return saida;
    } catch (e) {
      relatar('redução falhou: $e');
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
