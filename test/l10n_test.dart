import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:grimorio_de_bolso/core/providers/language_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fallback resolve unsupported locales to pt-BR', () {
    expect(
      LanguageProvider.resolve(
        const Locale('fr', 'FR'),
        LanguageProvider.supportedLocales,
      ),
      const Locale('pt', 'BR'),
    );
  });

  test('manual language choice is persisted in SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final provider = LanguageProvider(prefs);

    await provider.setLocale(const Locale('en'));

    expect(provider.locale, const Locale('en'));
    expect(prefs.getString(LanguageProvider.preferencesKey), 'en');
  });

  testWidgets('pluralized item count follows active locale', (tester) async {
    late BuildContext capturedContext;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final l10n = AppLocalizations.of(capturedContext);
    expect(l10n.itemsCount(0), 'Nenhum item');
    expect(l10n.itemsCount(1), '1 item');
    expect(l10n.itemsCount(2), '2 itens');
  });
}
