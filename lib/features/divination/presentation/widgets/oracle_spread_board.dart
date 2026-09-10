import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../data/models/oracle_card_model.dart';
import 'oracle_card_face.dart';

/// Positions of every Oracle table, shared by selection and result: one
/// daily message, three cards, or the five positions of the weekly guide
/// (Mon/Tue, Wed, Thu/Fri, weekend, focus) in a single row.
class OracleSpreadBoard extends StatelessWidget {
  const OracleSpreadBoard({
    super.key,
    required this.spread,
    required this.labels,
    required this.cardBuilder,
    this.compact = false,
    this.nextPosition,
    this.selectedPosition,
    this.onTap,
  });

  final OracleSpreadType spread;
  final List<String> labels;
  final Widget? Function(int index, double width) cardBuilder;
  final bool compact;
  final int? nextPosition;
  final int? selectedPosition;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    assert(labels.length == spread.cardCount, 'One label per table position');
    final count = spread.cardCount;
    // Each position spends 16 px around its card: 8 of padding and the 8 the
    // label column adds, so a narrow phone still fits five in one row.
    final width = math.min((constraints.maxWidth - 16.0 * count) / count,
        compact ? (count > 3 ? 44.0 : 60.0) : (count > 3 ? 64.0 : 100.0));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < count; index++)
          Padding(
            padding: const EdgeInsets.all(4),
            child: Semantics(
              sortKey: OrdinalSortKey(index.toDouble()),
              child: InkWell(
                key: ValueKey('oracle-slot-$index'),
                onTap: onTap == null ? null : () => onTap!(index),
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: width + 8,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    AnimatedSwitcher(
                      duration: GrimoireMotion.reduced(context)
                          ? Duration.zero : GrimoireMotion.state,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                            scale: Tween<double>(begin: .88, end: 1).animate(animation),
                            child: child),
                      ),
                      child: cardBuilder(index, width) ?? Container(
                        key: ValueKey('oracle-empty-$index'),
                        width: width, height: width / OracleCardFace.aspectRatio,
                        decoration: BoxDecoration(
                          color: context.gc.surface,
                          borderRadius: BorderRadius.circular(8),
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
                          fontSize: count > 3 ? 10 : null,
                          color: nextPosition == index || selectedPosition == index
                              ? context.gc.lilac : context.gc.textSecondary,
                          fontWeight: nextPosition == index || selectedPosition == index
                              ? FontWeight.bold : FontWeight.normal,
                        )),
                  ]),
                ),
              ),
            ),
          ),
      ],
    );
  });
}
