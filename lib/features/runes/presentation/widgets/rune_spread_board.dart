import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../data/models/rune_spread_model.dart';
import 'rune_stone_view.dart';

/// Positions of every rune table. Selection and result share the same slots:
/// one stone; a row of three; the Nordic cross (result above, past/situation/
/// future across, challenge below); nine worlds in a compact 3x3.
class RuneSpreadBoard extends StatelessWidget {
  const RuneSpreadBoard({
    super.key,
    required this.spread,
    required this.labels,
    required this.stoneBuilder,
    this.compact = false,
    this.nextPosition,
    this.selectedPosition,
    this.onTap,
  }) : assert(labels.length == spread.runeCount);

  final RuneSpreadType spread;
  final List<String> labels;
  final Widget? Function(int index, double size) stoneBuilder;
  final bool compact;
  final int? nextPosition;
  final int? selectedPosition;
  final ValueChanged<int>? onTap;

  static List<List<int?>> rowsFor(RuneSpreadType spread) {
    switch (spread) {
      case RuneSpreadType.single:
        return [[0]];
      case RuneSpreadType.threeCast:
        return [[0, 1, 2]];
      case RuneSpreadType.nordicCross:
        return [[null, 4, null], [2, 0, 3], [null, 1, null]];
      case RuneSpreadType.nineWorlds:
        return [[0, 1, 2], [3, 4, 5], [6, 7, 8]];
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final rows = rowsFor(spread);
    final columns = rows.first.length;
    final size = math.min((constraints.maxWidth - 8.0 * columns) / columns,
        compact ? 52.0 : 84.0);
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
                key: ValueKey('rune-slot-$index'),
                onTap: onTap == null ? null : () => onTap!(index),
                borderRadius: BorderRadius.circular(12),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  AnimatedSwitcher(
                    duration: GrimoireMotion.reduced(context)
                        ? Duration.zero : GrimoireMotion.state,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                          scale: Tween<double>(begin: .85, end: 1).animate(animation),
                          child: child),
                    ),
                    child: stoneBuilder(index, size) ?? Container(
                      key: ValueKey('rune-empty-$index'),
                      width: size, height: size / RuneStoneView.aspectRatio,
                      decoration: BoxDecoration(
                        color: context.gc.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: nextPosition == index
                              ? context.gc.lilac : context.gc.surfaceBorder,
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
