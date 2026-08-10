import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/core/providers/language_provider.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

/// Smoke de internacionalização: os 3 idiomas suportados resolvem delegates,
/// renderizam strings do ARB sem mistura e o ContentLocale acompanha.
void main() {
  tearDown(() => ContentLocale.instance.setLocale(const Locale('pt', 'BR')));

  Widget appIn(Locale locale) => MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return Scaffold(
              body: Column(
                children: [
                  Text(l10n.encyclopediaPageTitle),
                  Text(l10n.settingsTitle),
                  Text(l10n.premiumBePremium),
                  Text(l10n.wheelInDays(3)),
                ],
              ),
            );
          },
        ),
      );

  testWidgets('pt-BR renderiza strings em português', (tester) async {
    await tester.pumpWidget(appIn(const Locale('pt', 'BR')));
    await tester.pumpAndSettle();
    expect(find.text('Grimório'), findsOneWidget);
    expect(find.text('Configurações'), findsOneWidget);
    expect(find.text('Em 3 dias'), findsOneWidget);
  });

  testWidgets('en renderiza strings em inglês (sem PT)', (tester) async {
    await tester.pumpWidget(appIn(const Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text('Grimoire'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('In 3 days'), findsOneWidget);
    expect(find.text('Configurações'), findsNothing);
  });

  testWidgets('es renderiza strings em espanhol (sem PT)', (tester) async {
    await tester.pumpWidget(appIn(const Locale('es')));
    await tester.pumpAndSettle();
    expect(find.text('Grimorio'), findsOneWidget);
    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('En 3 días'), findsOneWidget);
  });

  test('lookupAppLocalizations cobre os 3 idiomas + fallback', () {
    expect(lookupAppLocalizations(const Locale('pt', 'BR')).settingsTitle,
        'Configurações');
    expect(
        lookupAppLocalizations(const Locale('en')).settingsTitle, 'Settings');
    expect(lookupAppLocalizations(const Locale('es')).settingsTitle,
        'Configuración');
    // Idioma não suportado cai no fallback via LanguageProvider.resolve.
    expect(
        LanguageProvider.resolve(
            const Locale('fr'), LanguageProvider.supportedLocales),
        LanguageProvider.fallbackLocale);
  });

  test('resolve prioriza idioma do dispositivo suportado', () {
    expect(
        LanguageProvider.resolve(
            const Locale('en', 'US'), LanguageProvider.supportedLocales),
        const Locale('en'));
    expect(
        LanguageProvider.resolve(
            const Locale('es', 'MX'), LanguageProvider.supportedLocales),
        const Locale('es'));
    expect(
        LanguageProvider.resolve(
            const Locale('pt', 'PT'), LanguageProvider.supportedLocales),
        const Locale('pt', 'BR'));
  });
}
