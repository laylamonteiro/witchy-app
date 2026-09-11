import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/widgets/folha_com_saida.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

/// Folhas sem saída.
///
/// A dona testa no navegador do celular, onde arrastar a folha para baixo não
/// se anuncia e tocar fora não se oferece. Cinco folhas grandes desenhavam uma
/// alça de 40x4 PINTADA à mão — decoração pura, que não arrastava nada — e não
/// tinham nenhum botão de sair. A pior delas era o portão do captcha: quem não
/// conseguisse resolver o desafio ficava presa no login, sem porta.
///
/// A primeira metade destes testes olha o comportamento do
/// [mostrarFolhaComSaida]; a segunda é uma catraca de código-fonte, para que a
/// alça pintada e o `showModalBottomSheet` cru não voltem sorrateiramente a
/// estes cinco arquivos.
void main() {
  Widget app(Widget child) => MaterialApp(
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );

  // Um botão que abre a folha — é assim que as telas chamam.
  Widget abridor(void Function(BuildContext context) aoTocar) => Builder(
        builder: (context) => TextButton(
          onPressed: () => aoTocar(context),
          child: const Text('abrir'),
        ),
      );

  group('a folha que se fecha', () {
    testWidgets('nasce com a alça de arrasto DE VERDADE', (tester) async {
      await tester.pumpWidget(app(abridor((context) {
        mostrarFolhaComSaida<void>(
          context: context,
          builder: (_) => const SizedBox(height: 120),
        );
      })));

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      final folha = tester.widget<BottomSheet>(find.byType(BottomSheet));
      expect(folha.showDragHandle, isTrue,
          reason: 'sem isto a alça volta a ser desenho, e o gesto some');
      expect(folha.enableDrag, isTrue,
          reason: 'a alça só significa alguma coisa se a folha arrastar');
    });

    testWidgets('o X fecha a folha e devolve nada', (tester) async {
      String? resultado = 'ainda aberta';

      await tester.pumpWidget(app(abridor((context) async {
        resultado = await mostrarFolhaComSaida<String>(
          context: context,
          builder: (_) => const Padding(
            padding: EdgeInsets.all(20),
            child: BotaoFecharFolha(key: ValueKey('folha-de-teste-close')),
          ),
        );
      })));

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('folha-de-teste-close')));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsNothing);
      // Desistir vale o mesmo que tocar fora: quem chamou recebe null.
      expect(resultado, isNull);
    });

    testWidgets('com onPressed, o X faz o que a tela mandou', (tester) async {
      var chamadas = 0;

      await tester.pumpWidget(app(BotaoFecharFolha(onPressed: () {
        chamadas++;
      })));

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(chamadas, 1);
    });
  });

  group('catraca das cinco folhas', () {
    // Os arquivos varridos, com o nome que a dona usa para cada tela.
    const arquivos = <String, String>{
      'lib/features/auth/presentation/widgets/captcha_gate.dart':
          'o portão do captcha (Entrar, Cadastrar, Esqueci minha senha)',
      'lib/features/wheel_of_year/presentation/pages/wheel_of_year_page.dart':
          'o detalhe do sabá',
      'lib/features/journeys/presentation/pages/journeys_page.dart':
          'o detalhe da jornada e a escada de títulos',
      'lib/features/guided_rituals/presentation/widgets/magical_moment_card.dart':
          'o guia completo do Momento Mágico',
      'lib/features/astrology/presentation/pages/birth_chart_view_page.dart':
          'o detalhe do mapa natal',
    };

    // A alça pintada: um retângulo de 40x4 prometendo um gesto que não
    // existia. Entre as duas medidas cabia margem ou comentário, daí o `\s+`.
    final alcaPintada = RegExp(r'width: 40,\s+height: 4,');

    arquivos.forEach((caminho, tela) {
      test('$tela tem saída de verdade', () {
        final arquivo = File(caminho);
        expect(arquivo.existsSync(), isTrue, reason: '$caminho não existe');

        final fonte = arquivo.readAsStringSync();

        expect(alcaPintada.hasMatch(fonte), isFalse,
            reason: '$caminho voltou a desenhar a alça à mão — ela não '
                'arrasta nada, só finge');
        expect(fonte.contains('showModalBottomSheet('), isFalse,
            reason: '$caminho abriu folha sem passar pelo '
                'mostrarFolhaComSaida, e aí a alça de arrasto some');
        expect(fonte.contains('BotaoFecharFolha'), isTrue,
            reason: '$caminho ficou sem botão de sair — no navegador, tocar '
                'fora não se anuncia');
      });
    });
  });
}
