import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/reading_session_schema.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/divination/data/data_sources/oracle_cards_data.dart';
import 'package:grimorio_de_bolso/features/divination/data/repositories/oracle_discovery_repository.dart';
import 'package:grimorio_de_bolso/features/divination/presentation/pages/oracle_album_page.dart';
import 'package:grimorio_de_bolso/features/divination/presentation/widgets/oracle_card_face.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'support/short_test_timeout.dart';

class _AuthFixture extends AuthProvider {}

void main() {
  useShortTestTimeout();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfiNoIsolate;
  late String user;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    final dir = await Directory.systemTemp.createTemp('oracle_album');
    await databaseFactory.setDatabasesPath(dir.path);
    await DatabaseHelper.instance.database;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    for (final table in [...ReadingSessionSchema.tables, 'oracle_readings']) {
      await db.delete(table);
    }
    user = _AuthFixture().currentUser.id;
  });

  /// Semeia uma leitura. Dentro de um teste de widget o banco só anda no
  /// tempo real, então a chamada precisa de `runAsync` — senão a gravação
  /// nunca completa e o teste espera o limite inteiro.
  Future<void> seedReading(String id, List<int> cardIds, DateTime when) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('oracle_readings', {
      'id': id,
      'user_id': user,
      'spread_type': 'single',
      'reading_data': jsonEncode({
        'cards': [
          for (final cardId in cardIds)
            {
              'position': 0,
              'card': oracleCardsData.firstWhere((c) => c.id == cardId).toJson(),
              'positionMeaning': '',
            },
        ],
      }),
      'date': when.millisecondsSinceEpoch,
      'created_at': when.millisecondsSinceEpoch,
      'updated_at': when.millisecondsSinceEpoch,
      'synced': 0,
    });
  }

  Future<void> until(WidgetTester tester, bool Function() ready, String stage) async {
    for (var i = 0; i < 150; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 50));
      if (ready()) return;
    }
    fail('The album did not reach: $stage');
  }

  Future<void> show(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
      create: (_) => _AuthFixture(),
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: const OracleAlbumPage(),
      ),
    ));
    await until(tester, () => find.byKey(const ValueKey('oracle-album')).evaluate().isNotEmpty,
        'the album grid');
  }

  test('the retrospective counts each card once, keeping the first date', () async {
    await seedReading('r2', [2, 3], DateTime(2026, 3, 2));
    await seedReading('r1', [1, 2], DateTime(2026, 3, 1));
    final repository = OracleDiscoveryRepository();
    await repository.backfill(user);
    expect(await repository.discovered(user), {1, 2, 3});

    final found = await repository.firstSeen(user);
    expect(found[2], DateTime(2026, 3, 1),
        reason: 'The repeated card keeps the earliest encounter');

    // A second pass never adds or moves anything.
    await repository.backfill(user);
    expect(await repository.discovered(user), {1, 2, 3});
    expect((await repository.firstSeen(user))[2], DateTime(2026, 3, 1));

    // A reading that only repeats cards leaves the count alone.
    await seedReading('r3', [1, 3], DateTime(2026, 3, 3));
    await repository.backfill(user);
    expect(await repository.discovered(user), hasLength(3));
  });

  testWidgets('the album opens the cards already met and keeps the others closed',
      (tester) async {
    await tester.runAsync(() => seedReading('r1', [1, 2], DateTime(2026, 3, 1)));
    await show(tester);
    final total = oracleCardsData.length;
    expect(find.text('2 of $total cards discovered'), findsOneWidget);
    expect(find.byKey(const ValueKey('oracle-album-card-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('oracle-album-card-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('oracle-album-locked-3')), findsOneWidget);
    // A card never met shows no face, so its name and message stay unseen.
    final unmet = oracleCardsData.firstWhere((c) => c.id == 3);
    expect(find.text(unmet.name), findsNothing);
    expect(
        tester.widgetList<OracleCardFace>(find.byType(OracleCardFace))
            .map((face) => face.card.id)
            .toSet(),
        {1, 2});
    expect(find.byKey(const ValueKey('oracle-album-empty')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('with nothing discovered the album says where the cards come from',
      (tester) async {
    await show(tester);
    final total = oracleCardsData.length;
    expect(find.text('0 of $total cards discovered'), findsOneWidget);
    expect(find.byKey(const ValueKey('oracle-album-empty')), findsOneWidget);
    expect(find.byType(OracleCardFace), findsNothing,
        reason: 'Nothing is revealed before a reading is confirmed');
    expect(tester.takeException(), isNull);
  });
}
