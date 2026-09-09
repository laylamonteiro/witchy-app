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

class _PremiumFixture extends AuthProvider {
  @override
  bool get isPremiumEffective => true;
  @override
  Future<void> refreshOracleUsage() async {}
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
    final dir = await Directory.systemTemp.createTemp('daily_tarot_flow');
    await databaseFactory.setDatabasesPath(dir.path);
    await DatabaseHelper.instance.database;
  });

  Future<void> until(WidgetTester tester, bool Function() ready,
      {required String stage}) async {
    for (var i = 0; i < 150; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 50));
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
    await tester.ensureVisible(find.byKey(const ValueKey('fan-select')));
    await tester.tap(find.byKey(const ValueKey('fan-select')));
    await until(tester, () => find.byType(TarotCardView).evaluate().isNotEmpty,
        stage: 'first revealed card');
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
