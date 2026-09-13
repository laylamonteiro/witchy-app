import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/ai/ai_service.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/motion/mist_typewriter.dart';
import '../../../../core/widgets/motion/tool_scene_frame.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../data/repositories/advisor_consultation_repository.dart';
import '../../domain/advisor_consultation.dart';
import '../widgets/advisor_feature_links.dart';
import '../widgets/advisor_mist_flight.dart';
import '../widgets/crystal_ball_view.dart';

import '../../../../core/widgets/motion/retry_notice.dart';
import '../../../../core/tools/tool_identity.dart';

/// Conselheiro Místico: responde perguntas sobre bruxaria, magia e misticismo
/// — e sobre o próprio app, sugerindo a ferramenta certa com o nome tocável.
///
/// Pergunta → resposta única. Ao consultar, o campo é limpo e a pergunta vira
/// citação; a espera é a da requisição real. Uma resposta que acaba de chegar
/// é escrita sob uma névoa que desce, com a tela rolando até ela; uma resposta
/// restaurada ao reabrir aparece inteira. Pode ser guardada em "Meus
/// Registros" uma vez. Trocar de conta recria a tela: a consulta pertence a
/// quem perguntou.
class MysticAdvisorPage extends StatelessWidget {
  const MysticAdvisorPage({super.key, this.ask});

  /// Transporte da pergunta; por padrão o serviço de IA. Injetável em testes.
  final Future<String> Function(String question)? ask;

  @override
  Widget build(BuildContext context) {
    final userId = context.select<AuthProvider, String>((auth) => auth.currentUser.id);
    return _AdvisorBody(key: ValueKey('advisor-$userId'), userId: userId, ask: ask);
  }
}

class _AdvisorBody extends StatefulWidget {
  const _AdvisorBody({super.key, required this.userId, this.ask});

  final String userId;
  final Future<String> Function(String question)? ask;

  @override
  State<_AdvisorBody> createState() => _AdvisorBodyState();
}

class _AdvisorBodyState extends State<_AdvisorBody> {
  final _questionController = TextEditingController();
  final _questionFocus = FocusNode();
  final _repository = AdvisorConsultationRepository();

  /// A consulta em cena: pendente, respondida ou falha. Null antes da
  /// primeira pergunta desta conta.
  AdvisorConsultation? _consultation;
  bool _saving = false;
  bool _restoring = true;

  /// A consulta cuja resposta chegou NESTA instância da tela: só ela é
  /// revelada com névoa e escrita. Restaurar nunca define isto.
  String? _revealId;

  /// O card de resposta, para rolar até ele quando a resposta chega, e a
  /// bola, de onde a névoa parte: o voo precisa dos dois retângulos.
  final _answerKey = GlobalKey();
  final _ballKey = GlobalKey();

  /// O bloco de texto da resposta: a névoa pousa no começo do primeiro
  /// parágrafo, não no meio do card.
  final _textKey = GlobalKey();

  /// A névoa está a caminho do card: o texto já está lá, todo transparente,
  /// e a escrita começa quando ela pousa.
  bool _flying = false;

  /// Uma resposta atrasada de outra consulta não substitui a atual.
  int _generation = 0;

  String get _userId => widget.userId;
  bool get _pending => _consultation?.status == AdvisorConsultationStatus.pending;

  @override
  void initState() {
    super.initState();
    _questionController.addListener(() => setState(() {}));
    unawaited(_restore());
  }

  /// Requisições em voo por consulta, compartilhadas entre instâncias da
  /// tela: sair e voltar durante a espera reencontra a mesma promessa, e a
  /// resposta aparece quando chega. Só uma consulta que ficou pendente num
  /// processo anterior vira falha, porque dela nada mais pode chegar.
  static final Map<String, Future<AdvisorConsultation?>> _inFlight = {};

  /// Ao abrir: a última resposta recebida volta sem nova chamada; uma
  /// consulta pendente sem requisição em voo aparece como falha, e só a
  /// pessoa decide tentar de novo.
  Future<void> _restore() async {
    try {
      var latest = await _repository.latest(_userId);
      final inFlight = latest == null ? null : _inFlight[latest.id];
      if (latest != null && latest.status == AdvisorConsultationStatus.pending &&
          inFlight == null) {
        latest = await _repository.fail(id: latest.id, userId: _userId) ?? latest;
      }
      if (!mounted) return;
      setState(() {
        _consultation = latest;
        _restoring = false;
      });
      if (inFlight != null) {
        final generation = _generation;
        try {
          await inFlight;
        } catch (_) {
          // The failure is already persisted; the reload below shows it.
        }
        final current = await _repository.byId(latest!.id, _userId);
        if (!mounted || generation != _generation || _consultation?.id != latest.id) return;
        setState(() => _consultation = current ?? _consultation);
      }
    } catch (_) {
      if (mounted) setState(() => _restoring = false);
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _questionFocus.dispose();
    super.dispose();
  }

  Future<void> _askAdvisor({String? repeat}) async {
    if (_pending || _saving) return;
    final question = (repeat ?? _questionController.text).trim();
    FocusScope.of(context).unfocus();
    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).advisorAskFirst),
        backgroundColor: context.gc.alert,
      ));
      _questionFocus.requestFocus();
      return;
    }

    final auth = context.read<AuthProvider>();
    if (!auth.currentUser.canUseAdvisor) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).advisorDailyLimit),
        backgroundColor: context.gc.alert,
        duration: const Duration(seconds: 4),
      ));
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const PremiumUpgradeSheet(),
      );
      return;
    }

    final generation = ++_generation;
    // A pergunta enviada vive na citação; o campo fica livre para a próxima.
    if (repeat == null) _questionController.clear();
    AdvisorConsultation consultation;
    try {
      consultation = await _repository.start(userId: _userId, question: question);
    } catch (_) {
      if (!mounted || generation != _generation) return;
      _showError(AppLocalizations.of(context).advisorGenericError);
      return;
    }
    if (!mounted || generation != _generation) return;
    setState(() => _consultation = consultation);

    final delivery = _deliver(consultation, auth);
    _inFlight[consultation.id] = delivery;
    Object? failure;
    AdvisorConsultation? delivered;
    try {
      delivered = await delivery;
    } catch (e) {
      failure = e;
    } finally {
      _inFlight.remove(consultation.id);
    }
    if (!mounted || generation != _generation) return;
    if (failure != null) {
      final failed = await _repository.byId(consultation.id, _userId);
      if (!mounted || generation != _generation) return;
      setState(() => _consultation = failed ?? consultation);
      _showError(_messageFor(failure, AppLocalizations.of(context)));
      return;
    }
    if (auth.currentUser.id == _userId) {
      // Anúncio ANTES de revelar a resposta (free, cooldown interno).
      await AdService.instance.showBeforeResult();
      if (!mounted || generation != _generation) return;
    }
    setState(() {
      _consultation = delivered ?? consultation;
      _revealId = consultation.id;
      _flying = true;
    });
    await _mistToAnswer(generation);
  }

  /// A chegada da resposta: a tela DESCE JUNTO com a névoa.
  ///
  /// Rolar primeiro e só então soltar a névoa escondia o voo — quando ele
  /// começava, a viagem já tinha acabado. Agora os dois partem no mesmo
  /// quadro: a página desce um pouco mais rápido, para assentar antes de a
  /// névoa pousar na primeira letra, e o voo mira o parágrafo por chave, que
  /// se move com a rolagem.
  Future<void> _mistToAnswer(int generation) async {
    await _nextFrame();
    if (!mounted || generation != _generation) return;
    await Future.wait([
      _scrollToAnswer(),
      AdvisorMistFlight.play(
        context: context,
        from: _ballKey,
        to: _textKey,
        // De dentro do cristal até a primeira letra do primeiro parágrafo.
        fromAnchor: const CrystalBallGeometry(120).sphereAnchor,
        toAnchor: Alignment.topLeft,
        toNudge: const Offset(10, 12),
      ),
    ]);
    if (!mounted || generation != _generation) return;
    setState(() => _flying = false);
  }

  /// O quadro em que o card de resposta já existe e foi medido.
  Future<void> _nextFrame() {
    final pronto = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) => pronto.complete());
    return pronto.future;
  }

  /// A tela rola até o cabeçalho "O Conselheiro responde", no tempo do voo.
  Future<void> _scrollToAnswer() async {
    final target = _answerKey.currentContext;
    if (!mounted || target == null) return;
    final reduced = GrimoireMotion.reduced(context);
    await Scrollable.ensureVisible(
      target,
      alignment: .05,
      duration: reduced ? Duration.zero : _scrollDuration,
      curve: Curves.easeInOutCubic,
    );
  }

  /// Um pouco menos que o voo: a página assenta e a névoa pousa em seguida.
  static const Duration _scrollDuration = Duration(milliseconds: 1500);

  /// A requisição real e o que ela persiste: independe da tela continuar
  /// montada. Sucesso grava a resposta e consome a cota; falha grava a
  /// falha e relança, para a tela mostrar a mensagem certa.
  Future<AdvisorConsultation?> _deliver(
      AdvisorConsultation consultation, AuthProvider auth) async {
    final ask = widget.ask ?? AIService.instance.answerMysticQuestion;
    try {
      final answer = await ask(consultation.question);
      final answered = await _repository.answer(
          id: consultation.id, userId: consultation.userId, answer: answer);
      if (auth.currentUser.id == consultation.userId) {
        try {
          await auth.incrementAdvisorConsultations();
        } catch (_) {
          // A provider torn down meanwhile must not turn a received answer
          // into a failure; the answer is already persisted.
        }
      }
      return answered;
    } catch (_) {
      await _repository.fail(id: consultation.id, userId: consultation.userId);
      rethrow;
    }
  }

  String _messageFor(Object e, AppLocalizations l10n) {
    final text = e.toString();
    if (text.contains('limit') || text.contains('quota') ||
        text.contains('usage') || text.contains('429')) {
      return l10n.advisorRateLimited;
    }
    if (text.contains('autenticação') || text.contains('authentication') ||
        text.contains('401')) {
      return l10n.advisorTempError;
    }
    if (text.contains('network') || text.contains('connection') ||
        text.contains('timeout')) {
      return l10n.advisorConnectionError;
    }
    if (text.contains('503')) return l10n.advisorPortalClosed;
    return l10n.advisorGenericError;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: context.gc.alert,
      duration: const Duration(seconds: 5),
    ));
  }

  /// "Guardar conselho": uma página por consulta; a confirmação só aparece
  /// depois que a gravação de fato aconteceu.
  Future<void> _save() async {
    final consultation = _consultation;
    if (consultation == null || !consultation.isAnswered || _saving) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      final saved = await _repository.save(
        consultation: consultation,
        title: l10n.advisorArchiveTitle,
        // A página guardada é texto plano: os marcadores de destaque saem.
        content: '✦ ${l10n.readingQuestionLabel}\n${consultation.question}'
            '\n\n✦ ${l10n.advisorAnswers}\n'
            '${stripAdvisorMarkers(consultation.answer ?? '')}',
      );
      if (!mounted || _consultation?.id != consultation.id) return;
      setState(() => _consultation = saved);
    } catch (_) {
      if (!mounted) return;
      _showError(l10n.advisorSaveError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final consultation = _consultation;
    return Scaffold(
      appBar: AppBar(
        title: ToolHeading(tool: ToolId.mysticAdvisor, title: l10n.profileMysticAdvisor),
        backgroundColor: context.gc.darkBackground,
      ),
      backgroundColor: context.gc.darkBackground,
      body: ToolSceneFrame(child: SingleChildScrollView(
        // Só o respiro de cima e de baixo: a margem lateral é do MagicalCard,
        // e somando as duas o conteúdo ficava a 32dp da borda — mais estreito
        // que o das ferramentas vizinhas, justo numa tela de texto longo.
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MagicalCard(
              child: Column(
                children: [
                  // A bola de cristal cede espaço ao teclado, vive o tempo
                  // todo e pulsa quando uma resposta chega.
                  KeyedSubtree(
                    key: _ballKey,
                    child: CrystalBallView(
                      key: const ValueKey('advisor-ball'),
                      size: keyboardOpen ? 64 : 120,
                      active: _pending,
                      pulseToken: _revealId,
                    ),
                  ),
                  if (!keyboardOpen) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.advisorWisdomTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: context.gc.lilac,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.advisorIntro,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.gc.softWhite.withValues(alpha: 0.8),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),

            MagicalCard(
              child: TextField(
                key: const ValueKey('advisor-question'),
                controller: _questionController,
                focusNode: _questionFocus,
                enabled: !_pending,
                style: TextStyle(color: context.gc.softWhite),
                decoration: InputDecoration(
                  hintText: l10n.advisorQuestionHint,
                  hintStyle: TextStyle(
                    color: context.gc.softWhite.withValues(alpha: 0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.gc.lilac),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: context.gc.lilac.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.gc.lilac),
                  ),
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),

            const SizedBox(height: 8),

            // O botão não é cartão: sem a margem lateral do MagicalCard, ele
            // encostaria na borda da tela.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                key: const ValueKey('advisor-consult'),
                onPressed: _pending || _restoring || _questionController.text.trim().isEmpty
                    ? null
                    : _askAdvisor,
                icon: _pending
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            context.gc.darkBackground,
                          ),
                        ),
                      )
                    : const Icon(Icons.auto_stories),
                label: Text(_pending ? l10n.advisorConsultingStars : l10n.advisorConsult),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.gc.lilac,
                  foregroundColor: context.gc.darkBackground,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  disabledBackgroundColor: context.gc.lilac.withValues(alpha: 0.3),
                ),
              ),
            ),

            // Exibir consultas restantes para usuários free
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                if (authProvider.isPremium) return const SizedBox.shrink();
                final remaining =
                    authProvider.currentUser.remainingAdvisorConsultations;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Text(
                    l10n.advisorRemainingToday('$remaining/${UserModel.freeAdvisorConsultationsLimit}'),
                    style: TextStyle(
                      color: remaining > 0
                          ? context.gc.softWhite.withValues(alpha: 0.6)
                          : context.gc.alert,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),

            if (consultation != null) ...[
              const SizedBox(height: 8),
              // A pergunta enviada vira citação: é exatamente o texto que a
              // operação usou, mesmo que o campo mude depois.
              AnimatedSwitcher(
                duration: GrimoireMotion.reduced(context) ? Duration.zero : GrimoireMotion.state,
                child: MagicalCard(
                  key: ValueKey('advisor-quote-${consultation.id}'),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.format_quote, color: context.gc.lilac, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(
                        consultation.question,
                        style: TextStyle(
                          color: context.gc.softWhite.withValues(alpha: .85),
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              switch (consultation.status) {
                AdvisorConsultationStatus.pending => _PendingCard(l10n: l10n),
                AdvisorConsultationStatus.failed => _FailedCard(
                    key: ValueKey('advisor-failed-${consultation.id}'),
                    l10n: l10n,
                    onRetry: () => _askAdvisor(repeat: consultation.question),
                  ),
                AdvisorConsultationStatus.answered => _AnswerCard(
                    key: _answerKey,
                    l10n: l10n,
                    answerId: consultation.id,
                    answer: consultation.answer ?? '',
                    reveal: _revealId == consultation.id,
                    started: !_flying,
                    textKey: _textKey,
                    saved: consultation.isSaved,
                    saving: _saving,
                    onSave: _save,
                  ),
              },
            ],
          ],
        ),
      )),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => MagicalCard(
    child: Semantics(
      liveRegion: true,
      child: Text(
        l10n.advisorConsultingStars,
        textAlign: TextAlign.center,
        style: TextStyle(color: context.gc.textSecondary),
      ),
    ),
  );
}

class _FailedCard extends StatelessWidget {
  const _FailedCard({super.key, required this.l10n, required this.onRetry});
  final AppLocalizations l10n;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => RetryNotice(
        retryKey: const ValueKey('advisor-retry'),
        message: l10n.advisorPendingNote,
        retryLabel: l10n.advisorRetry,
        onRetry: onRetry,
      );
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    super.key,
    required this.l10n,
    required this.answerId,
    required this.answer,
    required this.reveal,
    required this.started,
    required this.textKey,
    required this.saved,
    required this.saving,
    required this.onSave,
  });

  final AppLocalizations l10n;
  final String answerId;
  final String answer;

  /// Escrever letra a letra (resposta que acabou de chegar) ou mostrar
  /// inteira (resposta restaurada).
  final bool reveal;

  /// A névoa já pousou? Até pousar, o texto espera transparente.
  final bool started;

  /// Marca o bloco de texto para o voo da névoa saber onde pousar.
  final Key? textKey;
  final bool saved;
  final bool saving;
  final VoidCallback onSave;

  /// A resposta em trechos: corpo comum e os nomes de funcionalidades que o
  /// Conselheiro destacou entre `**`, em lilás e negrito — tocáveis quando o
  /// catálogo conhece o destino; só realce quando não conhece.
  List<RevealSpan> _spans(BuildContext context) {
    final catalog = AdvisorFeatureCatalog.of(l10n);
    final lilac = context.gc.lilac;
    return [
      for (final part in parseAdvisorAnswer(answer))
        if (!part.realce)
          RevealSpan(part.texto)
        else
          _highlight(context, catalog.match(part.texto), part.texto, lilac),
    ];
  }

  RevealSpan _highlight(
      BuildContext context, AdvisorFeature? feature, String text, Color lilac) {
    return RevealSpan(
      text,
      style: TextStyle(
        color: lilac,
        fontWeight: FontWeight.w700,
        decoration: feature == null ? null : TextDecoration.underline,
        decorationStyle: TextDecorationStyle.dotted,
        decorationColor: lilac,
      ),
      onTap: feature == null ? null : () => feature.open(context),
      semanticsLabel: feature == null ? null : l10n.advisorOpenFeature(text),
    );
  }

  @override
  Widget build(BuildContext context) => MagicalCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // 🌙 é o emblema dos Sonhos: o cabeçalho da resposta mostrava o
            // símbolo de outra ferramenta bem em cima da palavra
            // 'Conselheiro'. O emblema vem do ToolIdentity, que é o mesmo
            // lugar de onde saem o card do hub e a AppBar desta tela.
            const ToolEmblem(
                tool: ToolId.mysticAdvisor, size: 28, flies: false),
            const SizedBox(width: 12),
            // O título é traduzido: em telas estreitas ele quebra a linha
            // em vez de estourar o cartão.
            Expanded(
              child: Text(
                l10n.advisorAnswers,
                style: TextStyle(
                  color: context.gc.lilac,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Uma consulta nova é um widget novo (a chave leva o id): a escrita
        // recomeça para cada resposta que chega.
        MistTypewriterText(
          key: ValueKey('advisor-typewriter-$answerId'),
          spans: _spans(context),
          style: TextStyle(
            color: context.gc.softWhite.withValues(alpha: 0.9),
            fontSize: 15,
            height: 1.5,
          ),
          reveal: reveal,
          started: started,
          textKey: textKey,
          skipLabel: l10n.advisorShowAll,
          skipKey: const ValueKey('advisor-show-all'),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: saved
              ? Row(
                  key: const ValueKey('advisor-saved'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bookmark_added, color: context.gc.gold, size: 18),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(l10n.advisorSaved,
                          style: TextStyle(color: context.gc.gold)),
                    ),
                  ],
                )
              : TextButton.icon(
                  key: const ValueKey('advisor-save'),
                  onPressed: saving ? null : onSave,
                  icon: saving
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.bookmark_add_outlined),
                  label: Text(l10n.advisorSave),
                ),
        ),
      ],
    ),
  );
}
