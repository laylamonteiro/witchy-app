import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'rune_stone_view.dart';

/// Face-down stones on a cloth. Every slot stays where the session laid it;
/// chosen stones leave a gap instead of reshuffling. A tap, keyboard action
/// or press-and-lift selects the exact stone; nothing reveals its identity,
/// including the accessibility tree.
class RuneSelectionSurface extends StatefulWidget {
  const RuneSelectionSurface({
    super.key,
    required this.stoneIds,
    required this.onSelected,
    this.enabled = true,
    this.lockedStoneId,
    this.deckPositions,
  }) : assert(stoneIds.length > 0),
       assert(deckPositions == null || deckPositions.length == stoneIds.length);

  final List<String> stoneIds;
  final ValueChanged<String> onSelected;
  final bool enabled;
  final String? lockedStoneId;
  /// Original cloth slots (0..23), preserved when chosen stones leave.
  final List<int>? deckPositions;

  static const columns = 6;
  static const rows = 4;
  /// Lift needed for a press-and-drag to count as a deliberate pick.
  static const liftThreshold = 48.0;

  @override
  State<RuneSelectionSurface> createState() => _RuneSelectionSurfaceState();
}

class _RuneSelectionSurfaceState extends State<RuneSelectionSurface>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
      vsync: this, duration: GrimoireMotion.reveal);
  final _focusNode = FocusNode();
  late int _focused = _initialFocus();
  bool _started = false;
  int? _lifted;
  double _lift = 0;
  bool _inside = true;

  bool get _canExplore => widget.enabled && widget.lockedStoneId == null;
  int _slot(int index) => widget.deckPositions?[index] ?? index;

  int _initialFocus() {
    final locked = widget.stoneIds.indexOf(widget.lockedStoneId ?? '');
    return locked >= 0 ? locked : 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (GrimoireMotion.reduced(context)) {
      _entrance.value = 1;
      _started = true;
    } else if (!_started) {
      _started = true;
      _entrance.forward();
    }
  }

  @override
  void didUpdateWidget(RuneSelectionSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    final retained = _focused < oldWidget.stoneIds.length
        ? widget.stoneIds.indexOf(oldWidget.stoneIds[_focused]) : -1;
    final locked = widget.stoneIds.indexOf(widget.lockedStoneId ?? '');
    if (locked >= 0) {
      _focused = locked;
    } else if (retained >= 0) {
      _focused = retained;
    }
    _focused = _focused.clamp(0, widget.stoneIds.length - 1).toInt();
    if (_lifted != null && _lifted! >= widget.stoneIds.length) _cancelLift();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _move(int index) {
    if (!_canExplore) return;
    setState(() => _focused = index.clamp(0, widget.stoneIds.length - 1).toInt());
  }

  /// Nearest available stone in the row above/below the focused slot.
  void _moveRows(int delta) {
    final target = _slot(_focused) + delta * RuneSelectionSurface.columns;
    if (target < 0 || target >= RuneSelectionSurface.columns * RuneSelectionSurface.rows) {
      return;
    }
    var best = -1;
    var bestDistance = 1 << 30;
    for (var i = 0; i < widget.stoneIds.length; i++) {
      final slot = _slot(i);
      if (slot ~/ RuneSelectionSurface.columns != target ~/ RuneSelectionSurface.columns) {
        continue;
      }
      final distance = (slot - target).abs();
      if (distance < bestDistance) {
        best = i;
        bestDistance = distance;
      }
    }
    if (best >= 0) _move(best);
  }

  void _choose(int index) {
    if (!widget.enabled) return;
    widget.onSelected(widget.lockedStoneId ?? widget.stoneIds[index]);
  }

  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowLeft) {
      _move(_focused - 1);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _move(_focused + 1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _moveRows(-1);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _moveRows(1);
    } else if (key == LogicalKeyboardKey.home) {
      _move(0);
    } else if (key == LogicalKeyboardKey.end) {
      _move(widget.stoneIds.length - 1);
    } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      if (event is KeyDownEvent) _choose(_focused);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _cancelLift() {
    setState(() {
      _lifted = null;
      _lift = 0;
      _inside = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reduced = GrimoireMotion.reduced(context);
    final total = widget.stoneIds.length;
    return Focus(
      key: const ValueKey('rune-cloth-focus'),
      focusNode: _focusNode,
      onKeyEvent: _key,
      onFocusChange: (_) => setState(() {}),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.runeSelectionInstruction,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Semantics(
            key: const ValueKey('rune-cloth-semantics'),
            container: true,
            label: l10n.runeSelectionTitle,
            value: l10n.runeSelectionPosition(_focused + 1, total),
            increasedValue: _canExplore && _focused < total - 1
                ? l10n.runeSelectionPosition(_focused + 2, total) : null,
            decreasedValue: _canExplore && _focused > 0
                ? l10n.runeSelectionPosition(_focused, total) : null,
            enabled: widget.enabled,
            onIncrease: _canExplore && _focused < total - 1
                ? () => _move(_focused + 1) : null,
            onDecrease: _canExplore && _focused > 0
                ? () => _move(_focused - 1) : null,
            onTap: widget.enabled ? () => _choose(_focused) : null,
            child: ExcludeSemantics(
              child: LayoutBuilder(builder: (context, constraints) {
                const columns = RuneSelectionSurface.columns;
                const rows = RuneSelectionSurface.rows;
                final width = math.min(constraints.maxWidth, 520.0);
                final gap = width * .025;
                final stone = math.min((width - gap * (columns + 1)) / columns, 64.0);
                final stoneHeight = stone / RuneStoneView.aspectRatio;
                final rowStep = stoneHeight + gap * 1.6;
                const top = 26.0;
                final height = top + rows * rowStep + 12;
                final center = Offset(width / 2, height / 2);
                final order = List<int>.generate(total, (i) => i)
                  ..sort((a, b) {
                    if (a == _lifted) return 1;
                    if (b == _lifted) return -1;
                    if (a == _focused) return 1;
                    if (b == _focused) return -1;
                    return _slot(a).compareTo(_slot(b));
                  });
                return Center(
                  child: Container(
                    key: const ValueKey('rune-cloth'),
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: context.gc.gold.withValues(alpha: .45)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.lerp(context.gc.surface, context.gc.lilac, .12)!,
                          Color.lerp(context.gc.surface, context.gc.background, .3)!,
                        ],
                      ),
                    ),
                    child: AnimatedBuilder(
                      animation: _entrance,
                      builder: (context, _) => Stack(
                        clipBehavior: Clip.none,
                        children: [
                          for (final i in order)
                            _positioned(context, i, stone, stoneHeight, gap,
                                rowStep, top, center, reduced),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                key: const ValueKey('rune-previous'),
                tooltip: l10n.runeSelectionPrevious,
                onPressed: _canExplore && _focused > 0 ? () => _move(_focused - 1) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Flexible(child: Text(
                l10n.runeSelectionPosition(_focused + 1, total),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _focusNode.hasFocus ? context.gc.gold : context.gc.textSecondary,
                  fontWeight: _focusNode.hasFocus ? FontWeight.bold : FontWeight.normal,
                ),
              )),
              IconButton(
                key: const ValueKey('rune-next'),
                tooltip: l10n.runeSelectionNext,
                onPressed: _canExplore && _focused < total - 1
                    ? () => _move(_focused + 1) : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const ValueKey('rune-select'),
            onPressed: widget.enabled ? () => _choose(_focused) : null,
            icon: const Icon(Icons.touch_app_outlined),
            label: Text(widget.lockedStoneId == null
                ? l10n.runeSelectionChoose : l10n.cardSelectionRetry),
          ),
        ],
      ),
    );
  }

  Widget _positioned(BuildContext context, int i, double stone, double stoneHeight,
      double gap, double rowStep, double top, Offset center, bool reduced) {
    const columns = RuneSelectionSurface.columns;
    final slot = _slot(i);
    final jitter = RuneStoneScatter.offset(slot, gap * 1.2);
    final rest = Offset(
      gap + (slot % columns) * (stone + gap) + jitter.dx,
      top + (slot ~/ columns) * rowStep + jitter.dy,
    );
    final from = Offset(center.dx - stone / 2, center.dy - stoneHeight / 2);
    final t = GrimoireMotion.enter.transform(_entrance.value);
    final at = Offset.lerp(from, rest, t)!;
    final focused = i == _focused;
    final lifted = i == _lifted;
    final duration = reduced || lifted || _entrance.isAnimating
        ? Duration.zero : GrimoireMotion.tap;
    return AnimatedPositioned(
      key: ValueKey('rune-slot-position-$slot'),
      duration: duration,
      curve: GrimoireMotion.enter,
      left: at.dx,
      top: at.dy - (focused ? 8 : 0) + (lifted ? _lift : 0),
      child: Opacity(
        opacity: (.3 + .7 * t).clamp(0.0, 1.0).toDouble(),
        child: Transform.rotate(
          angle: RuneStoneScatter.angle(slot) * (1 - (lifted ? .5 : 0)),
          child: GestureDetector(
            key: ValueKey('rune-stone-$slot'),
            behavior: HitTestBehavior.opaque,
            onTap: widget.enabled ? () => _choose(i) : null,
            onLongPressStart: _canExplore ? (_) {
              _focusNode.requestFocus();
              HapticFeedback.selectionClick();
              setState(() { _lifted = i; _focused = i; _lift = -6; _inside = true; });
            } : null,
            onLongPressMoveUpdate: _canExplore ? (details) {
              final box = this.context.findRenderObject() as RenderBox?;
              final point = box?.globalToLocal(details.globalPosition);
              setState(() {
                _lift = (details.offsetFromOrigin.dy - 6).clamp(-120, 24).toDouble();
                _inside = box != null && point != null &&
                    point.dx >= 0 && point.dx <= box.size.width;
              });
            } : null,
            onLongPressEnd: _canExplore ? (_) {
              final confirm = _inside && _lift <= -RuneSelectionSurface.liftThreshold;
              _cancelLift();
              if (confirm) _choose(i);
            } : null,
            onLongPressCancel: _canExplore ? _cancelLift : null,
            child: MouseRegion(
              cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(stone / 2),
                  boxShadow: [BoxShadow(
                    color: context.gc.lilac.withValues(alpha: focused ? .35 : .08),
                    blurRadius: focused ? 14 : 3,
                  )],
                ),
                child: RuneStoneView(size: stone, deckPosition: slot, highlighted: focused),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
