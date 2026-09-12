import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/presentation/providers/free_writing_provider.dart';
import '../../../menstrual_cycle/data/repositories/menstrual_cycle_repository.dart';
import 'record_form_page.dart';

/// Rótulo do selinho de origem de uma entrada do acervo.
String archiveSourceLabel(AppLocalizations l10n, String source) =>
    switch (source) {
      FreeWritingSource.grimorioVivo => l10n.recordsSourceGrimorioVivo,
      FreeWritingSource.palmistry => l10n.recordsSourcePalmistry,
      FreeWritingSource.runes => l10n.recordsSourceRunes,
      FreeWritingSource.pendulum => l10n.recordsSourcePendulum,
      FreeWritingSource.oracle => l10n.recordsSourceOracle,
      FreeWritingSource.tarot => l10n.recordsSourceTarot,
      FreeWritingSource.cycleReading => l10n.recordsSourceCycleReading,
      FreeWritingSource.advisor => l10n.recordsSourceAdvisor,
      FreeWritingSource.menstrual => l10n.recordsSourceMenstrual,
      _ => l10n.recordsSourceReflection,
    };

/// Detalhe de uma entrada do acervo "Meus Registros": título + selinho da
/// origem, conteúdo (com destaque das linhas ✦) e datas. Editável e
/// excluível — a página veio do Grimório Vivo ou de uma leitura, mas é da
/// Bruxa.
///
/// Com UMA exceção: a página do Ciclo Menstrual não se edita nem se apaga
/// daqui. Ela é espelho de uma linha de `menstrual_days`, reescrita a cada
/// gravação do dia — editá-la aqui duraria até a próxima correção na roda, e
/// apagá-la aqui deixaria o dia vivo no registro com a vitrine vazia, que é
/// exatamente a mentira que este espelho existe para não contar. Quem manda
/// no dia é a roda do ciclo, e o rodapé diz isso em vez de esconder os
/// botões sem explicação.
class RecordDetailPage extends StatefulWidget {
  final FreeWritingModel entry;

  /// O repositório do ciclo, para o teste trocar. A página do dia do ciclo
  /// não é apagada como as outras: apagá-la é apagar o DIA, e quem sabe
  /// fazer isso (e tirar a página junto) é o repositório do ciclo.
  final MenstrualCycleRepository? menstrualRepository;

  const RecordDetailPage({
    super.key,
    required this.entry,
    this.menstrualRepository,
  });

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  late FreeWritingModel _entry = widget.entry;

  /// Esta página é o espelho de um dia do ciclo?
  bool get _espelhoDoCiclo => _entry.source == FreeWritingSource.menstrual;

  Future<void> _edit() async {
    final updated = await Navigator.push<FreeWritingModel>(
      context,
      MaterialPageRoute(builder: (_) => RecordFormPage(entry: _entry)),
    );
    if (updated != null && mounted) setState(() => _entry = updated);
  }

  Future<bool> _confirm(String message) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.gc.surface,
        title: Text(l10n.commonDelete),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            key: const ValueKey('record-delete-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed =
        await _confirm(l10n.recordDeleteConfirm(_entry.title ?? ''));
    if (!confirmed || !mounted) return;
    await context.read<FreeWritingProvider>().delete(_entry.id);
    if (mounted) Navigator.pop(context);
  }

  /// Apagar a página do dia do ciclo é apagar o dia — pelo repositório do
  /// ciclo, que grava a lápide da linha e tira a página junto, exatamente o
  /// que o "Apagar este dia" da roda faz. Apagar só a página, pelo acervo,
  /// deixaria o dia vivo no calendário e a próxima gravação o traria de volta
  /// ao Grimório — o contrário do que ela pediu.
  ///
  /// O dia observado é o `createdAt` da página: o espelho grava as duas datas
  /// como o dia registrado, nunca como o instante da digitação.
  Future<void> _confirmDeleteCycleDay() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(l10n.recordDeleteCycleDayConfirm);
    if (!confirmed || !mounted) return;
    // O modelo do acervo aceita página sem dono; a do ciclo sempre tem, mas
    // o tipo não sabe disso. Sem dono não há dia a apagar, e fingir um dono
    // apagaria o dia de outra pessoa.
    final userId = _entry.userId;
    if (userId == null) return;
    final repository = widget.menstrualRepository ?? MenstrualCycleRepository();
    await repository.remove(userId: userId, day: _entry.createdAt);
    if (!mounted) return;
    // A lista do acervo lê do provedor, e o repositório do ciclo escreve no
    // banco por baixo dele: sem recarregar, a página apagada continuaria na
    // lista até a próxima abertura.
    await context.read<FreeWritingProvider>().loadFreeWritings();
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
          if (_espelhoDoCiclo)
            // Sem editar: o corpo da página é o espelho do dia, e o dia se
            // edita na roda. Apagar, sim — pedido da dona, 12/09.
            IconButton(
              key: const ValueKey('record-cycle-delete'),
              icon: const Icon(Icons.delete),
              tooltip: l10n.menstrualDelete,
              onPressed: _confirmDeleteCycleDay,
            )
          else ...[
            IconButton(icon: const Icon(Icons.edit), onPressed: _edit),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
          ],
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
                  if (_espelhoDoCiclo) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.menstrualArchiveOrigin,
                      key: const ValueKey('record-menstrual-origin'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.gc.textSecondary,
                            height: 1.4,
                          ),
                    ),
                  ],
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
