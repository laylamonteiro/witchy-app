import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/presentation/providers/free_writing_provider.dart';
import 'record_form_page.dart';

/// Rótulo do selinho de origem de uma entrada do acervo.
String archiveSourceLabel(AppLocalizations l10n, String source) =>
    switch (source) {
      FreeWritingSource.grimorioVivo => l10n.recordsSourceGrimorioVivo,
      FreeWritingSource.palmistry => l10n.recordsSourcePalmistry,
      FreeWritingSource.runes => l10n.recordsSourceRunes,
      FreeWritingSource.pendulum => l10n.recordsSourcePendulum,
      FreeWritingSource.oracle => l10n.recordsSourceOracle,
      _ => l10n.recordsSourceReflection,
    };

/// Detalhe de uma entrada do acervo "Meus Registros": título + selinho da
/// origem, conteúdo (com destaque das linhas ✦) e datas. Editável e
/// excluível — a página veio do Grimório Vivo ou de uma leitura, mas é da
/// Bruxa.
class RecordDetailPage extends StatefulWidget {
  final FreeWritingModel entry;

  const RecordDetailPage({super.key, required this.entry});

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  late FreeWritingModel _entry = widget.entry;

  Future<void> _edit() async {
    final updated = await Navigator.push<FreeWritingModel>(
      context,
      MaterialPageRoute(builder: (_) => RecordFormPage(entry: _entry)),
    );
    if (updated != null && mounted) setState(() => _entry = updated);
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.gc.surface,
        title: Text(l10n.commonDelete),
        content: Text(
          l10n.recordDeleteConfirm(_entry.title ?? ''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<FreeWritingProvider>().delete(_entry.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(l10n.recordDetails),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _edit),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _entry.title ?? dateFormat.format(_entry.createdAt),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.auto_stories,
                          size: 16, color: context.gc.lilac),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.gc.lilac.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: context.gc.lilac.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          archiveSourceLabel(l10n, _entry.source),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.gc.lilac,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _contentLines(context),
              ),
            ),
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.spellCreatedAt(dateFormat.format(_entry.createdAt)),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (_entry.updatedAt != _entry.createdAt)
                    Text(
                      l10n.spellUpdatedAt(dateFormat.format(_entry.updatedAt)),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// O conteúdo vem como "✦ pergunta \n resposta": destaca as perguntas e
  /// mantém as respostas como texto corrido (mesmo visual dos registros
  /// antigos do Grimório Vivo).
  List<Widget> _contentLines(BuildContext context) {
    final widgets = <Widget>[];
    for (final line in _entry.content.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 14));
      } else if (trimmed.startsWith('✦')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            trimmed,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.gc.lilac,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
          ),
        ));
      } else {
        widgets.add(Text(
          line,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
        ));
      }
    }
    return widgets;
  }
}
