import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/data_sources/blood_lore_content.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/presentation/pages/blood_lore_page.dart';
import 'support/short_test_timeout.dart';

/// A caminhada dos Saberes do Sangue: capa → área → verbete.
///
/// O que este arquivo guarda não é layout, é promessa editorial na tela:
/// nenhum verbete chega ao olho sem a etiqueta que diz de onde ele veio,
/// toda prática que fala de sangue mostra a nota de segurança e a versão sem
/// ele, e o filtro amoroso histórico não vira passo a passo.
///
/// As telas não pedem provider nenhum: o conteúdo é estático e as cores caem
/// no tema padrão do app.
void main() {
  useShortTestTimeout();

  final content = bloodLoreContent;

  Future<void> show(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: BloodLorePage()));
    await tester.pumpAndSettle();
  }

  Future<void> abrir(WidgetTester tester, Finder alvo) async {
    await tester.ensureVisible(alvo);
    await tester.pumpAndSettle();
    await tester.tap(alvo);
    await tester.pumpAndSettle();
  }

  testWidgets('a capa abre as quatro áreas', (tester) async {
    await show(tester);
    for (final category in BloodLoreCategory.values) {
      expect(find.byKey(ValueKey('blood-lore-category-${category.name}')),
          findsOneWidget,
          reason: category.name);
    }
    expect(find.byKey(const ValueKey('blood-lore-safety')), findsOneWidget,
        reason: 'a nota de segurança é alcançável já da porta');
    expect(tester.takeException(), isNull);
  });

  testWidgets('uma prática mostra classificação, nota e versão sem sangue',
      (tester) async {
    await show(tester);
    await abrir(
        tester,
        find.byKey(
            ValueKey('blood-lore-category-${BloodLoreCategory.practices.name}')));
    // Na lista, cada prática já vem com a etiqueta.
    for (final entry in content.of(BloodLoreCategory.practices)) {
      expect(find.byKey(ValueKey('blood-lore-entry-${entry.id}')), findsOneWidget,
          reason: entry.id);
    }
    expect(find.byKey(const ValueKey('blood-lore-practices-safety')),
        findsOneWidget);

    await abrir(tester, find.byKey(const ValueKey('blood-lore-entry-selo-do-limiar')));
    expect(find.byKey(const ValueKey('blood-lore-head-selo-do-limiar')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('blood-lore-practice-selo-do-limiar')),
        findsOneWidget);
    expect(
        find.byKey(const ValueKey('blood-lore-without-blood-selo-do-limiar')),
        findsOneWidget,
        reason: 'nenhuma prática do Grimório exige sangue');
    expect(find.byKey(const ValueKey('blood-lore-safety-selo-do-limiar')),
        findsOneWidget);
    expect(find.text(content.classificationLabel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('o filtro amoroso é contado, e leva ao encanto seguro',
      (tester) async {
    await show(tester);
    await abrir(
        tester,
        find.byKey(ValueKey(
            'blood-lore-category-${BloodLoreCategory.traditions.name}')));
    await abrir(
        tester, find.byKey(const ValueKey('blood-lore-entry-filtro-de-sangue')));
    // Texto, e não receita: a tela do filtro não tem bloco de prática.
    expect(find.byKey(const ValueKey('blood-lore-practice-filtro-de-sangue')),
        findsNothing);
    expect(find.byKey(const ValueKey('blood-lore-cta')), findsOneWidget);

    await abrir(tester, find.byKey(const ValueKey('blood-lore-cta')));
    // O convite abre o encanto adaptado, que é prática e tem versão sem
    // sangue.
    expect(find.byKey(const ValueKey('blood-lore-head-encanto-de-atracao')),
        findsOneWidget);
    expect(
        find.byKey(const ValueKey('blood-lore-without-blood-encanto-de-atracao')),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
