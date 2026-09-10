import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/ai/ai_service.dart';
import '../../../../core/navigation/grimoire_route.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/motion/tool_scene_frame.dart';
import '../../../../core/widgets/premium_locked_preview.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/data/services/reading_archive_composer.dart';
import '../../../diary/data/services/reading_archive_recorder.dart';
import '../../../tarot/presentation/widgets/tarot_card_view.dart';
import '../../../your_day/presentation/providers/daily_checkin_provider.dart';
import '../../data/data_sources/runes_data.dart';
import '../../data/models/rune_spread_model.dart';
import '../../data/repositories/rune_reading_repository.dart';
import '../../data/repositories/rune_selection_repository.dart';
import '../../domain/rune_selection_session.dart';
import '../widgets/rune_spread_board.dart';
import '../widgets/rune_stone_view.dart';
import 'rune_detail_page.dart';
import 'rune_selection_page.dart';

/// Trocar de conta recria a tela: o rascunho, a mesa e a interpretação
/// pertencem a quem estava logada quando começaram.
class RuneReadingPage extends StatelessWidget {
  const RuneReadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.select<AuthProvider, String>((auth) => auth.currentUser.id);
    return _RuneReadingBody(key: ValueKey('runes-$userId'), userId: userId);
  }
}

class _RuneReadingBody extends StatefulWidget {
  const _RuneReadingBody({super.key, required this.userId});

  final String userId;

  @override
  State<_RuneReadingBody> createState() => _RuneReadingBodyState();
}

class _RuneReadingBodyState extends State<_RuneReadingBody> {
  final _questionController = TextEditingController();
  final _repository = RuneReadingRepository();
  final _sessions = RuneSelectionRepository();

  /// Escreve a leitura em "Meus Registros" assim que ela sai.
  final _archive = ReadingArchiveRecorder();

  RuneSpreadType _selectedSpread = RuneSpreadType.single;
  List<RunePosition>? _drawnRunes;
  bool _isDrawing = false;

  /// Mesa em exibição: a sessão confirmada, os lugares originais de cada
  /// pedra no tecido (para o verso não mudar ao virar) e o estado da cena.
  RuneSelectionSession? _activeSession;
  List<int> _backPositions = const [];
  bool _revealed = false;
  bool _textVisible = false;
  int? _highlighted;
  bool _newReadingRequested = false;
  Timer? _textTimer;
  List<GlobalKey> _positionKeys = const [];

  String get _userId => widget.userId;

  /// Cadência da virada das pedras: cada uma leva [GrimoireMotion.reveal],
  /// com até 90ms entre vizinhas; nas mesas grandes o passo aperta para a
  /// revelação inteira caber em [_tetoRevelacaoMs].
  static const int _tetoRevelacaoMs = 1200;

  static int _passoRevelacaoMs(int quantas) {
    if (quantas <= 1) return 0;
    return min(90, (_tetoRevelacaoMs - GrimoireMotion.reveal.inMilliseconds) ~/ (quantas - 1));
  }

  static int _totalRevelacaoMs(int quantas) =>
      (quantas - 1) * _passoRevelacaoMs(quantas) + GrimoireMotion.reveal.inMilliseconds;

  @override
  void dispose() {
    _questionController.dispose();
    _textTimer?.cancel();
    super.dispose();
  }

  Future<void> _drawRunes() async {
    if (_isDrawing) return;
    setState(() => _isDrawing = true);
    try {
      await _startSelection();
    } on RuneQuotaExceeded {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).oracleDailyLimit),
        backgroundColor: context.gc.alert,
        duration: const Duration(seconds: 4),
      ));
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const PremiumUpgradeSheet(),
      );
    } on RuneAccountChanged {
      // A tela da outra conta já foi recriada; nada a mostrar aqui.
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).cardSelectionLoadError)));
    } finally {
      if (mounted) setState(() => _isDrawing = false);
    }
  }

  /// Prepara (ou retoma) a sessão e abre o tecido. A escolha acontece na
  /// página de seleção; a mesa só volta para cá confirmada e gravada.
  Future<void> _startSelection() async {
    final auth = context.read<AuthProvider>();
    await auth.refreshRuneUsage();
    if (!mounted || auth.currentUser.id != _userId) return;
    final spread = _selectedSpread;
    final session = await _sessions.prepare(
      userId: _userId,
      spread: spread,
      question: _questionController.text,
      catalog: runesData,
      premium: auth.isPremiumEffective,
      legacyRuneUsed: auth.currentUser.runeReadingsToday,
      freeLimit: UserModel.freeRuneReadingsLimit,
      startNew: _newReadingRequested,
    );
    if (!mounted || auth.currentUser.id != _userId) return;
    _newReadingRequested = false;
    FocusScope.of(context).unfocus();
    final labels = List.generate(spread.runeCount, spread.getPositionMeaning);
    final emptyQuestion = AppLocalizations.of(context).runesNoQuestion;
    RuneSelectionUpdate? result;
    if (session.isCommitted) {
      result = RuneSelectionUpdate(session);
      await _prepareResult(result);
    } else {
      final route = MaterialPageRoute<RuneSelectionUpdate>(builder: (_) =>
        RuneSelectionPage(
          session: session, positionLabels: labels,
          onSelect: (runeId, expectedCount) async {
            final update = await _sessions.select(
              userId: _userId, sessionId: session.id, runeId: runeId,
              expectedCount: expectedCount, catalog: runesData,
              positionLabels: labels, emptyQuestionLabel: emptyQuestion,
              isCurrentUser: () => mounted && auth.currentUser.id == _userId,
              isPremium: () => auth.isPremiumEffective,
              freeLimit: UserModel.freeRuneReadingsLimit,
            );
            // Keep the cloth in front while the table is prepared: the
            // destination must already hold the stones when the route pops.
            if (update.session.isCommitted) await _prepareResult(update);
            return update;
          },
        ));
      result = await Navigator.of(context).push(route);
      // Only the flip waits for the overlay to leave, never result preparation.
      await route.completed;
    }
    if (!mounted || result == null || auth.currentUser.id != _userId) return;
    _revealPrepared(result.session.id, created: result.created);
  }

  Future<void> _prepareResult(RuneSelectionUpdate committed) async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final session = committed.session;
    if (auth.currentUser.id != session.userId) return;
    final stored = await _sessions.reading(session);
    if (stored == null) throw StateError('The confirmed reading is missing');
    await auth.refreshRuneUsage();
    if (!mounted || auth.currentUser.id != _userId) return;
    // Anúncio ANTES de revelar (free, só numa mesa recém-confirmada).
    if (committed.created && !auth.isPremiumEffective) {
      await AdService.instance.showBeforeResult();
      if (!mounted || auth.currentUser.id != _userId) return;
    }
    // Nome e glifo são invariantes; descrição e palavras-chave acompanham o
    // idioma atual, não o que estava ativo quando a mesa foi gravada.
    final catalog = runesData;
    final positions = [for (final p in stored.positions)
      RunePosition(
        position: p.position,
        rune: catalog.firstWhere((r) => r.name == p.rune.name, orElse: () => p.rune),
        isReversed: p.isReversed,
        positionMeaning: p.positionMeaning,
      )];
    final reading = RuneReading(
      id: stored.id, question: stored.question, spreadType: stored.spreadType,
      positions: positions, interpretation: stored.interpretation,
      date: stored.date, sessionId: stored.sessionId,
    );
    _textTimer?.cancel();
    setState(() {
      _activeSession = session;
      _selectedSpread = session.spread;
      _backPositions = session.selectedIds.map(session.positionOf).toList();
      _drawnRunes = positions;
      _lastReading = reading;
      _aiReading = reading.interpretation;
      _revealed = !committed.created;
      _textVisible = !committed.created;
      _highlighted = null;
      _positionKeys = List.generate(positions.length, (_) => GlobalKey());
    });
    // A mesa já nasce como página do acervo; reabrir reescreve a mesma linha.
    unawaited(_archive.record(
      readingId: reading.id,
      userId: _userId,
      source: FreeWritingSource.runes,
      page: ReadingArchiveComposer.runes(reading, interpretation: reading.interpretation),
      createdAt: reading.date,
    ));
  }

  void _revealPrepared(String sessionId, {required bool created}) {
    if (!created || !mounted || _activeSession?.id != sessionId) return;
    // A tiragem aconteceu: se as runas são o rito de hoje, está cumprido.
    unawaited(context.read<DailyCheckinProvider>().completeRite(DailyRites.runes));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _activeSession?.id != sessionId) return;
      // Um único toque físico marca o momento, também sob "reduzir movimento".
      HapticFeedback.lightImpact();
      final reduced = GrimoireMotion.reduced(context);
      setState(() {
        _revealed = true;
        _textVisible = reduced;
      });
      if (!reduced) {
        _textTimer?.cancel();
        _textTimer = Timer(
          Duration(milliseconds: _totalRevelacaoMs(_drawnRunes?.length ?? 1)),
          () {
            _textTimer = null;
            if (mounted && _activeSession?.id == sessionId) {
              setState(() => _textVisible = true);
            }
          },
        );
      }
    });
  }

  /// Antecipar: um toque na mesa durante a virada mostra o texto na hora.
  void _skipAhead() {
    if (_textVisible) return;
    _textTimer?.cancel();
    _textTimer = null;
    setState(() => _textVisible = true);
  }

  void _clearTable({required bool newReading}) {
    _textTimer?.cancel();
    _textTimer = null;
    setState(() {
      _newReadingRequested = newReading;
      _activeSession = null;
      _backPositions = const [];
      _drawnRunes = null;
      _lastReading = null;
      _aiReading = null;
      _revealed = false;
      _textVisible = false;
      _highlighted = null;
      _positionKeys = const [];
      if (newReading) _questionController.clear();
    });
  }

  /// Última leitura — o que o Conselheiro lê e o que já virou página do
  /// acervo.
  RuneReading? _lastReading;

  /// Interpretação do Conselheiro Místico (Premium), como no Tarot.
  String? _aiReading;
  bool _isReadingAI = false;

  /// Resumo da tiragem — o material que o Conselheiro lê, seja para o
  /// conselho completo ou para a degustação. O compositor do acervo já
  /// produz o texto limpo.
  String _readingSummary(RuneReading reading) {
    final page = ReadingArchiveComposer.runes(reading);
    return '${page.title}\n${page.content}';
  }

  /// Interpretação do Conselheiro Místico (Premium): tece a leitura das
  /// runas já sorteadas — mesmo fluxo do Tarot.
  Future<void> _askCounselor() async {
    final reading = _lastReading;
    if (reading == null || _isReadingAI) return;

    // Sem acesso o botão nem aparece: o card mostra a degustação no lugar.
    if (!context.read<AuthProvider>().isPremiumEffective) return;

    setState(() => _isReadingAI = true);
    try {
      final question = reading.question.trim();
      final noQuestion =
          question.isEmpty || question == AppLocalizations.of(context).runesNoQuestion;
      final interpretation = await AIService.instance.interpretRuneSpread(
        summary: _readingSummary(reading),
        question: noQuestion ? null : question,
      );
      // Uma resposta atrasada não pertence a outra mesa.
      if (!mounted || _lastReading?.id != reading.id) return;
      setState(() => _aiReading = interpretation);
      // Fica junto da leitura: reabrir a mesa não pede outra geração.
      await _repository.attachInterpretation(
        readingId: reading.id, userId: _userId, interpretation: interpretation);
      // Mesmo id da leitura: reescreve a página que já está no acervo, com
      // o conselho junto — nunca cria uma segunda.
      await _archive.record(
        readingId: reading.id,
        userId: _userId,
        source: FreeWritingSource.runes,
        page: ReadingArchiveComposer.runes(
          reading,
          interpretation: interpretation,
        ),
        createdAt: reading.date,
      );
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
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).runesReadingTitle),
        backgroundColor: context.gc.darkBackground,
      ),
      backgroundColor: context.gc.darkBackground,
      body: ToolSceneFrame(child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_drawnRunes == null) ...[
              MagicalCard(
                child: Column(
                  children: [
                    const Text('ᚱᚢᚾᚨ', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).runesReadingTitle,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: context.gc.lilac,
                              ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context).runesReadingIntro,
                      style: TextStyle(
                        color: context.gc.softWhite.withValues(alpha: 0.8),
                        fontSize: 14,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).runesReversedNote,
                      style: TextStyle(
                        color: context.gc.lilac.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                AppLocalizations.of(context).runesChooseLayout,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: context.gc.lilac,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Opções de spread
              _buildSpreadOption(
                RuneSpreadType.single,
                Icons.crop_square,
              ),
              const SizedBox(height: 12),
              _buildSpreadOption(
                RuneSpreadType.threeCast,
                Icons.view_column,
              ),
              const SizedBox(height: 12),
              _buildSpreadOption(
                RuneSpreadType.nordicCross,
                Icons.add,
              ),
              const SizedBox(height: 12),
              _buildSpreadOption(
                RuneSpreadType.nineWorlds,
                Icons.grid_3x3,
              ),

              const SizedBox(height: 16),

              // Campo de pergunta
              MagicalCard(
                child: TextField(
                  controller: _questionController,
                  style: TextStyle(color: context.gc.softWhite),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).runesQuestionOptional,
                    labelStyle: TextStyle(color: context.gc.lilac),
                    hintText: AppLocalizations.of(context).runesQuestionHint,
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
                  maxLines: 2,
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                key: const ValueKey('runes-draw'),
                onPressed: _isDrawing ? null : _drawRunes,
                // Enquanto a mesa é preparada, os glifos do cartão de
                // abertura se revezam no botão; sob "reduzir movimento" fica
                // o indicador circular de sempre.
                icon: !_isDrawing
                    ? const Icon(Icons.auto_awesome)
                    : GrimoireMotion.reduced(context)
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
                        : _GlifosDoSorteio(cor: context.gc.darkBackground),
                label: Text(_isDrawing ? AppLocalizations.of(context).runesDrawing : AppLocalizations.of(context).runesDraw),
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

              // Exibir usos restantes para usuários free
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  if (authProvider.isPremium) return const SizedBox.shrink();
                  final remaining =
                      authProvider.currentUser.remainingRuneReadings;
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      AppLocalizations.of(context).oracleRemainingToday('$remaining/${UserModel.freeRuneReadingsLimit}'),
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
            ],

            // Resultado
            if (_drawnRunes != null) ...[
              _buildReadingResult(_drawnRunes!),
              if (_lastReading != null) _buildCounselorCard(),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                key: const ValueKey('runes-new-reading'),
                onPressed: _isReadingAI ? null : () => _clearTable(newReading: true),
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context).oracleNewReading),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.gc.lilac,
                  side: BorderSide(color: context.gc.lilac),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ],
        ),
      )),
    );
  }

  Widget _buildSpreadOption(RuneSpreadType spread, IconData icon) {
    final isSelected = _selectedSpread == spread;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSpread = spread;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? context.gc.lilac.withValues(alpha: 0.2)
              : context.gc.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.gc.lilac : context.gc.surfaceBorder,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? context.gc.lilac : context.gc.softWhite,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spread.displayName,
                    style: TextStyle(
                      color: isSelected ? context.gc.lilac : context.gc.softWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    spread.description,
                    style: TextStyle(
                      color: context.gc.softWhite.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: context.gc.lilac,
              ),
          ],
        ),
      ),
    );
  }

  /// A pedra da posição [index] na mesa: verso do tecido até a revelação,
  /// glifo depois. O verso conserva o lugar original da pedra.
  Widget _stone(int index, double size) {
    final position = _drawnRunes![index];
    final slot = index < _backPositions.length ? _backPositions[index] : index;
    return TarotFlipCard(
      key: ValueKey('rune-flip-${_activeSession?.id}-$index'),
      revealed: _revealed,
      delay: Duration(milliseconds: _passoRevelacaoMs(_drawnRunes!.length) * index),
      back: RuneStoneView(size: size, deckPosition: slot),
      front: RuneStoneView(
        size: size, deckPosition: slot, symbol: position.rune.symbol,
        reversed: position.isReversed, highlighted: _highlighted == index,
      ),
    );
  }

  void _focusPosition(int index) {
    if (!_revealed) return;
    _skipAhead();
    setState(() => _highlighted = index);
    final target = index < _positionKeys.length ? _positionKeys[index].currentContext : null;
    if (target != null) {
      Scrollable.ensureVisible(target,
          duration: GrimoireMotion.reduced(context) ? Duration.zero : GrimoireMotion.state,
          alignment: .1);
    }
  }

  Widget _buildReadingResult(List<RunePosition> positions) {
    final l10n = AppLocalizations.of(context);
    final reduced = GrimoireMotion.reduced(context);
    final question = _lastReading?.question ?? '';
    final showQuestion = question.trim().isNotEmpty && question != l10n.runesNoQuestion;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MagicalCard(
          child: Column(
            children: [
              const Text('✨', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                l10n.oracleYourReading,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: context.gc.lilac,
                    ),
              ),
              if (showQuestion) ...[
                const SizedBox(height: 8),
                Text(
                  question,
                  style: TextStyle(
                    color: context.gc.softWhite.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // A mesa: as pedras viram no lugar em que foram postas. Tocar uma
        // pedra destaca a interpretação correspondente (e antecipa o texto).
        GestureDetector(
          key: const ValueKey('runes-table'),
          behavior: HitTestBehavior.translucent,
          onTap: _skipAhead,
          child: MagicalCard(
            child: Column(children: [
              RuneSpreadBoard(
                spread: _selectedSpread,
                labels: positions.map((p) => p.positionMeaning).toList(),
                selectedPosition: _highlighted,
                onTap: _focusPosition,
                stoneBuilder: _stone,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.runeTableHint,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.gc.textSecondary, fontSize: 12),
              ),
            ]),
          ),
        ),

        const SizedBox(height: 16),

        // O texto chega depois das pedras assentarem — nunca junto com elas.
        AnimatedSlide(
          offset: _textVisible ? Offset.zero : const Offset(0, .04),
          duration: reduced ? Duration.zero : GrimoireMotion.state,
          curve: GrimoireMotion.enter,
          child: AnimatedOpacity(
            key: const ValueKey('runes-text'),
            opacity: _textVisible ? 1 : 0,
            duration: reduced ? Duration.zero : GrimoireMotion.state,
            child: IgnorePointer(
              ignoring: !_textVisible,
              child: ExcludeSemantics(
                excluding: !_textVisible,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < positions.length; i++)
                      _positionCard(i, positions[i]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _positionCard(int index, RunePosition position) {
    final highlighted = _highlighted == index;
    return Padding(
      key: index < _positionKeys.length ? _positionKeys[index] : null,
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            GrimoireRoute(
              builder: (_) => RuneDetailPage(rune: position.rune),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: GrimoireMotion.reduced(context) ? Duration.zero : GrimoireMotion.state,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: highlighted ? context.gc.lilac : Colors.transparent,
              width: 2,
            ),
          ),
          child: MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: context.gc.lilac.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: RotatedBox(
                          quarterTurns: position.isReversed ? 2 : 0,
                          child: Text(
                            position.rune.symbol,
                            style: TextStyle(
                              fontSize: 32,
                              color: context.gc.lilac,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            position.positionMeaning,
                            style: TextStyle(
                              color: context.gc.softWhite.withValues(alpha: 0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            position.rune.name,
                            style: TextStyle(
                              color: context.gc.lilac,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (position.isReversed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.gc.alert.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          AppLocalizations.of(context).runesReversed,
                          style: TextStyle(
                            color: context.gc.alert,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Palavras-chave, como nos cards da tiragem de Tarot.
                Wrap(
                  spacing: 6,
                  children: position.rune.keywords
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
                  position.isReversed &&
                          position.rune.reversedMeaning != null
                      ? position.rune.reversedMeaning!
                      : position.rune.divination,
                  style: TextStyle(
                    color: context.gc.softWhite,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Card do Conselheiro Místico: botão premium que vira o texto tecido —
  /// idêntico ao da tiragem de Tarot.
  Widget _buildCounselorCard() {
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_lastReading != null &&
              !context.watch<AuthProvider>().isPremiumEffective)
            // Sem acesso: no lugar do botão, o sumário do que o
            // Conselheiro teceria sobre as runas que já estão na mesa.
            _previaDoConselheiro(context)
          else if (_aiReading == null)
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
                    : AppLocalizations.of(context).tarotAdvisorInterpretation,
              ),
            )
          else ...[
            Text(
              AppLocalizations.of(context).tarotAdvisorInterpretation,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.gc.lilac,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              _aiReading!,
              style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
          ],
        ],
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

/// Glifos que se revezam no botão enquanto a mesa é preparada — os mesmos
/// caracteres do cartão de abertura ('ᚱᚢᚾᚨ'), acendendo e apagando um por
/// vez. Puramente decorativo (o rótulo do botão já diz o estado), por isso
/// fora da árvore de semântica.
///
/// Quem decide o fallback sob "reduzir movimento" é o chamador; ainda
/// assim, o loop aqui segue a regra da casa: só começa depois de ler a
/// preferência de acessibilidade, nunca no initState.
class _GlifosDoSorteio extends StatefulWidget {
  const _GlifosDoSorteio({required this.cor});

  final Color cor;

  @override
  State<_GlifosDoSorteio> createState() => _GlifosDoSorteioState();
}

class _GlifosDoSorteioState extends State<_GlifosDoSorteio>
    with SingleTickerProviderStateMixin {
  static const List<String> _glifos = ['ᚱ', 'ᚢ', 'ᚾ', 'ᚨ'];

  late final AnimationController _c;
  bool? _reduzido;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduzido = MediaQuery.disableAnimationsOf(context);
    if (reduzido == _reduzido) return;
    _reduzido = reduzido;
    if (reduzido) {
      _c.stop();
      _c.value = 0.5;
    } else {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: 20,
        height: 20,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final volta = _c.value * _glifos.length;
            final indice = volta.floor() % _glifos.length;
            // Meia-senoide por glifo: acende e apaga sem sumir de vez.
            final brilho = 0.35 + 0.65 * sin(pi * (volta % 1.0));
            return Center(
              child: Opacity(
                opacity: brilho.clamp(0.0, 1.0).toDouble(),
                child: Text(
                  _glifos[indice],
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.0,
                    fontWeight: FontWeight.bold,
                    color: widget.cor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
