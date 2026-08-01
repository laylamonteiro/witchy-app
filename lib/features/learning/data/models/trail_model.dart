import '../../../grimoire/data/models/spell_model.dart';

/// Onde a página escrita na lição é registrada dentro do app.
///
/// A ideia do Grimório Vivo é levar a pessoa a usar todas as
/// funcionalidades naturalmente: cada lição salva no lugar certo.
enum LessonRecordKind {
  /// Meu Grimório → Meus Feitiços (um feitiço de verdade).
  spell,

  /// Meu Grimório → Meus Registros (estudo, reflexão, planejamento).
  note,

  /// Diário de Sonhos.
  dream,

  /// Diário de Gratidão.
  gratitude,

  /// Afirmações.
  affirmation,

  /// Diário de Desejos.
  desire,

  /// Registro + atalho para a ferramenta de Sigilos.
  sigil,

  /// Registro + atalho para as Runas.
  rune,

  /// Registro + atalho para as Cartas do Oráculo.
  oracle,

  /// Registro + atalho para o Pêndulo.
  pendulum,

  /// Registro + atalho para o Tarot.
  tarot,
}

extension LessonRecordKindX on LessonRecordKind {
  /// Tipos que abrem uma ferramenta do app como parte da prática.
  bool get isTool => switch (this) {
        LessonRecordKind.sigil ||
        LessonRecordKind.rune ||
        LessonRecordKind.oracle ||
        LessonRecordKind.pendulum ||
        LessonRecordKind.tarot =>
          true,
        _ => false,
      };

  /// Tipos gravados no Meu Grimório como página de registro (não feitiço).
  bool get savesAsNote => this != LessonRecordKind.spell && !savesInDiary;

  /// Tipos gravados nos Diários.
  bool get savesInDiary => switch (this) {
        LessonRecordKind.dream ||
        LessonRecordKind.gratitude ||
        LessonRecordKind.affirmation ||
        LessonRecordKind.desire =>
          true,
        _ => false,
      };
}

/// Ferramenta exata aberta pelo atalho da Prática de uma lição.
///
/// Permite que a lição leve direto à funcionalidade necessária (ex.: a
/// primeira lição de Tarot abre a Biblioteca de Cartas, as de fixação
/// abrem o Tutor). Quando a lição não define, o destino padrão vem do
/// [LessonRecordKind].
enum LessonTool {
  sigils,
  runes,
  oracle,
  pendulum,
  tarot,
  tarotLibrary,
  tarotTutor,
  palmistry,

  /// Fluxos "Adicionar em..." da enciclopédia pessoal: a prática pede para
  /// identificar uma planta/pedra/cor por foto e criar o verbete próprio —
  /// assim cada lição também faz a enciclopédia da pessoa crescer.
  addHerb,
  addCrystal,
  addColor,
}

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

/// Uma lição: ensino curto -> prática -> página guiada.
class TrailLesson {
  final String id;
  final String title;

  /// Conteúdo de ensino (parágrafos separados por \n\n).
  final String teaching;

  /// Prática sugerida antes de escrever a página.
  final String practice;

  /// A página a criar no Meu Grimório.
  final String pageTitle;
  final String pagePurpose;
  final SpellCategory pageCategory;
  final SpellType pageType;
  final List<String> pageIngredients;

  /// Perguntas do preenchimento guiado: cada uma vira um campo próprio e a
  /// página final é montada com pergunta + resposta.
  final List<String> pagePrompts;

  /// Onde esta página é registrada (feitiço, registro, diário, ferramenta).
  final LessonRecordKind recordKind;

  /// Ferramenta específica que o atalho da Prática abre. Nulo = destino
  /// padrão derivado do [recordKind].
  final LessonTool? tool;

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
    required this.pagePrompts,
    this.recordKind = LessonRecordKind.spell,
    this.tool,
  });

  /// Ferramenta que a Prática desta lição abre, quando houver.
  LessonTool? get toolTarget =>
      tool ??
      switch (recordKind) {
        LessonRecordKind.sigil => LessonTool.sigils,
        LessonRecordKind.rune => LessonTool.runes,
        LessonRecordKind.oracle => LessonTool.oracle,
        LessonRecordKind.pendulum => LessonTool.pendulum,
        LessonRecordKind.tarot => LessonTool.tarot,
        _ => null,
      };
}
