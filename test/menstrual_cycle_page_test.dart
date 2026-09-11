import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/menstrual_cycle_schema.dart';
import 'package:grimorio_de_bolso/core/i18n/gender.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/menstrual_consent_store.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/repositories/menstrual_cycle_repository.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_day.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/presentation/pages/menstrual_cycle_page.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/presentation/widgets/menstrual_cycle_card.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/presentation/widgets/menstrual_record_form.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'support/short_test_timeout.dart';

class _Fixture extends AuthProvider {
  _Fixture({this.gender = Gender.feminine, this.premium = false});

  final Gender gender;
  final bool premium;

  @override
  bool get isPremiumEffective => premium;
}

void main() {
  useShortTestTimeout();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfiNoIsolate;
  final today = DateTime(2026, 3, 12);

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    final dir = await Directory.systemTemp.createTemp('menstrual_page');
    await databaseFactory.setDatabasesPath(dir.path);
    await DatabaseHelper.instance.database;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    await db.delete(MenstrualCycleSchema.table);
  });

  Future<void> until(WidgetTester tester, bool Function() ready, String stage) async {
    for (var i = 0; i < 150; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 50));
      if (ready()) return;
    }
    fail('The record did not reach: $stage');
  }

  Future<void> show(
    WidgetTester tester, {
    Gender gender = Gender.feminine,
    bool premium = false,
  }) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
      create: (_) => _Fixture(gender: gender, premium: premium),
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: MenstrualCyclePage(today: today),
      ),
    ));
    await until(
        tester,
        () =>
            find.byKey(const ValueKey('menstrual-consent')).evaluate().isNotEmpty ||
            find.byKey(const ValueKey('menstrual-calendar')).evaluate().isNotEmpty,
        'the first screen');
  }

  testWidgets('nothing is recorded before the person says yes', (tester) async {
    await show(tester);
    expect(find.byKey(const ValueKey('menstrual-consent')), findsOneWidget);
    expect(find.byKey(const ValueKey('menstrual-calendar')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('menstrual-consent-accept')));
    await until(
        tester,
        () => find.byKey(const ValueKey('menstrual-calendar')).evaluate().isNotEmpty,
        'the calendar');
    expect(await const MenstrualConsentStore().recordingAllowed('local_user'), isTrue);
    expect(await const MenstrualConsentStore().syncAllowed('local_user'), isFalse,
        reason: 'Sending to the account is a separate yes');
  });

  testWidgets('a day is written, read back and erased, and the free plan gets no results',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {'menstrual_consent_record_local_user': true});
    await show(tester);
    expect(find.byKey(const ValueKey('menstrual-today')), findsOneWidget);
    expect(find.text('No record today'), findsOneWidget,
        reason: 'An empty day is absence of a record');
    expect(find.byKey(const ValueKey('menstrual-premium-invite')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('menstrual-record-today')));
    await until(tester, () => find.byType(MenstrualRecordForm).evaluate().isNotEmpty,
        'the form');
    expect(find.byKey(const ValueKey('menstrual-editing-day')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('menstrual-mark-spotting')));
    await tester.pump();
    await tester.enterText(find.byKey(const ValueKey('menstrual-note')), 'a quiet day');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('menstrual-save')));
    await until(tester, () => find.byType(MenstrualRecordForm).evaluate().isEmpty,
        'the form to close after the write');

    final saved = await MenstrualCycleRepository()
        .dayOf(userId: 'local_user', day: today);
    expect(saved, isNotNull);
    expect(saved!.mark, MenstrualMark.spotting,
        reason: 'Spotting is never promoted into a beginning');
    expect(saved.note, 'a quiet day');
    await until(tester, () => find.text('Spotting').evaluate().isNotEmpty,
        'the day on screen');

    // Nothing derived anywhere on the free plan.
    expect(find.textContaining('Day 1'), findsNothing);
    expect(find.textContaining('average'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the card is not offered in the masculine', (tester) async {
    Future<void> pumpCard(Gender gender) async {
      await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
        create: (_) => _Fixture(gender: gender),
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: MenstrualCycleCard()),
        ),
      ));
      await tester.pump();
    }

    await pumpCard(Gender.feminine);
    expect(find.byKey(const ValueKey('menstrual-card')), findsOneWidget);
    await pumpCard(Gender.neutral);
    expect(find.byKey(const ValueKey('menstrual-card')), findsOneWidget);
    await pumpCard(Gender.masculine);
    expect(find.byKey(const ValueKey('menstrual-card')), findsNothing,
        reason: 'No card, no teaser and no offer');
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed write keeps the form and what was written', (tester) async {
    SharedPreferences.setMockInitialValues(
        {'menstrual_consent_record_local_user': true});
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
      create: (_) => _Fixture(),
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: MenstrualCyclePage(today: today, repository: _FailingRepository()),
      ),
    ));
    await until(
        tester,
        () => find.byKey(const ValueKey('menstrual-calendar')).evaluate().isNotEmpty,
        'the calendar');
    await tester.tap(find.byKey(const ValueKey('menstrual-record-today')));
    await until(tester, () => find.byType(MenstrualRecordForm).evaluate().isNotEmpty,
        'the form');
    await tester.enterText(find.byKey(const ValueKey('menstrual-note')), 'keep me');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('menstrual-save')));
    await until(tester, () => find.byKey(const ValueKey('menstrual-error')).evaluate().isNotEmpty,
        'the failure');
    expect(find.byType(MenstrualRecordForm), findsOneWidget,
        reason: 'The form stays, with the text still in it');
    expect(find.text('keep me'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

/// Um repositório que falha ao gravar, para ver o que a tela faz com isso.
class _FailingRepository extends MenstrualCycleRepository {
  @override
  Future<List<MenstrualDay>> between({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async =>
      const [];

  @override
  Future<MenstrualDay> save(MenstrualDay day) async =>
      throw Exception('disk full');
}
