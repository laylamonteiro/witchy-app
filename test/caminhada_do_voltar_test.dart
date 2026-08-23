import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/utils/saida_por_dois_toques.dart';
import 'package:grimorio_de_bolso/core/utils/um_de_cada_vez.dart';
import 'package:grimorio_de_bolso/features/home/presentation/caminhada_do_voltar.dart';

/// O pedido da dona (23/08): "o voltar deve ir SEMPRE até o Seu Dia antes de
/// sair do app/fechar a aba". Estes testes provam a caminhada inteira, passo
/// a passo, com o relógio na mão — inclusive as duas garantias que só valem
/// na web (rajada nunca sai; sem para onde ir, não sai) e a paridade do
/// celular, onde sair é só ir para segundo plano.
class _SaidaFalsa extends SaidaDaAba {
  _SaidaFalsa({this.pode = true});

  final bool pode;
  int saidas = 0;

  @override
  bool podeSair() => pode;

  @override
  void sair() => saidas++;
}

void main() {
  /// Um palco mínimo: o Navigator raiz e o da aba ativa, sem providers,
  /// sem l10n, sem navegador.
  Future<
      ({
        CaminhadaDoVoltar caminhada,
        _SaidaFalsa saida,
        GlobalKey<NavigatorState> raiz,
        GlobalKey<NavigatorState> aba,
        List<int> abasPedidas,
        int Function() avisos,
        void Function(Duration) avancar,
      })> montar(
    WidgetTester tester, {
    _SaidaFalsa? saida,
    SaidaPorDoisToques? regra,
    int abaInicial = 0,
  }) async {
    final raiz = GlobalKey<NavigatorState>();
    final aba = GlobalKey<NavigatorState>();
    final abasPedidas = <int>[];
    var avisos = 0;
    var abaAtual = abaInicial;
    var relogio = DateTime(2026, 8, 23, 18, 0);

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: raiz,
        home: Scaffold(
          body: Navigator(
            key: aba,
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (_) => const Text('RAIZ DA ABA'),
            ),
          ),
        ),
      ),
    );

    final saidaUsada = saida ?? _SaidaFalsa();
    return (
      caminhada: CaminhadaDoVoltar(
        raiz: () => raiz.currentState,
        abaAtiva: () => aba.currentState,
        abaAtual: () => abaAtual,
        irParaAba: (indice) {
          abasPedidas.add(indice);
          abaAtual = indice;
        },
        mostrarAviso: () => avisos++,
        regra: regra ??
            SaidaPorDoisToques(
              janela: const Duration(seconds: 4),
              intervaloDeliberado: const Duration(milliseconds: 800),
            ),
        vivo: () => true,
        saida: saidaUsada,
        agora: () => relogio,
      ),
      saida: saidaUsada,
      raiz: raiz,
      aba: aba,
      abasPedidas: abasPedidas,
      avisos: () => avisos,
      avancar: (d) => relogio = relogio.add(d),
    );
  }

  /// Empilha uma página de detalhe DENTRO da aba, como o app faz.
  Future<void> abrirDetalhe(
    WidgetTester tester,
    GlobalKey<NavigatorState> aba,
  ) async {
    aba.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const Text('DETALHE')),
    );
    await tester.pumpAndSettle();
    expect(find.text('DETALHE'), findsOneWidget);
  }

  testWidgets('1. página empilhada volta para a raiz da aba, sem sair',
      (tester) async {
    final palco = await montar(tester, abaInicial: 2);
    await abrirDetalhe(tester, palco.aba);

    await palco.caminhada.resolver();
    await tester.pumpAndSettle();

    expect(find.text('DETALHE'), findsNothing);
    expect(find.text('RAIZ DA ABA'), findsOneWidget);
    expect(palco.abasPedidas, isEmpty, reason: 'ainda não é hora de descer');
    expect(palco.saida.saidas, 0);
    expect(palco.avisos(), 0, reason: 'nem chegou perto de sair');
  });

  testWidgets('2. da raiz de outra aba, o voltar leva ao Seu Dia',
      (tester) async {
    final palco = await montar(tester, abaInicial: 2);

    await palco.caminhada.resolver();
    await tester.pumpAndSettle();

    expect(palco.abasPedidas, [0]);
    expect(palco.saida.saidas, 0);
  });

  testWidgets('3. no Seu Dia, o primeiro voltar avisa — e não sai',
      (tester) async {
    final palco = await montar(tester);

    await palco.caminhada.resolver();
    await tester.pumpAndSettle();

    expect(palco.avisos(), 1);
    expect(palco.saida.saidas, 0);
  });

  testWidgets('4. no Seu Dia, o segundo voltar DELIBERADO sai',
      (tester) async {
    final palco = await montar(tester);

    await palco.caminhada.resolver();
    palco.avancar(const Duration(milliseconds: 900));
    await palco.caminhada.resolver();
    await tester.pumpAndSettle();

    expect(palco.saida.saidas, 1);
  });

  testWidgets('5. a jornada inteira: quatro voltares, uma saída só',
      (tester) async {
    final palco = await montar(tester, abaInicial: 2);
    await abrirDetalhe(tester, palco.aba);

    // (a) desempilha o detalhe
    await palco.caminhada.resolver();
    await tester.pumpAndSettle();
    expect(find.text('DETALHE'), findsNothing);
    expect(palco.saida.saidas, 0);

    // (b) desce para o Seu Dia
    palco.avancar(const Duration(seconds: 1));
    await palco.caminhada.resolver();
    await tester.pumpAndSettle();
    expect(palco.abasPedidas, [0]);
    expect(palco.saida.saidas, 0);

    // (c) avisa
    palco.avancar(const Duration(seconds: 1));
    await palco.caminhada.resolver();
    expect(palco.avisos(), 1);
    expect(palco.saida.saidas, 0);

    // (d) sai
    palco.avancar(const Duration(milliseconds: 900));
    await palco.caminhada.resolver();
    expect(palco.saida.saidas, 1);
  });

  testWidgets('6. rajada de deslizadas NUNCA sai (a regressão da aba)',
      (tester) async {
    final palco = await montar(tester);

    // Três segundos de deslizadas a cada 150ms, do jeito que o gesto do
    // Android repete.
    await palco.caminhada.resolver();
    for (var i = 0; i < 20; i++) {
      palco.avancar(const Duration(milliseconds: 150));
      await palco.caminhada.resolver();
    }
    await tester.pumpAndSettle();

    expect(palco.saida.saidas, 0, reason: 'rajada não fecha aba');
    expect(palco.avisos(), 1, reason: 'o aviso não vira spam');
  });

  testWidgets('7. sem para onde ir, o voltar fica no Seu Dia e não avisa',
      (tester) async {
    // Aba que nasceu no app: nenhuma página fecha uma aba que não abriu, e
    // prometer "toque de novo para sair" ali seria mentir.
    final palco = await montar(tester, saida: _SaidaFalsa(pode: false));

    await palco.caminhada.resolver();
    palco.avancar(const Duration(seconds: 1));
    await palco.caminhada.resolver();
    await tester.pumpAndSettle();

    expect(palco.saida.saidas, 0);
    expect(palco.avisos(), 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('8. no celular, dois toques rápidos saem (paridade)',
      (tester) async {
    final palco = await montar(
      tester,
      regra: SaidaPorDoisToques(
        janela: const Duration(seconds: 2),
        intervaloDeliberado: Duration.zero,
      ),
    );

    await palco.caminhada.resolver();
    palco.avancar(const Duration(milliseconds: 300));
    await palco.caminhada.resolver();

    expect(palco.saida.saidas, 1, reason: 'sair no celular é reversível');
  });

  testWidgets('9. uma tela cheia que abre e fecha caduca o aviso',
      (tester) async {
    final palco = await montar(tester);

    await palco.caminhada.resolver();
    expect(palco.avisos(), 1);

    // O que a Home faz ao ver a pilha raiz mudar (Configurações abriu e
    // fechou sem passar pelo tratador de voltar).
    palco.caminhada.regra.esquecer();

    palco.avancar(const Duration(milliseconds: 900));
    await palco.caminhada.resolver();

    expect(palco.saida.saidas, 0, reason: 'sair exige aviso na tela');
    expect(palco.avisos(), 2, reason: 'avisa de novo, do zero');
  });

  testWidgets('10. dois voltares em voo desempilham UMA tela só',
      (tester) async {
    // O portão que matou o WebBackKeeper, agora sobre a caminhada de
    // verdade: duas telas empilhadas, dois voltares ao mesmo tempo.
    final palco = await montar(tester, abaInicial: 2);
    await abrirDetalhe(tester, palco.aba);
    palco.aba.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const Text('SEGUNDA')),
    );
    await tester.pumpAndSettle();

    final portao = UmDeCadaVez();
    final primeiro = portao.executar(palco.caminhada.resolver);
    final segundo = portao.executar(palco.caminhada.resolver);
    await primeiro;
    await segundo;
    await tester.pumpAndSettle();

    expect(find.text('DETALHE'), findsOneWidget,
        reason: 'só a de cima saiu');
    expect(palco.saida.saidas, 0);
    expect(tester.takeException(), isNull);
  });
}
