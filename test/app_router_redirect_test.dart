import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/navigation/app_router.dart';

/// A regra de rota do app (o que era `RequireAuth`/`GuestOnly` + os ramos
/// transitórios do antigo `AuthWrapper`) agora é a função pura
/// [decidirRedirect]. Estes testes guardam a decisão sem montar a árvore.
String? _r({
  required String local,
  bool inicializada = true,
  bool logada = false,
  bool oauthPendente = false,
  bool naJanelaDeLogin = false,
  bool voltaOAuthPronta = false,
}) =>
    decidirRedirect(
      local: local,
      inicializada: inicializada,
      logada: logada,
      oauthPendente: oauthPendente,
      naJanelaDeLogin: naJanelaDeLogin,
      voltaOAuthPronta: voltaOAuthPronta,
    );

void main() {
  group('enquanto a sessão não foi lida do disco', () {
    test('qualquer rota vai para /carregando', () {
      expect(_r(local: '/seu-dia', inicializada: false), '/carregando');
      expect(_r(local: '/welcome', inicializada: false), '/carregando');
    });
    test('/carregando fica onde está (sem laço)', () {
      expect(_r(local: '/carregando', inicializada: false), isNull);
    });
  });

  group('sem sessão', () {
    test('as telas de entrada abrem normalmente', () {
      expect(_r(local: '/welcome'), isNull);
      expect(_r(local: '/login'), isNull);
      expect(_r(local: '/signup'), isNull);
    });
    test('qualquer rota de conteúdo vira boas-vindas', () {
      expect(_r(local: '/seu-dia'), '/welcome');
      expect(_r(local: '/enciclopedia'), '/welcome');
      expect(_r(local: '/grimorio'), '/welcome');
    });
  });

  group('com sessão', () {
    test('a raiz, as telas de entrada e os gates passam pelo PISO (/inicio)', () {
      // O piso monta e empurra /seu-dia por cima, para o voltar no Seu Dia cair
      // nele em vez de sair do app.
      expect(_r(local: '/', logada: true), '/inicio');
      expect(_r(local: '/welcome', logada: true), '/inicio');
      expect(_r(local: '/login', logada: true), '/inicio');
      expect(_r(local: '/signup', logada: true), '/inicio');
      expect(_r(local: '/carregando', logada: true), '/inicio');
      expect(_r(local: '/entrando', logada: true), '/inicio');
    });
    test('o piso monta (não é redirecionado) e as rotas de conteúdo passam', () {
      expect(_r(local: '/inicio', logada: true), isNull);
      expect(_r(local: '/seu-dia', logada: true), isNull);
      expect(_r(local: '/enciclopedia', logada: true), isNull);
      expect(_r(local: '/grimorio', logada: true), isNull);
      expect(_r(local: '/diarios', logada: true), isNull);
    });
    test('sem laço: /inicio → (piso empurra) /seu-dia → passa', () {
      // Se /inicio quicasse para /seu-dia, o piso nunca montaria; se /seu-dia
      // voltasse ao piso, laço. Nenhum dos dois.
      expect(_r(local: '/inicio', logada: true), isNull);
      expect(_r(local: '/seu-dia', logada: true), isNull);
    });
  });

  group('estados transitórios da volta do login social', () {
    test('troca do código em voo (sem sessão ainda) → /entrando', () {
      expect(_r(local: '/seu-dia', oauthPendente: true), '/entrando');
      expect(_r(local: '/welcome', oauthPendente: true), '/entrando');
    });
    test('/entrando fica onde está (sem laço)', () {
      expect(_r(local: '/entrando', oauthPendente: true), isNull);
    });
    test('janela de login voltando do Google (com sessão) → /entrando', () {
      expect(_r(local: '/seu-dia', logada: true, naJanelaDeLogin: true),
          '/entrando');
    });
    test('sessão do OAuth pronta (com sessão) → /entrando', () {
      expect(_r(local: '/seu-dia', logada: true, voltaOAuthPronta: true),
          '/entrando');
    });
  });

  group('recuperação de senha', () {
    test('passa sempre — tem token na URL e sessão própria', () {
      expect(_r(local: '/recuperar-senha'), isNull);
      expect(_r(local: '/recuperar-senha', inicializada: false), isNull);
      expect(_r(local: '/recuperar-senha', logada: true), isNull);
    });
  });
}
