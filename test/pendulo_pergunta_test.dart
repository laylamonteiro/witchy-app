// O bug: "no pêndulo o teclado não abre no campo da pergunta". A causa era o
// próprio campo, desabilitado enquanto o cristal balançava E depois da
// resposta — desabilitar derruba o foco (o teclado fechava sozinho na
// consulta) e, com a resposta na tela, tocar no campo não fazia nada.
//
// Estes testes provam o contrato novo: o campo abre o teclado, segura o foco
// durante o balanço inteiro, continua vivo depois da resposta, e editar a
// pergunta recomeça a consulta. De quebra, o toque duplo (que gastava duas
// consultas) e a saída no meio do assentamento (que deixava o botão morto).
//
// O banco entra de verdade (sqflite ffi) porque a consulta é gravada: o
// arranjo é o mesmo de salvar_nos_registros_test.dart.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/widgets/magical_card.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/divination/presentation/pages/pendulum_page.dart';
import 'package:grimorio_de_bolso/features/your_day/presentation/providers/daily_checkin_provider.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _AuthDeTeste extends AuthProvider {
  int consultasReservadas = 0;

  @override
  bool get canUsePendulum => true;

  @override
  int get remainingPendulumUses => 3;

  @override
  Future<void> incrementPendulumUses() async {
    consultasReservadas++;
  }
}

class _CheckinFake extends DailyCheckinProvider {
  final Set<String> feitos = {};

  @override
  bool get isLoaded => true;

  @override
  bool isRiteDone(String riteId) => feitos.contains(riteId);

  @override
  Future<void> completeRite(String riteId) async {
    feitos.add(riteId);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfiNoIsolate;

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('grimorio_pendulo');
    await databaseFactory.setDatabasesPath(dir.path);
    await DatabaseHelper.instance.database;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget app(_AuthDeTeste auth) => MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ChangeNotifierProvider<DailyCheckinProvider>(
            create: (_) => _CheckinFake(),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('pt', 'BR'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // Sem plugin de sensor no teste: um stream vazio no lugar dele.
          home: PendulumPage(acelerometro: () => const Stream.empty()),
        ),
      );

  bool campoFocado(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus;

  AppLocalizations l10nDe(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(PendulumPage)));

  /// O cristal dos emblemas anima sem parar, então `pumpAndSettle` nunca
  /// assentaria: os quadros avançam sempre com duração explícita.
  Future<void> montar(WidgetTester tester, _AuthDeTeste auth) async {
    await tester.pumpWidget(app(auth));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Dá tempo REAL ao insert da consulta (I/O de disco não anda no relógio
  /// falso), para a árvore não ser derrubada com a gravação em voo.
  Future<void> deixarAGravacaoTerminar(WidgetTester tester) async {
    for (var i = 0; i < 25; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
  }

  testWidgets(
      'o campo abre o teclado, segura o foco no balanço e segue vivo depois',
      (tester) async {
    final auth = _AuthDeTeste();
    await montar(tester, auth);
    final l10n = l10nDe(tester);

    // O botão "Perguntar" mora DENTRO do card da pergunta.
    final cardDaPergunta = find
        .ancestor(
          of: find.byType(TextField),
          matching: find.byType(MagicalCard),
        )
        .first;
    expect(
      find.descendant(
        of: cardDaPergunta,
        matching: find.text(l10n.pendulumAsk),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(campoFocado(tester), isTrue);
    expect(tester.testTextInput.hasAnyClients, isTrue,
        reason: 'tocar no campo tem de abrir o teclado');

    await tester.enterText(find.byType(TextField), 'Vou viajar em breve?');
    await tester.pump();

    await tester.tap(find.text(l10n.pendulumAsk));
    await tester.pump();
    expect(find.text(l10n.pendulumAsking), findsOneWidget);
    expect(auth.consultasReservadas, 1);

    // ~3 s de balanço + assentamento: o foco e o texto não podem cair.
    for (var i = 0; i < 7; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      expect(campoFocado(tester), isTrue, reason: 'foco caiu no quadro $i');
      expect(tester.testTextInput.hasAnyClients, isTrue,
          reason: 'teclado fechou no quadro $i');
      expect(find.text('Vou viajar em breve?'), findsOneWidget);
    }

    // A resposta chegou e o campo continua editável e focado.
    expect(find.text(l10n.pendulumNewConsult), findsOneWidget);
    expect(find.text(l10n.pendulumAsk), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled,
        isNot(false));
    expect(campoFocado(tester), isTrue);

    // Editar a pergunta depois da resposta recomeça a consulta.
    await tester.enterText(find.byType(TextField), 'E no mês que vem?');
    await tester.pump();
    expect(find.text(l10n.pendulumNewConsult), findsNothing);
    expect(find.text(l10n.pendulumAsk), findsOneWidget);
    expect(campoFocado(tester), isTrue);

    await deixarAGravacaoTerminar(tester);
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('dois toques no mesmo instante reservam UMA consulta',
      (tester) async {
    final auth = _AuthDeTeste();
    await montar(tester, auth);
    final l10n = l10nDe(tester);

    await tester.enterText(find.byType(TextField), 'Devo aceitar?');
    await tester.pump();

    await tester.tap(find.text(l10n.pendulumAsk));
    await tester.tap(find.text(l10n.pendulumAsk), warnIfMissed: false);
    await tester.pump();

    expect(auth.consultasReservadas, 1);

    await tester.pump(const Duration(seconds: 4));
    await deixarAGravacaoTerminar(tester);
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('sair da tela no meio do assentamento não deixa exceção',
      (tester) async {
    final auth = _AuthDeTeste();
    await montar(tester, auth);
    final l10n = l10nDe(tester);

    await tester.enterText(find.byType(TextField), 'Vai dar certo?');
    await tester.pump();
    await tester.tap(find.text(l10n.pendulumAsk));
    // 2350 ms de balanço já passaram; o assentamento (650 ms) está em curso.
    await tester.pump(const Duration(milliseconds: 2500));

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));

    expect(tester.takeException(), isNull);
  });
}
