/// Afrouxamentos que valem SÓ em build de teste.
///
/// Cada flag é `bool.fromEnvironment`, ou seja, **constante de compilação**:
/// sem o `--dart-define` correspondente ela é `false` e o compilador remove
/// o caminho solto na árvore. Uma build de produção que não passe o define
/// não tem como ficar frouxa por engano.
///
/// De propósito NÃO usa `kDebugMode`: `flutter test` roda em debug, e os
/// testes precisam exercitar os limites REAIS do produto. Para afrouxar no
/// desenvolvimento local, passe o define na mão:
///
/// ```
/// flutter run --dart-define=UNLIMITED_CYCLE_READINGS=true
/// ```
abstract final class TestBuildConfig {
  const TestBuildConfig._();

  /// Derruba o intervalo entre Leituras do Ciclo e o teto de regerações.
  ///
  /// Existe para quem testa o app não precisar esperar 7 ou 30 dias entre
  /// uma leitura e outra. NÃO libera a compra: o crédito continua sendo
  /// exigido, porque quem testa usa conta Vitalícia ou de admin.
  ///
  /// O APK candidato do `branch-validate.yml` passa este define; o
  /// `release.yml` nunca passa.
  static const bool unlimitedCycleReadings =
      bool.fromEnvironment('UNLIMITED_CYCLE_READINGS');
}
