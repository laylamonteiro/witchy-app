import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/reading_session_schema.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/runes/data/models/rune_spread_model.dart';
import 'package:grimorio_de_bolso/features/runes/presentation/pages/rune_reading_page.dart';
import 'package:grimorio_de_bolso/features/runes/presentation/widgets/rune_selection_surface.dart';
import 'package:grimorio_de_bolso/features/runes/presentation/widgets/rune_stone.dart';
import 'package:grimorio_de_bolso/features/your_day/presentation/providers/daily_checkin_provider.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _AuthFixture extends AuthProvider {
  _AuthFixture(this.premium);
  final bool premium;
  Completer<void>? pendingRefresh;
  bool waitingForRefresh = false;
  @override
  bool get isPremiumEffective => premium;
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
  @override
  Future<void> completeRite(String riteId) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    final dir = await Directory.systemTemp.createTemp('rune_flow');
    await databaseFactory.setDatabasesPath(dir.path);
    await DatabaseHelper.instance.database;
  });
  setUp(() async {
    ContentLocale.instance.setLocale(const Locale('en'));
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    for (final table in [...ReadingSessionSchema.tables, 'rune_readings', 'free_writings']) {
      await db.delete(table);
    }
  });

  Future<void> until(WidgetTester tester, bool Function() ready, String stage,
      {Duration step = const Duration(milliseconds: 50)}) async {
    for (var i = 0; i < 180; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(step);
      if (ready()) return;
    }
    fail('Rune flow did not reach: $stage');
  }

  Future<List<Map<String, Object?>>> rows(WidgetTester tester, String table) async {
    List<Map<String, Object?>>? result;
    Object? error;
    StackTrace? stack;
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

  Future<void> show(WidgetTester tester, RuneSpreadType spread) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => _AuthFixture(spread.runeCount != 1)),
        ChangeNotifierProvider<DailyCheckinProvider>(create: (_) => _CheckinFixture()),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(
          disableAnimations: spread.runeCount == 5,
          textScaler: TextScaler.linear(spread.runeCount == 9 ? 1.5 : 1)), child: child!),
        home: const RuneReadingPage(),
      ),
    ));
    await until(tester, () => find.byKey(const ValueKey('runes-start')).evaluate().isNotEmpty ||
        find.byKey(const ValueKey('runes-active-name')).evaluate().isNotEmpty, 'restoration');
    await tester.pumpAndSettle();
  }

  for (final spread in RuneSpreadType.values) {
    testWidgets('${spread.name}: choose, resume, reveal, inspect and reopen without duplication', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await show(tester, spread);
      final l10n = AppLocalizations.of(tester.element(find.byType(RuneReadingPage)));
      await tester.ensureVisible(find.text(spread.displayName));
      await tester.tap(find.text(spread.displayName));
      if (spread.runeCount != 1) await tester.enterText(find.byType(TextField), 'A rune question');
      Future<void> start() async {
        await tester.ensureVisible(find.byKey(const ValueKey('runes-start')));
        await tester.tap(find.byKey(const ValueKey('runes-start')));
        await until(tester, () => find.byType(RuneSelectionSurface).evaluate().isNotEmpty, 'stone selection');
        await tester.pumpAndSettle();
      }
      await start();
      final chosen = <String>[];
      final slots = <int>[];
      final refreshGate = Completer<void>();
      late _AuthFixture finishingAuth;
      for (var i = 0; i < spread.runeCount; i++) {
        final surface = tester.widget<RuneSelectionSurface>(find.byType(RuneSelectionSurface));
        final available = surface.stoneIds.where((id) => !chosen.contains(id)).toList();
        final id = i.isEven ? available.first : available.last;
        chosen.add(id);
        slots.add(surface.stoneIds.indexOf(id));
        tester.widget<Focus>(find.byKey(const ValueKey('rune-selection-focus'))).focusNode!.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(i.isEven ? LogicalKeyboardKey.home : LogicalKeyboardKey.end);
        await tester.pumpAndSettle();
        if (i == spread.runeCount - 1) {
          finishingAuth = tester.element(find.byType(RuneSelectionSurface)).read<AuthProvider>() as _AuthFixture;
          finishingAuth.pendingRefresh = refreshGate;
        }
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        if (i < spread.runeCount - 1) {
          await until(tester, () => tester.widget<RuneSelectionSurface>(
              find.byType(RuneSelectionSurface)).selectedIds.length == i + 1, 'saved stone ${i + 1}');
          await tester.pumpAndSettle();
          expect(tester.widgetList<RuneStone>(find.byType(RuneStone))
              .where((s) => s.symbol != null), isEmpty);
          if (i == 1) {
            final before = await rows(tester, 'selection_sessions');
            expect(await rows(tester, 'rune_readings'), isEmpty);
            await tester.pumpWidget(const SizedBox.shrink());
            await show(tester, spread);
            await start();
            final after = await rows(tester, 'selection_sessions');
            expect(after.single['id'], before.single['id']);
            expect(after.single['deck_json'], before.single['deck_json']);
            expect(tester.widget<RuneSelectionSurface>(find.byType(RuneSelectionSurface)).selectedIds, chosen);
          }
        }
      }
      await until(tester, () => finishingAuth.waitingForRefresh, 'result preparation');
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(RuneSelectionSurface), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      refreshGate.complete();
      await until(tester, () {
        expect(find.byType(TextField), findsNothing, reason: 'Do not flash the menu before revealing');
        return find.byKey(const ValueKey('runes-active-name')).evaluate().isNotEmpty;
      }, 'revealed result', step: const Duration(milliseconds: 16));
      await tester.pumpAndSettle();
      final stones = tester.widgetList<RuneStone>(find.byType(RuneStone)).toList();
      expect(stones.map((r) => r.symbol).toSet(), chosen.toSet());
      expect(stones.map((r) => r.slot).toSet(), slots.toSet());
      final readings = await rows(tester, 'rune_readings');
      final reading = RuneReading.fromJsonString(readings.single['reading_data'] as String);
      for (var i = 0; i < spread.runeCount; i++) {
        expect(stones.firstWhere((s) => s.symbol == chosen[i]).reversed, reading.positions[i].isReversed);
        await tester.ensureVisible(find.byKey(ValueKey('rune-board-position-$i')));
        await tester.tap(find.byKey(ValueKey('rune-board-position-$i')));
        await tester.pumpAndSettle();
        expect(tester.widget<Text>(find.byKey(const ValueKey('runes-active-name'))).data,
            reading.positions[i].rune.name);
      }
      final archive = await rows(tester, 'free_writings');
      expect(archive, hasLength(1));
      expect(archive.single['id'], reading.id);
      expect(archive.single['created_at'], readings.single['date']);
      await tester.pumpWidget(const SizedBox.shrink());
      await show(tester, spread);
      expect(find.byType(RuneSelectionSurface), findsNothing);
      expect(await rows(tester, 'rune_readings'), hasLength(1));
      expect(await rows(tester, 'free_writings'), hasLength(1));
      expect(tester.widgetList<RuneStone>(find.byType(RuneStone)).map((s) => s.symbol).toSet(), chosen.toSet());
      if (spread.runeCount != 1) {
        await tester.ensureVisible(find.text(l10n.oracleNewReading));
        await tester.tap(find.text(l10n.oracleNewReading));
        await tester.pumpAndSettle();
        await start();
        expect(tester.widget<RuneSelectionSurface>(find.byType(RuneSelectionSurface)).selectedIds, isEmpty);
        expect(await rows(tester, 'selection_sessions'), hasLength(2));
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }, timeout: const Timeout(Duration(minutes: 1)));
  }
}
