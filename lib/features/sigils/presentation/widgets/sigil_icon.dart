import 'package:flutter/material.dart';

import '../../../../core/tools/tool_identity.dart';

/// O emblema dos Sigilos dentro da tela.
///
/// Era o caractere ⛤ (U+26E4) escrito num `Text`. Num aparelho sem fonte que
/// cubra esse bloco do Unicode, o cabeçalho "O que é um Sigilo?" aparecia ao
/// lado do quadradinho de glifo ausente — e Sigilos é justamente a ferramenta
/// cujo assunto É o símbolo desenhado. Agora é o MESMO emblema do card do
/// Grimório e da AppBar (ver [ToolIdentity]), que não depende de fonte
/// instalada e ainda normaliza o tamanho: o glifo crescia junto com a fonte do
/// sistema, o desenho ocupa o quadrado que recebe.
///
/// O widget continua existindo, em vez de o chamador montar o [ToolEmblem]
/// direto, porque é ele que fixa as duas decisões desta tela: o emblema é o
/// dos Sigilos e ele NÃO voa. O Hero da rota já é o da AppBar, e dois heróis
/// com a mesma etiqueta na mesma tela lançam exceção.
class SigilIcon extends StatelessWidget {
  const SigilIcon({
    super.key,
    this.size = 48,
  });

  final double size;

  @override
  Widget build(BuildContext context) =>
      ToolEmblem(tool: ToolId.sigils, size: size, flies: false);
}
