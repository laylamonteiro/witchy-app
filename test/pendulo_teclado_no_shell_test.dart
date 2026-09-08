import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/divination/presentation/pages/pendulum_page.dart';
import 'package:grimorio_de_bolso/features/your_day/presentation/providers/daily_checkin_provider.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// No Android o teclado do Pêndulo abria e sumia sozinho. O teste que já
// existia (pendulo_pergunta_test.dart) passava porque não tinha NENHUM dos
// três ingredientes do defeito:
//
//   1. o sensor vivo — lá o stream é vazio, então a mola nunca se move e o
//      caminho de quadro a quadro nunca roda;
//   2. o teclado — `viewInsets` nunca muda no `flutter test`, e é a mudança
//      dele que reconstrói quem lê o MediaQuery sem aspecto;
//   3. o shell — a página era montada sozinha, sem o Scaffold da Home por
//      cima, que é quem reconstruía a cada quadro do teclado abrindo.
//
// Aqui os três estão presentes ao mesmo tempo.
class _AuthDeTeste extends AuthProvider {
  @override
  bool get canUsePendulum => true;

  @override
  int get remainingPendulumUses => 3;

  @override
  Future<void> incrementPendulumUses() async {}
}

class _CheckinFake extends DailyCheckinProvider {
  @override
  bool get isLoaded => true;

  @override
  bool isRiteDone(String riteId) => false;

  @override
  Future<void> completeRite(String riteId) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfiNoIsolate;

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('grimorio_pendulo_shell');
    await databaseFactory.setDatabasesPath(dir.path);
    await DatabaseHelper.instance.database;
  });

  setUp(() => SharedPreferences.setMockInitialValues({}));

  bool campoFocado(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus;

  testWidgets('com o teclado aberto e o sensor vivo, o campo não perde o foco',
      (tester) async {
    final sensor = StreamController<AccelerometerEvent>.broadcast();
    addTearDown(sensor.close);

    // O shell: um Scaffold com barra inferior por fora, como a Home de
    // verdade, e um widget que lê o tamanho da tela — era o `MediaQuery.of`
    // sem aspecto daí que reconstruía tudo a cada quadro do teclado.
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => _AuthDeTeste()),
        ChangeNotifierProvider<DailyCheckinProvider>(
          create: (_) => _CheckinFake(),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          bottomNavigationBar: const SizedBox(height: 56),
          body: Builder(
            builder: (context) {
              // A leitura que a Home faz para posicionar o mascote.
              final largura = MediaQuery.sizeOf(context).width;
              return SizedBox(
                width: largura,
                child: PendulumPage(acelerometro: () => sensor.stream),
              );
            },
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(campoFocado(tester), isTrue);
    expect(tester.testTextInput.hasAnyClients, isTrue);

    // O teclado sobe: no aparelho isso é uma animação, e cada quadro dela
    // muda o `viewInsets`.
    for (var altura = 60.0; altura <= 600; altura += 60) {
      tester.view.viewInsets = FakeViewPadding(bottom: altura);
      addTearDown(tester.view.resetViewInsets);
      sensor.add(AccelerometerEvent(0.4, 9.6, 0.2, DateTime.now()));
      await tester.pump(const Duration(milliseconds: 16));
      expect(campoFocado(tester), isTrue,
          reason: 'o campo perdeu o foco com o teclado em $altura px');
      expect(tester.testTextInput.hasAnyClients, isTrue,
          reason: 'o teclado fechou sozinho com $altura px');
    }

    // E continua dando para escrever.
    await tester.enterText(find.byType(TextField), 'Vou conseguir?');
    await tester.pump();
    expect(find.text('Vou conseguir?'), findsOneWidget);
    expect(campoFocado(tester), isTrue);
  });
}
