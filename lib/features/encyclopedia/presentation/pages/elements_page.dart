import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/living_emblem.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/expansion_magical_card.dart';
import '../../data/data_sources/elements_content.dart';

/// Página informativa sobre os 4 elementos.
///
/// Todo o conteúdo textual vem de `elements_content.dart` (ContentLocale),
/// localizado em pt/en/es.
class ElementsPage extends StatelessWidget {
  const ElementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final content = elementsContent;

    return Scaffold(
      backgroundColor: context.gc.background,
      appBar: AppBar(
        title: ResponsiveAppBarTitle(content.pageTitle),
        backgroundColor: context.gc.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: StaggeredEntrance(
          children: [
            const LivingEmblem(emblem: SectionEmblem.elements),
            const SizedBox(height: 12),
            // Introdução
            MagicalCard(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('∞', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          content.introTitle,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    content.introBody,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    content.introHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Terra, Água, Fogo, Ar
            for (final element in content.elements)
              ExpansionMagicalCard(
                title: element.name,
                emoji: element.emoji,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSubsection(
                        context, content.essenceLabel, element.essence),
                    _buildSubsection(
                        context, content.qualitiesLabel, element.qualities),
                    _buildSubsection(
                        context, content.directionLabel, element.direction),
                    _buildSubsection(
                        context, content.seasonLabel, element.season),
                    _buildSubsection(
                        context, content.lifePhaseLabel, element.lifePhase),
                    _buildSubsection(
                        context, content.timeOfDayLabel, element.timeOfDay),
                    _buildSubsection(
                        context, content.colorsLabel, element.colors),
                    _buildSubsection(
                        context, content.toolsLabel, element.tools),
                    _buildSubsection(context, content.correspondencesLabel,
                        element.correspondences),
                    _buildSubsection(
                        context, element.whenToWorkTitle, element.whenToWork),
                  ],
                ),
              ),

            // Equilíbrio dos Elementos
            ExpansionMagicalCard(
              title: content.balanceTitle,
              emoji: '⚖️',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    content.balanceIntro,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  for (final item in content.balanceItems)
                    _buildBalanceItem(context, '${item.emoji} ${item.name}',
                        item.description),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.gc.lilac.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: context.gc.lilac.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content.imbalanceTitle,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          content.imbalanceBody,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.gc.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Como Trabalhar com os Elementos
            ExpansionMagicalCard(
              title: content.practicesTitle,
              emoji: '✨',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  for (final practice in content.practices)
                    _buildPracticeItem(
                        context, practice.title, practice.description),
                ],
              ),
            ),

            // Considerações Finais
            ExpansionMagicalCard(
              title: content.honoringTitle,
              emoji: '🌟',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    content.honoringBody,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      '🌍🌊🔥💨',
                      style: TextStyle(fontSize: 32),
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

  Widget _buildSubsection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.gc.lilac,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.gc.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(
      BuildContext context, String element, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            element,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: context.gc.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeItem(
      BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: context.gc.starYellow, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
