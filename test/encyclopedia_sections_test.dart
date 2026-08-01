import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/navigation/encyclopedia_section.dart';

/// Congela a ordem canônica das seções da Enciclopédia.
///
/// TabBar, TabBarView, o sumário do livro-índice e os deep links derivam
/// todos de EncyclopediaSection — reordenar o enum reordena o app inteiro
/// junto, então qualquer mudança aqui deve ser CONSCIENTE: atualize a lista
/// abaixo junto com o enum.
void main() {
  test('a ordem canônica das seções está congelada', () {
    expect(EncyclopediaSection.values, const [
      EncyclopediaSection.bookIndex,
      EncyclopediaSection.moon,
      EncyclopediaSection.sun,
      EncyclopediaSection.sabbats,
      EncyclopediaSection.crystals,
      EncyclopediaSection.herbs,
      EncyclopediaSection.colors,
      EncyclopediaSection.goddesses,
      EncyclopediaSection.elements,
      EncyclopediaSection.runes,
      EncyclopediaSection.altar,
      EncyclopediaSection.metals,
      EncyclopediaSection.archetypes,
      EncyclopediaSection.symbols,
      EncyclopediaSection.angels,
      EncyclopediaSection.demons,
    ]);
  });
}
