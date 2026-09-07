import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/theme/app_theme.dart';
import 'package:grimorio_de_bolso/core/widgets/photo_source_buttons.dart';

// O pedido: "ajusta o tamanho, largura, centralização dos botões". O rótulo
// da galeria quebrava em duas linhas (três em inglês), o ícone era empurrado
// para a borda e os dois botões ficavam com pesos visuais diferentes.
//
// O teste monta COM O TEMA DO APP de propósito: a quebra depende do
// preenchimento e da fonte do tema, então um MaterialApp pelado mediria
// outro botão que não o da tela.
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

  double alturaDoRotulo(WidgetTester tester, String rotulo) =>
      tester.getSize(find.text(rotulo)).height;

  /// Altura do mesmo rótulo com largura de sobra — a referência de UMA linha.
  Future<double> alturaDeUmaLinha(
    WidgetTester tester,
    String rotulo, {
    required bool naGaleria,
  }) async {
    await montar(
      tester,
      largura: 1200,
      camera: naGaleria ? 'x' : rotulo,
      galeria: naGaleria ? rotulo : 'x',
    );
    return alturaDoRotulo(tester, rotulo);
  }

  Future<void> cabeNumaLinha(
    WidgetTester tester,
    String rotulo, {
    required double aparelho,
    required bool naGaleria,
    String outro = 'Tirar foto',
  }) async {
    final umaLinha =
        await alturaDeUmaLinha(tester, rotulo, naGaleria: naGaleria);
    await montar(
      tester,
      largura: dentroDoCard(aparelho),
      camera: naGaleria ? outro : rotulo,
      galeria: naGaleria ? rotulo : outro,
    );
    expect(
      alturaDoRotulo(tester, rotulo),
      moreOrLessEquals(umaLinha, epsilon: 0.5),
      reason: '"$rotulo" quebrou em mais de uma linha a $aparelho dp',
    );
  }

  testWidgets('num aparelho de 360 dp os dois botões ficam do mesmo tamanho',
      (tester) async {
    await montar(tester, largura: dentroDoCard(360));

    expect(tamanhoDoBotao(tester, 'Tirar foto'),
        tamanhoDoBotao(tester, 'Da galeria'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a 360 dp cada rótulo cabe numa linha nos três idiomas',
      (tester) async {
    await cabeNumaLinha(tester, 'Tirar foto',
        aparelho: 360, naGaleria: false, outro: 'Da galeria');
    await cabeNumaLinha(tester, 'Da galeria', aparelho: 360, naGaleria: true);

    await cabeNumaLinha(tester, 'Take photo',
        aparelho: 360, naGaleria: false, outro: 'From gallery');
    await cabeNumaLinha(tester, 'From gallery',
        aparelho: 360, naGaleria: true, outro: 'Take photo');

    await cabeNumaLinha(tester, 'Tomar foto',
        aparelho: 360, naGaleria: false, outro: 'De la galería');
    await cabeNumaLinha(tester, 'De la galería',
        aparelho: 360, naGaleria: true, outro: 'Tomar foto');
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
