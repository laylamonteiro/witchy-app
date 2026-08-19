import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimorio_de_bolso/core/navigation/encyclopedia_section.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/pages/encyclopedia_index_page.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

/// Congela a ordem canônica das seções da Enciclopédia.
///
/// TabBar, TabBarView, o sumário do livro-índice e os deep links derivam
/// todos de EncyclopediaSection — reordenar o enum reordena o app inteiro
/// junto, então qualquer mudança aqui deve ser CONSCIENTE: atualize a lista
/// abaixo junto com o enum.
void main() {
  test('a ordem canônica das seções está congelada', () {
    expect(EncyclopediaSection.values, const [
      EncyclopediaSection.bookIndex,
      EncyclopediaSection.myGrimoire,
      EncyclopediaSection.moon,
      EncyclopediaSection.sun,
      EncyclopediaSection.sabbats,
      EncyclopediaSection.colors,
      EncyclopediaSection.crystals,
      EncyclopediaSection.herbs,
      EncyclopediaSection.goddesses,
      EncyclopediaSection.metals,
      EncyclopediaSection.archetypes,
      EncyclopediaSection.symbols,
      EncyclopediaSection.angels,
      EncyclopediaSection.demons,
      EncyclopediaSection.elements,
      EncyclopediaSection.runes,
      EncyclopediaSection.altar,
    ]);
  });

  testWidgets('o sumário do livro abre a seção escolhida após a virada',
      (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    EncyclopediaSection? selected;

    await tester.pumpWidget(MaterialApp(
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // As estrelas da capa (BlinkStar) piscam em loop infinito, então
      // pumpAndSettle nunca terminava. O próprio widget respeita
      // disableAnimations — é o mesmo caminho de quem pede menos movimento
      // no sistema —, então o teste pede isso em vez de mexer no app.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: Scaffold(
        body: EncyclopediaIndexPage(
          onSectionSelected: (section) => selected = section,
        ),
      ),
    ));

    // A capa começa FECHADA — o Grimório é um livro em repouso.
    await tester.pump();
    expect(find.byKey(const ValueKey('grimoire-cover')), findsOneWidget);

    // Um toque abre o livro.
    await tester.tap(find.byKey(const ValueKey('grimoire-cover')));
    await tester.pumpAndSettle();

    // Todas as seções aparecem no sumário.
    expect(find.text('Cristais'), findsOneWidget);
    expect(find.text('Demônios'), findsOneWidget);

    // Tocar numa entrada vira a folha e então entrega a seção.
    await tester.tap(find.text('Cristais'));
    await tester.pumpAndSettle();
    expect(selected, EncyclopediaSection.crystals);
  });
}
