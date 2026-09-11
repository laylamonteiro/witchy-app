// Um teste que falha no meio de uma gravação deixa o cadeado do SQLite
// preso para os seguintes: o limite por teste evita que isso vire dezenas
// de minutos de CI em vez de uma falha legível.
@Timeout(Duration(minutes: 2))
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/tarot/presentation/pages/daily_tarot_selection_page.dart';
import 'package:grimorio_de_bolso/features/tarot/presentation/pages/tarot_page.dart';
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
    final dir = await Directory.systemTemp.createTemp('daily_tarot_flow');
    await databaseFactory.setDatabasesPath(dir.path);
    await DatabaseHelper.instance.database;
  });

  Future<void> until(WidgetTester tester, bool Function() ready,
      {required String stage, Duration step = const Duration(milliseconds: 50)}) async {
    for (var i = 0; i < 150; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(step);
      if (ready()) return;
    }
    fail('The reading flow did not reach: $stage');
  }

  testWidgets('manual daily choice reveals and archives once, including reopening', (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => _PremiumFixture()),
        ChangeNotifierProvider<DailyCheckinProvider>(create: (_) => _CheckinFixture()),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const TarotPage(),
      ),
    ));
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(tester.element(find.byType(TarotPage)));
    await tester.enterText(find.byType(TextField), 'A fixture question');
    await tester.ensureVisible(find.text(l10n.tarotDailyCard));
    await tester.tap(find.text(l10n.tarotDailyCard));
    await until(tester, () => find.byType(DailyTarotSelectionPage).evaluate().isNotEmpty,
        stage: 'selection route');
    await tester.pumpAndSettle();
    final auth = tester.element(find.byType(DailyTarotSelectionPage))
        .read<AuthProvider>() as _PremiumFixture;
    final refreshGate = Completer<void>();
    auth.pendingRefresh = refreshGate;
    await tester.ensureVisible(find.byKey(const ValueKey('fan-select')));
    await tester.tap(find.byKey(const ValueKey('fan-select')));
    await until(tester, () => auth.waitingForRefresh, stage: 'result preparation');
    await tester.pump(const Duration(milliseconds: 500));
    final selection = find.byType(DailyTarotSelectionPage);
    expect(selection, findsOneWidget,
        reason: 'The fan must cover the menu while the result is being prepared');
    expect(ModalRoute.of(tester.element(selection))!.isCurrent, isTrue);
    refreshGate.complete();
    await until(tester, () {
      expect(find.byType(TextField), findsNothing,
          reason: 'No frame between the fan and the result may show the spread menu');
      if (selection.evaluate().isNotEmpty) {
        expect(find.byType(TarotCardView), findsNothing,
            reason: 'The flip starts after the fan has left');
      }
      return find.byType(TarotCardView).evaluate().isNotEmpty;
    }, stage: 'first revealed card', step: const Duration(milliseconds: 16));
    final selected = tester.widget<TarotCardView>(find.byType(TarotCardView)).card.id;

    Future<List<Map<String, Object?>>> rows(String table) async {
      List<Map<String, Object?>>? result;
      Object? error;
      StackTrace? stack;
      // Keep the read in the same fake-async zone as the UI transaction.
      // Awaiting it inside runAsync can wait on a SQLite lock whose owner
      // needs the next pump to release it. Pump both clocks until it finishes.
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
          stage: 'SQLite snapshot of $table');
      if (error != null) Error.throwWithStackTrace(error!, stack!);
      return result!;
    }

    final draws = await rows('tarot_readings');
    final archive = await rows('free_writings');
    expect(draws, hasLength(1));
    expect(archive, hasLength(1));
    expect(archive.single['id'], draws.single['id']);
    expect(archive.single['created_at'], draws.single['date']);
    expect(archive.single['content'], contains('A fixture question'));

    await tester.ensureVisible(find.text(l10n.tarotNewSpread));
    await tester.tap(find.text(l10n.tarotNewSpread));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(l10n.tarotDailyCard));
    await tester.tap(find.text(l10n.tarotDailyCard));
    await until(tester, () => find.byType(TarotCardView).evaluate().isNotEmpty,
        stage: 'reopened card');
    expect(find.byType(DailyTarotSelectionPage), findsNothing);
    expect(tester.widget<TarotCardView>(find.byType(TarotCardView)).card.id, selected);
    expect(await rows('tarot_readings'), hasLength(1));
    expect(await rows('free_writings'), hasLength(1));
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(minutes: 1)));
}
