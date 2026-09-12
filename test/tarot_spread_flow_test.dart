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
import 'package:grimorio_de_bolso/features/divination/presentation/widgets/card_selection_surface.dart';
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
  @override
  Future<void> completeRite(String riteId) async {}
}

void main() {
  useShortTestTimeout();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    final dir = await Directory.systemTemp.createTemp('tarot_spread_flow');
    await databaseFactory.setDatabasesPath(dir.path);
    await DatabaseHelper.instance.database;
  });
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    for (final table in [...ReadingSessionSchema.tables, 'tarot_readings', 'free_writings']) {
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
    fail('The spread did not reach: $stage');
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

  Future<void> show(WidgetTester tester, {double textScale = 1}) async {
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
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const TarotPage(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  for (final count in [3, 5]) {
    testWidgets('$count cards: choose extremes, restart, reveal, archive and revisit', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await show(tester, textScale: count == 5 ? 1.5 : 1);
      final l10n = AppLocalizations.of(tester.element(find.byType(TarotPage)));
      final title = count == 3 ? l10n.tarotThreeCards : l10n.tarotCross;
      // O palco do painel de foco mostra a carta em foco GRANDE, e ela também
      // é um TarotCardView. Contar a tiragem exige olhar só para a mesa.
      final naMesa = find.descendant(
          of: find.byKey(const ValueKey('tarot-table')),
          matching: find.byType(TarotCardView));
      Future<void> open() async {
        await tester.enterText(find.byType(TextField), 'A manual spread question');
        await tester.ensureVisible(find.text(title));
        await tester.tap(find.text(title));
        await until(tester, () => find.byType(TarotSpreadSelectionPage).evaluate().isNotEmpty,
            'selection route');
        await tester.pumpAndSettle();
      }
      await open();
      final chosen = <String>[];
      final originalPositions = <int>[];
      final refreshGate = Completer<void>();
      late _PremiumFixture finishingAuth;
      for (var i = 0; i < count; i++) {
        final fan = tester.widget<CardSelectionSurface>(find.byType(CardSelectionSurface));
        final index = i.isEven ? 0 : fan.cardIds.length - 1;
        chosen.add(fan.cardIds[index]);
        originalPositions.add(fan.deckPositions![index]);
        tester.widget<Focus>(find.byKey(const ValueKey('card-fan-focus'))).focusNode!.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(i.isEven ? LogicalKeyboardKey.home : LogicalKeyboardKey.end);
        await tester.pumpAndSettle();
        if (i == count - 1) {
          finishingAuth = tester.element(find.byType(TarotSpreadSelectionPage))
              .read<AuthProvider>() as _PremiumFixture;
          finishingAuth.pendingRefresh = refreshGate;
        }
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        if (i < count - 1) {
          await until(tester, () => find.byKey(ValueKey('spread-selected-$i')).evaluate().isNotEmpty,
              'selection ${i + 1}');
          await tester.pumpAndSettle();
          expect(find.byType(TarotCardView), findsNothing, reason: 'Faces stay hidden until the set is complete');
          final nextFan = tester.widget<CardSelectionSurface>(find.byType(CardSelectionSurface));
          expect(nextFan.cardIds.length, 78 - i - 1);
          expect(nextFan.cardIds.toSet().intersection(chosen.toSet()), isEmpty);
        }
        if (i == 1) {
          final before = await rows(tester, 'selection_sessions');
          expect(await rows(tester, 'tarot_readings'), isEmpty);
          await tester.pumpWidget(const SizedBox.shrink());
          await show(tester, textScale: count == 5 ? 1.5 : 1);
          await open();
          final after = await rows(tester, 'selection_sessions');
          expect(after.single['id'], before.single['id']);
          expect(after.single['deck_json'], before.single['deck_json']);
          expect(jsonDecode(after.single['selected_json'] as String), chosen);
        }
      }
      await until(tester, () => finishingAuth.waitingForRefresh, 'result preparation');
      await tester.pump(const Duration(milliseconds: 500));
      final selection = find.byType(TarotSpreadSelectionPage);
      expect(selection, findsOneWidget,
          reason: 'The fan must cover the menu while the result is being prepared');
      expect(ModalRoute.of(tester.element(selection))!.isCurrent, isTrue);
      refreshGate.complete();
      await until(tester, () {
        expect(find.byType(TextField), findsNothing,
            reason: 'No frame between the fan and the result may show the spread menu');
        if (selection.evaluate().isNotEmpty) {
          expect(naMesa, findsNothing,
              reason: 'The flip starts after the fan has left');
        }
        return naMesa.evaluate().length == count;
      }, 'all revealed faces', step: const Duration(milliseconds: 16));
      await tester.pumpAndSettle();
      final cards = tester.widgetList<TarotCardView>(naMesa).toList();
      expect(cards.map((c) => c.card.id).toSet(), chosen.toSet());
      final flips = tester.widgetList<TarotFlipCard>(find.byType(TarotFlipCard));
      expect(flips.map((f) => (f.back as TarotCardBack).deckPosition).toSet(),
          originalPositions.toSet());
      if (count == 5) {
        Offset point(int i) => tester.getCenter(find.descendant(
            of: find.byKey(const ValueKey('tarot-table')),
            matching: find.byWidgetPredicate(
                (w) => w is TarotCardView && w.card.id == chosen[i])));
        expect(point(4).dy, lessThan(point(0).dy));
        expect(point(2).dy, greaterThan(point(0).dy));
        expect(point(3).dx, lessThan(point(0).dx));
        expect(point(1).dx, greaterThan(point(0).dx));
      }
      final readings = await rows(tester, 'tarot_readings');
      final archive = await rows(tester, 'free_writings');
      expect(readings, hasLength(1));
      expect(archive, hasLength(1));
      expect(archive.single['id'], readings.single['id']);
      expect(archive.single['created_at'], readings.single['date']);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(title));
      await tester.tap(find.text(title));
      await until(tester, () => naMesa.evaluate().length == count, 'revisited result');
      expect(find.byType(TarotSpreadSelectionPage), findsNothing);
      expect(await rows(tester, 'tarot_readings'), hasLength(1));
      expect(await rows(tester, 'free_writings'), hasLength(1));
      await tester.ensureVisible(find.text(l10n.tarotNewSpread));
      await tester.tap(find.text(l10n.tarotNewSpread));
      await tester.pumpAndSettle();
      await open();
      expect(find.byKey(const ValueKey('spread-selected-0')), findsNothing);
      expect(await rows(tester, 'selection_sessions'), hasLength(2));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }, timeout: const Timeout(Duration(minutes: 1)));
  }
}
