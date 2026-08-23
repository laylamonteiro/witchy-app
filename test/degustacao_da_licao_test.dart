import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/offers/teaser_reveal.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/widgets/premium_blur_widget.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails_data.dart';
import 'package:grimorio_de_bolso/features/learning/presentation/pages/lesson_page.dart';
import 'package:grimorio_de_bolso/features/learning/presentation/pages/trail_page.dart';
import 'package:grimorio_de_bolso/features/learning/presentation/providers/learning_provider.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A degustação da lição, destravada (decisão de 23/08, conflito 3.2 do
/// plano unificado).
///
/// O teaser sempre existiu dentro da LessonPage — o primeiro parágrafo real
/// do ensino, o véu e o convite — mas dois interceptadores abriam o paywall
/// ANTES de navegar: a pessoa gratuita nunca via o que estava comprando, e a
/// exposição nem era registrada no motor de ofertas. Estes testes travam o
/// caminho novo: lição Premium NAVEGA e mostra a degustação; a 1ª lição e o
/// Premium continuam abrindo a lição inteira.
class _AuthPremium extends AuthProvider {
  @override
  bool get isPremiumEffective => true;
}

class _AuthFree extends AuthProvider {
  @override
  bool get isPremiumEffective => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget tela(AuthProvider auth) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ChangeNotifierProvider<LearningProvider>.value(
          value: LearningProvider(),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TrailPage(trail: learningTrails.first),
      ),
    );
  }

  testWidgets('free toca a 2ª lição e chega à degustação, não ao paywall',
      (tester) async {
    await tester.pumpWidget(tela(_AuthFree()));
    await tester.pumpAndSettle();

    final trail = learningTrails.first;
    final licao2 = find.textContaining(trail.lessons[1].title);
    await tester.ensureVisible(licao2);
    await tester.pumpAndSettle();
    await tester.tap(licao2);
    await tester.pumpAndSettle();

    // Navegou de verdade: a página da lição está na frente, com o véu da
    // degustação — e nenhum paywall interceptou o caminho.
    expect(find.byType(LessonPage), findsOneWidget);
    expect(find.byType(TeaserReveal), findsOneWidget,
        reason: 'a pessoa gratuita agora VÊ o começo do que está comprando');
    expect(find.byType(PremiumUpgradeSheet), findsNothing,
        reason: 'o paywall na cara era o interceptador que a decisão tirou');
  });

  testWidgets('a 1ª lição continua inteira para quem é free', (tester) async {
    await tester.pumpWidget(tela(_AuthFree()));
    await tester.pumpAndSettle();

    final trail = learningTrails.first;
    final licao1 = find.textContaining(trail.lessons.first.title);
    await tester.ensureVisible(licao1);
    await tester.pumpAndSettle();
    await tester.tap(licao1);
    await tester.pumpAndSettle();

    expect(find.byType(LessonPage), findsOneWidget);
    expect(find.byType(TeaserReveal), findsNothing,
        reason: 'a porta de entrada gratuita não pode virar degustação');
  });

  testWidgets('Premium abre a 2ª lição inteira, sem véu', (tester) async {
    await tester.pumpWidget(tela(_AuthPremium()));
    await tester.pumpAndSettle();

    final trail = learningTrails.first;
    final licao2 = find.textContaining(trail.lessons[1].title);
    await tester.ensureVisible(licao2);
    await tester.pumpAndSettle();
    await tester.tap(licao2);
    await tester.pumpAndSettle();

    expect(find.byType(LessonPage), findsOneWidget);
    expect(find.byType(TeaserReveal), findsNothing,
        reason: 'destravar a degustação não pode trancar quem já pagou');
  });
}
