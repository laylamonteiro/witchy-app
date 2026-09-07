import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'reducao_de_imagem.dart';

/// A ponte de HEIC, definida em `web/heic/decodificador_heic.js` e carregada
/// pelo `index.html`. Nula quando o script não está lá — o que acontece
/// servindo o app sem os arquivos de `web/`, e aí a foto HEIC volta a ser
/// "formato não suportado" em vez de virar erro.
@JS('grimorioHeic')
external JSObject? get _pontePraHeic;

extension type _PonteHeic(JSObject _) implements JSObject {
  external JSPromise<web.ImageBitmap?> paraBitmap(JSUint8Array bytes);
}

/// A perna web da redução de fotos: decodifica com o próprio navegador
/// (`createImageBitmap`, que já respeita a orientação EXIF), desenha num
/// canvas com o lado maior preso a [ladoMaximo] e exporta JPEG.
///
/// Por que não deixar isso com os plugins: o redimensionador do
/// `image_picker` na web engole o erro e devolve o arquivo ORIGINAL quando o
/// navegador não decodifica (e reexporta PNG como PNG, que continua enorme),
/// e a compressão do `flutter_image_compress` depende da versão resolvida.
/// Aqui o resultado é sempre JPEG pequeno — ou `null`.
///
/// O navegador vem PRIMEIRO e o libheif só entra quando ele recusa: foto
/// comum não paga nada pela existência do decodificador, e no dia em que o
/// Chrome abrir HEIC sozinho o caminho rápido simplesmente passa a valer.
Future<Uint8List?> reduzirImagemNoNavegador(
  Uint8List bytes, {
  required int ladoMaximo,
  required double qualidade,
}) async {
  final web.ImageBitmap? aberta =
      await _abrir(bytes) ?? await _decodificarHeic(bytes);
  if (aberta == null) return null;
  final bitmap = aberta;
  try {
    final alvo = dimensoesReduzidas(
      bitmap.width,
      bitmap.height,
      ladoMaximo: ladoMaximo,
    );
    final canvas = web.HTMLCanvasElement()
      ..width = alvo.largura
      ..height = alvo.altura;
    canvas.context2D.drawImage(
      bitmap,
      0,
      0,
      alvo.largura.toDouble(),
      alvo.altura.toDouble(),
    );
    // data URL em vez de toBlob: síncrono, sem callback, e o base64 de um
    // JPEG de algumas centenas de KB é barato.
    final dataUrl = canvas.toDataUrl('image/jpeg', qualidade);
    final virgula = dataUrl.indexOf(',');
    if (!dataUrl.startsWith('data:image/jpeg') || virgula < 0) return null;
    return base64Decode(dataUrl.substring(virgula + 1));
  } catch (_) {
    return null;
  } finally {
    bitmap.close();
  }
}

Future<web.ImageBitmap?> _abrir(Uint8List bytes) async {
  try {
    final blob = web.Blob(<JSAny>[bytes.toJS].toJS);
    return await web.window.createImageBitmap(blob).toDart;
  } catch (_) {
    return null;
  }
}

/// Chama a ponte só quando os bytes REALMENTE parecem HEIF: um JPEG truncado
/// ou um TIFF também fazem `createImageBitmap` falhar, e não vale baixar
/// 1,5 MB de decodificador para descobrir que não era isso.
Future<web.ImageBitmap?> _decodificarHeic(Uint8List bytes) async {
  if (!pareceHeif(bytes)) return null;
  final ponte = _pontePraHeic;
  if (ponte == null) return null;
  try {
    return await _PonteHeic(ponte).paraBitmap(bytes.toJS).toDart;
  } catch (_) {
    return null;
  }
}
