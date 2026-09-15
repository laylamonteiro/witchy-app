import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/divination/contexto_da_tiragem.dart';
import '../../../../core/divination/regra_da_tiragem.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/campo_da_pergunta.dart';
import '../../../../core/widgets/motion/tool_scene_frame.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../divination/presentation/widgets/card_selection_surface.dart';
import '../../../divination/presentation/widgets/spread_board.dart';
import '../../domain/daily_tarot_session.dart';
import '../../domain/tarot_spread_session.dart';
import '../widgets/tarot_card_view.dart';

/// Escolhe cada carta da mesa — e é aqui que a pergunta é escrita.
///
/// A pergunta vive em cima da mesa e continua editável enquanto a pessoa
/// escolhe: ela é parte do gesto de tirar, não um formulário antes dele. O
/// aviso do que aquela pergunta custa fica logo abaixo dela, e o leque se
/// desliga quando não há mais tiragem — nunca se escolhe uma carta para só
/// então descobrir que não podia.
class TarotSpreadSelectionPage extends StatefulWidget {
  const TarotSpreadSelectionPage({
    super.key,
    required this.session,
    required this.title,
    required this.positionLabels,
    required this.onSelect,
    required this.contexto,
    required this.premium,
    required this.aoEscreverPergunta,
  });

  final TarotSpreadSession session;
  final String title;
  final List<String> positionLabels;
  final Future<TarotSpreadUpdate> Function(String cardId, int expectedCount) onSelect;

  /// O que a tela precisa para avisar, antes da escolha, o que a pergunta
  /// custa. Carregado uma vez por quem abriu a página.
  final ContextoDaTiragem contexto;
  final bool premium;

  /// Grava o rascunho da pergunta. Chamado com atraso, não a cada tecla.
  final Future<void> Function(String pergunta) aoEscreverPergunta;

  @override
  State<TarotSpreadSelectionPage> createState() => _TarotSpreadSelectionPageState();
}

class _TarotSpreadSelectionPageState extends State<TarotSpreadSelectionPage> {
  late TarotSpreadSession _session = widget.session;
  bool _saving = false;
  bool _error = false;
  bool _quotaError = false;
  String? _pendingId;

  late final TextEditingController _pergunta =
      TextEditingController(text: _session.question);
  // O nó vive no State, nunca dentro do TextField: uma reconstrução que
  // re-infla a subárvore levaria o foco junto, e o teclado fecharia sozinho.
  final _focoDaPergunta = FocusNode(debugLabel: 'tarot table question');
  Timer? _gravacaoDoRascunho;

  @override
  void dispose() {
    _gravacaoDoRascunho?.cancel();
    _pergunta.removeListener(_aoDigitar);
    _pergunta.dispose();
    _focoDaPergunta.dispose();
    super.dispose();
  }

  void _aoDigitar() {
    setState(() {});
    _gravacaoDoRascunho?.cancel();
    // Meio segundo depois da última tecla: gravar a cada letra encheria o
    // banco de escritas por uma frase que ainda está sendo pensada.
    _gravacaoDoRascunho = Timer(const Duration(milliseconds: 500), () {
      widget.aoEscreverPergunta(_pergunta.text);
    });
  }

  /// Grava o que estiver escrito AGORA, sem esperar o atraso. Vai antes de
  /// qualquer escolha: a carta fecha a mesa, e a mesa cita a pergunta.
  Future<void> _fixarPergunta() async {
    _gravacaoDoRascunho?.cancel();
    await widget.aoEscreverPergunta(_pergunta.text);
  }

  SituacaoDaTiragem get _situacao =>
      widget.contexto.situacaoDe(_pergunta.text, premium: widget.premium);

  bool get _lequeLigado =>
      _situacao != SituacaoDaTiragem.semCota &&
      _situacao != SituacaoDaTiragem.jaFeita;

  String? _avisoDe(AppLocalizations l10n) => switch (_situacao) {
        SituacaoDaTiragem.livre =>
          widget.contexto.perguntaDoDia == null ? null : l10n.perguntaAjudaLivre,
        SituacaoDaTiragem.gastaUma => l10n.perguntaAjudaGastaUma,
        SituacaoDaTiragem.semCota => l10n.perguntaAjudaSemCota,
        SituacaoDaTiragem.jaFeita => l10n.perguntaAjudaJaFeita,
      };

  Widget _campo(AppLocalizations l10n) {
    final voltar = widget.contexto.perguntaDeHojeNoCampo;
    final podeVoltar = _situacao == SituacaoDaTiragem.semCota && voltar != null;
    return CampoDaPergunta(
      controller: _pergunta,
      focusNode: _focoDaPergunta,
      rotulo: l10n.tarotQuestionLabel,
      dica: l10n.tarotQuestionHint,
      situacao: _situacao,
      mostrarCota: !widget.premium,
      textoDoAviso: _avisoDe(l10n),
      habilitado: !_saving && !_session.isCommitted,
      rotuloDoAtalho: podeVoltar ? l10n.perguntaVoltarParaHoje : null,
      aoUsarOAtalho: podeVoltar ? () => _pergunta.text = voltar : null,
    );
  }

  @override
  void initState() {
    super.initState();
    // Redesenha o aviso a cada tecla — a avaliação é pura e síncrona, então
    // não custa banco nenhum. Gravar o rascunho, isso sim, espera.
    _pergunta.addListener(_aoDigitar);
    // Recover a process stopped after the last choice but before its commit.
    if (_session.isComplete && !_session.isCommitted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _select(_session.selectedIds.last);
      });
    }
  }

  Future<void> _select(String cardId) async {
    if (_saving) return;
    // A carta fecha a mesa, e a mesa cita a pergunta: o que está escrito agora
    // tem de estar no banco antes da escolha, não meio segundo depois.
    await _fixarPergunta();
    if (!mounted) return;
    setState(() {
      _pendingId ??= cardId;
      _saving = true;
      _error = false;
      _quotaError = false;
    });
    var leaving = false;
    try {
      final update = await widget.onSelect(_pendingId!, _session.selectedIds.length);
      if (!mounted || context.read<AuthProvider>().currentUser.id != _session.userId) return;
      if (update.session.isCommitted) {
        Navigator.of(context).pop(update);
        leaving = true;
      } else {
        setState(() { _session = update.session; _pendingId = null; });
      }
    } on TarotQuotaExceeded {
      if (mounted) setState(() { _error = true; _quotaError = true; });
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted && !leaving) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.select<AuthProvider, String>((auth) => auth.currentUser.id);
    if (userId != _session.userId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) Navigator.of(context).pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    final l10n = AppLocalizations.of(context);
    final selected = _session.selectedIds;
    final available = [for (var i = 0; i < _session.deck.length; i++)
      if (!selected.contains(_session.deck[i].id)) i];
    final parts = _session.dayKey.split('-').map(int.parse).toList();
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: ToolSceneFrame(child: SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _campo(l10n),
            const SizedBox(height: 4),
            Text(l10n.cardSelectionDay(MaterialLocalizations.of(context)
                .formatMediumDate(DateTime(parts[0], parts[1], parts[2]))),
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            SpreadBoard(
              labels: widget.positionLabels, cross: _session.spread == 'cross', compact: true,
              nextPosition: selected.length,
              cardBuilder: (i, width) => i < selected.length
                  ? TarotCardBack(key: ValueKey('spread-selected-$i'), width: width,
                      deckPosition: _session.positionOf(selected[i])) : null,
            ),
            const SizedBox(height: 12),
            Semantics(liveRegion: true, child: Text(
              _session.isComplete
                  ? l10n.tarotSelectionReady
                  : l10n.tarotSelectionStep(selected.length + 1, _session.cardCount,
                      widget.positionLabels[selected.length]),
              textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium,
            )),
            if (!_session.isComplete) ...[
              const SizedBox(height: 8),
              CardSelectionSurface(
                cardIds: [for (final i in available) _session.deck[i].id],
                deckPositions: available,
                // Desligado quando a pergunta não tem tiragem: é isto que
                // impede escolher a carta e só então levar o não.
                enabled: !_saving && _lequeLigado,
                lockedCardId: _pendingId,
                onSelected: _select,
              ),
            ] else if (!_saving)
              FilledButton.icon(
                key: const ValueKey('spread-retry'),
                onPressed: () => _select(selected.last),
                icon: const Icon(Icons.refresh), label: Text(l10n.cardSelectionRetry),
              ),
            if (_saving) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
              Text(l10n.cardSelectionSaving, textAlign: TextAlign.center),
            ],
            if (_error) ...[
              const SizedBox(height: 12),
              Semantics(liveRegion: true, child: Text(
                _quotaError ? l10n.tarotFreeLimitReached : l10n.tarotSelectionSaveError,
                textAlign: TextAlign.center, style: TextStyle(color: context.gc.alert),
              )),
            ],
          ]),
        ))),
      ),
    );
  }
}
