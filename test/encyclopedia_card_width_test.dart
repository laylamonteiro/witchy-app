import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/widgets/expansion_magical_card.dart';
import 'package:grimorio_de_bolso/core/widgets/magical_card.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/pages/altar_page.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/pages/elements_page.dart';
import 'package:grimorio_de_bolso/features/runes/presentation/pages/runes_list_page.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester, Widget page) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(locale: const Locale('pt', 'BR'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: page));
    await tester.pump();
  }

  testWidgets('Elementos mantém introdução e expansões com a mesma largura',
      (tester) async {
    await pumpPage(tester, const ElementsPage());

    final introWidth = tester.getSize(find.byType(MagicalCard).first).width;
    final sectionWidth =
        tester.getSize(find.byType(ExpansionMagicalCard).first).width;

    expect(introWidth, closeTo(sectionWidth, 0.1));
  });

  testWidgets('Altar mantém cards simples e expansões com a mesma largura',
      (tester) async {
    await pumpPage(tester, const AltarPage());

    final introWidth = tester.getSize(find.byType(MagicalCard).first).width;
    final sectionWidth =
        tester.getSize(find.byType(ExpansionMagicalCard).first).width;

    expect(introWidth, closeTo(sectionWidth, 0.1));
  });

  testWidgets('Runas usa toda a largura disponível do conteúdo e do grid',
      (tester) async {
    await pumpPage(tester, const RunesListPage());

    final cards = find.byType(MagicalCard);
    final introWidth = tester.getSize(cards.first).width;
    final runeWidth = tester.getSize(cards.at(1)).width;

    expect(introWidth, closeTo(368, 0.1));
    expect(runeWidth, closeTo(178, 0.1));
  });
}
