import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import '../../../../core/sharing/image_download_stub.dart'
    if (dart.library.js_interop) '../../../../core/sharing/image_download_web.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/magical_button.dart';
import '../../data/models/sigil_model.dart';
import '../../data/models/sigil_wheel_model.dart';
import '../widgets/witch_wheel_painter.dart';
import '../widgets/sigil_drawing_painter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../../diary/data/models/desire_model.dart';
import '../../../diary/presentation/providers/desire_provider.dart';
import '../../../journeys/domain/action_outcome.dart';
import '../../../journeys/domain/action_recorder.dart';

/// Etapa 3: Mostrar desenho do sigilo com a Roda das Bruxas
class SigilStep3DrawingPage extends StatefulWidget {
  final Sigil sigil;

  const SigilStep3DrawingPage({
    super.key,
    required this.sigil,
  });

  @override
  State<SigilStep3DrawingPage> createState() => _SigilStep3DrawingPageState();
}

class _SigilStep3DrawingPageState extends State<SigilStep3DrawingPage>
    with TickerProviderStateMixin {
  bool _showWheel = true;
  bool _showStartEnd = true;
  bool _isShuffled = false;
  bool _isExporting = false;

  /// Delimita a área do desenho para exportar exatamente o que está na tela
  /// (com/sem roda, com/sem pontos).
  final GlobalKey _drawingKey = GlobalKey();
  Map<String, WheelPosition>? _shuffledPositions;

  /// Arranjo de onde as letras estão saindo enquanto se reorganizam.
  Map<String, WheelPosition>? _previousPositions;
  bool _isSaving = false;

  /// Ids criados UMA vez por tela, e não a cada toque: se a gravação falhar
  /// no meio e ela tocar em "Finalizar" de novo, a repetição reescreve as
  /// mesmas duas linhas em vez de fazer nascer um segundo sigilo e uma
  /// segunda página no Diário.
  final String _sigilId = const Uuid().v4();
  final String _desireId = const Uuid().v4();

  /// O traço percorrendo os pontos da roda, uma vez.
  late final AnimationController _trace = AnimationController(
      vsync: this, duration: GrimoireMotion.celebration);

  /// A reorganização das letras: interpola do arranjo anterior para o novo.
  late final AnimationController _blend = AnimationController(
      vsync: this, duration: GrimoireMotion.reveal, value: 1);
  bool _traceStarted = false;

  @override
  void initState() {
    super.initState();
    _blend.addStatusListener((status) {
      // Terminada a viagem, só o arranjo novo importa (e volta a ser
      // reaproveitado o percurso já medido).
      if (status == AnimationStatus.completed && _previousPositions != null) {
        setState(() => _previousPositions = null);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (GrimoireMotion.reduced(context)) {
      _trace.value = 1;
      _blend.value = 1;
      _traceStarted = true;
    } else if (!_traceStarted) {
      _traceStarted = true;
      _trace.forward();
    }
  }

  @override
  void dispose() {
    _trace.dispose();
    _blend.dispose();
    super.dispose();
  }

  /// Antecipa: o símbolo assenta agora, no mesmo estado final de sempre.
  void _finishTrace() {
    if (_trace.value >= 1 && _blend.value >= 1) return;
    // Os pintores escutam os dois controladores: mexer no valor já repinta,
    // e o estado só muda para soltar o arranjo antigo.
    _trace
      ..stop()
      ..value = 1;
    _blend
      ..stop()
      ..value = 1;
    if (_previousPositions != null) setState(() => _previousPositions = null);
  }

  /// Refaz o traçado do início. O resultado final não muda.
  void _replayTrace() {
    if (GrimoireMotion.reduced(context)) {
      setState(() => _trace.value = 1);
      return;
    }
    _trace.forward(from: 0);
  }

  /// Toda captura de imagem usa o símbolo inteiro: o traço vai ao fim e um
  /// quadro é pintado antes de ler os pixels, nunca um traçado pela metade.
  Future<void> _settleForCapture() async {
    final settled = _trace.value >= 1 && _blend.value >= 1;
    _finishTrace();
    if (!settled) await WidgetsBinding.instance.endOfFrame;
  }

  /// "Finalizar" faz o trabalho inteiro: guarda o sigilo E cria a página dele
  /// no Diário de Desejos. Sem a segunda gravação a confirmação anunciava uma
  /// guarda que ela nunca encontrava — a tabela `sigils` não é listada em
  /// tela nenhuma, ela só é contada, exportada e lida pela Leitura de Ciclo;
  /// o único acervo onde um sigilo vira página visível é o Diário.
  ///
  /// A ordem é deliberada (persistir primeiro, apresentar depois): a imagem é
  /// capturada ANTES de qualquer escrita, para que uma falha de captura não
  /// deixe metade guardada, e a confirmação só sai depois das DUAS gravações,
  /// para que a frase nunca chegue antes do fato.
  Future<void> _saveAndFinish() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    // Tudo que depende do contexto é lido antes dos awaits: a confirmação
    // continua acima do roteador mesmo depois que esta tela fechar.
    final recorder = ActionRecorder.of(context);
    final l10n = AppLocalizations.of(context);
    final userId = context.read<AuthProvider>().currentUser.id;
    // Nulável de propósito, como o ActionRecorder: uma árvore montada sem o
    // provider (teste de widget, tela destacada) não pode explodir por isso.
    final desireProvider = context.read<DesireProvider?>();
    // Capturados antes do await: avisar do que aconteceu não pode depender de
    // a tela ainda estar montada.
    final messenger = ScaffoldMessenger.of(context);
    final alertColor = context.gc.alert;
    final successColor = context.gc.success;
    try {
      await _settleForCapture();
      final boundary = _drawingKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception(l10n.sigilDrawingNotReady);
      }
      // Miniatura leve (~320px): a imagem vai como base64 na descrição do
      // desejo, que sincroniza como texto. Uma resolução menor mantém o
      // sigilo legível no card e evita payloads grandes que falham no sync.
      // (A exportação para a galeria continua em alta resolução.)
      const targetWidth = 320.0;
      final logicalWidth = boundary.size.width;
      final ratio = logicalWidth > 0 ? targetWidth / logicalWidth : 1.0;
      final image = await boundary.toImage(pixelRatio: ratio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception(l10n.sigilImageError);
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final data = <String, dynamic>{
        'id': _sigilId,
        'user_id': userId,
        'intention': widget.sigil.intention,
        'image_path': jsonEncode({
          'letters': widget.sigil.processedLetters,
          'points': widget.sigil.points
              .map((point) => {'x': point.dx, 'y': point.dy})
              .toList(),
        }),
        'created_at': now,
        'updated_at': now,
        'synced': 0,
      };
      final db = await DatabaseHelper.instance.database;
      // Substituir em vez de inserir outra: uma segunda tentativa reescreve a
      // linha do mesmo id, nunca duplica o sigilo.
      await db.insert('sigils', data,
          conflictAlgorithm: ConflictAlgorithm.replace);
      await DataSyncService().syncItem(SyncEntity.sigils, data);

      // Título fixo — a intenção do sigilo é secreta e não pode aparecer na
      // lista do Diário; quem vai é o desenho, como PNG dentro da descrição.
      // O DesireRepository também grava por substituição, então repetir com o
      // mesmo id reescreve a página em vez de criar outra.
      final desire = DesireModel(
        id: _desireId,
        title: l10n.diaryDesireSigilTitle,
        description:
            DesireModel.encodeSigilImage(byteData.buffer.asUint8List()),
      );
      final saved = await desireProvider?.addDesire(desire);
      if (saved == false) {
        throw Exception(desireProvider?.error ?? l10n.errorsGeneric);
      }

      // UM registro só, e depois das duas gravações: o coordenador RECALCULA
      // o XP em vez de somar, então um único cartão já mostra o total das
      // duas linhas — um segundo registro apareceria com +0.
      unawaited(
          recorder.record(origin: ActionOrigin.sigil, entityId: _sigilId));
      // O cartão global confirma a guarda; esta linha diz ONDE ela reencontra
      // o sigilo, que é justamente o que faltava. Só aparece se a página do
      // Diário existir de verdade.
      if (saved == true) {
        messenger.showSnackBar(SnackBar(
          content: Text(l10n.sigilSavedToDesires),
          backgroundColor: successColor,
        ));
      }
    } catch (e) {
      // O aviso sai pelo messenger guardado ANTES do await, e não depende de
      // `mounted`: se ela já tiver saído da tela no meio da gravação, a falha
      // continua sendo dita em vez de sumir em silêncio.
      // O 'Exception: ' que o Dart prefixa não diz nada a ela.
      final motivo = '$e'.replaceAll('Exception: ', '');
      messenger.showSnackBar(SnackBar(
        content: Text('${l10n.sigilSaveError}: $motivo'),
        backgroundColor: alertColor,
      ));
      // Volta a aceitar toque: os ids são campos do State, então repetir o
      // Finalizar reescreve as mesmas duas linhas em vez de criar um segundo
      // sigilo e uma segunda página.
      if (mounted) setState(() => _isSaving = false);
      return;
    }
    // Fechar a rota fica FORA do try de propósito: com tudo já guardado e a
    // confirmação já dada, uma exceção ao sair (rota trocada por baixo) viraria
    // um "falha ao salvar" mentiroso na tela.
    if (mounted) Navigator.pop(context, true);
  }

  /// Exporta o desenho atual como PNG para a galeria (exclusivo Premium).
  Future<void> _exportToGallery() async {
    if (_isExporting) return;

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isPremiumEffective) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const PremiumUpgradeSheet(),
      );
      return;
    }

    // l10n capturado antes dos awaits (use_build_context_synchronously).
    final l10n = AppLocalizations.of(context);
    setState(() => _isExporting = true);
    try {
      await _settleForCapture();
      final boundary = _drawingKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception(l10n.sigilDrawingNotReady);
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception(l10n.sigilImageError);
      }

      final name =
          'sigilo_${DateTime.now().millisecondsSinceEpoch}';

      // O Gal fala com a galeria do sistema, que não existe no navegador:
      // ali o equivalente é o arquivo cair na pasta de downloads.
      if (kIsWeb) {
        await downloadBytes(byteData.buffer.asUint8List(), '$name.png',
            mimeType: 'image/png');
      } else {
        await Gal.putImageBytes(byteData.buffer.asUint8List(), name: name);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            kIsWeb
                ? AppLocalizations.of(context).shareImageDownloaded
                : AppLocalizations.of(context).sigilSavedToGallery,
          ),
          backgroundColor: context.gc.success,
        ),
      );
    } on GalException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.type == GalExceptionType.accessDenied
                ? AppLocalizations.of(context).sigilGalleryPermission
                : AppLocalizations.of(context).sigilImageSaveError,
          ),
          backgroundColor: context.gc.alert,
        ),
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
      if (mounted) setState(() => _isExporting = false);
    }
  }

  /// Embaralha as posições das letras na roda (como no "Sigilo Nada" do livro).
  /// As letras deslizam do arranjo anterior para o novo e o traço acompanha.
  void _shuffleLetters() {
    _rearrange(SigilWheel.generateShuffledPositions(), shuffled: true);
  }

  /// Restaura as posições originais das letras
  void _resetLetters() {
    _rearrange(null, shuffled: false);
  }

  void _rearrange(Map<String, WheelPosition>? positions, {required bool shuffled}) {
    setState(() {
      _previousPositions = _shuffledPositions ?? SigilWheel.letterPositions;
      _isShuffled = shuffled;
      _shuffledPositions = positions;
      // O traço já percorrido continua onde está; só a geometria viaja.
      if (_trace.value < 1) _trace.value = 1;
    });
    if (GrimoireMotion.reduced(context)) {
      setState(() {
        _blend.value = 1;
        _previousPositions = null;
      });
    } else {
      _blend.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.gc.background,
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).sigilYourSigil),
        backgroundColor: context.gc.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título
            Text(
              AppLocalizations.of(context).sigilYourDrawing,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.sigil.intention,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: context.gc.lilac,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Área do desenho
            MagicalCard(
              child: Column(
                children: [
                  // Desenho do sigilo. Tocar antecipa: o símbolo assenta no
                  // mesmo estado final, sem esperar o traço terminar.
                  // O quadro acompanha a largura disponível: num telefone
                  // estreito ele encolhe inteiro. A roda e os pontos são
                  // calculados a partir do tamanho real do canvas, então o
                  // desenho é o mesmo em qualquer tela — e a exportação
                  // também.
                  LayoutBuilder(
                    builder: (context, constraints) => _drawing(
                      context,
                      constraints.maxWidth.isFinite
                          ? constraints.maxWidth.clamp(0.0, 360.0).toDouble()
                          : 360.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _trace,
                    builder: (context, _) => AnimatedOpacity(
                      opacity: _trace.value < 1 ? 1 : 0,
                      duration: GrimoireMotion.state,
                      child: Text(
                        AppLocalizations.of(context).sigilTraceHint,
                        key: const ValueKey('sigil-trace-hint'),
                        style: TextStyle(
                          color: context.gc.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Legenda
                  if (_showStartEnd) ...[
                    // Três legendas traduzidas: em telas estreitas elas
                    // passam para a linha de baixo em vez de estourar.
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 6,
                      children: [
                        _buildLegendItem(Colors.green.shade300, AppLocalizations.of(context).sigilLegendStart),
                        _buildLegendItem(context.gc.lilac, AppLocalizations.of(context).sigilLegendLetters),
                        _buildLegendItem(Colors.red.shade300, AppLocalizations.of(context).sigilLegendEnd),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Controles de visualização: sempre em uma unica linha,
                  // centralizados. Se nao couberem, o FittedBox reduz tudo
                  // proporcionalmente em vez de estourar ou quebrar a linha.
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _showWheel
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  size: 16,
                                  color: _showWheel
                                      ? context.gc.lilac
                                      : context.gc.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(AppLocalizations.of(context).sigilWheel),
                              ],
                            ),
                            selected: _showWheel,
                            onSelected: (value) {
                              setState(() {
                                _showWheel = value;
                              });
                            },
                            selectedColor: context.gc.lilac.withValues(alpha: 0.2),
                            backgroundColor: context.gc.surface,
                            labelStyle: TextStyle(
                              color: _showWheel
                                  ? context.gc.lilac
                                  : context.gc.textSecondary,
                              fontSize: 12,
                            ),
                            side: BorderSide(
                              color: _showWheel
                                  ? context.gc.lilac
                                  : Colors.transparent,
                            ),
                            showCheckmark: false,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _showStartEnd
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  size: 16,
                                  color: _showStartEnd
                                      ? context.gc.starYellow
                                      : context.gc.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(AppLocalizations.of(context).sigilPoints),
                              ],
                            ),
                            selected: _showStartEnd,
                            onSelected: (value) {
                              setState(() {
                                _showStartEnd = value;
                              });
                            },
                            selectedColor:
                                context.gc.starYellow.withValues(alpha: 0.2),
                            backgroundColor: context.gc.surface,
                            labelStyle: TextStyle(
                              color: _showStartEnd
                                  ? context.gc.starYellow
                                  : context.gc.textSecondary,
                              fontSize: 12,
                            ),
                            side: BorderSide(
                              color: _showStartEnd
                                  ? context.gc.starYellow
                                  : Colors.transparent,
                            ),
                            showCheckmark: false,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            key: const ValueKey('sigil-trace-replay'),
                            onPressed: _replayTrace,
                            icon: const Icon(Icons.replay, size: 20),
                            tooltip: AppLocalizations.of(context).sigilTraceReplay,
                            style: IconButton.styleFrom(
                              backgroundColor: context.gc.surface,
                              foregroundColor: context.gc.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: _shuffleLetters,
                            icon: const Icon(Icons.shuffle, size: 20),
                            tooltip: AppLocalizations.of(context).sigilShuffle,
                            style: IconButton.styleFrom(
                              backgroundColor: _isShuffled
                                  ? context.gc.mint.withValues(alpha: 0.3)
                                  : context.gc.surface,
                              foregroundColor: _isShuffled
                                  ? context.gc.mint
                                  : context.gc.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: _isExporting ? null : _exportToGallery,
                            icon: _isExporting
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: context.gc.lilac,
                                    ),
                                  )
                                : const Icon(Icons.download, size: 20),
                            tooltip:
                                AppLocalizations.of(context).sigilSaveImage,
                            style: IconButton.styleFrom(
                              backgroundColor: context.gc.surface,
                              foregroundColor: context.gc.textSecondary,
                            ),
                          ),
                          if (_isShuffled) ...[
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed: _resetLetters,
                              icon: const Icon(Icons.restart_alt, size: 20),
                              tooltip:
                                  AppLocalizations.of(context).sigilRestore,
                              style: IconButton.styleFrom(
                                backgroundColor: context.gc.surface,
                                foregroundColor: context.gc.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Informações
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🎨', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      // O título é traduzido: numa tela estreita ele quebra
                      // a linha em vez de estourar o cartão.
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).sigilHowToUse,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStep(
                    AppLocalizations.of(context).sigilUse1Title,
                    AppLocalizations.of(context).sigilUse1Desc,
                  ),
                  _buildStep(
                    AppLocalizations.of(context).sigilUse2Title,
                    AppLocalizations.of(context).sigilUse2Desc,
                  ),
                  _buildStep(
                    AppLocalizations.of(context).sigilUse3Title,
                    AppLocalizations.of(context).sigilUse3Desc,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.gc.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: context.gc.starYellow.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('✨', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context).sigilRemember,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: context.gc.textSecondary,
                                      fontStyle: FontStyle.italic,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botão finalizar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MagicalButton(
                text: _isSaving ? AppLocalizations.of(context).commonSaving : AppLocalizations.of(context).commonFinish,
                onPressed: _saveAndFinish,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// O quadro do desenho, do tamanho que couber (até 360). A roda e os
  /// pontos vêm do tamanho real do canvas, então o símbolo é o mesmo em
  /// qualquer tela — e a exportação também. Tocar antecipa o traçado.
  Widget _drawing(BuildContext context, double side) {
    return GestureDetector(
    onTap: _finishTrace,
    child: Semantics(
      label: AppLocalizations.of(context).sigilDrawingSemantics,
      child: RepaintBoundary(
        key: _drawingKey,
        child: Container(
          width: side,
          height: side,
          decoration: BoxDecoration(
            color: context.gc.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnimatedBuilder(
            animation: Listenable.merge([_trace, _blend]),
            builder: (context, _) => CustomPaint(
              key: const ValueKey('sigil-drawing'),
              size: Size(side, side),
              painter: _showWheel
                  ? WitchWheelPainter(
                      borderColor: context.gc.surfaceBorder,
                      starColor: context.gc.starYellow,
                      accentColor: context.gc.lilac,
                      showLetters: true,
                      highlightedLetters: widget
                          .sigil.processedLetters
                          .split('')
                          .toSet(),
                      customPositions: _shuffledPositions,
                      previousPositions: _previousPositions,
                      blend: _blend.value,
                    )
                  : null,
              foregroundPainter: SigilDrawingPainter(
                lineColor: context.gc.starYellow,
                pointColor: context.gc.lilac,
                intention: widget.sigil.intention,
                showStartEnd: _showStartEnd,
                customPositions: _shuffledPositions,
                previousPositions: _previousPositions,
                blend: _blend.value,
                progress: _trace.value,
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: context.gc.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStep(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.gc.lilac,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: context.gc.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
