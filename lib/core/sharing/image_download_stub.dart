import 'dart:typed_data';

/// Fora da web não existe "baixar arquivo": as plataformas nativas salvam na
/// galeria (ver [showShareCardSheet]). Este stub existe apenas para o import
/// condicional compilar no celular.
Future<void> downloadImageBytes(Uint8List bytes, String fileName) async {
  throw UnsupportedError('Baixar arquivo só existe na web');
}
