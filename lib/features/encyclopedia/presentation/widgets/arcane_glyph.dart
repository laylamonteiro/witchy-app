import 'package:flutter/material.dart';

import '../../data/data_sources/arcane_categories.dart';
import '../../data/models/arcane_entry_model.dart';
import 'archetype_glyph.dart';

/// A arte de um verbete arcano: o DESENHO quando a categoria tem desenho, o
/// emoji do próprio verbete quando não tem.
///
/// As páginas de verbete (`arcane_list_page`, `arcane_detail_page`) são
/// genéricas e servem às quatro categorias, então a escolha entre desenho e
/// emoji não pode ficar espalhada por elas — cada call site esquecido
/// devolveria a lista e o detalhe mostrando coisas diferentes. Ela mora em um
/// widget só, que pergunta a resposta a [ArcaneCategory.glyphIdFor]. Uma
/// segunda categoria desenhada, depois, é uma linha lá e nenhuma aqui.
///
/// [size] é o lado da caixa do DESENHO, não o corpo do emoji. Para trocar um
/// emoji por um desenho sem mudar o tamanho aparente, use
/// [ArchetypeGlyphArt.boxForEmojiSize] — o emoji preenche quase todo o corpo
/// da fonte, enquanto o desenho ocupa dois terços da caixa.
///
/// Os dois lados ficam MUDOS para o leitor de tela. Em todos os usos de hoje
/// o nome do verbete está escrito ao lado, e era ele que devia falar: a barra
/// do verbete dizia "mulher maga, A Bruxa" e a linha de origem dizia "coruja,
/// Grimório de Salomão". O desenho não tem nome próprio a acrescentar e o
/// emoji nunca teve.
class ArcaneGlyph extends StatelessWidget {
  const ArcaneGlyph({
    super.key,
    required this.category,
    required this.entry,
    required this.size,
    this.emojiStyle,
  });

  final ArcaneCategory category;
  final ArcaneEntry entry;

  /// Lado da caixa do desenho.
  final double size;

  /// Estilo do emoji quando a categoria não tem desenho. Nulo herda o estilo
  /// do contexto, como o `Text` que estava no lugar deste widget.
  final TextStyle? emojiStyle;

  @override
  Widget build(BuildContext context) {
    final id = category.glyphIdFor(entry);
    if (id != null && archetypeGlyphArt(id) != null) {
      return ArchetypeGlyph(id: id, size: size);
    }
    return ExcludeSemantics(child: Text(entry.emoji, style: emojiStyle));
  }
}
