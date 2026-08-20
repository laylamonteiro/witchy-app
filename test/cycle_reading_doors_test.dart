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
    // Largura folgada de propósito: a página tem dois Rows que estouram
    // em 390px sem dados no banco (magical_analytics_page.dart:576 e :908),
    // e qualquer exceção reprova o teste antes do expect. Aqui a pergunta é
    // "o card está na árvore?", não "o layout aguenta tela estreita" — esse
    // é outro teste, para outro dia.
    await tester.binding.setSurfaceSize(const Size(1200, 3000));
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
          // Scaffold de propósito: em `embedded: true` a página não traz
          // o seu, porque na vida real ela vive dentro do Scaffold da
          // Evolução Mágica (magical_progress_page.dart). Solta em `home:`,
          // os InkWell dos cards de categoria não acham Material e derrubam
          // o frame antes do expect. Aqui o teste monta a página como o app
          // monta — que é a única montagem cujo resultado interessa.
          home: Scaffold(body: MagicalAnalyticsPage(embedded: true)),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Leitura do Ciclo'), findsOneWidget);
  });
}
