import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/motion/tool_scene_frame.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../divination/presentation/widgets/card_selection_surface.dart';
import '../../domain/daily_tarot_session.dart';

class DailyTarotSelectionPage extends StatefulWidget {
  const DailyTarotSelectionPage({
    super.key,
    required this.session,
    required this.onCommit,
  });

  final DailyTarotSession session;
  final Future<DailyTarotCommit> Function(String cardId) onCommit;

  @override
  State<DailyTarotSelectionPage> createState() => _DailyTarotSelectionPageState();
}

class _DailyTarotSelectionPageState extends State<DailyTarotSelectionPage> {
  bool _saving = false;
  bool _error = false;
  bool _quotaError = false;
  String? _pendingId;

  @override
  void initState() {
    super.initState();
    _pendingId = widget.session.selectedId;
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
      final result = await widget.onCommit(_pendingId!);
      if (!mounted) return;
      if (context.read<AuthProvider>().currentUser.id != widget.session.userId) return;
      Navigator.of(context).pop(result);
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
    if (userId != widget.session.userId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
          Navigator.of(context).pop();
        }
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    final l10n = AppLocalizations.of(context);
    final dayParts = widget.session.dayKey.split('-').map(int.parse).toList();
    final day = DateTime(dayParts[0], dayParts[1], dayParts[2]);
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.tarotDailyCard)),
        body: ToolSceneFrame(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.tarotQuestionPrefix(widget.session.question),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(l10n.cardSelectionDay(
                      MaterialLocalizations.of(context).formatMediumDate(day)),
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 20),
                  Text(l10n.cardSelectionTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  CardSelectionSurface(
                    cardIds: widget.session.deck.map((c) => c.id).toList(),
                    enabled: !_saving,
                    lockedCardId: _pendingId,
                    onSelected: _select,
                  ),
                  if (_saving || _error) const SizedBox(height: 16),
                  if (_saving) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: 8),
                    Semantics(liveRegion: true,
                        child: Text(l10n.cardSelectionSaving, textAlign: TextAlign.center)),
                  ] else if (_error)
                    Semantics(liveRegion: true,
                      child: Text(_quotaError ? l10n.tarotFreeLimitReached : l10n.cardSelectionError,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.gc.alert)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
