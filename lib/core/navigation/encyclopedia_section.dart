/// As seções da Enciclopédia Mágica, na ORDEM CANÔNICA das abas.
///
/// A ordem de declaração É a ordem exibida: o índice da aba de uma seção é
/// `section.index`. TabBar, TabBarView, o sumário do livro-índice e os deep
/// links derivam todos deste enum — não existe segunda lista para desatualizar;
/// reordenar aqui reordena o app inteiro junto.
///
/// Vive em core/navigation porque [AppDeepLink] (também core) referencia
/// seções em construtores const, e core não importa código de features.
enum EncyclopediaSection {
  /// A capa do livro: o sumário da Enciclopédia (não pode se chamar `index`,
  /// que colide com o getter nativo `Enum.index`).
  bookIndex,

  moon,
  sun,
  sabbats,
  colors,
  crystals,
  herbs,
  goddesses,
  elements,
  runes,
  altar,
  metals,
  archetypes,
  symbols,
  angels,
  demons,
}
