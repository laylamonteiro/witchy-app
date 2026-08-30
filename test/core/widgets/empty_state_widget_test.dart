import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/widgets/empty_state_widget.dart';

/// Contratos do estado vazio ilustrado.
///
/// O que já quebrou (ou quebraria) em silêncio por aqui: um loop ambiente
/// que não congela sob "reduzir movimento" trava o pumpAndSettle da suíte
/// inteira; a ilustração fora de ExcludeSemantics vira ruído no leitor de
/// tela; e o formato antigo (só `icon`) precisa seguir de pé para qualquer
/// chamador não migrado.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const ilustracao = ValueKey('empty_state_illustration');

  Widget app(Widget child, {bool disableAnimations = false}) => MaterialApp(
        home: Scaffold(
          body: disableAnimations
              // Sempre copyWith em cima do MediaQuery real: um MediaQueryData
              // cru zera o tamanho da tela e derruba o layout.
              ? Builder(
                  builder: (context) => MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(disableAnimations: true),
                    child: child,
                  ),
                )
              : child,
        ),
      );

  group('variantes ilustradas', () {
    for (final tipo in MagicalEmptyStateType.values) {
      testWidgets('$tipo renderiza com animações ligadas', (tester) async {
        await tester.pumpWidget(app(
          EmptyStateWidget(message: 'nada por aqui', type: tipo),
        ));
        // Loop ambiente ligado: settle nunca terminaria. Quadros contados.
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(seconds: 2));

        expect(find.byKey(ilustracao), findsOneWidget);
        expect(find.text('nada por aqui'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('$tipo congela sob disableAnimations', (tester) async {
        await tester.pumpWidget(app(
          EmptyStateWidget(message: 'nada por aqui', type: tipo),
          disableAnimations: true,
        ));
        // Só termina porque o widget parou o próprio loop.
        await tester.pumpAndSettle();

        expect(find.byKey(ilustracao), findsOneWidget);
        expect(find.text('nada por aqui'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('ilustração é decorativa: fica fora da semântica',
        (tester) async {
      await tester.pumpWidget(app(
        const EmptyStateWidget(
          message: 'nada por aqui',
          type: MagicalEmptyStateType.generic,
        ),
        disableAnimations: true,
      ));
      await tester.pumpAndSettle();

      expect(
        find.ancestor(
          of: find.byKey(ilustracao),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
    });
  });

  group('botão de ação', () {
    testWidgets('continua clicável com animações ligadas', (tester) async {
      var chamadas = 0;
      await tester.pumpWidget(app(
        EmptyStateWidget(
          message: 'nada por aqui',
          type: MagicalEmptyStateType.gratitude,
          actionText: 'Adicionar',
          onAction: () => chamadas++,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('Adicionar'));
      expect(chamadas, 1);
    });

    testWidgets('continua clicável sob disableAnimations', (tester) async {
      var chamadas = 0;
      await tester.pumpWidget(app(
        EmptyStateWidget(
          message: 'nada por aqui',
          type: MagicalEmptyStateType.search,
          actionText: 'Adicionar',
          onAction: () => chamadas++,
        ),
        disableAnimations: true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Adicionar'));
      expect(chamadas, 1);
    });
  });

  group('compatibilidade com o formato antigo', () {
    testWidgets('só icon: mostra o ícone, sem ilustração', (tester) async {
      await tester.pumpWidget(app(
        const EmptyStateWidget(
          message: 'nada por aqui',
          icon: Icons.favorite,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byKey(ilustracao), findsNothing);
      expect(find.text('nada por aqui'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('só icon com ação: botão segue funcionando', (tester) async {
      var chamadas = 0;
      await tester.pumpWidget(app(
        EmptyStateWidget(
          message: 'nada por aqui',
          icon: Icons.favorite,
          actionText: 'Adicionar',
          onAction: () => chamadas++,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Adicionar'));
      expect(chamadas, 1);
    });

    testWidgets('sem icon e sem type: cai na cena genérica', (tester) async {
      await tester.pumpWidget(app(
        const EmptyStateWidget(message: 'nada por aqui'),
        disableAnimations: true,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(ilustracao), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('desmontar no meio do ciclo não deixa nada pendente',
      (tester) async {
    await tester.pumpWidget(app(
      const EmptyStateWidget(
        message: 'nada por aqui',
        type: MagicalEmptyStateType.dreams,
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.pumpWidget(app(const SizedBox.shrink()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
