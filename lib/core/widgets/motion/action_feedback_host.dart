import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../features/journeys/domain/action_outcome.dart';
import '../../../features/journeys/domain/progress_coordinator.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../theme/grimoire_colors.dart';
import '../../theme/grimoire_motion.dart';

/// Presents one [ActionOutcome] at a time above the whole app: a compact
/// card with the confirmation, the XP the stored formula yielded, the
/// milestones reached, a new title and a closed day, all in one
/// composition. A tap or a short timer dismisses it; the next one follows.
/// It lives above the router, so a confirmation that lands while its route
/// is closing still reaches the person, without any discarded context.
class ActionFeedbackHost extends StatelessWidget {
  const ActionFeedbackHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final coordinator = context.watch<ProgressCoordinator?>();
    return Stack(
      children: [
        child,
        if (coordinator != null)
          Positioned(
            left: 16,
            right: 16,
            top: MediaQuery.paddingOf(context).top + 12,
            child: _FeedbackCard(
              key: ValueKey(coordinator.current?.actionId),
              outcome: coordinator.current,
              onDismiss: coordinator.dismiss,
            ),
          ),
      ],
    );
  }
}

class _FeedbackCard extends StatefulWidget {
  const _FeedbackCard({super.key, required this.outcome, required this.onDismiss});

  final ActionOutcome? outcome;
  final VoidCallback onDismiss;

  /// How long a composition stays before leaving on its own.
  static const Duration linger = Duration(milliseconds: 3600);

  @override
  State<_FeedbackCard> createState() => _FeedbackCardState();
}

class _FeedbackCardState extends State<_FeedbackCard> {
  Timer? _timer;
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    if (widget.outcome != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _shown = true);
      });
      _timer = Timer(_FeedbackCard.linger, () {
        _timer = null;
        if (mounted) widget.onDismiss();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outcome = widget.outcome;
    if (outcome == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final reduced = GrimoireMotion.reduced(context);
    final colors = context.gc;
    final celebration = outcome.isCelebration;
    final accent = celebration ? colors.gold : colors.lilac;
    final lines = <Widget>[];
    if (outcome.xpGained > 0) {
      lines.add(Text(l10n.feedbackXp(outcome.xpGained),
          key: const ValueKey('feedback-xp'),
          style: TextStyle(color: accent, fontWeight: FontWeight.bold)));
    }
    if (outcome.newMilestones.isNotEmpty) {
      lines.add(Text(l10n.feedbackMilestones(outcome.newMilestones.length),
          key: const ValueKey('feedback-milestones'),
          style: TextStyle(color: colors.textSecondary, fontSize: 12)));
      for (final step in outcome.newMilestones.take(3)) {
        lines.add(Text('✦ ${step.localizedTitle}',
            style: TextStyle(color: colors.textPrimary)));
      }
      if (outcome.newMilestones.length > 3) {
        lines.add(Text('+${outcome.newMilestones.length - 3}',
            style: TextStyle(color: colors.textSecondary, fontSize: 12)));
      }
    }
    if (outcome.newLevel != null) {
      lines.add(Text(
          '${outcome.newLevel!.emoji} ${l10n.feedbackLevelUp(outcome.newLevel!.title)}',
          key: const ValueKey('feedback-level'),
          style: TextStyle(color: colors.gold, fontWeight: FontWeight.bold)));
    }
    if (outcome.dayCompleted) {
      lines.add(Text(l10n.feedbackDayComplete,
          key: const ValueKey('feedback-day'),
          style: TextStyle(color: colors.gold, fontWeight: FontWeight.bold)));
    }
    return AnimatedSlide(
      offset: _shown || reduced ? Offset.zero : const Offset(0, -.4),
      duration: reduced ? Duration.zero : GrimoireMotion.state,
      curve: GrimoireMotion.enter,
      child: AnimatedOpacity(
        opacity: _shown || reduced ? 1 : 0,
        duration: reduced ? Duration.zero : GrimoireMotion.state,
        child: Semantics(
          liveRegion: true,
          button: true,
          hint: l10n.feedbackDismiss,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: const ValueKey('feedback-card'),
              onTap: widget.onDismiss,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accent.withValues(alpha: .8), width: 1.5),
                  boxShadow: [BoxShadow(
                    color: accent.withValues(alpha: celebration ? .35 : .2),
                    blurRadius: 18,
                  )],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(celebration ? Icons.auto_awesome : Icons.check_circle_outline,
                        color: accent, size: 22),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(originLabel(l10n, outcome.origin),
                            key: const ValueKey('feedback-origin'),
                            style: TextStyle(
                                color: colors.textPrimary, fontWeight: FontWeight.w600)),
                        for (final line in lines) ...[const SizedBox(height: 4), line],
                      ],
                    )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String originLabel(AppLocalizations l10n, ActionOrigin origin) => switch (origin) {
    ActionOrigin.dream => l10n.feedbackOriginDream,
    ActionOrigin.gratitude => l10n.feedbackOriginGratitude,
    ActionOrigin.desire => l10n.feedbackOriginDesire,
    ActionOrigin.affirmation => l10n.feedbackOriginAffirmation,
    ActionOrigin.spell => l10n.feedbackOriginSpell,
    ActionOrigin.sigil => l10n.feedbackOriginSigil,
    ActionOrigin.encyclopedia => l10n.feedbackOriginEncyclopedia,
    ActionOrigin.reading => l10n.feedbackOriginReading,
    ActionOrigin.ritual => l10n.feedbackOriginRitual,
    ActionOrigin.lesson => l10n.feedbackOriginLesson,
    ActionOrigin.other => l10n.feedbackOriginOther,
  };
}
