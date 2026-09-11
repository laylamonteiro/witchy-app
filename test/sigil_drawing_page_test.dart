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
import 'package:grimorio_de_bolso/features/sigils/data/models/sigil_model.dart';
import 'package:grimorio_de_bolso/features/sigils/data/models/sigil_wheel_model.dart';
import 'package:grimorio_de_bolso/features/sigils/domain/sigil_trace.dart';
import 'package:grimorio_de_bolso/features/sigils/presentation/pages/sigil_step2_letters_page.dart';
import 'package:grimorio_de_bolso/features/sigils/presentation/pages/sigil_step3_drawing_page.dart';
import 'package:grimorio_de_bolso/features/sigils/presentation/widgets/sigil_drawing_painter.dart';
import 'package:grimorio_de_bolso/features/sigils/presentation/widgets/sigil_letters_transition.dart';
import 'package:grimorio_de_bolso/features/sigils/presentation/widgets/witch_wheel_painter.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'support/short_test_timeout.dart';

class _AuthFixture extends AuthProvider {
  @override
  bool get isPremiumEffective => false;
}

void main() {
  useShortTestTimeout();
  final sigil = Sigil.fromIntention('PROTECAO');

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    final dir = await Directory.systemTemp.createTemp('sigil_drawing_page');
    await databaseFactory.setDatabasesPath(dir.path);
    await DatabaseHelper.instance.database;
  });

  setUp(() async {
    SigilTrace.resetCache();
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    await db.delete('sigils');
  });

  Future<void> until(WidgetTester tester, bool Function() ready, String stage) async {
    for (var i = 0; i < 150; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 50));
      if (ready()) return;
    }
    fail('The sigil did not reach: $stage');
  }

  Future<void> show(WidgetTester tester, {bool reduced = false}) async {
    tester.view.physicalSize = const Size(390, 1400);
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
          data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
          child: child!,
        ),
        home: SigilStep3DrawingPage(sigil: sigil),
      ),
    ));
    await tester.pump();
  }

  /// Uma leitura do banco fora da zona de tempo falso, como nas outras telas.
  Future<List<Map<String, Object?>>> rows(WidgetTester tester, String table) async {
    List<Map<String, Object?>>? result;
    unawaited(() async {
      final db = await DatabaseHelper.instance.database;
      result = await db.query(table);
    }());
    await until(tester, () => result != null, 'SQLite snapshot of $table');
    return result!;
  }

  SigilDrawingPainter painterOf(WidgetTester tester) =>
      tester.widget<CustomPaint>(find.byKey(const ValueKey('sigil-drawing')))
          .foregroundPainter! as SigilDrawingPainter;

  WitchWheelPainter wheelOf(WidgetTester tester) =>
      tester.widget<CustomPaint>(find.byKey(const ValueKey('sigil-drawing')))
          .painter! as WitchWheelPainter;

  testWidgets('the tracing runs once and settles on the whole symbol', (tester) async {
    await show(tester);
    expect(painterOf(tester).progress, lessThan(1));
    expect(find.byKey(const ValueKey('sigil-trace-hint')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    final midway = painterOf(tester).progress;
    expect(midway, greaterThan(0));
    expect(midway, lessThan(1));
    await tester.pump(const Duration(milliseconds: 900));
    expect(painterOf(tester).progress, 1);
    await tester.pumpAndSettle();
    expect(painterOf(tester).progress, 1, reason: 'It settles and stays settled');
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion draws the settled symbol on the first frame',
      (tester) async {
    await show(tester, reduced: true);
    expect(painterOf(tester).progress, 1);
    expect(painterOf(tester).blend, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a tap finishes the tracing at the same final symbol', (tester) async {
    await show(tester);
    await tester.pump(const Duration(milliseconds: 200));
    expect(painterOf(tester).progress, lessThan(1));
    await tester.tap(find.byKey(const ValueKey('sigil-drawing')));
    await tester.pump();
    expect(painterOf(tester).progress, 1);
    // The anticipated symbol is the same route as the one drawn to the end.
    final anticipated = SigilTrace.of(intention: sigil.intention, size: const Size(360, 360));
    expect(anticipated.upTo(1).getBounds(), anticipated.path.getBounds());
    expect(tester.takeException(), isNull);
  });

  testWidgets('rearranging the letters travels from the old positions and then settles',
      (tester) async {
    await show(tester);
    await tester.pump(const Duration(milliseconds: 900));
    expect(painterOf(tester).progress, 1);

    await tester.ensureVisible(find.byIcon(Icons.shuffle));
    await tester.tap(find.byIcon(Icons.shuffle));
    await tester.pump();
    final moving = painterOf(tester);
    expect(moving.previousPositions, isNotNull,
        reason: 'The letters leave from where they were');
    expect(moving.blend, lessThan(1));
    expect(moving.customPositions, isNotNull);
    expect(moving.progress, 1, reason: 'Only the geometry travels; the trace is whole');
    // The wheel walks each letter along its own ring, never jumping.
    final wheel = wheelOf(tester);
    final travelling = wheel.customPositions!.entries
        .where((e) => e.value.angle != SigilWheel.letterPositions[e.key]!.angle)
        .toList();
    expect(travelling, isNotEmpty, reason: 'A shuffle moves letters');
    final letter = travelling.first;
    expect(wheel.angleFor(letter.key, letter.value), isNot(letter.value.angle),
        reason: 'It has not arrived yet');
    expect(wheel.angleFor(letter.key, letter.value),
        SigilWheel.letterPositions[letter.key]!.angle,
        reason: 'It leaves from where it was');

    await tester.pump(const Duration(milliseconds: 500));
    expect(painterOf(tester).blend, 1);
    expect(painterOf(tester).previousPositions, isNull,
        reason: 'Arrived, the measured route is reusable again');
    expect(wheelOf(tester).angleFor(letter.key, letter.value), letter.value.angle);
    expect(tester.takeException(), isNull);
  });

  testWidgets('replaying redraws without changing the result', (tester) async {
    await show(tester, reduced: true);
    expect(painterOf(tester).progress, 1);
    await tester.ensureVisible(find.byKey(const ValueKey('sigil-trace-replay')));
    await tester.tap(find.byKey(const ValueKey('sigil-trace-replay')));
    await tester.pump();
    expect(painterOf(tester).progress, 1,
        reason: 'With reduced motion there is nothing to replay');
    expect(tester.takeException(), isNull);
  });

  testWidgets('finishing waits for the write before leaving', (tester) async {
    tester.view.physicalSize = const Size(390, 1400);
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
        home: Builder(builder: (context) => Scaffold(
          body: Center(child: ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => SigilStep3DrawingPage(sigil: sigil))),
            child: const Text('open'),
          )),
        )),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(SigilStep3DrawingPage), findsOneWidget);

    final l10n = AppLocalizations.of(tester.element(find.byType(SigilStep3DrawingPage)));
    await tester.ensureVisible(find.text(l10n.commonFinish));
    await tester.tap(find.text(l10n.commonFinish));
    await until(tester, () => find.byType(SigilStep3DrawingPage).evaluate().isEmpty,
        'the drawing to close after the write');
    final saved = await rows(tester, 'sigils');
    expect(saved, hasLength(1), reason: 'It only leaves after the write');
    expect(saved.single['intention'], 'PROTECAO');
    expect(tester.takeException(), isNull);
  });

  testWidgets('the letters of the intention keep exactly what the rule left',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: SigilStep2LettersPage(sigil: Sigil.fromIntention('PROTECAO')),
    ));
    await tester.pump();
    expect(find.byType(SigilLettersTransition), findsOneWidget);
    // PROTECAO keeps P R O T E C A: the repeated O is gone from the tree.
    final tiles = tester.widgetList<Text>(find.descendant(
        of: find.byType(SigilLettersTransition), matching: find.byType(Text)));
    expect(tiles.map((t) => t.data).join(), 'PROTECA');
    expect(tester.takeException(), isNull);
  });
}
