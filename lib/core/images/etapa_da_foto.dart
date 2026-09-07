/// Em que passo do caminho da foto a tela está. Serve para a tela mostrar
/// "Convertendo…" em vez de um spinner mudo: uma foto HEIC de 12 MP leva
/// alguns segundos a mais, e silêncio parece travamento.
enum EtapaDaFoto {
  /// O seletor do aparelho está aberto.
  abrindo,

  /// Decodificando/convertendo para um formato que a tela abre (HEIC → JPEG,
  /// na web pelo libheif).
  convertendo,

  /// A tela de recorte está aberta.
  recortando,

  /// Redução final (lado maior de 1600 px, JPEG).
  reduzindo,
}
