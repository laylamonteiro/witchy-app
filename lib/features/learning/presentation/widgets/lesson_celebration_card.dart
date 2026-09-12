import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../journeys/domain/action_outcome.dart';
import '../../data/models/trail_model.dart';
import '../providers/learning_provider.dart';
import 'bound_book_cover.dart';
import 'wax_seal_stamp.dart';

/// The single moment after a lesson is sealed. A page gets its wax seal; the
/// last page of a trail closes the book instead, and everything else that
/// happened with this action (level, milestones, closed day) is folded into
/// the same composition. XP is the reward the provider computed: 25 per
/// page plus the trail bonus once, never added again here.
class LessonCelebrationCard extends StatelessWidget {
  const LessonCelebrationCard({
    super.key,
    required this.trail,
    required this.reward,
    required this.onDone,
    this.outcome,
    this.onShare,
  });

  final LearningTrail trail;
  final LessonReward reward;
  final ActionOutcome? outcome;
  final VoidCallback onDone;
  final VoidCallback? onShare;

  bool get _shareable => reward.trailBound || reward.leveledUpTo != null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.gc;
    final accent = reward.trailBound ? colors.starYellow : colors.lilac;
    final milestones = outcome?.newMilestones ?? const [];
    final dayCompleted = outcome?.dayCompleted ?? false;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent, width: 2),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.35), blurRadius: 30)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (reward.trailBound)
            BoundBookCover(
              key: const ValueKey('lesson-bound-book'),
              trailId: trail.id, emblem: trail.emoji, width: 84, closing: true,
            )
          else
            const WaxSealStamp(key: ValueKey('lesson-wax-seal'), emblem: '📜'),
          const SizedBox(height: 12),
          Text(
            reward.trailBound ? l10n.learnTrailBound : l10n.learnPageDone,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: colors.lilac),
          ),
          const SizedBox(height: 8),
          if (reward.xpGained > 0)
            Text(
              '+${reward.xpGained} XP',
              key: const ValueKey('lesson-xp'),
              style: TextStyle(
                color: colors.starYellow, fontSize: 18, fontWeight: FontWeight.bold,
              ),
            ),
          if (reward.trailBound) ...[
            const SizedBox(height: 8),
            Text(
              l10n.learnChapterBound(trail.title),
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, height: 1.4),
            ),
          ],
          if (reward.leveledUpTo != null) ...[
            const SizedBox(height: 12),
            _Pill(
              key: const ValueKey('lesson-level'),
              text: '${reward.leveledUpTo!.emoji} ${l10n.learnNewTitle}: '
                  '${reward.leveledUpTo!.title}',
              color: colors.lilac,
            ),
          ],
          if (milestones.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(l10n.feedbackMilestones(milestones.length),
                key: const ValueKey('lesson-milestones'),
                style: TextStyle(color: colors.textSecondary, fontSize: 12)),
            for (final step in milestones.take(3))
              Text('✦ ${step.localizedTitle}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textPrimary)),
          ],
          if (dayCompleted) ...[
            const SizedBox(height: 12),
            _Pill(
              key: const ValueKey('lesson-day'),
              text: l10n.feedbackDayComplete,
              color: colors.starYellow,
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            key: const ValueKey('lesson-so-be-it'),
            onPressed: onDone,
            child: Text(l10n.learnSoBeIt),
          ),
          if (_shareable && onShare != null) ...[
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: onShare,
              icon: Icon(Icons.share_outlined, size: 18, color: colors.lilac),
              label: Text(l10n.shareImageShare,
                  style: TextStyle(color: colors.lilac, fontSize: 13)),
            ),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({super.key, required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: color.withValues(alpha: 0.15),
    ),
    child: Text(text, textAlign: TextAlign.center,
        style: TextStyle(color: color, fontWeight: FontWeight.bold)),
  );
}
