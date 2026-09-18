// O cristal passou a girar em vez de ir de um lado para o outro. O que estes
// testes trancam é a diferença entre as duas coisas na TELA — a aritmética da
// projeção se prova em `orbita_do_pendulo_test.dart`.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/divination/presentation/pages/pendulum_page.dart';
import 'package:grimorio_de_bolso/features/your_day/presentation/providers/daily_checkin_provider.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
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
    final dir = await Directory.systemTemp.createTemp('pendulo_orbita');
    await databaseFactory.setDatabasesPath(dir.path);
    await DatabaseHelper.instance.database;
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget app({required bool reduzido}) => MultiProvider(
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
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reduzido),
            child: child!,
          ),
          // Sem plugin de sensor no teste: um stream vazio no lugar dele. Com
          // isso a inclinação fica em zero e o que sobra no ângulo é só a
          // órbita — que é o que se quer medir.
          home: const PendulumPage(acelerometro: Stream.empty),
        ),
      );

  /// O painter é a fonte mais direta: guarda o peso e o ângulo aparente do
  /// quadro, já projetados.
  PendulumPainter painter(WidgetTester tester) => tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .map((c) => c.painter)
      .whereType<PendulumPainter>()
      .first;

  Future<void> montar(WidgetTester tester, {required bool reduzido}) async {
    await tester.pumpWidget(app(reduzido: reduzido));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// A consulta agenda timers (balanço, assentamento) e grava em disco. Largar
  /// a árvore no meio deixa timer pendente e o binding reclama — então toda
  /// consulta iniciada aqui é levada até o fim, como em `pendulo_pergunta_test`.
  Future<void> deixarAConsultaTerminar(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    for (var i = 0; i < 25; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
  }

  Future<void> perguntar(WidgetTester tester) async {
    final l10n = AppLocalizations.of(tester.element(find.byType(PendulumPage)));
    await tester.enterText(find.byType(TextField), 'Vou viajar?');
    await tester.pump();
    // O card da pergunta fica abaixo do pêndulo, fora da dobra do palco de
    // teste: sem rolar até ele, o toque erra o alvo e o Flutter só avisa.
    await tester.ensureVisible(find.text(l10n.pendulumAsk));
    await tester.pump();
    await tester.tap(find.text(l10n.pendulumAsk));
    await tester.pump();
  }

  testWidgets('girando, o peso descreve uma elipse — é órbita, não vaivém',
      (tester) async {
    await montar(tester, reduzido: false);
    final aFio = painter(tester);
    final fixacao = aFio.anchor;
    final corda = (aFio.bob - fixacao).distance;
    await perguntar(tester);

    // Uma volta inteira (1500 ms), amostrada de 50 em 50 ms. A fase de partida
    // é sorteada, então nada aqui pode depender de cair num ponto específico
    // da volta — só do CONJUNTO de pontos visitados.
    var maisPerto = double.infinity, maisLonge = 0.0;
    var maisAlto = double.infinity, maiorDesvioLateral = 0.0;
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      final bob = painter(tester).bob;
      final distancia = (bob - fixacao).distance;
      maisPerto = distancia < maisPerto ? distancia : maisPerto;
      maisLonge = distancia > maisLonge ? distancia : maisLonge;
      maisAlto = bob.dy < maisAlto ? bob.dy : maisAlto;
      final lateral = (bob.dx - fixacao.dx).abs();
      maiorDesvioLateral = lateral > maiorDesvioLateral
          ? lateral
          : maiorDesvioLateral;
    }

    expect(maiorDesvioLateral, greaterThan(40),
        reason: 'o cristal precisa sair do eixo para haver movimento');
    // A assinatura da elipse: num balanço PLANO o peso nunca sai do círculo de
    // raio `corda`, então a distância até a fixação seria constante. Aqui ela
    // encolhe, porque parte da corda aponta para dentro da tela.
    expect(maisLonge - maisPerto, greaterThan(25),
        reason: 'a distância até a fixação tem de variar — é o que distingue '
            'uma elipse de um arco de círculo');
    expect(maisLonge, lessThanOrEqualTo(corda + 0.5),
        reason: 'a corda não estica');
    // E a órbita sobe bem acima do repouso, que é o que o olho lê como fundo.
    expect(maisAlto, lessThan(fixacao.dy + corda - 30));

    await deixarAConsultaTerminar(tester);
  });

  testWidgets('a órbita nunca desce abaixo do repouso', (tester) async {
    await montar(tester, reduzido: false);
    final repouso = painter(tester).bob;
    await perguntar(tester);

    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      // Meio pixel de folga para o arredondamento do ponto flutuante. Sem o
      // encurtamento da corda em perspectiva, a frente da órbita desceria uns
      // 26 px e a ponta do cristal cruzaria o rótulo "Talvez".
      expect(painter(tester).bob.dy, lessThanOrEqualTo(repouso.dy + 0.5));
    }

    await deixarAConsultaTerminar(tester);
  });

  testWidgets('com movimento reduzido o cristal fica reto durante a pausa',
      (tester) async {
    await montar(tester, reduzido: true);
    final repouso = painter(tester).bob;
    await perguntar(tester);

    // Aqui o controller da órbita NUNCA é posto para girar, mas a consulta
    // fica ligada durante os 600 ms de pausa. Sem a guarda de `isAnimating`,
    // o cristal apareceria congelado numa pose de órbita.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      expect(painter(tester).swing, closeTo(0, 1e-9));
      expect(painter(tester).bob.dx, closeTo(repouso.dx, 1e-9));
      expect(painter(tester).bob.dy, closeTo(repouso.dy, 1e-9));
    }

    await deixarAConsultaTerminar(tester);
  });
}
