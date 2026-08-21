import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/sharing/share_card.dart';
import '../../../../core/sharing/share_card_sheet.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/paged_reading.dart';
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

    final corpo = _forDisplay(writing.content);
    final secoes = _sections(corpo);
    final acoes = _actions(context, l10n, resolvedAffirmation, resolvedSeal);

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(
          CycleReadingService.periodTitle(periodType),
        ),
      ),
      // Com as seções reconhecidas, a leitura vira páginas que deslizam: sete
      // telas curtas em vez de uma rolagem sem fim. Se o Markdown vier sem os
      // títulos esperados, cai na rolagem única de sempre — a leitura é um
      // produto pago e não pode depender do formato exato que a geração
      // devolveu.
      body: SafeArea(
        child: secoes.length < 2
            ? SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _markdown(context, corpo),
                    const SizedBox(height: 24),
                    acoes,
                  ],
                ),
              )
            : PagedReading(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                pages: [
                  for (final secao in secoes) _markdown(context, secao),
                  acoes,
                ],
              ),
      ),
    );
  }

  /// Quebra o Markdown nos títulos de seção (`## `), uma página por seção.
  ///
  /// O que vier antes do primeiro título — a linha `_período_` em itálico —
  /// fica grudado na primeira seção, para não virar uma página quase vazia.
  /// Devolve lista vazia quando não há pelo menos duas seções — sem títulos
  /// reconhecíveis, ou com uma só, quem chama cai no modo rolagem.
  static List<String> _sections(String markdown) {
    final linhas = markdown.split('\n');
    final secoes = <String>[];
    final atual = <String>[];

    for (final linha in linhas) {
      if (linha.trimLeft().startsWith('## ') && atual.isNotEmpty) {
        secoes.add(atual.join('\n').trim());
        atual.clear();
      }
      atual.add(linha);
    }
    if (atual.isNotEmpty) secoes.add(atual.join('\n').trim());

    final cheias = secoes.where((s) => s.isNotEmpty).toList();
    // Uma "seção" só significa que não achamos os títulos.
    if (cheias.length < 2) return const [];

    // O preâmbulo (sem `## `) entra junto da primeira seção de verdade.
    if (!cheias.first.trimLeft().startsWith('## ')) {
      final preambulo = cheias.removeAt(0);
      if (cheias.isEmpty) return const [];
      cheias[0] = '$preambulo\n\n${cheias[0]}';
    }
    // Uma página só não é paginação: melhor a rolagem de sempre.
    return cheias.length < 2 ? const [] : cheias;
  }

  Widget _markdown(BuildContext context, String data) {
    return MarkdownBody(
      // Sem o `# Título` de topo: a AppBar já o mostra, e repeti-lo dava o
      // título duplicado. O `_período_` (itálico) segue como subtítulo. Só
      // exibição — o conteúdo salvo no acervo é intacto.
      data: data,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
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
    );
  }

  /// A última página: os dois cartões compartilháveis e o aviso de que a
  /// leitura ficou guardada no acervo.
  Widget _actions(
    BuildContext context,
    AppLocalizations l10n,
    String? resolvedAffirmation,
    List<String> resolvedSeal,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (resolvedAffirmation != null && resolvedAffirmation.isNotEmpty) ...[
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
