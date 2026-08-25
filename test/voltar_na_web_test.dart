import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/utils/saida_por_dois_toques.dart';
import 'package:grimorio_de_bolso/core/utils/um_de_cada_vez.dart';

/// O pedido que originou tudo isto foi "voltar nunca sai do app". Na web,
/// voltar é o histórico do navegador, e depois de um login social a entrada
/// anterior é o `accounts.google.com`.
///
/// A tentativa anterior (WebBackKeeper) foi revertida porque entrou em
/// RECURSÃO com o tratador de voltar da home: um `PopScope` que recusa o pop
/// chama o tratador, o tratador chama `maybePop`, o `maybePop` chama o
/// `PopScope` de novo. Estes testes guardam o portão que quebra esse ciclo, e
/// a regra do toque duplo — que hoje só o celular alcança, porque na web o
/// passo 4 da caminhada termina antes, em "você já está no Seu Dia".
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

  group('sair só com um voltar deliberado', () {
    final t0 = DateTime(2026, 8, 23, 18, 0, 0);

    test('o primeiro voltar na raiz avisa, não sai', () {
      final saida = SaidaPorDoisToques();
      expect(saida.registrar(t0), DecisaoDeSaida.avisar);
      expect(saida.avisando, isTrue);
    });
    test('o segundo voltar deliberado sai', () {
      final saida = SaidaPorDoisToques();
      saida.registrar(t0);
      expect(
        saida.registrar(t0.add(const Duration(milliseconds: 900))),
        DecisaoDeSaida.sair,
      );
    });

    test('depois da janela, o aviso caduca e tudo recomeça', () {
      final saida = SaidaPorDoisToques();
      saida.registrar(t0);
      expect(
        saida.registrar(t0.add(const Duration(seconds: 5))),
        DecisaoDeSaida.avisar,
      );
    });
    test('no celular o toque duplo rápido sai', () {
      // Sair no celular é ir para segundo plano — reversível. Ali o padrão de
      // sempre (dois toques rápidos) vale, e é o único lugar que chega aqui:
      // na web o passo 4 termina antes, em "você já está no Seu Dia".
      final saida = SaidaPorDoisToques();
      expect(saida.registrar(t0), DecisaoDeSaida.avisar);
      expect(
        saida.registrar(t0.add(const Duration(milliseconds: 300))),
        DecisaoDeSaida.sair,
      );
    });

    test('caminhar (desempilhar, trocar de aba) esquece o aviso', () {
      // Sem isto, um aviso dado no Seu Dia continuaria valendo depois de a
      // pessoa navegar, e o voltar seguinte sairia de dentro de outra tela.
      final saida = SaidaPorDoisToques();
      saida.registrar(t0);
      saida.esquecer();
      expect(saida.avisando, isFalse);
      expect(
        saida.registrar(t0.add(const Duration(milliseconds: 900))),
        DecisaoDeSaida.avisar,
      );
    });
  });
}
