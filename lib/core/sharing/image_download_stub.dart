import 'dart:typed_data';

/// Fora da web não existe "baixar arquivo": as plataformas nativas salvam na
/// galeria ou compartilham um arquivo real. Este stub existe apenas para o
/// import condicional compilar no celular.
Future<void> downloadBytes(
  Uint8List bytes,
  String fileName, {
  String mimeType = 'application/octet-stream',
}) async {
  throw UnsupportedError('Baixar arquivo só existe na web');
}
