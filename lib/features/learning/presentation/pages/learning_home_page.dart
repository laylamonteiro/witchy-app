import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
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
                        AppLocalizations.of(context)!.learnHomeTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: context.gc.lilac),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.learnHomeSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.gc.textSecondary,
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: 14),
                      // Nível e XP — a gamificação das Jornadas Mágicas
                      // aplicada ao aprendizado.
                      Row(
                        children: [
                          Text(learning.level.emoji,
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  learning.level.title,
                                  style: TextStyle(
                                    color: context.gc.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: learning.levelProgress,
                                  backgroundColor: context.gc.surfaceBorder,
                                  valueColor: AlwaysStoppedAnimation(
                                      context.gc.starYellow),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${learning.xp} XP',
                            style: TextStyle(
                              color: context.gc.starYellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        learning.nextLevel == null
                            ? AppLocalizations.of(context)!.learnMaxTitle
                            : AppLocalizations.of(context)!.learnNextTitle('${learning.totalPagesWritten}', learning.nextLevel!.title, '${learning.nextLevel!.minXp}'),
                        style: TextStyle(
                          color: context.gc.textSecondary,
                          fontSize: 11,
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
      child: complete
          ? _buildBoundCover(context, trail)
          : MagicalCard(
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
                  complete ? AppLocalizations.of(context)!.learnBoundShort : AppLocalizations.of(context)!.learnPagesProgress('$done', '$total'),
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

  /// Capa de livro encadernado: a trilha completa vira um volume do grimório.
  Widget _buildBoundCover(BuildContext context, trail) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(context.gc.surface, context.gc.starYellow, 0.10)!,
            Color.lerp(context.gc.surface, context.gc.lilac, 0.16)!,
          ],
        ),
        border: Border.all(color: context.gc.starYellow, width: 1.6),
        boxShadow: [
          BoxShadow(
            color: context.gc.starYellow.withValues(alpha: 0.18),
            blurRadius: 14,
          ),
        ],
      ),
      child: Row(
        children: [
          // Lombada do livro
          Container(
            width: 10,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: context.gc.starYellow.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(width: 14),
          Text(trail.emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trail.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.gc.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context)!.learnBoundVolume('${trail.lessons.length}'),
                  style: TextStyle(
                    color: context.gc.starYellow,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.auto_stories, color: context.gc.starYellow),
        ],
      ),
    );
  }
}
