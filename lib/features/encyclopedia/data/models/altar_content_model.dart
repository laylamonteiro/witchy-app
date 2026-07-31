/// Modelo do conteúdo editorial da página "O Altar Mágico".
///
/// O texto é localizado por idioma nos arquivos
/// `altar_content_pt/en/es.dart` (data_sources), selecionados em tempo de
/// execução por `altar_content.dart` via `ContentLocale`. Emojis e a
/// ordem/contagem das listas são invariantes entre idiomas — a paridade é
/// verificada em `test/encyclopedia_content_parity_test.dart`.
class AltarContent {
  /// Título da AppBar.
  final String pageTitle;

  // Introdução
  final String introTitle;
  final String introBody;
  final String introHint;

  // Passo-a-passo para iniciantes
  final String beginnerTitle;
  final String beginnerSubtitle;
  final String beginnerIntro;
  final List<AltarNumberedStep> beginnerSteps;
  final String firstTimesTitle;
  final List<String> firstTimesItems;
  final String speakTitle;
  final List<AltarSpeech> speakExamples;
  final String speakNote;
  final String faqTitle;
  final List<AltarFaq> faqs;

  // Como montar
  final String mountTitle;
  final List<AltarStep> mountSteps;

  // O que usar
  final String itemsTitle;
  final List<AltarEmojiItem> items;
  final String itemsNote;

  // O que evitar
  final String avoidTitle;
  final List<AltarStep> avoidItems;
  final String safetyNote;

  // Como purificar
  final String purifyTitle;
  final String purifyIntro;
  final List<AltarEmojiItem> purifyMethods;
  final String purifyFrequency;

  // Como manter
  final String maintainTitle;
  final List<AltarStep> maintainItems;

  // Como utilizar
  final String usageTitle;
  final List<AltarStep> usageItems;
  final String routineTitle;
  final String routineBody;

  // Considerações finais
  final String finalTitle;
  final String finalBody;

  const AltarContent({
    required this.pageTitle,
    required this.introTitle,
    required this.introBody,
    required this.introHint,
    required this.beginnerTitle,
    required this.beginnerSubtitle,
    required this.beginnerIntro,
    required this.beginnerSteps,
    required this.firstTimesTitle,
    required this.firstTimesItems,
    required this.speakTitle,
    required this.speakExamples,
    required this.speakNote,
    required this.faqTitle,
    required this.faqs,
    required this.mountTitle,
    required this.mountSteps,
    required this.itemsTitle,
    required this.items,
    required this.itemsNote,
    required this.avoidTitle,
    required this.avoidItems,
    required this.safetyNote,
    required this.purifyTitle,
    required this.purifyIntro,
    required this.purifyMethods,
    required this.purifyFrequency,
    required this.maintainTitle,
    required this.maintainItems,
    required this.usageTitle,
    required this.usageItems,
    required this.routineTitle,
    required this.routineBody,
    required this.finalTitle,
    required this.finalBody,
  });
}

/// Par título + descrição (passos, avisos, manutenção, usos).
class AltarStep {
  final String title;
  final String description;

  const AltarStep(this.title, this.description);
}

/// Passo numerado do guia para iniciantes, com dica extra.
class AltarNumberedStep {
  final String title;
  final String description;
  final String tip;

  const AltarNumberedStep(this.title, this.description, this.tip);
}

/// Item com emoji invariante (itens do altar, métodos de purificação).
class AltarEmojiItem {
  final String emoji;
  final String title;
  final String description;

  const AltarEmojiItem(this.emoji, this.title, this.description);
}

/// Exemplo de fala no altar (rótulo + frase sugerida).
class AltarSpeech {
  final String label;
  final String phrase;

  const AltarSpeech(this.label, this.phrase);
}

/// Dúvida comum de iniciantes.
class AltarFaq {
  final String question;
  final String answer;

  const AltarFaq(this.question, this.answer);
}
