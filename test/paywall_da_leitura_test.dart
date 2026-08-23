import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/data/models/cycle_reading_model.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/presentation/widgets/paywall_da_leitura.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

/// Decisão da dona (23/08): o preço da Leitura do Ciclo saiu da tela de
/// intro e mora num paywall próprio — a folha explica seção por seção o que
/// a leitura entrega e só então mostra o valor e o botão de pagar.
///
/// Estes testes provam as três promessas da folha: a lunação lista as 8
/// seções (sem upsell — quem já vai levar o produto completo não precisa de
/// convite), a semana lista as 5 (a previsão entra nas duas janelas) e
/// convida honestamente para a lunação, e o CTA fecha a folha antes de
/// avisar quem paga.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final l10n = lookupAppLocalizations(const Locale('pt', 'BR'));

  // Na folha, o emoji do título vai para DENTRO do selo circular e o rótulo
  // fica limpo ao lado — os testes procuram o rótulo, como a pessoa o lê.
  String rotulo(String titulo) => PaywallDaLeitura.separarEmoji(titulo).rotulo;

  const abrir = ValueKey('abrir_paywall');

  Widget tela({
    required String periodType,
    VoidCallback? onComprar,
  }) =>
      MaterialApp(
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                key: abrir,
                onPressed: () => mostrarPaywallDaLeitura(
                  context,
                  periodType: periodType,
                  periodStart: DateTime(2026, 8, 1),
                  periodEnd: DateTime(2026, 8, 29),
                  price: r'R$ 14,90',
                  onComprar: onComprar ?? () {},
                ),
                child: const Icon(Icons.open_in_new),
              ),
            ),
          ),
        ),
      );

  /// Abre a folha com quadros contados na mão — o padrão da suíte para
  /// telas com animação de entrada (a cascata do StaggeredEntrance).
  Future<void> abrirFolha(WidgetTester tester, Widget host) async {
    // Superfície alta de propósito: a folha limita a própria altura a 92%
    // da tela, e numa superfície de 600px o CTA nasceria fora da dobra.
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(host);
    await tester.tap(find.byKey(abrir));
    await tester.pump();
    // Entrada da folha + cascata dos bullets (8 × 70ms + 420ms de entrada).
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('a folha da lunação tece as 8 seções e não faz upsell',
      (tester) async {
    await abrirFolha(
      tester,
      tela(periodType: CycleReadingPeriodType.lunation),
    );

    expect(find.text(l10n.cycleReadingLunationTitle), findsOneWidget);
    for (final titulo in [
      l10n.cycleReadingSectionPortrait,
      l10n.cycleReadingSectionThreads,
      l10n.cycleReadingSectionSky,
      l10n.cycleReadingSectionPractice,
      l10n.cycleReadingSectionForecast,
      l10n.cycleReadingSectionRituals,
      l10n.cycleReadingSectionAffirmation,
      l10n.cycleReadingSectionSeal,
    ]) {
      expect(find.text(rotulo(titulo)), findsOneWidget,
          reason: 'cada seção do produto completo vira um bullet');
    }
    expect(find.text(l10n.cycleReadingPaywallWeekUpsell), findsNothing,
        reason: 'quem já leva a lunação não precisa de convite para ela');
    // O preço aparece aqui — e é a primeira vez no fluxo inteiro.
    expect(find.text(r'R$ 14,90'), findsOneWidget);
  });

  testWidgets('a folha da semana tece 5 seções e convida para a lunação',
      (tester) async {
    await abrirFolha(
      tester,
      tela(periodType: CycleReadingPeriodType.week),
    );

    expect(find.text(l10n.cycleReadingWeekTitle), findsOneWidget);
    for (final titulo in [
      l10n.cycleReadingSectionPortrait,
      l10n.cycleReadingSectionThreads,
      l10n.cycleReadingSectionSky,
      l10n.cycleReadingSectionForecast,
      l10n.cycleReadingSectionAffirmation,
    ]) {
      expect(find.text(rotulo(titulo)), findsOneWidget);
    }
    // O que só a lunação sustenta fica FORA da folha da semana...
    expect(find.text(rotulo(l10n.cycleReadingSectionPractice)), findsNothing);
    expect(find.text(rotulo(l10n.cycleReadingSectionRituals)), findsNothing);
    expect(find.text(rotulo(l10n.cycleReadingSectionSeal)), findsNothing);
    // ...e vira o upsell honesto, dito com todas as letras.
    expect(find.text(l10n.cycleReadingPaywallWeekUpsell), findsOneWidget);
  });

  testWidgets('o CTA fecha a folha e avisa quem paga', (tester) async {
    var compras = 0;
    await abrirFolha(
      tester,
      tela(
        periodType: CycleReadingPeriodType.lunation,
        onComprar: () => compras++,
      ),
    );

    final cta = find.text(l10n.cycleReadingWantFull);
    await tester.ensureVisible(cta);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(cta);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(compras, 1, reason: 'a folha só apresenta — quem compra é quem '
        'recebeu o callback');
    expect(find.byType(PaywallDaLeitura), findsNothing,
        reason: 'a folha se fecha ANTES do fluxo de pagamento começar');
  });
}
