// Fora da tela o pêndulo não pode continuar ouvindo o acelerômetro: a rota
// coberta apaga o TickerMode, e é dele que a assinatura depende.
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
import 'support/short_test_timeout.dart';

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
  useShortTestTimeout();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfiNoIsolate;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    final dir = await Directory.systemTemp.createTemp('pendulo_fora_da_tela');
    await databaseFactory.setDatabasesPath(dir.path);
    await DatabaseHelper.instance.database;
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Vários quadros, sem esperar silêncio: o pêndulo balança para sempre, e
  /// a troca de rota só chega ao TickerMode um quadro depois de a transição
  /// terminar — quando o Overlay marca a rota de baixo como fora de cena.
  Future<void> avancar(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets('a rota coberta desliga o acelerômetro, e voltar religa',
      (tester) async {
    final sensor = StreamController<AccelerometerEvent>.broadcast();
    addTearDown(sensor.close);
    final navigator = GlobalKey<NavigatorState>();

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => _AuthDeTeste()),
        ChangeNotifierProvider<DailyCheckinProvider>(create: (_) => _CheckinFake()),
      ],
      child: MaterialApp(
        navigatorKey: navigator,
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PendulumPage(acelerometro: () => sensor.stream),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(sensor.hasListener, isTrue, reason: 'Na tela, o sensor está vivo');

    navigator.currentState!.push(MaterialPageRoute<void>(
      builder: (_) => const Scaffold(body: Center(child: Text('outra tela'))),
    ));
    await tester.pump();
    await avancar(tester);
    expect(find.text('outra tela'), findsOneWidget);
    expect(sensor.hasListener, isFalse,
        reason: 'Coberto, o acelerômetro só gastaria bateria');

    navigator.currentState!.pop();
    await tester.pump();
    await avancar(tester);
    expect(sensor.hasListener, isTrue, reason: 'De volta, volta a ouvir');
    expect(tester.takeException(), isNull);
  });

  testWidgets('com movimento reduzido o sensor nem chega a ser assinado',
      (tester) async {
    final sensor = StreamController<AccelerometerEvent>.broadcast();
    addTearDown(sensor.close);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => _AuthDeTeste()),
        ChangeNotifierProvider<DailyCheckinProvider>(create: (_) => _CheckinFake()),
      ],
      child: MaterialApp(
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: PendulumPage(acelerometro: () => sensor.stream),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(sensor.hasListener, isFalse);
    expect(tester.takeException(), isNull);
  });
}
