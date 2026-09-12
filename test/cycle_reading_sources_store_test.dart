import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/data/cycle_reading_sources_store.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/data/services/cycle_reading_composer.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// O painel "o que vai para a análise" vivia só no State da tela: sair da
/// Leitura do Ciclo religava as quatro chaves, e na visita seguinte a pessoa
/// podia gerar a leitura com os sonhos dentro sem nunca ter dito que sim de
/// novo. Estes testes travam a entrega — um "não" que se desfaz sozinho não
/// é um "não".
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const store = CycleReadingSourcesStore();

  test('quem nunca mexeu abre com tudo ligado', () async {
    SharedPreferences.setMockInitialValues({});

    final fontes = await store.load('she');

    expect(fontes.includeDreams, isTrue);
    expect(fontes.includeJournals, isTrue);
    expect(fontes.includeDivination, isTrue);
    expect(fontes.includePractice, isTrue);
  });

  test('o que ela desligou continua desligado na volta', () async {
    SharedPreferences.setMockInitialValues({});

    await store.save(
      'she',
      const CycleReadingSourceOptions(
        includeDreams: false,
        includeDivination: false,
      ),
    );
    final fontes = await store.load('she');

    expect(fontes.includeDreams, isFalse,
        reason: 'Os sonhos ficaram de fora e têm de continuar de fora');
    expect(fontes.includeDivination, isFalse);
    // O que ela não tocou segue como estava: guardar uma escolha não é
    // desligar o resto junto.
    expect(fontes.includeJournals, isTrue);
    expect(fontes.includePractice, isTrue);
  });

  test('religar volta a valer, e o sim é tão guardado quanto o não',
      () async {
    SharedPreferences.setMockInitialValues({});

    await store.save(
        'she', const CycleReadingSourceOptions(includeDreams: false));
    await store.save('she', const CycleReadingSourceOptions());

    expect((await store.load('she')).includeDreams, isTrue);
  });

  test('a escolha é de cada conta, não do aparelho', () async {
    SharedPreferences.setMockInitialValues({});

    await store.save(
        'she', const CycleReadingSourceOptions(includePractice: false));

    expect((await store.load('she')).includePractice, isFalse);
    expect((await store.load('outra')).includePractice, isTrue,
        reason: 'A conta ao lado nunca disse nada sobre a prática dela');
  });
}
