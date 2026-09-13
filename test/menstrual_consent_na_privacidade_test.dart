import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/menstrual_cycle_schema.dart';
import 'package:grimorio_de_bolso/core/i18n/gender.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/user_model.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/menstrual_consent_store.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/repositories/menstrual_cycle_repository.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_day.dart';
import 'package:grimorio_de_bolso/features/settings/presentation/pages/privacy_settings_page.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'support/short_test_timeout.dart';

/// O SEGUNDO sim mudou de lugar: guardar o registro do ciclo na conta saiu da
/// folha do Ciclo e passou a viver em Configurações → Privacidade, ao lado
/// das outras decisões sobre dado, com o texto resumido.
///
/// O que este arquivo guarda é que MUDOU SÓ O LUGAR. As regras continuam as
/// mesmas: nasce desligado, sem conta não há sim, ligar pergunta de novo,
/// desligar é um toque só, e as datas que ela apagou antes não são liberadas
/// para sair daqui por causa deste interruptor.
class _Fixture extends AuthProvider {
  _Fixture({this.gender = Gender.feminine, this.comConta = false});

  final Gender gender;

  /// Há conta de verdade? Quem decide isso no app é o e-mail
  /// (`UserModel.isAuthenticated`); o id continua `local_user` nos dois casos.
  final bool comConta;

  @override
  UserModel get currentUser => UserModel.defaultUser().copyWith(
        gender: gender,
        email: comConta ? 'dela@exemplo.app' : null,
      );

  @override
  bool get isPremiumEffective => false;
}

void main() {
  useShortTestTimeout();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfiNoIsolate;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    final dir = await Directory.systemTemp.createTemp('menstrual_privacy');
    await databaseFactory.setDatabasesPath(dir.path);
    await DatabaseHelper.instance.database;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    await db.delete(MenstrualCycleSchema.table);
    await db.delete('free_writings');
  });

  Future<void> until(
      WidgetTester tester, bool Function() ready, String stage) async {
    for (var i = 0; i < 150; i++) {
      await tester
          .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 50));
      if (ready()) return;
    }
    fail('Privacy did not reach: $stage');
  }

  Future<void> show(
    WidgetTester tester, {
    Gender gender = Gender.feminine,
    bool comConta = false,
  }) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
      key: ValueKey('$gender-$comConta'),
      create: (_) => _Fixture(gender: gender, comConta: comConta),
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: const PrivacySettingsPage(),
      ),
    ));
    await until(tester, () => find.byType(ListTile).evaluate().isNotEmpty,
        'the settings list');
  }

  testWidgets('without the first yes there is nothing to decide here',
      (tester) async {
    await show(tester, comConta: true);
    expect(find.byKey(const ValueKey('menstrual-cloud')), findsNothing,
        reason: 'The block only exists after she said yes to recording');
    expect(tester.takeException(), isNull);
  });

  testWidgets('in the masculine the block is not offered at all',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {'menstrual_consent_record_local_user': true});
    await show(tester, gender: Gender.masculine, comConta: true);
    expect(find.byKey(const ValueKey('menstrual-cloud')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('with no account the block explains and offers no yes',
      (tester) async {
    // Sem conta não há para onde enviar: ligar gravaria a preferência sob o
    // `local_user`, que não sobe nada e não acompanha ela ao entrar de
    // verdade. Um sim que não tem efeito é um sim que engana.
    SharedPreferences.setMockInitialValues(
        {'menstrual_consent_record_local_user': true});
    await show(tester);
    await until(
        tester,
        () => find.byKey(const ValueKey('menstrual-cloud')).evaluate().isNotEmpty,
        'the cycle block');
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.menstrualCloudStateNoAccount), findsOneWidget);
    expect(find.byKey(const ValueKey('menstrual-cloud-erase')), findsNothing);
    final chave = tester.widget<Switch>(find.descendant(
      of: find.byKey(const ValueKey('menstrual-cloud')),
      matching: find.byType(Switch),
    ));
    expect(chave.onChanged, isNull, reason: 'There is no yes to give');
    expect(await const MenstrualConsentStore().syncAllowed('local_user'), isFalse);
    expect(tester.takeException(), isNull);
  });

  /// O interruptor do bloco do Ciclo. O ListTile não tem toque próprio: quem
  /// recebe o gesto é o Switch.
  Finder chaveDoCiclo() => find.descendant(
        of: find.byKey(const ValueKey('menstrual-cloud')),
        matching: find.byType(Switch),
      );

  Future<void> tocarNaChave(WidgetTester tester) async {
    await tester.ensureVisible(chaveDoCiclo());
    await tester.pump();
    await tester.tap(chaveDoCiclo());
    await tester.pump();
  }

  testWidgets('turning it on asks again; turning it off is a single tap',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {'menstrual_consent_record_local_user': true});
    await show(tester, comConta: true);
    await until(
        tester,
        () => find.byKey(const ValueKey('menstrual-cloud')).evaluate().isNotEmpty,
        'the cycle block');
    expect(await const MenstrualConsentStore().syncAllowed('local_user'), isFalse,
        reason: 'It is born off');

    // Recuar na confirmação não muda nada: o sim é o botão de aceitar, não o
    // gesto que abre a pergunta.
    await tocarNaChave(tester);
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
    expect(tester.widget<Switch>(chaveDoCiclo()).value, isFalse,
        reason: 'Backing out leaves the block exactly as it was');

    await tocarNaChave(tester);
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
        () => tester.any(chaveDoCiclo()) &&
            tester.widget<Switch>(chaveDoCiclo()).value,
        'the switch turned on');
    expect(await const MenstrualConsentStore().syncAllowed('local_user'), isTrue);

    // A confirmação abre um aviso no rodapé, e ele pode cobrir o alvo.
    final scaffold = tester.element(find.byType(Scaffold).first);
    ScaffoldMessenger.of(scaffold).clearSnackBars();
    await tester.pump();
    // Desligar é um toque só, sem segunda pergunta: a saída nunca é a parte
    // que se dificulta.
    await tocarNaChave(tester);
    await until(
        tester,
        () => tester.any(chaveDoCiclo()) &&
            !tester.widget<Switch>(chaveDoCiclo()).value,
        'the switch turned off');
    expect(await const MenstrualConsentStore().syncAllowed('local_user'), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('turning it on does not release the days she erased first',
      (tester) async {
    // A lápide de um dia menstrual É a data em que ela sangrou e depois
    // apagou. Liberada no momento do sim, sairia deste aparelho na primeira
    // varredura — e o que ela autorizou foi guardar o registro, não as datas
    // que apagou antes de existir para onde mandar.
    SharedPreferences.setMockInitialValues(
        {'menstrual_consent_record_local_user': true});
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
        'the cycle block');
    await tocarNaChave(tester);
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
        () => tester.any(chaveDoCiclo()) &&
            tester.widget<Switch>(chaveDoCiclo()).value,
        'the switch turned on');

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
    expect(tester.takeException(), isNull);
  });
}
