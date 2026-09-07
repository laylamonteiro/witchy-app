import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'reducao_de_imagem.dart';

/// A perna web da redução de fotos: decodifica com o próprio navegador
/// (`createImageBitmap`, que já respeita a orientação EXIF), desenha num
/// canvas com o lado maior preso a [ladoMaximo] e exporta JPEG.
///
/// Por que não deixar isso com os plugins: o redimensionador do
/// `image_picker` na web engole o erro e devolve o arquivo ORIGINAL quando o
/// navegador não decodifica (e reexporta PNG como PNG, que continua enorme),
/// e a compressão do `flutter_image_compress` depende da versão resolvida.
/// Aqui o resultado é sempre JPEG pequeno — ou `null`, que significa "o
/// navegador não abre esta imagem" (HEIC/HEIF, por exemplo).
Future<Uint8List?> reduzirImagemNoNavegador(
  Uint8List bytes, {
  required int ladoMaximo,
  required double qualidade,
}) async {
  final blob = web.Blob(<JSAny>[bytes.toJS].toJS);
  final web.ImageBitmap bitmap;
  try {
    bitmap = await web.window.createImageBitmap(blob).toDart;
  } catch (_) {
    return null;
  }
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
    final dataUrl = canvas.toDataUrl('image/jpeg', qualidade.toJS);
    final virgula = dataUrl.indexOf(',');
    if (!dataUrl.startsWith('data:image/jpeg') || virgula < 0) return null;
    return base64Decode(dataUrl.substring(virgula + 1));
  } catch (_) {
    return null;
  } finally {
    bitmap.close();
  }
}
