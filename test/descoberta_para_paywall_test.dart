import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/services/payment_service.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/widgets/premium_blur_widget.dart';
import 'package:grimorio_de_bolso/features/subscription/presentation/pages/pagina_de_descoberta.dart';
import 'package:grimorio_de_bolso/features/subscription/presentation/pages/subscription_page.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

/// Decisão da dona (23/08): todo "Desbloquear Premium" da tela de
/// descoberta vai DIRETO ao paywall. A página de Assinatura vira gestão de
/// conta e mora nas Configurações — o convite não desvia mais por ela.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget tela() => MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: AuthProvider()),
          ChangeNotifierProvider<PaymentService>.value(
            value: PaymentService(),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('pt', 'BR'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PaginaDeDescoberta(),
        ),
      );

  testWidgets('o Desbloquear Premium da descoberta abre o paywall',
      (tester) async {
    await tester.pumpWidget(tela());
    await tester.pumpAndSettle();

    final cta = find.text('Desbloquear Premium').first;
    await tester.ensureVisible(cta);
    await tester.pumpAndSettle();
    await tester.tap(cta);
    await tester.pumpAndSettle();

    expect(find.byType(PremiumUpgradeSheet), findsOneWidget,
        reason: 'quem tocou já viu o que quer — o preço vem sem desvio');
    expect(find.byType(SubscriptionPage), findsNothing,
        reason: 'a página de Assinatura agora é gestão, nas Configurações');
  });
}
