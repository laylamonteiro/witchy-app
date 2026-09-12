import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../theme/grimoire_colors.dart';

/// Abre uma folha (bottom sheet) que a pessoa consegue FECHAR.
///
/// `enableDrag` e `isDismissible` já eram `true` por padrão nestas folhas, ou
/// seja: arrastar e tocar fora sempre fecharam. O que faltava era o ANÚNCIO.
/// No navegador do celular — onde a dona testa — nenhum dos dois gestos se
/// oferece, e uma folha cuja única saída é gesto invisível é, para quem olha,
/// uma folha sem saída.
///
/// O que estas telas tinham era uma alça PINTADA à mão: um retângulo de 40x4
/// desenhado DENTRO do conteúdo, sem alvo de toque, sem realce e sem semântica
/// — decoração que parecia afordância. A alça do Material que entra aqui fica
/// FORA da área rolável, tem alvo de 48x48 e rótulo de acessibilidade; e as
/// telas ainda põem lá dentro um [BotaoFecharFolha] visível, porque botão se
/// vê e gesto não.
Future<T?> mostrarFolhaComSaida<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    showDragHandle: true,
    backgroundColor: context.gc.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: builder,
  );
}

/// O X que fecha a folha.
///
/// A alça de arrasto é o segundo afordance; este é o primeiro, porque botão
/// se vê e gesto não. Mesmo desenho em todas as folhas para que fechar uma
/// ensine a fechar as outras.
class BotaoFecharFolha extends StatelessWidget {
  const BotaoFecharFolha({super.key, this.onPressed});

  /// O que fazer ao fechar. Quando nulo, fecha a própria folha sem devolver
  /// resultado — que é o que "desistir" significa em quase toda folha.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        final acao = onPressed;
        if (acao != null) {
          acao();
          return;
        }
        Navigator.of(context).maybePop();
      },
      icon: const Icon(Icons.close, size: 20),
      tooltip: AppLocalizations.of(context).commonClose,
      color: context.gc.textSecondary,
    );
  }
}
