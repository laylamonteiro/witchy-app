import 'package:flutter_test/flutter_test.dart';

/// Encurta o limite por teste deste arquivo.
///
/// O padrão do `flutter_test` é dez minutos, e `testWidgets` passa esse
/// valor explicitamente — uma anotação `@Timeout` no arquivo não o alcança.
/// Quando um teste falha no meio de uma gravação, o cadeado do SQLite fica
/// preso para os seguintes, e cada um deles espera os dez minutos inteiros:
/// uma falha vira meia hora de CI em vez de uma mensagem legível.
void useShortTestTimeout([Duration limit = const Duration(minutes: 2)]) {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  if (binding is AutomatedTestWidgetsFlutterBinding) {
    binding.defaultTestTimeout = Timeout(limit);
  }
}
