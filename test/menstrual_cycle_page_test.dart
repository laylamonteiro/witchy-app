import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/menstrual_cycle_schema.dart';
import 'package:grimorio_de_bolso/core/i18n/gender.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/user_model.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/menstrual_consent_store.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/repositories/menstrual_cycle_repository.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/internal_season.dart';
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

  /// O tratamento vem do usuário, e é por ele que a tela decide se a área
  /// sequer é oferecida — sem isto o teste do masculino olharia para o
  /// padrão do app, não para o que o teste pediu.
  @override
  UserModel get currentUser =>
      UserModel.defaultUser().copyWith(gender: gender);

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

  /// A folha de registro entra deslizando: no quadro em que o formulário
  /// aparece ela ainda está fora da tela, e um toque ali não acerta nada.
  /// Esperar o formulário parar de se mover vale para os dois casos — com
  /// animação e sem ela.
  Future<void> openForm(WidgetTester tester) async {
    await until(tester, () => find.byType(MenstrualRecordForm).evaluate().isNotEmpty,
        'the form');
    final form = find.byType(MenstrualRecordForm);
    Offset? previous;
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      final now = tester.getTopLeft(form);
      if (now == previous) return;
      previous = now;
    }
    fail('The record did not reach: the form in place');
  }

  /// Tocar no que está dentro da folha: o painel rola, e o alvo pode estar
  /// abaixo da dobra em telas curtas.
  Future<void> pressIn(WidgetTester tester, String key) async {
    final target = find.byKey(ValueKey(key));
    await tester.ensureVisible(target);
    await tester.pump();
    await tester.tap(target);
    await tester.pump();
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
      // Uma chave por combinação: pedir a tela de novo com outro plano
      // constrói tudo do zero, em vez de herdar o provedor anterior.
      key: ValueKey('$gender-$premium'),
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
    await openForm(tester);
    expect(find.byKey(const ValueKey('menstrual-editing-day')), findsOneWidget);

    await pressIn(tester, 'menstrual-mark-spotting');
    await tester.ensureVisible(find.byKey(const ValueKey('menstrual-note')));
    await tester.pump();
    await tester.enterText(find.byKey(const ValueKey('menstrual-note')), 'a quiet day');
    await tester.pump();
    await pressIn(tester, 'menstrual-save');
    await until(tester, () => find.byType(MenstrualRecordForm).evaluate().isEmpty,
        'the form to close after the write');

    final saved = await tester.runAsync(() =>
        MenstrualCycleRepository().dayOf(userId: 'local_user', day: today));
    expect(saved, isNotNull);
    expect(saved!.mark, MenstrualMark.spotting,
        reason: 'Spotting is never promoted into a beginning');
    expect(saved.note, 'a quiet day');
    await until(tester, () => find.text('Spotting').evaluate().isNotEmpty,
        'the day on screen');

    // Nothing derived anywhere on the free plan. O convite Premium fala de
    // médias — por isso a ausência se mede pelas chaves do que é calculado,
    // não por procurar a palavra na tela.
    expect(find.byKey(const ValueKey('menstrual-derived')), findsNothing);
    expect(find.byKey(const ValueKey('menstrual-cycle-day')), findsNothing);
    expect(find.byKey(const ValueKey('menstrual-average')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('premium sees what the history shows; free sees none of it',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {'menstrual_consent_record_local_user': true});
    // Four beginnings, twenty-eight days apart: three complete intervals.
    final repo = MenstrualCycleRepository();
    await tester.runAsync(() async {
      for (final start in [
        DateTime(2025, 12, 1),
        DateTime(2025, 12, 29),
        DateTime(2026, 1, 26),
        DateTime(2026, 2, 23),
      ]) {
        await repo.save(MenstrualDay(
            userId: 'local_user', day: start, mark: MenstrualMark.start));
      }
    });

    await show(tester);
    expect(find.byKey(const ValueKey('menstrual-derived')), findsNothing,
        reason: 'Nothing derived is even built on the free plan');
    expect(find.byKey(const ValueKey('menstrual-premium-invite')), findsOneWidget);

    await show(tester, premium: true);
    await until(
        tester,
        () => find.byKey(const ValueKey('menstrual-derived')).evaluate().isNotEmpty,
        'the derived card');
    expect(find.byKey(const ValueKey('menstrual-average')), findsOneWidget);
    expect(find.text('Observed average: 28 days'), findsOneWidget);
    expect(find.byKey(const ValueKey('menstrual-next-reference')), findsNothing,
        reason: 'The next date is opt in, and nobody opted in');
    expect(find.byKey(const ValueKey('menstrual-lunar')), findsOneWidget,
        reason: 'The comparison with the Moon comes with the derived side');
    expect(find.byKey(const ValueKey('menstrual-lunar-closing')), findsOneWidget,
        reason: 'The fourth beginning closes the third interval, and says so');

    await tester.ensureVisible(
        find.byKey(const ValueKey('menstrual-next-reference-switch')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('menstrual-next-reference-switch')));
    await until(
        tester,
        () => find.byKey(const ValueKey('menstrual-next-reference')).evaluate().isNotEmpty,
        'the reference');
    expect(find.textContaining('23/03/2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the season is her choice, and choosing already records it',
      (tester) async {
    // O nome das estações vem da camada de conteúdo, não do ARB.
    ContentLocale.instance.setLocale(const Locale('en'));
    addTearDown(
        () => ContentLocale.instance.setLocale(const Locale('pt', 'BR')));
    SharedPreferences.setMockInitialValues(
        {'menstrual_consent_record_local_user': true});
    await show(tester, premium: true);
    await until(
        tester,
        () => find.byKey(const ValueKey('menstrual-season')).evaluate().isNotEmpty,
        'the season card');
    expect(find.byKey(const ValueKey('menstrual-season-invitation')), findsNothing,
        reason: 'Nothing is chosen for her');

    await pressIn(tester, 'menstrual-season-spring');
    await until(
        tester,
        () => find
            .byKey(const ValueKey('menstrual-season-invitation'))
            .evaluate()
            .isNotEmpty,
        'the invitation');
    final chosen = await tester.runAsync(() =>
        MenstrualCycleRepository().dayOf(userId: 'local_user', day: today));
    expect(chosen!.season, InternalSeason.spring);
    expect(chosen.mark, MenstrualMark.note,
        reason: 'Choosing a season says nothing about bleeding');
    expect(find.byKey(const ValueKey('menstrual-season-link-citrine')),
        findsOneWidget,
        reason: 'The curated entry is right there, and it opens');

    await tester
        .ensureVisible(find.byKey(const ValueKey('menstrual-season-writing')));
    await tester.pump();
    await tester.enterText(
        find.byKey(const ValueKey('menstrual-season-writing')), 'a first gesture');
    await tester.pump();
    await pressIn(tester, 'menstrual-season-save');
    await until(
        tester,
        () => find
            .byKey(const ValueKey('menstrual-season-sealed'))
            .evaluate()
            .isNotEmpty,
        'the seal');
    final written = await tester.runAsync(() =>
        MenstrualCycleRepository().dayOf(userId: 'local_user', day: today));
    expect(written!.seasonNote, 'a first gesture');

    // Tocar de novo na mesma estação desmarca, sem levar o resto junto.
    await pressIn(tester, 'menstrual-season-spring');
    await until(
        tester,
        () => find
            .byKey(const ValueKey('menstrual-season-invitation'))
            .evaluate()
            .isEmpty,
        'the season cleared');
    final cleared = await tester.runAsync(() =>
        MenstrualCycleRepository().dayOf(userId: 'local_user', day: today));
    expect(cleared!.season, isNull);
    expect(cleared.seasonNote, 'a first gesture',
        reason: 'Unchoosing a season never erases what she wrote');
    expect(tester.takeException(), isNull);
  });

  testWidgets('the free plan is never offered a season', (tester) async {
    SharedPreferences.setMockInitialValues(
        {'menstrual_consent_record_local_user': true});
    await show(tester);
    expect(find.byKey(const ValueKey('menstrual-season')), findsNothing,
        reason: 'Editorial content lives in Premium, and nothing is half shown');
    expect(find.byKey(const ValueKey('menstrual-premium-invite')), findsOneWidget);
  });

  testWidgets('cancelling closes the sheet and writes nothing', (tester) async {
    SharedPreferences.setMockInitialValues(
        {'menstrual_consent_record_local_user': true});
    await show(tester);
    await tester.tap(find.byKey(const ValueKey('menstrual-record-today')));
    await openForm(tester);

    await tester.ensureVisible(find.byKey(const ValueKey('menstrual-note')));
    await tester.pump();
    await tester.enterText(
        find.byKey(const ValueKey('menstrual-note')), 'never meant to keep');
    await tester.pump();
    await pressIn(tester, 'menstrual-cancel');
    await until(tester, () => find.byType(MenstrualRecordForm).evaluate().isEmpty,
        'the form to close without writing');

    final saved = await tester.runAsync(() =>
        MenstrualCycleRepository().dayOf(userId: 'local_user', day: today));
    expect(saved, isNull, reason: 'Leaving without saving leaves no record');
    expect(find.text('No record today'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelling never touches what was already saved', (tester) async {
    SharedPreferences.setMockInitialValues(
        {'menstrual_consent_record_local_user': true});
    await show(tester);
    await tester.runAsync(() => MenstrualCycleRepository().save(MenstrualDay(
          userId: 'local_user',
          day: today,
          mark: MenstrualMark.start,
          note: 'kept',
        )));

    await tester.tap(find.byKey(const ValueKey('menstrual-record-today')));
    await openForm(tester);
    await pressIn(tester, 'menstrual-mark-spotting');
    await tester.ensureVisible(find.byKey(const ValueKey('menstrual-note')));
    await tester.pump();
    await tester.enterText(
        find.byKey(const ValueKey('menstrual-note')), 'a second thought');
    await tester.pump();
    await pressIn(tester, 'menstrual-cancel');
    await until(tester, () => find.byType(MenstrualRecordForm).evaluate().isEmpty,
        'the form to close');

    final saved = await tester.runAsync(() =>
        MenstrualCycleRepository().dayOf(userId: 'local_user', day: today));
    expect(saved!.mark, MenstrualMark.start);
    expect(saved.note, 'kept', reason: 'A discarded edit is a discarded edit');
    expect(tester.takeException(), isNull);
  });

  testWidgets('the X in the header is a way out too', (tester) async {
    SharedPreferences.setMockInitialValues(
        {'menstrual_consent_record_local_user': true});
    await show(tester);
    await tester.tap(find.byKey(const ValueKey('menstrual-record-today')));
    await openForm(tester);
    await pressIn(tester, 'menstrual-close');
    await until(tester, () => find.byType(MenstrualRecordForm).evaluate().isEmpty,
        'the form to close by the X');
    expect(tester.takeException(), isNull);
  });

  testWidgets('the card is not offered in the masculine', (tester) async {
    Future<void> pumpCard(Gender gender) async {
      await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
        // Sem chave, o provedor do primeiro tratamento sobreviveria aos
        // outros dois e o teste olharia sempre para o mesmo usuário.
        key: ValueKey(gender),
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
    expect(find.text('🩸'), findsOneWidget,
        reason: 'The cycle card wears the drop, not the moon');
    expect(find.text('🌘'), findsNothing);
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
    await openForm(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('menstrual-note')));
    await tester.pump();
    await tester.enterText(find.byKey(const ValueKey('menstrual-note')), 'keep me');
    await tester.pump();
    await pressIn(tester, 'menstrual-save');
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
