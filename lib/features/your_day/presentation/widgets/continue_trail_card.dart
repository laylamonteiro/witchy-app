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
    final trails = learningTrails;
    if (trails.isEmpty) return const SizedBox.shrink();

    // Trilha em andamento; se não houver, a primeira ainda não começada.
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
    // Tudo encadernado: nada a retomar.
    if (target == null) return const SizedBox.shrink();

    final done = learning.completedInTrail(target);
    final total = target.lessons.length;
    final started = done > 0;

    // A trilha é linear: a próxima é a primeira lição ainda não concluída.
    final nextLesson = target.lessons.firstWhere(
      (lesson) => !learning.isLessonCompleted(lesson.id),
      orElse: () => target!.lessons.last,
    );
    final trail = target;

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
