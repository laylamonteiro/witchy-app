import '../../../grimoire/data/models/spell_model.dart';
import '../../domain/menstrual_shortcut.dart';

/// As quatro áreas dos "Saberes do Sangue".
///
/// A ordem é a da tela, e os ids são invariantes entre idiomas: traduzir
/// nunca muda identidade nem estrutura do conteúdo (a mesma regra das runas,
/// das cartas e dos sabbats).
enum BloodLoreCategory {
  /// 🩸 O sangue na magia.
  bloodInMagic,

  /// 🌙 Ciclo e Lua.
  cycleAndMoon,

  /// 🔮 Práticas e feitiços.
  practices,

  /// 📜 Tradições e história.
  traditions,
}

/// A etiqueta editorial de um conteúdo: de onde ele vem.
///
/// Ela existe para que história e invenção não se confundam. Um verbete
/// marcado como documentado descreve o que os registros mostram; um marcado
/// como adaptação diz, sem rodeio, que a prática é de agora.
enum BloodLoreTag {
  /// 📜 Historicamente documentado.
  documented,

  /// 🌿 Tradição específica (de um povo, de uma região — nunca universal).
  tradition,

  /// ✨ Prática contemporânea.
  contemporary,

  /// 🔮 Adaptação moderna de algo documentado.
  modernAdaptation,
}

extension BloodLoreCategoryEmoji on BloodLoreCategory {
  /// O emblema da área. Invariante: não é texto traduzível.
  String get emoji => switch (this) {
        BloodLoreCategory.bloodInMagic => '🩸',
        BloodLoreCategory.cycleAndMoon => '🌙',
        BloodLoreCategory.practices => '🔮',
        BloodLoreCategory.traditions => '📜',
      };
}

extension BloodLoreTagEmoji on BloodLoreTag {
  /// O emblema da etiqueta. Invariante, como o da área.
  String get emoji => switch (this) {
        BloodLoreTag.documented => '📜',
        BloodLoreTag.tradition => '🌿',
        BloodLoreTag.contemporary => '✨',
        BloodLoreTag.modernAdaptation => '🔮',
      };
}

/// Para onde um convite leva.
///
/// Nenhum destino daqui é novo: são as ferramentas que o Grimório já tem. O
/// Ciclo é a lente, não um segundo aplicativo.
enum BloodLoreLink {
  /// Outro verbete desta mesma área.
  entry,

  /// O criador de sigilos que já existe no Grimório.
  sigils,

  /// A escrita livre dos Diários.
  diary,

  /// O diário de sonhos.
  dreams,

  /// O Oráculo.
  oracle,
}

/// Um convite ao fim de um verbete.
class BloodLoreCta {
  const BloodLoreCta({required this.label, required this.link, this.entryId});

  final String label;
  final BloodLoreLink link;

  /// Só para [BloodLoreLink.entry]: o id do verbete de destino.
  final String? entryId;
}

/// Um trecho de um verbete: um subtítulo e o corpo dele.
class BloodLoreSection {
  const BloodLoreSection({required this.title, required this.body});

  final String title;
  final String body;
}

/// Um verbete dos Saberes do Sangue — um texto, ou uma prática.
///
/// Prática e texto são o mesmo objeto de propósito: a diferença é ter ou não
/// [steps]. Assim uma prática pode explicar de onde veio com as mesmas
/// seções de um verbete de história, e a tela tem um renderizador só.
class BloodLoreEntry {
  const BloodLoreEntry({
    required this.id,
    required this.category,
    required this.tag,
    required this.emoji,
    required this.title,
    required this.summary,
    required this.sections,
    this.intention,
    this.materials = const [],
    this.steps = const [],
    this.withoutBlood,
    this.mentionsBlood = false,
    this.cta,
  });

  /// Identidade estável, igual nos três idiomas.
  final String id;

  final BloodLoreCategory category;
  final BloodLoreTag tag;

  /// O emblema do verbete. Invariante, como os das áreas.
  final String emoji;

  final String title;

  /// Uma linha para o cartão da lista.
  final String summary;

  final List<BloodLoreSection> sections;

  /// Só nas práticas: a intenção declarada.
  final String? intention;

  /// Só nas práticas.
  final List<String> materials;
  final List<String> steps;

  /// Só nas práticas que oferecem sangue como possibilidade: a mesma prática
  /// sem ele. Nenhuma prática do Grimório EXIGE sangue.
  final String? withoutBlood;

  /// O verbete fala de sangue? Quando sim, a nota de segurança acompanha —
  /// curta, no rodapé, sem virar alerta que quebre a leitura.
  final bool mentionsBlood;

  final BloodLoreCta? cta;

  /// Uma prática é um verbete que tem passos.
  bool get isPractice => steps.isNotEmpty;
}

/// O texto de um atalho contextual ("Práticas para este momento").
///
/// O emblema não mora aqui: ele é invariante e vem de
/// [MenstrualShortcutEmoji].
class BloodLoreShortcut {
  const BloodLoreShortcut({
    required this.title,
    required this.body,
    this.prompt,
  });

  final String title;
  final String body;

  /// Só nos atalhos que abrem o Diário: o convite que a folha mostra acima
  /// do campo. É convite, nunca conteúdo — o que ela escrever continua sendo
  /// uma entrada normal do Diário.
  final String? prompt;
}

/// Tudo o que os Saberes do Sangue dizem, num idioma.
///
/// Mora na camada de conteúdo (e não no ARB) pela mesma razão que o altar e
/// os elementos moram: são ITENS com id, categoria e etiqueta, não frases
/// fixas de uma tela. A paridade pt/en/es é garantida por teste.
class BloodLoreContent {
  const BloodLoreContent({
    required this.pageTitle,
    required this.intro,
    required this.introNote,
    required this.categoryTitles,
    required this.categorySubtitles,
    required this.tagLabels,
    required this.safetyNote,
    required this.classificationLabel,
    required this.practiceIntentionLabel,
    required this.practiceMaterialsLabel,
    required this.practiceStepsLabel,
    required this.practiceWithoutBloodLabel,
    required this.entriesCountTemplate,
    required this.cycleCta,
    required this.momentTitle,
    required this.momentIntro,
    required this.shortcuts,
    required this.moonCorrespondences,
    required this.correspondenceTemplate,
    required this.startUnderTemplate,
    required this.phaseTallyTemplate,
    required this.moonNotSynced,
    required this.closingCorrespondence,
    required this.entries,
  });

  /// A folha de rosto da área.
  final String pageTitle;
  final String intro;
  final String introNote;

  final Map<BloodLoreCategory, String> categoryTitles;
  final Map<BloodLoreCategory, String> categorySubtitles;
  final Map<BloodLoreTag, String> tagLabels;

  /// A nota de segurança das práticas com sangue. Uma só, curta, repetida
  /// onde precisa aparecer — nunca reescrita caso a caso.
  final String safetyNote;

  final String classificationLabel;
  final String practiceIntentionLabel;
  final String practiceMaterialsLabel;
  final String practiceStepsLabel;
  final String practiceWithoutBloodLabel;

  /// "{count} textos" — quantos verbetes a área tem.
  final String entriesCountTemplate;

  /// O convite que a página do Ciclo mostra: "Explorar os saberes do sangue".
  final String cycleCta;

  /// "Práticas para este momento".
  final String momentTitle;
  final String momentIntro;

  final Map<MenstrualShortcut, BloodLoreShortcut> shortcuts;

  /// A correspondência mágica de cada fase — o que a magia lunar costuma
  /// associar a ela. Nunca uma afirmação sobre o corpo de quem lê.
  final Map<MoonPhase, String> moonCorrespondences;

  /// "Na magia lunar, {phase} costuma ser associada a {meaning}."
  final String correspondenceTemplate;

  /// "Seu último ciclo começou sob {phase}."
  final String startUnderTemplate;

  /// "{count} dos seus {total} últimos começos aconteceram sob {phase}."
  final String phaseTallyTemplate;

  /// A frase que impede a leitura de virar biologia.
  final String moonNotSynced;

  /// A frase do encontro entre sangramento e Lua que recolhe.
  final String closingCorrespondence;

  final List<BloodLoreEntry> entries;

  /// Os verbetes de uma área, na ordem em que foram escritos.
  List<BloodLoreEntry> of(BloodLoreCategory category) =>
      [for (final entry in entries) if (entry.category == category) entry];

  /// Um verbete pelo id, ou nulo — um convite que aponta para um id que não
  /// existe simplesmente não aparece, em vez de derrubar a tela.
  BloodLoreEntry? byId(String id) {
    for (final entry in entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  /// Troca os marcadores de um modelo pelo que a tela tem para dizer.
  static String fill(String template, Map<String, String> values) {
    var text = template;
    values.forEach((key, value) => text = text.replaceAll('{$key}', value));
    return text;
  }
}
