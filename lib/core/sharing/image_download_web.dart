import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Entrega [bytes] como download do navegador.
///
/// Na web não há galeria do sistema nem pasta do app: o equivalente é o
/// arquivo cair na pasta de downloads. Cria um blob temporário, dispara um
/// clique num link com o atributo `download` e libera o blob em seguida.
Future<void> downloadBytes(
  Uint8List bytes,
  String fileName, {
  String mimeType = 'application/octet-stream',
}) async {
  final blob = web.Blob(
    <JSAny>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: mimeType),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName;
  anchor.click();
  web.URL.revokeObjectURL(url);
}
