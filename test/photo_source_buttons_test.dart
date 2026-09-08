import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/theme/app_theme.dart';
import 'package:grimorio_de_bolso/core/widgets/photo_source_buttons.dart';

// O pedido: "ajusta o tamanho, largura, centralização dos botões". O rótulo
// da galeria quebrava em duas linhas (três em inglês), o ícone era empurrado
// para a borda e os dois botões ficavam com pesos visuais diferentes.
//
// O teste monta com o tema do app (é dele que vêm o preenchimento e a
// borda dos botões), mas NÃO afirma quantas linhas cada rótulo ocupa:
// `flutter test` desenha com a fonte de teste, de largura fixa, e não com a
// Nunito do aparelho — uma conta de caracteres aqui provaria a fonte errada.
// O que dá para garantir, e é o que a usuária pediu, é que os dois ladrilhos
// tenham sempre o mesmo tamanho e que nada estoure.
void main() {
  // Largura útil dentro do MagicalCard: a tela desconta a margem (16 de cada
  // lado) e o preenchimento (16 de cada lado).
  double dentroDoCard(double aparelho) => aparelho - 64;

  Future<void> montar(
    WidgetTester tester, {
    required double largura,
    String camera = 'Tirar foto',
    String galeria = 'Da galeria',
    double escalaDoTexto = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(escalaDoTexto),
                ),
                child: SizedBox(
                  width: largura,
                  child: PhotoSourceButtons(
                    onCamera: () {},
                    onGallery: () {},
                    cameraLabel: camera,
                    galleryLabel: galeria,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Size tamanhoDoBotao(WidgetTester tester, String rotulo) => tester.getSize(
        find.ancestor(
          of: find.text(rotulo),
          matching: find.byType(OutlinedButton),
        ),
      );

  testWidgets('num aparelho de 360 dp os dois botões ficam do mesmo tamanho',
      (tester) async {
    await montar(tester, largura: dentroDoCard(360));

    expect(tamanhoDoBotao(tester, 'Tirar foto'),
        tamanhoDoBotao(tester, 'Da galeria'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('rótulo comprido em qualquer um dos dois: continuam iguais',
      (tester) async {
    // Se um rótulo quebrar em duas linhas — outro idioma, fonte ampliada, um
    // aparelho mais estreito —, os dois ladrilhos crescem JUNTOS. Quantos
    // caracteres cabem por linha não dá para afirmar aqui: `flutter test`
    // desenha com a fonte de teste, não com a Nunito do aparelho.
    for (final par in [
      ('Tirar foto', 'Da galeria'),
      ('Take photo', 'From gallery'),
      ('Tomar foto', 'De la galería'),
      ('Tirar foto', 'Escolher uma foto da galeria do aparelho'),
    ]) {
      await montar(
        tester,
        largura: dentroDoCard(360),
        camera: par.$1,
        galeria: par.$2,
      );
      expect(tamanhoDoBotao(tester, par.$1), tamanhoDoBotao(tester, par.$2),
          reason: '${par.$1} × ${par.$2}');
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('o rótulo fica centralizado, e não colado no ícone',
      (tester) async {
    await montar(tester, largura: dentroDoCard(360));

    final rotulo = tester.widget<Text>(find.text('Da galeria'));
    expect(rotulo.textAlign, TextAlign.center);
    expect(rotulo.maxLines, 2, reason: 'teto de duas linhas, sem cortar');

    // O ícone fica ACIMA do rótulo: é o que devolve a largura inteira do
    // ladrilho para o texto.
    final icone = tester.getCenter(find.byIcon(Icons.photo_library_outlined));
    expect(icone.dy, lessThan(tester.getCenter(find.text('Da galeria')).dy));
  });

  testWidgets('numa tela estreita continuam do mesmo tamanho, sem estourar',
      (tester) async {
    await montar(
      tester,
      largura: dentroDoCard(320),
      camera: 'Tomar foto',
      galeria: 'De la galería',
    );

    expect(tamanhoDoBotao(tester, 'Tomar foto'),
        tamanhoDoBotao(tester, 'De la galería'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('com a fonte ampliada os dois crescem juntos', (tester) async {
    await montar(tester, largura: dentroDoCard(360), escalaDoTexto: 1.5);

    final camera = tamanhoDoBotao(tester, 'Tirar foto');
    expect(camera, tamanhoDoBotao(tester, 'Da galeria'));
    // O 88 é piso, não teto: com fonte grande o ladrilho cresce em vez de
    // cortar o texto.
    expect(camera.height, greaterThanOrEqualTo(88));
    expect(tester.takeException(), isNull);
  });
}
