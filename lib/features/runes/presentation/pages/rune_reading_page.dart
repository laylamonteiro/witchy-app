import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/ai/ai_service.dart';
import '../../../../core/haptics/toque_magico.dart';
import '../../../../core/navigation/grimoire_route.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/motion/tool_scene_frame.dart';
import '../../../../core/widgets/premium_locked_preview.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/data/services/reading_archive_composer.dart';
import '../../../diary/data/services/reading_archive_recorder.dart';
import '../../../your_day/presentation/providers/daily_checkin_provider.dart';
import '../../data/data_sources/runes_data.dart';
import '../../data/models/rune_spread_model.dart';
import '../../data/repositories/rune_reading_repository.dart';
import '../../data/repositories/rune_selection_repository.dart';
import '../../domain/rune_selection_session.dart';
import '../widgets/rune_selection_surface.dart';
import '../widgets/rune_spread_board.dart';
import '../widgets/rune_stone.dart';
import 'rune_detail_page.dart';

class RuneReadingPage extends StatelessWidget {
  const RuneReadingPage({super.key});
  @override
  Widget build(BuildContext context) => _RuneReadingContent(
    key: ValueKey(context.select<AuthProvider, String>((auth) => auth.currentUser.id)),
  );
}

class _RuneReadingContent extends StatefulWidget {
  const _RuneReadingContent({super.key});
  @override
  State<_RuneReadingContent> createState() => _RuneReadingContentState();
}

class _RuneReadingContentState extends State<_RuneReadingContent>
    with SingleTickerProviderStateMixin {
  final _question = TextEditingController();
  final _scroll = ScrollController();
  final _meaningKey = GlobalKey();
  final _repository = RuneReadingRepository();
  final _sessions = RuneSelectionRepository();
  final _archive = ReadingArchiveRecorder();
  late final String _userId;
  late final AnimationController _reveal = AnimationController(vsync: this)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted && _revealing) {
        setState(() => _revealing = false);
      }
    });
  RuneSpreadType _spread = RuneSpreadType.single;
  RuneSelectionSession? _session;
  RuneReading? _reading;
  bool _restoring = true;
  bool _busy = false;
  bool _selecting = false;
  bool _newRequested = false;
  bool _revealing = false;
  bool _readingAI = false;
  int _activePosition = 0;
  String? _pendingId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _userId = context.read<AuthProvider>().currentUser.id;
    _restore();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_revealing && GrimoireMotion.reduced(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _reveal.value = 1;
      });
    }
  }

  @override
  void dispose() {
    _question.dispose();
    _scroll.dispose();
    _reveal.dispose();
    super.dispose();
  }

  Future<void> _restore() async {
    try {
      final session = await _sessions.latest(_userId);
      if (!mounted) return;
      if (session != null) {
        _session = session;
        _spread = session.spread;
        _question.text = session.question;
        if (session.isCommitted) await _present(RuneSelectionUpdate(session));
      }
    } catch (_) {
      if (mounted) _error = AppLocalizations.of(context).cardSelectionLoadError;
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  void _top() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) _scroll.jumpTo(0);
    });
  }

  Future<void> _start() async {
    if (_busy || _restoring) return;
    final spread = _spread;
    final question = _question.text.trim();
    final auth = context.read<AuthProvider>();
    setState(() { _busy = true; _error = null; });
    try {
      await auth.refreshRuneUsage();
      if (!mounted || auth.currentUser.id != _userId) return;
      final session = await _sessions.prepare(
        userId: _userId, spread: spread, question: question, catalog: runesData,
        premium: auth.isPremiumEffective, legacyRuneUsed: auth.currentUser.runeReadingsToday,
        freeLimit: UserModel.freeRuneReadingsLimit, startNew: _newRequested,
      );
      if (!mounted || auth.currentUser.id != _userId) return;
      _newRequested = false;
      _question.clear();
      _question.text = session.question;
      FocusScope.of(context).unfocus();
      if (session.isCommitted) {
        await _present(RuneSelectionUpdate(session));
      } else {
        setState(() { _session = session; _selecting = true; _pendingId = null; });
        _top();
        // The last choice survived, but its result transaction was interrupted.
        if (session.isComplete) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _select(session.selectedIds.last);
          });
        }
      }
    } on RuneQuotaExceeded {
      if (!mounted) return;
      setState(() => _error = AppLocalizations.of(context).oracleDailyLimit);
      await showModalBottomSheet<void>(context: context,
          isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (_) => const PremiumUpgradeSheet());
    } catch (_) {
      if (mounted) setState(() => _error = AppLocalizations.of(context).cardSelectionLoadError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _select(String stoneId) async {
    if (_busy || !_selecting || _session == null) return;
    final session = _session!;
    final auth = context.read<AuthProvider>();
    setState(() { _busy = true; _pendingId ??= stoneId; _error = null; });
    try {
      final update = await _sessions.select(
        userId: _userId, sessionId: session.id, stoneId: _pendingId!,
        expectedCount: session.selectedIds.length, catalog: runesData,
        positionLabels: [for (var i = 0; i < session.spread.runeCount; i++)
          session.spread.getPositionMeaning(i)],
        isCurrentUser: () => mounted && auth.currentUser.id == _userId,
        isPremium: () => auth.isPremiumEffective, freeLimit: UserModel.freeRuneReadingsLimit,
      );
      if (!mounted || auth.currentUser.id != _userId) return;
      if (update.session.isCommitted) {
        // Keep the cloth visible until every result dependency is ready.
        await _present(update);
      } else {
        setState(() { _session = update.session; _pendingId = null; });
      }
    } on RuneQuotaExceeded {
      if (mounted) setState(() => _error = AppLocalizations.of(context).oracleDailyLimit);
    } catch (_) {
      if (mounted) setState(() => _error = AppLocalizations.of(context).tarotSelectionSaveError);
    } finally {
      if (mounted && _error != null) {
        try {
          final saved = await _sessions.read(_userId, session.id);
          if (mounted) setState(() => _session = saved);
        } catch (_) {
          // Preserve the pending ID if storage itself is unavailable.
        }
      }
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _present(RuneSelectionUpdate update) async {
    final session = update.session;
    final reading = await _repository.getReading(session.resultId!, userId: _userId);
    if (!mounted) return;
    if (reading == null) throw StateError('Rune result is no longer available');
    final auth = context.read<AuthProvider>();
    await auth.refreshRuneUsage();
    if (!mounted || auth.currentUser.id != _userId) return;
    if (update.created && !auth.isPremiumEffective) {
      await AdService.instance.showBeforeResult();
      if (!mounted || auth.currentUser.id != _userId) return;
    }
    final animate = update.created && !GrimoireMotion.reduced(context);
    _reveal.duration = Duration(milliseconds: 450 + (reading.positions.length - 1) * 70);
    _reveal.value = animate ? 0 : 1;
    setState(() {
      _session = session; _reading = reading; _spread = session.spread;
      _selecting = false; _revealing = animate; _activePosition = 0; _pendingId = null;
    });
    _top();
    unawaited(_record(reading));
    unawaited(_repository.syncReading(reading.id, _userId));
    if (update.created) {
      ToqueMagico.leve();
      unawaited(context.read<DailyCheckinProvider>().completeRite(DailyRites.runes));
    }
    if (animate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _reading?.id == reading.id && _revealing) _reveal.forward(from: 0);
      });
    }
  }

  Future<void> _record(RuneReading reading) => _archive.record(
    readingId: reading.id, userId: _userId, source: FreeWritingSource.runes,
    createdAt: reading.date,
    page: ReadingArchiveComposer.runes(reading, interpretation: reading.interpretation),
  );

  void _backToMenu({bool newReading = false}) {
    if (_busy || _readingAI) return;
    setState(() {
      _revealing = false; _selecting = false; _reading = null; _error = null;
      _newRequested = newReading; _pendingId = null;
      if (newReading) { _session = null; _question.clear(); }
    });
    _reveal.reset();
    _top();
  }

  Future<void> _askCounselor() async {
    final reading = _reading;
    if (reading == null || _readingAI || !context.read<AuthProvider>().isPremiumEffective) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _readingAI = true);
    try {
      final page = ReadingArchiveComposer.runes(reading);
      final question = reading.question.trim();
      final interpretation = await AIService.instance.interpretRuneSpread(
        summary: '${page.title}\n${page.content}',
        question: question.isEmpty || question == l10n.runesNoQuestion ? null : question,
      );
      if (!mounted || _reading?.id != reading.id) return;
      final updated = await _repository.updateInterpretation(reading.id, _userId, interpretation);
      if (!mounted || _reading?.id != reading.id || updated == null) return;
      setState(() => _reading = updated);
      unawaited(_record(updated));
    } catch (_) {
      if (mounted) setState(() => _error = l10n.tarotSelectionSaveError);
    } finally {
      if (mounted) setState(() => _readingAI = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: !_busy && !_readingAI && !_selecting && _reading == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToMenu();
      },
      child: Scaffold(
        appBar: AppBar(title: ResponsiveAppBarTitle(l10n.runesReadingTitle)),
        body: ToolSceneFrame(child: SingleChildScrollView(
          controller: _scroll, padding: const EdgeInsets.all(16),
          child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 640),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if (_restoring) const LinearProgressIndicator()
              else if (_selecting) ..._selection(context)
              else if (_reading != null) ..._result(context)
              else ..._menu(context),
              if (_error != null) Padding(padding: const EdgeInsets.only(top: 16),
                child: Semantics(liveRegion: true, child: Text(_error!,
                  textAlign: TextAlign.center, style: TextStyle(color: context.gc.alert)))),
              const SizedBox(height: 24),
            ]),
          )),
        )),
      ),
    );
  }

  List<Widget> _menu(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final resumes = !_newRequested && _session != null && !_session!.isCommitted &&
        _session!.spread == _spread && _session!.question.toLowerCase() == _question.text.trim().toLowerCase();
    return [
      MagicalCard(child: Column(children: [
        const RunePouch(open: .7),
        const SizedBox(height: 12),
        Text(l10n.runesReadingIntro, textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text(l10n.runesReversedNote, textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.gc.textSecondary)),
      ])),
      const SizedBox(height: 16),
      Text(l10n.runesChooseLayout, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      for (final spread in RuneSpreadType.values) Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(onTap: _busy ? null : () => setState(() => _spread = spread),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(duration: GrimoireMotion.reduced(context)
              ? Duration.zero : GrimoireMotion.state,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: context.gc.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: _spread == spread ? 2 : 1,
                color: _spread == spread ? context.gc.lilac : context.gc.surfaceBorder)),
            child: Row(children: [
              RuneStone(slot: spread.index, size: 42,
                  symbol: '${spread.runeCount}', highlighted: _spread == spread),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(spread.displayName, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(spread.description, style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: context.gc.textSecondary)),
              ])),
              if (_spread == spread) Icon(Icons.check_circle_outline, color: context.gc.lilac),
            ]),
          ),
        ),
      ),
      const SizedBox(height: 8),
      TextField(controller: _question, enabled: !_busy, maxLines: 2,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(labelText: l10n.runesQuestionOptional,
          hintText: l10n.runesQuestionHint, border: const OutlineInputBorder())),
      const SizedBox(height: 20),
      FilledButton.icon(key: const ValueKey('runes-start'),
        onPressed: _busy ? null : _start,
        icon: _busy ? const SizedBox.square(dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.touch_app_outlined),
        label: Text(_busy ? l10n.runesDrawing : resumes ? l10n.runesContinue : l10n.runesDraw)),
      if (!auth.isPremiumEffective) Padding(padding: const EdgeInsets.only(top: 12),
        child: Text(l10n.oracleRemainingToday(
            '${auth.remainingRuneReadings}/${UserModel.freeRuneReadingsLimit}'),
          textAlign: TextAlign.center, style: TextStyle(color: context.gc.textSecondary))),
    ];
  }

  List<Widget> _selection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = _session!;
    final count = session.selectedIds.length;
    return [
      Text(session.spread.displayName, textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      if (session.question.isNotEmpty) Text(session.question, textAlign: TextAlign.center),
      Text(l10n.cardSelectionDay(MaterialLocalizations.of(context)
          .formatMediumDate(session.startedAt)), textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 12),
      RuneSpreadBoard(spread: session.spread, compact: true, nextPosition: count,
        stoneSlots: session.selectedIds.map(session.positionOf).toList()),
      const SizedBox(height: 12),
      Semantics(liveRegion: true, child: Text(session.isComplete ? l10n.tarotSelectionReady :
        l10n.runesSelectionStep(count + 1, session.spread.runeCount,
            session.spread.getPositionMeaning(count)), textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium)),
      const SizedBox(height: 8),
      if (!session.isComplete) ...[
        Text(l10n.runesSelectionInstruction, textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        RuneSelectionSurface(key: ValueKey(session.id),
          stoneIds: session.deck.map((r) => r.id).toList(), selectedIds: session.selectedIds,
          enabled: !_busy && _pendingId == null, onSelected: _select),
      ],
      if (_busy) ...[
        const SizedBox(height: 12), const LinearProgressIndicator(),
        Text(l10n.cardSelectionSaving, textAlign: TextAlign.center),
      ] else if (_pendingId != null || session.isComplete)
        FilledButton.icon(key: const ValueKey('runes-retry'),
          onPressed: () => _select(_pendingId ?? session.selectedIds.last),
          icon: const Icon(Icons.refresh), label: Text(l10n.cardSelectionRetry)),
    ];
  }

  List<Widget> _result(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reading = _reading!;
    return [
      Text(reading.spreadType.displayName, textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      if (reading.question.isNotEmpty) Text(reading.question, textAlign: TextAlign.center),
      Text(l10n.cardSelectionDay(MaterialLocalizations.of(context).formatMediumDate(reading.date)),
          textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 16),
      RuneCloth(child: AnimatedBuilder(animation: _reveal, builder: (context, _) => RuneSpreadBoard(
        spread: reading.spreadType, positions: reading.positions, progress: _reveal.value,
        stoneSlots: _session!.selectedIds.map(_session!.positionOf).toList(),
        activePosition: _revealing ? null : _activePosition,
        onTap: (index) {
          if (_revealing) { _reveal.value = 1; return; }
          setState(() => _activePosition = index);
          final target = _meaningKey.currentContext;
          if (target != null) Scrollable.ensureVisible(target,
            duration: GrimoireMotion.reduced(context) ? Duration.zero : GrimoireMotion.state,
            alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd);
        },
      ))),
      if (_revealing) TextButton(key: const ValueKey('runes-reveal-now'),
          onPressed: () => _reveal.value = 1, child: Text(l10n.runesRevealNow))
      else ...[
        const SizedBox(height: 12),
        Text(l10n.runesSelectMeaning, textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall),
        _meaning(context, reading.positions[_activePosition]),
        _counselor(context),
      ],
      const SizedBox(height: 16),
      OutlinedButton.icon(onPressed: _busy || _readingAI ? null : () => _backToMenu(newReading: true),
        icon: const Icon(Icons.refresh), label: Text(l10n.oracleNewReading)),
    ];
  }

  Widget _meaning(BuildContext context, RunePosition position) {
    final l10n = AppLocalizations.of(context);
    return MagicalCard(key: _meaningKey, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(position.positionMeaning, style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: context.gc.gold)),
        const SizedBox(height: 6),
        Text(position.rune.name, key: const ValueKey('runes-active-name'),
            style: Theme.of(context).textTheme.headlineSmall),
        if (position.isReversed) Text(l10n.runesReversed,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.gc.textSecondary)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [for (final word in position.rune.keywords)
          Text('· $word', style: TextStyle(color: context.gc.textSecondary))]),
        const SizedBox(height: 12),
        Text(position.isReversed && position.rune.reversedMeaning != null
            ? position.rune.reversedMeaning! : position.rune.divination),
        const SizedBox(height: 8),
        TextButton.icon(onPressed: () => Navigator.of(context).push(GrimoireRoute<void>(
          builder: (_) => RuneDetailPage(rune: position.rune))),
          icon: const Icon(Icons.menu_book_outlined), label: Text(l10n.runesOpenEncyclopedia)),
      ],
    ));
  }

  Widget _counselor(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MagicalCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (!context.watch<AuthProvider>().isPremiumEffective)
        PremiumLockedPreview(titles: [l10n.counselorLockedTitle1, l10n.counselorLockedTitle2,
          l10n.counselorLockedTitle3, l10n.counselorLockedTitle4])
      else if (_reading!.interpretation == null)
        FilledButton.icon(onPressed: _readingAI ? null : _askCounselor,
          icon: _readingAI ? const SizedBox.square(dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome),
          label: Text(_readingAI ? l10n.tarotConsultingCards : l10n.tarotAdvisorInterpretation))
      else ...[
        Text(l10n.tarotAdvisorInterpretation, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12), Text(_reading!.interpretation!),
      ],
    ]));
  }
}
