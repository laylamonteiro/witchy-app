import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../data/data_sources/blood_lore_content.dart';
import '../menstrual_type.dart';
import 'blood_lore_category_page.dart';

/// "Saberes do Sangue": a capa da pequena área de conhecimento sobre
/// menstruação e bruxaria.
///
/// Ela é parte do Ciclo Menstrual, não um segundo aplicativo: usa os mesmos
/// cards, a mesma tipografia e as mesmas cores do resto do Grimório, e o
/// conteúdo inteiro mora na camada de conteúdo (`blood_lore_content.dart`),
/// como o altar e os elementos.
///
/// A capa é curta de propósito. O texto longo vive nas telas internas —
/// quatro áreas, cada uma com os seus verbetes.
class BloodLorePage extends StatelessWidget {
  const BloodLorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final content = bloodLoreContent;
    return Scaffold(
      backgroundColor: context.gc.background,
      appBar: AppBar(
        title: ResponsiveAppBarTitle(content.pageTitle),
        backgroundColor: context.gc.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: StaggeredEntrance(
          children: [
            MagicalCard(
              key: const ValueKey('blood-lore-intro'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(content.pageTitle,
                      style: MenstrualType.cardTitle(context)),
                  const SizedBox(height: 12),
                  Text(content.intro, style: MenstrualType.body(context)),
                  const SizedBox(height: 12),
                  Text(content.introNote,
                      style: MenstrualType.caption(context)),
                ],
              ),
            ),
            for (final category in BloodLoreCategory.values)
              _CategoryCard(category: category, content: content),
            // A nota de segurança fecha a capa: acessível desde a porta,
            // sem virar um alerta que atravesse a leitura.
            MagicalCard(
              key: const ValueKey('blood-lore-safety'),
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

/// Uma das quatro áreas: o emblema, o nome, uma linha e quantos textos ela
/// tem. O mesmo formato do cartão do Ciclo na aba Ciclos.
class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.content});

  final BloodLoreCategory category;
  final BloodLoreContent content;

  @override
  Widget build(BuildContext context) {
    final colors = context.gc;
    final total = content.of(category).length;
    return MagicalCard(
      key: ValueKey('blood-lore-category-${category.name}'),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BloodLoreCategoryPage(category: category),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Text(category.emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(content.categoryTitles[category]!,
                    style: MenstrualType.cardTitle(context)),
                const SizedBox(height: 4),
                Text(content.categorySubtitles[category]!,
                    style: MenstrualType.quiet(context)),
                const SizedBox(height: 6),
                Text(
                  BloodLoreContent.fill(
                      content.entriesCountTemplate, {'count': '$total'}),
                  style: MenstrualType.caption(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, size: 20, color: colors.lilac),
        ],
      ),
    );
  }
}
