import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import '../../data/data_sources/arcane_categories.dart';
import '../../data/models/arcane_entry_model.dart';
import '../../../auth/data/models/feature_access.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';

/// Detalhe genérico de uma entrada arcana da Enciclopédia.
class ArcaneDetailPage extends StatelessWidget {
  final ArcaneEntry entry;
  final ArcaneCategory category;

  const ArcaneDetailPage({
    super.key,
    required this.entry,
    required this.category,
  });

  /// Caminho da imagem do verbete (helper compartilhado com a lista).
  String get imageAsset => category.imageAssetFor(entry);

  String get displayTitle {
    if (category == ArcaneCategory.archetypes) {
      return entry.name.replaceFirst(
          RegExp(r'^(A|O|The|El|La)\s+', caseSensitive: false), '');
    }
    return entry.name;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle('${entry.emoji} $displayTitle'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Cabeçalho no mesmo padrão da página de Deusas: imagem, nome em
          // Cinzel lilás, pílula de origem e resumo centralizado.
          MagicalCard(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imageAsset,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, __) => Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: context.gc.lilac.withOpacity(0.10),
                        border: Border.all(
                          color: context.gc.lilac.withOpacity(0.35),
                        ),
                      ),
                      child: Text(entry.emoji,
                          style: const TextStyle(fontSize: 72)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  displayTitle,
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: context.gc.lilac,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Pílula de origem (mesmo estilo do badge das Deusas).
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.gc.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${entry.emoji} ${entry.origin}',
                    style: TextStyle(
                      color: context.gc.softWhite,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  entry.summary,
                  style: TextStyle(
                    color: context.gc.softWhite,
                    fontSize: 15,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          _section(
            context,
            title: l10n.encySectionHistory,
            child: Text(
              entry.history,
              style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
          if (entry.perspectives.isNotEmpty)
            _section(
              context,
              title: l10n.encyArcaneTraditions,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.encyArcaneTraditionsNote,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  const SizedBox(height: 10),
                  for (final p in entry.perspectives) ...[
                    Text(
                      p.tradition,
                      style: TextStyle(
                        color: context.gc.lilac,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.view,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(height: 1.45),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          if (entry.characteristics.isNotEmpty)
            _bulletSection(
                context, l10n.encyArcaneCharacteristics, entry.characteristics),
          if (entry.symbolism.isNotEmpty)
            _bulletSection(context, l10n.encyArcaneSymbolism, entry.symbolism),
          if (entry.correspondences.isNotEmpty)
            _premiumSection(
              context,
              title: l10n.encySectionCorrespondences,
              subtitle: l10n.encyArcaneCorrespondencesSub,
              content: _chipContent(context, entry.correspondences),
            ),
          if (entry.studyPractices.isNotEmpty)
            _premiumSection(
              context,
              title: l10n.encyArcaneStudy,
              subtitle: l10n.encyArcaneStudySub,
              content: _bulletContent(context, entry.studyPractices),
            ),
          if (entry.magicalUses.isNotEmpty)
            _premiumSection(
              context,
              title: l10n.encySectionMagicUses,
              subtitle: l10n.encyArcaneUsesSub,
              content: _bulletContent(context, entry.magicalUses),
            ),
          if (entry.cautions.isNotEmpty)
            _section(
              context,
              title: l10n.encyArcaneCautions,
              child: Text(
                entry.cautions,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.gc.textSecondary,
                      height: 1.5,
                    ),
              ),
            ),
          if (entry.related.isNotEmpty)
            _chipSection(context, l10n.encyArcaneSeeAlso, entry.related),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Seção com conteúdo de bruxaria atrás do gate Premium (mesmo padrão
  /// das demais abas da Enciclopédia: título visível, conteúdo com blur).
  Widget _premiumSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget content,
  }) {
    return MagicalCard(
      child: PremiumContentSection(
        feature: AppFeature.encyclopediaArcaneDetails,
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        subtitle: subtitle,
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: content,
        ),
      ),
    );
  }

  Widget _bulletContent(BuildContext context, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: context.gc.lilac)),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _chipContent(BuildContext context, List<String> items) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (item) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: context.gc.lilac.withOpacity(0.12),
                border: Border.all(
                  color: context.gc.lilac.withOpacity(0.35),
                ),
              ),
              child: Text(
                item,
                style: TextStyle(color: context.gc.lilac, fontSize: 13),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _section(BuildContext context,
      {required String title, required Widget child}) {
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _bulletSection(
      BuildContext context, String title, List<String> items) {
    return _section(
      context,
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: context.gc.lilac)),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _chipSection(BuildContext context, String title, List<String> items) {
    return _section(
      context,
      title: title,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items
            .map(
              (item) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: context.gc.lilac.withOpacity(0.12),
                  border: Border.all(
                    color: context.gc.lilac.withOpacity(0.35),
                  ),
                ),
                child: Text(
                  item,
                  style: TextStyle(color: context.gc.lilac, fontSize: 13),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
