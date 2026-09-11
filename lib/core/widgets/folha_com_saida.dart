import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../theme/grimoire_colors.dart';

/// Abre uma folha (bottom sheet) que a pessoa consegue FECHAR.
///
/// No navegador do celular — onde a dona testa — arrastar a folha para baixo
/// não se anuncia e tocar fora não tem afordância nenhuma. Uma folha cuja
/// única saída é o gesto é, na prática, uma folha sem saída.
///
/// Por isso toda folha aberta por aqui nasce com a alça de arrasto DE VERDADE
/// (a do Material, que arrasta mesmo) e as telas põem lá dentro um
/// [BotaoFecharFolha] visível. O que estas telas tinham antes era uma alça
/// PINTADA à mão: um retângulo de 40x4 prometendo um gesto que não existia.
///
/// `enableDrag` e `isDismissible` ficam no padrão do Material (ambos `true`) —
/// o gesto e o toque fora continuam funcionando; o que faltava era o anúncio.
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
