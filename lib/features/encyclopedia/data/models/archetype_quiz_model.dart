/// Modelo das perguntas do Teste de Arquétipo.
///
/// O texto é localizado por idioma nos arquivos
/// `archetype_quiz_data_pt/en/es.dart` (data_sources), selecionados em tempo
/// de execução por `archetype_quiz_data.dart` via `ContentLocale`.
///
/// Cada opção pontua para um arquétipo da Enciclopédia identificado pelo
/// [ArchetypeQuizOption.archetypeEmoji] — o emoji do `ArcaneEntry`, que é
/// invariante entre idiomas (os nomes são traduzidos, então não servem de
/// chave). A paridade e o mapeamento resposta→arquétipo são verificados em
/// `test/encyclopedia_content_parity_test.dart`.
class ArchetypeQuizQuestion {
  final String text;
  final List<ArchetypeQuizOption> options;

  const ArchetypeQuizQuestion(this.text, this.options);
}

class ArchetypeQuizOption {
  final String text;

  /// Chave invariante do arquétipo: deve casar com `ArcaneEntry.emoji`.
  final String archetypeEmoji;

  const ArchetypeQuizOption(this.text, this.archetypeEmoji);
}
