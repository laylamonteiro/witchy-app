import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/models/arcane_entry_model.dart';

/// Detalhe genérico de uma entrada arcana da Enciclopédia.
class ArcaneDetailPage extends StatelessWidget {
  final ArcaneEntry entry;
  final String categoryTitle;

  const ArcaneDetailPage({
    super.key,
    required this.entry,
    required this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle('${entry.emoji} ${entry.name}'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.summary,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.gc.lilac,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Origem: ${entry.origin}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          _section(
            context,
            title: '📜 Contexto Histórico',
            child: Text(
              entry.history,
              style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
          if (entry.perspectives.isNotEmpty)
            _section(
              context,
              title: '🗺️ Olhares das Tradições',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cada tradição enxerga essa figura de um jeito — nenhuma '
                    'leitura é a única verdade.',
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
                context, '✨ Características', entry.characteristics),
          if (entry.symbolism.isNotEmpty)
            _bulletSection(context, '🔯 Simbolismos', entry.symbolism),
          if (entry.correspondences.isNotEmpty)
            _chipSection(
                context, '🕯️ Correspondências', entry.correspondences),
          if (entry.studyPractices.isNotEmpty)
            _bulletSection(
                context, '📖 Estudo & Contemplação', entry.studyPractices),
          if (entry.magicalUses.isNotEmpty)
            _bulletSection(context, '🪄 Usos Mágicos', entry.magicalUses),
          if (entry.cautions.isNotEmpty)
            _section(
              context,
              title: '⚠️ Cuidados & Observações',
              child: Text(
                entry.cautions,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.gc.textSecondary,
                      height: 1.5,
                    ),
              ),
            ),
          if (entry.related.isNotEmpty)
            _chipSection(context, '🔗 Veja também', entry.related),
          const SizedBox(height: 24),
        ],
      ),
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.gc.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
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
