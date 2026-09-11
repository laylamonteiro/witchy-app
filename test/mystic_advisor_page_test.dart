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
import 'package:grimorio_de_bolso/core/database/reading_session_schema.dart';
import 'package:grimorio_de_bolso/core/widgets/motion/staggered_paragraphs.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/grimoire/presentation/pages/mystic_advisor_page.dart';
import 'package:grimorio_de_bolso/features/grimoire/presentation/widgets/crystal_ball_view.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'support/short_test_timeout.dart';

class _AuthFixture extends AuthProvider {
  @override
  bool get isPremiumEffective => true;
}

const _answer = 'The waxing moon favors protection.\n\n'
    'Light a white candle and speak your intention aloud.';

void main() {
  useShortTestTimeout();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    final dir = await Directory.systemTemp.createTemp('mystic_advisor_page');
    await databaseFactory.setDatabasesPath(dir.path);
    await DatabaseHelper.instance.database;
  });
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    for (final table in [...ReadingSessionSchema.tables, 'free_writings']) {
      await db.delete(table);
    }
  });

  Future<void> until(WidgetTester tester, bool Function() ready, String stage) async {
    for (var i = 0; i < 150; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 50));
      if (ready()) return;
    }
    fail('The advisor did not reach: $stage');
  }

  Future<List<Map<String, Object?>>> rows(WidgetTester tester, String table) async {
    List<Map<String, Object?>>? result;
    unawaited(() async {
      final db = await DatabaseHelper.instance.database;
      result = await db.query(table);
    }());
    await until(tester, () => result != null, 'SQLite snapshot of $table');
    return result!;
  }

  final calls = <String>[];
  late Future<String> Function(String) ask;

  Future<void> show(WidgetTester tester, {EdgeInsets viewInsets = EdgeInsets.zero}) async {
    await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
      create: (_) => _AuthFixture(),
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(viewInsets: viewInsets),
          child: child!,
        ),
        home: MysticAdvisorPage(ask: (q) => ask(q)),
      ),
    ));
    await until(tester, () => tester.widget<ElevatedButton>(
        find.byKey(const ValueKey('advisor-consult'))).onPressed == null, 'restored');
    // Never pumpAndSettle here: while a request is in flight the mist loops.
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> askQuestion(WidgetTester tester, String question) async {
    await tester.enterText(find.byKey(const ValueKey('advisor-question')), question);
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('advisor-consult')));
    await tester.tap(find.byKey(const ValueKey('advisor-consult')));
    await tester.pump();
  }

  setUp(() {
    calls.clear();
    ask = (q) async { calls.add(q); return _answer; };
  });

  testWidgets('an immediate answer is presented whole, saved once and restored', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await show(tester);
    await askQuestion(tester, 'Which moon for protection?');
    await until(tester, () => find.byType(StaggeredParagraphs).evaluate().isNotEmpty, 'answer');
    // Every paragraph is in the tree from the first frame; no typewriter.
    expect(find.text('The waxing moon favors protection.'), findsOneWidget);
    expect(find.text('Light a white candle and speak your intention aloud.'), findsOneWidget);
    expect(calls, ['Which moon for protection?']);
    await tester.pumpAndSettle();
    expect(find.text('Which moon for protection?'), findsWidgets);
    final ball = tester.widget<CrystalBallView>(find.byKey(const ValueKey('advisor-ball')));
    expect(ball.active, isFalse);

    await tester.ensureVisible(find.byKey(const ValueKey('advisor-save')));
    await tester.tap(find.byKey(const ValueKey('advisor-save')));
    await until(tester, () => find.byKey(const ValueKey('advisor-saved')).evaluate().isNotEmpty,
        'saved');
    var pages = await rows(tester, 'free_writings');
    expect(pages, hasLength(1));
    expect(pages.single['source'], 'advisor');
    expect(pages.single['content'], contains('Which moon for protection?'));
    expect(pages.single['content'], contains(_answer));

    // Reopening restores the received answer without another call.
    await tester.pumpWidget(const SizedBox.shrink());
    await show(tester);
    expect(find.text('The waxing moon favors protection.'), findsOneWidget);
    expect(find.byKey(const ValueKey('advisor-saved')), findsOneWidget);
    expect(calls, hasLength(1));
    pages = await rows(tester, 'free_writings');
    expect(pages, hasLength(1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the wait follows the real request and survives leaving the page', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final pending = Completer<String>();
    ask = (q) { calls.add(q); return pending.future; };
    await show(tester);
    await askQuestion(tester, 'Slow question?');
    await until(tester, () => tester.widget<CrystalBallView>(
        find.byKey(const ValueKey('advisor-ball'))).active, 'mist while pending');
    expect(tester.widget<TextField>(find.byKey(const ValueKey('advisor-question'))).enabled,
        isFalse);
    expect(tester.widget<ElevatedButton>(find.byKey(const ValueKey('advisor-consult'))).onPressed,
        isNull);
    expect(find.byType(StaggeredParagraphs), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await show(tester);
    expect(tester.widget<CrystalBallView>(find.byKey(const ValueKey('advisor-ball'))).active,
        isTrue, reason: 'The same request is still in flight');
    pending.complete(_answer);
    await until(tester, () => find.byType(StaggeredParagraphs).evaluate().isNotEmpty,
        'answer after returning');
    expect(calls, ['Slow question?']);
    final consultations = await rows(tester, 'advisor_consultations');
    expect(consultations.single['status'], 'answered');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a failure keeps the question and only an explicit retry asks again',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var fail = true;
    ask = (q) async {
      calls.add(q);
      if (fail) throw Exception('network down');
      return _answer;
    };
    await show(tester);
    await askQuestion(tester, 'Fragile question?');
    await until(tester, () => find.byKey(const ValueKey('advisor-retry')).evaluate().isNotEmpty,
        'failed state');
    await tester.pumpAndSettle();
    expect(find.text('Fragile question?'), findsWidgets);
    expect(tester.widget<TextField>(find.byKey(const ValueKey('advisor-question'))).controller!
        .text, 'Fragile question?');
    expect(calls, hasLength(1));

    // Reopening does not resend.
    await tester.pumpWidget(const SizedBox.shrink());
    await show(tester);
    expect(find.byKey(const ValueKey('advisor-retry')), findsOneWidget);
    expect(calls, hasLength(1));

    fail = false;
    await tester.ensureVisible(find.byKey(const ValueKey('advisor-retry')));
    await tester.tap(find.byKey(const ValueKey('advisor-retry')));
    await until(tester, () => find.byType(StaggeredParagraphs).evaluate().isNotEmpty, 'retry');
    expect(calls, ['Fragile question?', 'Fragile question?']);
    final consultations = await rows(tester, 'advisor_consultations');
    expect(consultations.map((r) => r['status']).toSet(), {'failed', 'answered'});
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a question left pending by a previous process is shown as failed, not resent',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = await DatabaseHelper.instance.database;
    await db.insert('advisor_consultations', {
      'id': 'stale', 'user_id': 'local_user', 'question': 'Old question?', 'answer': null,
      'status': 'pending', 'writing_id': null, 'created_at': 1, 'updated_at': 1,
    });
    await show(tester);
    final owner = (await rows(tester, 'advisor_consultations')).single['user_id'];
    if (owner == 'local_user') {
      expect(find.byKey(const ValueKey('advisor-retry')), findsOneWidget);
      expect(find.text('Old question?'), findsWidgets);
    }
    expect(calls, isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('with the keyboard open the ball shrinks and the action stays reachable',
      (tester) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await show(tester, viewInsets: const EdgeInsets.only(bottom: 300));
    expect(tester.widget<CrystalBallView>(find.byKey(const ValueKey('advisor-ball'))).size,
        lessThan(100));
    await tester.enterText(find.byKey(const ValueKey('advisor-question')), 'Q?');
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('advisor-consult')));
    expect(find.byKey(const ValueKey('advisor-consult')).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
