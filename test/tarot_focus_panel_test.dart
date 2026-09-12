// Um teste que falha no meio de uma gravação deixa o cadeado do SQLite
// preso para os seguintes: o limite por teste evita que isso vire dezenas
// de minutos de CI em vez de uma falha legível.
@Timeout(Duration(minutes: 2))
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/reading_session_schema.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/divination/presentation/widgets/card_selection_surface.dart';
import 'package:grimorio_de_bolso/features/tarot/presentation/pages/daily_tarot_selection_page.dart';
import 'package:grimorio_de_bolso/features/tarot/presentation/pages/tarot_page.dart';
import 'package:grimorio_de_bolso/features/tarot/presentation/pages/tarot_spread_selection_page.dart';
import 'package:grimorio_de_bolso/features/tarot/presentation/widgets/tarot_card_view.dart';
import 'package:grimorio_de_bolso/features/your_day/presentation/providers/daily_checkin_provider.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'support/short_test_timeout.dart';

class _PremiumFixture extends AuthProvider {
  @override
  bool get isPremiumEffective => true;

  /// A cota não é o assunto deste arquivo: o que se mede aqui é o TEMPO da
  /// cena. Uma leitura de uso real traria o banco para dentro da medida.
  @override
  Future<void> refreshOracleUsage() async {}
}

class _CheckinFixture extends DailyCheckinProvider {
  @override
  Future<void> completeRite(String riteId) async {}
}

/// A cena da revelação do Tarô tem dois tempos: as cartas viram, e só depois
/// o texto entra. Este arquivo guarda as três coisas que podem quebrar nisso:
/// o texto que nunca chega com movimento reduzido, o texto que chega cedo
/// demais, e o painel de foco cobrando uma segunda tiragem para andar entre
/// as posições.
void main() {
  useShortTestTimeout();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    final dir = await Directory.systemTemp.createTemp('tarot_focus_panel');
    await databaseFactory.setDatabasesPath(dir.path);
    await DatabaseHelper.instance.database;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    for (final table in [
      ...ReadingSessionSchema.tables,
      'tarot_readings',
      'free_writings',
    ]) {
      await db.delete(table);
    }
  });

  Future<void> until(WidgetTester tester, bool Function() ready, String stage,
      {Duration step = const Duration(milliseconds: 16)}) async {
    for (var i = 0; i < 200; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(step);
      if (ready()) return;
    }
    fail('A cena do tarô não chegou a: $stage');
  }

  Future<List<Map<String, Object?>>> rows(
      WidgetTester tester, String table) async {
    List<Map<String, Object?>>? result;
    Object? error;
    StackTrace? stack;
    // A transação do SQLite é da UI e vive na zona de fake-async: esperar por
    // ela dentro de runAsync trava num cadeado que só o próximo pump solta.
    unawaited(() async {
      try {
        final db = await DatabaseHelper.instance.database;
        result = await db.query(table);
      } catch (e, trace) {
        error = e;
        stack = trace;
      }
    }());
    await until(tester, () => result != null || error != null,
        'leitura de $table');
    if (error != null) Error.throwWithStackTrace(error!, stack!);
    return result!;
  }

  Future<void> show(WidgetTester tester, {required bool reduced}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => _PremiumFixture()),
        ChangeNotifierProvider<DailyCheckinProvider>(
            create: (_) => _CheckinFixture()),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
          child: child!,
        ),
        home: const TarotPage(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  /// A mesa: o palco do painel mostra a mesma carta GRANDE e também é um
  /// [TarotCardView], então contar a tiragem exige olhar só para a mesa.
  final naMesa = find.descendant(
      of: find.byKey(const ValueKey('tarot-table')),
      matching: find.byType(TarotCardView));

  /// O alvo do envelope de texto: 0 enquanto as cartas viram, 1 quando a cena
  /// solta o texto. É o estado que a página pediu, não o quadro intermediário
  /// da animação — é exatamente ele que o movimento reduzido deve pular.
  double alvoDoTexto(WidgetTester tester) => tester
      .widget<AnimatedOpacity>(find.byKey(const ValueKey('tarot-text')))
      .opacity;

  Future<void> tirarCartaDoDia(WidgetTester tester,
      AppLocalizations l10n) async {
    await tester.enterText(find.byType(TextField), 'A focus panel question');
    await tester.ensureVisible(find.text(l10n.tarotDailyCard));
    await tester.tap(find.text(l10n.tarotDailyCard));
    await until(
        tester,
        () => find.byType(DailyTarotSelectionPage).evaluate().isNotEmpty,
        'rota de escolha da carta do dia');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('fan-select')));
    await tester.tap(find.byKey(const ValueKey('fan-select')));
  }

  Future<void> tirarCruzDeTres(WidgetTester tester,
      AppLocalizations l10n) async {
    await tester.enterText(find.byType(TextField), 'A focus panel question');
    await tester.ensureVisible(find.text(l10n.tarotThreeCards));
    await tester.tap(find.text(l10n.tarotThreeCards));
    await until(
        tester,
        () => find.byType(TarotSpreadSelectionPage).evaluate().isNotEmpty,
        'rota de escolha da tiragem');
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      tester
          .widget<Focus>(find.byKey(const ValueKey('card-fan-focus')))
          .focusNode!
          .requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      if (i < 2) {
        await until(
            tester,
            () => find.byKey(ValueKey('spread-selected-$i')).evaluate().isNotEmpty,
            'escolha ${i + 1}');
        await tester.pumpAndSettle();
        // O leque continua no lugar: nenhuma frente pode aparecer no meio.
        expect(find.byType(CardSelectionSurface), findsOneWidget);
      }
    }
  }

  testWidgets('movimento reduzido: o texto entra no mesmo quadro da carta',
      (tester) async {
    await show(tester, reduced: true);
    final l10n = AppLocalizations.of(tester.element(find.byType(TarotPage)));
    await tirarCartaDoDia(tester, l10n);
    await until(tester, () {
      if (naMesa.evaluate().isEmpty) return false;
      // O estado FINAL de imediato: com movimento reduzido não existe quadro
      // em que a carta já esteja lá e o texto ainda não.
      expect(alvoDoTexto(tester), 1,
          reason: 'Movimento reduzido não pode congelar o estado inicial');
      return true;
    }, 'carta do dia revelada');
    await tester.pumpAndSettle();
    expect(find.text(l10n.readingFocusCounter(1, 1)), findsNothing,
        reason: 'Uma carta só não ganha contador de posição');
    expect(find.byKey(const ValueKey('tarot-stage')), findsNothing,
        reason: 'Com uma carta só a mesa já é o palco');
    expect(await rows(tester, 'tarot_readings'), hasLength(1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(minutes: 1)));

  testWidgets('um toque na mesa antecipa o texto sem tirar outra carta',
      (tester) async {
    await show(tester, reduced: false);
    final l10n = AppLocalizations.of(tester.element(find.byType(TarotPage)));
    await tirarCartaDoDia(tester, l10n);
    await until(tester, () {
      if (naMesa.evaluate().isEmpty) return false;
      expect(alvoDoTexto(tester), 0,
          reason: 'O texto espera a virada terminar');
      return true;
    }, 'primeira frente na mesa');
    final antes = await rows(tester, 'tarot_readings');
    await tester.ensureVisible(find.byKey(const ValueKey('tarot-table')));
    await tester.tap(find.byKey(const ValueKey('tarot-table')));
    await tester.pump();
    expect(alvoDoTexto(tester), 1,
        reason: 'Um toque na mesa mostra o texto na hora');
    await tester.pumpAndSettle();
    // Antecipar é apresentação: não tira carta, não cobra, não grava nada.
    expect(await rows(tester, 'tarot_readings'), hasLength(antes.length));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(minutes: 1)));

  testWidgets('três cartas: o texto chega sozinho e o painel percorre as posições',
      (tester) async {
    await show(tester, reduced: false);
    final l10n = AppLocalizations.of(tester.element(find.byType(TarotPage)));
    await tirarCruzDeTres(tester, l10n);
    await until(tester, () {
      if (naMesa.evaluate().isEmpty) return false;
      expect(alvoDoTexto(tester), 0,
          reason: 'O texto espera as três cartas assentarem');
      return true;
    }, 'primeira frente na mesa');
    // O relógio da cena solta o texto sem precisar de toque nenhum.
    await tester.pump(const Duration(milliseconds: 900));
    expect(alvoDoTexto(tester), 1);
    await tester.pumpAndSettle();
    expect(naMesa.evaluate(), hasLength(3));
    expect(find.byKey(const ValueKey('tarot-stage')), findsOneWidget,
        reason: 'Com mais de uma carta o painel ganha palco');
    expect(find.text(l10n.readingFocusCounter(1, 3)), findsOneWidget);

    final antes = await rows(tester, 'tarot_readings');
    expect(antes, hasLength(1));
    await tester.ensureVisible(find.byKey(const ValueKey('tarot-focus-next')));
    await tester.tap(find.byKey(const ValueKey('tarot-focus-next')));
    await tester.pumpAndSettle();
    expect(find.text(l10n.readingFocusCounter(2, 3)), findsOneWidget);
    // Andar entre as posições é apresentação: a tiragem gravada é a mesma.
    expect(await rows(tester, 'tarot_readings'), hasLength(1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(minutes: 1)));
}
