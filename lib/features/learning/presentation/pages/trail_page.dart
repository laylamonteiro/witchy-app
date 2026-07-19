import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../data/models/trail_model.dart';
import '../providers/learning_provider.dart';
import 'lesson_page.dart';

/// Uma trilha do Grimório Vivo: lista de lições com destrave sequencial.
/// A primeira lição é gratuita; as demais são Premium.
class TrailPage extends StatelessWidget {
  final LearningTrail trail;

  const TrailPage({super.key, required this.trail});

  @override
  Widget build(BuildContext context) {
    final learning = context.watch<LearningProvider>();
    final isPremium = context.watch<AuthProvider>().isPremiumEffective;

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle('${trail.emoji} ${trail.title}'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          MagicalCard(
            child: Text(
              trail.description,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.5),
            ),
          ),
          for (var i = 0; i < trail.lessons.length; i++)
            _buildLessonTile(context, learning, isPremium, i),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLessonTile(
    BuildContext context,
    LearningProvider learning,
    bool isPremium,
    int index,
  ) {
    final lesson = trail.lessons[index];
    final completed = learning.isLessonCompleted(lesson.id);
    final unlocked = learning.isLessonUnlocked(trail, index);
    final needsPremium = index > 0 && !isPremium;
    final accessible = unlocked && !needsPremium;

    IconData icon;
    Color color;
    if (completed) {
      icon = Icons.check_circle;
      color = context.gc.success;
    } else if (!unlocked) {
      icon = Icons.lock_outline;
      color = context.gc.textSecondary;
    } else if (needsPremium) {
      icon = Icons.star_outline;
      color = context.gc.starYellow;
    } else {
      icon = Icons.edit_outlined;
      color = context.gc.lilac;
    }

    return InkWell(
      onTap: () {
        if (!unlocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  const Text('Complete a lição anterior para destravar esta.'),
              backgroundColor: context.gc.alert,
            ),
          );
          return;
        }
        if (needsPremium) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const PremiumUpgradeSheet(),
          );
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LessonPage(trail: trail, lesson: lesson),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: MagicalCard(
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lição ${index + 1} — ${lesson.title}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: accessible || completed
                              ? context.gc.textPrimary
                              : context.gc.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    completed
                        ? 'Página escrita: "${lesson.pageTitle}"'
                        : needsPremium && unlocked
                            ? 'Lição Premium'
                            : 'Cria a página: "${lesson.pageTitle}"',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
