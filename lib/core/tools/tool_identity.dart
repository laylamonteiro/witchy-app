import 'package:flutter/material.dart';

import '../../features/sigils/presentation/widgets/sigil_icon.dart';
import '../theme/app_theme.dart';

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

  static const Map<ToolId, String> emblems = {
    ToolId.livingGrimoire: '📖',
    ToolId.mysticAdvisor: '🔮',
    ToolId.sigils: kSigilIconGlyph,
    ToolId.natureGuide: '🍃',
    ToolId.tarot: '🎴',
    ToolId.dreams: '🌙',
    ToolId.palmistry: '🖐️',
    ToolId.runes: ' ᚱ ',
    ToolId.oracle: '🃏',
    ToolId.pendulum: ' ⟟ ',
    ToolId.archetypes: '🎭',
    ToolId.numerology: '🔢',
  };

  static String emblemOf(ToolId tool) => emblems[tool] ?? '✦';

  static String heroTag(ToolId tool) => 'tool-emblem-${tool.name}';
}

/// O emblema da ferramenta, do tamanho que couber.
///
/// Com [flies], o mesmo emblema do card viaja até o cabeçalho da ferramenta
/// ao abri-la: a arte da entrada continua na cena, em vez de a tela começar
/// do zero. O símbolo é desenhado num quadrado e ajustado por dentro, então
/// os dois tamanhos são o mesmo desenho.
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
    final art = SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
          ToolIdentity.emblemOf(tool),
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
