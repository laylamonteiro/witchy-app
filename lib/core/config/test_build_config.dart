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

  /// HOJE NÃO GOVERNA NADA — e isso é bom.
  ///
  /// Nasceu para derrubar duas travas da Leitura do Ciclo em build de teste: a
  /// espera de 7/30 dias entre uma leitura e outra, e o teto de 2 regerações
  /// da mesma janela. As duas deixaram de existir para todo mundo — a espera
  /// primeiro (ver `CycleReadingService.inviteBackAfter`, que hoje é só o
  /// ritmo do lembrete), o teto em 24/08 (ver `CycleReadingModel.canRegenerate`).
  ///
  /// Fica de pé porque o `branch-validate.yml` ainda passa o define nos dois
  /// builds, e porque é o lugar pronto para o próximo afrouxamento que
  /// alguém precisar. Não apague sem tirar o `--dart-define` de lá junto.
  static const bool unlimitedCycleReadings =
      bool.fromEnvironment('UNLIMITED_CYCLE_READINGS');
}
