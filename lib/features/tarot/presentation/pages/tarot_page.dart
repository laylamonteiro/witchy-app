import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/ai/ai_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/repositories/daily_tarot_repository.dart';
import '../../data/repositories/tarot_day_repository.dart';
import '../../domain/daily_tarot_session.dart';
import '../../domain/tarot_spread_session.dart';
import '../../data/repositories/tarot_spread_repository.dart';
import '../../../divination/presentation/widgets/spread_board.dart';
import 'tarot_spread_selection_page.dart';
import 'daily_tarot_selection_page.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../your_day/presentation/providers/daily_checkin_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../data/data_sources/tarot_cards_data.dart';
import '../../data/models/tarot_card_model.dart';
import '../../data/repositories/tarot_reading_repository.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/data/services/reading_archive_composer.dart';
import '../../../diary/data/services/reading_archive_recorder.dart';
import '../widgets/tarot_card_view.dart';
import 'tarot_learn_tab.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/widgets/premium_locked_preview.dart';

/// Tarot: tiragens com significados + tutor de aprendizado.
class TarotPage extends StatefulWidget {
  const TarotPage({super.key});

  @override
  State<TarotPage> createState() => _TarotPageState();
}

class _TarotPageState extends State<TarotPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).toolTarotTitle),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: context.gc.lilac,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          labelPadding: const EdgeInsets.symmetric(horizontal: 24),
          tabs: [
            Tab(text: AppLocalizations.of(context).tarotTabDraw),
            Tab(text: AppLocalizations.of(context).tarotTabLearn),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SpreadTab(key: ValueKey(context.select<AuthProvider, String>(
              (auth) => auth.currentUser.id))),
          const TarotLearnTab(),
        ],
      ),
    );
  }
}

/// Tipos de tiragem disponíveis.
enum TarotSpread { daily, threeCards, cross }

extension TarotSpreadX on TarotSpread {
  String displayName(AppLocalizations l10n) => switch (this) {
        TarotSpread.daily => l10n.tarotDailyCard,
        TarotSpread.threeCards => l10n.tarotThreeCards,
        TarotSpread.cross => l10n.tarotCross,
      };

  String description(AppLocalizations l10n) => switch (this) {
        TarotSpread.daily => l10n.tarotDailyDesc,
        TarotSpread.threeCards => l10n.tarotThreeDesc,
        TarotSpread.cross => l10n.tarotCrossDesc,
      };

  String get emoji => switch (this) {
        TarotSpread.daily => '🌞',
        TarotSpread.threeCards => '🔮',
        TarotSpread.cross => '✚',
      };

  List<String> positions(AppLocalizations l10n) => switch (this) {
        TarotSpread.daily => [l10n.tarotDailyCard],
        TarotSpread.threeCards => [
            l10n.tarotPosPast,
            l10n.tarotPosPresent,
            l10n.tarotPosFuture,
          ],
        TarotSpread.cross => [
            l10n.tarotPosSituation,
            l10n.tarotPosChallenge,
            l10n.tarotPosRoot,
            l10n.tarotPosAdvice,
            l10n.tarotPosTendency,
          ],
      };
}

class _SpreadTab extends StatefulWidget {
  const _SpreadTab({super.key});

  @override
  State<_SpreadTab> createState() => _SpreadTabState();
}

class _SpreadTabState extends State<_SpreadTab>
    with WidgetsBindingObserver {
  TarotSpread? _activeSpread;
  List<TarotDrawnCard> _drawn = [];
  bool _revealed = false;
  bool _starting = false;
  String? _activeReadingSignature;
  List<int> _backPositions = [];
  DateTime? _activeReadingDate;
  bool _newSpreadRequested = false;
  final _spreadRepository = TarotSpreadRepository();
  final _dailyRepository = DailyTarotRepository();

  /// Pergunta de quem consulta — obrigatória, capturada ao iniciar a
  /// tiragem. O foco volta para cá quando alguém tenta tirar sem perguntar.
  final _questionController = TextEditingController();
  final _questionFocus = FocusNode();
  String _question = '';

  /// O que foi posto no campo por esta tela (a pergunta de hoje) e em que
  /// dia. Quando o dia vira com a tela aberta, o campo só é limpo se ainda
  /// mostrar exatamente isto — o que a pessoa digitou por conta própria fica.
  String? _perguntaPreenchida;
  String? _diaPreenchido;

  String? _aiReading;
  bool _isReadingAI = false;

  late final String _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _userId = context.read<AuthProvider>().currentUser.id;
    _carregarPerguntaDoDia();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _questionController.dispose();
    _questionFocus.dispose();
    super.dispose();
  }

  /// Voltou do segundo plano: se o dia virou, a pergunta de ontem sai do
  /// campo (e a de hoje, se já houver, entra).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _carregarPerguntaDoDia();
  }

  /// A identidade da sessão também distingue consultas com cartas iguais.
  String _signature(TarotSpread spread, List<TarotDrawnCard> drawn) {
    if (_activeReadingSignature != null) {
      return _activeReadingSignature!;
    }
    // Usa (naipe, número) — chaves estáveis entre idiomas — para que a
    // interpretação salva sobreviva à troca de idioma do app.
    // Inclui a pergunta: outra pergunta sobre as mesmas cartas gera outra
    // interpretação (não reaproveita o cache).
    return '${spread.name}|'
        '${drawn.map((d) => '${d.card.suit.name}${d.card.number}:${d.isReversed ? 'R' : 'U'}').join('|')}'
        '|q:${_question.toLowerCase()}';
  }

  /// Interpretação salva para exatamente esta assinatura (ou null).
  Future<String?> _savedReadingFor(String signature) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('tarot_sig_$_userId') == signature) {
      return prefs.getString('tarot_ai_$_userId');
    }
    return null;
  }

  Future<void> _persistReading(String signature, String reading) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tarot_sig_$_userId', signature);
    await prefs.setString('tarot_ai_$_userId', reading);
  }

  /// Chave do dia de hoje, para lembrar a última pergunta da carta do dia.
  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  /// Ao abrir (e ao voltar do segundo plano): a pergunta de hoje volta ao
  /// campo; a de ontem, não. Se o dia virou com a tela aberta e o campo
  /// ainda mostra o que foi preenchido, limpa — o que a pessoa digitou fica.
  Future<void> _carregarPerguntaDoDia() async {
    TarotDayState state;
    try {
      state = await TarotDayRepository().read(_userId, DateTime.now());
    } catch (_) {
      return; // A failed draft lookup must not overwrite typed text.
    }
    if (!mounted) return;
    final hoje = _todayKey();
    final deHoje = state.lastQuestion;
    final campo = _questionController.text;
    if (deHoje != null) {
      if (campo.isEmpty || campo == _perguntaPreenchida) {
        _questionController.text = deHoje;
      }
    } else if (_diaPreenchido != null &&
        _diaPreenchido != hoje &&
        campo == _perguntaPreenchida) {
      _questionController.clear();
    }
    _perguntaPreenchida = deHoje;
    _diaPreenchido = hoje;
  }

  Future<void> _startSpread(TarotSpread spread) async {
    if (_starting) return;
    setState(() => _starting = true);
    try {
      if (spread == TarotSpread.daily) {
        await _startDailySpread();
      } else {
        await _startManualSpread(spread);
      }
    } on TarotQuotaExceeded {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).tarotFreeLimitReached)));
      await showModalBottomSheet<void>(context: context,
          isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (_) => const PremiumUpgradeSheet());
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).cardSelectionLoadError)));
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _startDailySpread() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).tarotQuestionRequired)));
      _questionFocus.requestFocus();
      return;
    }
    final auth = context.read<AuthProvider>();
    await auth.refreshOracleUsage();
    if (!mounted || auth.currentUser.id != _userId) return;
    final session = await _dailyRepository.prepare(
      userId: _userId,
      question: question,
      catalog: tarotCards,
      premium: auth.isPremiumEffective,
      legacyOracleUsed: auth.currentUser.oracleReadingsToday,
      freeLimit: UserModel.freeOracleReadingsLimit,
    );
    if (!mounted || auth.currentUser.id != _userId) return;
    _questionFocus.unfocus();
    final position = AppLocalizations.of(context).tarotDailyCard;
    DailyTarotCommit? result;
    if (session.isCommitted) {
      result = DailyTarotCommit(session, created: false);
    } else {
      final selectionRoute = MaterialPageRoute<DailyTarotCommit>(
        builder: (_) => DailyTarotSelectionPage(
          session: session,
          onCommit: (cardId) => _dailyRepository.selectAndCommit(
            userId: _userId,
            sessionId: session.id,
            cardId: cardId,
            catalog: tarotCards,
            positionLabel: position,
            isCurrentUser: () => mounted && auth.currentUser.id == _userId,
            isPremium: () => auth.isPremiumEffective,
            freeLimit: UserModel.freeOracleReadingsLimit,
          ),
        ),
      );
      result = await Navigator.of(context).push(selectionRoute);
      // push completes when pop starts. Wait for the overlay to leave so
      // the result's flip is visible from its first frame.
      await selectionRoute.completed;
    }
    if (!mounted || result == null || auth.currentUser.id != _userId) return;
    final committedResult = result;
    final completed = committedResult.session;
    final entry = completed.card(completed.selectedId!);
    final card = tarotCards.firstWhere((c) => c.id == entry.id);
    final saved = await _dailyRepository.interpretation(completed) ??
        await _savedReadingFor(completed.resultSignature!);
    await auth.refreshOracleUsage();
    if (!mounted || auth.currentUser.id != _userId) return;
    await precacheImage(AssetImage(card.assetPath(TarotDeck.riderWaite)), context,
        onError: (Object error, StackTrace? stack) {});
    if (!mounted || auth.currentUser.id != _userId) return;
    final reduced = GrimoireMotion.reduced(context);
    setState(() {
      _activeSpread = TarotSpread.daily;
      _activeReadingSignature = completed.resultSignature;
      _backPositions = [completed.deck.indexWhere(
          (entry) => entry.id == completed.selectedId)];
      _activeReadingDate = completed.dayStart;
      _newSpreadRequested = false;
      _question = completed.question;
      _drawn = [TarotDrawnCard(card: card, isReversed: entry.reversed,
          positionLabel: AppLocalizations.of(context).tarotDailyCard)];
      _revealed = reduced || !committedResult.created;
      _aiReading = saved;
    });
    unawaited(_registrarMesa(
      spread: TarotSpread.daily,
      spreadLabel: position,
      drawn: _drawn,
      question: completed.question,
      interpretation: saved,
      readingDate: completed.dayStart,
    ));
    if (committedResult.created) {
      unawaited(context.read<DailyCheckinProvider>().completeRite(DailyRites.divination));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _activeReadingSignature != completed.resultSignature) return;
        setState(() => _revealed = true);
      });
    }
  }

  Future<void> _startManualSpread(TarotSpread spread) async {
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).tarotQuestionRequired)));
      _questionFocus.requestFocus();
      return;
    }
    final auth = context.read<AuthProvider>();
    await auth.refreshOracleUsage();
    if (!mounted || auth.currentUser.id != _userId) return;
    final session = await _spreadRepository.prepare(
      userId: _userId, spread: spread.name, question: question, catalog: tarotCards,
      premium: auth.isPremiumEffective, legacyOracleUsed: auth.currentUser.oracleReadingsToday,
      freeLimit: UserModel.freeOracleReadingsLimit, startNew: _newSpreadRequested,
    );
    if (!mounted || auth.currentUser.id != _userId) return;
    _newSpreadRequested = false;
    _questionFocus.unfocus();
    final labels = spread.positions(AppLocalizations.of(context));
    final title = spread.displayName(AppLocalizations.of(context));
    TarotSpreadUpdate? result;
    if (session.isCommitted) {
      result = TarotSpreadUpdate(session);
    } else {
      final route = MaterialPageRoute<TarotSpreadUpdate>(builder: (_) =>
        TarotSpreadSelectionPage(
          session: session, title: title, positionLabels: labels,
          onSelect: (cardId, expectedCount) => _spreadRepository.select(
            userId: _userId, sessionId: session.id, cardId: cardId,
            expectedCount: expectedCount, catalog: tarotCards, positionLabels: labels,
            isCurrentUser: () => mounted && auth.currentUser.id == _userId,
            isPremium: () => auth.isPremiumEffective, freeLimit: UserModel.freeOracleReadingsLimit,
          ),
        ));
      result = await Navigator.of(context).push(route);
      await route.completed;
    }
    if (!mounted || result == null || auth.currentUser.id != _userId) return;
    final committedResult = result;
    final completed = committedResult.session;
    final drawn = [for (var i = 0; i < completed.selectedIds.length; i++)
      TarotDrawnCard(
        card: tarotCards.firstWhere((c) => c.id == completed.selectedIds[i]),
        isReversed: completed.card(completed.selectedIds[i]).reversed,
        positionLabel: labels[i],
      )];
    final saved = await _spreadRepository.interpretation(completed) ??
        await _savedReadingFor(completed.resultSignature!);
    await auth.refreshOracleUsage();
    if (!mounted || auth.currentUser.id != _userId) return;
    await Future.wait([for (final d in drawn)
      precacheImage(AssetImage(d.card.assetPath(TarotDeck.riderWaite)), context,
          onError: (Object error, StackTrace? stack) {})]);
    if (!mounted || auth.currentUser.id != _userId) return;
    if (committedResult.created && !auth.isPremiumEffective) {
      await AdService.instance.showBeforeResult();
      if (!mounted || auth.currentUser.id != _userId) return;
    }
    setState(() {
      _activeSpread = spread;
      _activeReadingSignature = completed.resultSignature;
      _activeReadingDate = completed.startedAt;
      _backPositions = completed.selectedIds.map(completed.positionOf).toList();
      _question = completed.question;
      _drawn = drawn;
      _revealed = GrimoireMotion.reduced(context) || !committedResult.created;
      _aiReading = saved;
    });
    unawaited(_registrarMesa(spread: spread, spreadLabel: title, drawn: drawn,
        question: completed.question, interpretation: saved, readingDate: completed.startedAt));
    if (committedResult.created) {
      unawaited(context.read<DailyCheckinProvider>().completeRite(DailyRites.divination));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _activeReadingSignature == completed.resultSignature) {
          setState(() => _revealed = true);
        }
      });
    }
  }

  Widget _resultCard(int index, double width) => TarotFlipCard(
    key: ValueKey('reading_${_activeReadingSignature}_$index'),
    revealed: _revealed,
    delay: Duration(milliseconds: 90 * index),
    back: TarotCardBack(width: width, deckPosition: _backPositions[index]),
    front: TarotCardView(card: _drawn[index].card, width: width,
        reversed: _drawn[index].isReversed),
  );

  /// Resumo das cartas na mesa — o material que o Conselheiro lê, seja para
  /// o conselho completo ou para a degustação.
  String _spreadSummary() {
    final l10n = AppLocalizations.of(context);
    final summary = StringBuffer()
      ..writeln('${l10n.tarotSpreadLabel}: '
          '${_activeSpread!.displayName(l10n)}');
    for (final drawn in _drawn) {
      summary.writeln(
        '- ${drawn.positionLabel}: ${drawn.card.name}'
        '${drawn.isReversed ? ' (${l10n.tarotReversed})' : ''} — ${drawn.meaning}',
      );
    }
    return summary.toString();
  }

  /// Registra a mesa revelada e escreve a sua página em "Meus Registros".
  ///
  /// Uma chamada só para as duas coisas porque as duas dependem do mesmo id:
  /// `recordDraw` é idempotente por assinatura e devolve SEMPRE o mesmo id
  /// para as mesmas cartas, e é ele que nomeia a entrada do acervo. Assim
  /// reabrir a carta do dia não cria uma segunda página, e o Conselheiro que
  /// chega depois reescreve a que já existe.
  ///
  /// Roda solta (`unawaited`) e por isso engole a própria falha: a mesa já
  /// está na tela, e um erro de banco aqui não pode virar exceção sem dono.
  Future<void> _registrarMesa({
    required TarotSpread spread,
    required String spreadLabel,
    required List<TarotDrawnCard> drawn,
    required String question,
    String? interpretation,
    DateTime? readingDate,
  }) async {
    try {
      final signature = _signature(spread, drawn);
      readingDate ??= _activeReadingDate;
      final id = await TarotReadingRepository().recordDraw(
        userId: _userId,
        spreadName: spread.name,
        signature: signature,
        drawn: drawn,
        question: question,
        date: readingDate,
      );
      if (interpretation != null && interpretation.trim().isNotEmpty) {
        await TarotReadingRepository().attachInterpretation(
          userId: _userId,
          signature: signature,
          interpretation: interpretation,
        );
      }
      await ReadingArchiveRecorder().record(
        readingId: id,
        userId: _userId,
        source: FreeWritingSource.tarot,
        createdAt: readingDate,
        page: ReadingArchiveComposer.tarot(
          spreadName: spreadLabel,
          question: question,
          drawn: drawn,
          interpretation: interpretation,
        ),
      );
    } catch (e) {
      debugPrint('tarot: falhou ao registrar a mesa: $e');
    }
  }

  Future<void> _askCounselor() async {
    if (_drawn.isEmpty || _isReadingAI) return;

    // Interpretação do Conselheiro Místico: exclusiva Premium. Sem acesso o
    // botão nem aparece — o card mostra a degustação no lugar.
    if (!context.read<AuthProvider>().isPremiumEffective) return;

    final signature = _signature(_activeSpread!, _drawn);
    setState(() => _isReadingAI = true);
    try {
      final reading = await AIService.instance.interpretTarotSpread(
        summary: _spreadSummary(),
        question: _question.isEmpty ? null : _question,
      );
      if (!mounted || _activeReadingSignature != signature) return;
      final spreadLabel = _activeSpread!.displayName(AppLocalizations.of(context));
      setState(() => _aiReading = reading);
      // Guarda a interpretação atrelada a estas cartas para não regerar.
      await _persistReading(signature, reading);
      if (!mounted || _activeReadingSignature != signature) return;
      // E reescreve o registro da tiragem e a sua página no acervo com o
      // conselho junto — a Leitura do Ciclo cita a resposta.
      unawaited(_registrarMesa(
        spread: _activeSpread!,
        spreadLabel: spreadLabel,
        drawn: _drawn,
        question: _question,
        interpretation: reading,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'.replaceAll('Exception: ', '')),
          backgroundColor: context.gc.alert,
        ),
      );
    } finally {
      if (mounted) setState(() => _isReadingAI = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Voltar desfaz por camadas: com uma tiragem aberta, o gesto de voltar
    // fecha a tiragem (volta ao seletor) em vez de sair da página inteira.
    return PopScope(
      canPop: _activeSpread == null,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        setState(() {
          _activeSpread = null;
          _activeReadingSignature = null;
          _newSpreadRequested = false;
          _drawn = [];
          _aiReading = null;
          _question = '';
        });
      },
      child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_activeSpread == null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                AppLocalizations.of(context).tarotBreathe,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.gc.textSecondary,
                    ),
              ),
            ),
            // Pergunta obrigatória: as cartas e o Conselheiro Místico ancoram
            // a leitura nela. Caixa dourada — é o convite principal da tiragem.
            MagicalCard.accent(
              accent: context.gc.gold,
              child: TextField(
                controller: _questionController,
                focusNode: _questionFocus,
                maxLines: 2,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: context.gc.textPrimary),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).tarotQuestionLabel,
                  labelStyle: TextStyle(
                    color: context.gc.gold,
                    fontWeight: FontWeight.w600,
                  ),
                  hintText: AppLocalizations.of(context).tarotQuestionHint,
                  hintStyle: TextStyle(
                    color: context.gc.starYellow.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                  prefixIcon:
                      Icon(Icons.auto_awesome, color: context.gc.gold),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: context.gc.gold.withValues(alpha: 0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: context.gc.gold.withValues(alpha: 0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: context.gc.gold, width: 1.5),
                  ),
                ),
              ),
            ),
            for (final spread in TarotSpread.values)
              InkWell(
                onTap: _starting ? null : () => _startSpread(spread),
                borderRadius: BorderRadius.circular(12),
                child: MagicalCard(
                  child: Row(
                    children: [
                      Text(spread.emoji,
                          style: const TextStyle(fontSize: 30)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              spread.displayName(AppLocalizations.of(context)),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: context.gc.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              spread.description(AppLocalizations.of(context)),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: context.gc.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          color: context.gc.textSecondary),
                    ],
                  ),
                ),
              ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OverflowBar(
                alignment: MainAxisAlignment.spaceBetween,
                overflowAlignment: OverflowBarAlignment.start,
                spacing: 12,
                overflowSpacing: 4,
                children: [
                  Text(
                    '${_activeSpread!.emoji} ${_activeSpread!.displayName(AppLocalizations.of(context))}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.gc.lilac,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: _isReadingAI ? null : () => setState(() {
                      _newSpreadRequested = true;
                      _activeReadingSignature = null;
                      _activeSpread = null;
                      _drawn = [];
                      _aiReading = null;
                      _question = '';
                    }),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(AppLocalizations.of(context).tarotNewSpread),
                  ),
                ],
              ),
            ),
            if (_question.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Text(
                  AppLocalizations.of(context).tarotQuestionPrefix(_question),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _activeSpread == TarotSpread.daily
                  ? Center(child: _resultCard(0, 110))
                  : SpreadBoard(
                      labels: _drawn.map((d) => d.positionLabel).toList(),
                      cross: _activeSpread == TarotSpread.cross,
                      cardBuilder: _resultCard,
                    ),
            ),
            if (_revealed) ...[
              for (final drawn in _drawn)
                MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${drawn.positionLabel} — ${drawn.card.name}'
                        '${drawn.isReversed ? ' (${AppLocalizations.of(context).tarotReversed})' : ''}',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: context.gc.lilac,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        children: drawn.card.keywords
                            .map((k) => Text(
                                  '· $k',
                                  style: TextStyle(
                                    color: context.gc.textSecondary,
                                    fontSize: 12,
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        drawn.meaning,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!context.watch<AuthProvider>().isPremiumEffective)
                      // Sem acesso: no lugar do botão, o sumário do que o
                      // Conselheiro teceria sobre as cartas que já estão na
                      // mesa.
                      _previaDoConselheiro(context)
                    else if (_aiReading == null)
                      // Sem interpretação para estas cartas: mostra o botão.
                      ElevatedButton.icon(
                        onPressed: _isReadingAI ? null : _askCounselor,
                        icon: _isReadingAI
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: context.gc.onPrimary,
                                ),
                              )
                            : const Icon(Icons.auto_awesome, size: 18),
                        label: Text(
                          _isReadingAI
                              ? AppLocalizations.of(context).tarotConsultingCards
                              : AppLocalizations.of(context)
                                  .tarotAdvisorInterpretation,
                        ),
                      )
                    else ...[
                      // Já interpretado: mostra só o texto. O botão volta apenas
                      // em uma nova tiragem (cartas diferentes).
                      Text(
                        AppLocalizations.of(context).tarotAdvisorInterpretation,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: context.gc.lilac,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _aiReading!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(height: 1.6),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
          const SizedBox(height: 24),
        ],
      ),
      ),
    );
  }
}

/// O que o Conselheiro Místico teceria sobre a tiragem que já está na mesa.
///
/// Sem Premium não sai chamada de IA nenhuma: os títulos são fixos, e o que
/// eles mostram é a FORMA da leitura — como as peças conversam, a narrativa
/// que formam, a resposta à pergunta e o conselho final. É mais informação
/// do que a antiga degustação dava, e não custa geração.
Widget _previaDoConselheiro(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return PremiumLockedPreview(
    titles: [
      l10n.counselorLockedTitle1,
      l10n.counselorLockedTitle2,
      l10n.counselorLockedTitle3,
      l10n.counselorLockedTitle4,
    ],
  );
}
