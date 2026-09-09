import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../tarot/presentation/widgets/tarot_card_view.dart';

/// Only a small window is painted, but every deck position is reachable.
/// Horizontal exploration never selects on release. A tap, keyboard action
/// or deliberate upward withdrawal selects the exact visible ID.
class CardSelectionSurface extends StatefulWidget {
  const CardSelectionSurface({
    super.key,
    required this.cardIds,
    required this.onSelected,
    this.enabled = true,
    this.lockedCardId,
  }) : assert(cardIds.length > 0);

  final List<String> cardIds;
  final ValueChanged<String> onSelected;
  final bool enabled;
  final String? lockedCardId;

  @override
  State<CardSelectionSurface> createState() => _CardSelectionSurfaceState();
}

class _CardSelectionSurfaceState extends State<CardSelectionSurface>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
      vsync: this, duration: GrimoireMotion.reveal);
  late double _position = (widget.cardIds.length - 1) / 2;
  final _focusNode = FocusNode();
  bool _started = false;
  bool _exploring = false;
  int? _dragged;
  double _lift = 0;
  bool _inside = true;

  int get _focused => _position.round().clamp(0, widget.cardIds.length - 1).toInt();
  bool get _canExplore => widget.enabled && widget.lockedCardId == null;

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
  void initState() {
    super.initState();
    final locked = widget.cardIds.indexOf(widget.lockedCardId ?? '');
    if (locked >= 0) _position = locked.toDouble();
  }

  @override
  void didUpdateWidget(CardSelectionSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    final locked = widget.cardIds.indexOf(widget.lockedCardId ?? '');
    if (locked >= 0) _position = locked.toDouble();
    _position = _position.clamp(0, widget.cardIds.length - 1).toDouble();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _move(num position) {
    if (!_canExplore) return;
    setState(() {
      _position = position.clamp(0, widget.cardIds.length - 1).toDouble();
    });
  }

  void _choose(int index) {
    if (!widget.enabled) return;
    final id = widget.lockedCardId ?? widget.cardIds[index];
    widget.onSelected(id);
  }

  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _move(_focused - 1);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _move(_focused + 1);
    } else if (event.logicalKey == LogicalKeyboardKey.home) {
      _move(0);
    } else if (event.logicalKey == LogicalKeyboardKey.end) {
      _move(widget.cardIds.length - 1.0);
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      if (event is KeyDownEvent) _choose(_focused);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _cancelWithdrawal() {
    setState(() {
      _dragged = null;
      _lift = 0;
      _inside = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reduced = GrimoireMotion.reduced(context);
    final duration = reduced || _exploring || _dragged != null
        ? Duration.zero : GrimoireMotion.tap;
    return Focus(
      key: const ValueKey('card-fan-focus'),
      focusNode: _focusNode,
      onKeyEvent: _key,
      onFocusChange: (_) => setState(() {}),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.cardSelectionInstruction,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Semantics(
            key: const ValueKey('card-fan-semantics'),
            container: true,
            label: l10n.cardSelectionTitle,
            value: l10n.cardSelectionPosition(_focused + 1, widget.cardIds.length),
            increasedValue: _canExplore && _focused < widget.cardIds.length - 1
                ? l10n.cardSelectionPosition(_focused + 2, widget.cardIds.length)
                : null,
            decreasedValue: _canExplore && _focused > 0
                ? l10n.cardSelectionPosition(_focused, widget.cardIds.length)
                : null,
            enabled: widget.enabled,
            onIncrease: _canExplore && _focused < widget.cardIds.length - 1
                ? () => _move(_focused + 1) : null,
            onDecrease: _canExplore && _focused > 0
                ? () => _move(_focused - 1) : null,
            onTap: widget.enabled ? () => _choose(_focused) : null,
            child: ExcludeSemantics(
              child: LayoutBuilder(builder: (context, constraints) {
                final width = math.min(constraints.maxWidth, 600.0);
                final cardWidth = math.min(width * .29, 120.0);
                final cardHeight = cardWidth / TarotCardView.aspectRatio;
                final step = (width - cardWidth) / 8;
                final indices = [
                  for (var i = _focused - 5; i <= _focused + 5; i++)
                    if (i >= 0 && i < widget.cardIds.length) i,
                ]..sort((a, b) {
                    if (a == b) return 0;
                    if (a == _dragged) return 1;
                    if (b == _dragged) return -1;
                    return (b - _position).abs().compareTo((a - _position).abs());
                  });
                return Center(
                  child: GestureDetector(
                    key: const ValueKey('card-fan-gesture'),
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart: _canExplore ? (_) {
                      _focusNode.requestFocus();
                      setState(() => _exploring = true);
                    } : null,
                    onHorizontalDragUpdate: _canExplore
                        ? (details) => _move(_position - details.delta.dx / step)
                        : null,
                    onHorizontalDragEnd: _canExplore ? (_) {
                      setState(() {
                        _exploring = false;
                        _position = _focused.toDouble();
                      });
                    } : null,
                    onHorizontalDragCancel: () => setState(() => _exploring = false),
                    child: SizedBox(
                      width: width,
                      height: cardHeight + 145,
                      child: AnimatedBuilder(
                        animation: _entrance,
                        builder: (context, _) => Stack(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            for (final i in indices)
                              AnimatedPositioned(
                                key: ValueKey('fan-position-$i'),
                                duration: duration,
                                curve: GrimoireMotion.enter,
                                left: (width - cardWidth) / 2 +
                                    (i - _position) * step * _entrance.value,
                                top: 70 + (i - _position) * (i - _position) * 1.8 -
                                    (i == _focused ? 18 : 0) +
                                    (i == _dragged ? _lift : 0),
                                child: AnimatedRotation(
                                  turns: (i - _position) * .012 * _entrance.value,
                                  duration: duration,
                                  child: GestureDetector(
                                    key: ValueKey('fan-card-$i'),
                                    onTap: widget.enabled ? () => _choose(i) : null,
                                    onVerticalDragStart: _canExplore ? (_) {
                                      _focusNode.requestFocus();
                                      setState(() { _dragged = i; _inside = true; });
                                    } : null,
                                    onVerticalDragUpdate: _canExplore ? (details) {
                                      final box = this.context.findRenderObject() as RenderBox?;
                                      final point = box?.globalToLocal(details.globalPosition);
                                      setState(() {
                                        _lift = (_lift + details.delta.dy).clamp(-100, 35).toDouble();
                                        _inside = box != null && point != null &&
                                            point.dx >= 0 && point.dx <= box.size.width;
                                      });
                                    } : null,
                                    onVerticalDragEnd: _canExplore ? (_) {
                                      final confirm = _inside && _lift <= -65;
                                      _cancelWithdrawal();
                                      if (confirm) _choose(i);
                                    } : null,
                                    onVerticalDragCancel: _cancelWithdrawal,
                                    child: MouseRegion(
                                      cursor: widget.enabled
                                          ? SystemMouseCursors.click : SystemMouseCursors.basic,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [BoxShadow(
                                            color: context.gc.lilac.withValues(
                                                alpha: i == _focused ? .32 : .10),
                                            blurRadius: i == _focused ? 15 : 4,
                                          )],
                                        ),
                                        child: TarotCardBack(width: cardWidth),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
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
                key: const ValueKey('fan-previous'),
                tooltip: l10n.cardSelectionPrevious,
                onPressed: _canExplore && _focused > 0 ? () => _move(_focused - 1) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Flexible(child: Text(
                l10n.cardSelectionPosition(_focused + 1, widget.cardIds.length),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _focusNode.hasFocus ? context.gc.gold : context.gc.textSecondary,
                  fontWeight: _focusNode.hasFocus ? FontWeight.bold : FontWeight.normal,
                ),
              )),
              IconButton(
                key: const ValueKey('fan-next'),
                tooltip: l10n.cardSelectionNext,
                onPressed: _canExplore && _focused < widget.cardIds.length - 1
                    ? () => _move(_focused + 1) : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const ValueKey('fan-select'),
            onPressed: widget.enabled ? () => _choose(_focused) : null,
            icon: const Icon(Icons.touch_app_outlined),
            label: Text(widget.lockedCardId == null
                ? l10n.cardSelectionChoose : l10n.cardSelectionRetry),
          ),
        ],
      ),
    );
  }
}
