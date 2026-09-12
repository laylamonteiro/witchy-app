import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/widgets/mascot/draggable_cat_mascot.dart';

/// A reancoragem do Salem (set/2026).
///
/// `_x`/`_y` são coordenadas de viewport, e até aqui a trava de borda só
/// rodava DURANTE o arraste. Bastava o viewport mudar — redimensionar a janela
/// do navegador, cruzar o breakpoint de 600 px do quadro web, abrir o teclado
/// ou dividir a tela no Android — para o gato ficar numa coordenada de uma
/// tela que não existe mais, estourando a borda (e, na web, sendo cortado pelo
/// recorte duro do quadro de 430 px).
///
/// A posição de repouso dele NÃO muda aqui: mudar de canto esbarraria nos FABs
/// de cinco telas e desancoraria o balão de fala.
const double _tamanho = 85;

void main() {
  // Muda o viewport e deixa o quadro correr até o post-frame, que é onde o
  // mascote avisa o notifier (avisar durante o build marcaria o balão de fala,
  // irmão anterior na pilha da Home, para reconstruir no mesmo quadro).
  Future<void> redimensionar(WidgetTester tester, Size tamanho) async {
    tester.view.physicalSize = tamanho;
    await tester.pump();
    await tester.pump();
  }

  testWidgets('o Salem volta para dentro quando o viewport encolhe',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.reset);

    final posicao = ValueNotifier(Offset.zero);
    addTearDown(posicao.dispose);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DraggableCatMascot(
          initialX: 1000,
          initialY: 700,
          positionNotifier: posicao,
        ),
      ),
    ));
    await tester.pump();

    // Na janela larga ele fica exatamente onde a dona o deixou.
    expect(posicao.value, const Offset(1000, 700));

    // O quadro web de 430 px — o salto de largura que deixava a coordenada
    // obsoleta.
    await redimensionar(tester, const Size(430, 700));

    expect(posicao.value, isNot(const Offset(1000, 700)),
        reason: 'sem retravar, o gato fica numa coordenada de outra tela');
    expect(posicao.value.dx + _tamanho, lessThanOrEqualTo(430),
        reason: 'o gato inteiro tem de caber no viewport novo');
    expect(posicao.value.dy + _tamanho, lessThanOrEqualTo(700));
    expect(posicao.value.dx, greaterThan(0));
    expect(posicao.value.dy, greaterThan(0));
  });

  testWidgets('a trava não estoura num viewport menor que o próprio gato',
      (tester) async {
    // `clamp` lança quando o limite inferior passa o superior, e uma janela de
    // navegador arrastada até ficar minúscula chega lá de verdade.
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.reset);

    final posicao = ValueNotifier(Offset.zero);
    addTearDown(posicao.dispose);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DraggableCatMascot(
          initialX: 900,
          initialY: 700,
          positionNotifier: posicao,
        ),
      ),
    ));
    await tester.pump();

    await redimensionar(tester, const Size(60, 120));

    expect(posicao.value.dx.isFinite, isTrue);
    expect(posicao.value.dy.isFinite, isTrue);
    expect(posicao.value.dx, greaterThanOrEqualTo(0));
    expect(posicao.value.dy, greaterThanOrEqualTo(0));
  });

  testWidgets('viewport que só cresce deixa o Salem onde está', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 800);
    addTearDown(tester.view.reset);

    final posicao = ValueNotifier(Offset.zero);
    addTearDown(posicao.dispose);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DraggableCatMascot(
          initialX: 120,
          initialY: 200,
          positionNotifier: posicao,
        ),
      ),
    ));
    await tester.pump();

    await redimensionar(tester, const Size(1200, 900));

    // Retravar não pode virar "reposicionar": quem arrastou o gato para um
    // canto continua com ele lá.
    expect(posicao.value, const Offset(120, 200));
  });
}
