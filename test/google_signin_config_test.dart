import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/config/google_signin_config.dart';

/// A entrada com o Google dentro da página é OPCIONAL: sem a chave no build,
/// o app tem que seguir no redirecionamento de sempre. Este teste existe
/// porque o contrário seria invisível — um build sem a chave que tentasse o
/// caminho novo simplesmente não logaria ninguém, sem erro na tela.
void main() {
  test('sem a chave no build, o caminho novo fica desligado', () {
    // Os testes rodam sem `--dart-define`, então esta é a situação real de
    // um build que não recebeu o segredo.
    expect(GoogleSignInConfig.webClientId, isEmpty);
    expect(GoogleSignInConfig.isConfigured, isFalse);
  });

  test('a espera é curta o bastante para não parecer travamento', () {
    // Seis segundos é o tempo de a janelinha do Google aparecer numa rede
    // ruim; mais que isso vira um botão que não responde.
    expect(GoogleSignInConfig.limite.inSeconds, lessThanOrEqualTo(8));
    expect(GoogleSignInConfig.limite.inSeconds, greaterThanOrEqualTo(3));
  });

  group('origem autorizada', () {
    test('produção e staging podem tentar', () {
      expect(GoogleSignInConfig.origemAutorizada('grimoriodebolso.app'), isTrue);
      expect(
        GoogleSignInConfig.origemAutorizada('staging.grimorio-de-bolso.pages.dev'),
        isTrue,
      );
    });

    test('o endereço de deploy da Cloudflare fica de fora', () {
      // O caso que atrapalhou de verdade: o endereço próprio de cada
      // publicação, que muda a cada build e nunca poderá estar no painel.
      expect(
        GoogleSignInConfig.origemAutorizada('47a8ec37.grimorio-de-bolso.pages.dev'),
        isFalse,
      );
    });

    test('a prévia com nome de branch também fica de fora', () {
      // Esta é a que a conferência anterior deixava passar: sem oito
      // hexadecimais na frente, o RegExp não a reconhecia, e o login batia
      // numa tela de "Access blocked: origin_mismatch".
      expect(
        GoogleSignInConfig.origemAutorizada(
            'claude-ciclos-de-vida-featur.grimorio-de-bolso.pages.dev'),
        isFalse,
      );
    });

    test('não basta terminar com o domínio do projeto', () {
      // Aceitar por sufixo autorizaria todas as prévias de uma vez — o
      // oposto do que o Google faz, que é lista exata.
      expect(
        GoogleSignInConfig.origemAutorizada('grimorio-de-bolso.pages.dev'),
        isFalse,
      );
      expect(
        GoogleSignInConfig.origemAutorizada('mal.grimoriodebolso.app'),
        isFalse,
      );
    });

    test('maiúscula no endereço não muda a resposta', () {
      // Hostname é insensível a caixa no navegador; a lista, não seria.
      expect(GoogleSignInConfig.origemAutorizada('GrimorioDeBolso.app'), isTrue);
    });
  });
}
