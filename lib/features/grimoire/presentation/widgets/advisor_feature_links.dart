import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/navigation/app_deep_link.dart';
import '../../../../core/widgets/highlighted_text.dart';
import '../../../astrology/presentation/pages/daily_magical_weather_page.dart';
import '../../../encyclopedia/presentation/pages/archetype_quiz_page.dart';
import '../../../numerology/presentation/pages/numerology_page.dart';
import '../../../your_day/data/shortcut_registry.dart';
import '../pages/records_archive_list_page.dart';

/// Uma funcionalidade do app que o Conselheiro pode sugerir e a pessoa pode
/// abrir tocando no nome dela dentro da resposta.
@immutable
class AdvisorFeature {
  const AdvisorFeature({
    required this.id,
    required this.name,
    required this.open,
  });

  /// Id estável (o mesmo dos atalhos do Seu Dia, quando é um deles).
  final String id;

  /// O nome traduzido — o que o prompt pede ao modelo para escrever.
  final String name;

  final void Function(BuildContext context) open;
}

/// O catálogo do que o Conselheiro conhece do app, no idioma ativo.
///
/// O prompt do Conselheiro lista as funcionalidades pelos MESMOS nomes que a
/// interface mostra e pede que ele as escreva entre `**`. Este catálogo faz o
/// caminho de volta: um nome destacado na resposta vira um destino do app.
/// A navegação reaproveita o catálogo de atalhos do Seu Dia, que já sabe
/// abrir cada ferramenta (página empilhada, destino de aba ou ação própria).
///
/// O import `shortcut_registry → mystic_advisor_page → este arquivo →
/// shortcut_registry` é circular e compila: Dart resolve imports por
/// biblioteca, não por ordem.
class AdvisorFeatureCatalog {
  const AdvisorFeatureCatalog(this.features);

  final List<AdvisorFeature> features;

  factory AdvisorFeatureCatalog.of(AppLocalizations l10n) {
    final features = <AdvisorFeature>[
      for (final tool in YourDayShortcuts.all)
        if (tool.id != 'mystic_advisor')
          AdvisorFeature(
            id: tool.id,
            name: tool.label(l10n),
            open: (context) => _openShortcut(context, tool),
          ),
      AdvisorFeature(
        id: 'archetypes',
        name: l10n.toolArchetypeTitle,
        open: (context) => _push(context, const ArchetypeQuizPage()),
      ),
      AdvisorFeature(
        id: 'numerology',
        name: l10n.toolNumerologyTitle,
        open: (context) => _push(context, const NumerologyPage()),
      ),
      AdvisorFeature(
        id: 'cycle_reading',
        name: l10n.cycleReadingTitle,
        open: (_) => DeepLinkService.instance.dispatch(AppDeepLink.cycleReading),
      ),
      AdvisorFeature(
        id: 'weather',
        name: l10n.yourDayWeatherTitle,
        open: (context) => _push(context, const DailyMagicalWeatherPage()),
      ),
      AdvisorFeature(
        id: 'records',
        name: l10n.grimoireMyRecords,
        open: (context) => _push(context, const RecordsArchiveListPage()),
      ),
      AdvisorFeature(
        id: 'guided_rituals',
        name: l10n.guidedRitualsSectionTitle,
        open: (_) =>
            DeepLinkService.instance.dispatch(AppDeepLink.moonEncyclopedia),
      ),
      _link('ency_moon', l10n.encyTabMoon, AppDeepLink.moonEncyclopedia),
      _link('ency_sun', l10n.encyTabSun, AppDeepLink.sunEncyclopedia),
      _link('ency_sabbats', l10n.encyTabSabbats, AppDeepLink.sabbatsEncyclopedia),
      _link('ency_crystals', l10n.encyTabCrystals,
          AppDeepLink.crystalsEncyclopedia),
      _link('ency_herbs', l10n.encyTabHerbs, AppDeepLink.herbsEncyclopedia),
      _link('diary_gratitude', l10n.diaryTabGratitude,
          AppDeepLink.gratitudeDiary),
      _link('diary_affirmations', l10n.diaryTabAffirmations,
          AppDeepLink.affirmationsDiary),
      _link('diary_dreams', l10n.diaryTabDreams, AppDeepLink.dreamsDiary),
      _link('diary_desires', l10n.diaryTabDesires, AppDeepLink.desiresDiary),
    ];
    return AdvisorFeatureCatalog(features);
  }

  static AdvisorFeature _link(String id, String name, AppDeepLink link) =>
      AdvisorFeature(
        id: id,
        name: name,
        open: (_) => DeepLinkService.instance.dispatch(link),
      );

  /// O mesmo caminho da grade de atalhos: ação própria, destino de aba ou
  /// página empilhada. Um destino de aba funciona de cima do Conselheiro
  /// porque a HomePage troca a aba e volta a seção de destino à raiz; esta
  /// tela fica na pilha da aba de origem, como qualquer atalho.
  static void _openShortcut(BuildContext context, ShortcutTool tool) {
    final onTap = tool.onTap;
    if (onTap != null) {
      onTap(context);
      return;
    }
    final link = tool.link;
    if (link != null) {
      DeepLinkService.instance.dispatch(link);
      return;
    }
    _push(context, Builder(builder: tool.builder!));
  }

  static void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  /// A funcionalidade cujo nome casa com [highlighted], ou null.
  AdvisorFeature? match(String highlighted) {
    final wanted = normalize(highlighted);
    if (wanted.isEmpty) return null;
    for (final feature in features) {
      if (normalize(feature.name) == wanted) return feature;
    }
    return null;
  }

  static const Map<String, String> _semAcento = {
    'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
    'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'ç': 'c', 'ñ': 'n',
  };

  static final RegExp _pontuacaoFinal = RegExp(r'[.,:;!?…]+$');
  static final RegExp _artigoInicial =
      RegExp(r'^(o|a|os|as|the|el|la|los|las|un|una|um|uma)\s+');
  static final RegExp _espacos = RegExp(r'\s+');

  /// Minúsculas, sem acento, sem pontuação no fim, sem artigo no começo e
  /// com os espaços colapsados: "a Leitura de Runas." casa com o rótulo.
  static String normalize(String text) {
    final buffer = StringBuffer();
    for (final rune in text.toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_semAcento[char] ?? char);
    }
    return buffer
        .toString()
        .replaceAll(_espacos, ' ')
        .trim()
        .replaceAll(_pontuacaoFinal, '')
        .replaceFirst(_artigoInicial, '')
        .trim();
  }
}

/// A resposta dividida em trechos: corpo comum e destaques `**assim**`.
List<({String texto, bool realce})> parseAdvisorAnswer(String raw) =>
    HighlightedText.partes(raw);

/// A resposta sem os marcadores de destaque, para onde só cabe texto plano
/// (a página guardada em Meus Registros).
String stripAdvisorMarkers(String raw) => raw.replaceAll('**', '');
