import 'dart:math';

/// A parte PURA da redução de fotos: aritmética de tamanho e o nome do
/// formato. Sem Flutter e sem navegador, para ser provada em teste de
/// unidade; a perna que decodifica de verdade fica em
/// `reducao_de_imagem_web.dart` (canvas) e no `flutter_image_compress`
/// (nativo), atrás de `image_compression.dart`.

/// Lado maior das fotos guardadas pelo app (px). Uma foto de verbete com
/// 1600 px de lado maior, em JPEG a 80 %, fica em 200–600 KB — o suficiente
/// para a IA e para a página, e leve para o Storage e para o espelho local.
const int ladoMaximoDaFoto = 1600;

/// Qualidade JPEG da redução (0..1).
const double qualidadeDaFoto = 0.8;

/// Tamanho de saída para uma foto [largura]×[altura] com o lado maior preso
/// a [ladoMaximo]. Nunca amplia; preserva a proporção; nunca devolve zero.
({int largura, int altura}) dimensoesReduzidas(
  int largura,
  int altura, {
  int ladoMaximo = ladoMaximoDaFoto,
}) {
  final maior = max(largura, altura);
  if (maior <= ladoMaximo || maior <= 0) {
    return (largura: max(1, largura), altura: max(1, altura));
  }
  final escala = ladoMaximo / maior;
  return (
    largura: max(1, (largura * escala).round()),
    altura: max(1, (altura * escala).round()),
  );
}

/// Nome curto do formato da foto, para a mensagem de erro ("HEIC", "PNG").
/// Prefere o mime; sem ele, a extensão do nome; sem nada, "?".
String formatoDaFoto({String? mime, String? nome}) {
  const porMime = {
    'image/jpeg': 'JPG',
    'image/jpg': 'JPG',
    'image/png': 'PNG',
    'image/webp': 'WEBP',
    'image/gif': 'GIF',
    'image/heic': 'HEIC',
    'image/heif': 'HEIF',
    'image/avif': 'AVIF',
    'image/bmp': 'BMP',
    'image/tiff': 'TIFF',
  };
  final tipo = mime?.trim().toLowerCase();
  if (tipo != null && tipo.isNotEmpty) {
    final conhecido = porMime[tipo];
    if (conhecido != null) return conhecido;
    if (tipo.startsWith('image/')) {
      return tipo.substring('image/'.length).toUpperCase();
    }
  }
  final arquivo = nome?.trim() ?? '';
  final ponto = arquivo.lastIndexOf('.');
  if (ponto > 0 && ponto < arquivo.length - 1) {
    final extensao = arquivo.substring(ponto + 1).toUpperCase();
    return extensao == 'JPEG' ? 'JPG' : extensao;
  }
  return '?';
}

/// Os bytes parecem um arquivo da família HEIF (HEIC, HEIF, AVIF)?
///
/// A conta é a do contêiner ISOBMFF: os bytes 4..7 são `ftyp` e os 8..11
/// trazem a marca. Serve para NÃO baixar 1,5 MB de decodificador por causa
/// de um JPEG truncado ou de um TIFF, que também fazem o navegador recusar
/// a imagem. `avif`/`avis` entram de propósito: o libheif também os abre, e
/// navegadores antigos não.
bool pareceHeif(List<int> bytes) {
  if (bytes.length < 12) return false;
  // 'ftyp'
  if (bytes[4] != 0x66 ||
      bytes[5] != 0x74 ||
      bytes[6] != 0x79 ||
      bytes[7] != 0x70) {
    return false;
  }
  const marcas = {
    'heic', 'heix', 'heim', 'heis', //
    'hevc', 'hevx', 'hevm', 'hevs',
    'mif1', 'msf1', 'avif', 'avis',
  };
  final marca = String.fromCharCodes(bytes.sublist(8, 12)).toLowerCase();
  return marcas.contains(marca);
}

/// O navegador não decodifica esta foto (HEIC/HEIF, por exemplo): não dá
/// para reduzir, e a tela também não conseguiria mostrá-la. Quem chama
/// explica o formato em vez de seguir com bytes crus.
class FotoNaoSuportadaException implements Exception {
  const FotoNaoSuportadaException(this.formato);

  /// Nome curto do formato, como em [formatoDaFoto].
  final String formato;

  @override
  String toString() => 'FotoNaoSuportadaException($formato)';
}
