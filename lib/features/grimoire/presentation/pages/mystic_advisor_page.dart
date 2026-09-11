import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/ai/ai_service.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/motion/staggered_paragraphs.dart';
import '../../../../core/widgets/motion/tool_scene_frame.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../data/repositories/advisor_consultation_repository.dart';
import '../../domain/advisor_consultation.dart';
import '../widgets/crystal_ball_view.dart';
import '../../../../core/widgets/motion/retry_notice.dart';

/// Conselheiro Místico: responde perguntas sobre bruxaria, magia e misticismo.
///
/// Pergunta → resposta única. A espera é a da requisição real (a bola de
/// cristal enevoa enquanto ela dura); a resposta entra em parágrafos, sem
/// atraso artificial, e pode ser guardada em "Meus Registros" uma vez.
/// Trocar de conta recria a tela: a consulta pertence a quem perguntou.
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
    setState(() => _consultation = delivered ?? consultation);
  }

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
        content: '✦ ${l10n.readingQuestionLabel}\n${consultation.question}'
            '\n\n✦ ${l10n.advisorAnswers}\n${consultation.answer}',
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
        title: ResponsiveAppBarTitle(l10n.profileMysticAdvisor),
        backgroundColor: context.gc.darkBackground,
      ),
      backgroundColor: context.gc.darkBackground,
      body: ToolSceneFrame(child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MagicalCard(
              child: Column(
                children: [
                  // A bola de cristal cede espaço ao teclado e enevoa só
                  // enquanto a requisição real dura.
                  CrystalBallView(
                    key: const ValueKey('advisor-ball'),
                    size: keyboardOpen ? 64 : 120,
                    active: _pending,
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

            const SizedBox(height: 16),

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

            const SizedBox(height: 16),

            ElevatedButton.icon(
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

            // Exibir consultas restantes para usuários free
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                if (authProvider.isPremium) return const SizedBox.shrink();
                final remaining =
                    authProvider.currentUser.remainingAdvisorConsultations;
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
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
              const SizedBox(height: 24),
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
              const SizedBox(height: 12),
              switch (consultation.status) {
                AdvisorConsultationStatus.pending => _PendingCard(l10n: l10n),
                AdvisorConsultationStatus.failed => _FailedCard(
                    key: ValueKey('advisor-failed-${consultation.id}'),
                    l10n: l10n,
                    onRetry: () => _askAdvisor(repeat: consultation.question),
                  ),
                AdvisorConsultationStatus.answered => _AnswerCard(
                    key: ValueKey('advisor-answer-${consultation.id}'),
                    l10n: l10n,
                    answer: consultation.answer ?? '',
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
    required this.answer,
    required this.saved,
    required this.saving,
    required this.onSave,
  });

  final AppLocalizations l10n;
  final String answer;
  final bool saved;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => MagicalCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🌙', style: TextStyle(fontSize: 28)),
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
        StaggeredParagraphs(
          text: answer,
          style: TextStyle(
            color: context.gc.softWhite.withValues(alpha: 0.9),
            fontSize: 15,
            height: 1.5,
          ),
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
