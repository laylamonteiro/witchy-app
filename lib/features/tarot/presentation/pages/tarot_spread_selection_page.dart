import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/motion/tool_scene_frame.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../divination/presentation/widgets/card_selection_surface.dart';
import '../../../divination/presentation/widgets/spread_board.dart';
import '../../domain/daily_tarot_session.dart';
import '../../domain/tarot_spread_session.dart';
import '../widgets/tarot_card_view.dart';

class TarotSpreadSelectionPage extends StatefulWidget {
  const TarotSpreadSelectionPage({
    super.key,
    required this.session,
    required this.title,
    required this.positionLabels,
    required this.onSelect,
  });

  final TarotSpreadSession session;
  final String title;
  final List<String> positionLabels;
  final Future<TarotSpreadUpdate> Function(String cardId, int expectedCount) onSelect;

  @override
  State<TarotSpreadSelectionPage> createState() => _TarotSpreadSelectionPageState();
}

class _TarotSpreadSelectionPageState extends State<TarotSpreadSelectionPage> {
  late TarotSpreadSession _session = widget.session;
  bool _saving = false;
  bool _error = false;
  bool _quotaError = false;
  String? _pendingId;

  @override
  void initState() {
    super.initState();
    // Recover a process stopped after the last choice but before its commit.
    if (_session.isComplete && !_session.isCommitted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _select(_session.selectedIds.last);
      });
    }
  }

  Future<void> _select(String cardId) async {
    if (_saving) return;
    setState(() {
      _pendingId ??= cardId;
      _saving = true;
      _error = false;
      _quotaError = false;
    });
    try {
      final update = await widget.onSelect(_pendingId!, _session.selectedIds.length);
      if (!mounted || context.read<AuthProvider>().currentUser.id != _session.userId) return;
      if (update.session.isCommitted) {
        Navigator.of(context).pop(update);
      } else {
        setState(() { _session = update.session; _pendingId = null; });
      }
    } on TarotQuotaExceeded {
      if (mounted) setState(() { _error = true; _quotaError = true; });
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.select<AuthProvider, String>((auth) => auth.currentUser.id);
    if (userId != _session.userId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) Navigator.of(context).pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    final l10n = AppLocalizations.of(context);
    final selected = _session.selectedIds;
    final available = [for (var i = 0; i < _session.deck.length; i++)
      if (!selected.contains(_session.deck[i].id)) i];
    final parts = _session.dayKey.split('-').map(int.parse).toList();
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: ToolSceneFrame(child: SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l10n.tarotQuestionPrefix(_session.question)),
            const SizedBox(height: 4),
            Text(l10n.cardSelectionDay(MaterialLocalizations.of(context)
                .formatMediumDate(DateTime(parts[0], parts[1], parts[2]))),
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            SpreadBoard(
              labels: widget.positionLabels, cross: _session.spread == 'cross', compact: true,
              nextPosition: selected.length,
              cardBuilder: (i, width) => i < selected.length
                  ? TarotCardBack(key: ValueKey('spread-selected-$i'), width: width,
                      deckPosition: _session.positionOf(selected[i])) : null,
            ),
            const SizedBox(height: 12),
            Semantics(liveRegion: true, child: Text(
              _session.isComplete
                  ? l10n.tarotSelectionReady
                  : l10n.tarotSelectionStep(selected.length + 1, _session.cardCount,
                      widget.positionLabels[selected.length]),
              textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium,
            )),
            if (!_session.isComplete) ...[
              const SizedBox(height: 8),
              CardSelectionSurface(
                cardIds: [for (final i in available) _session.deck[i].id],
                deckPositions: available,
                enabled: !_saving, lockedCardId: _pendingId,
                onSelected: _select,
              ),
            ] else if (!_saving)
              FilledButton.icon(
                key: const ValueKey('spread-retry'),
                onPressed: () => _select(selected.last),
                icon: const Icon(Icons.refresh), label: Text(l10n.cardSelectionRetry),
              ),
            if (_saving) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
              Text(l10n.cardSelectionSaving, textAlign: TextAlign.center),
            ],
            if (_error) ...[
              const SizedBox(height: 12),
              Semantics(liveRegion: true, child: Text(
                _quotaError ? l10n.tarotFreeLimitReached : l10n.tarotSelectionSaveError,
                textAlign: TextAlign.center, style: TextStyle(color: context.gc.alert),
              )),
            ],
          ]),
        ))),
      ),
    );
  }
}
