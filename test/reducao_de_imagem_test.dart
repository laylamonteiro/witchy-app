import 'dart:typed_data';

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

  group('pareceHeif', () {
    // Um HEIF de mentira: só o cabeçalho ISOBMFF importa aqui.
    Uint8List comMarca(String marca, {String caixa = 'ftyp'}) =>
        Uint8List.fromList([
          0, 0, 0, 24, // tamanho da caixa
          ...caixa.codeUnits,
          ...marca.codeUnits,
          ...List<int>.filled(12, 0),
        ]);

    Uint8List comeco(List<int> primeiros) =>
        Uint8List.fromList([...primeiros, ...List<int>.filled(20, 0)]);

    test('reconhece as marcas da família', () {
      for (final marca in ['heic', 'heix', 'mif1', 'avif', 'hevc']) {
        expect(pareceHeif(comMarca(marca)), isTrue, reason: marca);
      }
    });

    test('não confunde JPEG nem PNG', () {
      expect(pareceHeif(comeco([0xFF, 0xD8, 0xFF, 0xE0])), isFalse);
      expect(pareceHeif(comeco([0x89, 0x50, 0x4E, 0x47])), isFalse);
    });

    test('caixa que não é ftyp, ou marca desconhecida, não passa', () {
      expect(pareceHeif(comMarca('heic', caixa: 'moov')), isFalse);
      expect(pareceHeif(comMarca('qt  ')), isFalse);
    });

    test('arquivo curto demais não explode', () {
      expect(pareceHeif(Uint8List(0)), isFalse);
      expect(pareceHeif(Uint8List(11)), isFalse);
    });
  });

  test('FotoNaoSuportadaException carrega o formato', () {
    const e = FotoNaoSuportadaException('HEIC');
    expect(e.formato, 'HEIC');
    expect('$e', contains('HEIC'));
  });
}
