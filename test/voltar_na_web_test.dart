import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/utils/um_de_cada_vez.dart';
import 'package:grimorio_de_bolso/core/widgets/guarda_de_voltar_web.dart';

/// O pedido que originou tudo isto foi "voltar nunca sai do app". Na web,
/// voltar é o histórico do navegador, e depois de um login social a entrada
/// anterior é o `accounts.google.com`.
///
/// A tentativa anterior (WebBackKeeper) foi revertida porque entrou em
/// RECURSÃO com o tratador de voltar da home: um `PopScope` que recusa o pop
/// chama o tratador, o tratador chama `maybePop`, o `maybePop` chama o
/// `PopScope` de novo. Estes testes cobrem os dois lados do conserto — o
/// portão que quebra o ciclo e o guarda que segura a saída.
void main() {
  group('um de cada vez', () {
    test('a segunda chamada durante a primeira é descartada', () async {
      final portao = UmDeCadaVez();
      final segura = Completer<void>();
      var execucoes = 0;

      final primeira = portao.executar(() async {
        execucoes++;
        await segura.future;
      });

      // Ainda em voo: a segunda tem de ser recusada, e recusada AGORA — sem
      // esperar a primeira, senão seria fila, não descarte.
      expect(await portao.executar(() async => execucoes++), isFalse);
      expect(execucoes, 1);

      segura.complete();
      expect(await primeira, isTrue);
    });

    test('depois de terminar, volta a deixar passar', () async {
      final portao = UmDeCadaVez();
      var execucoes = 0;

      await portao.executar(() async => execucoes++);
      await portao.executar(() async => execucoes++);

      expect(execucoes, 2);
      expect(portao.emVoo, isFalse);
    });

    test('uma falha não tranca o portão para sempre', () async {
      // Se o `finally` sumisse, o voltar pararia de funcionar até o app
      // reiniciar — e o rastro seria "o botão de voltar morreu do nada".
      final portao = UmDeCadaVez();

      await expectLater(
        portao.executar(() async => throw StateError('falhou')),
        throwsStateError,
      );

      expect(portao.emVoo, isFalse);
      expect(await portao.executar(() async {}), isTrue);
    });
  });

  testWidgets('o tratador de voltar não se chama de novo por baixo de si',
      (tester) async {
    // Reproduz a forma exata que matou o WebBackKeeper: o tratador do
    // `PopScope` desempilha com `maybePop`, e o `maybePop` — recusado —
    // chama o mesmo tratador. Sem o portão, isto não termina.
    final portao = UmDeCadaVez();
    final navegador = GlobalKey<NavigatorState>();
    var execucoes = 0;

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navegador,
        home: Builder(
          builder: (context) => PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              portao.executar(() async {
                execucoes++;
                await Navigator.of(context).maybePop();
              });
            },
            child: const Scaffold(body: Text('APP')),
          ),
        ),
      ),
    );

    await navegador.currentState!.maybePop();
    await tester.pumpAndSettle();

    expect(execucoes, 1, reason: 'o tratador rodou uma vez só');
    expect(find.text('APP'), findsOneWidget, reason: 'ninguém saiu da tela');
    expect(tester.takeException(), isNull);
  });

  group('guarda de voltar na web', () {
    // A pergunta é comportamental de propósito: `maybePop` devolve `true`
    // tanto quando desempilha quanto quando o PopScope RECUSA — quem
    // assertasse o retorno estaria testando o Flutter, e errado. O que
    // importa é qual tela ficou na frente.
    Future<void> montar(WidgetTester tester,
        {required bool naWeb, required GlobalKey<NavigatorState> chave}) async {
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: chave,
          home: const Scaffold(body: Text('DE ONDE VEIO')),
        ),
      );
      unawaited(chave.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => GuardaDeVoltarWeb(
            naWeb: naWeb,
            child: const Scaffold(body: Text('ESPERANDO')),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('ESPERANDO'), findsOneWidget);
    }

    testWidgets('na web, o voltar não tira a pessoa da tela', (tester) async {
      final chave = GlobalKey<NavigatorState>();
      await montar(tester, naWeb: true, chave: chave);

      await chave.currentState!.maybePop();
      await tester.pumpAndSettle();

      expect(find.text('ESPERANDO'), findsOneWidget);
      expect(find.text('DE ONDE VEIO'), findsNothing);
    });

    testWidgets('fora da web, o voltar volta normalmente', (tester) async {
      // No celular o voltar na porta de entrada é como se fecha o app. Um
      // guarda ligado aqui prenderia a pessoa sem saída nenhuma.
      final chave = GlobalKey<NavigatorState>();
      await montar(tester, naWeb: false, chave: chave);

      await chave.currentState!.maybePop();
      await tester.pumpAndSettle();

      expect(find.text('DE ONDE VEIO'), findsOneWidget);
      expect(find.text('ESPERANDO'), findsNothing);
    });
  });
}
