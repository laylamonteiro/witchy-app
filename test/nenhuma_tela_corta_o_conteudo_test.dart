// A catraca contra a tela que corta o próprio conteúdo.
//
// O defeito que deu origem a este arquivo foi achado NO APARELHO, não no
// código: na grade de runas da Enciclopédia a palavra-chave saía cortada no
// meio da letra, porque o cartão somava a margem dele (16) a um Padding
// interno (12) dentro de uma célula quadrada que não tinha essa folga. Três
// leituras adversariais do código passaram por ali sem ver. E não veriam:
// esse erro não existe no texto do programa, existe só quando a tela
// DESENHA — e sem SDK aqui ninguém desenha nada.
//
// O Flutter, em teste, denuncia estouro de layout como EXCEÇÃO (a mensagem
// fala em "A RenderFlex overflowed by N pixels"). Isso torna a defesa
// mecânica: montar a página numa tela estreita, com a fonte do sistema
// ampliada, e reprovar se alguma exceção de layout aparecer. É a única
// guarda desta classe inteira que não depende de ter um telefone na mão.
//
// ---------------------------------------------------------------------
// ONDE A REDE TEM BURACO — leia antes de confiar nela
// ---------------------------------------------------------------------
//
// 1. SÓ PEGA O QUE O FLUTTER DENUNCIA. Quem acusa estouro é o RenderFlex
//    (Row e Column) e uns poucos parentes. NÃO acusam, e portanto passam
//    batido aqui:
//      - `SizedBox(height: 40, child: Text(...))` — o texto maior que a
//        caixa é simplesmente pintado por fora, sem uma linha de erro. A
//        `SunPage` tem um desses de propósito (slot de duas linhas para o
//        herói do Sol terminar na mesma altura do da Lua).
//      - Stack, Align, Center e Positioned: filho maior que o pai não
//        reclama.
//      - Wrap: o que não cabe numa linha desce; o que não cabe sozinho
//        numa linha inteira transborda calado.
//    Para essas três famílias a catraca é cega. Continua valendo olhar.
//
// 2. A FONTE DO TESTE NÃO É A FONTE DO APARELHO. O `flutter test` desenha
//    com uma fonte de teste, de métrica própria; larguras aqui não são as
//    larguras de um telefone. Serve para ACHAR linhas rígidas demais, não
//    para medir quanto sobra. Por isso as asserções são sobre "estourou ou
//    não", nunca sobre pixels.
//
// 3. A LISTA DE TELAS É PARCIAL, e de propósito. Entraram as páginas que
//    montam sozinhas ou com o andaime mínimo (um provedor de autenticação
//    de mentira). FICARAM DE FORA, com o motivo:
//      - Tudo que exige banco com dados plantados: Grimório, Diários
//        (sonhos, desejos, gratidões, afirmações, escrita livre), Acervo,
//        Registros. O custo ali é a fixture, não o teste — quem for
//        estender comece por elas, reaproveitando o andaime de
//        `menstrual_cycle_page_test.dart`.
//      - Tudo que depende da cadeia de provedores do `main.dart`
//        (HomePage, abas de Astrologia/Ciclos/Tarô, Configurações,
//        Assinatura, Jornadas, Aprendizado): montar exige metade do
//        MultiProvider do app.
//      - As telas com rede ou plugin nativo no caminho: Conselheiro
//        Místico, Quiromancia, Pêndulo, Mapa Astral.
//      - As frentes que estavam sendo mexidas na mesma rodada: runas,
//        Seu Dia, o hub de Adivinhação e a busca da Enciclopédia. Não é
//        que estejam limpas — é que não eram minhas para consertar.
//
// 4. ERRO QUE NÃO É DE LAYOUT NÃO REPROVA. Uma foto que não carrega ou um
//    canal de plugin ausente no teste são ruído do ambiente, não defeito da
//    tela. Mas uma página que EXPLODE ao construir reprova sim, pela outra
//    porta: um ErrorWidget na árvore, ou uma página sem texto nenhum, é
//    aprovação vazia — e catraca que não pega nada é pior que nenhuma,
//    porque dá sensação de proteção.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:grimorio_de_bolso/core/theme/app_theme.dart';
import 'package:grimorio_de_bolso/features/astrology/presentation/pages/zodiac_signs_page.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/user_model.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/pages/welcome_page.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/diary/presentation/pages/dream_themes_page.dart';
import 'package:grimorio_de_bolso/features/diary/presentation/pages/dream_tools_page.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/arcane_categories.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/archetypes_data.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/colors_data.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/crystals_data.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/goddesses_data.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/herbs_data.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/metals_data.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/pages/altar_page.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/pages/arcane_detail_page.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/pages/arcane_list_page.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/pages/color_detail_page.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/pages/crystal_detail_page.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/pages/elements_page.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/pages/goddess_detail_page.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/pages/goddesses_list_page.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/pages/herb_detail_page.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/pages/metal_detail_page.dart';
import 'package:grimorio_de_bolso/features/numerology/presentation/pages/numerology_page.dart';
import 'package:grimorio_de_bolso/features/settings/presentation/pages/about_help_page.dart';
import 'package:grimorio_de_bolso/features/settings/presentation/pages/faq_page.dart';
import 'package:grimorio_de_bolso/features/sun/presentation/pages/sun_page.dart';
import 'package:grimorio_de_bolso/features/tarot/presentation/pages/tarot_library_page.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import 'support/short_test_timeout.dart';

/// Uma tela da catraca: o nome que aparece na falha e como construí-la.
class _Tela {
  const _Tela(this.nome, this.constroi);

  final String nome;
  final Widget Function() constroi;
}

/// Uma condição dura de exibição.
///
/// 320 é o telefone estreito que ainda existe (e é a largura em que a
/// própria `PremiumOfferPanel` já é testada, em regression_fixes_test).
/// A fonte ampliada é o que a pessoa liga quando não enxerga bem — e é
/// exatamente aí que uma linha rígida demais corta a palavra.
class _Condicao {
  const _Condicao(this.nome, this.tamanho, this.fonte);

  final String nome;
  final Size tamanho;
  final double fonte;
}

const List<_Condicao> _condicoes = [
  _Condicao('tela de 320 com fonte a 130%', Size(320, 640), 1.3),
  _Condicao('tela de 360 com fonte a 150%', Size(360, 740), 1.5),
];

/// Bruxa sem plano: é o pior caso de conteúdo na tela (véus, cadeados e
/// convites aparecem), e é a maioria de quem usa o app.
class _BruxaSemPlano extends AuthProvider {
  @override
  UserModel get currentUser => UserModel.defaultUser();

  @override
  bool get isPremiumEffective => false;
}

/// O item de nome mais comprido da lista — o pior caso honesto de cada
/// verbete, sem precisar montar os duzentos.
T _maisLongo<T>(List<T> itens, String Function(T) nome) =>
    itens.reduce((a, b) => nome(a).length >= nome(b).length ? a : b);

/// Só o que é defeito de layout. Foto que não carrega e canal de plugin
/// ausente são ruído do ambiente de teste, não da tela.
bool _ehEstouroDeLayout(FlutterErrorDetails detalhes) {
  final texto = detalhes.exceptionAsString();
  return texto.contains('overflowed') ||
      texto.contains('was not laid out') ||
      texto.contains('unbounded') ||
      texto.contains('ParentDataWidget');
}

void main() {
  useShortTestTimeout();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfiNoIsolate;

  setUpAll(() async {
    // Sem isto o google_fonts tenta baixar a fonte pela rede a cada
    // montagem; no teste a busca falha e vira ruído no console.
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    // Banco em diretório próprio: o `flutter test` roda os arquivos em
    // paralelo e todos que usam o caminho padrão disputam o mesmo arquivo.
    final dir = await Directory.systemTemp.createTemp('catraca_de_layout');
    await databaseFactory.setDatabasesPath(dir.path);
  });

  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Monta [tela] em [condicao] e devolve a lista de problemas encontrados
  /// (vazia quando a tela se comportou).
  Future<List<String>> conferir(
    WidgetTester tester,
    _Tela tela,
    _Condicao condicao,
  ) async {
    final capturados = <FlutterErrorDetails>[];
    final anterior = FlutterError.onError;
    // Interceptar em vez de deixar o binding reprovar: assim a falha sai
    // com o nome da tela e da condição, e uma tela ruim não esconde as
    // outras. O `finally` devolve o tratador — sem isso, um erro real de
    // um teste seguinte sumiria dentro desta lista.
    FlutterError.onError = capturados.add;
    try {
      await tester.binding.setSurfaceSize(condicao.tamanho);
      await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
        create: (_) => _BruxaSemPlano(),
        child: MaterialApp(
          locale: const Locale('pt', 'BR'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.darkTheme,
          // `copyWith` a partir do context, nunca um MediaQueryData cru: um
          // cru zeraria o tamanho da tela e o layout inteiro viraria zero —
          // a catraca passaria sempre, sem medir nada.
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(condicao.fonte),
              // Várias telas animam em laço (estrelas, sol que respira,
              // emblemas vivos): com `pumpAndSettle` o teste nunca
              // terminaria. Desligar é o mesmo caminho de quem pede menos
              // movimento no sistema.
              disableAnimations: true,
            ),
            child: child!,
          ),
          home: tela.constroi(),
        ),
      ));
      // Nem pump() puro nem pumpAndSettle(): a entrada em cascata agenda um
      // Timer por item (sem andar o relógio o teste morre com timer
      // pendente) e a página nunca chega ao repouso.
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
    } finally {
      FlutterError.onError = anterior;
    }

    final problemas = <String>{
      for (final detalhes in capturados)
        if (_ehEstouroDeLayout(detalhes)) detalhes.exceptionAsString(),
    }.toList();

    // As duas guardas contra aprovação vazia: uma tela que explodiu ao
    // construir vira ErrorWidget, e ErrorWidget nunca estoura.
    if (find.byType(ErrorWidget).evaluate().isNotEmpty) {
      problemas.add('a página não chegou a ser construída (ErrorWidget)');
    }
    if (find.byType(Text).evaluate().isEmpty) {
      problemas.add('a página montou sem texto nenhum — não há o que medir');
    }
    return problemas;
  }

  final telas = <_Tela>[
    // --- Enciclopédia: listas e conteúdo estático ---
    _Tela('Elementos', () => const ElementsPage()),
    _Tela('Altar', () => const AltarPage()),
    _Tela('Deusas (lista)', () => const GoddessesListPage()),
    _Tela(
      'Arquétipos (lista)',
      () => ArcaneListPage(
        category: ArcaneCategory.archetypes,
        title: lookupAppLocalizations(const Locale('pt', 'BR'))
            .encyTabArchetypes,
        intro: lookupAppLocalizations(const Locale('pt', 'BR'))
            .encyArcaneIntroArchetypes,
        entries: archetypesData,
      ),
    ),

    // --- Enciclopédia: verbetes, sempre no de nome mais comprido ---
    _Tela(
      'Verbete de cristal',
      () => CrystalDetailPage(
        crystal: _maisLongo(crystalsData, (c) => c.name),
      ),
    ),
    _Tela(
      'Verbete de erva',
      () => HerbDetailPage(herb: _maisLongo(herbsData, (h) => h.name)),
    ),
    _Tela(
      'Verbete de cor',
      () => ColorDetailPage(
        colorModel: _maisLongo(colorsData, (c) => c.name),
      ),
    ),
    _Tela(
      'Verbete de metal',
      () => MetalDetailPage(metal: _maisLongo(metalsData, (m) => m.name)),
    ),
    _Tela(
      'Verbete de deusa',
      () => GoddessDetailPage(
        goddess: _maisLongo(goddessesData, (g) => g.name),
      ),
    ),
    _Tela(
      'Verbete de arquétipo',
      () => ArcaneDetailPage(
        entry: _maisLongo(archetypesData, (e) => e.name),
        category: ArcaneCategory.archetypes,
      ),
    ),

    // --- Outras seções que montam sozinhas ---
    _Tela('Signos', () => const ZodiacSignsPage()),
    _Tela('Sol', () => const SunPage()),
    _Tela('Numerologia', () => const NumerologyPage()),
    _Tela('Biblioteca do Tarô', () => const TarotLibraryPage()),
    _Tela('Ferramentas de sonho', () => const DreamToolsPage()),
    _Tela('Significados dos sonhos', () => const DreamThemesPage()),
    _Tela('Sobre e ajuda', () => const AboutHelpPage()),
    _Tela('Perguntas frequentes', () => const FaqPage()),
    _Tela('Boas-vindas', () => const WelcomePage()),
    _Tela('Esqueci a senha', () => const ForgotPasswordPage()),
  ];

  for (final tela in telas) {
    testWidgets('${tela.nome} não corta o próprio conteúdo', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final condicao in _condicoes) {
        final problemas = await conferir(tester, tela, condicao);
        expect(
          problemas,
          isEmpty,
          reason: '${tela.nome} — ${condicao.nome}:\n${problemas.join('\n')}',
        );
      }
    });
  }

  testWidgets('a própria catraca pega um estouro quando existe um',
      (tester) async {
    // Sem esta prova o arquivo inteiro é fé: se um dia a captura de erros
    // parar de funcionar (mudança no binding, tratador restaurado cedo
    // demais), todos os testes acima passariam a aprovar qualquer coisa em
    // silêncio. Aqui a linha estoura DE PROPÓSITO.
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final problemas = await conferir(
      tester,
      _Tela(
        'linha rígida de propósito',
        () => const Scaffold(
          body: Row(
            children: [
              SizedBox(width: 400, child: Text('largo demais')),
              SizedBox(width: 400, child: Text('para esta tela')),
            ],
          ),
        ),
      ),
      _condicoes.first,
    );
    expect(problemas, isNotEmpty);
    expect(problemas.first, contains('overflowed'));
  });
}
