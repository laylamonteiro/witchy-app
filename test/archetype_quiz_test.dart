import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/archetype_quiz_data.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/archetypes_data.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/pages/archetype_quiz_page.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/widgets/archetype_constellation.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/short_test_timeout.dart';

void main() {
  useShortTestTimeout();

  List<String> catalog() => [for (final entry in archetypesData) entry.emoji];

  group('constellation', () {
    test('the same answers always draw the same figure', () {
      final order = catalog();
      final scores = {order[0]: 3, order[4]: 2, order[2]: 1};
      final first = ArchetypeConstellation.stars(
          scores: scores, order: order, winner: order[0]);
      final again = ArchetypeConstellation.stars(
          scores: Map<String, int>.from(scores), order: order, winner: order[0]);
      expect(first.map((s) => s.key), again.map((s) => s.key));
      for (var i = 0; i < first.length; i++) {
        expect(first[i].position, again[i].position);
        expect(first[i].weight, again[i].weight);
      }
    });

    test('only archetypes the answers touched get a star, and the winner glows', () {
      final order = catalog();
      final stars = ArchetypeConstellation.stars(
        scores: {order[1]: 5, order[3]: 0, order[6]: 2},
        order: order,
        winner: order[1],
      );
      expect(stars.map((s) => s.key), [order[1], order[6]],
          reason: 'A zero score is not in the sky, and the order is the catalog order');
      expect(stars.first.isWinner, isTrue);
      expect(stars.last.isWinner, isFalse);
      expect(stars.first.weight, 1);
      expect(stars.last.weight, closeTo(.4, 0.001));
      // More points sit closer to the centre.
      final centre = const Offset(.5, .5);
      expect((stars.first.position - centre).distance,
          lessThan((stars.last.position - centre).distance));
    });

    test('no answers, no constellation', () {
      expect(ArchetypeConstellation.stars(
          scores: const {}, order: catalog(), winner: ''), isEmpty);
    });
  });

  Future<void> show(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1200);
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
      home: const ArchetypeQuizPage(),
    ));
    await tester.pump();
  }

  Future<void> settle(WidgetTester tester, bool Function() ready, String stage) async {
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      if (ready()) return;
    }
    fail('The quiz did not reach: $stage');
  }

  testWidgets('answering keeps the same score and only shows the result once it is saved',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await show(tester);
    final questions = archetypeQuizQuestions.length;
    for (var i = 0; i < questions; i++) {
      await tester.ensureVisible(find.byType(InkWell).first);
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();
    }
    await settle(tester, () => find.byKey(const ValueKey('quiz-result-name')).evaluate().isNotEmpty,
        'the archetype');

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('archetype_result');
    expect(saved, isNotNull, reason: 'The result is written before it is shown');
    final winner = archetypesData.firstWhere((e) => e.emoji == saved);
    expect(find.text(winner.name), findsWidgets);
    // Eight answers, eight points, split among the archetypes they touched.
    final top = prefs.getStringList('archetype_top3')!;
    expect(top, isNotEmpty);
    expect(top.map((raw) => int.parse(raw.split('|').last)).reduce((a, b) => a + b),
        lessThanOrEqualTo(questions));
    expect(find.byKey(const ValueKey('quiz-constellation')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a saved archetype opens straight to its result', (tester) async {
    final order = catalog();
    SharedPreferences.setMockInitialValues({
      'archetype_result': order.first,
      'archetype_top3': <String>['${order.first}|5', '${order[1]}|3'],
      'archetype_date': '01/03/2026',
    });
    await show(tester);
    await settle(tester, () => find.byKey(const ValueKey('quiz-result-name')).evaluate().isNotEmpty,
        'the saved archetype');
    expect(find.text(archetypesData.first.name), findsWidgets);
    expect(find.byType(InkWell).evaluate().isEmpty, isFalse);
    expect(find.byKey(const ValueKey('quiz-constellation')), findsNothing,
        reason: 'The constellation belongs to the session that was just answered');
    expect(tester.takeException(), isNull);
  });
}
