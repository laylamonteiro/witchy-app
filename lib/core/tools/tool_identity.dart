import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'tool_emblem_art.dart';

/// As doze ferramentas do Grimório, por identidade estável.
///
/// O nome de cada uma é traduzido; o emblema não. É ele que liga o card de
/// entrada à tela de destino, então precisa ser o mesmo símbolo dos dois
/// lados — e a chave que os une não pode ser um texto traduzido.
enum ToolId {
  livingGrimoire,
  mysticAdvisor,
  sigils,
  natureGuide,
  tarot,
  dreams,
  palmistry,
  runes,
  oracle,
  pendulum,
  archetypes,
  numerology,
}

/// O emblema de cada ferramenta e a etiqueta do voo entre card e cena.
abstract class ToolIdentity {
  ToolIdentity._();

  /// As nove ferramentas cujo emblema é um emoji — desenho que TODO aparelho
  /// tem, porque vem do próprio sistema.
  static const Map<ToolId, String> emojis = {
    ToolId.livingGrimoire: '📖',
    ToolId.mysticAdvisor: '🔮',
    ToolId.natureGuide: '🍃',
    ToolId.tarot: '🎴',
    ToolId.dreams: '🌙',
    ToolId.palmistry: '🖐️',
    ToolId.oracle: '🃏',
    ToolId.archetypes: '🎭',
    ToolId.numerology: '🔢',
  };

  /// As três que o app desenha. Eram glifos de blocos raros do Unicode (⛤, ᚱ
  /// e ⟟): sem uma fonte de símbolos instalada, o aparelho mostrava o
  /// quadradinho de glifo ausente no lugar do emblema. Ver [ToolDrawing].
  static const Map<ToolId, ToolDrawing> drawings = {
    ToolId.sigils: ToolDrawing.pentagram,
    ToolId.runes: ToolDrawing.raidho,
    ToolId.pendulum: ToolDrawing.pendulum,
  };

  /// O emoji da ferramenta, ou null quando o emblema dela é desenhado.
  static String? emojiOf(ToolId tool) => emojis[tool];

  /// O desenho da ferramenta, ou null quando o emblema dela é um emoji.
  static ToolDrawing? drawingOf(ToolId tool) => drawings[tool];

  static String heroTag(ToolId tool) => 'tool-emblem-${tool.name}';
}

/// O emblema da ferramenta, do tamanho que couber.
///
/// Com [flies], o mesmo emblema do card viaja até o cabeçalho da ferramenta
/// ao abri-la: a arte da entrada continua na cena, em vez de a tela começar
/// do zero. Emoji ou desenho, a arte ocupa um quadrado e se ajusta por
/// dentro dele, então os dois tamanhos são a mesma arte.
class ToolEmblem extends StatelessWidget {
  const ToolEmblem({
    super.key,
    required this.tool,
    this.size = 40,
    this.flies = true,
  });

  final ToolId tool;
  final double size;
  final bool flies;

  @override
  Widget build(BuildContext context) {
    final drawing = ToolIdentity.drawingOf(tool);
    final Widget art = drawing != null
        // Sem rótulo de propósito: nos dois lugares em que o emblema aparece
        // (o card do Grimório e o cabeçalho da tela) o nome da ferramenta
        // está escrito ao lado, e rotular o desenho faria o leitor de tela
        // dizer o mesmo nome duas vezes. Ver [ToolDrawingArt].
        ? ToolDrawingArt(drawing: drawing, size: size)
        : SizedBox(
            width: size,
            height: size,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                ToolIdentity.emojiOf(tool) ?? '✦',
                style: const TextStyle(fontSize: 40),
              ),
            ),
          );
    if (!flies) return art;
    return Hero(
      tag: ToolIdentity.heroTag(tool),
      // Em voo o emblema fica fora da árvore da tela: sem um Material por
      // perto, o texto não teria de onde tirar estilo.
      child: Material(type: MaterialType.transparency, child: art),
    );
  }
}

/// O cabeçalho de uma ferramenta: o emblema que veio do card e o título
/// traduzido, que continua encolhendo para caber como em qualquer AppBar.
class ToolHeading extends StatelessWidget {
  const ToolHeading({
    super.key,
    required this.tool,
    required this.title,
    this.flies = true,
  });

  final ToolId tool;
  final String title;
  final bool flies;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ToolEmblem(tool: tool, size: 22, flies: flies),
          const SizedBox(width: 8),
          Flexible(child: ResponsiveAppBarTitle(title)),
        ],
      );
}
