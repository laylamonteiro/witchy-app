import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../cycle_reading/data/models/cycle_reading_model.dart';
import '../../../cycle_reading/data/repositories/cycle_reading_repository.dart';
import '../../../cycle_reading/presentation/pages/cycle_reading_intro_page.dart';
import '../../../cycle_reading/presentation/pages/cycle_reading_report_page.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/presentation/providers/free_writing_provider.dart';
import 'record_detail_page.dart';

/// Um filtro do acervo: `id` estável (guarda a seleção entre rebuilds),
/// rótulo do chip e o teste de pertencimento.
typedef ArchiveFilter = ({
  String id,
  String label,
  bool Function(FreeWritingModel entry) matches,
});

/// Id do filtro padrão: o acervo inteiro. Os outros chips é que recortam —
/// um por origem, sem agrupadores que repetem o resultado de outro chip.
const _defaultFilterId = 'records';

/// "Meus Registros": a janela do acervo unificado dentro do Meu Grimório.
/// Abre com tudo à vista — páginas do Grimório Vivo, leituras salvas
/// (quiromancia, runas, pêndulo, oráculo, tarot) e reflexões — e os chips
/// recortam por origem. Não há botão de criar: as entradas nascem das
/// lições, das leituras e da aba 💭 dos Diários.
class RecordsArchiveListPage extends StatefulWidget {
  const RecordsArchiveListPage({super.key});

  @override
  State<RecordsArchiveListPage> createState() =>
      _RecordsArchiveListPageState();
}

class _RecordsArchiveListPageState extends State<RecordsArchiveListPage> {
  String _filterId = _defaultFilterId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FreeWritingProvider>().loadFreeWritings();
    });
  }

  /// Os chips nascem do que a Bruxa realmente tem no acervo: cada origem
  /// com entradas vira um filtro, com o mesmo nome do selinho do card —
  /// nada de chip que abre lista vazia, nem origem visível sem filtro.
  List<ArchiveFilter> _buildFilters(
    AppLocalizations l10n,
    List<FreeWritingModel> entries,
  ) {
    final present = entries.map((e) => e.source).toSet();
    final readings =
        FreeWritingSource.readings.where(present.contains).toList();

    return [
      (
        id: _defaultFilterId,
        label: l10n.recordsFilterRecords,
        matches: (FreeWritingModel _) => true,
      ),
      if (present.contains(FreeWritingSource.grimorioVivo))
        (
          id: FreeWritingSource.grimorioVivo,
          label: l10n.recordsFilterGrimorioVivo,
          matches: (FreeWritingModel e) =>
              e.source == FreeWritingSource.grimorioVivo,
        ),
      for (final source in readings)
        (
          id: source,
          label: archiveSourceLabel(l10n, source),
          matches: (FreeWritingModel e) => e.source == source,
        ),
      if (present.contains(FreeWritingSource.cycleReading))
        (
          id: FreeWritingSource.cycleReading,
          label: archiveSourceLabel(l10n, FreeWritingSource.cycleReading),
          matches: (FreeWritingModel e) =>
              e.source == FreeWritingSource.cycleReading,
        ),
      if (present.contains(FreeWritingSource.free))
        (
          id: FreeWritingSource.free,
          label: l10n.recordsFilterReflections,
          matches: (FreeWritingModel e) => e.source == FreeWritingSource.free,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(l10n.grimoireMyRecords),
      ),
      body: Consumer<FreeWritingProvider>(
        builder: (context, provider, _) {
          final filters = _buildFilters(l10n, provider.freeWritings);
          // O chip escolhido pode sumir (última entrada daquela origem
          // apagada): nesse caso o acervo volta ao filtro padrão.
          final active = filters.firstWhere(
            (filter) => filter.id == _filterId,
            orElse: () => filters.first,
          );
          final entries =
              provider.freeWritings.where(active.matches).toList();

          return Column(
            children: [
              // Chips de filtro — dentro de UMA superfície, em vez de duas
              // funcionalidades parecidas.
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final filter in filters)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter.label),
                          selected: active.id == filter.id,
                          selectedColor:
                              context.gc.lilac.withValues(alpha: 0.35),
                          onSelected: (_) =>
                              setState(() => _filterId = filter.id),
                        ),
                      ),
                  ],
                ),
              ),
              // Porta permanente da Leitura do Ciclo. Quem abre o acervo é
              // exatamente quem dá valor ao histórico — e é do histórico
              // que a leitura é tecida. Faixa fina de propósito: aqui ela
              // é atalho, não anúncio.
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CycleReadingIntroPage(),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.gc.lilac.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('🌙', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.cycleReadingTitle,
                            style: TextStyle(
                              color: context.gc.lilac,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: context.gc.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: provider.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: context.gc.lilac,
                        ),
                      )
                    : entries.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                l10n.grimoireNoRecords,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: context.gc.textSecondary,
                                ),
                              ),
                            ),
                          )
                        : CascadeScope(
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: entries.length,
                              itemBuilder: (context, index) {
                                final entry = entries[index];
                                return CascadeIn(
                                  index: index,
                                  child:
                                      _buildEntryCard(context, l10n, entry),
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Abre a entrada na moldura certa: a Leitura do Ciclo é Markdown e tem
  /// cartões para compartilhar, então volta pela própria página do
  /// relatório — na página genérica ela apareceria com a marcação crua.
  Future<void> _openEntry(BuildContext context, FreeWritingModel entry) async {
    if (entry.source == FreeWritingSource.cycleReading) {
      final reading = await CycleReadingRepository().findByWritingId(entry.id);
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CycleReadingReportPage(
            writing: entry,
            periodStart: reading?.periodStart,
            periodEnd: reading?.periodEnd,
            periodType:
                reading?.periodType ?? CycleReadingPeriodType.lunation,
          ),
        ),
      );
      return;
    }
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecordDetailPage(entry: entry)),
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
      onTap: () => _openEntry(context, entry),
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
