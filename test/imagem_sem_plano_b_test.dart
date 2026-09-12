import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimorio_de_bolso/core/sharing/share_card.dart';
import 'package:grimorio_de_bolso/features/subscription/presentation/widgets/subscription_offer_widgets.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import 'support/short_test_timeout.dart';

/// Nenhuma imagem sem plano B.
///
/// Na web cada asset é um download separado, e todo download pode falhar:
/// rede ruim, cache frio, deploy publicado no meio da sessão. Sem
/// `errorBuilder` o Flutter desenha um X cinza no lugar da arte — e onde
/// isso acontece importa: no herói do paywall é dinheiro, no cartão de
/// compartilhar é a imagem que sai do app e vira post de outra pessoa.
///
/// O arquivo guarda duas coisas: que toda imagem destas telas TEM reserva
/// (a varredura) e que a reserva desenha o que devia, no mesmo espaço que
/// a arte ocupava (os testes de widget).
void main() {
  useShortTestTimeout();

  // GoogleFonts tenta baixar a fonte na primeira montagem; no teste isso é
  // uma chamada de rede que não vai a lugar nenhum.
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget app(Widget child) => MaterialApp(
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );

  group('varredura', () {
    // Devolve o trecho de código de uma chamada, do parêntese de abertura
    // até o que o fecha — é o que permite perguntar se ESTA imagem tem
    // reserva, em vez de contar `errorBuilder` soltos no arquivo (um
    // comentário citando o nome já inflaria a conta).
    //
    // Nulo quando a contagem não fecha: o casamento não distingue código de
    // string nem de comentário, então um parêntese solto dentro deles
    // desalinha tudo. Devolver o resto do arquivo nesse caso seria PIOR do
    // que falhar — o `errorBuilder` de qualquer imagem seguinte faria esta
    // aqui passar, e a varredura viraria um carimbo que não vigia nada.
    String? argumentosDe(String fonte, int abertura) {
      var profundidade = 0;
      for (var i = abertura; i < fonte.length; i++) {
        if (fonte[i] == '(') profundidade++;
        if (fonte[i] == ')') {
          profundidade--;
          if (profundidade == 0) return fonte.substring(abertura, i + 1);
        }
      }
      return null;
    }

    test('toda imagem das telas de assinatura e do cartão tem reserva', () {
      // As frentes cobertas por este teste. Ficam de fora as telas de
      // outras equipes: apontar o dedo para o arquivo alheio num teste só
      // faz o CI cair no colo de quem não mexeu nele.
      const pastas = [
        'lib/features/subscription',
        'lib/core/sharing',
        'lib/core/widgets',
      ];
      const construtores = [
        'Image.asset(',
        'Image.network(',
        'Image.file(',
        'Image.memory(',
      ];

      final arquivos = <File>[
        for (final pasta in pastas)
          ...Directory(pasta)
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart')),
      ];
      expect(arquivos, isNotEmpty, reason: 'as pastas mudaram de lugar');

      var imagensVistas = 0;
      for (final arquivo in arquivos) {
        final fonte = arquivo.readAsStringSync();
        for (final construtor in construtores) {
          var de = 0;
          while (true) {
            final achou = fonte.indexOf(construtor, de);
            if (achou < 0) break;
            de = achou + 1;
            imagensVistas++;
            final argumentos =
                argumentosDe(fonte, achou + construtor.length - 1);
            final linha = '\n'.allMatches(fonte.substring(0, achou)).length + 1;
            expect(
              argumentos,
              isNotNull,
              reason: '${arquivo.path}:$linha — os parênteses desta chamada '
                  'não fecham para a varredura (parêntese solto numa string '
                  'ou num comentário dentro dela?). Sem casar, este teste '
                  'não consegue afirmar nada sobre a imagem.',
            );
            expect(
              argumentos!,
              contains('errorBuilder'),
              reason: '${arquivo.path}:$linha — $construtor sem errorBuilder: '
                  'na web este asset pode simplesmente não chegar.',
            );
          }
        }
      }
      expect(imagensVistas, greaterThanOrEqualTo(4),
          reason: 'a varredura deixou de encontrar as imagens que conhecia');
    });

    test('as artes que estas telas pedem existem mesmo em disco', () {
      for (final caminho in const [
        'assets/app_icon.png',
        'assets/premium/cat_hero.png',
        'assets/premium/icon_orb.png',
        'assets/premium/icon_book.png',
        'assets/premium/icon_moon.png',
        'assets/premium/icon_runes.png',
        'assets/premium/icon_shield.png',
        'assets/premium/icon_lock.png',
      ]) {
        expect(File(caminho).existsSync(), isTrue,
            reason: '$caminho saiu do repositório');
      }
    });

    test('o pubspec ainda empacota estas artes', () {
      // Existir em disco não basta: asset fora da lista do pubspec não vai
      // no build, e aí a reserva passa a ser o estado NORMAL da tela.
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('- assets/app_icon.png'));
      expect(pubspec, contains('- assets/premium/'));
    });
  });

  group('a reserva de cada imagem', () {
    testWidgets('o herói do paywall vira a silhueta do gato, no mesmo box',
        (tester) async {
      await tester.pumpWidget(app(const Center(child: CatHeroArt(height: 120))));

      // A altura é do SizedBox do próprio herói, não da arte: é por isso
      // que a oferta abaixo não se move quando o PNG não chega.
      expect(tester.getSize(find.byType(CatHeroArt)).height, 120);

      final arte = tester.widget<Image>(find.descendant(
        of: find.byType(CatHeroArt),
        matching: find.byType(Image),
      ));
      expect(arte.errorBuilder, isNotNull,
          reason: 'a arte da tela que cobra não pode ficar sem plano B');

      final reserva = arte.errorBuilder!(
          tester.element(find.byType(CatHeroArt)), 'rede caiu', null);
      // O Image só embrulha o semanticLabel no caminho que dá certo; no
      // erro devolve cru o que o builder retornar. Sem este Semantics quem
      // usa leitor de tela perderia o gato junto com o PNG.
      expect(reserva, isA<Semantics>());

      await tester.pumpWidget(app(SizedBox(height: 120, child: reserva)));
      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('o benefício sem arte mostra o ícone da própria peça e a '
        'linha não encolhe', (tester) async {
      const rotulo = 'Conselheiro místico';
      final comArteQuebrada = OfferBenefit.asset(
        'assets/premium/icon_orb.png',
        rotulo,
        reserva: Icons.psychology,
      );
      final soIcone =
          OfferBenefit.icon(Icons.psychology, rotulo, highlighted: false);

      // Center para a linha medir o próprio conteúdo: o corpo do Scaffold
      // entrega altura apertada, e aí as duas variantes mediriam a tela
      // inteira — a comparação não provaria nada.
      await tester.pumpWidget(app(Center(
        child: SizedBox(
            width: 320, child: OfferBenefitRow(benefit: comArteQuebrada)),
      )));

      final arte = tester.widget<Image>(find.descendant(
        of: find.byType(OfferBenefitRow),
        matching: find.byType(Image),
      ));
      expect(arte.errorBuilder, isNotNull);
      final reserva = arte.errorBuilder!(
          tester.element(find.byType(OfferBenefitRow)), 'rede caiu', null);
      expect(
        reserva,
        isA<Icon>().having((i) => i.icon, 'ícone', Icons.psychology),
        reason: 'sem a arte, a peça precisa continuar dizendo o que vende',
      );
      final alturaComArte = tester.getSize(find.byType(OfferBenefitRow)).height;

      // A MESMA linha sem arte nenhuma: o círculo de 44 é do Container, não
      // do que vem dentro dele, então a lista não muda de altura quando um
      // PNG não chega.
      await tester.pumpWidget(app(Center(
        child: SizedBox(width: 320, child: OfferBenefitRow(benefit: soIcone)),
      )));
      expect(tester.getSize(find.byType(OfferBenefitRow)).height, alturaComArte,
          reason: 'a lista de benefícios muda de altura quando um PNG falha');
    });

    testWidgets('o selo de garantia guarda o mesmo quadrado de 14',
        (tester) async {
      await tester.pumpWidget(app(const Center(child: GuaranteeBadges())));

      final selos = tester
          .widgetList<Image>(find.descendant(
            of: find.byType(GuaranteeBadges),
            matching: find.byType(Image),
          ))
          .toList();
      expect(selos, hasLength(2));
      for (final selo in selos) {
        expect(selo.errorBuilder, isNotNull);
        expect(selo.width, 14);
        expect(selo.height, 14);
      }

      final reserva = selos.first.errorBuilder!(
          tester.element(find.byType(GuaranteeBadges)), 'rede caiu', null);
      await tester.pumpWidget(app(Center(child: reserva)));
      expect(tester.getSize(find.byType(Icon)), const Size(14, 14),
          reason: 'selo maior ou menor que o PNG rearranja o Wrap');
    });

    testWidgets('o cartão de compartilhar assina com um livro quando o ícone '
        'do app não carrega', (tester) async {
      await tester.pumpWidget(app(const ShareCard(child: Text('afirmação'))));

      final marca = tester.widget<Image>(find.descendant(
        of: find.byType(ShareCard),
        matching: find.byType(Image),
      ));
      expect(marca.errorBuilder, isNotNull,
          reason: 'o X cinza aqui seria publicado junto com o cartão');

      final reserva = marca.errorBuilder!(
          tester.element(find.byType(ShareCard)), 'rede caiu', null);
      await tester.pumpWidget(app(Center(child: reserva)));
      expect(find.byIcon(Icons.auto_stories), findsOneWidget);
      expect(tester.getSize(find.byIcon(Icons.auto_stories)),
          const Size(22, 22));
    });
  });
}
