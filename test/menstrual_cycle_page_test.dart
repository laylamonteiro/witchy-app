import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/menstrual_cycle_schema.dart';
import 'package:grimorio_de_bolso/core/i18n/gender.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/user_model.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/models/spell_model.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/menstrual_consent_store.dart';
import 'package:grimorio_de_bolso/features/lunar/presentation/providers/lunar_provider.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/repositories/menstrual_cycle_repository.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/lunar_comparison.dart';
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
  _Fixture({
    this.gender = Gender.feminine,
    this.premium = false,
    this.comConta = false,
  });

  final Gender gender;
  final bool premium;

  /// Há conta de verdade? O que decide isso no app é o e-mail
  /// (`UserModel.isAuthenticated`), e o id continua `local_user` — que é o
  /// mesmo id que a tela usa para as preferências nos dois casos.
  final bool comConta;

  /// O tratamento vem do usuário, e é por ele que a tela decide se a área
  /// sequer é oferecida — sem isto o teste do masculino olharia para o
  /// padrão do app, não para o que o teste pediu.
  @override
  UserModel get currentUser => UserModel.defaultUser().copyWith(
        gender: gender,
        email: comConta ? 'dela@exemplo.app' : null,
      );

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
    // Gravar um dia passou a escrever também a página dele no acervo: sem
    // esta limpeza, a sobra de um teste apareceria como registro no seguinte.
    await db.delete('free_writings');
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
    bool comConta = false,
  }) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
      // Uma chave por combinação: pedir a tela de novo com outro plano
      // constrói tudo do zero, em vez de herdar o provedor anterior.
      key: ValueKey('$gender-$premium-$comConta'),
      create: (_) =>
          _Fixture(gender: gender, premium: premium, comConta: comConta),
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

  testWidgets('sending to the account is off until a second, separate yes',
      (tester) async {
    // The first yes opens the wheel; it must not open the cloud. The second
    // one lives here, in its own card with its own words — never a switch
    // buried in a list of settings — and it asks again before it turns on.
    await show(tester, comConta: true);
    await tester.tap(find.byKey(const ValueKey('menstrual-consent-accept')));
    await until(
        tester,
        () => find.byKey(const ValueKey('menstrual-cloud')).evaluate().isNotEmpty,
        'the cloud card');

    expect(find.byKey(const ValueKey('menstrual-cloud-on')), findsOneWidget);
    expect(find.byKey(const ValueKey('menstrual-cloud-off')), findsNothing);
    expect(await const MenstrualConsentStore().syncAllowed('local_user'), isFalse);

    // Backing out of the confirmation really does change nothing: the yes is
    // the accept button, not the button that opens the question.
    await pressIn(tester, 'menstrual-cloud-on');
    await until(
        tester,
        () => find
            .byKey(const ValueKey('menstrual-cloud-confirm'))
            .evaluate()
            .isNotEmpty,
        'the confirmation');
    await tester.tap(find.byKey(const ValueKey('menstrual-cloud-confirm-cancel')));
    await until(
        tester,
        () =>
            find.byKey(const ValueKey('menstrual-cloud-confirm')).evaluate().isEmpty,
        'the confirmation closing');
    expect(await const MenstrualConsentStore().syncAllowed('local_user'), isFalse);
    expect(find.byKey(const ValueKey('menstrual-cloud-on')), findsOneWidget,
        reason: 'Backing out leaves the card exactly as it was');

    await pressIn(tester, 'menstrual-cloud-on');
    await until(
        tester,
        () => find
            .byKey(const ValueKey('menstrual-cloud-confirm'))
            .evaluate()
            .isNotEmpty,
        'the confirmation again');
    await tester.tap(find.byKey(const ValueKey('menstrual-cloud-confirm-accept')));
    await until(
        tester,
        () =>
            find.byKey(const ValueKey('menstrual-cloud-off')).evaluate().isNotEmpty,
        'the off button');

    expect(await const MenstrualConsentStore().syncAllowed('local_user'), isTrue);
    // A confirmação abre um aviso no rodapé, e o botão de desligar pode parar
    // debaixo dele: fechar o aviso antes do segundo toque tira a dúvida.
    final scaffold = tester.element(find.byType(Scaffold).first);
    ScaffoldMessenger.of(scaffold).clearSnackBars();
    await tester.pump();
    // Turning it off is one tap, with no second question: the way out is
    // never the part that gets made harder.
    await pressIn(tester, 'menstrual-cloud-off');
    await until(
        tester,
        () =>
            find.byKey(const ValueKey('menstrual-cloud-on')).evaluate().isNotEmpty,
        'the on button');
    expect(await const MenstrualConsentStore().syncAllowed('local_user'), isFalse);
  });

  testWidgets('with no account the card explains, and offers no yes at all',
      (tester) async {
    // Sem conta não existe para onde enviar: `DataSyncService.isReady` é
    // falso e nada sairia daqui. Oferecer o sim mesmo assim gravaria a
    // preferência sob o `local_user`, mostraria "Ligado. Seu registro
    // acompanha a sua conta" sobre uma conta que não existe, e o sim nem
    // acompanharia ela ao entrar de verdade — a chave é por conta. E
    // "apagar a cópia da nuvem" responderia que não deu para falar com a
    // conta, quando o motivo é não haver conta nenhuma.
    await show(tester);
    await tester.tap(find.byKey(const ValueKey('menstrual-consent-accept')));
    await until(
        tester,
        () => find.byKey(const ValueKey('menstrual-cloud')).evaluate().isNotEmpty,
        'the cloud card');

    final l10n = lookupAppLocalizations(const Locale('en'));
    final estado = tester.widget<Text>(
        find.byKey(const ValueKey('menstrual-cloud-state')));
    expect(estado.data, l10n.menstrualCloudStateNoAccount);
    expect(find.byKey(const ValueKey('menstrual-cloud-on')), findsNothing);
    expect(find.byKey(const ValueKey('menstrual-cloud-off')), findsNothing);
    expect(find.byKey(const ValueKey('menstrual-cloud-erase')), findsNothing);
    expect(await const MenstrualConsentStore().syncAllowed('local_user'), isFalse);
  });

  testWidgets('turning sending on does not release the days she erased first',
      (tester) async {
    // A lápide de um dia menstrual É a data em que ela sangrou e depois
    // apagou. Liberada no momento do sim, ela sairia deste aparelho na
    // primeira varredura — e o que ela autorizou foi mandar o registro, não
    // as datas que apagou antes de existir para onde mandar.
    SharedPreferences.setMockInitialValues({
      'menstrual_consent_record_local_user': true,
    });
    final repo = MenstrualCycleRepository();
    await tester.runAsync(() async {
      await repo.save(MenstrualDay(
        userId: 'local_user',
        day: DateTime(2026, 3, 4),
        mark: MenstrualMark.flow,
        note: 'o que ela apagou depois',
      ));
      await repo.remove(userId: 'local_user', day: DateTime(2026, 3, 4));
      await repo.save(MenstrualDay(
        userId: 'local_user',
        day: DateTime(2026, 3, 6),
        mark: MenstrualMark.flow,
        note: 'o que ficou',
      ));
    });

    await show(tester, comConta: true);
    await until(
        tester,
        () => find.byKey(const ValueKey('menstrual-cloud')).evaluate().isNotEmpty,
        'the cloud card');
    await pressIn(tester, 'menstrual-cloud-on');
    await until(
        tester,
        () => find
            .byKey(const ValueKey('menstrual-cloud-confirm'))
            .evaluate()
            .isNotEmpty,
        'the confirmation');
    await tester.tap(find.byKey(const ValueKey('menstrual-cloud-confirm-accept')));
    await until(
        tester,
        () =>
            find.byKey(const ValueKey('menstrual-cloud-off')).evaluate().isNotEmpty,
        'the off button');

    final lidas = await tester.runAsync(() async {
      final db = await DatabaseHelper.instance.database;
      return db.query(MenstrualCycleSchema.table,
          where: 'user_id = ?', whereArgs: ['local_user']);
    });
    final linhas = lidas ?? const <Map<String, Object?>>[];
    expect(linhas.map((l) => l['day_key']), ['2026-03-06'],
        reason: 'a data do dia apagado não fica esperando para sair daqui');
    expect(linhas.single['synced'], 0,
        reason: 'o dia vivo, esse sim, é liberado — o sim vale para o '
            'registro inteiro, não só para o que vier depois');
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

    // A folha inteira é do gratuito: a abertura e "A Lua e você" também.
    expect(find.byKey(const ValueKey('menstrual-opening')), findsOneWidget);
    expect(find.byKey(const ValueKey('lua-e-voce')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the history is no longer turned into numbers, on either plan',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {'menstrual_consent_record_local_user': true});
    // Four beginnings, twenty-eight days apart: exactly the history that used
    // to produce an average, a cycle day and a comparison with the Moon.
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
    expect(find.byKey(const ValueKey('menstrual-opening')), findsOneWidget);
    expect(find.byKey(const ValueKey('lua-e-voce')), findsOneWidget,
        reason: 'The Moon beside her beginnings is for everyone');
    expect(find.byKey(const ValueKey('menstrual-premium-invite')), findsOneWidget,
        reason: 'One line inside the calendar card, on the free plan only');
    expect(find.byKey(const ValueKey('menstrual-view-toggle')), findsNothing,
        reason: 'The wheel is still Premium');

    await show(tester, premium: true);
    await until(
        tester,
        () =>
            find.byKey(const ValueKey('menstrual-view-toggle')).evaluate().isNotEmpty,
        'the premium page');
    // O que o Premium continua tendo: a roda e a mesma folha. O que
    // ninguém tem mais: qualquer número tirado do histórico.
    expect(find.byKey(const ValueKey('menstrual-opening')), findsOneWidget);
    expect(find.byKey(const ValueKey('lua-e-voce')), findsOneWidget);
    expect(find.byKey(const ValueKey('menstrual-premium-invite')), findsNothing);
    expect(find.textContaining('28 days'), findsNothing,
        reason: 'No average survives anywhere');
    expect(find.textContaining('23/03/2026'), findsNothing,
        reason: 'No reference for a next date is estimated any more');
    expect(tester.takeException(), isNull);
  });

  testWidgets('the opening is for everyone, and the essay starts folded',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {'menstrual_consent_record_local_user': true});
    for (final premium in [false, true]) {
      await show(tester, premium: premium);
      await until(
          tester,
          () => find.byKey(const ValueKey('menstrual-opening')).evaluate().isNotEmpty,
          'the opening');
      expect(find.text('Moon Blood'), findsOneWidget);
      expect(find.byKey(const ValueKey('menstrual-about-text')), findsNothing,
          reason: 'Folded by default: the page cannot come back longer');
      expect(find.text('Read more'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const ValueKey('menstrual-opening')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('menstrual-opening')));
      await tester.pump();
      expect(find.byKey(const ValueKey('menstrual-about-text')), findsOneWidget,
          reason: 'A tap opens it on both plans');
      // O título está sempre à vista: procurá-lo não provaria abertura
      // nenhuma. Quem prova é um subtítulo do corpo.
      expect(find.text('What the blood marks'), findsOneWidget,
          reason: 'The body is only there once it is open');
      expect(find.text('Read less'), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('the sheet opens under the Moon of the day, and today wears it too',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {'menstrual_consent_record_local_user': true});
    await show(tester);
    final phase = LunarProvider.phaseOn(LunarComparison.noonOf(today));
    // A única lua protagonista da página: a de hoje, com a data por extenso.
    final eyebrow =
        tester.widget<Text>(find.byKey(const ValueKey('menstrual-today-moon')));
    expect(eyebrow.data, contains(phase.displayName));
    expect(eyebrow.data, contains('2026'));

    await tester.tap(find.byKey(const ValueKey('menstrual-record-today')));
    await openForm(tester);
    final line =
        tester.widget<Text>(find.byKey(const ValueKey('menstrual-editing-day')));
    expect(line.data, contains(phase.displayName),
        reason: 'The day in edition is named with its Moon');
    expect(line.data, contains('12'));
    expect(find.byKey(const ValueKey('menstrual-moon-invite')), findsOneWidget,
        reason: 'One sentence from the Moon of the day, inside the sheet');
    expect(find.textContaining('optional'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('how she is: the chip writes the id, and tapping again clears it',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {'menstrual_consent_record_local_user': true});
    await show(tester);
    await tester.tap(find.byKey(const ValueKey('menstrual-record-today')));
    await openForm(tester);
    await pressIn(tester, 'menstrual-mood-sensitive');
    await pressIn(tester, 'menstrual-save');
    await until(tester, () => find.byType(MenstrualRecordForm).evaluate().isEmpty,
        'the form to close after the write');
    expect(find.textContaining('Kept in your Grimoire, under the'), findsOneWidget,
        reason: 'The confirmation names the Moon of the day');

    var saved = await tester.runAsync(() =>
        MenstrualCycleRepository().dayOf(userId: 'local_user', day: today));
    expect(saved!.mood, 'sensitive', reason: 'The id is what is written');
    await until(
        tester,
        () => find.byKey(const ValueKey('menstrual-today-mood')).evaluate().isNotEmpty,
        'the mood on the day card');
    expect(find.text('You marked: Sensitive'), findsOneWidget,
        reason: 'The card speaks the label, never the id');

    await tester.tap(find.byKey(const ValueKey('menstrual-record-today')));
    await openForm(tester);
    expect(
        tester
            .widget<ChoiceChip>(find.byKey(const ValueKey('menstrual-mood-sensitive')))
            .selected,
        isTrue);
    await pressIn(tester, 'menstrual-mood-sensitive');
    await pressIn(tester, 'menstrual-save');
    await until(tester, () => find.byType(MenstrualRecordForm).evaluate().isEmpty,
        'the form to close after clearing the mood');
    saved = await tester.runAsync(() =>
        MenstrualCycleRepository().dayOf(userId: 'local_user', day: today));
    expect(saved!.mood, isNull, reason: 'Tapping the chosen chip again unchooses it');
    expect(tester.takeException(), isNull);
  });

  testWidgets('an old free word for the mood survives a save that does not touch it',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {'menstrual_consent_record_local_user': true});
    // De antes dos chips: a palavra dela, gravada como texto livre.
    await tester.runAsync(() => MenstrualCycleRepository().save(MenstrualDay(
          userId: 'local_user',
          day: today,
          mark: MenstrualMark.flow,
          mood: 'cansada',
        )));
    await show(tester);
    expect(find.text('You marked: cansada'), findsOneWidget,
        reason: 'An unknown id is shown as the word she wrote');

    await tester.tap(find.byKey(const ValueKey('menstrual-record-today')));
    await openForm(tester);
    for (final id in ['light', 'sensitive', 'irritable', 'sad', 'strong', 'at_peace']) {
      expect(
          tester.widget<ChoiceChip>(find.byKey(ValueKey('menstrual-mood-$id'))).selected,
          isFalse,
          reason: 'No chip claims a word that is not one of theirs');
    }
    await tester.ensureVisible(find.byKey(const ValueKey('menstrual-note')));
    await tester.pump();
    await tester.enterText(find.byKey(const ValueKey('menstrual-note')), 'still tired');
    await tester.pump();
    await pressIn(tester, 'menstrual-save');
    await until(tester, () => find.byType(MenstrualRecordForm).evaluate().isEmpty,
        'the form to close');
    var saved = await tester.runAsync(() =>
        MenstrualCycleRepository().dayOf(userId: 'local_user', day: today));
    expect(saved!.mood, 'cansada', reason: 'Untouched, the old word stays');
    expect(saved.note, 'still tired');

    // Escolher um chip é o único gesto que a substitui.
    await tester.tap(find.byKey(const ValueKey('menstrual-record-today')));
    await openForm(tester);
    await pressIn(tester, 'menstrual-mood-strong');
    await pressIn(tester, 'menstrual-save');
    await until(tester, () => find.byType(MenstrualRecordForm).evaluate().isEmpty,
        'the form to close after choosing');
    saved = await tester.runAsync(() =>
        MenstrualCycleRepository().dayOf(userId: 'local_user', day: today));
    expect(saved!.mood, 'strong');
    expect(tester.takeException(), isNull);
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
  Future<List<MenstrualDay>> history(String userId) async => const [];

  @override
  Future<MenstrualDay> save(MenstrualDay day) async =>
      throw Exception('disk full');
}
