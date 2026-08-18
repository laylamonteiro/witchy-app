import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/sharing/share_card.dart';
import '../../../../core/sharing/share_card_sheet.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../diary/data/models/free_writing_model.dart';
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

  const CycleReadingReportPage({
    super.key,
    required this.writing,
    this.affirmation,
    this.sealKeywords,
    this.periodStart,
    this.periodEnd,
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
        title: ResponsiveAppBarTitle(l10n.cycleReadingTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MarkdownBody(
              data: writing.content,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                  .copyWith(
                h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: context.gc.lilac,
                    ),
                h2: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: context.gc.lilac,
                      fontWeight: FontWeight.bold,
                    ),
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

  void _shareAffirmation(
    BuildContext context,
    AppLocalizations l10n,
    String text,
  ) {
    showShareCardSheet(
      context,
      card: ShareCard(
        child: AffirmationShareContent(
          title: l10n.cycleReadingTitle,
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
