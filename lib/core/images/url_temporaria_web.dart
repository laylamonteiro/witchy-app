import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Um endereço `blob:` para bytes em memória: é o que a tela de recorte da
/// web (Cropper.js, via image_cropper) aceita como origem. Quem cria libera
/// com [liberarUrlTemporaria] — cada URL viva segura os bytes na memória.
String criarUrlTemporaria(Uint8List jpeg) {
  final blob = web.Blob(
    <JSAny>[jpeg.toJS].toJS,
    web.BlobPropertyBag(type: 'image/jpeg'),
  );
  return web.URL.createObjectURL(blob);
}

void liberarUrlTemporaria(String url) {
  if (url.startsWith('blob:')) web.URL.revokeObjectURL(url);
}
