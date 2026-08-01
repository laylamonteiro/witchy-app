import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/magical_progress.dart';
import '../../../learning/data/data_sources/trails_data.dart';
import '../../../learning/data/models/trail_model.dart';
import '../../../learning/presentation/pages/lesson_page.dart';
import '../../../learning/presentation/providers/learning_provider.dart';

/// Trilha a retomar (a em andamento; senão a primeira ainda não começada) e
/// a próxima lição dela. Null quando tudo já foi encadernado.
///
/// Compartilhado pelo card "continue sua trilha" e pelo rito do dia — os dois
/// precisam apontar exatamente para a mesma lição.
({LearningTrail trail, TrailLesson lesson, bool started})? resumeTrail(
  LearningProvider learning,
) {
  final trails = learningTrails;
  if (trails.isEmpty) return null;

  LearningTrail? target;
  for (final trail in trails) {
    final done = learning.completedInTrail(trail);
    if (done > 0 && done < trail.lessons.length) {
      target = trail;
      break;
    }
  }
  target ??= trails.cast<LearningTrail?>().firstWhere(
        (trail) => learning.completedInTrail(trail!) == 0,
        orElse: () => null,
      );
  if (target == null) return null;

  final trail = target;
  final lesson = trail.lessons.firstWhere(
    (l) => !learning.isLessonCompleted(l.id),
    orElse: () => trail.lessons.last,
  );
  return (
    trail: trail,
    lesson: lesson,
    started: learning.completedInTrail(trail) > 0,
  );
}

/// "Continue de onde parou" do Grimório Vivo.
///
/// Retomar algo já começado é o convite mais forte de todos: mostra a trilha
/// em andamento, o quanto falta e leva direto para a próxima lição.
class ContinueTrailCard extends StatelessWidget {
  const ContinueTrailCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final learning = context.watch<LearningProvider>();
    final resume = resumeTrail(learning);
    if (resume == null) return const SizedBox.shrink();

    final trail = resume.trail;
    final nextLesson = resume.lesson;
    final started = resume.started;
    final done = learning.completedInTrail(trail);
    final total = trail.lessons.length;

    return MagicalCard.accent(
      accent: context.gc.mint,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LessonPage(trail: trail, lesson: nextLesson),
        ),
      ),
      child: Row(
        children: [
          MagicalProgressRing(
            value: total == 0 ? 0 : done / total,
            size: 52,
            strokeWidth: 4,
            color: context.gc.mint,
            center: Text(trail.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  started
                      ? l10n.yourDayTrailContinueTitle
                      : l10n.yourDayTrailStartTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: context.gc.textSecondary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  trail.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.yourDayTrailNext(nextLesson.title),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.learnPagesProgress('$done', '$total'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.mint,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Icon(Icons.play_circle_fill, color: context.gc.mint, size: 30),
              const SizedBox(height: 4),
              Text(
                started
                    ? l10n.yourDayTrailCtaContinue
                    : l10n.yourDayTrailCtaStart,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.gc.mint,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
