import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/widgets/photo_source_buttons.dart';

// O pedido: "os botões devem ter a mesma altura e largura". Numa tela
// estreita "Escolher da galeria" quebra em duas linhas e o botão ficava mais
// alto que "Tirar foto" — a largura já era a mesma (metade para cada um).
void main() {
  Future<void> montar(WidgetTester tester, {required double largura}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: largura,
              child: PhotoSourceButtons(
                onCamera: () {},
                onGallery: () {},
                cameraLabel: 'Tirar foto',
                galleryLabel: 'Escolher da galeria',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Size tamanhoDo(WidgetTester tester, String rotulo) => tester.getSize(
        find.ancestor(
          of: find.text(rotulo),
          matching: find.byType(OutlinedButton),
        ),
      );

  testWidgets('numa tela estreita, o rótulo longo quebra e os dois botões '
      'ficam com a mesma altura e largura', (tester) async {
    await montar(tester, largura: 320);

    final camera = tamanhoDo(tester, 'Tirar foto');
    final galeria = tamanhoDo(tester, 'Escolher da galeria');

    expect(camera.width, moreOrLessEquals(galeria.width, epsilon: 0.5));
    expect(camera.height, moreOrLessEquals(galeria.height, epsilon: 0.5));
    // A prova de que o caso é o da foto enviada: o rótulo da galeria de fato
    // quebrou (o botão está mais alto que um botão de uma linha), e mesmo
    // assim nada foi cortado.
    expect(galeria.height, greaterThan(48));
    expect(tester.takeException(), isNull);
  });

  testWidgets('numa tela larga, cabem numa linha e continuam iguais',
      (tester) async {
    await montar(tester, largura: 800);

    final camera = tamanhoDo(tester, 'Tirar foto');
    final galeria = tamanhoDo(tester, 'Escolher da galeria');

    expect(camera, equals(galeria));
  });
}
