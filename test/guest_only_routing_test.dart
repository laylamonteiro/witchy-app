import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/user_model.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/pages/auth_wrapper.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';

/// Na web o voltar caminha pelo HISTÓRICO do navegador, e o histórico guarda
/// a URL de antes do login. Sem o [GuestOnly], voltar depois de entrar
/// reabria `#/login` por cima de uma sessão viva — a pessoa não era
/// deslogada, mas via a porta de entrada de novo, o que é a mesma coisa aos
/// olhos dela.
///
/// Este teste não monta as telas reais: monta o ROTEAMENTO, que é onde o
/// defeito vivia.
class _AuthLogada extends AuthProvider {
  @override
  bool get isInitialized => true;

  @override
  UserModel get currentUser => UserModel.defaultUser().copyWith(
        email: 'bruxa@exemplo.com',
      );
}

class _AuthDeslogada extends AuthProvider {
  @override
  bool get isInitialized => true;

  @override
  UserModel get currentUser => UserModel.defaultUser();
}

Widget _app(AuthProvider auth) {
  return ChangeNotifierProvider<AuthProvider>.value(
    value: auth,
    child: MaterialApp(
      initialRoute: '/login',
      routes: {
        '/login': (_) => const GuestOnly(child: Text('PORTA DE ENTRADA')),
        '/home': (_) => const Text('APP'),
      },
    ),
  );
}

void main() {
  testWidgets('com sessão viva, a rota de entrada leva ao app', (tester) async {
    await tester.pumpWidget(_app(_AuthLogada()));
    await tester.pumpAndSettle();

    expect(find.text('PORTA DE ENTRADA'), findsNothing);
    expect(find.text('APP'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sem sessão, a rota de entrada abre normalmente', (tester) async {
    await tester.pumpWidget(_app(_AuthDeslogada()));
    await tester.pumpAndSettle();

    expect(find.text('PORTA DE ENTRADA'), findsOneWidget);
    expect(find.text('APP'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a troca limpa a pilha: não sobra rota de entrada para voltar',
      (tester) async {
    await tester.pumpWidget(_app(_AuthLogada()));
    await tester.pumpAndSettle();

    // Sem isto, o endereço continuaria dizendo `#/login` e o voltar seguinte
    // cairia no mesmo susto.
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
  });
}
