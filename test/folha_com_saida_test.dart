import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/widgets/folha_com_saida.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

/// Folhas sem saída.
///
/// A dona testa no navegador do celular, onde arrastar a folha para baixo não
/// se anuncia e tocar fora não se oferece. Os dois gestos FUNCIONAVAM (o
/// padrão do Material já traz `enableDrag` e `isDismissible`); o que faltava
/// era dizer isso a quem olha. As folhas grandes desenhavam uma alça de
/// 40x4 PINTADA à mão — retângulo dentro do conteúdo, sem alvo de toque nem
/// semântica — e nenhuma tinha botão de sair. A pior delas era o portão do
/// captcha: quem não conseguisse resolver o desafio não via nenhuma porta.
///
/// A primeira metade destes testes olha o comportamento do
/// [mostrarFolhaComSaida]; a segunda é uma catraca de código-fonte, para que a
/// alça pintada e o `showModalBottomSheet` cru não voltem sorrateiramente aos
/// arquivos já consertados. A lista cresce a cada folha achada, por isso
/// nenhum número entra neste texto: número em comentário envelhece calado.
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
          reason: 'sem isto a folha ainda arrasta, mas não diz a ninguém '
              'que arrasta — que era o defeito');
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

  group('catraca das folhas sem saída', () {
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
      'lib/features/encyclopedia/presentation/widgets/nature_guide_launcher.dart':
          'a escolha de categoria do Guia da Natureza',
    };

    // As folhas que pintam o PRÓPRIO cartão (fundo transparente no modal).
    // Nelas a alça do Material não serve — flutuaria sobre o escurecido, fora
    // do cartão —, então a saída é só o botão. Por isso o
    // `showModalBottomSheet` cru continua legítimo aqui.
    const cartoesProprios = <String, String>{
      'lib/features/auth/presentation/widgets/usage_limit_widget.dart':
          'a oferta de Premium ao bater o limite',
      'lib/features/auth/presentation/widgets/profile_avatar_picker.dart':
          'a escolha de foto do perfil',
      'lib/core/sharing/share_card_sheet.dart':
          'o cartão de compartilhar',
      'lib/features/divination/presentation/pages/oracle_album_page.dart':
          'a carta encontrada no álbum do Oráculo',
    };

    // A alça pintada: um retângulo baixinho prometendo um gesto que não
    // existia. Entre as duas medidas cabia margem ou comentário, daí o `\s+`.
    // A largura vai de 40 a 49 porque as alças que sobraram em lib/ variam
    // entre 40 e 42 — travar no 40 deixaria a mesma decoração voltar com dois
    // pixels a mais; o `height: 4` é o que a torna específica.
    final alcaPintada = RegExp(r'width: 4\d,\s+height: 4,');

    // O `showModalBottomSheet` cru — com ou sem tipo explícito. Era o tipo que
    // deixava a folha do álbum do Oráculo escapar de uma busca por texto
    // simples por `showModalBottomSheet(`: ela chamava
    // `showModalBottomSheet<void>(`. Casar só `[<(]` logo depois do nome evita
    // repetir o mesmo furo com genérico aninhado — `showModalBottomSheet<Map<
    // String, int>>(` passaria por um `<[^>]*>`, que para no primeiro `>`.
    final folhaCrua = RegExp(r'showModalBottomSheet\s*[<(]');

    arquivos.forEach((caminho, tela) {
      test('$tela tem saída de verdade', () {
        final arquivo = File(caminho);
        expect(arquivo.existsSync(), isTrue, reason: '$caminho não existe');

        final fonte = arquivo.readAsStringSync();

        expect(alcaPintada.hasMatch(fonte), isFalse,
            reason: '$caminho voltou a desenhar a alça à mão — retângulo sem '
                'alvo de toque nem semântica, que só PARECE afordância');
        expect(folhaCrua.hasMatch(fonte), isFalse,
            reason: '$caminho abriu folha sem passar pelo '
                'mostrarFolhaComSaida, e aí a alça de arrasto some');
        expect(fonte.contains('BotaoFecharFolha'), isTrue,
            reason: '$caminho ficou sem botão de sair — no navegador, tocar '
                'fora não se anuncia');
      });
    });

    cartoesProprios.forEach((caminho, tela) {
      test('$tela tem saída de verdade', () {
        final arquivo = File(caminho);
        expect(arquivo.existsSync(), isTrue, reason: '$caminho não existe');

        final fonte = arquivo.readAsStringSync();

        expect(alcaPintada.hasMatch(fonte), isFalse,
            reason: '$caminho voltou a desenhar a alça à mão');
        expect(fonte.contains('BotaoFecharFolha'), isTrue,
            reason: '$caminho ficou sem botão de sair');
      });
    });
  });
}
