import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'rune_stone.dart';

/// Twenty-four stable places on a cloth. Exploring never commits a choice.
class RuneSelectionSurface extends StatefulWidget {
  const RuneSelectionSurface({super.key, required this.stoneIds,
    required this.selectedIds, required this.onSelected, this.enabled = true});
  final List<String> stoneIds;
  final List<String> selectedIds;
  final ValueChanged<String> onSelected;
  final bool enabled;
  @override
  State<RuneSelectionSurface> createState() => _RuneSelectionSurfaceState();
}

class _RuneSelectionSurfaceState extends State<RuneSelectionSurface>
    with SingleTickerProviderStateMixin {
  late final AnimationController _opening = AnimationController(
      vsync: this, duration: GrimoireMotion.celebration);
  final _focus = FocusNode();
  int _slot = 0;
  bool _started = false;

  List<int> get _available => [for (var i = 0; i < widget.stoneIds.length; i++)
    if (!widget.selectedIds.contains(widget.stoneIds[i])) i];

  @override
  void initState() {
    super.initState();
    if (_available.isNotEmpty) _slot = _available.first;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (GrimoireMotion.reduced(context) || widget.selectedIds.isNotEmpty) {
      _opening.value = 1;
    } else if (!_started) {
      _opening.forward();
    }
    _started = true;
  }

  @override
  void didUpdateWidget(RuneSelectionSurface old) {
    super.didUpdateWidget(old);
    final available = _available;
    if (!available.contains(_slot) && available.isNotEmpty) {
      _slot = available.firstWhere((i) => i > _slot, orElse: () => available.first);
    }
  }

  @override
  void dispose() {
    _opening.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _move(int delta) {
    final available = _available;
    if (!widget.enabled || available.isEmpty) return;
    final index = available.indexOf(_slot);
    setState(() => _slot = available[(index + delta).clamp(0, available.length - 1).toInt()]);
  }

  void _choose(int slot) {
    if (!widget.enabled || !_available.contains(slot)) return;
    widget.onSelected(widget.stoneIds[slot]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final available = _available;
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 480 ? 6 : 4;
      final cell = (constraints.maxWidth - 24) / columns;
      final stoneSize = math.min(62.0, cell - 10);
      const rowHeight = 68.0;
      Offset place(int slot) => Offset(
          (slot % columns + .5) * cell - stoneSize / 2 + (slot % 3 - 1) * 3,
          64 + (slot ~/ columns) * rowHeight + (slot % 4 - 1.5) * 2);
      final nodes = [for (final slot in available) (
        slot: slot, position: place(slot),
        child: Semantics(
          button: true, enabled: widget.enabled, selected: _slot == slot,
          label: l10n.runesStonePosition(slot + 1, widget.stoneIds.length),
          onTap: widget.enabled ? () => _choose(slot) : null,
          excludeSemantics: true,
          child: MouseRegion(
            onEnter: widget.enabled ? (_) => setState(() => _slot = slot) : null,
            child: GestureDetector(
              key: ValueKey('rune-stone-$slot'),
              behavior: HitTestBehavior.opaque,
              onTapDown: widget.enabled ? (_) => setState(() => _slot = slot) : null,
              onTap: widget.enabled ? () => _choose(slot) : null,
              child: AnimatedContainer(
                duration: GrimoireMotion.reduced(context) ? Duration.zero : GrimoireMotion.tap,
                transform: Matrix4.translationValues(0, _slot == slot ? -5 : 0, 0),
                child: RuneStone(slot: slot, size: stoneSize, highlighted: _slot == slot),
              ),
            ),
          ),
        ),
      )];
      return Focus(
        key: const ValueKey('rune-selection-focus'), focusNode: _focus, autofocus: true,
        onKeyEvent: (_, event) {
          if (event is! KeyDownEvent || !widget.enabled || available.isEmpty) {
            return KeyEventResult.ignored;
          }
          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
            _choose(_slot);
          } else if (key == LogicalKeyboardKey.arrowRight) {
            _move(1);
          } else if (key == LogicalKeyboardKey.arrowLeft) {
            _move(-1);
          } else if (key == LogicalKeyboardKey.arrowDown) {
            _move(columns);
          } else if (key == LogicalKeyboardKey.arrowUp) {
            _move(-columns);
          } else if (key == LogicalKeyboardKey.home || key == LogicalKeyboardKey.end) {
            setState(() => _slot = key == LogicalKeyboardKey.home ? available.first : available.last);
          } else {
            return KeyEventResult.ignored;
          }
          return KeyEventResult.handled;
        },
        child: Column(children: [
          RuneCloth(child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: widget.enabled ? (event) {
              if (available.isEmpty) return;
              final closest = available.reduce((a, b) =>
                  (place(a) + Offset(stoneSize / 2, stoneSize / 2) - event.localPosition).distanceSquared <
                  (place(b) + Offset(stoneSize / 2, stoneSize / 2) - event.localPosition).distanceSquared ? a : b);
              if (closest != _slot) setState(() => _slot = closest);
            } : null,
            child: SizedBox(
              width: double.infinity,
              height: 64 + ((widget.stoneIds.length + columns - 1) ~/ columns) * rowHeight,
              child: AnimatedBuilder(animation: _opening, builder: (context, _) {
                final t = GrimoireMotion.enter.transform(
                    ((_opening.value - .15) / .85).clamp(0.0, 1.0).toDouble());
                final source = Offset((constraints.maxWidth - 24 - stoneSize) / 2, 5);
                return Stack(clipBehavior: Clip.none, children: [
                  Align(alignment: Alignment.topCenter,
                      child: RunePouch(open: (_opening.value * 4).clamp(0.0, 1.0).toDouble())),
                  for (final node in nodes) Positioned(
                    left: source.dx + (node.position.dx - source.dx) * t,
                    top: source.dy + (node.position.dy - source.dy) * t,
                    child: Opacity(opacity: t, child: Transform.rotate(
                      angle: (node.slot.isEven ? 1 : -1) * .08 * (1 - t),
                      child: node.child,
                    )),
                  ),
                ]);
              }),
            ),
          )),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(tooltip: l10n.runesPreviousStone,
                onPressed: widget.enabled && available.indexOf(_slot) > 0 ? () => _move(-1) : null,
                icon: const Icon(Icons.chevron_left)),
            Flexible(child: Semantics(liveRegion: true, child: Text(
              l10n.runesStonePosition(_slot + 1, widget.stoneIds.length),
              textAlign: TextAlign.center, style: TextStyle(color: context.gc.gold),
            ))),
            IconButton(tooltip: l10n.runesNextStone,
                onPressed: widget.enabled && available.indexOf(_slot) < available.length - 1
                    ? () => _move(1) : null,
                icon: const Icon(Icons.chevron_right)),
          ]),
          FilledButton.icon(
            key: const ValueKey('rune-select'),
            onPressed: widget.enabled && available.isNotEmpty ? () => _choose(_slot) : null,
            icon: const Icon(Icons.touch_app_outlined), label: Text(l10n.runesChooseStone),
          ),
        ]),
      );
    });
  }
}
