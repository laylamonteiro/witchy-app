import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/widgets/loading_widget.dart';

/// O loader oficial do Grimório — lua crescente com estrelinhas em vez do
/// spinner genérico.
///
/// Os contratos que ele guarda: a API antiga (`message` opcional, texto
/// embaixo) continua valendo para as seis telas que o usam; o desenho é
/// decorativo e não vira ruído no leitor de tela; e, acima de tudo, o laço
/// das estrelas PARA sob "reduzir movimento" — um loop que ignorasse a
/// preferência prenderia qualquer pumpAndSettle da suíte para sempre.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget tela(Widget child, {bool reduzirMovimento = false}) => MaterialApp(
        home: Builder(
          // `copyWith` a partir do context, e não um MediaQueryData cru: um
          // cru zeraria o tamanho da tela e o layout inteiro viraria zero.
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(disableAnimations: reduzirMovimento),
            child: Scaffold(body: child),
          ),
        ),
      );

  testWidgets('com mensagem: lua no alto, texto embaixo, desenho mudo',
      (tester) async {
    await tester.pumpWidget(
      tela(const LoadingWidget(message: 'Preparando o caldeirão...')),
    );
    // As estrelas piscam em laço: nada de pumpAndSettle aqui — só quadros
    // contados.
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Preparando o caldeirão...'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(LoadingWidget),
        matching: find.byType(CustomPaint),
      ),
      findsWidgets,
      reason: 'a lua e as estrelas são pintadas, não spinner do Material',
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // O desenho é enfeite; quem fala com o leitor de tela é a mensagem.
    expect(
      find.descendant(
        of: find.byType(LoadingWidget),
        matching: find.byType(ExcludeSemantics),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('sem mensagem: nenhum texto e nenhum rótulo hardcoded',
      (tester) async {
    // Sem mensagem, o loader fica mudo de propósito (paridade com o spinner
    // antigo): um rótulo fixo seria português hardcoded nas telas EN/ES.
    await tester.pumpWidget(tela(const LoadingWidget()));
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.descendant(
        of: find.byType(LoadingWidget),
        matching: find.byType(Text),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('com "reduzir movimento" a tela assenta — nada anima em laço',
      (tester) async {
    // Este é o teste que prova o congelamento: `pumpAndSettle` espera os
    // quadros PARAREM. Se as estrelas continuassem em laço com a
    // acessibilidade ligada, ele estouraria o tempo e falharia aqui.
    await tester.pumpWidget(
      tela(
        const LoadingWidget(message: 'Consultando os astros...'),
        reduzirMovimento: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Consultando os astros...'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(LoadingWidget),
        matching: find.byType(CustomPaint),
      ),
      findsWidgets,
      reason: 'congelado, não invisível: lua e estrelas seguem na tela',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('desmontar no meio do ciclo não deixa nada pendente',
      (tester) async {
    await tester.pumpWidget(tela(const LoadingWidget(message: 'Carregando')));
    await tester.pump(const Duration(milliseconds: 300));

    // A troca de tela dispõe o controller; se algo sobrevivesse, o binding
    // acusaria ticker vivo ao fim do teste.
    await tester.pumpWidget(tela(const SizedBox.shrink()));
    await tester.pump();

    expect(find.byType(LoadingWidget), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
