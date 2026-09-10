import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/reading_session_schema.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/runes/data/models/rune_spread_model.dart';
import 'package:grimorio_de_bolso/features/runes/presentation/pages/rune_reading_page.dart';
import 'package:grimorio_de_bolso/features/runes/presentation/pages/rune_selection_page.dart';
import 'package:grimorio_de_bolso/features/runes/presentation/widgets/rune_selection_surface.dart';
import 'package:grimorio_de_bolso/features/runes/presentation/widgets/rune_stone_view.dart';
import 'package:grimorio_de_bolso/features/your_day/presentation/providers/daily_checkin_provider.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _PremiumFixture extends AuthProvider {
  Completer<void>? pendingRefresh;
  bool waitingForRefresh = false;

  @override
  bool get isPremiumEffective => true;
  @override
  Future<void> refreshRuneUsage() async {
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
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    final dir = await Directory.systemTemp.createTemp('rune_reading_flow');
    await databaseFactory.setDatabasesPath(dir.path);
    await DatabaseHelper.instance.database;
  });
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    for (final table in [...ReadingSessionSchema.tables, 'rune_readings', 'free_writings']) {
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
    fail('The rune flow did not reach: $stage');
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

  Future<void> show(WidgetTester tester, {double textScale = 1}) async {
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
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const RuneReadingPage(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Finder faces() => find.byWidgetPredicate((w) => w is RuneStoneView && w.symbol != null);

  Future<void> open(WidgetTester tester, RuneSpreadType spread) async {
    await tester.ensureVisible(find.text(spread.displayName));
    await tester.tap(find.text(spread.displayName));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'A manual rune question');
    await tester.ensureVisible(find.byKey(const ValueKey('runes-draw')));
    await tester.tap(find.byKey(const ValueKey('runes-draw')));
  }

  testWidgets('nine stones: choose, reveal after the cloth leaves, archive, revisit and new reading',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const spread = RuneSpreadType.nineWorlds;
    await show(tester, textScale: 1.3);
    await open(tester, spread);
    await until(tester, () => find.byType(RuneSelectionPage).evaluate().isNotEmpty,
        'selection route');
    await tester.pumpAndSettle();

    final chosen = <String>[];
    final slots = <int>[];
    final refreshGate = Completer<void>();
    late _PremiumFixture finishingAuth;
    for (var i = 0; i < spread.runeCount; i++) {
      final cloth = tester.widget<RuneSelectionSurface>(find.byType(RuneSelectionSurface));
      final index = i.isEven ? 0 : cloth.stoneIds.length - 1;
      chosen.add(cloth.stoneIds[index]);
      slots.add(cloth.deckPositions![index]);
      tester.widget<Focus>(find.byKey(const ValueKey('rune-cloth-focus'))).focusNode!.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(i.isEven ? LogicalKeyboardKey.home : LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      if (i == spread.runeCount - 1) {
        finishingAuth = tester.element(find.byType(RuneSelectionPage))
            .read<AuthProvider>() as _PremiumFixture;
        finishingAuth.pendingRefresh = refreshGate;
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      if (i < spread.runeCount - 1) {
        await until(tester, () => find.byKey(ValueKey('rune-selected-$i')).evaluate().isNotEmpty,
            'selection ${i + 1}');
        await tester.pumpAndSettle();
        expect(faces(), findsNothing, reason: 'Glyphs stay hidden until the set is complete');
        final next = tester.widget<RuneSelectionSurface>(find.byType(RuneSelectionSurface));
        expect(next.stoneIds.length, 24 - i - 1);
        expect(next.stoneIds.toSet().intersection(chosen.toSet()), isEmpty);
        expect(find.byKey(ValueKey('rune-stone-${slots[i]}')), findsNothing,
            reason: 'A chosen stone leaves its slot; the rest keep theirs');
      }
      if (i == 2) {
        final before = await rows(tester, 'selection_sessions');
        expect(await rows(tester, 'rune_readings'), isEmpty);
        await tester.pumpWidget(const SizedBox.shrink());
        await show(tester, textScale: 1.3);
        await open(tester, spread);
        await until(tester, () => find.byType(RuneSelectionPage).evaluate().isNotEmpty,
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
    final selection = find.byType(RuneSelectionPage);
    expect(selection, findsOneWidget,
        reason: 'The cloth must cover the menu while the table is being prepared');
    expect(ModalRoute.of(tester.element(selection))!.isCurrent, isTrue);
    refreshGate.complete();
    await until(tester, () {
      expect(find.byType(TextField), findsNothing,
          reason: 'No frame between the cloth and the table may show the menu');
      if (selection.evaluate().isNotEmpty) {
        expect(faces(), findsNothing, reason: 'The flip starts after the cloth has left');
      }
      return faces().evaluate().length == spread.runeCount;
    }, 'all revealed glyphs', step: const Duration(milliseconds: 16));
    expect(checkin.rites, [DailyRites.runes]);
    final text = find.byKey(const ValueKey('runes-text'));
    await until(tester, () => tester.widget<AnimatedOpacity>(text).opacity == 1,
        'meanings after the stones settle');
    await tester.pumpAndSettle();
    for (final name in chosen) {
      expect(find.text(name), findsWidgets);
    }

    final readings = await rows(tester, 'rune_readings');
    final archive = await rows(tester, 'free_writings');
    expect(readings, hasLength(1));
    expect(archive, hasLength(1));
    expect(archive.single['id'], readings.single['id']);
    expect(archive.single['created_at'], readings.single['date']);
    expect(archive.single['content'], contains('A manual rune question'));
    final data = jsonDecode(readings.single['reading_data'] as String) as Map;
    final positions = data['positions'] as List;
    expect(positions.map((p) => p['rune']['name']).toList(), chosen);
    final sessions = await rows(tester, 'selection_sessions');
    expect(sessions.single['result_id'], readings.single['id']);
    final deck = (jsonDecode(sessions.single['deck_json'] as String) as List).cast<Map>();
    for (var i = 0; i < chosen.length; i++) {
      final stone = deck.firstWhere((s) => s['id'] == chosen[i]);
      expect(positions[i]['isReversed'], stone['reversed']);
    }

    // Reopening the page and asking again shows the same table: no cloth,
    // no second reading, no second archive page.
    await tester.pumpWidget(const SizedBox.shrink());
    await show(tester, textScale: 1.3);
    await open(tester, spread);
    await until(tester, () => faces().evaluate().length == spread.runeCount, 'revisited table');
    expect(find.byType(RuneSelectionPage), findsNothing);
    expect(checkin.rites, isEmpty, reason: 'Revisiting is not a new rite');
    expect(await rows(tester, 'rune_readings'), hasLength(1));
    expect(await rows(tester, 'free_writings'), hasLength(1));
    expect(await rows(tester, 'selection_sessions'), hasLength(1));

    await tester.ensureVisible(find.byKey(const ValueKey('runes-new-reading')));
    await tester.tap(find.byKey(const ValueKey('runes-new-reading')));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await open(tester, spread);
    await until(tester, () => find.byType(RuneSelectionPage).evaluate().isNotEmpty,
        'new reading selection route');
    expect(find.byKey(const ValueKey('rune-selected-0')), findsNothing);
    expect(await rows(tester, 'selection_sessions'), hasLength(2));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(minutes: 1)));

  testWidgets('a single stone under reduced motion shows its glyph and text at once',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => _PremiumFixture()),
        ChangeNotifierProvider<DailyCheckinProvider>(create: (_) => _CheckinFixture()),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: const RuneReadingPage(),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('runes-draw')));
    await tester.tap(find.byKey(const ValueKey('runes-draw')));
    await until(tester, () => find.byType(RuneSelectionPage).evaluate().isNotEmpty,
        'selection route');
    await tester.pumpAndSettle();
    final cloth = tester.widget<RuneSelectionSurface>(find.byType(RuneSelectionSurface));
    final chosen = cloth.stoneIds[10];
    final stone = find.byKey(ValueKey('rune-stone-${cloth.deckPositions![10]}'));
    await tester.ensureVisible(stone);
    await tester.pumpAndSettle();
    await tester.tap(stone);
    await until(tester, () => faces().evaluate().length == 1, 'revealed stone');
    await tester.pumpAndSettle();
    expect(tester.widget<RuneStoneView>(faces()).symbol, isNotEmpty);
    expect(tester.widget<AnimatedOpacity>(find.byKey(const ValueKey('runes-text'))).opacity, 1);
    expect(find.text(chosen), findsWidgets);
    final readings = await rows(tester, 'rune_readings');
    expect(readings.single['question'], isNotEmpty);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
