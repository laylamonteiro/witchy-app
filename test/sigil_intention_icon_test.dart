import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/tools/tool_emblem_art.dart';
import 'package:grimorio_de_bolso/features/sigils/presentation/pages/sigil_step1_intention_page.dart';
import 'package:grimorio_de_bolso/features/sigils/presentation/widgets/sigil_icon.dart';

void main() {
  testWidgets('bloco explicativo de sigilo usa o ícone reutilizável do card',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(locale: const Locale('pt', 'BR'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
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
    expect(sigilIcon.size, 48,
        reason: 'O emblema de abertura tem um tamanho só nas doze ferramentas');
    // O que este teste garante é que o emblema APARECE no cabeçalho, ao lado
    // do título — não a forma dele. Era o caractere ⛤, procurado por texto;
    // agora é o desenho, porque num aparelho sem fonte para aquele bloco do
    // Unicode o `Text` achava o glifo e a pessoa via um quadradinho.
    final arte = find.descendant(
      of: headerRow,
      matching: find.byType(ToolDrawingArt),
    );
    expect(arte, findsOneWidget);
    expect(tester.widget<ToolDrawingArt>(arte).drawing, ToolDrawing.pentagram);
    expect(find.descendant(of: headerRow, matching: find.text('🃏')), findsNothing);

    // Quem voa nesta rota é só o emblema da AppBar; o do cabeçalho é
    // `flies: false`. O guarda aqui é a CONTAGEM, e não uma exceção: etiqueta
    // repetida só estoura durante um voo, e este teste não navega — o defeito
    // apareceria no push seguinte, longe daqui.
    expect(find.byType(Hero), findsOneWidget);
  });
}
