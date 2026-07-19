import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/sigils/presentation/pages/sigil_step1_intention_page.dart';
import 'package:grimorio_de_bolso/features/sigils/presentation/widgets/sigil_icon.dart';

void main() {
  testWidgets('bloco explicativo de sigilo usa o ícone reutilizável do card',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SigilStep1IntentionPage(),
      ),
    );

    final title = find.text('O que é um Sigilo?');
    expect(title, findsOneWidget);

    final headerRow = find.ancestor(
      of: title,
      matching: find.byType(Row),
    );
    expect(headerRow, findsOneWidget);

    final icon = find.descendant(
      of: headerRow,
      matching: find.byType(SigilIcon),
    );
    expect(icon, findsOneWidget);

    final sigilIcon = tester.widget<SigilIcon>(icon);
    expect(sigilIcon.size, 32);
    expect(find.descendant(of: headerRow, matching: find.text(kSigilIconGlyph)),
        findsOneWidget);
    expect(find.descendant(of: headerRow, matching: find.text('🃏')), findsNothing);
  });
}
