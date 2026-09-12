import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/archetype_identity.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/archetype_quiz_data.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/archetypes_data.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/pages/archetype_quiz_page.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/widgets/archetype_constellation.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/short_test_timeout.dart';

void main() {
  useShortTestTimeout();

  group('constellation', () {
    test('the same answers always draw the same figure', () {
      // O catálogo de chaves é o dos ids: é por eles que a sessão pontua e é
      // o que vai para o aparelho. O emoji ficou só como desenho.
      final order = archetypeIds;
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
      final order = archetypeIds;
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
          scores: const {}, order: archetypeIds, winner: ''), isEmpty);
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

  Finder resultName() => find.byKey(const ValueKey('quiz-result-name'));

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
    await settle(tester, () => resultName().evaluate().isNotEmpty, 'the archetype');

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('archetype_result');
    expect(saved, isNotNull, reason: 'The result is written before it is shown');
    // O que fica no aparelho é o id, não o desenho.
    expect(archetypeIds, contains(saved));
    final winner = archetypeForId(saved!)!;
    expect(find.text(winner.name), findsWidgets);
    // Eight answers, eight points, split among the archetypes they touched.
    final top = prefs.getStringList('archetype_top3')!;
    expect(top, isNotEmpty);
    expect(top.map((raw) => raw.split('|').first), everyElement(isIn(archetypeIds)));
    expect(top.map((raw) => int.parse(raw.split('|').last)).reduce((a, b) => a + b),
        lessThanOrEqualTo(questions));
    expect(find.byKey(const ValueKey('quiz-constellation')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a saved archetype opens straight to its result', (tester) async {
    SharedPreferences.setMockInitialValues({
      'archetype_result': archetypeIds.first,
      'archetype_top3': <String>['${archetypeIds.first}|5', '${archetypeIds[1]}|3'],
      'archetype_date': '01/03/2026',
    });
    await show(tester);
    await settle(tester, () => resultName().evaluate().isNotEmpty, 'the saved archetype');
    expect(find.text(archetypesData.first.name), findsWidgets);
    expect(find.byType(InkWell).evaluate().isEmpty, isFalse);
    expect(find.byKey(const ValueKey('quiz-constellation')), findsNothing,
        reason: 'The constellation belongs to the session that was just answered');
    expect(tester.takeException(), isNull);
  });

  testWidgets('a result saved by the old emoji survives, and is rewritten by id',
      (tester) async {
    // Exatamente o que está no aparelho de quem fez o teste antes desta
    // versão: o resultado e as energias gravados pelo símbolo.
    final seer = archetypesData[2];
    final witch = archetypesData.first;
    SharedPreferences.setMockInitialValues({
      'archetype_result': seer.emoji,
      'archetype_top3': <String>['${seer.emoji}|5', '${witch.emoji}|3'],
      'archetype_date': '01/03/2026',
    });
    await show(tester);
    await settle(tester, () => resultName().evaluate().isNotEmpty, 'the migrated archetype');

    expect(find.text(seer.name), findsWidgets, reason: 'The archetype is the same one');
    expect(find.text(witch.name), findsWidgets, reason: 'And so are the other energies');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('archetype_result'), archetypeIds[2]);
    expect(prefs.getStringList('archetype_top3'),
        <String>['${archetypeIds[2]}|5', '${archetypeIds.first}|3']);
    // A migração não é um teste novo: a data em que a pessoa respondeu fica.
    expect(prefs.getString('archetype_date'), '01/03/2026');
    expect(tester.takeException(), isNull);
  });

  testWidgets('the symbol on screen does not change with the migration',
      (tester) async {
    final entry = archetypesData[4];
    SharedPreferences.setMockInitialValues({
      'archetype_result': entry.emoji,
      'archetype_date': '01/03/2026',
    });
    await show(tester);
    await settle(tester, () => resultName().evaluate().isNotEmpty, 'the migrated archetype');

    // O desenho continua sendo o emoji do verbete, no mesmo tamanho — a troca
    // foi só de identidade gravada.
    final symbol = tester.widget<Text>(find.text(entry.emoji));
    expect(symbol.style?.fontSize, 56);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a result saved by the old portuguese name survives too',
      (tester) async {
    // Registro mais antigo ainda, de antes do emoji: o nome em português.
    SharedPreferences.setMockInitialValues({
      'archetype_result': 'A Sábia',
      'archetype_date': '01/03/2026',
    });
    await show(tester);
    await settle(tester, () => resultName().evaluate().isNotEmpty, 'the migrated archetype');

    expect(find.text(archetypesData[4].name), findsWidgets);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('archetype_result'), archetypeIds[4]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a saved value that matches nothing is an absence, not a crash',
      (tester) async {
    // Um símbolo gravado por outra fonte, ou de uma versão que não existe
    // mais: não dá para inventar um arquétipo para ele.
    SharedPreferences.setMockInitialValues({
      'archetype_result': '\u{1F9D9}',
      'archetype_top3': <String>['\u{1F9D9}|5'],
      'archetype_date': '01/03/2026',
    });
    await show(tester);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(resultName(), findsNothing, reason: 'No archetype is invented');
    expect(find.text(archetypeQuizQuestions.first.text), findsOneWidget,
        reason: 'The quiz opens at the first question');
    // O que não se entende também não se apaga: o registro fica onde estava.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('archetype_result'), '\u{1F9D9}');
    expect(tester.takeException(), isNull);
  });

  testWidgets('an energy that matches nothing is not erased from the device',
      (tester) async {
    // O resultado é legível, uma das energias não. A migração regravava a
    // lista já filtrada, e com isso apagava de vez a linha que não soube ler
    // — a mesma regra do resultado vale aqui: o que não se entende fica.
    final seer = archetypesData[2];
    final witch = archetypesData.first;
    final legacy = <String>[
      '${seer.emoji}|5',
      '${witch.emoji}|3',
      '\u{1F9D9}|1',
    ];
    SharedPreferences.setMockInitialValues({
      'archetype_result': seer.emoji,
      'archetype_top3': legacy,
      'archetype_date': '01/03/2026',
    });
    await show(tester);
    await settle(tester, () => resultName().evaluate().isNotEmpty, 'the migrated archetype');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('archetype_result'), archetypeIds[2],
        reason: 'O resultado, esse, migra');
    expect(prefs.getStringList('archetype_top3'), legacy,
        reason: 'As energias ficam como estavam até poderem ser lidas inteiras');
    // A linha ilegível apenas não aparece: as duas que se entendem, sim.
    expect(find.text(seer.name), findsWidgets);
    expect(find.text(witch.name), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
