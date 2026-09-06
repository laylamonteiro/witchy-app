import 'dart:typed_data';

import 'package:grimorio_de_bolso/core/services/armazem_de_imagens.dart';

/// Storage de mentira: um mapa em memória no lugar do bucket, com o
/// interruptor de "rede fora do ar". É só a borda de rede — quem decide o
/// que sobe, espelha ou fica local continua sendo o código de verdade.
class ArmazemDeMentira implements ArmazemDeImagens {
  final Map<String, Uint8List> objetos = {};

  /// Fora do ar: toda chamada falha, como um aparelho sem rede.
  bool foraDoAr = false;

  @override
  String? usuarioAtual;

  int envios = 0;
  int downloads = 0;

  void _exigirRede() {
    if (foraDoAr) throw Exception('rede fora do ar');
  }

  @override
  Future<void> enviar(String path, Uint8List bytes, {bool upsert = false}) async {
    _exigirRede();
    if (!upsert && objetos.containsKey(path)) {
      throw Exception('409: The resource already exists');
    }
    objetos[path] = Uint8List.fromList(bytes);
    envios++;
  }

  @override
  Future<Uint8List> baixar(String path) async {
    _exigirRede();
    final bytes = objetos[path];
    if (bytes == null) throw Exception('404: Object not found');
    downloads++;
    return bytes;
  }

  @override
  Future<String> urlAssinada(String path, int validadeSegundos) async {
    _exigirRede();
    return 'https://assinada.exemplo/$path?ttl=$validadeSegundos';
  }

  @override
  Future<void> remover(List<String> paths) async {
    _exigirRede();
    paths.forEach(objetos.remove);
  }
}
