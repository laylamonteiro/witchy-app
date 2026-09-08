import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/widgets/splash_screen.dart';

// O splash de marca trocava a rota inteira da Home por uma rota imperativa
// depois de 2,5 s (herança de antes do go_router). Com a Home sendo uma rota
// DE PÁGINA, isso deixava dois estados da Home vivos: o "Pular tour" mexia
// num State descartado e os Navigators das abas mudavam de dono a cada
// rebuild — o teclado fechava sozinho. Agora o splash é só uma camada por
// cima: o app nasce montado e continua o MESMO depois que o logo some.
class _Conteudo extends StatefulWidget {
  const _Conteudo({required this.aoTocar});

  final VoidCallback aoTocar;

  @override
  State<_Conteudo> createState() => _ConteudoState();
}

class _ConteudoState extends State<_Conteudo> {
  static int montagens = 0;

  @override
  void initState() {
    super.initState();
    montagens++;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: widget.aoTocar,
            child: const Text('CONTEUDO'),
          ),
        ),
      );
}

class _Observador extends NavigatorObserver {
  int pushes = 0;
  int replaces = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    replaces++;
  }
}

void main() {
  setUp(() => _ConteudoState.montagens = 0);

  testWidgets('o app nasce montado sob o logo, o logo some sem trocar de rota '
      'e o State do app é o mesmo antes e depois', (tester) async {
    var toques = 0;
    final observador = _Observador();
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observador],
        home: SplashScreen(child: _Conteudo(aoTocar: () => toques++)),
      ),
    );

    // Primeiro quadro: o conteúdo JÁ existe (initState rodou) e o logo está
    // por cima.
    expect(_ConteudoState.montagens, 1);
    final antes = tester.state(find.byType(_Conteudo));
    expect(find.byType(Image), findsOneWidget, reason: 'logo na frente');

    // Enquanto o logo está na frente, o toque não chega ao app.
    await tester.tap(find.text('CONTEUDO'), warnIfMissed: false);
    await tester.pump();
    expect(toques, 0);

    // 2,5 s de logo + fade de saída. O controller só se dá por concluído
    // num tick DEPOIS do fim da duração (isDone é `t > duração`), daí o
    // quadro extra antes do rebuild que tira a camada.
    await tester.pump(SplashScreen.duracao);
    await tester.pump(SplashScreen.saida);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    expect(find.byType(Image), findsNothing, reason: 'logo saiu');

    // O mesmo State: nada foi desmontado nem recriado.
    expect(identical(antes, tester.state(find.byType(_Conteudo))), isTrue);
    expect(_ConteudoState.montagens, 1);

    // E agora o toque chega.
    await tester.tap(find.text('CONTEUDO'));
    await tester.pump();
    expect(toques, 1);

    // Nenhuma cirurgia de rota: só o push inicial da home do MaterialApp.
    expect(observador.pushes, 1);
    expect(observador.replaces, 0);
  });

  testWidgets('descartar o splash no meio não deixa nada pendente',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: SplashScreen(child: _Conteudo(aoTocar: () {}))),
    );
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(SplashScreen.duracao);
    expect(tester.takeException(), isNull);
  });
}
