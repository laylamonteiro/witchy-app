import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/sharing/share_card.dart';
import '../../../../core/sharing/share_card_sheet.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/paged_reading.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../../grimoire/presentation/pages/spell_detail_page.dart';
import '../../../grimoire/presentation/providers/spell_provider.dart';
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
    final ondeVaiAAfirmacao =
        _indiceDaAfirmacao(secoes, l10n, resolvedAffirmation);
    final ondeVaoOsRituais = secoes.indexWhere(
      (secao) => secao.contains(l10n.cycleReadingSectionRituals),
    );

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
                    if (_temAfirmacao(resolvedAffirmation))
                      _botaoAfirmacao(context, l10n, resolvedAffirmation!),
                    if (resolvedSeal.isNotEmpty)
                      _botaoPalavrasChave(context, l10n, resolvedSeal),
                    const SizedBox(height: 16),
                    _notaDoAcervo(context, l10n),
                  ],
                ),
              )
            : PagedReading(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                pages: [
                  for (var i = 0; i < secoes.length; i++)
                    _pagina(
                      context,
                      l10n,
                      secao: secoes[i],
                      // O botão de compartilhar mora na página da seção a que
                      // pertence: a afirmação com a afirmação, as palavras-chave
                      // com as palavras-chave. Antes ficavam numa página de
                      // ações no fim, longe do que compartilhavam.
                      afirmacao:
                          i == ondeVaiAAfirmacao ? resolvedAffirmation : null,
                      // As palavras-chave fecham o relatório — é a mesma
                      // premissa que `sealFromMarkdown` usa para recortá-las,
                      // e vale também para leituras antigas, cujo título da
                      // seção era outro.
                      palavrasChave:
                          i == secoes.length - 1 ? resolvedSeal : const [],
                      // Os rituais deixam de ser uma lista corrida: cada um
                      // ganha cartão e um botão para virar feitiço.
                      rituais: i == ondeVaoOsRituais,
                      ultima: i == secoes.length - 1,
                    ),
                ],
              ),
      ),
    );
  }

  static bool _temAfirmacao(String? afirmacao) =>
      afirmacao != null && afirmacao.trim().isNotEmpty;

  /// Em que seção mora a afirmação.
  ///
  /// Procura primeiro pelo título da seção, que é o que o app escreve no
  /// Markdown; se não achar (relatório antigo, título diferente), procura o
  /// próprio texto da afirmação. Sem nenhum dos dois, cai na última página —
  /// o botão pode ficar fora de lugar, mas nunca some.
  static int _indiceDaAfirmacao(
    List<String> secoes,
    AppLocalizations l10n,
    String? afirmacao,
  ) {
    final titulo = l10n.cycleReadingSectionAffirmation;
    for (var i = 0; i < secoes.length; i++) {
      if (secoes[i].contains(titulo)) return i;
    }
    if (_temAfirmacao(afirmacao)) {
      for (var i = 0; i < secoes.length; i++) {
        if (secoes[i].contains(afirmacao!.trim())) return i;
      }
    }
    return secoes.length - 1;
  }

  Widget _pagina(
    BuildContext context,
    AppLocalizations l10n, {
    required String secao,
    required String? afirmacao,
    required List<String> palavrasChave,
    required bool ultima,
    bool rituais = false,
  }) {
    final ritos = rituais ? _rituais(secao) : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (ritos != null) ...[
          _markdown(context, ritos.cabecalho),
          for (final rito in ritos.itens)
            _CartaoDeRitual(
              nome: rito.nome,
              corpo: rito.corpo,
              periodo: _periodoParaNota(),
            ),
        ] else
          _markdown(context, secao),
        if (_temAfirmacao(afirmacao)) ...[
          const SizedBox(height: 20),
          _botaoAfirmacao(context, l10n, afirmacao!),
        ],
        if (palavrasChave.isNotEmpty) ...[
          const SizedBox(height: 20),
          _botaoPalavrasChave(context, l10n, palavrasChave),
        ],
        if (ultima) ...[
          const SizedBox(height: 20),
          _notaDoAcervo(context, l10n),
        ],
      ],
    );
  }

  /// Recorta a seção dos rituais em cabeçalho + um item por ritual.
  ///
  /// A geração pede uma lista com "-", e cada item vem como
  /// `**Nome do ritual**: como fazer`. Se o formato não for esse (leitura
  /// antiga, geração torta), devolve null e a seção segue como texto — é um
  /// produto pago e não pode depender do formato exato que a IA produziu.
  static ({String cabecalho, List<({String nome, String corpo})> itens})?
      _rituais(String secao) {
    final linhas = secao.split('\n');
    final cabecalho = <String>[];
    final blocos = <List<String>>[];

    for (final linha in linhas) {
      final limpa = linha.trimLeft();
      final marcador = RegExp(r'^[-*+]\s+');
      if (marcador.hasMatch(limpa)) {
        blocos.add([limpa.replaceFirst(marcador, '')]);
      } else if (blocos.isEmpty) {
        cabecalho.add(linha);
      } else if (limpa.isNotEmpty) {
        // Continuação do item anterior (a IA quebra linha no meio).
        blocos.last.add(limpa);
      }
    }
    if (blocos.isEmpty) return null;

    final itens = <({String nome, String corpo})>[];
    for (final bloco in blocos) {
      final texto = bloco.join(' ').trim();
      if (texto.isEmpty) continue;
      final comRealce =
          RegExp(r'^\*\*(.+?)\*\*\s*[:—–-]?\s*(.*)$', dotAll: true)
              .firstMatch(texto);
      if (comRealce != null) {
        itens.add((
          nome: comRealce.group(1)!.trim(),
          corpo: comRealce.group(2)!.trim(),
        ));
        continue;
      }
      final doisPontos = texto.indexOf(':');
      if (doisPontos > 0 && doisPontos < 80) {
        itens.add((
          nome: texto.substring(0, doisPontos).trim(),
          corpo: texto.substring(doisPontos + 1).trim(),
        ));
        continue;
      }
      itens.add((nome: '', corpo: texto));
    }
    if (itens.isEmpty) return null;
    return (cabecalho: cabecalho.join('\n').trim(), itens: itens);
  }

  /// "13/08/2026 a 11/09/2026" para a observação do feitiço salvo; null ao
  /// abrir do acervo, onde o período não vem.
  String? _periodoParaNota() {
    if (periodStart == null || periodEnd == null) return null;
    final formato = DateFormat('dd/MM/yyyy');
    return '${formato.format(periodStart!)} — '
        '${formato.format(periodEnd!.subtract(const Duration(days: 1)))}';
  }

  Widget _botaoAfirmacao(
    BuildContext context,
    AppLocalizations l10n,
    String afirmacao,
  ) {
    return ElevatedButton.icon(
      onPressed: () => _shareAffirmation(context, l10n, afirmacao),
      icon: const Icon(Icons.ios_share, size: 18),
      label: Text(l10n.cycleReadingShareAffirmation),
    );
  }

  Widget _botaoPalavrasChave(
    BuildContext context,
    AppLocalizations l10n,
    List<String> palavras,
  ) {
    return OutlinedButton.icon(
      onPressed: () => _shareSeal(context, l10n, palavras),
      icon: const Icon(Icons.auto_awesome, size: 18),
      label: Text(l10n.cycleReadingShareSeal),
    );
  }

  Widget _notaDoAcervo(BuildContext context, AppLocalizations l10n) {
    return Text(
      l10n.cycleReadingSavedToArchive,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.gc.textSecondary,
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

  static Widget _markdown(BuildContext context, String data) {
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
        // As expressões que a leitura marca com `**` saem em COR, não em
        // negrito — a mesma gramática das leituras das Eras. Negrito no meio
        // do parágrafo pesa; cor guia o olho sem quebrar o ritmo.
        strong: TextStyle(
          color: context.gc.lilac,
          fontWeight: FontWeight.normal,
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
      fileName: 'leitura_ciclo_palavras_chave',
      shareText: keywords.join(' · '),
    );
  }
}

/// Um ritual sugerido pela leitura, com o caminho para virar feitiço.
///
/// A sugestão nasce sob medida para o ciclo que a pessoa viveu e, até agora,
/// morria no texto: para guardá-la era preciso copiar à mão para o Grimório.
/// O botão fecha esse caminho — o ritual entra em Meus Feitiços com o nome
/// que a leitura deu, o passo a passo que ela escreveu e a origem anotada.
class _CartaoDeRitual extends StatefulWidget {
  const _CartaoDeRitual({
    required this.nome,
    required this.corpo,
    this.periodo,
  });

  final String nome;
  final String corpo;

  /// Período lido, para a observação do feitiço (null ao abrir do acervo).
  final String? periodo;

  @override
  State<_CartaoDeRitual> createState() => _CartaoDeRitualState();
}

class _CartaoDeRitualState extends State<_CartaoDeRitual> {
  bool _salvo = false;
  bool _salvando = false;

  /// Texto sem NENHUMA marcação: o feitiço vive no Grimório, onde o campo é
  /// texto puro — `**realce**` e `*itálico*` sairiam como asteriscos na
  /// ficha. Na leitura, ao contrário, a marcação é lida pelo Markdown.
  static String _textoPuro(String texto) =>
      CycleReadingService.semRealce(texto).replaceAll('*', '').trim();

  Future<void> _salvar() async {
    if (_salvando || _salvo) return;
    setState(() => _salvando = true);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final destaque = context.gc.lilac;

    // Sem a marcação de realce: o feitiço é texto do Grimório, não Markdown
    // da leitura.
    final feitico = SpellModel(
      name: _textoPuro(
        widget.nome.isEmpty ? l10n.cycleReadingSectionRituals : widget.nome,
      ),
      purpose: l10n.cycleReadingRitualPurpose,
      // O que a leitura sugere é sempre construtivo, e a categoria fica em
      // "outros": inventar uma pelo texto acertaria pouco e a pessoa pode
      // corrigir num toque na ficha do feitiço.
      type: SpellType.attraction,
      category: SpellCategory.other,
      steps: _textoPuro(widget.corpo),
      observations: widget.periodo == null
          ? l10n.cycleReadingRitualPurpose
          : l10n.cycleReadingRitualFrom(widget.periodo!),
    );

    await context.read<SpellProvider>().addSpell(feitico);
    if (!mounted) return;
    setState(() {
      _salvo = true;
      _salvando = false;
    });
    messenger.showSnackBar(SnackBar(
      content: Text(l10n.cycleReadingRitualSaved),
      action: SnackBarAction(
        label: l10n.numSee,
        textColor: destaque,
        onPressed: () => navigator.push(
          MaterialPageRoute(builder: (_) => SpellDetailPage(spell: feitico)),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tema = Theme.of(context);

    return MagicalCard(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.nome.isNotEmpty)
            Text(
              _textoPuro(widget.nome),
              style: tema.textTheme.titleMedium?.copyWith(
                color: context.gc.lilac,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (widget.nome.isNotEmpty) const SizedBox(height: 6),
          CycleReadingReportPage._markdown(context, widget.corpo),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: _salvo
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 18, color: context.gc.lilac),
                      const SizedBox(width: 8),
                      Text(
                        l10n.cycleReadingRitualSaved,
                        style: tema.textTheme.bodySmall
                            ?.copyWith(color: context.gc.textSecondary),
                      ),
                    ],
                  )
                : OutlinedButton.icon(
                    onPressed: _salvando ? null : _salvar,
                    icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                    label: Text(l10n.cycleReadingSaveRitual),
                  ),
          ),
        ],
      ),
    );
  }
}
