import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/utils/reducao_de_imagem.dart';

// O pedido: "o próprio app deve fazer o resize da imagem para ela não ficar
// muito grande". A aritmética da redução e o nome do formato (que vai na
// mensagem quando o navegador não abre a foto) são puros e ficam provados
// aqui; o canvas de verdade só existe no navegador.
void main() {
  group('dimensoesReduzidas', () {
    test('paisagem grande: o lado maior vira 1600 e a proporção fica', () {
      final r = dimensoesReduzidas(4000, 3000);
      expect(r.largura, 1600);
      expect(r.altura, 1200);
    });

    test('retrato grande: o lado maior é a altura', () {
      final r = dimensoesReduzidas(3000, 4000);
      expect(r.largura, 1200);
      expect(r.altura, 1600);
    });

    test('nunca amplia: foto pequena sai do mesmo tamanho', () {
      expect(dimensoesReduzidas(800, 600), (largura: 800, altura: 600));
      expect(dimensoesReduzidas(1600, 1600), (largura: 1600, altura: 1600));
    });

    test('lado máximo é parâmetro; uma tira fina nunca chega a zero', () {
      expect(
        dimensoesReduzidas(5000, 10, ladoMaximo: 1000),
        (largura: 1000, altura: 2),
      );
      expect(dimensoesReduzidas(100000, 1).altura, 1);
    });

    test('tamanho inválido não explode', () {
      expect(dimensoesReduzidas(0, 0), (largura: 1, altura: 1));
    });
  });

  group('formatoDaFoto', () {
    test('mime conhecido manda', () {
      expect(formatoDaFoto(mime: 'image/heic', nome: 'x.jpg'), 'HEIC');
      expect(formatoDaFoto(mime: 'image/jpeg'), 'JPG');
      expect(formatoDaFoto(mime: 'IMAGE/PNG'), 'PNG');
    });

    test('mime de imagem desconhecido vira o sufixo em maiúsculas', () {
      expect(formatoDaFoto(mime: 'image/x-portable-pixmap'),
          'X-PORTABLE-PIXMAP');
    });

    test('sem mime, a extensão do nome; JPEG vira JPG', () {
      expect(formatoDaFoto(nome: 'IMG_0001.HEIC'), 'HEIC');
      expect(formatoDaFoto(nome: 'foto.jpeg'), 'JPG');
      expect(formatoDaFoto(mime: '', nome: 'foto.webp'), 'WEBP');
    });

    test('sem nada que ajude, um ponto de interrogação', () {
      expect(formatoDaFoto(), '?');
      expect(formatoDaFoto(nome: 'semextensao'), '?');
      expect(formatoDaFoto(nome: 'termina.'), '?');
    });
  });

  test('FotoNaoSuportadaException carrega o formato', () {
    const e = FotoNaoSuportadaException('HEIC');
    expect(e.formato, 'HEIC');
    expect('$e', contains('HEIC'));
  });
}
