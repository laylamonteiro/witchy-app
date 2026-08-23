import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/ai/ai_service.dart';
import '../../../../core/ai/prompts/ai_prompts.dart';
import '../../../../core/sharing/share_card.dart';
import '../../../../core/sharing/share_card_sheet.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/paged_reading.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/reading_markdown.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/presentation/providers/free_writing_provider.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../../grimoire/presentation/pages/spell_detail_page.dart';
import '../../../grimoire/presentation/providers/spell_provider.dart';
import '../../data/models/cycle_reading_model.dart';
import '../../data/repositories/cycle_reading_repository.dart';
import '../../data/services/cycle_reading_service.dart';

/// Um título de seção como ele pode aparecer no relatório GRAVADO.
///
/// A leitura é markdown, e o título foi escrito no idioma em que ela foi
/// gerada — enquanto a tela lê no idioma de agora. Comparar só com o título
/// atual fazia a seção desaparecer das leituras antigas de quem troca o
/// idioma do app: o texto continuava lá, os cartõezinhos de ritual não.
///
/// A chave estável seria o certo, mas ela não existe no que já está gravado.
/// Cobrir os três idiomas resolve o acervo sem reescrever nada.
Set<String> _tituloEmTodosOsIdiomas(
  String Function(AppLocalizations) escolher,
) =>
    {
      for (final locale in AppLocalizations.supportedLocales)
        escolher(lookupAppLocalizations(locale)),
    };

final _titulosDeRituais =
    _tituloEmTodosOsIdiomas((l) => l.cycleReadingSectionRituals);

final _titulosDaAfirmacao =
    _tituloEmTodosOsIdiomas((l) => l.cycleReadingSectionAffirmation);

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

    final corpo = _semTitulo(writing.content);
    final secoes = _sections(corpo);
    final ondeVaiAAfirmacao =
        _indiceDaAfirmacao(secoes, resolvedAffirmation);
    final ondeVaoOsRituais = secoes.indexWhere(
      (secao) => _titulosDeRituais.any(secao.contains),
    );

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(
          CycleReadingService.periodTitle(periodType),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.commonDelete,
            onPressed: () => _confirmarExclusao(context, l10n),
          ),
        ],
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
                    _markdown(context, _semAnotacoes(corpo)),
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

  /// Apaga a leitura: o relatório do acervo E o registro que aponta para
  /// ele.
  ///
  /// A leitura é da pessoa e ela pode querer que suma — inclusive porque o
  /// texto foi tecido dos diários dela. Apagar só a entrada do acervo
  /// deixaria a linha em `cycle_readings` apontando para um relatório
  /// inexistente, e a lista "Suas leituras" mostraria uma porta que não
  /// abre nada.
  Future<void> _confirmarExclusao(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        backgroundColor: dialogo.gc.surface,
        title: Text(l10n.commonDelete),
        content: Text(l10n.cycleReadingDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogo, false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogo, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: dialogo.gc.alert,
            ),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmado != true || !context.mounted) return;

    final registro =
        await CycleReadingRepository().findByWritingId(writing.id);
    if (registro != null) {
      await CycleReadingRepository().delete(registro.id);
    }
    if (!context.mounted) return;
    await context.read<FreeWritingProvider>().delete(writing.id);
    if (context.mounted) Navigator.pop(context);
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
    String? afirmacao,
  ) {
    for (var i = 0; i < secoes.length; i++) {
      if (_titulosDaAfirmacao.any(secoes[i].contains)) return i;
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
          _markdown(context, _semAnotacoes(ritos.cabecalho)),
          for (final rito in ritos.itens)
            _CartaoDeRitual(
              nome: rito.nome,
              corpo: rito.corpo,
              lua: rito.lua,
              ingredientes: rito.ingredientes,
              periodo: _periodoParaNota(),
            ),
        ] else
          _markdown(context, _semAnotacoes(secao)),
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

  /// A anotação que a geração deixa para o app: `[moon: fase]` e
  /// `[items: a; b; c]`.
  ///
  /// Fica entre colchetes e em inglês nos TRÊS idiomas de propósito: é
  /// campo de máquina, não texto de leitura. Assim o mesmo recorte vale
  /// para uma leitura gerada em espanhol e aberta em português.
  static final RegExp _anotacao =
      RegExp(r'\[\s*(moon|items)\s*:\s*([^\]]*)\]', caseSensitive: false);

  /// Recorta a seção dos rituais em cabeçalho + um item por ritual.
  ///
  /// A geração pede uma lista com "-", e cada item vem como
  /// `**Nome do ritual**`, a anotação do app e o passo a passo. Se o formato
  /// não for esse (leitura antiga, geração torta), devolve null e a seção
  /// segue como texto — é um produto pago e não pode depender do formato
  /// exato que a IA produziu; e cada pedaço tem seu próprio plano B: sem
  /// anotação, o cartão só perde a lua e os ingredientes.
  static ({
    String cabecalho,
    List<
        ({
          String nome,
          String corpo,
          MoonPhase? lua,
          List<String> ingredientes
        })> itens,
  })? _rituais(String secao) {
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

    final itens = <({
      String nome,
      String corpo,
      MoonPhase? lua,
      List<String> ingredientes
    })>[];

    for (final bloco in blocos) {
      var texto = bloco.join(' ').trim();
      if (texto.isEmpty) continue;

      MoonPhase? lua;
      var ingredientes = const <String>[];
      for (final achado in _anotacao.allMatches(texto)) {
        final valor = achado.group(2)!.trim();
        if (achado.group(1)!.toLowerCase() == 'moon') {
          lua = _luaDe(valor);
        } else {
          ingredientes = valor
              .split(RegExp(r'[;,]'))
              .map((i) => i.trim())
              .where((i) => i.isNotEmpty)
              .toList();
        }
      }
      // A anotação sai do texto: ela é para o app, não para quem lê.
      texto = texto.replaceAll(_anotacao, '').replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (texto.isEmpty) continue;

      final comRealce =
          RegExp(r'^\*\*(.+?)\*\*\s*[:—–-]?\s*(.*)$', dotAll: true)
              .firstMatch(texto);
      if (comRealce != null) {
        itens.add((
          nome: comRealce.group(1)!.trim(),
          corpo: comRealce.group(2)!.trim(),
          lua: lua,
          ingredientes: ingredientes,
        ));
        continue;
      }
      final doisPontos = texto.indexOf(':');
      if (doisPontos > 0 && doisPontos < 80) {
        itens.add((
          nome: texto.substring(0, doisPontos).trim(),
          corpo: texto.substring(doisPontos + 1).trim(),
          lua: lua,
          ingredientes: ingredientes,
        ));
        continue;
      }
      itens.add((
        nome: '',
        corpo: texto,
        lua: lua,
        ingredientes: ingredientes,
      ));
    }
    if (itens.isEmpty) return null;
    return (cabecalho: cabecalho.join('\n').trim(), itens: itens);
  }

  /// A fase da lua pelo nome invariante que o prompt pede. Valor
  /// desconhecido (ou traduzido, contra o combinado) vira null: melhor sem
  /// lua do que com a lua errada.
  static MoonPhase? _luaDe(String valor) {
    final alvo = valor.trim().toLowerCase();
    for (final fase in MoonPhase.values) {
      if (fase.name.toLowerCase() == alvo) return fase;
    }
    return null;
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
    return ReadingMarkdown(
      // Sem o `# Título` de topo: a AppBar já o mostra, e repeti-lo dava o
      // título duplicado. O `_período_` (itálico) segue como subtítulo. Só
      // exibição — o conteúdo salvo no acervo é intacto.
      data,
      refine: (base) => base.copyWith(
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
        // O `strong` fica como a base do grimório o define: cor E peso.
        //
        // Aqui ele era sobrescrito para `FontWeight.normal` — cor sem peso.
        // Era literalmente o que a Leitura do Ciclo tinha de tímido perto do
        // Perfil Mágico, que recebeu negrito de verdade e ficou legível de
        // relance. As duas leituras agora falam a mesma língua.
        //
        // Junto vem o respiro entre blocos, o mesmo do Perfil: com parágrafos
        // colados, dois curtos voltam a parecer um só longo.
        blockSpacing: 18,
        // O destaque desta leitura é um cartão fechado, com borda inteira —
        // a barra à esquerda da base é para as leituras que deslizam.
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

  /// Remove o `# Título` inicial (a AppBar já o traz), preservando o resto —
  /// inclusive a linha `_período_` E as anotações dos rituais.
  ///
  /// As anotações ficam de propósito: elas são o que alimenta as pílulas de
  /// lua e de ingredientes dos cartõezinhos. Elas eram apagadas AQUI, antes
  /// de a seção chegar ao `_rituais` que as lê — então o código de extração
  /// existia, rodava e nunca produzia nada na tela. Quem tira as anotações
  /// agora é [_semAnotacoes], na hora de renderizar o texto.
  static String _semTitulo(String markdown) {
    final lines = markdown.split('\n');
    if (lines.isNotEmpty && lines.first.trimLeft().startsWith('# ')) {
      lines.removeAt(0);
      while (lines.isNotEmpty && lines.first.trim().isEmpty) {
        lines.removeAt(0);
      }
    }
    return lines.join('\n');
  }

  /// O texto como a pessoa lê: sem a anotação de máquina.
  ///
  /// Aplicado no RENDER, e não antes: assim o extrator dos cartões ainda
  /// encontra `[moon: ...]` e `[items: ...]` na seção original.
  static String _semAnotacoes(String texto) =>
      texto.replaceAll(_anotacao, '').replaceAll(RegExp(r'[ \t]{2,}'), ' ');

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
    // Último dia VIVIDO no cartão, como nas demais telas — o fim cru é
    // exclusivo e apontaria um dia fora da leitura.
    final periodLine = periodStart != null && periodEnd != null
        ? '${format.format(periodStart!)}–'
            '${format.format(CycleReadingService.lastDayOf(periodEnd!))}'
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
    this.lua,
    this.ingredientes = const [],
    this.periodo,
  });

  final String nome;
  final String corpo;

  /// Fase da lua sugerida (null quando a geração não anotou).
  final MoonPhase? lua;

  /// Ingredientes, já separados (vazio quando a geração não anotou).
  final List<String> ingredientes;

  /// Período lido, para a observação do feitiço (null ao abrir do acervo).
  final String? periodo;

  @override
  State<_CartaoDeRitual> createState() => _CartaoDeRitualState();
}

class _CartaoDeRitualState extends State<_CartaoDeRitual> {
  bool _salvo = false;
  bool _salvando = false;

  /// O feitiço recém-salvo, para o atalho "ver" logo ali.
  SpellModel? _feitico;

  /// Texto sem NENHUMA marcação: o feitiço vive no Grimório, onde o campo é
  /// texto puro — `**realce**` e `*itálico*` sairiam como asteriscos na
  /// ficha. Na leitura, ao contrário, a marcação é lida pelo Markdown.
  static String _textoPuro(String texto) =>
      CycleReadingService.semRealce(texto).replaceAll('*', '').trim();

  /// Guarda o ritual como feitiço — completo, como os outros do Grimório.
  ///
  /// A leitura sugere o ritual em duas frases, porque é uma LEITURA. Salvo
  /// assim, ele virava uma ficha pela metade: sem ingredientes e com um
  /// "como realizar" de uma linha, ao lado de feitiços com sete passos.
  ///
  /// Então o ritual volta para a geração de feitiços como intenção, e o que
  /// entra no Grimório tem ingredientes, passo a passo e duração. O nome e a
  /// intenção são preservados: nasceram do ciclo desta pessoa.
  ///
  /// Se a geração falhar (sem rede, limite da IA), salva do jeito simples —
  /// o que ela pediu foi guardar o ritual, e isso nunca pode falhar.
  Future<void> _salvar() async {
    if (_salvando || _salvo) return;
    setState(() => _salvando = true);
    final l10n = AppLocalizations.of(context);
    final provider = context.read<SpellProvider>();

    final nome = _textoPuro(
      widget.nome.isEmpty ? l10n.cycleReadingSectionRituals : widget.nome,
    );
    final corpo = _textoPuro(widget.corpo);
    final ingredientes = widget.ingredientes
        .map(_textoPuro)
        .where((i) => i.isNotEmpty)
        .toList();
    final origem = widget.periodo == null
        ? l10n.cycleReadingRitualPurpose
        : l10n.cycleReadingRitualFrom(widget.periodo!);

    final feitico = await _tecerFeitico(
      nome: nome,
      corpo: corpo,
      ingredientes: ingredientes,
      origem: origem,
      l10n: l10n,
    );

    await provider.addSpell(feitico);
    if (!mounted) return;
    setState(() {
      _feitico = feitico;
      _salvo = true;
      _salvando = false;
    });
  }

  /// O feitiço em si: detalhado pela IA quando dá, simples quando não dá.
  Future<SpellModel> _tecerFeitico({
    required String nome,
    required String corpo,
    required List<String> ingredientes,
    required String origem,
    required AppLocalizations l10n,
  }) async {
    // O que a leitura anotou entra na intenção: a fase escolhida a partir do
    // céu do período e os ingredientes que ela já sugeriu.
    final extras = StringBuffer();
    final lua = widget.lua;
    if (lua != null) {
      extras.write(' (${lua.displayName})');
    }
    if (ingredientes.isNotEmpty) {
      extras.write(' [${ingredientes.join('; ')}]');
    }

    try {
      final tecido = await AIService.instance.generateSpell(
        aiPrompts.cycleRitualToSpellIntention(nome, corpo, extras.toString()),
      );
      return tecido.copyWith(
        // O nome e o propósito vêm do ciclo dela, não de uma invenção nova.
        name: nome,
        category: SpellCategory.suggested,
        moonPhase: lua ?? tecido.moonPhase,
        ingredients:
            tecido.ingredients.isNotEmpty ? tecido.ingredients : ingredientes,
        // A origem vai junto das observações de segurança que a geração
        // escreve — as duas coisas interessam a quem for fazer o ritual.
        observations: [origem, tecido.observations ?? '']
            .where((t) => t.trim().isNotEmpty)
            .join('\n\n'),
      );
    } catch (_) {
      return SpellModel(
        name: nome,
        purpose: l10n.cycleReadingRitualPurpose,
        type: SpellType.attraction,
        category: SpellCategory.suggested,
        moonPhase: lua,
        ingredients: ingredientes,
        steps: corpo,
        observations: origem,
      );
    }
  }

  void _abrirFeitico() {
    final feitico = _feitico;
    if (feitico == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SpellDetailPage(spell: feitico)),
    );
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
          if (widget.lua != null || widget.ingredientes.isNotEmpty) ...[
            const SizedBox(height: 2),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (widget.lua != null)
                  _Pilula(
                    texto:
                        '${widget.lua!.emoji} ${widget.lua!.displayName}',
                    destaque: true,
                  ),
                for (final item in widget.ingredientes)
                  _Pilula(texto: _textoPuro(item)),
              ],
            ),
            const SizedBox(height: 10),
          ],
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
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: _abrirFeitico,
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        child: Text(l10n.numSee),
                      ),
                    ],
                  )
                : OutlinedButton.icon(
                    onPressed: _salvando ? null : _salvar,
                    icon: _salvando
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.gc.lilac,
                            ),
                          )
                        : const Icon(Icons.bookmark_add_outlined, size: 18),
                    label: Text(_salvando
                        ? l10n.cycleReadingRitualWeaving
                        : l10n.cycleReadingSaveRitual),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Etiqueta curta do cartão de ritual: a fase da lua (em destaque) e cada
/// ingrediente.
class _Pilula extends StatelessWidget {
  const _Pilula({required this.texto, this.destaque = false});

  final String texto;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final cor = destaque ? context.gc.starYellow : context.gc.lilac;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: cor.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cor),
      ),
    );
  }
}
