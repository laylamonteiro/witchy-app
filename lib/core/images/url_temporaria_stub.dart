import 'dart:typed_data';

/// Fora da web não existe URL de blob: o recorte recebe o caminho do arquivo.
String criarUrlTemporaria(Uint8List jpeg) =>
    throw UnsupportedError('URL temporária só existe na web');

void liberarUrlTemporaria(String url) {}
