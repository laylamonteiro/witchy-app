import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/models/rune_spread_model.dart';
import 'rune_stone.dart';

/// Position labels stay still; only the stones settle and reveal.
class RuneSpreadBoard extends StatelessWidget {
  const RuneSpreadBoard({super.key, required this.spread, required this.stoneSlots,
    this.positions = const [], this.progress = 0, this.activePosition,
    this.nextPosition, this.onTap, this.compact = false});
  final RuneSpreadType spread;
  final List<int> stoneSlots;
  final List<RunePosition> positions;
  final double progress;
  final int? activePosition, nextPosition;
  final ValueChanged<int>? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = switch (spread) {
      RuneSpreadType.single => <List<int?>>[[0]],
      RuneSpreadType.threeCast => <List<int?>>[[0, 1, 2]],
      RuneSpreadType.nordicCross => <List<int?>>[[null, 4, null], [2, 0, 3], [null, 1, null]],
      RuneSpreadType.nineWorlds => <List<int?>>[[0, 1, 2], [3, 4, 5], [6, 7, 8]],
    };
    return LayoutBuilder(builder: (context, constraints) {
      final size = math.min((constraints.maxWidth - 24) / rows.first.length,
          compact ? 38.0 : 76.0);
      return Table(defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [for (final row in rows) TableRow(children: [
          for (final index in row)
            if (index == null) const SizedBox.shrink()
            else Builder(builder: (context) {
              final hasStone = index < stoneSlots.length;
              final t = positions.isEmpty ? 0.0 :
                  ((progress * (450 + (spread.runeCount - 1) * 70) - index * 70) / 450)
                      .clamp(0.0, 1.0).toDouble();
              final face = t >= .5;
              final position = positions.isEmpty ? null : positions[index];
              final label = spread.getPositionMeaning(index);
              return Padding(padding: const EdgeInsets.all(4), child: Semantics(
                sortKey: OrdinalSortKey(index.toDouble()),
                button: onTap != null && hasStone,
                selected: activePosition == index,
                label: face && position != null
                    ? '$label: ${position.rune.name}${position.isReversed ? ', ${l10n.runesReversed}' : ''}'
                    : label,
                onTap: onTap == null || !hasStone ? null : () => onTap!(index),
                excludeSemantics: true,
                child: InkWell(
                  key: ValueKey('rune-board-position-$index'),
                  borderRadius: BorderRadius.circular(12),
                  onTap: onTap == null || !hasStone ? null : () => onTap!(index),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    AnimatedSwitcher(
                      duration: GrimoireMotion.reduced(context) ? Duration.zero : GrimoireMotion.state,
                      transitionBuilder: (child, animation) => ScaleTransition(
                        scale: Tween<double>(begin: .86, end: 1).animate(animation),
                        child: FadeTransition(opacity: animation, child: child)),
                      child: hasStone ? Transform.translate(
                        key: ValueKey('rune-board-filled-$index'),
                        offset: Offset(0, t > 0 && t < 1 ? -8 * math.sin(math.pi * t) : 0),
                        child: Transform.scale(scaleX: (1 - 2 * t).abs().clamp(.04, 1.0).toDouble(),
                          child: RuneStone(slot: stoneSlots[index], size: size,
                            symbol: face ? position?.rune.symbol : null,
                            reversed: face && (position?.isReversed ?? false),
                            highlighted: activePosition == index),
                        ),
                      ) : SizedBox.square(dimension: size, child: DecoratedBox(
                        decoration: BoxDecoration(shape: BoxShape.circle,
                          border: Border.all(color: nextPosition == index
                              ? context.gc.lilac : context.gc.surfaceBorder)),
                        child: Center(child: Text('${index + 1}',
                            style: TextStyle(color: context.gc.textSecondary))),
                      )),
                    ),
                    const SizedBox(height: 4),
                    Text(label, textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: activePosition == index || nextPosition == index
                            ? context.gc.lilac : context.gc.textSecondary)),
                  ]),
                ),
              ));
            }),
        ])],
      );
    });
  }
}
