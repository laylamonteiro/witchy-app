import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/presentation/providers/free_writing_provider.dart';
import 'record_detail_page.dart';

/// Filtros do acervo: por padrão só o que foi GERADO (páginas de lição e
/// leituras); "Todas" inclui também as reflexões livres, como consulta.
enum ArchiveFilter { records, grimorioVivo, readings, all }

/// "Meus Registros": a janela do acervo unificado dentro do Meu Grimório.
/// As entradas nascem das lições do Grimório Vivo e das leituras
/// (quiromancia, runas, pêndulo, oráculo) — por isso não há botão de criar.
class RecordsArchiveListPage extends StatefulWidget {
  const RecordsArchiveListPage({super.key});

  @override
  State<RecordsArchiveListPage> createState() =>
      _RecordsArchiveListPageState();
}

class _RecordsArchiveListPageState extends State<RecordsArchiveListPage> {
  ArchiveFilter _filter = ArchiveFilter.records;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FreeWritingProvider>().loadFreeWritings();
    });
  }

  bool _matches(FreeWritingModel entry) => switch (_filter) {
        ArchiveFilter.records => entry.source != FreeWritingSource.free,
        ArchiveFilter.grimorioVivo =>
          entry.source == FreeWritingSource.grimorioVivo,
        ArchiveFilter.readings =>
          FreeWritingSource.readings.contains(entry.source),
        ArchiveFilter.all => true,
      };

  String _filterLabel(AppLocalizations l10n, ArchiveFilter filter) =>
      switch (filter) {
        ArchiveFilter.records => l10n.recordsFilterRecords,
        ArchiveFilter.grimorioVivo => l10n.recordsFilterGrimorioVivo,
        ArchiveFilter.readings => l10n.recordsFilterReadings,
        ArchiveFilter.all => l10n.recordsFilterAll,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(l10n.grimoireMyRecords),
      ),
      body: Column(
        children: [
          // Chips de filtro — dentro de UMA superfície, em vez de duas
          // funcionalidades parecidas.
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final filter in ArchiveFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_filterLabel(l10n, filter)),
                      selected: _filter == filter,
                      selectedColor:
                          context.gc.lilac.withValues(alpha: 0.35),
                      onSelected: (_) => setState(() => _filter = filter),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<FreeWritingProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return Center(
                    child:
                        CircularProgressIndicator(color: context.gc.lilac),
                  );
                }
                final entries =
                    provider.freeWritings.where(_matches).toList();
                if (entries.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        l10n.grimoireNoRecords,
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: context.gc.textSecondary),
                      ),
                    ),
                  );
                }
                return CascadeScope(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return CascadeIn(
                        index: index,
                        child: _buildEntryCard(context, l10n, entry),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(
    BuildContext context,
    AppLocalizations l10n,
    FreeWritingModel entry,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    // Reflexões não têm título: a primeira linha do texto apresenta o card.
    final title = entry.title ??
        entry.content.split('\n').firstWhere(
              (line) => line.trim().isNotEmpty,
              orElse: () => dateFormat.format(entry.createdAt),
            );

    return MagicalCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecordDetailPage(entry: entry),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.gc.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.gc.lilac.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.gc.lilac.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  archiveSourceLabel(l10n, entry.source),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.lilac,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            dateFormat.format(entry.updatedAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.gc.textSecondary,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            entry.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
