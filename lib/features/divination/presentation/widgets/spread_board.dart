import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../tarot/presentation/widgets/tarot_card_view.dart';

/// Selection and result share the same positions. Cross: tendency above,
/// advice/situation/challenge across the middle, root below.
class SpreadBoard extends StatelessWidget {
  const SpreadBoard({
    super.key,
    required this.labels,
    required this.cardBuilder,
    this.cross = false,
    this.compact = false,
    this.nextPosition,
    this.selectedPosition,
    this.onTap,
  }) : assert(labels.length == (cross ? 5 : 3));

  final List<String> labels;
  final Widget? Function(int index, double width) cardBuilder;
  final bool cross;
  final bool compact;
  final int? nextPosition;

  /// Posição em foco no painel de leitura. Só marca o rótulo: quem desenha o
  /// destaque na carta é a própria carta, que sabe se está virada.
  final int? selectedPosition;

  /// Tocar numa posição muda o foco do painel. Nulo nas mesas de seleção,
  /// onde quem escolhe é o leque e a mesa é só espelho.
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final width = math.min((constraints.maxWidth - 24) / 3,
        compact ? (cross ? 40.0 : 60.0) : 110.0);
    final rows = cross
        ? <List<int?>>[[null, 4, null], [3, 0, 1], [null, 2, null]]
        : <List<int?>>[[0, 1, 2]];
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [for (final row in rows) TableRow(children: [
        for (final index in row)
          if (index == null) const SizedBox.shrink()
          else Padding(
            padding: const EdgeInsets.all(4),
            child: Semantics(
              sortKey: OrdinalSortKey(index.toDouble()),
              child: InkWell(
                key: ValueKey('tarot-slot-$index'),
                onTap: onTap == null ? null : () => onTap!(index),
                borderRadius: BorderRadius.circular(10),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                AnimatedSwitcher(
                  duration: GrimoireMotion.reduced(context)
                      ? Duration.zero : GrimoireMotion.state,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: Tween<double>(begin: .88, end: 1)
                        .animate(animation), child: child),
                  ),
                  child: cardBuilder(index, width) ?? Container(
                    key: ValueKey('spread-empty-$index'),
                    width: width, height: width / TarotCardView.aspectRatio,
                    decoration: BoxDecoration(
                      color: context.gc.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: nextPosition == index ? context.gc.lilac : context.gc.surfaceBorder,
                        width: nextPosition == index ? 2 : 1,
                      ),
                    ),
                    child: Center(child: Text('${index + 1}',
                        style: TextStyle(color: context.gc.textSecondary))),
                  ),
                ),
                const SizedBox(height: 4),
                Text(labels[index], textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: nextPosition == index || selectedPosition == index
                          ? context.gc.lilac : context.gc.textSecondary,
                      fontWeight: nextPosition == index || selectedPosition == index
                          ? FontWeight.bold : FontWeight.normal,
                    )),
                ]),
              ),
            ),
          ),
      ])],
    );
  });
}
