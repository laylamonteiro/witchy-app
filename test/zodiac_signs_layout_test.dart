import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/astrology/presentation/pages/zodiac_signs_page.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('campos do signo usam a mesma margem esquerda', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Sem os delegates a página quebra em AppLocalizations.of(context),
    // que faz null check no Localizations ausente.
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ZodiacSignsPage(),
      ),
    );

    await tester.tap(find.text('Áries'));
    await tester.pumpAndSettle();

    final personalityLeft = tester.getTopLeft(find.text('Personalidade')).dx;
    final personalityContentLeft =
        tester.getTopLeft(find.text(zodiacSignsData.first.personality)).dx;

    for (final title in const ['Cristais', 'Ervas', 'Cores']) {
      expect(tester.getTopLeft(find.text(title)).dx, personalityLeft);
    }

    for (final content in [
      zodiacSignsData.first.crystals,
      zodiacSignsData.first.herbs,
      zodiacSignsData.first.colors,
    ]) {
      expect(tester.getTopLeft(find.text(content)).dx, personalityContentLeft);
    }
  });
}
