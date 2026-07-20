import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
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

class _SigilStep3DrawingPageState extends State<SigilStep3DrawingPage> {
  bool _showWheel = true;
  bool _showStartEnd = true;
  bool _isShuffled = false;
  bool _isExporting = false;

  /// Delimita a área do desenho para exportar exatamente o que está na tela
  /// (com/sem roda, com/sem pontos).
  final GlobalKey _drawingKey = GlobalKey();
  Map<String, WheelPosition>? _shuffledPositions;
  bool _isSaving = false;

  Future<void> _saveAndFinish() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final data = <String, dynamic>{
        'id': const Uuid().v4(),
        'user_id': context.read<AuthProvider>().currentUser.id,
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
      await db.insert('sigils', data);
      await DataSyncService().syncItem(SyncEntity.sigils, data);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.sigilSaveError}: $e')),
      );
    }
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

    setState(() => _isExporting = true);
    try {
      final boundary = _drawingKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception(AppLocalizations.of(context)!.sigilDrawingNotReady);
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception(AppLocalizations.of(context)!.sigilImageError);
      }

      final name =
          'sigilo_${DateTime.now().millisecondsSinceEpoch}';
      await Gal.putImageBytes(
        byteData.buffer.asUint8List(),
        name: name,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.sigilSavedToGallery),
          backgroundColor: context.gc.success,
        ),
      );
    } on GalException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.type == GalExceptionType.accessDenied
                ? AppLocalizations.of(context)!.sigilGalleryPermission
                : AppLocalizations.of(context)!.sigilImageSaveError,
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

  /// Salva o sigilo no Diário de Desejos como IMAGEM (Premium, sincroniza na
  /// nuvem via DesireProvider/DataSyncService). Guardamos o PNG do desenho —
  /// não um texto — justamente por se tratar de um sigilo.
  Future<void> _saveToDesires() async {
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

    final l10n = AppLocalizations.of(context)!;
    try {
      final boundary = _drawingKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception(l10n.sigilDrawingNotReady);
      }
      // Mesma captura da exportação para galeria: gera a imagem exatamente
      // como o usuário deixou (roda, letras e pontos visíveis ou não).
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception(l10n.sigilImageError);
      }
      // Título fixo — a intenção do sigilo é secreta e não pode aparecer.
      final desire = DesireModel(
        title: l10n.diaryDesireSigilTitle,
        description:
            DesireModel.encodeSigilImage(byteData.buffer.asUint8List()),
      );
      await context.read<DesireProvider>().addDesire(desire);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.sigilSavedToDesires),
          backgroundColor: context.gc.success,
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
    }
  }

  /// Embaralha as posições das letras na roda (como no "Sigilo Nada" do livro)
  void _shuffleLetters() {
    setState(() {
      _isShuffled = true;
      _shuffledPositions = SigilWheel.generateShuffledPositions();
    });
  }

  /// Restaura as posições originais das letras
  void _resetLetters() {
    setState(() {
      _isShuffled = false;
      _shuffledPositions = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.gc.background,
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context)!.sigilYourSigil),
        backgroundColor: context.gc.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título
            Text(
              AppLocalizations.of(context)!.sigilYourDrawing,
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
                  // Desenho do sigilo
                  RepaintBoundary(
                    key: _drawingKey,
                    child: Container(
                    width: 360,
                    height: 360,
                    decoration: BoxDecoration(
                      color: context.gc.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomPaint(
                      size: const Size(360, 360),
                      painter: _showWheel
                          ? WitchWheelPainter(
                              borderColor: context.gc.surfaceBorder,
                              starColor: context.gc.starYellow,
                              accentColor: context.gc.lilac,
                              showLetters: true,
                              highlightedLetters: widget.sigil.processedLetters
                                  .split('')
                                  .toSet(),
                              customPositions: _shuffledPositions,
                            )
                          : null,
                      foregroundPainter: SigilDrawingPainter(
                        lineColor: context.gc.starYellow,
                        pointColor: context.gc.lilac,
                        intention: widget.sigil.intention,
                        showStartEnd: _showStartEnd,
                        customPositions: _shuffledPositions,
                      ),
                    ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Legenda
                  if (_showStartEnd) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(Colors.green.shade300, AppLocalizations.of(context)!.sigilLegendStart),
                        const SizedBox(width: 16),
                        _buildLegendItem(context.gc.lilac, AppLocalizations.of(context)!.sigilLegendLetters),
                        const SizedBox(width: 16),
                        _buildLegendItem(Colors.red.shade300, AppLocalizations.of(context)!.sigilLegendEnd),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Controles de visualização (todos lado a lado)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                            Text(AppLocalizations.of(context)!.sigilWheel),
                          ],
                        ),
                        selected: _showWheel,
                        onSelected: (value) {
                          setState(() {
                            _showWheel = value;
                          });
                        },
                        selectedColor: context.gc.lilac.withOpacity(0.2),
                        backgroundColor: context.gc.surface,
                        labelStyle: TextStyle(
                          color: _showWheel
                              ? context.gc.lilac
                              : context.gc.textSecondary,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color:
                              _showWheel ? context.gc.lilac : Colors.transparent,
                        ),
                        showCheckmark: false,
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
                            Text(AppLocalizations.of(context)!.sigilPoints),
                          ],
                        ),
                        selected: _showStartEnd,
                        onSelected: (value) {
                          setState(() {
                            _showStartEnd = value;
                          });
                        },
                        selectedColor: context.gc.starYellow.withOpacity(0.2),
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
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _shuffleLetters,
                        icon: const Icon(Icons.shuffle, size: 20),
                        tooltip: AppLocalizations.of(context)!.sigilShuffle,
                        style: IconButton.styleFrom(
                          backgroundColor: _isShuffled
                              ? context.gc.mint.withOpacity(0.3)
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
                        tooltip: AppLocalizations.of(context)!.sigilSaveImage,
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
                          tooltip: AppLocalizations.of(context)!.sigilRestore,
                          style: IconButton.styleFrom(
                            backgroundColor: context.gc.surface,
                            foregroundColor: context.gc.textSecondary,
                          ),
                        ),
                      ],
                    ],
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
                      Text(
                        AppLocalizations.of(context)!.sigilHowToUse,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStep(
                    AppLocalizations.of(context)!.sigilUse1Title,
                    AppLocalizations.of(context)!.sigilUse1Desc,
                  ),
                  _buildStep(
                    AppLocalizations.of(context)!.sigilUse2Title,
                    AppLocalizations.of(context)!.sigilUse2Desc,
                  ),
                  _buildStep(
                    AppLocalizations.of(context)!.sigilUse3Title,
                    AppLocalizations.of(context)!.sigilUse3Desc,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.gc.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: context.gc.starYellow.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('✨', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.sigilRemember,
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

            // Salvar o sigilo no Diário de Desejos (Premium, sincroniza).
            // Padding horizontal de 16 para acompanhar a largura dos cards
            // (o MagicalCard tem margem lateral própria de 16).
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: _saveToDesires,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: Text(AppLocalizations.of(context)!.sigilSaveToDesires),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.gc.lilac,
                  side: BorderSide(color: context.gc.lilac.withOpacity(0.5)),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Botão finalizar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MagicalButton(
                text: _isSaving ? AppLocalizations.of(context)!.commonSaving : AppLocalizations.of(context)!.commonFinish,
                onPressed: _saveAndFinish,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
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
