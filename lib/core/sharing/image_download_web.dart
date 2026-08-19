import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Entrega o PNG como download do navegador.
///
/// Na web não há galeria do sistema: o equivalente é o arquivo cair na pasta
/// de downloads. Cria um blob temporário, dispara um clique num link com o
/// atributo `download` e libera o blob em seguida.
Future<void> downloadImageBytes(Uint8List bytes, String fileName) async {
  final blob = web.Blob(
    <JSAny>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'image/png'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName;
  anchor.click();
  web.URL.revokeObjectURL(url);
}
