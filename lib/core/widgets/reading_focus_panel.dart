import 'package:flutter/material.dart';

import '../theme/grimoire_colors.dart';
import '../theme/grimoire_motion.dart';
import '../../l10n/generated/app_localizations.dart';
import 'magical_card.dart';

/// O painel de foco de uma tiragem: a peça grande em cima, o que ela diz
/// embaixo, e um lugar fixo na página para os dois.
///
/// Ele existe por causa de um defeito concreto: tocar numa carta da mesa
/// abria a carta grande E rolava a página até o texto no mesmo quadro, então
/// a carta ia embora antes de ser vista. Aqui a página não viaja. A peça tem
/// caixa de tamanho fixo e fica sempre no mesmo lugar; o texto troca por
/// baixo dela. Não há para onde rolar porque não há destino: o destino já
/// está na tela.
///
/// Percorrer as posições tem três caminhos, e nenhum deles é o único: tocar
/// outra peça na mesa, as setas do painel (que funcionam com teclado, para a
/// web) ou arrastar o painel na horizontal.
class ReadingFocusPanel extends StatelessWidget {
  const ReadingFocusPanel({
    super.key,
    required this.keyPrefix,
    required this.index,
    required this.total,
    required this.onFocus,
    required this.child,
    this.stage,
  });

  /// Prefixo das chaves ('oracle' ou 'runes'), para os testes encontrarem
  /// cada parte sem inventar uma segunda convenção.
  final String keyPrefix;

  final int index;
  final int total;
  final ValueChanged<int> onFocus;

  /// A peça grande. Nula numa tiragem de uma peça só: ali a mesa já é o
  /// palco, e repetir a figura seria mostrá-la duas vezes à toa.
  final Widget? stage;

  /// O texto da posição em foco.
  final Widget child;

  void _swipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 200) return;
    final next = velocity < 0 ? index + 1 : index - 1;
    if (next < 0 || next >= total) return;
    onFocus(next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reduced = GrimoireMotion.reduced(context);
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onHorizontalDragEnd: total > 1 ? _swipe : null,
      child: MagicalCard(
        key: ValueKey('$keyPrefix-focus'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (stage != null) ...[
              Center(child: stage!),
              const SizedBox(height: 10),
            ],
            if (total > 1) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // As setas nunca desligam: um botão que some do foco no
                  // fim da lista joga o teclado para a raiz da tela, e a
                  // pessoa que estava percorrendo perde o lugar. Na ponta,
                  // ela não faz nada e a cor diz isso.
                  IconButton(
                    key: ValueKey('$keyPrefix-focus-prev'),
                    icon: const Icon(Icons.chevron_left),
                    tooltip: l10n.readingFocusPrevious,
                    color: index <= 0
                        ? context.gc.textSecondary.withValues(alpha: .4)
                        : null,
                    onPressed: () {
                      if (index > 0) onFocus(index - 1);
                    },
                  ),
                  Flexible(
                    child: Text(
                      l10n.readingFocusCounter(index + 1, total),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: context.gc.textSecondary, fontSize: 12),
                    ),
                  ),
                  IconButton(
                    key: ValueKey('$keyPrefix-focus-next'),
                    icon: const Icon(Icons.chevron_right),
                    tooltip: l10n.readingFocusNext,
                    color: index >= total - 1
                        ? context.gc.textSecondary.withValues(alpha: .4)
                        : null,
                    onPressed: () {
                      if (index < total - 1) onFocus(index + 1);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            AnimatedSwitcher(
              duration: reduced ? Duration.zero : GrimoireMotion.state,
              switchInCurve: GrimoireMotion.enter,
              switchOutCurve: GrimoireMotion.exit,
              // Só o texto que ENTRA dá altura à pilha: sem isto o painel
              // cresceria com o texto antigo ainda dentro e depois daria um
              // solavanco ao encolher.
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.topLeft,
                clipBehavior: Clip.hardEdge,
                children: [
                  // O texto que sai fica fora da árvore semântica: durante a
                  // troca havia dois liveRegion ao mesmo tempo, e o leitor de
                  // tela lia a posição antiga junto com a nova.
                  for (final old in previous)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: ExcludeSemantics(child: old),
                    ),
                  if (current != null) current,
                ],
              ),
              child: KeyedSubtree(key: ValueKey(index), child: child),
            ),
          ],
        ),
      ),
    );
  }
}
