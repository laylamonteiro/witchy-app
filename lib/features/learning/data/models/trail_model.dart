import '../../../grimoire/data/models/spell_model.dart';

/// Trilha de aprendizado do Grimório Vivo.
///
/// Conceito: aprender FAZENDO o próprio grimório — cada lição termina com a
/// criação de uma página real (feitiço/prática) no Meu Grimório da pessoa.
class LearningTrail {
  final String id;
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final List<TrailLesson> lessons;

  const LearningTrail({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.lessons,
  });
}

/// Uma lição: ensino curto -> prática -> página do grimório.
class TrailLesson {
  final String id;
  final String title;

  /// Conteúdo de ensino (2-4 parágrafos, texto corrido).
  final String teaching;

  /// Prática sugerida antes de escrever a página.
  final String practice;

  /// A página a criar: título sugerido e roteiro que pré-preenche o
  /// formulário de feitiço do app.
  final String pageTitle;
  final String pagePurpose;
  final SpellCategory pageCategory;
  final SpellType pageType;
  final List<String> pageIngredients;
  final String pageStepsTemplate;

  const TrailLesson({
    required this.id,
    required this.title,
    required this.teaching,
    required this.practice,
    required this.pageTitle,
    required this.pagePurpose,
    required this.pageCategory,
    this.pageType = SpellType.attraction,
    this.pageIngredients = const [],
    required this.pageStepsTemplate,
  });
}
