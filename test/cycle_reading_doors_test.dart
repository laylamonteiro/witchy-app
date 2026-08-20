import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/analytics/presentation/pages/magical_analytics_page.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/learning/presentation/providers/learning_provider.dart';
import 'package:grimorio_de_bolso/features/your_day/presentation/providers/daily_checkin_provider.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

/// A porta permanente da Leitura do Ciclo na aba Estatísticas some sem
/// barulho: nada quebra, nenhum teste falha, ela apenas deixa de estar lá e
/// a venda morre em silêncio. Foi o que se suspeitou ter acontecido — e a
/// suspeita não pôde ser respondida por leitura de código, porque "está no
/// arquivo" e "renderiza na tela" são coisas diferentes.
///
/// Este teste responde. Sem banco, `_loadStats` lança, o `catch` desliga o
/// _isLoading e a árvore completa é construída — que é exatamente o estado
/// em que a pergunta importa.
void main() {
  testWidgets('Estatísticas mostra a porta permanente da Leitura do Ciclo',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
          ChangeNotifierProvider<LearningProvider>(
            create: (_) => LearningProvider(),
          ),
          ChangeNotifierProvider<DailyCheckinProvider>(
            create: (_) => DailyCheckinProvider(),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('pt', 'BR'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MagicalAnalyticsPage(embedded: true),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Leitura do Ciclo'), findsOneWidget);
  });
}
