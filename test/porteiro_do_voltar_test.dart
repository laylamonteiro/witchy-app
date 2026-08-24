import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/navigation/porteiro_do_voltar.dart';

/// O defeito que estes testes guardam:
///
/// `WidgetsBinding.handlePopRoute()` percorre os observadores do binding e, se
/// NENHUM devolver `true`, chama `SystemNavigator.pop()`
/// (binding.dart:1116-1132, Flutter 3.47). Na web esse atalho cai no `exit()`
/// do motor, que desliga o ouvinte de `popstate` PARA SEMPRE e apaga a
/// entrada-guarda — e a partir daí qualquer voltar fecha a aba, de qualquer
/// tela do app.
///
/// O [PorteiroDoVoltar] é a única peça que fecha essa porta em TODO quadro,
/// inclusive naqueles em que nenhum `PopScope` está montado (o boot antes do
/// primeiro `runApp`, a tela de erro de render, a troca de sessão).
void main() {
  /// Captura o que o app pede à plataforma. É aqui que se vê o
  /// `SystemNavigator.pop` acontecer — ou não.
  List<MethodCall> espionarAPlataforma() {
    final chamadas = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (chamada) async {
      chamadas.add(chamada);
      return null;
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    return chamadas;
  }

  bool pediuParaSair(List<MethodCall> chamadas) =>
      chamadas.any((c) => c.method == 'SystemNavigator.pop');

  /// Instala o porteiro do jeito que a produção instala: PRIMEIRO na fila de
  /// observadores, antes de a árvore existir (no app real, antes do `runApp`).
  ///
  /// A ordem é parte do teste. `handlePopRoute` percorre os observadores na
  /// ordem de registro, e o `_WidgetsAppState` entra na fila quando o
  /// `MaterialApp` monta: instalar o porteiro DEPOIS do `pumpWidget` faria o
  /// observador do framework tratar o voltar primeiro, e estes testes passariam
  /// sem nunca exercitar o porteiro.
  PorteiroDoVoltar instalarPrimeiro(
    WidgetTester tester,
    NavigatorState? Function() raiz, {
    bool naWeb = true,
  }) {
    final porteiro = PorteiroDoVoltar(
      raiz: raiz,
      naWeb: naWeb,
      registrar: (_) {},
    );
    tester.binding.addObserver(porteiro);
    addTearDown(() => tester.binding.removeObserver(porteiro));
    return porteiro;
  }

  /// Manda o voltar pelo MESMO caminho do motor da web: a mensagem `popRoute`
  /// no canal `flutter/navigation`. É ela que o `SingleEntryBrowserHistory`
  /// despacha ao receber um `popstate`, e é ela que termina em
  /// `WidgetsBinding.handlePopRoute()`. Usar o canal (e não o método, que é
  /// `@protected`) exercita a cadeia inteira, que é justamente o que está sob
  /// suspeita.
  Future<void> voltarDoNavegador(WidgetTester tester) async {
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/navigation',
      const JSONMethodCodec().encodeMethodCall(const MethodCall('popRoute')),
      (_) {},
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
      'CONTROLE POSITIVO: sem porteiro, um voltar sem ninguém para tratá-lo '
      'chama SystemNavigator.pop', (tester) async {
    // Prova que o buraco é real — este teste tem de passar mesmo se alguém
    // apagar o porteiro. Uma tela sem `PopScope` e sem nada para desempilhar é
    // o quadro do boot, o da tela de erro e o da troca de sessão.
    final chamadas = espionarAPlataforma();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('SEM GUARDA'))),
    );

    await voltarDoNavegador(tester);

    expect(pediuParaSair(chamadas), isTrue,
        reason: 'é este atalho que na web mata o voltar do documento inteiro');
  });

  testWidgets('na web o porteiro engole o voltar e a plataforma não é chamada',
      (tester) async {
    final chamadas = espionarAPlataforma();
    final raiz = GlobalKey<NavigatorState>();
    final porteiro = instalarPrimeiro(tester, () => raiz.currentState);
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: raiz,
        home: const Scaffold(body: Text('SEM GUARDA')),
      ),
    );

    await voltarDoNavegador(tester);

    expect(pediuParaSair(chamadas), isFalse,
        reason: 'o exit() do motor tem de ficar inalcançável na web');
    expect(porteiro.voltaresTratados, 1);
  });

  testWidgets('sem navegador raiz (boot, tela de erro) ainda assim segura',
      (tester) async {
    // O quadro mais perigoso: nenhuma árvore montada, nenhum `PopScope`
    // possível. Antes do porteiro, um voltar aqui envenenava o documento.
    final chamadas = espionarAPlataforma();
    final porteiro = instalarPrimeiro(tester, () => null);
    await tester.pumpWidget(const SizedBox.shrink());

    await voltarDoNavegador(tester);

    expect(pediuParaSair(chamadas), isFalse);
    expect(porteiro.voltaresTratados, 1);
  });

  testWidgets('o porteiro desempilha de verdade a tela do topo',
      (tester) async {
    // Ele não pode só engolir o gesto: tem de fazer o que o `_WidgetsAppState`
    // faria — e, sendo o primeiro da fila, é ele quem faz.
    final raiz = GlobalKey<NavigatorState>();
    final porteiro = instalarPrimeiro(tester, () => raiz.currentState);
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: raiz,
        home: const Scaffold(body: Text('RAIZ')),
      ),
    );
    raiz.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const Text('DETALHE')),
    );
    await tester.pumpAndSettle();
    expect(find.text('DETALHE'), findsOneWidget);

    await voltarDoNavegador(tester);

    expect(find.text('DETALHE'), findsNothing);
    expect(find.text('RAIZ'), findsOneWidget);
    expect(porteiro.voltaresTratados, 1, reason: 'foi ele quem desempilhou');
  });

  testWidgets('o PopScope da tela continua mandando: pop recusado não sai',
      (tester) async {
    // É por este caminho que a `CaminhadaDoVoltar` da Home recebe o gesto: o
    // porteiro chama `maybePop`, o `PopScope` recusa, e a caminhada decide.
    var recusas = 0;
    final chamadas = espionarAPlataforma();
    final raiz = GlobalKey<NavigatorState>();
    instalarPrimeiro(tester, () => raiz.currentState);
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: raiz,
        home: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) recusas++;
          },
          child: const Scaffold(body: Text('HOME')),
        ),
      ),
    );

    await voltarDoNavegador(tester);

    expect(recusas, 1);
    expect(find.text('HOME'), findsOneWidget);
    expect(pediuParaSair(chamadas), isFalse);
  });

  testWidgets('dois voltares em voo desempilham UMA tela só', (tester) async {
    // O portão de reentrada do porteiro (`UmDeCadaVez`): `maybePop` é
    // assíncrono, e sem trava dois gestos em voo desempilham duas telas.
    final raiz = GlobalKey<NavigatorState>();
    instalarPrimeiro(tester, () => raiz.currentState);
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: raiz,
        home: const Scaffold(body: Text('RAIZ')),
      ),
    );
    raiz.currentState!
        .push(MaterialPageRoute<void>(builder: (_) => const Text('PRIMEIRA')));
    await tester.pumpAndSettle();
    raiz.currentState!
        .push(MaterialPageRoute<void>(builder: (_) => const Text('SEGUNDA')));
    await tester.pumpAndSettle();

    final a = voltarDoNavegador(tester);
    final b = voltarDoNavegador(tester);
    await a;
    await b;
    await tester.pumpAndSettle();

    expect(find.text('PRIMEIRA'), findsOneWidget, reason: 'só a de cima saiu');
    expect(tester.takeException(), isNull);
  });

  testWidgets('FORA da web o porteiro é inerte — sair é ir para segundo plano',
      (tester) async {
    // No celular o `SystemNavigator.pop()` está CERTO: manda o app para segundo
    // plano, é reversível, e engoli-lo prenderia a Bruxa dentro do app.
    final chamadas = espionarAPlataforma();
    final porteiro = instalarPrimeiro(tester, () => null, naWeb: false);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('SEM GUARDA'))),
    );

    await voltarDoNavegador(tester);

    expect(pediuParaSair(chamadas), isTrue,
        reason: 'no celular o voltar na raiz manda o app para segundo plano');
    expect(porteiro.voltaresTratados, 0);
  });
}
