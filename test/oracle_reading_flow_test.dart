// Um teste que falha no meio de uma gravação deixa o cadeado do SQLite
// preso para os seguintes: o limite por teste evita que isso vire dezenas
// de minutos de CI em vez de uma falha legível.
@Timeout(Duration(minutes: 2))
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/reading_session_schema.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/divination/data/models/oracle_card_model.dart';
import 'package:grimorio_de_bolso/features/divination/presentation/pages/oracle_cards_page.dart';
import 'package:grimorio_de_bolso/features/divination/presentation/pages/oracle_selection_page.dart';
import 'package:grimorio_de_bolso/features/divination/presentation/widgets/card_selection_surface.dart';
import 'package:grimorio_de_bolso/features/divination/presentation/widgets/oracle_card_face.dart';
import 'package:grimorio_de_bolso/features/your_day/presentation/providers/daily_checkin_provider.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'support/short_test_timeout.dart';

class _PremiumFixture extends AuthProvider {
  Completer<void>? pendingRefresh;
  bool waitingForRefresh = false;

  @override
  bool get isPremiumEffective => true;
  @override
  Future<void> refreshOracleUsage() async {
    final pending = pendingRefresh;
    if (pending == null) return;
    waitingForRefresh = true;
    await pending.future;
    pendingRefresh = null;
    waitingForRefresh = false;
  }
}

class _CheckinFixture extends DailyCheckinProvider {
  final rites = <String>[];
  @override
  Future<void> completeRite(String riteId) async => rites.add(riteId);
}

void main() {
  useShortTestTimeout();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    final dir = await Directory.systemTemp.createTemp('oracle_reading_flow');
    await databaseFactory.setDatabasesPath(dir.path);
    await DatabaseHelper.instance.database;
  });
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    for (final table in [...ReadingSessionSchema.tables, 'oracle_readings', 'free_writings']) {
      await db.delete(table);
    }
  });

  Future<void> until(WidgetTester tester, bool Function() ready, String stage,
      {Duration step = const Duration(milliseconds: 50)}) async {
    for (var i = 0; i < 150; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(step);
      if (ready()) return;
    }
    fail('The oracle flow did not reach: $stage');
  }

  Future<List<Map<String, Object?>>> rows(WidgetTester tester, String table) async {
    List<Map<String, Object?>>? result;
    Object? error;
    StackTrace? stack;
    // The UI owns SQLite transactions in the fake-async zone. Pump both clocks
    // instead of waiting in runAsync on a lock that only the next pump releases.
    unawaited(() async {
      try {
        final db = await DatabaseHelper.instance.database;
        result = await db.query(table);
      } catch (e, trace) { error = e; stack = trace; }
    }());
    await until(tester, () => result != null || error != null, 'SQLite snapshot of $table');
    if (error != null) Error.throwWithStackTrace(error!, stack!);
    return result!;
  }

  late _CheckinFixture checkin;

  Future<void> show(WidgetTester tester, {double textScale = 1, bool reduced = false}) async {
    checkin = _CheckinFixture();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => _PremiumFixture()),
        ChangeNotifierProvider<DailyCheckinProvider>(create: (_) => checkin),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale), disableAnimations: reduced),
          child: child!,
        ),
        home: const OracleCardsPage(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Finder faces() => find.byWidgetPredicate((w) => w is OracleCardFace && w.width <= 100);

  Future<void> open(WidgetTester tester, OracleSpreadType spread) async {
    await tester.ensureVisible(find.text(spread.displayName));
    await tester.tap(find.text(spread.displayName));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('oracle-draw')));
    await tester.tap(find.byKey(const ValueKey('oracle-draw')));
  }

  testWidgets('weekly guide: choose five, reveal after the fan leaves, discover, archive, revisit',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const spread = OracleSpreadType.weeklyGuidance;
    await show(tester, textScale: 1.3);
    await open(tester, spread);
    await until(tester, () => find.byType(OracleSelectionPage).evaluate().isNotEmpty,
        'selection route');
    await tester.pumpAndSettle();

    final chosen = <String>[];
    final refreshGate = Completer<void>();
    late _PremiumFixture finishingAuth;
    for (var i = 0; i < spread.cardCount; i++) {
      final fan = tester.widget<CardSelectionSurface>(find.byType(CardSelectionSurface));
      final index = i.isEven ? 0 : fan.cardIds.length - 1;
      chosen.add(fan.cardIds[index]);
      tester.widget<Focus>(find.byKey(const ValueKey('card-fan-focus'))).focusNode!.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(i.isEven ? LogicalKeyboardKey.home : LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      if (i == spread.cardCount - 1) {
        finishingAuth = tester.element(find.byType(OracleSelectionPage))
            .read<AuthProvider>() as _PremiumFixture;
        finishingAuth.pendingRefresh = refreshGate;
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      if (i < spread.cardCount - 1) {
        await until(tester, () => find.byKey(ValueKey('oracle-selected-$i')).evaluate().isNotEmpty,
            'selection ${i + 1}');
        await tester.pumpAndSettle();
        expect(find.byType(OracleCardFace), findsNothing,
            reason: 'Fronts stay hidden until the set is complete');
        final next = tester.widget<CardSelectionSurface>(find.byType(CardSelectionSurface));
        expect(next.cardIds.length, 44 - i - 1);
        expect(next.cardIds.toSet().intersection(chosen.toSet()), isEmpty);
      }
      if (i == 1) {
        final before = await rows(tester, 'selection_sessions');
        expect(await rows(tester, 'oracle_readings'), isEmpty);
        await tester.pumpWidget(const SizedBox.shrink());
        await show(tester, textScale: 1.3);
        await open(tester, spread);
        await until(tester, () => find.byType(OracleSelectionPage).evaluate().isNotEmpty,
            'resumed selection route');
        await tester.pumpAndSettle();
        final after = await rows(tester, 'selection_sessions');
        expect(after.single['id'], before.single['id']);
        expect(after.single['deck_json'], before.single['deck_json']);
        expect(jsonDecode(after.single['selected_json'] as String), chosen);
      }
    }
    await until(tester, () => finishingAuth.waitingForRefresh, 'result preparation');
    await tester.pump(const Duration(milliseconds: 500));
    final selection = find.byType(OracleSelectionPage);
    expect(selection, findsOneWidget,
        reason: 'The fan must cover the menu while the table is being prepared');
    expect(ModalRoute.of(tester.element(selection))!.isCurrent, isTrue);
    refreshGate.complete();
    await until(tester, () {
      expect(find.byKey(const ValueKey('oracle-draw')), findsNothing,
          reason: 'No frame between the fan and the table may show the menu');
      if (selection.evaluate().isNotEmpty) {
        expect(faces(), findsNothing, reason: 'The flip starts after the fan has left');
      }
      return faces().evaluate().length == spread.cardCount;
    }, 'all revealed fronts', step: const Duration(milliseconds: 16));
    expect(checkin.rites, [DailyRites.oracle]);
    final text = find.byKey(const ValueKey('oracle-text'));
    await until(tester, () => tester.widget<AnimatedOpacity>(text).opacity == 1,
        'meanings after the cards settle');
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(tester.element(find.byType(OracleCardsPage)));
    expect(find.text(l10n.oracleNewDiscovery(5)), findsOneWidget);
    expect(find.byKey(const ValueKey('oracle-stage')), findsOneWidget);

    final readings = await rows(tester, 'oracle_readings');
    final archive = await rows(tester, 'free_writings');
    expect(readings, hasLength(1));
    expect(archive, hasLength(1));
    expect(archive.single['id'], readings.single['id']);
    expect(archive.single['created_at'], readings.single['date']);
    final data = jsonDecode(readings.single['reading_data'] as String) as Map;
    final positions = data['positions'] as List;
    expect(positions.map((p) => '${p['card']['id']}').toList(), chosen);
    expect(await rows(tester, 'oracle_discoveries'), hasLength(5));

    // Tapping a table card brings it to the stage and highlights its text.
    await tester.ensureVisible(find.byKey(const ValueKey('oracle-slot-3')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('oracle-slot-3')));
    await tester.pumpAndSettle();
    final stage = tester.widget<OracleSceneCard>(find.descendant(
        of: find.byKey(const ValueKey('oracle-stage')),
        matching: find.byType(OracleSceneCard)));
    expect('${stage.card.id}', chosen[3]);

    // A queixa que este painel resolve: tocar numa carta NÃO move a página.
    final scroll = tester.state<ScrollableState>(find.descendant(
        of: find.byType(OracleCardsPage), matching: find.byType(Scrollable)));
    final before = scroll.position.pixels;
    await tester.tap(find.byKey(const ValueKey('oracle-slot-1')));
    await tester.pumpAndSettle();
    expect(scroll.position.pixels, before,
        reason: 'A mesa e o painel já estão à vista: não há para onde rolar');
    final swapped = tester.widget<OracleSceneCard>(find.descendant(
        of: find.byKey(const ValueKey('oracle-stage')),
        matching: find.byType(OracleSceneCard)));
    expect('${swapped.card.id}', chosen[1]);

    // Reopening shows the same table: no fan, no second reading, no popup.
    await tester.pumpWidget(const SizedBox.shrink());
    await show(tester, textScale: 1.3);
    await open(tester, spread);
    await until(tester, () => faces().evaluate().length == spread.cardCount, 'revisited table');
    expect(find.byType(OracleSelectionPage), findsNothing);
    expect(checkin.rites, isEmpty, reason: 'Revisiting is not a new rite');
    expect(find.byKey(const ValueKey('oracle-discovery')), findsNothing);
    expect(await rows(tester, 'oracle_readings'), hasLength(1));
    expect(await rows(tester, 'free_writings'), hasLength(1));
    expect(await rows(tester, 'oracle_discoveries'), hasLength(5));

    await tester.ensureVisible(find.byKey(const ValueKey('oracle-new-reading')));
    await tester.tap(find.byKey(const ValueKey('oracle-new-reading')));
    await tester.pumpAndSettle();
    await open(tester, spread);
    await until(tester, () => find.byType(OracleSelectionPage).evaluate().isNotEmpty,
        'new reading selection route');
    expect(find.byKey(const ValueKey('oracle-selected-0')), findsNothing);
    expect(await rows(tester, 'selection_sessions'), hasLength(2));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(minutes: 1)));

  testWidgets('daily message under reduced motion shows front, scene and text at once',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await show(tester, reduced: true);
    await tester.ensureVisible(find.byKey(const ValueKey('oracle-draw')));
    await tester.tap(find.byKey(const ValueKey('oracle-draw')));
    await until(tester, () => find.byType(OracleSelectionPage).evaluate().isNotEmpty,
        'selection route');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('fan-select')));
    await tester.tap(find.byKey(const ValueKey('fan-select')));
    await until(tester, () => faces().evaluate().length == 1, 'revealed card');
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedOpacity>(find.byKey(const ValueKey('oracle-text'))).opacity, 1);
    expect(find.byKey(const ValueKey('oracle-stage')), findsNothing,
        reason: 'With one card the table is already the stage');
    final face = tester.widget<OracleCardFace>(faces().first);
    expect(face.sceneProgress, 1,
        reason: 'Reduced motion shows the scene already settled, on the table');
    final l10n = AppLocalizations.of(tester.element(find.byType(OracleCardsPage)));
    expect(find.text(l10n.oracleNewDiscovery(1)), findsOneWidget);
    expect(await rows(tester, 'oracle_readings'), hasLength(1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
