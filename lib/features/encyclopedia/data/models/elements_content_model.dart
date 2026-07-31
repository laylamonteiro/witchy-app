/// Modelo do conteúdo editorial da página "Os Quatro Elementos".
///
/// O texto é localizado por idioma nos arquivos
/// `elements_content_pt/en/es.dart` (data_sources), selecionados em tempo de
/// execução por `elements_content.dart` via `ContentLocale`. Emojis e a
/// ordem/contagem das listas são invariantes entre idiomas — a paridade é
/// verificada em `test/encyclopedia_content_parity_test.dart`.
class ElementsContent {
  /// Título da AppBar.
  final String pageTitle;

  // Introdução
  final String introTitle;
  final String introBody;
  final String introHint;

  // Rótulos das subseções de cada elemento
  final String essenceLabel;
  final String qualitiesLabel;
  final String directionLabel;
  final String seasonLabel;
  final String lifePhaseLabel;
  final String timeOfDayLabel;
  final String colorsLabel;
  final String toolsLabel;
  final String correspondencesLabel;

  /// Os quatro elementos, na ordem Terra, Água, Fogo, Ar.
  final List<ElementInfo> elements;

  // Equilíbrio elemental
  final String balanceTitle;
  final String balanceIntro;
  final List<ElementBalanceItem> balanceItems;
  final String imbalanceTitle;
  final String imbalanceBody;

  // Como trabalhar com os elementos
  final String practicesTitle;
  final List<ElementPractice> practices;

  // Honrando os elementos
  final String honoringTitle;
  final String honoringBody;

  const ElementsContent({
    required this.pageTitle,
    required this.introTitle,
    required this.introBody,
    required this.introHint,
    required this.essenceLabel,
    required this.qualitiesLabel,
    required this.directionLabel,
    required this.seasonLabel,
    required this.lifePhaseLabel,
    required this.timeOfDayLabel,
    required this.colorsLabel,
    required this.toolsLabel,
    required this.correspondencesLabel,
    required this.elements,
    required this.balanceTitle,
    required this.balanceIntro,
    required this.balanceItems,
    required this.imbalanceTitle,
    required this.imbalanceBody,
    required this.practicesTitle,
    required this.practices,
    required this.honoringTitle,
    required this.honoringBody,
  });
}

/// Um dos quatro elementos. O [emoji] é invariante entre idiomas.
class ElementInfo {
  final String name;
  final String emoji;
  final String essence;
  final String qualities;
  final String direction;
  final String season;
  final String lifePhase;
  final String timeOfDay;
  final String colors;
  final String tools;
  final String correspondences;

  /// Título da subseção "Quando Trabalhar com <elemento>" (leva o nome
  /// traduzido do elemento, por isso fica no verbete e não como rótulo comum).
  final String whenToWorkTitle;
  final String whenToWork;

  const ElementInfo({
    required this.name,
    required this.emoji,
    required this.essence,
    required this.qualities,
    required this.direction,
    required this.season,
    required this.lifePhase,
    required this.timeOfDay,
    required this.colors,
    required this.tools,
    required this.correspondences,
    required this.whenToWorkTitle,
    required this.whenToWork,
  });
}

/// Item da seção de equilíbrio (emoji invariante + nome + descrição).
class ElementBalanceItem {
  final String emoji;
  final String name;
  final String description;

  const ElementBalanceItem(this.emoji, this.name, this.description);
}

/// Prática de trabalho com os elementos.
class ElementPractice {
  final String title;
  final String description;

  const ElementPractice(this.title, this.description);
}
