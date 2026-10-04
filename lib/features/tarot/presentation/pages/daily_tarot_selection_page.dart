import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/divination/regra_da_tiragem.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/campo_da_pergunta.dart';
import '../../../../core/widgets/motion/tool_scene_frame.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../divination/presentation/widgets/card_selection_surface.dart';
import '../../domain/daily_tarot_session.dart';

/// Escolhe a Carta do Dia — e é aqui que a pergunta dela é escrita.
///
/// A caixa é a mesma das outras mesas, e por um motivo: a pergunta é parte do
/// gesto de tirar, não um formulário antes dele. O que muda é o que o aviso
/// diz. A Carta do Dia não custa nada e é UMA por dia, então ela nunca fala de
/// cota e o leque nunca se desliga — fala do que surpreenderia quem escrevesse
/// outra pergunta esperando outra carta: a carta de hoje é uma só, e a
/// pergunta muda a leitura, não a carta.
class DailyTarotSelectionPage extends StatefulWidget {
  const DailyTarotSelectionPage({
    super.key,
    required this.session,
    required this.onCommit,
    required this.aoEscreverPergunta,
  });

  final DailyTarotSession session;
  final Future<DailyTarotCommit> Function(String cardId) onCommit;

  /// Grava o rascunho da pergunta. Chamado com atraso, não a cada tecla.
  final Future<void> Function(String pergunta) aoEscreverPergunta;

  @override
  State<DailyTarotSelectionPage> createState() => _DailyTarotSelectionPageState();
}

class _DailyTarotSelectionPageState extends State<DailyTarotSelectionPage> {
  bool _saving = false;
  bool _error = false;
  bool _quotaError = false;
  String? _pendingId;

  // O nó do foco pertence à PÁGINA, nunca à caixa: com um nó interno, uma
  // reconstrução leva o foco junto e o teclado fecha sozinho no Android.
  final _pergunta = TextEditingController();
  final _focoDaPergunta = FocusNode(debugLabel: 'daily card question');
  Timer? _gravacaoDoRascunho;

  @override
  void initState() {
    super.initState();
    _pendingId = widget.session.selectedId;
    _pergunta.text = widget.session.question;
    _pergunta.addListener(_aoDigitar);
  }

  @override
  void dispose() {
    _gravacaoDoRascunho?.cancel();
    _pergunta.dispose();
    _focoDaPergunta.dispose();
    super.dispose();
  }

  void _aoDigitar() {
    // Gravar a cada tecla seria um INSERT por letra. Meio segundo de silêncio
    // basta, e a escolha da carta força a gravação antes de fechar a mesa.
    if (_saving) return;
    _gravacaoDoRascunho?.cancel();
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

  Widget _campo(AppLocalizations l10n) => CampoDaPergunta(
        controller: _pergunta,
        focusNode: _focoDaPergunta,
        rotulo: l10n.tarotQuestionLabel,
        dica: l10n.cartaDoDiaQuestionHint,
        // `livre` só porque a caixa exige uma situação; quem manda no aviso é
        // `avisoForaDaCota`, e aqui não há cota nenhuma em jogo.
        situacao: SituacaoDaTiragem.livre,
        mostrarCota: false,
        avisoForaDaCota: true,
        textoDoAviso: l10n.perguntaAjudaCartaDoDia,
        habilitado: !_saving && !widget.session.isCommitted,
      );

  Future<void> _select(String cardId) async {
    if (_saving) return;
    // `_saving` ANTES de esperar a gravação: ele é o que desliga o campo e o
    // que faz `_aoDigitar` parar de rearmar o atraso. Sem isso, uma tecla
    // digitada durante o await poderia gravar DEPOIS de a leitura já ter
    // copiado a pergunta, e a mesa citaria um texto escrito depois da carta.
    setState(() => _saving = true);
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
      final result = await widget.onCommit(_pendingId!);
      if (!mounted) return;
      if (context.read<AuthProvider>().currentUser.id != widget.session.userId) return;
      Navigator.of(context).pop(result);
      leaving = true;
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
    if (userId != widget.session.userId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
          Navigator.of(context).pop();
        }
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    final l10n = AppLocalizations.of(context);
    final dayParts = widget.session.dayKey.split('-').map(int.parse).toList();
    final day = DateTime(dayParts[0], dayParts[1], dayParts[2]);
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.tarotDailyCard)),
        body: ToolSceneFrame(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _campo(l10n),
                  const SizedBox(height: 4),
                  // A data é o que identifica esta carta — ela é DO DIA, e a
                  // pergunta não entra nessa identidade.
                  Text(l10n.cardSelectionDay(
                      MaterialLocalizations.of(context).formatMediumDate(day)),
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 20),
                  Text(l10n.cardSelectionTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  CardSelectionSurface(
                    cardIds: widget.session.deck.map((c) => c.id).toList(),
                    enabled: !_saving,
                    lockedCardId: _pendingId,
                    onSelected: _select,
                  ),
                  if (_saving || _error) const SizedBox(height: 16),
                  if (_saving) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: 8),
                    Semantics(liveRegion: true,
                        child: Text(l10n.cardSelectionSaving, textAlign: TextAlign.center)),
                  ] else if (_error)
                    Semantics(liveRegion: true,
                      child: Text(_quotaError ? l10n.tarotFreeLimitReached : l10n.cardSelectionError,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.gc.alert)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
