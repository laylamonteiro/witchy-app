import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/widgets/page_dots.dart';
import 'package:grimorio_de_bolso/core/widgets/paged_reading.dart';
import 'package:grimorio_de_bolso/core/widgets/premium_locked_preview.dart';
import 'package:grimorio_de_bolso/core/widgets/staggered_entrance.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/widgets/premium_blur_widget.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

/// Os quatro widgets de núcleo que estavam com cobertura zero.
///
/// Cada um guarda um contrato que já quebrou (ou quase) em silêncio: os
/// pontinhos decorativos fora da árvore de semântica, a paginação que nunca
/// esconde conteúdo, o fail-closed do véu Premium e a cascata que não pode
/// deixar timer pendente nem reanimar a rolagem.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget app(Widget child) => MaterialApp(
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );

  group('PageDots', () {
    testWidgets('uma página só não desenha nada', (tester) async {
      await tester.pumpWidget(app(const PageDots(count: 1, index: 0)));
      expect(find.byType(AnimatedContainer), findsNothing);
    });

    testWidgets('o ponto ativo vira traço; os outros ficam redondos',
        (tester) async {
      await tester.pumpWidget(app(const PageDots(count: 4, index: 1)));
      await tester.pumpAndSettle();

      final pontos = find.byType(AnimatedContainer);
      expect(pontos, findsNWidgets(4));
      expect(tester.getSize(pontos.at(1)).width, 18);
      expect(tester.getSize(pontos.at(0)).width, 6);
      expect(tester.getSize(pontos.at(2)).width, 6);
    });

    testWidgets('com onTap, tocar num ponto pede aquela página',
        (tester) async {
      int? tocada;
      await tester.pumpWidget(app(
        PageDots(count: 4, index: 0, onTap: (i) => tocada = i),
      ));
      await tester.tap(find.byType(AnimatedContainer).at(2));
      expect(tocada, 2);
    });

    testWidgets('sem onTap, os pontos saem da árvore de semântica',
        (tester) async {
      // Decorativos: um leitor de tela não tem o que fazer com eles. O
      // escopo é o próprio PageDots — a rota do MaterialApp tem widgets de
      // semântica dela acima de tudo.
      await tester.pumpWidget(app(const PageDots(count: 3, index: 0)));
      final exclusao = find.descendant(
        of: find.byType(PageDots),
        matching: find.byType(ExcludeSemantics),
      );
      expect(exclusao, findsOneWidget);
      expect(
        find.descendant(
          of: exclusao,
          matching: find.byType(AnimatedContainer),
        ),
        findsNWidgets(3),
      );
    });
  });

  group('PagedReading', () {
    testWidgets('sem páginas não desenha nada', (tester) async {
      await tester.pumpWidget(app(
        const SizedBox(height: 400, child: PagedReading(pages: [])),
      ));
      expect(find.byType(PageView), findsNothing);
    });

    testWidgets('tocar num pontinho leva àquela página e avisa quem pediu',
        (tester) async {
      final visitadas = <int>[];
      await tester.pumpWidget(app(SizedBox(
        height: 400,
        child: PagedReading(
          onPageChanged: visitadas.add,
          pages: const [
            Text('Página um'),
            Text('Página dois'),
            Text('Página três'),
          ],
        ),
      )));

      expect(find.text('Página um'), findsOneWidget);

      await tester.tap(find.byType(AnimatedContainer).at(2));
      await tester.pumpAndSettle();

      expect(find.text('Página três'), findsOneWidget);
      expect(visitadas, contains(2));
    });

    testWidgets('página comprida rola sozinha — a paginação nunca esconde '
        'conteúdo', (tester) async {
      await tester.pumpWidget(app(SizedBox(
        height: 300,
        child: PagedReading(
          pages: [
            Column(
              children: [
                const Text('Topo da página'),
                const SizedBox(height: 900),
                const Text('Fim da página'),
              ],
            ),
          ],
        ),
      )));

      expect(find.text('Fim da página', skipOffstage: false), findsOneWidget);
      await tester.dragUntilVisible(
        find.text('Fim da página'),
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      expect(find.text('Fim da página'), findsOneWidget);
    });
  });

  group('PremiumLockedPreview', () {
    testWidgets('mostra um cadeado e um título por seção, e o convite',
        (tester) async {
      var convites = 0;
      await tester.pumpWidget(app(SingleChildScrollView(
        child: PremiumLockedPreview(
          titles: const ['Essência', 'Intuição', 'Sombra'],
          ctaLabel: 'Abrir a leitura',
          onCta: () => convites++,
        ),
      )));

      expect(find.byIcon(Icons.lock), findsNWidgets(3));
      expect(find.text('Essência'), findsOneWidget);
      expect(find.text('Sombra'), findsOneWidget);

      await tester.tap(find.text('Abrir a leitura'));
      expect(convites, 1);
    });

    testWidgets('sob o véu vai o placeholder, nunca conteúdo real — e fora '
        'da semântica', (tester) async {
      // Fail-closed: blur é cosmético. O que um leitor de tela (ou um
      // print) alcançaria é texto de enfeite, porque o conteúdo verdadeiro
      // nem chega a ser gerado para quem não tem acesso.
      await tester.pumpWidget(app(SingleChildScrollView(
        child: PremiumLockedPreview(
          titles: const ['Essência'],
          ctaLabel: 'Abrir',
          onCta: () {},
        ),
      )));

      final veu = find.text(kPremiumPlaceholderText, skipOffstage: false);
      expect(veu, findsOneWidget);

      // O escopo é o próprio widget — e sem contar ExcludeSemantics: o
      // botão do Material traz os dele. O contrato é que o PLACEHOLDER
      // esteja sob exclusão de semântica e sob o embaçado.
      final exclusoesDoPreview = find.descendant(
        of: find.byType(PremiumLockedPreview),
        matching: find.byType(ExcludeSemantics),
      );
      expect(
        find.descendant(of: exclusoesDoPreview, matching: veu),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: exclusoesDoPreview,
          matching: find.byType(ImageFiltered),
        ),
        findsOneWidget,
      );
    });
  });

  group('StaggeredEntrance', () {
    testWidgets('todos os filhos estão na árvore desde o primeiro quadro, e '
        'só os primeiros animam', (tester) async {
      await tester.pumpWidget(app(SingleChildScrollView(
        child: StaggeredEntrance(
          children: [for (var i = 0; i < 8; i++) Text('Item $i')],
        ),
      )));

      // Nada some enquanto a animação corre: os 8 existem já no início.
      for (var i = 0; i < 8; i++) {
        expect(find.text('Item $i', skipOffstage: false), findsOneWidget);
      }
      // Só os 6 primeiros ganham entrada animada (abaixo da dobra ninguém vê).
      expect(
        find.descendant(
          of: find.byType(StaggeredEntrance),
          matching: find.byType(FadeTransition),
        ),
        findsNWidgets(6),
      );

      await tester.pumpAndSettle();
      final primeira = tester.widget<FadeTransition>(
        find
            .descendant(
              of: find.byType(StaggeredEntrance),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(primeira.opacity.value, 1.0,
          reason: 'terminada a entrada, tudo fica plenamente visível');
    });

    testWidgets('desmontar no meio da cascata não deixa timer pendente',
        (tester) async {
      // O atraso de cada filho é um Timer; um timer solto depois do dispose
      // é exatamente o que derruba um teste de widget ("A Timer is still
      // pending"). Trocar a árvore no meio da espera prova o cancelamento.
      await tester.pumpWidget(app(StaggeredEntrance(
        children: const [Text('a'), Text('b'), Text('c')],
      )));
      await tester.pump(const Duration(milliseconds: 30));
      await tester.pumpWidget(app(const SizedBox.shrink()));
      await tester.pumpAndSettle();
      expect(find.text('a'), findsNothing);
    });

    testWidgets('CascadeIn respeita a dobra e o desligar de animações',
        (tester) async {
      // O escopo é o próprio CascadeIn: a rota do MaterialApp tem
      // FadeTransitions dela acima de TUDO, então procurar por ancestral
      // acha animação mesmo onde não existe nenhuma nossa.
      Finder entradaDo(int posicao) => find.descendant(
            of: find.byType(CascadeIn).at(posicao),
            matching: find.byType(FadeTransition),
          );

      await tester.pumpWidget(app(Column(
        children: const [
          CascadeIn(index: 0, child: Text('animado')),
          CascadeIn(index: 9, child: Text('abaixo da dobra')),
        ],
      )));

      expect(entradaDo(0), findsOneWidget);
      expect(entradaDo(1), findsNothing,
          reason: 'abaixo da dobra ninguém vê a animação');
      await tester.pumpAndSettle();

      // Com as animações desligadas no sistema, ninguém anima.
      await tester.pumpWidget(app(MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Column(
          children: const [CascadeIn(index: 0, child: Text('parado'))],
        ),
      )));
      expect(entradaDo(0), findsNothing);
    });

    testWidgets('CascadeScope: item que monta muito depois entra parado',
        (tester) async {
      // O escopo marca o nascimento da lista; quem monta ~900ms depois (a
      // rolagem voltando ao topo) não repete o show. O relógio aqui é o de
      // verdade — DateTime.now() — então a espera usa runAsync.
      final mostrarTardio = ValueNotifier<bool>(false);
      await tester.pumpWidget(app(CascadeScope(
        child: ValueListenableBuilder<bool>(
          valueListenable: mostrarTardio,
          builder: (_, tardio, __) => Column(
            children: [
              const CascadeIn(index: 0, child: Text('nascido junto')),
              if (tardio) const CascadeIn(index: 1, child: Text('tardio')),
            ],
          ),
        ),
      )));
      await tester.pumpAndSettle();

      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 950)),
      );
      mostrarTardio.value = true;
      await tester.pump();

      expect(find.text('tardio'), findsOneWidget);
      expect(
        // Dentro do CascadeIn tardio (o segundo): nenhuma entrada animada.
        // O escopo importa — as FadeTransitions da rota estão sempre acima.
        find.descendant(
          of: find.byType(CascadeIn).at(1),
          matching: find.byType(FadeTransition),
        ),
        findsNothing,
        reason: 'fora da janela de nascimento, a entrada é sem show',
      );
      await tester.pumpAndSettle();
    });
  });
}
