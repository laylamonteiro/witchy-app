import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:grimorio_de_bolso/core/theme/app_theme.dart';
import 'package:grimorio_de_bolso/core/theme/grimoire_colors.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/magical_profile_report.dart';
import 'package:grimorio_de_bolso/features/astrology/presentation/pages/magical_profile_section_page.dart';
import 'package:grimorio_de_bolso/features/astrology/presentation/providers/astrology_provider.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';

/// A seção é tecida quando a pessoa abre o card, e a chamada só pode partir
/// depois do primeiro frame. Esse intervalo de um frame caía no mesmo ramo do
/// "não deu certo": a tela NASCIA dizendo que falhou, antes de ter tentado —
/// e quem abria via o erro e ia embora.
///
/// Este teste segura os dois lados: enquanto tece, aparece a espera; só o que
/// de fato falhou mostra o erro (com o motivo).
class _AstroFake extends AstrologyProvider {
  _AstroFake({
    this.secao,
    this.erro,
    this.limite = false,
    this.demora = Duration.zero,
  });

  ProfileSection? secao;
  final String? erro;
  final bool limite;
  final Duration demora;

  /// Quais seções falharam. Vazio com `erro` preenchido significa "todas",
  /// para os testes que não se importam com qual é qual.
  Set<String> secoesQueFalharam = const {};

  int chamadas = 0;
  final Set<String> _tecendo = {};

  // A falha é por SEÇÃO, e o dublê acompanha: um erro global fazia a seção
  // que falhava marcar falha em todas as outras abertas.
  bool _falhou(String key) =>
      secoesQueFalharam.isEmpty || secoesQueFalharam.contains(key);

  @override
  String? erroDaSecao(String key) => _falhou(key) ? erro : null;

  @override
  bool falhaDeLimiteNaSecao(String key) => limite && _falhou(key);

  @override
  bool isWeavingSection(String key) => _tecendo.contains(key);

  @override
  ProfileSection? profileSection(String key) => secao;

  @override
  Future<void> generateProfileSection(
    String sectionKey, {
    required bool hasFullAccess,
  }) async {
    chamadas++;
    _tecendo.add(sectionKey);
    notifyListeners();
    await Future<void>.delayed(demora);
    _tecendo.remove(sectionKey);
    notifyListeners();
  }
}

class _AuthPremium extends AuthProvider {
  @override
  bool get isPremiumEffective => true;
}

Widget _tela(_AstroFake astro, {ProfileSection? guardada}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AstrologyProvider>.value(value: astro),
      ChangeNotifierProvider<AuthProvider>.value(value: _AuthPremium()),
    ],
    child: MaterialApp(
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.darkTheme,
      home: MagicalProfileSectionPage(
        title: 'Seus Dons Intuitivos',
        sectionKey: MagicalProfileSections.intuition,
        section: guardada,
      ),
    ),
  );
}

void main() {
  final l10n = lookupAppLocalizations(const Locale('pt', 'BR'));

  testWidgets('abre tecendo — nunca nasce dizendo que falhou', (tester) async {
    final astro = _AstroFake(demora: const Duration(seconds: 1));
    await tester.pumpWidget(_tela(astro));

    // O PRIMEIRO frame, antes de a geração sequer partir.
    expect(find.text(l10n.profileSectionFailed), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump();
    expect(find.text(l10n.profileSectionFailed), findsNothing);
    expect(astro.chamadas, 1);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });

  testWidgets('com a seção pronta, mostra a leitura e some a espera',
      (tester) async {
    const guardada = ProfileSection(
      key: MagicalProfileSections.intuition,
      legacyTitle: null,
      slides: [ProfileSlide(title: 'A Lua em Peixes', body: 'Corpo.')],
    );
    final astro = _AstroFake(secao: guardada);
    await tester.pumpWidget(_tela(astro, guardada: guardada));
    await tester.pumpAndSettle();

    expect(find.text('A Lua em Peixes'), findsOneWidget);
    expect(find.text(l10n.profileSectionFailed), findsNothing);
    // Já estava guardada: não se gasta chamada de IA para reler.
    expect(astro.chamadas, 0);
  });

  testWidgets('a frase de destaque e o negrito chegam à tela', (tester) async {
    // A forma é o produto aqui: sem o `> ` em evidência e sem o negrito nas
    // posições, a leitura vira a parede de texto que ela era.
    const guardada = ProfileSection(
      key: MagicalProfileSections.intuition,
      legacyTitle: null,
      slides: [
        ProfileSlide(
          title: 'A Lua que sente antes',
          body: '> Sua intuição chega pelo corpo, não pela cabeça\n\n'
              'Sua **Lua em Peixes na Casa 4** avisa por sensação.\n\n'
              'É por isso que você sabe antes de entender.',
        ),
      ],
    );
    final astro = _AstroFake(secao: guardada);
    await tester.pumpWidget(_tela(astro, guardada: guardada));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Sua intuição chega pelo corpo'),
      findsOneWidget,
    );
    expect(find.textContaining('Lua em Peixes na Casa 4'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // E chega vestida: o destaque num cartão lilás, nunca no azul-claro que
    // o flutter_markdown usa quando a tela não estiliza o `> `.
    final caixas = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((d) => d.decoration)
        .whereType<BoxDecoration>()
        .toList();
    final lilas = GrimoireColors.vinhoOrquidea.lilac;

    expect(caixas.map((d) => d.color), isNot(contains(Colors.blue.shade100)));
    // O cartão do destaque: lilás e com a barra à esquerda — não confundir
    // com o tracinho lilás que separa o subtítulo.
    expect(
      caixas.any(
        (d) =>
            d.border != null &&
            d.color != null &&
            d.color!.r == lilas.r &&
            d.color!.g == lilas.g &&
            d.color!.b == lilas.b,
      ),
      isTrue,
      reason: 'a frase de destaque deveria sair no cartão lilás',
    );
  });

  testWidgets('falhou de verdade: erro com o motivo e um botão de tentar',
      (tester) async {
    final astro = _AstroFake(erro: 'Sem conexão com o oráculo');
    await tester.pumpWidget(_tela(astro));
    await tester.pumpAndSettle();

    expect(find.text(l10n.profileSectionFailed), findsOneWidget);
    expect(find.text('Sem conexão com o oráculo'), findsOneWidget);
    expect(find.text(l10n.commonTryAgain), findsOneWidget);

    await tester.tap(find.text(l10n.commonTryAgain));
    await tester.pumpAndSettle();
    expect(astro.chamadas, 2, reason: 'a abertura tenta uma vez; o botão, outra');
  });

  testWidgets('limite do provedor vira orientação, não nome de exceção',
      (tester) async {
    await tester.pumpWidget(_tela(_AstroFake(limite: true)));
    await tester.pumpAndSettle();

    expect(find.text(l10n.aiVisionRateLimit), findsOneWidget);
    expect(find.textContaining('Exception'), findsNothing);
  });

  testWidgets('a falha de OUTRA seção não contamina esta', (tester) async {
    // A trava de geração já era por seção — abrir um card enquanto outro
    // termina é o normal de quem está explorando. O erro, porém, era um só
    // para todas: a seção que falhasse marcava falha em TODAS as abertas,
    // inclusive nas que estavam indo bem. A tela é a da intuição; quem
    // falhou foi a essência.
    final astro = _AstroFake(erro: 'Sem conexão com o oráculo')
      ..secoesQueFalharam = {MagicalProfileSections.essence};

    await tester.pumpWidget(_tela(astro));
    await tester.pumpAndSettle();

    expect(
      find.text('Sem conexão com o oráculo'),
      findsNothing,
      reason: 'o motivo pertence à essência, não à intuição',
    );
  });

  testWidgets('o limite de OUTRA seção não contamina esta', (tester) async {
    final astro = _AstroFake(limite: true)
      ..secoesQueFalharam = {MagicalProfileSections.essence};

    await tester.pumpWidget(_tela(astro));
    await tester.pumpAndSettle();

    expect(find.text(l10n.aiVisionRateLimit), findsNothing);
  });
}
