import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/sharing/share_card.dart';
import '../../../../core/sharing/share_card_sheet.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../data/models/cycle_reading_model.dart';
import '../../data/services/cycle_reading_service.dart';

/// O relatório da Leitura do Ciclo: Markdown das 7 seções + os dois
/// cartões compartilháveis (afirmação sob medida e selo do ciclo).
///
/// A entrada já vive no acervo (`free_writings`, source `cycle_reading`):
/// esta página é a moldura de leitura — reabrir depois cai em Meus
/// Registros ou de novo aqui.
class CycleReadingReportPage extends StatelessWidget {
  final FreeWritingModel writing;

  /// Presentes na geração recém-concluída; ao reabrir são recuperados do
  /// próprio Markdown salvo.
  final String? affirmation;
  final List<String>? sealKeywords;

  /// Período coberto (para o cartão do selo); null ao abrir do acervo.
  final DateTime? periodStart;
  final DateTime? periodEnd;

  /// Janela lida — decide o nome do produto no título e no cartão.
  final String periodType;

  const CycleReadingReportPage({
    super.key,
    required this.writing,
    this.affirmation,
    this.sealKeywords,
    this.periodStart,
    this.periodEnd,
    this.periodType = CycleReadingPeriodType.lunation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final resolvedAffirmation = affirmation ??
        CycleReadingService.affirmationFromMarkdown(writing.content);
    final resolvedSeal = sealKeywords ??
        CycleReadingService.sealFromMarkdown(writing.content);

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(
          CycleReadingService.periodTitle(periodType),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MarkdownBody(
              // Sem o `# Título` de topo: a AppBar já o mostra, e repeti-lo
              // dava o título duplicado. O `_período_` (itálico) segue como
              // subtítulo. Só exibição — o conteúdo salvo no acervo é intacto.
              data: _forDisplay(writing.content),
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                  .copyWith(
                h2: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: context.gc.lilac,
                      fontWeight: FontWeight.bold,
                    ),
                h2Padding: const EdgeInsets.only(top: 20, bottom: 4),
                pPadding: const EdgeInsets.only(bottom: 8),
                p: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                em: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: context.gc.textSecondary,
                ),
                blockquotePadding: const EdgeInsets.all(16),
                blockquoteDecoration: BoxDecoration(
                  color: context.gc.lilac.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.gc.lilac.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (resolvedAffirmation != null &&
                resolvedAffirmation.isNotEmpty) ...[
              ElevatedButton.icon(
                onPressed: () => _shareAffirmation(
                  context,
                  l10n,
                  resolvedAffirmation,
                ),
                icon: const Icon(Icons.ios_share, size: 18),
                label: Text(l10n.cycleReadingShareAffirmation),
              ),
              const SizedBox(height: 8),
            ],
            if (resolvedSeal.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () => _shareSeal(context, l10n, resolvedSeal),
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: Text(l10n.cycleReadingShareSeal),
              ),
            const SizedBox(height: 16),
            Text(
              l10n.cycleReadingSavedToArchive,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.gc.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Só para exibição: remove o `# Título` inicial (a AppBar já o traz),
  /// preservando o resto — inclusive a linha `_período_`.
  static String _forDisplay(String markdown) {
    final lines = markdown.split('\n');
    if (lines.isNotEmpty && lines.first.trimLeft().startsWith('# ')) {
      lines.removeAt(0);
      while (lines.isNotEmpty && lines.first.trim().isEmpty) {
        lines.removeAt(0);
      }
    }
    return lines.join('\n');
  }

  void _shareAffirmation(
    BuildContext context,
    AppLocalizations l10n,
    String text,
  ) {
    showShareCardSheet(
      context,
      card: ShareCard(
        child: AffirmationShareContent(
          title: CycleReadingService.periodTitle(periodType),
          text: text,
        ),
      ),
      fileName: 'leitura_ciclo_afirmacao',
      shareText: text,
    );
  }

  void _shareSeal(
    BuildContext context,
    AppLocalizations l10n,
    List<String> keywords,
  ) {
    final format = DateFormat('dd/MM');
    final periodLine = periodStart != null && periodEnd != null
        ? '${format.format(periodStart!)}–${format.format(periodEnd!)}'
        : null;
    showShareCardSheet(
      context,
      card: ShareCard(
        child: AchievementShareContent(
          emoji: '🌙',
          title: l10n.cycleReadingSectionSeal,
          highlight: keywords.join(' · '),
          extraLine: periodLine,
          accent: ShareCard.colors.lilac,
        ),
      ),
      fileName: 'leitura_ciclo_selo',
      shareText: keywords.join(' · '),
    );
  }
}
