import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../data/data_sources/blood_lore_content.dart';
import '../menstrual_type.dart';
import '../widgets/blood_lore_tag_chip.dart';
import 'blood_lore_entry_page.dart';

/// Os verbetes de uma das quatro áreas dos Saberes do Sangue.
///
/// Cada cartão traz a etiqueta editorial ao lado do título: quem só passa os
/// olhos pela lista já sabe o que é história documentada, o que é tradição
/// específica e o que é prática de agora.
class BloodLoreCategoryPage extends StatelessWidget {
  const BloodLoreCategoryPage({super.key, required this.category});

  final BloodLoreCategory category;

  @override
  Widget build(BuildContext context) {
    final content = bloodLoreContent;
    final entries = content.of(category);
    return Scaffold(
      backgroundColor: context.gc.background,
      appBar: AppBar(
        title: ResponsiveAppBarTitle(content.categoryTitles[category]!),
        backgroundColor: context.gc.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: StaggeredEntrance(
          children: [
            MagicalCard(
              key: ValueKey('blood-lore-list-${category.name}'),
              child: Text(content.categorySubtitles[category]!,
                  style: MenstrualType.body(context)),
            ),
            for (final entry in entries) _EntryCard(entry: entry),
            // Onde há prática, a nota de segurança vem antes de qualquer
            // gesto — uma só, curta, sempre a mesma.
            if (category == BloodLoreCategory.practices)
              MagicalCard(
                key: const ValueKey('blood-lore-practices-safety'),
                child: Text(content.safetyNote,
                    style: MenstrualType.caption(context)),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});

  final BloodLoreEntry entry;

  @override
  Widget build(BuildContext context) {
    return MagicalCard(
      key: ValueKey('blood-lore-entry-${entry.id}'),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => BloodLoreEntryPage(entry: entry)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Text(entry.emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: MenstrualType.cardTitle(context)),
                const SizedBox(height: 6),
                BloodLoreTagChip(tag: entry.tag),
                const SizedBox(height: 8),
                Text(entry.summary, style: MenstrualType.quiet(context)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, size: 20, color: context.gc.lilac),
        ],
      ),
    );
  }
}
