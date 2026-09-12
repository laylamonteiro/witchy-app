import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/ai/ai_service.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/motion/tool_scene_frame.dart';
import '../../../../core/widgets/reading_focus_panel.dart';
import '../../../../core/widgets/premium_locked_preview.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/data/services/reading_archive_composer.dart';
import '../../../diary/data/services/reading_archive_recorder.dart';
import '../../../tarot/presentation/widgets/tarot_card_view.dart';
import '../../../your_day/presentation/providers/daily_checkin_provider.dart';
import '../../data/data_sources/oracle_cards_data.dart';
import '../../data/models/oracle_card_model.dart';
import '../../data/repositories/oracle_reading_repository.dart';
import '../../data/repositories/oracle_selection_repository.dart';
import '../../domain/oracle_selection_session.dart';
import '../widgets/grimoire_card_back.dart';
import '../widgets/oracle_card_face.dart';
import '../widgets/oracle_spread_board.dart';
import 'oracle_album_page.dart';
import 'oracle_selection_page.dart';
import '../../../../core/tools/tool_identity.dart';

/// Trocar de conta recria a tela: rascunho, mesa e conselho pertencem a
/// quem estava logada quando começaram.
class OracleCardsPage extends StatelessWidget {
  const OracleCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.select<AuthProvider, String>((auth) => auth.currentUser.id);
    return _OracleBody(key: ValueKey('oracle-$userId'), userId: userId);
  }
}

class _OracleBody extends StatefulWidget {
  const _OracleBody({super.key, required this.userId});

  final String userId;

  @override
  State<_OracleBody> createState() => _OracleBodyState();
}

class _OracleBodyState extends State<_OracleBody> {
  final _sessions = OracleSelectionRepository();
  final _readings = OracleReadingRepository();

  /// Escreve a tiragem em "Meus Registros" assim que ela sai.
  final _archive = ReadingArchiveRecorder();

  OracleSpreadType _selectedSpread = OracleSpreadType.daily;
  List<OracleCardPosition>? _drawnCards;

  /// Última tiragem — o que o Conselheiro lê e o que já virou página do
  /// acervo.
  OracleReading? _lastReading;

  /// Interpretação do Conselheiro Místico (Premium), como no Tarot.
  String? _aiReading;
  bool _isReadingAI = false;
  bool _isDrawing = false;

  /// Mesa em exibição: sessão confirmada, lugares originais no leque (o
  /// verso não muda ao virar), estado da cena e descobertas desta tiragem.
  OracleSelectionSession? _activeSession;
  List<int> _backPositions = const [];
  bool _revealed = false;
  bool _textVisible = false;
  int _focused = 0;
  int _sceneToken = 0;
  List<int> _newDiscoveries = const [];
  bool _newReadingRequested = false;
  Timer? _textTimer;
  /// A caixa do palco. É uma só: o painel mostra uma posição por vez, e é
  /// para ela que a página olha quando precisa olhar para alguma coisa.
  final GlobalKey _stageKey = GlobalKey();

  /// A tiragem inteira, aberta embaixo do painel. Fechada por padrão: quem
  /// quiser ler tudo de uma vez pede.
  bool _showAll = false;

  String get _userId => widget.userId;

  /// Cadência da virada: cada carta leva [GrimoireMotion.reveal], com até
  /// 90 ms entre vizinhas; na mesa de cinco o passo aperta para caber em
  /// [_tetoRevelacaoMs].
  static const int _tetoRevelacaoMs = 1200;

  static int _passoRevelacaoMs(int quantas) {
    if (quantas <= 1) return 0;
    return min(90, (_tetoRevelacaoMs - GrimoireMotion.reveal.inMilliseconds) ~/ (quantas - 1));
  }

  static int _totalRevelacaoMs(int quantas) =>
      (quantas - 1) * _passoRevelacaoMs(quantas) + GrimoireMotion.reveal.inMilliseconds;

  @override
  void dispose() {
    _textTimer?.cancel();
    super.dispose();
  }

  Future<void> _drawCards() async {
    if (_isDrawing) return;
    setState(() => _isDrawing = true);
    try {
      await _startSelection();
    } on OracleQuotaExceeded {
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
    } on OracleAccountChanged {
      // A tela da outra conta já foi recriada; nada a mostrar aqui.
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).cardSelectionLoadError)));
    } finally {
      if (mounted) setState(() => _isDrawing = false);
    }
  }

  /// Prepara (ou retoma) a sessão e abre o leque. A escolha acontece na
  /// página de seleção; a mesa só volta para cá confirmada e gravada.
  Future<void> _startSelection() async {
    final auth = context.read<AuthProvider>();
    await auth.refreshOracleUsage();
    if (!mounted || auth.currentUser.id != _userId) return;
    final spread = _selectedSpread;
    final session = await _sessions.prepare(
      userId: _userId,
      spread: spread,
      catalog: oracleCardsData,
      premium: auth.isPremiumEffective,
      legacyOracleUsed: auth.currentUser.oracleReadingsToday,
      freeLimit: UserModel.freeOracleReadingsLimit,
      startNew: _newReadingRequested,
    );
    if (!mounted || auth.currentUser.id != _userId) return;
    _newReadingRequested = false;
    final labels = List.generate(spread.cardCount, spread.getPositionMeaning);
    OracleSelectionUpdate? result;
    if (session.isCommitted) {
      result = OracleSelectionUpdate(session);
      await _prepareResult(result);
    } else {
      final route = MaterialPageRoute<OracleSelectionUpdate>(builder: (_) =>
        OracleSelectionPage(
          session: session, positionLabels: labels,
          onSelect: (cardId, expectedCount) async {
            final update = await _sessions.select(
              userId: _userId, sessionId: session.id, cardId: cardId,
              expectedCount: expectedCount, catalog: oracleCardsData,
              positionLabels: labels,
              isCurrentUser: () => mounted && auth.currentUser.id == _userId,
              isPremium: () => auth.isPremiumEffective,
              freeLimit: UserModel.freeOracleReadingsLimit,
            );
            // Keep the fan in front while the table is prepared: the
            // destination must already hold the backs when the route pops.
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

  Future<void> _prepareResult(OracleSelectionUpdate committed) async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final session = committed.session;
    if (auth.currentUser.id != session.userId) return;
    final stored = await _sessions.reading(session);
    if (stored == null) throw StateError('The confirmed reading is missing');
    await auth.refreshOracleUsage();
    if (!mounted || auth.currentUser.id != _userId) return;
    if (committed.created && !auth.isPremiumEffective) {
      await AdService.instance.showBeforeResult();
      if (!mounted || auth.currentUser.id != _userId) return;
    }
    // ID e emoji são invariantes; nome, mensagem e orientação acompanham o
    // idioma atual, não o que estava ativo quando a mesa foi gravada.
    final catalog = oracleCardsData;
    final positions = [for (final p in stored.positions)
      OracleCardPosition(
        position: p.position,
        card: catalog.firstWhere((c) => c.id == p.card.id, orElse: () => p.card),
        positionMeaning: p.positionMeaning,
      )];
    final reading = OracleReading(
      id: stored.id, spreadType: stored.spreadType, positions: positions,
      date: stored.date, interpretation: stored.interpretation, sessionId: stored.sessionId,
    );
    _textTimer?.cancel();
    setState(() {
      _activeSession = session;
      _selectedSpread = session.spread;
      _backPositions = session.selectedIds.map(session.positionOf).toList();
      _drawnCards = positions;
      _lastReading = reading;
      _aiReading = reading.interpretation;
      _revealed = !committed.created;
      _textVisible = !committed.created;
      _focused = 0;
      _sceneToken++;
      _newDiscoveries = committed.created ? committed.newDiscoveries : const [];
      _showAll = false;
    });
    // A mesa já nasce como página do acervo; reabrir reescreve a mesma linha.
    unawaited(_archive.record(
      readingId: reading.id,
      userId: _userId,
      source: FreeWritingSource.oracle,
      page: ReadingArchiveComposer.oracle(reading, interpretation: reading.interpretation),
      createdAt: reading.date,
    ));
  }

  void _revealPrepared(String sessionId, {required bool created}) {
    if (!created || !mounted || _activeSession?.id != sessionId) return;
    // A tiragem aconteceu: se o oráculo é o rito de hoje, está cumprido.
    unawaited(context.read<DailyCheckinProvider>().completeRite(DailyRites.oracle));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _activeSession?.id != sessionId) return;
      HapticFeedback.lightImpact();
      final reduced = GrimoireMotion.reduced(context);
      setState(() {
        _revealed = true;
        _textVisible = reduced;
        if (reduced) _sceneToken++;
      });
      if (!reduced) {
        _textTimer?.cancel();
        _textTimer = Timer(
          Duration(milliseconds: _totalRevelacaoMs(_drawnCards?.length ?? 1)),
          () {
            _textTimer = null;
            if (mounted && _activeSession?.id == sessionId) {
              setState(() { _textVisible = true; _sceneToken++; });
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
    setState(() { _textVisible = true; _sceneToken++; });
  }

  /// Tocar numa carta da mesa muda o que o painel mostra — e mais nada.
  ///
  /// A página só se mexe quando o painel não cabe na tela, e aí pelo mínimo:
  /// `keepVisibleAtEnd` não rola nada se ele já está inteiro à vista. Antes,
  /// o toque abria a carta grande e ao mesmo tempo levava a página até o
  /// texto — a carta ia embora justamente enquanto se abria.
  void _focusPosition(int index) {
    if (!_revealed) return;
    final wasVisible = _textVisible;
    _skipAhead();
    setState(() {
      if (_focused != index || wasVisible) _sceneToken++;
      _focused = index;
    });
    _bringStageIntoView();
  }

  /// Traz o palco para a tela — e só se ele não estiver nela.
  ///
  /// `ensureVisible` com `keepVisibleAtEnd` encostaria a peça na borda de
  /// baixo, com o texto dela fora da tela. Aqui a conta é explícita: se o
  /// palco já cabe inteiro, nada se move; se não cabe, a página anda UMA vez
  /// até ele ficar no alto, e o que ele diz aparece logo abaixo.
  void _bringStageIntoView() {
    final target = _stageKey.currentContext;
    if (target == null) return;
    final box = target.findRenderObject();
    final scrollable = Scrollable.maybeOf(target);
    if (box is! RenderBox || scrollable == null) return;
    final position = scrollable.position;
    final viewport = RenderAbstractViewport.of(box);
    final atTop = viewport.getOffsetToReveal(box, 0).offset;
    final atBottom = viewport.getOffsetToReveal(box, 1).offset;
    if (position.pixels >= atBottom && position.pixels <= atTop) return;
    final destino = (atTop - 8)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    if (GrimoireMotion.reduced(context)) {
      position.jumpTo(destino);
      return;
    }
    position.animateTo(destino,
        duration: GrimoireMotion.state, curve: GrimoireMotion.enter);
  }

  void _clearTable({required bool newReading}) {
    _textTimer?.cancel();
    _textTimer = null;
    setState(() {
      _newReadingRequested = newReading;
      _activeSession = null;
      _backPositions = const [];
      _drawnCards = null;
      _lastReading = null;
      _aiReading = null;
      _revealed = false;
      _textVisible = false;
      _focused = 0;
      _newDiscoveries = const [];
      _showAll = false;
    });
  }

  /// Resumo da tiragem — o material que o Conselheiro lê, seja para o
  /// conselho completo ou para a degustação.
  String _readingSummary(OracleReading reading) {
    final page = ReadingArchiveComposer.oracle(reading);
    return '${page.title}\n${page.content}';
  }

  /// Interpretação do Conselheiro Místico (Premium): tece a leitura das
  /// cartas já escolhidas — mesmo fluxo do Tarot.
  Future<void> _askCounselor() async {
    final reading = _lastReading;
    if (reading == null || _isReadingAI) return;

    // Sem acesso o botão nem aparece: o card mostra a degustação no lugar.
    if (!context.read<AuthProvider>().isPremiumEffective) return;

    setState(() => _isReadingAI = true);
    try {
      final interpretation = await AIService.instance.interpretOracleSpread(
        summary: _readingSummary(reading),
      );
      // Uma resposta atrasada não pertence a outra mesa.
      if (!mounted || _lastReading?.id != reading.id) return;
      setState(() => _aiReading = interpretation);
      // Fica junto da tiragem: reabrir a mesa não pede outra geração.
      await _readings.attachInterpretation(
        readingId: reading.id, userId: _userId, interpretation: interpretation);
      // Mesmo id da leitura: reescreve a página que já está no acervo, com
      // o conselho junto — nunca cria uma segunda.
      await _archive.record(
        readingId: reading.id,
        userId: _userId,
        source: FreeWritingSource.oracle,
        page: ReadingArchiveComposer.oracle(
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
        title: ToolHeading(tool: ToolId.oracle,
            title: AppLocalizations.of(context).oracleTitle),
        backgroundColor: context.gc.darkBackground,
        actions: [
          // O álbum só lê o que as tiragens já registraram.
          IconButton(
            key: const ValueKey('oracle-album-open'),
            tooltip: AppLocalizations.of(context).oracleAlbumOpen,
            icon: const Icon(Icons.auto_stories),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const OracleAlbumPage(),
            )),
          ),
        ],
      ),
      backgroundColor: context.gc.darkBackground,
      body: ToolSceneFrame(child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_drawnCards == null) ...[
              MagicalCard(
                child: Column(
                  children: [
                    const Text('🔮', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).oracleTitle,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: context.gc.lilac,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).oracleSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.gc.softWhite.withValues(alpha: 0.8),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _buildSpreadOption(OracleSpreadType.daily),
              const SizedBox(height: 12),
              _buildSpreadOption(OracleSpreadType.threeCard),
              const SizedBox(height: 12),
              _buildSpreadOption(OracleSpreadType.weeklyGuidance),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                key: const ValueKey('oracle-draw'),
                onPressed: _isDrawing ? null : _drawCards,
                icon: _isDrawing
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
                    : const Icon(Icons.auto_awesome),
                label: Text(_isDrawing ? AppLocalizations.of(context).oracleDrawing : AppLocalizations.of(context).oracleDraw),
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
                      authProvider.currentUser.remainingOracleReadings;
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      AppLocalizations.of(context).oracleRemainingToday('$remaining/${UserModel.freeOracleReadingsLimit}'),
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
            if (_drawnCards != null) ...[
              _buildReadingResult(_drawnCards!),
              const SizedBox(height: 16),
              if (_lastReading != null) ...[
                _EntradaSuave(child: _buildCounselorCard()),
                const SizedBox(height: 8),
              ],
              OutlinedButton.icon(
                key: const ValueKey('oracle-new-reading'),
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

  Widget _buildSpreadOption(OracleSpreadType spread) {
    final isSelected = _selectedSpread == spread;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSpread = spread;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: GrimoireMotion.reduced(context)
            ? Duration.zero
            : GrimoireMotion.state,
        curve: GrimoireMotion.enter,
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
              Icons.style,
              color: context.gc.lilac,
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

  /// A carta da posição [index] na mesa: verso do leque até a revelação,
  /// frente ilustrada depois. O verso conserva o lugar original no leque.
  Widget _card(int index, double width) {
    final position = _drawnCards![index];
    final slot = index < _backPositions.length ? _backPositions[index] : index;
    return TarotFlipCard(
      key: ValueKey('oracle-flip-${_activeSession?.id}-$index'),
      revealed: _revealed,
      delay: Duration(milliseconds: _passoRevelacaoMs(_drawnCards!.length) * index),
      back: OracleCardBack(width: width, deckPosition: slot),
      // Numa tiragem de uma carta só, é aqui que a cena acontece: a mesa
      // faz o papel do palco, sem repetir a figura mais abaixo.
      front: _drawnCards!.length == 1
          ? OracleSceneCard(
              card: position.card,
              width: width,
              playToken: '${_activeSession?.id}-$_sceneToken',
              highlighted: _focused == index,
            )
          : OracleCardFace(card: position.card, width: width,
              highlighted: _focused == index),
    );
  }

  Widget _buildReadingResult(List<OracleCardPosition> positions) {
    final l10n = AppLocalizations.of(context);
    final reduced = GrimoireMotion.reduced(context);
    final focused = positions[_focused.clamp(0, positions.length - 1).toInt()];
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
            ],
          ),
        ),
        const SizedBox(height: 16),

        // A mesa: as cartas viram no lugar em que foram postas. Tocar uma
        // carta a traz para o palco (com sua cena) e destaca o texto.
        GestureDetector(
          key: const ValueKey('oracle-table'),
          behavior: HitTestBehavior.translucent,
          onTap: _skipAhead,
          child: MagicalCard(
            child: Column(children: [
              OracleSpreadBoard(
                spread: _selectedSpread,
                labels: positions.map((p) => p.positionMeaning).toList(),
                selectedPosition: positions.length > 1 ? _focused : null,
                onTap: _focusPosition,
                cardBuilder: _card,
              ),
              if (positions.length > 1) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.oracleTableHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.gc.textSecondary, fontSize: 12),
                ),
              ],
            ]),
          ),
        ),
        const SizedBox(height: 16),

        // O palco e o texto chegam depois das cartas assentarem.
        AnimatedSlide(
          offset: _textVisible ? Offset.zero : const Offset(0, .04),
          duration: reduced ? Duration.zero : GrimoireMotion.state,
          curve: GrimoireMotion.enter,
          child: AnimatedOpacity(
            key: const ValueKey('oracle-text'),
            opacity: _textVisible ? 1 : 0,
            duration: reduced ? Duration.zero : GrimoireMotion.state,
            child: IgnorePointer(
              ignoring: !_textVisible,
              child: ExcludeSemantics(
                excluding: !_textVisible,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_newDiscoveries.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Center(child: Container(
                        key: const ValueKey('oracle-discovery'),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: context.gc.gold.withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.gc.gold.withValues(alpha: .5)),
                        ),
                        child: Text(
                          l10n.oracleNewDiscovery(_newDiscoveries.length),
                          style: TextStyle(color: context.gc.gold, fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                    ],
                    const SizedBox(height: 16),
                    // A carta em foco e o que ela diz, no mesmo lugar: o
                    // palco existe para destacar UMA carta entre várias, e
                    // numa tiragem de uma carta só a mesa já é o palco.
                    ReadingFocusPanel(
                      keyPrefix: 'oracle',
                      index: _focused.clamp(0, positions.length - 1).toInt(),
                      total: positions.length,
                      onFocus: _focusPosition,
                      stage: positions.length > 1 ? _stage(focused) : null,
                      child: _focusBody(focused),
                    ),
                    // A tiragem inteira continua ali para quem quiser lê-la
                    // de ponta a ponta — fechada, para a página não voltar a
                    // ser uma pilha de cartões.
                    if (positions.length > 1) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton.icon(
                          key: const ValueKey('oracle-show-all'),
                          onPressed: () => setState(() => _showAll = !_showAll),
                          icon: Icon(_showAll
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down),
                          label: Text(_showAll
                              ? l10n.readingFocusHideAll
                              : l10n.readingFocusShowAll),
                        ),
                      ),
                      if (_showAll)
                        for (var i = 0; i < positions.length; i++)
                          _positionCard(i, positions[i]),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// A carta em foco, grande, num box de tamanho fixo — é por ser fixo que o
  /// texto trocando embaixo nunca a empurra.
  Widget _stage(OracleCardPosition position) {
    final reduced = GrimoireMotion.reduced(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? min(210.0, constraints.maxWidth * .62)
            : 210.0;
        return SizedBox(
          key: _stageKey,
          width: width,
          height: width / OracleCardFace.aspectRatio,
          child: AnimatedSwitcher(
            key: const ValueKey('oracle-stage'),
            duration: reduced ? Duration.zero : GrimoireMotion.state,
            switchInCurve: GrimoireMotion.enter,
            switchOutCurve: GrimoireMotion.exit,
            child: OracleSceneCard(
              key: ValueKey('$_focused-$_sceneToken'),
              card: position.card,
              width: width,
              playToken: '${_activeSession?.id}-$_focused-$_sceneToken',
            ),
          ),
        );
      },
    );
  }

  /// O que a carta em foco diz. É o miolo do antigo cartão de posição, sem a
  /// moldura e sem a miniatura: a figura já está grande logo acima.
  Widget _focusBody(OracleCardPosition position) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          container: true,
          liveRegion: true,
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
                position.card.name,
                style: TextStyle(
                  color: context.gc.lilac,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          position.card.message,
          style: TextStyle(
            color: context.gc.softWhite.withValues(alpha: 0.8),
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 12),
        Divider(color: context.gc.lilac),
        const SizedBox(height: 8),
        Text(
          position.card.guidance,
          style: TextStyle(color: context.gc.softWhite, height: 1.5),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final keyword in position.card.keywords)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.gc.lilac.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: context.gc.lilac.withValues(alpha: 0.5)),
                ),
                child: Text(
                  keyword,
                  style: TextStyle(color: context.gc.lilac, fontSize: 12),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _positionCard(int index, OracleCardPosition position) {
    final highlighted = _focused == index && _drawnCards!.length > 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
                  // A miniatura ajuda a distinguir uma posição entre várias.
                  // Com uma carta só, ela seria a terceira vez que a mesma
                  // figura aparece na tela.
                  if (_drawnCards!.length > 1) ...[
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.gc.lilac,
                            context.gc.lilac.withValues(alpha: 0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          position.card.emoji,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
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
                          position.card.name,
                          style: TextStyle(
                            color: context.gc.lilac,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          position.card.message,
                          style: TextStyle(
                            color: context.gc.softWhite.withValues(alpha: 0.8),
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: context.gc.lilac),
              const SizedBox(height: 8),
              Text(
                position.card.guidance,
                style: TextStyle(
                  color: context.gc.softWhite,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: position.card.keywords.map((keyword) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.gc.lilac.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.gc.lilac.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      keyword,
                      style: TextStyle(
                        color: context.gc.lilac,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
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
            // Conselheiro teceria sobre as cartas que já estão na mesa.
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

/// Entrada de um bloco que chega DEPOIS: opacidade 0 → 1 e subida de 8 px,
/// uma vez, na montagem.
///
/// O Conselheiro só existe depois que a leitura foi gravada no banco — um
/// rebuild que acontece instantes após as cartas. Sem isto ele pipoca na
/// tela, do nada.
class _EntradaSuave extends StatelessWidget {
  final Widget child;

  const _EntradaSuave({required this.child});

  @override
  Widget build(BuildContext context) {
    if (GrimoireMotion.reduced(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: GrimoireMotion.state,
      curve: GrimoireMotion.enter,
      builder: (context, t, inner) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 8),
          child: inner,
        ),
      ),
      child: child,
    );
  }
}
