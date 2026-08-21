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
}
