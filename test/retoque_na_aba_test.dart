import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/home/presentation/retoque_na_aba.dart';

/// O pedido: "tocar em Ferramentas dentro do Pêndulo tem de voltar à aba
/// principal — e isso vale para toda página". O `goBranch(initialLocation)`
/// do go_router não enxerga as telas empurradas com Navigator.push, então o
/// re-toque tem de desempilhar o Navigator da aba ANTES de refazer o branch.
void main() {
  /// Palco mínimo: um Navigator de aba com a raiz e, opcionalmente, uma
  /// página de detalhe por cima — como o app faz com o Pêndulo.
  Future<GlobalKey<NavigatorState>> montar(
    WidgetTester tester, {
    bool comDetalhe = true,
  }) async {
    final aba = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
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
    if (comDetalhe) {
      aba.currentState!.push(
        MaterialPageRoute<void>(builder: (_) => const Text('DETALHE')),
      );
      await tester.pumpAndSettle();
      expect(find.text('DETALHE'), findsOneWidget);
    }
    return aba;
  }

  testWidgets('desempilha a página de detalhe e devolve a seção à raiz',
      (tester) async {
    final aba = await montar(tester);
    var idasARaiz = 0;
    var resets = 0;

    retocarAbaAtiva(
      navegadorDaAba: aba.currentState,
      irParaARaizDoBranch: () => idasARaiz++,
      resetarSecao: () => resets++,
    );
    await tester.pumpAndSettle();

    expect(find.text('DETALHE'), findsNothing);
    expect(find.text('RAIZ DA ABA'), findsOneWidget);
    expect(idasARaiz, 1);
    expect(resets, 1);
  });

  testWidgets('já na raiz, só refaz o branch e reseta a seção',
      (tester) async {
    final aba = await montar(tester, comDetalhe: false);
    var idasARaiz = 0;
    var resets = 0;

    retocarAbaAtiva(
      navegadorDaAba: aba.currentState,
      irParaARaizDoBranch: () => idasARaiz++,
      resetarSecao: () => resets++,
    );
    await tester.pumpAndSettle();

    expect(find.text('RAIZ DA ABA'), findsOneWidget);
    expect(idasARaiz, 1);
    expect(resets, 1);
  });

  testWidgets('sem Navigator (aba nunca montada) não quebra', (tester) async {
    var idasARaiz = 0;
    var resets = 0;

    retocarAbaAtiva(
      navegadorDaAba: null,
      irParaARaizDoBranch: () => idasARaiz++,
      resetarSecao: () => resets++,
    );

    expect(idasARaiz, 1);
    expect(resets, 1);
  });
}
