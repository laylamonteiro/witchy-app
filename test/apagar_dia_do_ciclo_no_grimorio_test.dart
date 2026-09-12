import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/menstrual_cycle_schema.dart';
import 'package:grimorio_de_bolso/features/diary/data/models/free_writing_model.dart';
import 'package:grimorio_de_bolso/features/diary/presentation/providers/free_writing_provider.dart';
import 'package:grimorio_de_bolso/features/grimoire/presentation/pages/record_detail_page.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/repositories/menstrual_cycle_repository.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_day.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'support/short_test_timeout.dart';

/// A página do dia do ciclo no Grimório ganhou um "apagar" (pedido da dona,
/// 12/09). Apagar ali não é apagar uma página: é apagar o DIA — pelo
/// repositório do ciclo, que tira a página junto. Este teste garante que o
/// botão existe só nessa página, que ele passa pela confirmação, e que
/// depois dele nem o dia nem a página sobrevivem.
void main() {
  useShortTestTimeout();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfiNoIsolate;
  const userId = 'local_user';
  final day = DateTime(2026, 3, 12);

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    final dir =
        await Directory.systemTemp.createTemp('apagar_dia_do_ciclo_grimorio');
    await databaseFactory.setDatabasesPath(dir.path);
    await DatabaseHelper.instance.database;
  });

  setUp(() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(MenstrualCycleSchema.table);
    await db.delete('free_writings');
  });

  Future<void> until(
      WidgetTester tester, bool Function() ready, String stage) async {
    for (var i = 0; i < 150; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 50));
      if (ready()) return;
    }
    fail('The record did not reach: $stage');
  }

  testWidgets('deleting the cycle page in the Grimoire deletes the day',
      (tester) async {
    final repository = MenstrualCycleRepository();
    await repository.save(MenstrualDay(
      userId: userId,
      day: day,
      mark: MenstrualMark.flow,
      note: 'quiet day',
    ));
    final provider = FreeWritingProvider();
    await provider.setUserId(userId);
    final page = provider.freeWritings
        .singleWhere((w) => w.source == FreeWritingSource.menstrual);

    await tester.pumpWidget(ChangeNotifierProvider<FreeWritingProvider>.value(
      value: provider,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // A página de detalhe é EMPURRADA, como no app: apagar a fecha com
        // `pop`, e a raiz não pode ser ela.
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              key: const ValueKey('open'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecordDetailPage(
                    entry: page,
                    menstrualRepository: repository,
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.byKey(const ValueKey('open')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('record-cycle-delete')), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsNothing,
        reason: 'The day is edited on the wheel, not here');

    await tester.tap(find.byKey(const ValueKey('record-cycle-delete')));
    await tester.pumpAndSettle();
    expect(find.text('Delete this cycle day? Its page leaves the Grimoire with it.'),
        findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('record-delete-confirm')));
    await until(
        tester,
        () => find.byType(RecordDetailPage).evaluate().isEmpty,
        'the detail page closing');

    expect(await repository.dayOf(userId: userId, day: day), isNull,
        reason: 'The day itself is gone, not only its page');
    expect(
        provider.freeWritings
            .where((w) => w.source == FreeWritingSource.menstrual),
        isEmpty,
        reason: 'The archive list reads from the provider, reloaded');
  });
}
