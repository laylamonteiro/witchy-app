import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/data_sources/trails_data.dart';
import '../providers/learning_provider.dart';
import 'trail_page.dart';

/// Grimório Vivo: trilhas de aprendizado em que cada lição termina com uma
/// página real escrita no Meu Grimório.
class LearningHomePage extends StatefulWidget {
  const LearningHomePage({super.key});

  @override
  State<LearningHomePage> createState() => _LearningHomePageState();
}

class _LearningHomePageState extends State<LearningHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveAppBarTitle('Grimório Vivo'),
      ),
      body: Consumer<LearningProvider>(
        builder: (context, learning, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MagicalCard(
                  child: Column(
                    children: [
                      const Text('📖', style: TextStyle(fontSize: 44)),
                      const SizedBox(height: 10),
                      Text(
                        'Aprenda escrevendo o seu grimório',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: context.gc.lilac),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cada lição termina com uma página criada por você '
                        'no Meu Grimório. Ao completar uma trilha, o '
                        'capítulo é seu — escrito de próprio punho.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.gc.textSecondary,
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${learning.totalPagesWritten} de '
                        '${LearningProvider.totalLessons} páginas escritas',
                        style: TextStyle(
                          color: context.gc.starYellow,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                for (final trail in learningTrails)
                  _buildTrailCard(context, learning, trail),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrailCard(
      BuildContext context, LearningProvider learning, trail) {
    final done = learning.completedInTrail(trail);
    final total = trail.lessons.length;
    final complete = learning.isTrailComplete(trail);

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TrailPage(trail: trail)),
      ),
      borderRadius: BorderRadius.circular(16),
      child: MagicalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(trail.emoji, style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              trail.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: context.gc.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          if (complete) ...[
                            const SizedBox(width: 6),
                            Text('📕',
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ],
                      ),
                      Text(
                        trail.subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.gc.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: context.gc.textSecondary),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : done / total,
                    backgroundColor: context.gc.surfaceBorder,
                    valueColor: AlwaysStoppedAnimation(
                      complete ? context.gc.success : context.gc.lilac,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  complete ? 'Encadernada!' : '$done/$total páginas',
                  style: TextStyle(
                    color: complete
                        ? context.gc.success
                        : context.gc.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
